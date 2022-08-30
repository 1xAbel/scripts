if game:GetService("CoreGui"):FindFirstChild("ui") then
    game:GetService("CoreGui"):FindFirstChild("ui"):Destroy()
end

local vu = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local lib = loadstring(game:HttpGet"https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt")()

local win = lib:Window("Strong Ninja Simulator | abels script",Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)

local tab = win:Tab("Main")


tab:Toggle("Auto Swing",false, function(t)
    getgenv().autoSwing = t

    while getgenv().autoSwing == true do task.wait()
        vu:ClickButton1(Vector2.new(907,610))
    end
end)

tab:Toggle("Auto Rebirth",false, function(t)
    getgenv().autoRebirth = t

    while getgenv().autoRebirth == true do wait()
        local args = {
            [1] = {}
        }
        
        game:GetService("ReplicatedStorage").Framework.Modules.Shared.Internal.Modules:FindFirstChild("2 | Network").Remotes.s_controller_rebirth:InvokeServer(unpack(args))
    end
end)

tab:Toggle('Auto Equip Best Pets',false, function(t)
    getgenv().autoEquip = t
    
    while getgenv().autoEquip == true do wait()
        local args = {
    [1] = {}
    }
    
    game:GetService("ReplicatedStorage").Framework.Modules.Shared.Internal.Modules:FindFirstChild("2 | Network").Remotes.s_pets_bestpets:FireServer(unpack(args))
    wait(10.5)
    end
end)


local teleport = win:Tab('Teleports')

teleport:Button("Beach", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1309.5623779296875, 0.55409836769104, 1660.7957763671875)
end)
teleport:Button("Laboratory", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-473.22509765625, 0.5540494918823242, 1328.114501953125)
end)
teleport:Button("Hell", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-468.5224914550781, 0.4209734797477722, 250.02610778808594)
end)
teleport:Button("Heaven", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1591.4676513671875, 0.421047568321228, -45.73652648925781)
end)
teleport:Button("Marine", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2272.8330078125, 0.42100971937179565, 937.55224609375)
end)
teleport:Button("Alien", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-819.4315795898438, 0.4211675226688385, -563.2957763671875)
end)

local misc = win:Tab('Misc')

misc:Toggle('Boost Fps',false, function(t)
    getgenv().boostfps = t
    RunService:Set3dRenderingEnabled(false)
    setfpscap(15)
    if getgenv().boostfps == false then
    RunService:Set3dRenderingEnabled(true)
    setfpscap(220)
    end
end)
misc:Button("Rejon", function()
    game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)

local discord = win:Tab('Credits')

discord:Label("Scripter: abel#0002")
discord:Button("Copy Discord Invite", function()
    lib:Notification("Notification", "Discord Invite Successfully Copy Discord Invite", "Thank You!")
    setclipboard('https://discord.gg/grWfPQ7fky')
end)
