if game.PlaceId == 1499872953 then

    if game:GetService("CoreGui"):FindFirstChild("ScreenGui") then
        game:GetService("CoreGui"):FindFirstChild("ScreenGui"):Destroy()
    end

    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)

    game:GetService("RunService").RenderStepped:Connect(function() 
        if getgenv().AutoFarm == true then
            game.Players.LocalPlayer.Character.Humanoid:ChangeState(11)
        end
    end)

    setfflag("HumanoidParallelRemoveNoPhysics", "False")
    setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")

    local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'

    local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
    local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
    local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()


    local Window = Library:CreateWindow({
        Title = 'abels script | Boku No Roblox',
        Center = true, 
        AutoShow = true,
    })

    local Tabs = {
        -- Creates a new tab titled Main
        Main = Window:AddTab('Main'), 
        Credits = Window:AddTab('Credits'),
        ['UI Settings'] = Window:AddTab('UI Settings'),
    }

    local GeneralFM = Tabs.Main:AddLeftTabbox()
    local mSec = GeneralFM:AddTab('Main')
    local GeneralMisc = Tabs.Main:AddRightTabbox()
    local Misc = GeneralMisc:AddTab('Misc')

    local Credits = Tabs.Credits:AddLeftGroupbox('Credits')




    local function getNPCS()
        local t = {}
    
        for i,v in pairs(game:GetService("Workspace").NPCs:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and not table.find(t, v.Name) then
                table.insert(t, v.Name)
            end
        end
    
        table.sort(t)
        
        return t
    end


    --Main
    mSec:AddDropdown('NPC', {
        Values = getNPCS(),
        Default = nil, -- number index of the value / string
        Multi = false, -- true / false, allows multiple choices to be selected
    
        Text = 'Select NPC',
        Tooltip = false, -- Information shown when you hover over the textbox
    })
    Options.NPC:OnChanged(function()
        getgenv().NpcSelected = Options.NPC.Value
    end)

    mSec:AddDropdown('FarmMethod', {
        Values = { 'Above', 'Under', 'Behind', 'Front' },
        Default = nil, -- number index of the value / string
        Multi = false, -- true / false, allows multiple choices to be selected
    
        Text = 'Farm Method',
        Tooltip = false, -- Information shown when you hover over the textbox
    })
    
    Options.FarmMethod:OnChanged(function()
        getgenv().FarmMethod = Options.FarmMethod.Value
    end)

    mSec:AddToggle('AutoFarm', {
        Text = 'Auto Farm NPCS',
        Default = false, -- Default value (true / false)
        Tooltip = false, -- Information shown when you hover over the toggle
    })
    Toggles.AutoFarm:OnChanged(function()
        getgenv().AutoFarm = Toggles.AutoFarm.Value
    end)

    mSec:AddSlider('farmDistance', {
        Text = 'Farm Distance',
        Default = 5,
        Min = 0,
        Max = 60,
        Rounding = 0,
    
        Compact = true, -- If set to true, then it will hide the label
    })
    local Number = Options.farmDistance.Value
    Options.farmDistance:OnChanged(function()
        getgenv().farmDistance = Options.farmDistance.Value
    end)

    mSec:AddDropdown('Test', {
        Values = { 'Punch', 'Swing' },
        Default = 1, -- number index of the value / string
        Multi = false, -- true / false, allows multiple choices to be selected
    
        Text = 'Attack Method',
        Tooltip = false, -- Information shown when you hover over the textbox
    })
    Options.Test:OnChanged(function()
        getgenv().attackMethods = Options.Test.Value
    end)


    --misc
    Misc:AddDropdown('Quirks', {
        Values = { 'Commons', 'Uncommon', 'Rare', 'Front' },
        Default = nil, -- number index of the value / string
        Multi = false, -- true / false, allows multiple choices to be selected
    
        Text = 'Quirk Type',
        Tooltip = false, -- Information shown when you hover over the textbox
    })
    Options.Quirks:OnChanged(function()
        getgenv().Quirks = Options.Quirks.Value
    end)

    Misc:AddToggle("AutoSpin", {
        Text = 'Auto Spin Quirk',
        Default = false,
        Tooltip = false,
    })        
    Toggles.AutoSpin:OnChanged(function()
        getgenv().Autospin = Toggles.AutoSpin.Value
    end)












    Credits:AddLabel('<font color="#3da5ff">abel#0002</font> - Scripter')
    Credits:AddButton('Join/Copy Discord', function()
        setclipboard("//discord.gg/uGPhKAVGFq")
        syn.request(
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
							["code"] = "uGPhKAVGFq",
						},
						["cmd"] = "INVITE_BROWSER",
						["nonce"] = "."
					}
				)
			}
		)
    end)

    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
    MenuGroup:AddButton('Unload', function() Library:Unload() end)
    MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' }) 
    Library.ToggleKeybind = Options.MenuKeybind
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings() 
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 
    ThemeManager:SetFolder('MyScriptHub')
    SaveManager:SetFolder('MyScriptHub/specific-game')
    SaveManager:BuildConfigSection(Tabs['UI Settings'])
    ThemeManager:ApplyToTab(Tabs['UI Settings'])



    --functions
    coroutine.wrap(function()
        while wait() do
            if getgenv().AutoFarm == true then
                pcall(function()
                    for i,v in pairs(game:GetService("Workspace").NPCs:GetChildren()) do --enemy location
                        if v:IsA("Model") and v.Name == getgenv().NpcSelected then --remove this if you want farm all mobs 
                            if v.Humanoid.Health > 0 and game.Players.LocalPlayer.Character.Humanoid.Health > 0 then
                                repeat
                                    wait()
                                    if getgenv().FarmMethod == "Above" then
                                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,farmDistance,0) * CFrame.Angles(math.rad(-90),0,0) --distance and angles
                                    elseif getgenv().FarmMethod == "Under" then
                                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,-farmDistance,0) * CFrame.Angles(math.rad(90),0,0) --distance and angles
                                    elseif getgenv().FarmMethod == "Behind" then
                                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,0,farmDistance)
                                    elseif getgenv().FarmMethod == "Front" then
                                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,0,-farmDistance) * CFrame.Angles(math.rad(180),0,0)
                                    end
                                until v.Humanoid.Health <= 0 or getgenv().AutoFarm == false
                            end
                        end
                    end
                end)
            end
        end
    end)()

    spawn(function()
        while task.wait() do
            if getgenv().Autospin then
                local args = {
                    [1] = Quirks
                }
                
                workspace.S1c2R5i66p5t5s51.Spin.Spinner:InvokeServer(unpack(args))
            end
        end
    end)

    spawn(function()
        while task.wait() do
            if getgenv().AutoFarm then 
                game:GetService("Players").LocalPlayer.Character.NavelLaser.E:FireServer()
            end
        end
    end)
end
