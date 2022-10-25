

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
   wait(1)
   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

local playerHead = game.Players.LocalPlayer.Character.Head;
local RunService = game:GetService("RunService")


local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
local Window = Rayfield:CreateWindow({Name = "abel's script | Rebirth Champion X"})

local MainTab = Window:CreateTab("Main")
local MainSection = MainTab:CreateSection("Farm")
MainTab:CreateToggle({
	Name = "Auto Click",
	CurrentValue = false,
	Callback = function(t)
        getgenv().autoClick = t
        while getgenv().autoClick do wait()
            game:GetService("ReplicatedStorage").Events.Click3:FireServer()
        end
	end,
})
MainTab:CreateDropdown({
	Name = "Rebirth Amount",
	Options = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73},
	CurrentOption = 'nil',
	Callback = function(RebirthAmount)
        getgenv().RebirthAmount = RebirthAmount
	end,
})
MainTab:CreateToggle({
	Name = "Auto Rebirth",
	CurrentValue = false,
	Callback = function(t)
        getgenv().autoRebirth = t
        while autoRebirth do wait()
            local args = {
                [1] = RebirthAmount
            }
            
            game:GetService("ReplicatedStorage").Events.Rebirth:FireServer(unpack(args))
        end
	end,
})

local EggTab = Window:CreateTab("Eggs")
local EggSection = EggTab:CreateSection("Eggs")
EggTab:CreateDropdown({
	Name = "Select Egg",
	Options = {"Basic","Forest","Beach","Winter","Desert","Volcano","Lava","Mythic","Magma","Atlantis","Hell","Moon","Cyber","Magic","Heaven","Nuclear","Void","Spooky","Cave","Steampunk","Water","Mars","Space","Shadow","Galaxy Forest","Neon","Destruction","SpaceLab","Alien","Fantasy","Sun","Saturn","Hacker","Black Hole","Aqua","Axolotl","Underwater Lab","Pixel","Ghost","Pumpkin"},
	CurrentOption = "nil",
	Callback = function(EggType)
        getgenv().EggType = EggType
	end,
})
EggTab:CreateDropdown({
	Name = "Hatch Amount",
	Options = {"Single","Triple"},
	CurrentOption = "nil",
	Callback = function(HatchType)
        getgenv().HatchType = HatchType
	end,
})
EggTab:CreateToggle({
	Name = "Auto Hatch",
	CurrentValue = false,
	Callback = function(t)
        getgenv().autoHatch = t
        while autoHatch do wait()
            local args = {
                [1] = EggType,
                [2] = HatchType
            }
            
            game:GetService("ReplicatedStorage").Functions.Unbox:InvokeServer(unpack(args))
        end
	end,
})
EggTab:CreateToggle({
	Name = "Auto Craft",
	CurrentValue = false,
	Callback = function(t)
        getgenv().autoCraft = t
        while autoCraft do wait()
            local args = {
                [1] = "CraftAll",
                [2] = {}
            }
            
            game:GetService("ReplicatedStorage").Functions.Request:InvokeServer(unpack(args))
        end
	end,
})

local TpTab = Window:CreateTab("Worlds")
local WordSection = TpTab:CreateSection("World Boost")
TpTab:CreateDropdown({
	Name = "Select Area Boost",
	Options = {"Forest","Beach","Atlantis","Desert","Winter","Volcano","Moon","Cyber","Magic","Heaven","Nuclear","Void","Spooky","Cave","Steampunk","Hell","Space","Mars","Alien","Galaxy Forest","Space Lab","Fantasy","Neon","Shadow","Destruction","Sun","Saturn","Hacker","Black Hole","Aqua","Axolotls","Pixel","Halloween"},
	CurrentOption = "nil",
	Callback = function(AreaBoost)
        getgenv().AreaBoost = AreaBoost
	end,
})
TpTab:CreateButton({
	Name = "Apply Area Boost",
	Callback = function()
        local args = {
            [1] = AreaBoost
        }
        
        game:GetService("ReplicatedStorage").Events.WorldBoost:FireServer(unpack(args))
	end,
})
local TpSection = TpTab:CreateSection("Teleports")



local MiscTab = Window:CreateTab("Misc")
local MiscSection = MiscTab:CreateSection("Misc")
local Toggle = MiscTab:CreateToggle({
	Name = "Auto Chest",
	CurrentValue = false,
	Callback = function(t)
        getgenv().autoChest = t
        while autoChest do wait()
            game:GetService("ReplicatedStorage").Events.Chest:FireServer("Beach")
            game:GetService("ReplicatedStorage").Events.Chest:FireServer("Spawn")
            game:GetService("ReplicatedStorage").Events.Chest:FireServer("Winter")
            game:GetService("ReplicatedStorage").Events.Chest:FireServer("Cyber")
            game:GetService("ReplicatedStorage").Events.Chest:FireServer("Hell")
            game:GetService("ReplicatedStorage").Events.Chest:FireServer("Nuclear")
            game:GetService("ReplicatedStorage").Events.Chest:FireServer("Space")
            game:GetService("ReplicatedStorage").Events.Chest:FireServer("Galaxy")
            game:GetService("ReplicatedStorage").Events.Chest:FireServer("Shadow")
            game:GetService("ReplicatedStorage").Events.Chest:FireServer("Hacker")
            game:GetService("ReplicatedStorage").Events.Chest:FireServer("Aqua")
            game:GetService("ReplicatedStorage").Events.Chest:FireServer("Halloween")
        end
	end,
})
local Toggle = MiscTab:CreateToggle({
	Name = "Auto Pet Machine",
	CurrentValue = false,
	Callback = function(t)
        getgenv().petMechine = t
        while petMechine do wait()
            game:GetService("ReplicatedStorage").Functions.Machine:InvokeServer()
        end
	end,
})
MiscTab:CreateToggle({
	Name = "Boost FPS",
	CurrentValue = false,
	Callback = function(t)
        getgenv().boostfps = t
        RunService:Set3dRenderingEnabled(false)
        setfpscap(15)
        if getgenv().boostfps == false then
            RunService:Set3dRenderingEnabled(true)
            setfpscap(220)
        end
	end,
})

local HalloweenTab = Window:CreateTab("Halloween Event")
local HallowenSection = HalloweenTab:CreateSection("Halloween Farm")
HalloweenTab:CreateLabel("Equip Halloween Pets To Get More Pumpkins")
HalloweenTab:CreateToggle({
	Name = "Collect All Pumpkins",
	CurrentValue = false,
	Callback = function(t)
        getgenv().pumpkinfarm = t
        while pumpkinfarm do wait()
            for i,v in pairs(game:GetService("Workspace").Scripts.PumpkinsCollect.Storage:GetDescendants()) do
                if v.Name == "TouchInterest" and v.Parent then
                    firetouchinterest(playerHead, v.Parent, 0)
                    firetouchinterest(playerHead, v.Parent, 1)
                end
            end
        end
	end,
})

local CreditsTab = Window:CreateTab("Credits")
local CreditsSection = CreditsTab:CreateSection("Credit Section")
CreditsTab:CreateLabel("Scripter: abel#0002")
