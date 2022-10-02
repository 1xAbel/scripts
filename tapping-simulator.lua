if game:GetService("CoreGui"):FindFirstChild("Vynixius UI Library") then
    game:GetService("CoreGui"):FindFirstChild("Vynixius UI Library"):Destroy()
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/UI-Libraries/main/Vynixius/Source.lua"))()

local lp = game.Players.LocalPlayer

local Window = Library:AddWindow({
	title = {"abel's script", "Tapping Simualator"},
	theme = {
		Accent = Color3.fromRGB(0, 255, 0)
	},
	key = Enum.KeyCode.RightControl,
	default = true
})

local Main = Window:AddTab("Main", {default = false})

local MainSection = Main:AddSection("Farm", {default = false})

local Toggle = MainSection:AddToggle("Auto Tap", {flag = "Toggle_Flag", default = false}, function(t)
	getgenv().autoTap = t

	while autoTap do wait()
	game:GetService("ReplicatedStorage").Events.Tap:FireServer()
	end
end)

local Dropdown = MainSection:AddDropdown("Rebirth amount", {"1", "5", "10", "20", "100", "500", "4000"}, {default = "nil"}, function(selected)
	getgenv().rebirthamount = selected
end)

local Toggle = MainSection:AddToggle("Auto Rebirth", {flag = "Toggle_Flag", default = false}, function(bool)
	getgenv().autoRebirth = bool

	while autoRebirth do wait()
		local args = {
		[1] = rebirthamount
	}

	game:GetService("ReplicatedStorage").Events.Rebirth:FireServer(unpack(args))
	end
end)

local EggsSection = Main:AddSection("Pets", {default = false})

local Dropdown = EggsSection:AddDropdown("Select Egg", {"Starter", "Wood Egg", "Jungle Egg", "Forest Egg", "Bee Egg", "Snow Egg", "Desert Egg", "Death Egg", "Beach Egg", "Mines Egg", "Cloud Egg", "Coral Egg", "Darkheart Egg", "Flameslands Egg", "Swamp Egg", "55M Egg"}, {default = "nil"}, function(selected)
	getgenv().eggtype = selected
end)

local Toggle = EggsSection:AddToggle("Auto Hatch", {flag = "Toggle_Flag", default = false}, function(bool)
	getgenv().autoHatch = bool 

	while autoHatch do wait()
		local args = {
			[1] = {},
			[2] = eggtype,
			[3] = 1
		}

		game:GetService("ReplicatedStorage").Events.HatchEgg:InvokeServer(unpack(args))
	end
end)

local Credits = Window:AddTab("Credits", {default = false})

local Credits = Credits:AddSection("Credits", {default = false})

local DualLabel = Credits:AddDualLabel({"Scripter:", "abel#0001"})
local DualLabel = Credits:AddDualLabel({"Teacher:", "LioK..!#4205"})
local DualLabel = Credits:AddDualLabel({"UI Library:", "RegularVynixu"})
local ClipboardLabel = Credits:AddClipboardLabel("Copy Discord Invite", function()
	return "discord.gg/grWfPQ7fky"
end)
