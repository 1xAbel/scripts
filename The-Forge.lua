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
    --missing one
}

--functions
local is_alive, farm_method, distance_check, parry, connect_parry, scan_ores do
    is_alive = function()
        local char = lp.Character or lp.CharacterAdded:Wait()
        if lp and char ~= nil and char:FindFirstChild('HumanoidRootPart') ~= nil and char:FindFirstChild('Humanoid') ~= nil and char.Humanoid.Health > 0 then 
            return true 
        end
            
        return false
    end

    farm_method = function(targetPart, distance)
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not (hrp and targetPart) then
            return
        end
    
        local targetCFrame
    
        if getgenv().farm_setting == "Above/Below" then
            targetCFrame = CFrame.new(
                targetPart.Position + Vector3.new(0, distance, 0),
                targetPart.Position
            )
        elseif getgenv().farm_setting == "Front/Behind" then
            targetCFrame = CFrame.new(
                targetPart.Position + targetPart.CFrame.LookVector * distance,
                targetPart.Position
            )
        end
    
        if targetCFrame then
            local travelTime = (hrp.Position - targetCFrame.Position).Magnitude / 100
            local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear)
    
            if _G.TWEENONE then
                _G.TWEENONE:Cancel()
            end
    
            _G.TWEENONE = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
            _G.TWEENONE:Play()
        end
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

    connect_parry = function(npc)
        local hum = npc:FindFirstChild("Humanoid")
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
    Values = { 'Above/Below', 'Front/Behind' },
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'Select Farm Method: ',
    Tooltip = nil, -- Information shown when you hover over the dropdown

    Callback = function(Value)
        getgenv().FarmMethod = Value
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
        getgenv().farm_distance = Value
    end
})

--ore farm tab
orefarm:AddDropdown('OreDropdown', {
    Values = { 'All', 'Basalt Rock', 'Basalt Core', 'Basalt Vein', 'Volcanic Rock', 'Light Crystal', 'Earth Crystal', 'Violet Crystal', 'Crimson Crystal', 'Cyan Crystal'},
    Default = 1, -- number index of the value / string
    Multi = true, -- true / false, allows multiple choices to be selected

    Text = 'Select Ore Type: ',
    Tooltip = nil, -- Information shown when you hover over the dropdown

    Callback = function(Value)
        getgenv().ore_selected = Value
    end
})
orefarm:AddToggle('AutoFarmOres', {
    Text = 'Auto Mine Ores',
    Default = false,

    Callback = function(t)
        getgenv().auto_ore = t
    end
})

--mob farm tab
mobfarm:AddDropdown('OreDropdown', {
    Values = { 'All', 'Reaper', 'Bomber', 'Deathaxe Skeleton', 'Slime', 'Skeleton Rogue', 'Axe Skeleton', 'Elite Deathaxe Skeleton', 'Elite Rogue Skeleton', 'Blazing Slime'},
    Default = 1, -- number index of the value / string
    Multi = true, -- true / false, allows multiple choices to be selected

    Text = 'Select Mob Type: ',
    Tooltip = nil, -- Information shown when you hover over the dropdown

    Callback = function(Value)
        getgenv().mob_selected = Value
    end
})
mobfarm:AddToggle('AutoFarmOres', {
    Text = 'Auto Farm Mobs',
    Default = false, -- Default value (true / false)
    Tooltip = nil, -- Information shown when you hover over the toggle

    Callback = function(t)
        getgenv().auto_farm = t
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
APBuilder:AddInput('APBuilderAnimationdID', {
    Default = nil,
    Numeric = false,
    Finished = false,
    Text = 'Enter Animation ID: ',
    Tooltip = nil,

    Placeholder = 'Enter Animation ID',

    Callback = function(Value)
        getgenv().animation_id_tracking = Value
    end
})
APBuilder:AddToggle('APBuilderToggle', {
    Text = 'Track Animation Timing',
    Default = false, -- Default value (true / false)
    Tooltip = nil, -- Information shown when you hover over the toggle

    Callback = function(t)
        getgenv().tracking_time = t
    end
})

for _, enemy in ipairs(workspace:WaitForChild("Living"):GetChildren()) do
    if enemy:IsA("Model") and enemy:GetAttribute("IsNpc") then
        connect_parry(enemy)
    end
end
workspace.Living.ChildAdded:Connect(function(enemy)
    if enemy:IsA("Model") and enemy:GetAttribute("IsNpc") then
        connect_parry(enemy)
    end
end)


game.Workspace.Rocks.DescendantAdded:Connect(function(obj)
    if obj.Name == getgenv().ore then
        local hitbox = obj.Parent:FindFirstChild("Hitbox")
        if hitbox then
            table.insert(OreList, hitbox)
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
