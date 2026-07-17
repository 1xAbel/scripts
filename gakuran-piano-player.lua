-- Re-executing the script safely shuts down the previous copy.
if _G.MatchaPianoCleanup then
    pcall(_G.MatchaPianoCleanup)
end

_G.MatchaPianoRunId = (_G.MatchaPianoRunId or 0) + 1
local RunId = _G.MatchaPianoRunId

local Config = {
    ToggleKey = 0xBA, -- ;
    FasterKey = 0x26, -- Up Arrow
    SlowerKey = 0x28, -- Down Arrow
    PanicKey = 0x7B,  -- F12: stop and release every simulated key

    BPM = 120,
    BPMStep = 5,
    MinimumBPM = 30,
    MaximumBPM = 400,

    BeatsPerBar = 4,

    -- 0 means automatic. You can force 2 for 8-slot sheets
    -- or 4 for 16-slot sheets if detection ever sounds wrong.
    StepsPerBeat = 0,

    -- Safety limits. These prevent a bad timing guess from flooding
    -- Matcha with thousands of key events per second.
    MinimumStepsPerBeat = 1,
    MaximumStepsPerBeat = 8,
    MinimumSlotTime = 0.025,

    -- Notes are tapped briefly instead of physically held for the
    -- whole slot. This greatly reduces stuck keys and PC/input lag.
    KeyHoldTime = 0.018,

    -- Lower polling/chunk rates keep the executor responsive.
    ControlPollTime = 0.05,
    CancelCheckTime = 0.05,
}

--------------------------------------------------
-- Matcha load notification
--------------------------------------------------

local function ShowLoadNotification()
    local ok = pcall(function()
        notify(
            "; Play/Stop | Up/Down BPM | F12 emergency stop | BPM: "
                .. tostring(Config.BPM),
            "Piano Player Loaded",
            7
        )
    end)

    if not ok then
        print("Piano Player Loaded")
        print("; = Play/Stop | Up/Down = BPM | F12 = Emergency Stop")
    end
end

ShowLoadNotification()

local SHIFT = 0x10

local VK = {
    ["0"] = 0x30, ["1"] = 0x31, ["2"] = 0x32, ["3"] = 0x33,
    ["4"] = 0x34, ["5"] = 0x35, ["6"] = 0x36, ["7"] = 0x37,
    ["8"] = 0x38, ["9"] = 0x39,

    ["a"] = 0x41, ["b"] = 0x42, ["c"] = 0x43, ["d"] = 0x44,
    ["e"] = 0x45, ["f"] = 0x46, ["g"] = 0x47, ["h"] = 0x48,
    ["i"] = 0x49, ["j"] = 0x4A, ["k"] = 0x4B, ["l"] = 0x4C,
    ["m"] = 0x4D, ["n"] = 0x4E, ["o"] = 0x4F, ["p"] = 0x50,
    ["q"] = 0x51, ["r"] = 0x52, ["s"] = 0x53, ["t"] = 0x54,
    ["u"] = 0x55, ["v"] = 0x56, ["w"] = 0x57, ["x"] = 0x58,
    ["y"] = 0x59, ["z"] = 0x5A,
}

local ShiftedSymbols = {
    ["!"] = "1", ["@"] = "2", ["#"] = "3", ["$"] = "4",
    ["%"] = "5", ["^"] = "6", ["&"] = "7", ["*"] = "8",
    ["("] = "9", [")"] = "0",
}

local function Clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end

local function ResolveKey(character)
    local shiftedNumber = ShiftedSymbols[character]

    if shiftedNumber then
        return VK[shiftedNumber], true
    end

    local lower = character:lower()
    local vk = VK[lower]

    if not vk then
        return nil, false
    end

    local needsShift =
        character:match("%a") ~= nil
        and character == character:upper()

    return vk, needsShift
end

--------------------------------------------------
-- Parse sheet into safe timing slots
--------------------------------------------------

local Slots = {}
local ExplicitBarSizes = {}
local LineSizes = {}
local CurrentExplicitBarSize = 0
local HasExplicitBars = false

local function AddSlot(slot)
    Slots[#Slots + 1] = slot
    CurrentExplicitBarSize = CurrentExplicitBarSize + 1
end

local function ParseNotes(token)
    local content = token

    if token:sub(1, 1) == "["
        and token:sub(-1, -1) == "]" then
        content = token:sub(2, -2)
    end

    local notes = {}

    for i = 1, #content do
        local character = content:sub(i, i)

        -- Never let timing symbols become keyboard notes.
        if character ~= "-"
            and character ~= "_"
            and character ~= "|" then
            notes[#notes + 1] = character
        end
    end

    return notes
end

local function AddToken(token)
    if token == "" then
        return 0
    end

    -- Every dash or underscore is one silent timing slot.
    -- This supports -, --, ----, _, __, and so on.
    if token:match("^[%-%_]+$") then
        local added = 0

        for i = 1, #token do
            local character = token:sub(i, i)

            if character == "-" or character == "_" then
                AddSlot({ Type = "Rest" })
                added = added + 1
            end
        end

        return added
    end

    local notes = ParseNotes(token)

    if #notes > 0 then
        AddSlot({
            Type = "Notes",
            Notes = notes,
        })

        return 1
    end

    return 0
end

local function FinishExplicitBar()
    HasExplicitBars = true

    if CurrentExplicitBarSize > 0 then
        ExplicitBarSizes[#ExplicitBarSizes + 1] = CurrentExplicitBarSize
        CurrentExplicitBarSize = 0
    end
end

local SongText = Song

if type(SongText) ~= "string" then
    SongText = ""
    warn("Song was not a string, so an empty sheet was loaded.")
end

local NormalizedSong = string.gsub(
    string.gsub(SongText, "\r\n", "\n"),
    "\r",
    "\n"
)

for line in (NormalizedSong .. "\n"):gmatch("(.-)\n") do
    local lineSize = 0

    for rawToken in line:gmatch("%S+") do
        local _, barCount = string.gsub(rawToken, "|", "")
        local token = string.gsub(rawToken, "|", "")

        lineSize = lineSize + AddToken(token)

        for _ = 1, barCount do
            FinishExplicitBar()
        end
    end

    if lineSize > 0 then
        LineSizes[#LineSizes + 1] = lineSize
    end
end

if HasExplicitBars and CurrentExplicitBarSize > 0 then
    ExplicitBarSizes[#ExplicitBarSizes + 1] = CurrentExplicitBarSize
end

--------------------------------------------------
-- Safe timing detection
--------------------------------------------------

local function Median(values)
    if #values == 0 then
        return nil
    end

    local copy = {}

    for i = 1, #values do
        copy[i] = values[i]
    end

    table.sort(copy)

    local middle = math.floor(#copy / 2)

    if #copy % 2 == 1 then
        return copy[middle + 1]
    end

    return (copy[middle] + copy[middle + 1]) / 2
end

local CommonSlotsPerBar = { 4, 6, 8, 12, 16, 24, 32 }

local function SnapToCommonGrid(value)
    local closest = CommonSlotsPerBar[1]
    local closestDistance = math.abs(value - closest)

    for i = 2, #CommonSlotsPerBar do
        local candidate = CommonSlotsPerBar[i]
        local distance = math.abs(value - candidate)

        if distance < closestDistance then
            closest = candidate
            closestDistance = distance
        end
    end

    return closest
end

local TimingSource
local TimingSamples

if HasExplicitBars and #ExplicitBarSizes > 0 then
    TimingSource = "explicit | bars"
    TimingSamples = ExplicitBarSizes
else
    TimingSource = "line estimate"
    TimingSamples = LineSizes
end

local RawSlotsPerBar =
    Median(TimingSamples)
    or (Config.BeatsPerBar * 2)

local DetectedSlotsPerBar = SnapToCommonGrid(RawSlotsPerBar)
local StepsPerBeat

if Config.StepsPerBeat > 0 then
    StepsPerBeat = Config.StepsPerBeat
else
    StepsPerBeat = DetectedSlotsPerBar / Config.BeatsPerBar
end

StepsPerBeat = Clamp(
    StepsPerBeat,
    Config.MinimumStepsPerBeat,
    Config.MaximumStepsPerBeat
)

local function GetSlotTime()
    local calculated = (60 / Config.BPM) / StepsPerBeat
    return math.max(calculated, Config.MinimumSlotTime)
end

--------------------------------------------------
-- Safe keyboard handling
--------------------------------------------------

local HeldKeys = {}
local WarnedUnsupported = {}

local function SafeKeyPress(vk)
    if not vk or HeldKeys[vk] then
        return
    end

    HeldKeys[vk] = true

    local ok, err = pcall(function()
        keypress(vk)
    end)

    if not ok then
        HeldKeys[vk] = nil
        print("keypress failed: " .. tostring(err))
    end
end

local function SafeKeyRelease(vk)
    if not vk then
        return
    end

    pcall(function()
        keyrelease(vk)
    end)

    HeldKeys[vk] = nil
end

local function ReleaseAllKeys()
    -- Release tracked keys first.
    local toRelease = {}

    for vk in pairs(HeldKeys) do
        toRelease[#toRelease + 1] = vk
    end

    for _, vk in ipairs(toRelease) do
        SafeKeyRelease(vk)
    end

    -- Always release Shift as an extra failsafe.
    pcall(function()
        keyrelease(SHIFT)
    end)

    HeldKeys = {}
end

local function BuildChord(notes)
    local normalKeys = {}
    local shiftedKeys = {}
    local seenNormal = {}
    local seenShifted = {}

    for _, character in ipairs(notes) do
        local vk, needsShift = ResolveKey(character)

        if vk then
            if needsShift then
                if not seenShifted[vk] then
                    seenShifted[vk] = true
                    shiftedKeys[#shiftedKeys + 1] = vk
                end
            else
                if not seenNormal[vk] then
                    seenNormal[vk] = true
                    normalKeys[#normalKeys + 1] = vk
                end
            end
        elseif not WarnedUnsupported[character] then
            WarnedUnsupported[character] = true
            print("Ignored unsupported piano key: " .. tostring(character))
        end
    end

    return normalKeys, shiftedKeys
end

local function TapNotes(notes)
    local normalKeys, shiftedKeys = BuildChord(notes)

    -- Press unshifted notes first.
    for _, vk in ipairs(normalKeys) do
        SafeKeyPress(vk)
    end

    -- Then press Shift and shifted notes.
    if #shiftedKeys > 0 then
        SafeKeyPress(SHIFT)

        for _, vk in ipairs(shiftedKeys) do
            SafeKeyPress(vk)
        end
    end

    task.wait(Config.KeyHoldTime)

    -- Always release in reverse order.
    for i = #shiftedKeys, 1, -1 do
        SafeKeyRelease(shiftedKeys[i])
    end

    if #shiftedKeys > 0 then
        SafeKeyRelease(SHIFT)
    end

    for i = #normalKeys, 1, -1 do
        SafeKeyRelease(normalKeys[i])
    end
end

--------------------------------------------------
-- Playback and controls
--------------------------------------------------

local Playing = false
local Session = 0

local function IsKeyDown(vk)
    local ok, result = pcall(function()
        return iskeypressed(vk)
    end)

    return ok and result == true
end

local function StopPlayback(message)
    Session = Session + 1
    Playing = false
    ReleaseAllKeys()

    if message then
        print(message)
    end
end

_G.MatchaPianoCleanup = function()
    Session = Session + 1
    Playing = false
    ReleaseAllKeys()
end

local function WaitCancelable(duration, session)
    local remaining = duration

    while remaining > 0 do
        if not Playing
            or session ~= Session
            or _G.MatchaPianoRunId ~= RunId then
            return false
        end

        local amount = math.min(Config.CancelCheckTime, remaining)
        task.wait(amount)
        remaining = remaining - amount
    end

    return Playing
        and session == Session
        and _G.MatchaPianoRunId == RunId
end

local function PlaySong(session)
    local ok, err = pcall(function()
        for _, slot in ipairs(Slots) do
            if not Playing
                or session ~= Session
                or _G.MatchaPianoRunId ~= RunId then
                return
            end

            local slotTime = GetSlotTime()

            if slot.Type == "Rest" then
                if not WaitCancelable(slotTime, session) then
                    return
                end
            elseif slot.Type == "Notes" then
                local tapStart = os.clock()
                TapNotes(slot.Notes)

                if not Playing
                    or session ~= Session
                    or _G.MatchaPianoRunId ~= RunId then
                    return
                end

                local elapsed = os.clock() - tapStart
                local remaining = slotTime - elapsed

                if remaining > 0 then
                    if not WaitCancelable(remaining, session) then
                        return
                    end
                end
            end
        end
    end)

    ReleaseAllKeys()

    if not ok then
        StopPlayback("Playback error: " .. tostring(err))
        return
    end

    if Playing and session == Session then
        Playing = false
        print("Song finished.")
    end
end

local ToggleWasDown = false
local FasterWasDown = false
local SlowerWasDown = false
local PanicWasDown = false

task.spawn(function()
    print(("Loaded %d timing slots."):format(#Slots))
    print(("Timing source: %s"):format(TimingSource))
    print(("Typical line/bar size: %.2f"):format(RawSlotsPerBar))
    print(("Detected grid: %d slots per bar"):format(DetectedSlotsPerBar))
    print(("Using %.2f steps per beat"):format(StepsPerBeat))
    print(("Starting BPM: %d"):format(Config.BPM))
    print("; = Play/Stop | Up/Down = BPM | F12 = Emergency Stop")

    while _G.MatchaPianoRunId == RunId do
        local panicDown = IsKeyDown(Config.PanicKey)

        if panicDown and not PanicWasDown then
            StopPlayback("Emergency stop: all simulated keys released.")
        end

        PanicWasDown = panicDown

        local toggleDown = IsKeyDown(Config.ToggleKey)

        if toggleDown and not ToggleWasDown then
            if Playing then
                StopPlayback("Stopped.")
            else
                Session = Session + 1
                Playing = true

                local currentSession = Session
                print(("Playing at %d BPM."):format(Config.BPM))

                task.spawn(function()
                    PlaySong(currentSession)
                end)
            end
        end

        ToggleWasDown = toggleDown

        local fasterDown = IsKeyDown(Config.FasterKey)

        if fasterDown and not FasterWasDown then
            Config.BPM = math.min(
                Config.MaximumBPM,
                Config.BPM + Config.BPMStep
            )

            print(("BPM: %d"):format(Config.BPM))
        end

        FasterWasDown = fasterDown

        local slowerDown = IsKeyDown(Config.SlowerKey)

        if slowerDown and not SlowerWasDown then
            Config.BPM = math.max(
                Config.MinimumBPM,
                Config.BPM - Config.BPMStep
            )

            print(("BPM: %d"):format(Config.BPM))
        end

        SlowerWasDown = slowerDown

        task.wait(Config.ControlPollTime)
    end

    ReleaseAllKeys()
end)
