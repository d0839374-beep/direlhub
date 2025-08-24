local library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ShaddowScripts/Main/main/Library"))()

local Main = library:CreateWindow("Main","Crimson")

local tab = Main:CreateTab("Player")

tab:CreateSlider("Jump power",1,500,function(s)
game.Players.LocalPlayer.Character.Humanoid.JumpPower = s
end)

tab:CreateSlider("Speed",1,500,function(s)
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

tab:CreateButton("fly",function(s)
loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
end)

local tab2 = Main:CreateTab("Misc")
