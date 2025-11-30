local reallib = 'https://raw.githubusercontent.com/1xAbel/LinoriaLib-Modify/main/'
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(reallib .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'The Forge - [BETA]',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})


--variables
local lp = game.Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local rfFolder = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF")
local OreList = {}
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

getgenv().flags = {
    tweenspeed = 40,
    distance = 5,
    farmmethod = "Above",
    current_tween = false,
    autofarm = false,
    autoore = false,
    mob_selected = {},
    ore_selected = {},
}

--remotes
local blockRemote = rfFolder:WaitForChild("StartBlock")
local stopBlockRemote = rfFolder:WaitForChild("StopBlock")

--AP Animations
local parryAnimations = {
    --Rogue Skeleton
	["rbxassetid://106199289601358"] = 0.433, --Hit1
	["rbxassetid://82533430458765"] = 0.37, --Hit2
    --Axe Skeleton
    ["rbxassetid://89496572417272"] = 0.44, -- HIt1
    ["rbxassetid://97668319966803"] = 0.30,
    --DeathAxe Skeleton
    ["rbxassetid://107274803323874"] = 0.93,
    ["rbxassetid://89127058244517"] = 0.59,
    --Reaper
    ["rbxassetid://73829363877010"] = 0.43,
    ["rbxassetid://131510736644901"] = 0.4,
    ["rbxassetid://98266710251041"] = 0.25,
    --missing spin move

    --slime
    --0.5
}

--functions
local is_alive, tweenToFARM, find_ore, distance_check, parry, connect_parry, scan_ores do
    is_alive = function()
        local char = lp.Character or lp.CharacterAdded:Wait()
        if lp and char ~= nil and char:FindFirstChild('HumanoidRootPart') ~= nil and char:FindFirstChild('Humanoid') ~= nil and char.Humanoid.Health > 0 then 
            return true 
        end
            
        return false
    end

    tweenToFARM = function(Target)
        if typeof(Target) == "Instance" and Target:IsA("BasePart") then Target = Target.Position end
        if typeof(Target) == "CFrame" then Target = Target.Position end
        if typeof(Target) ~= "Vector3" then return end
    
        local char = lp.Character; if not char then return end
        local HRP = char:FindFirstChild("HumanoidRootPart"); if not HRP then return end
    
        flags.current_tween = true
    
        local StartPos = HRP.Position
        local DeltaPos = Target - StartPos
        local StartTime = tick()
        local Duration = (StartPos - Target).Magnitude / flags.tweenspeed
        if Duration <= 0 then return end
    
        repeat
            RunService.Heartbeat:Wait()
            if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then break end
            HRP = lp.Character.HumanoidRootPart
            local d = tick() - StartTime
            local p = math.min(d / Duration, 1)
            local pos = StartPos + (DeltaPos * p)
            HRP.Velocity = Vector3.new()
            HRP.CFrame = CFrame.new(pos)
        until (HRP.Position - Target).Magnitude <= flags.tweenspeed / 2000 or flags.current_tween == false
    
        if (HRP.Position - Target).Magnitude <= 15 then
            if flags.farmmethod == "Above" then
                HRP.CFrame = CFrame.new(Target + Vector3.new(0, flags.distance, 0), Target)
            elseif flags.farmmethod == "Below" then
                HRP.CFrame = CFrame.new(Target + Vector3.new(0, -flags.distance, 0), Target)
            end
        end
    end

    find_ore = function()
        for _, obj in ipairs(game.workspace.Rocks:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "Basalt Core" then
                if obj.Parent and obj.Parent:FindFirstChild("Hitbox") then
                    return obj
                end
            end
        end
        return nil
    end
    
    distance_check = function(part)
        local currentRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not currentRoot or not part then return false end
        return (part.Position - currentRoot.Position).Magnitude <= 25
    end

    parry = function(enemy, animId) -- very shit
        local hrp = enemy:FindFirstChild("HumanoidRootPart")
        if hrp and distance_check(hrp) then
            if not getgenv().auto_parry then return end
            local baseDelay = parryAnimations[animId] or 0.2
            local randomOffset = math.random(-3, 3) / 100
            local delay = baseDelay + randomOffset
    
            task.delay(delay, function()
                if enemy.Parent and enemy:FindFirstChild("Humanoid") then
                    if auto_parry_debug then
                        Library:Notify("[Auto Parry Debug] Attempt To Parry ".. animId .. " from ".. enemy.Name .. " after "..string.format("%.3f", delay).. " seconds", 2)
                    end
                    blockRemote:InvokeServer()
                    task.wait(0.25)
                    stopBlockRemote:InvokeServer()
                end
            end)
        end
    end

    local slimeDelay = 0.49
    safe_connect_parry = function(npc)
        task.spawn(function()
            -- wait for HumanoidRootPart
            local hrp = npc:WaitForChild("HumanoidRootPart", 5)
            if not hrp then return end
    
            -- wait for infoFrame hierarchy
            local infoFrame = hrp:WaitForChild("infoFrame", 5)
            if not infoFrame then return end
            local frame = infoFrame:WaitForChild("Frame", 5)
            if not frame then return end
            local rockNameLabel = frame:WaitForChild("rockName", 5)
            if not rockNameLabel or not rockNameLabel:IsA("TextLabel") then return end
    
            local mobNameText = rockNameLabel.Text
            local isSlime = string.find(mobNameText, "Slime")
    
            if isSlime then
                -- wait for Status folder
                local status = npc:WaitForChild("Status", 5)
                if not status then return end
    
                status.ChildAdded:Connect(function(child)
                    if child:IsA("BoolValue") and child.Name == "Attacking" then
                        if hrp and distance_check(hrp) and getgenv().auto_parry then
                            task.delay(slimeDelay + math.random(-3,3)/100, function()
                                if npc.Parent and npc:FindFirstChild("Humanoid") then
                                    if auto_parry_debug then
                                        Library:Notify("[Auto Parry Debug] Slime parried after "..string.format("%.3f", slimeDelay).." seconds", 2)
                                    end
                                    blockRemote:InvokeServer()
                                    task.wait(0.25)
                                    stopBlockRemote:InvokeServer()
                                end
                            end)
                        end
                    end
                end)
            else
                local hum = npc:FindFirstChild("Humanoid") or npc:WaitForChild("Humanoid", 5)
                if hum then
                    hum.AnimationPlayed:Connect(function(track)
                        if track.Animation then
                            local animId = track.Animation.AnimationId
                            if parryAnimations[animId] then
                                parry(npc, animId)
                            end
                        end
                    end)
                end
            end
        end)
    end
end

local Tabs = {
    AP = Window:AddTab('Auto Parry'),
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}
local aptab = Tabs.AP:AddLeftTabbox()
local apbuildtab = Tabs.AP:AddLeftTabbox()
local farmtab = Tabs.Main:AddLeftTabbox()
local oretab = Tabs.Main:AddRightTabbox()
local mobtab = Tabs.Main:AddLeftTabbox()
local minigtab = Tabs.Main:AddRightTabbox()

local AP = aptab:AddTab(" \\\\ Auto Parry //")
local APBuilder = apbuildtab:AddTab(" \\\\ Auto Parry Builder //")
local farmSet = farmtab:AddTab(" \\\\ Farm Settings //")
local orefarm = oretab:AddTab(" \\\\ Ore Farm //")
local mobfarm = mobtab:AddTab(" \\\\ Mob Farm //")
local minigame = minigtab:AddTab(" \\\\ Forge Minigame Exploits //")

--farm settings
farmSet:AddDropdown('FarmMethod', {
    Values = { 'Above', 'Below' },
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'Select Farm Method: ',
    Tooltip = nil, -- Information shown when you hover over the dropdown

    Callback = function(t)
        flags.farmmethod = t
    end
})
farmSet:AddSlider('DistanceSlider', {
    Text = 'Farm Distance',
    Default = -5,
    Min = -10,
    Max = 10,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        flags.distance = Value
    end
})

--ore farm tab
orefarm:AddDropdown('OreDropdown', {
    Values = {'Basalt Rock', 'Basalt Core', 'Basalt Vein', 'Volcanic Rock', 'Light Crystal', 'Earth Crystal', 'Violet Crystal', 'Crimson Crystal', 'Cyan Crystal'},
    Default = 1, -- number index of the value / string
    Multi = true, -- true / false, allows multiple choices to be selected

    Text = 'Select Ore Type: ',
    Tooltip = nil, -- Information shown when you hover over the dropdown

    Callback = function(Value)
        flags.ore_selected = Value
    end
})
orefarm:AddToggle('AutoFarmOres', {
    Text = 'Auto Mine Ores',
    Default = false,

    Callback = function(t)
        flags.autoore = t
    end
})

--mob farm tab
mobfarm:AddDropdown('OreDropdown', {
    Values = {'Reaper', 'Bomber', 'Deathaxe Skeleton', 'Slime', 'Skeleton Rogue', 'Axe Skeleton', 'Elite Deathaxe Skeleton', 'Elite Rogue Skeleton', 'Blazing Slime'},
    Default = 1, -- number index of the value / string
    Multi = true, -- true / false, allows multiple choices to be selected

    Text = 'Select Mob Type: ',
    Tooltip = nil, -- Information shown when you hover over the dropdown

    Callback = function(t)
        flags.mob_selected = t
    end
})
mobfarm:AddToggle('AutoFarmOres', {
    Text = 'Auto Farm Mobs',
    Default = false, -- Default value (true / false)
    Tooltip = nil, -- Information shown when you hover over the toggle

    Callback = function(t)
        flags.auto_farm = t

        task.spawn(function()
            while flags.auto_farm do task.wait()
                for i,v in pairs(workspace.Living:GetChildren()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                        if v:GetAttribute("IsNpc") and v.HumanoidRootPart.infoFrame.Frame.rockName.Text then
                            local mobName = v.HumanoidRootPart.infoFrame.Frame.rockName.Text
                            if flags.mob_selected[mobName] then
                                repeat task.wait()
                                    tweenToFARM(v:FindFirstChild("HumanoidRootPart"))
                                until v.Humanoid.Health <= 0 or not flags.auto_farm
                            end
                        end
                    end
                end
            end
        end)
    end
})

-- AutoParry Tab
AP:AddToggle('AutoParryToggle', {
    Text = 'Auto Parry',
    Default = false, -- Default value (true / false)
    Tooltip = nil, -- Information shown when you hover over the toggle

    Callback = function(t)
        getgenv().auto_parry = t
    end
})
AP:AddToggle('AutoParryDebugToggle', {
    Text = 'Auto Parry Debug',
    Default = false, -- Default value (true / false)
    Tooltip = nil, -- Information shown when you hover over the toggle

    Callback = function(t)
        getgenv().auto_parry_debug = t
    end
})


--AutoParry Builder Tab


-- Connect existing NPCs
-- Connect existing NPCs
for _, enemy in ipairs(workspace:WaitForChild("Living"):GetChildren()) do
    if enemy:IsA("Model") and enemy:GetAttribute("IsNpc") then
        safe_connect_parry(enemy)
    end
end

-- Connect newly spawned NPCs
workspace.Living.ChildAdded:Connect(function(enemy)
    if enemy:IsA("Model") and enemy:GetAttribute("IsNpc") then
        safe_connect_parry(enemy)
    end
end)



task.spawn(function()
    while task.wait() do
        if getgenv().auto_farm or getgenv().auto_ore then
            if not lp.Character:WaitForChild("HumanoidRootPart"):FindFirstChild("BodyVelocity") then
                local bv = Instance.new("BodyVelocity")
                bv.Parent = lp.Character:WaitForChild("HumanoidRootPart")
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        else
            if lp.Character:WaitForChild("HumanoidRootPart"):FindFirstChild("BodyVelocity") then
                lp.Character:WaitForChild("HumanoidRootPart"):FindFirstChild("BodyVelocity"):Destroy()
            end
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = true
                end
            end
        end
    end
end)




--Settings
Library:OnUnload(function()
    print('Unloaded!')
    Library.Unloaded = true
end)
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('abels-shit')
SaveManager:SetFolder('abels-shit/the-forge')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
