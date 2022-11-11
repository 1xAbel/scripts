getgenv().killaura = true
while killaura do wait()
  local args = {
    [1] = "blacks make me mad",
    [2] = "All"
  }

  game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(args))
end
