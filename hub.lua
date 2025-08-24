local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Tuturial_UI_Library/main/UI_Template_1"))()

local Window = Library.CreateLib("DIRELHUB", "RJTheme3")

local Tab = Window:NewTab("Player")

local Section = Tab:NewSection("Speed")

Section:NewSlider("Speed", "speed 0-500", 500, 0, function(s) -- 500 (Макс. значение) | 0 (Мин. значение)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

Section:NewTextBox("Speed", "speed", function(e)
  game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = e
end)

local Section = Tab:NewSection("Jump power")

Section:NewSlider("JumpPower", "высота прыжка", 500, 0, function(s) -- 500 (Макс. значение) | 0 (Мин. значение)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = s
end)

Section:NewTextBox("JumpPower", "высота прыжка", function(s)
  game.Players.LocalPlayer.Character.Humanoid.JumpPower = s
end)

local Section = Tab:NewSection("fly")

Section:NewButton("fly", "Полет", function(s)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
end)
