for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
    v:Disable()
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/1xAbel/scripts/main/cattoware_lua.lua"))() --you can go into the github link and copy all of it and modify it for yourself.
local Window = Library:CreateWindow("Lazy Hub | Jujutsu Chronicles | https://discord.gg/5AcFHTpA2b", Vector2.new(492, 598), Enum.KeyCode.Insert) --you can change your UI keybind
local AimingTab = Window:CreateTab("Main")
local Credits = Window:CreateTab("Credits")

local args = {
    [1] = {
        ["NotificationText"] = "Thank You For Using Lazy Hub!",
        ["GradientChoice"] = "System"
    }
}

game:GetService("Players").LocalPlayer.Character.Client.Server.Notify:FireServer(unpack(args))

local testSection = AimingTab:CreateSector("Farm", "left") 
local Credit = Credits:CreateSector('Credits', 'left')
local ad1 = AimingTab:CreateSector("Auto Skill", "right")  
local ad2 = AimingTab:CreateSector("Troll", "left")
local ad = AimingTab:CreateSector("Misc", "right")  
local UserInputService = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local lp = game.Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded():Wait()

local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false

check_char = function()
    if not char:IsDescendantOf(lp.Character.Parent) or not char:FindFirstChild("HumanoidRootPart") or not char then char = lp.Character wait(0.5) end
end

local File = pcall(function()
    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end
function TPReturner()
    local Site;
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    local num = 0;
    for i,v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _,Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 10
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                wait()
                pcall(function()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                wait(4)
            end
        end
    end
end

function Teleport()
    while wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end

testSection:AddToggle("Auto Farm Dummy", false, function(auto_farm_enabled)
    getgenv().auto_farm = auto_farm_enabled

    while auto_farm do wait()
        for i,v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v.Name == "Dummy" then
                lp.Character:WaitForChild('HumanoidRootPart').CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,0,4)
            end
        end
    end         
end)


testSection:AddToggle("Bring Dummys", false, function(safe_place_enabled)
    getgenv().safe_place = safe_place_enabled

    while safe_place do wait()
        for i,v in pairs(workspace:GetChildren()) do 
            if v.Name == "Dummy" then
                v.HumanoidRootPart.CFrame = lp.Character:WaitForChild('HumanoidRootPart').CFrame * CFrame.new(0,0,-4)
            end
        end
    end         
end)

testSection:AddToggle("Safe Place", false, function(bring_dummys_enabled)
    getgenv().bring_dummys = bring_dummys_enabled

    while bring_dummys do wait()
        lp.Character:WaitForChild('HumanoidRootPart').CFrame = CFrame.new(-349, -2, 531)
    end         
end)

testSection:AddToggle("Kill Aura", false, function(kill_aura_enabled)
    getgenv().kill_aura = kill_aura_enabled

    while kill_aura do wait()
        for i,v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= lp.Name then
                if (lp.Character:WaitForChild('HumanoidRootPart').Position - v.HumanoidRootPart.Position).magnitude <= 7 then
                    local args = {
                        [1] = {
                            ["Character"] = workspace:WaitForChild(lp.Name),
                            ["Action"] = "M1",
                            ["Combo"] = 1,
                            ["Target"] = v,
                            ["BehindPlayer"] = true
                        }
                    }
                        
                    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CombatEvent"):FireServer(unpack(args))
                end
            end
        end
    end         
end)

testSection:AddToggle("Farm Stamina", false, function(Stamina_farm_enabled)
    getgenv().Stamina_farm = Stamina_farm_enabled

    while Stamina_farm do wait()
        for i = 1, 15 do
            game:GetService("Players").LocalPlayer.Character.Client.Server.RewardStamina:FireServer()  
        end
    end         
end)

testSection:AddToggle("Farm Cursed Energy", false, function(Cursed_Energy_farm_enabled)
    getgenv().Cursed_Energy_farm = Cursed_Energy_farm_enabled

    while Cursed_Energy_farm do wait()
        local args = {
            [1] = {
                ["Character"] = workspace:WaitForChild(lp.Name),
                ["Action"] = "Cursed_Energy",
                ["MiscData"] = game:GetService("Players").LocalPlayer:WaitForChild("UIStats")
            }
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CombatEvent"):FireServer(unpack(args))
        wait(0.2)             
    end         
end)

testSection:AddToggle("Farm Endurance", false, function(Endurance_farm_enabled)
    getgenv().Endurance_farm = Endurance_farm_enabled

    while Endurance_farm do wait()
        local args = {
            [1] = {
                ["Character"] = workspace:WaitForChild(lp.Name),
                ["Action"] = "Endurance",
                ["MiscData"] = game:GetService("Players").LocalPlayer:WaitForChild("UIStats")
            }
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CombatEvent"):FireServer(unpack(args))        
    end         
end)

testSection:AddToggle("Reset When Low Stamina", false, function(reset_low_enabled)
    getgenv().reset_low = reset_low_enabled

    while reset_low do wait()
        if lp.UIStats.Stamina.Value < 50 then
            lp.Character:WaitForChild('Humanoid').Health = 0
        end
    end       
end)

local function collect1()
    for i = 1, 500 do -- Get Spins Any mount by change number (To use. use when u at the hold e thing then execute if too much u may crashes)
        fireproximityprompt(workspace.Game_FX.CurseSpinOrb.CurseSpinOrb.Prompt)
    end
end

local function collect2()
    for i = 1, 1000 do
        fireproximityprompt(workspace.Game_FX.Vessel_Finger.Finger.Collect)
    end
end

local function collect3()
    for i = 1, 1000 do
        fireproximityprompt(workspace.Game_FX.ClanSpinOrb.ClanSpinOrb.Prompt)
    end
end

local function collect4()
    for i = 1, 1000 do
        fireproximityprompt(workspace.Game_FX.MiscOrb.MiscOrb.Prompt)
    end
end

ad1:AddToggle("Auto Use Skill Z", false, function(skillz_enabled)
    getgenv().skillz = skillz_enabled 
    
    while skillz do wait()
        VIM:SendKeyEvent(true, Enum.KeyCode.Z, false, UserInputService:GetFocusedTextBox())
    end
end)
ad1:AddToggle("Auto Use Skill X", false, function(skillx_enabled)
    getgenv().skillx = skillx_enabled
    
    while skillx do wait()
        VIM:SendKeyEvent(true, Enum.KeyCode.X, false, UserInputService:GetFocusedTextBox())
    end
end)
ad1:AddToggle("Auto Use Skill C", false, function(skillc_enabled)
    getgenv().skillc = skillc_enabled  
    
    while skillc do wait()
        VIM:SendKeyEvent(true, Enum.KeyCode.C, false, UserInputService:GetFocusedTextBox())
    end
end)
ad1:AddToggle("Auto Use Skill V", false, function(skillv_enabled)
    getgenv().skillv = skillv_enabled  
    
    while skillv do wait()
        VIM:SendKeyEvent(true, Enum.KeyCode.V, false, UserInputService:GetFocusedTextBox())
    end
end)
ad1:AddToggle("Auto Use Skill B", false, function(skillz_enabled)
    getgenv().skillb = skillz_enabled  
    
    while skillb do wait()
        VIM:SendKeyEvent(true, Enum.KeyCode.B, false, UserInputService:GetFocusedTextBox())
    end
end)
ad1:AddToggle("Auto Use Skill N", false, function(skilln_enabled)
    getgenv().skilln = skilln_enabled    
    
    while skilln do wait()
        VIM:SendKeyEvent(true, Enum.KeyCode.N, false, UserInputService:GetFocusedTextBox())
    end
end)

ad1:AddToggle("Auto Active Vessel", false, function(Vessel_enabled)
    getgenv().Vessel = Vessel_enabled
    
    while Vessel do wait()
        check_char()

        pcall(function()
            if not lp.Character:FindFirstChild('Vessel') then

                if char:IsDescendantOf(lp.Character.Parent) then
                    local args = {
                        [1] = {
                            ["Character"] = workspace:WaitForChild(lp.Name),
                            ["Action"] = "CursedTechnique",
                            ["MiscData"] = game:GetService("Players").LocalPlayer:WaitForChild("UIStats"),
                            ["Technique"] = "Vessel",
                            ["Skill"] = "VesselSwap"
                        }
                    }
                    
                    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CombatEvent"):FireServer(unpack(args))
                    
                    task.wait(0.2)
                end
            end
        end)
        
    end
end)

ad2:AddLabel("Requires Limitless")
ad2:AddSlider("Lag Amount", 50, 30000, 100000, 1, function(StatedLagg)
    getgenv().lag_amount = StatedLagg
end)
ad2:AddButton("Lag Server", function(IhateGayPeople)
    for i = 1, lag_amount do
        local args = {
            [1] = {
                ["Mode"] = "Create",
                ["FX"] = "LapseBlue",
                ["Character"] = workspace:WaitForChild(lp.Name)
            }
        }
        
        game:GetService("Players").LocalPlayer.Character.Main_Client.Main_Server.Attach:FireServer(unpack(args))
    end
end)

ad:AddToggle("Cursed Orb Farm", false, function(cursed_orb_farm_enabled)
    getgenv().cursed_orb_farm = cursed_orb_farm_enabled

    while cursed_orb_farm do wait()
        for i,v in pairs(workspace.Game_FX:GetChildren()) do
            if v:IsA("Model") and v.Name == "CurseSpinOrb" and v:FindFirstChild("CurseSpinOrb")then
                local oldCframe = lp.Character.HumanoidRootPart.CFrame
                lp.Character.HumanoidRootPart.CFrame = v.CurseSpinOrb.CFrame
                wait(0.1)
                collect1()
                wait(0.4)
                lp.Character.HumanoidRootPart.CFrame = oldCframe
            end
        end
    end         
end)

ad:AddToggle("Blue Orb Farm", false, function(blue_orb_farm_enabled)
    getgenv().blue_orb_farm = blue_orb_farm_enabled

    while blue_orb_farm do wait()
        for i,v in pairs(workspace.Game_FX:GetChildren()) do
            if v:IsA("Model") and v.Name == "ClanSpinOrb" and v:FindFirstChild("ClanSpinOrb")then
                local oldCframe = lp.Character.HumanoidRootPart.CFrame
                lp.Character.HumanoidRootPart.CFrame = v.ClanSpinOrb.CFrame
                wait(0.1)
                collect3()
                wait(0.4)
                lp.Character.HumanoidRootPart.CFrame = oldCframe
            end
        end
    end         
end)

ad:AddToggle("Misc Orb Farm", false, function(misc_orb_farm_enabled)
    getgenv().misc_orb_farm = misc_orb_farm_enabled

    while misc_orb_farm do wait()
        for i,v in pairs(workspace.Game_FX:GetChildren()) do
            if v:IsA("Model") and v.Name == "MiscOrb" and v:FindFirstChild("MiscOrb")then
                local oldCframe = lp.Character.HumanoidRootPart.CFrame
                lp.Character.HumanoidRootPart.CFrame = v.MiscOrb.CFrame
                wait(0.1)
                collect4()
                wait(0.4)
                lp.Character.HumanoidRootPart.CFrame = oldCframe
            end
        end
    end         
end)

ad:AddToggle("Cursed Finger Farm", false, function(cursed_finger_farm_enabled)
    getgenv().cursed_finger_farm = cursed_finger_farm_enabled

    while cursed_finger_farm do wait()
        for i,v in pairs(workspace.Game_FX:GetChildren()) do
            if v:IsA("Model") and v.Name == "Vessel_Finger" and v:FindFirstChild("Finger") then
                local oldCframe = lp.Character.HumanoidRootPart.CFrame
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Finger.CFrame
                wait(0.1)
                collect2()
                wait(0.4)
                lp.Character.HumanoidRootPart.CFrame = oldCframe
            end
        end
    end         
end)
ad:AddButton("Server Hop", function(IhateGayPeople)
    Teleport()
end)


Credit:AddLabel("👑 abel7878 - Owner/Developer")
Credit:AddButton("Join Discord", function(IhateGayPeople)
    request = http_request or request or HttpPost or syn.request
    request(
        {
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["origin"] = "https://discord.com",
            },
            Body = game:GetService("HttpService"):JSONEncode(
                {
                    ["args"] = {
                        ["code"] = "5AcFHTpA2b",
                    },
                    ["cmd"] = "INVITE_BROWSER",
                    ["nonce"] = "."
                }
            )
        }
    )
end)
