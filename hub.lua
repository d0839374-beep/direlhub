local Library = require(script.Parent.UILibrary) -- путь к модулю

local win = Library:CreateWindow({
	Title = "Elegant Panel",
	Size = UDim2.new(0, 750, 0, 550),
	Keybind = Enum.KeyCode.LeftControl
})

local home = win:AddTab({ Name = "Главная" })
local scripts = win:AddTab({ Name = "Скрипты" })
local settings = win:AddTab({ Name = "Настройки" })

home:AddParagraph({
	Title = "Добро пожаловать",
	Description = "Это рабочая библиотека с чёрно-фиолетовым градиентом."
})
home:AddButton({
	Text = "Тест",
	Callback = function()
		print("Нажато!")
		win:Notify({
			Title = "Успех",
			Description = "Кнопка сработала",
			Duration = 2
		})
	end
})
home:AddToggle({
	Text = "Включить",
	Default = false,
	Callback = function(state) print("Тумблер:", state) end
})
home:AddSlider({
	Text = "Громкость",
	Min = 0,
	Max = 100,
	Default = 50,
	AllowDecimals = false,
	Callback = function(val) print("Громкость:", val) end
})

scripts:AddDropdown({
	Text = "Выбери",
	Options = {"A", "B", "C"},
	Callback = function(opt) print("Выбрано:", opt) end
})
scripts:AddInput({
	Text = "Имя",
	Placeholder = "Введите имя",
	Callback = function(text) print("Введено:", text) end
})

settings:AddToggle({ Text = "Автозапуск", Default = true, Callback = function(s) print("Автозапуск:", s) end })
settings:AddButton({ Text = "Сохранить", Callback = function() print("Сохранено") end })
