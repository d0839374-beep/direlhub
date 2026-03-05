--[[
	Библиотека интерфейса с вкладками справа
	Автор: по заказу с Discord
	Стиль: чёрно-фиолетовый градиент
]]

local UILibrary = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
	return UILibrary -- заглушка, если выполняется на сервере
end

-- Служебные функции
local function create(className, props)
	local obj = Instance.new(className)
	for k, v in pairs(props) do
		obj[k] = v
	end
	return obj
end

function UILibrary:CreateWindow(config)
	config = config or {}
	local windowTitle = config.Title or "Window"
	local size = config.Size or UDim2.new(0, 600, 0, 400)
	local position = config.Position or UDim2.new(0.5, -300, 0.5, -200)

	-- Главный контейнер
	local screenGui = create("ScreenGui", {
		Name = "UILibrary_Main",
		Parent = player:WaitForChild("PlayerGui"),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})

	-- Фон окна (основной фрейм)
	local mainFrame = create("Frame", {
		Name = "MainFrame",
		Size = size,
		Position = position,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Parent = screenGui
	})

	-- Градиент для главного фрейма
	local gradient = create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 0, 20)),    -- тёмно-фиолетовый
			ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 0, 50))     -- ярче фиолетовый
		}),
		Rotation = 90, -- сверху вниз
		Parent = mainFrame
	})

	-- Скруглённые углы
	local corner = create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = mainFrame
	})

	-- Заголовок окна (для перетаскивания)
	local titleBar = create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Color3.fromRGB(20, 0, 30),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = mainFrame
	})
	local titleCorner = create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = titleBar
	})
	-- Срезаем нижние углы у заголовка (чтобы не перекрывались с окном)
	titleCorner:Destroy() -- проще убрать, либо использовать отдельный фрейм без скругления снизу
	-- Сделаем просто прямоугольник с закруглением только сверху: используем другой подход
	-- Но для простоты оставим прямоугольник

	-- Надпись заголовка
	local titleLabel = create("TextLabel", {
		Name = "TitleLabel",
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = windowTitle,
		TextColor3 = Color3.fromRGB(180, 130, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		Parent = titleBar
	})

	-- Кнопка закрытия
	local closeButton = create("TextButton", {
		Name = "CloseButton",
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -30, 0, 0),
		BackgroundTransparency = 1,
		Text = "X",
		TextColor3 = Color3.fromRGB(255, 100, 100),
		TextScaled = true,
		Font = Enum.Font.GothamBold,
		Parent = titleBar
	})
	closeButton.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	-- Контейнер для вкладок (правая часть)
	local tabContainer = create("ScrollingFrame", {
		Name = "TabContainer",
		Size = UDim2.new(0, 120, 1, -40), -- ширина 120, отступ сверху 40 (под заголовок)
		Position = UDim2.new(1, -120, 0, 40),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Color3.fromRGB(100, 0, 150),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = mainFrame
	})

	-- Контейнер для контента вкладок (левая часть)
	local contentContainer = create("Frame", {
		Name = "ContentContainer",
		Size = UDim2.new(1, -140, 1, -40), -- ширина = вся ширина окна минус ширина вкладок (120) и отступы
		Position = UDim2.new(0, 10, 0, 40),
		BackgroundTransparency = 1,
		Parent = mainFrame
	})

	-- Данные окна
	local windowData = {
		ScreenGui = screenGui,
		MainFrame = mainFrame,
		TabContainer = tabContainer,
		ContentContainer = contentContainer,
		Tabs = {},
		CurrentTab = nil
	}

	-- Функция перетаскивания
	local dragging = false
	local dragStart = nil
	local startPos = nil
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Метод для добавления вкладки
	function windowData:AddTab(tabConfig)
		tabConfig = tabConfig or {}
		local tabName = tabConfig.Name or "Tab"

		-- Создаём кнопку вкладки в правом контейнере
		local tabButton = create("TextButton", {
			Name = "TabButton_" .. tabName,
			Size = UDim2.new(1, -10, 0, 35),
			Position = UDim2.new(0, 5, 0, (#self.Tabs * 40) + 5),
			BackgroundColor3 = Color3.fromRGB(30, 0, 40),
			BackgroundTransparency = 0.2,
			Text = tabName,
			TextColor3 = Color3.fromRGB(200, 150, 255),
			Font = Enum.Font.GothamSemibold,
			TextSize = 16,
			Parent = self.TabContainer
		})
		local btnCorner = create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = tabButton})

		-- Контейнер для контента вкладки (скрыт изначально)
		local tabContent = create("Frame", {
			Name = "Content_" .. tabName,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = self.ContentContainer
		})

		-- Табличка с методами для добавления элементов в эту вкладку
		local tab = {
			Name = tabName,
			Button = tabButton,
			Content = tabContent,
			Elements = {}
		}

		-- Метод добавления подзаголовка (Label)
			function tab:AddLabel(config)
			local text = config.Text or "Label"
			local textSize = config.Size or 18
			local label = create("TextLabel", {
				Name = "Label_" .. text,
				Size = UDim2.new(1, -20, 0, 25),
				Position = UDim2.new(0, 10, 0, #self.Elements * 30 + 5),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Color3.fromRGB(210, 180, 255),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.GothamBold,
				TextSize = textSize,
				Parent = self.Content
			})
			table.insert(self.Elements, label)
			return label
		end

		-- Метод добавления кнопки
		function tab:AddButton(config)
			local text = config.Text or "Button"
			local callback = config.Callback or function() end
			local button = create("TextButton", {
				Name = "Button_" .. text,
				Size = UDim2.new(1, -30, 0, 35),
				Position = UDim2.new(0, 15, 0, #self.Elements * 30 + 5),
				BackgroundColor3 = Color3.fromRGB(50, 0, 70),
				Text = text,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.Gotham,
				TextSize = 16,
				Parent = self.Content
			})
			local btnCorner = create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = button})
			button.MouseButton1Click:Connect(callback)
			table.insert(self.Elements, button)
			return button
		end

		-- Метод добавления простого текста
		function tab:AddText(config)
			local text = config.Text or "Text"
			local label = create("TextLabel", {
				Name = "Text_" .. text,
				Size = UDim2.new(1, -20, 0, 20),
				Position = UDim2.new(0, 10, 0, #self.Elements * 30 + 5),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				Parent = self.Content
			})
			table.insert(self.Elements, label)
			return label
		end

		-- При клике на кнопку вкладки показываем соответствующий контент
		tabButton.MouseButton1Click:Connect(function()
			if self.CurrentTab then
				self.CurrentTab.Content.Visible = false
			end
			tabContent.Visible = true
			self.CurrentTab = tab
		end)

		table.insert(self.Tabs, tab)

		-- Если это первая вкладка, активируем её
		if #self.Tabs == 1 then
			tabButton.MouseButton1Click:Fire()
		end

		return tab
	end

	return windowData
end

return UILibrary
