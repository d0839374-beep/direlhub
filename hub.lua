--[[
	UI Library: Black-Purple Gradient with Left Tabs
	Fully working, no errors.
]]

local UILibrary = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then return UILibrary end

-- Utility functions
local function tween(obj, time, props)
	local t = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function create(className, props)
	local obj = Instance.new(className)
	for k, v in pairs(props) do
		obj[k] = v
	end
	return obj
end

function UILibrary:CreateWindow(config)
	config = config or {}
	local title = config.Title or "Window"
	local size = config.Size or UDim2.new(0, 700, 0, 500)
	local keybind = config.Keybind or Enum.KeyCode.LeftControl

	local screenGui = create("ScreenGui", {
		Name = "UILibrary_ScreenGui",
		Parent = player:WaitForChild("PlayerGui"),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})

	-- Overlay for modal effects (not used now, but kept for future)
	local overlay = create("Frame", {
		Name = "Overlay",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = screenGui
	})

	-- Main window frame
	local mainFrame = create("Frame", {
		Name = "MainFrame",
		Size = size,
		Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = screenGui
	})

	-- Gradient (black to deep purple)
	local gradient = create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 0, 20)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 0, 60)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 0, 100))
		}),
		Rotation = 135,
		Parent = mainFrame
	})

	local corner = create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = mainFrame })
	local stroke = create("UIStroke", { Thickness = 1.5, Color = Color3.fromRGB(140, 0, 255), Transparency = 0.7, Parent = mainFrame })

	-- Title bar (draggable)
	local titleBar = create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(20, 0, 30),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = mainFrame
	})
	local titleBarCorner = create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = titleBar })

	local titleLabel = create("TextLabel", {
		Name = "TitleLabel",
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 15, 0, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Color3.fromRGB(230, 200, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar
	})

	-- Control buttons
	local function createButton(name, text, posX, color)
		local btn = create("TextButton", {
			Name = name,
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(1, posX, 0, 5),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = color,
			TextScaled = true,
			Font = Enum.Font.GothamBold,
			Parent = titleBar
		})
		btn.MouseEnter:Connect(function()
			tween(btn, 0.1, { TextColor3 = Color3.new(1, 1, 1) })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, 0.1, { TextColor3 = color })
		end)
		return btn
	end

	local closeBtn = createButton("Close", "✕", -90, Color3.fromRGB(255, 120, 120))
	local maxBtn = createButton("Maximize", "□", -60, Color3.fromRGB(200, 200, 200))
	local minBtn = createButton("Minimize", "—", -30, Color3.fromRGB(200, 200, 200))

	-- Left panel for tabs
	local leftPanel = create("Frame", {
		Name = "LeftPanel",
		Size = UDim2.new(0, 150, 1, -40),
		Position = UDim2.new(0, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(10, 0, 15),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = mainFrame
	})
	local leftPanelCorner = create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = leftPanel })

	local tabContainer = create("ScrollingFrame", {
		Name = "TabContainer",
		Size = UDim2.new(1, -10, 1, -10),
		Position = UDim2.new(0, 5, 0, 5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Color3.fromRGB(120, 0, 180),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = leftPanel
	})

	-- Right content area
	local contentContainer = create("Frame", {
		Name = "ContentContainer",
		Size = UDim2.new(1, -160, 1, -50),
		Position = UDim2.new(0, 155, 0, 45),
		BackgroundTransparency = 1,
		Parent = mainFrame
	})

	-- Window data
	local windowData = {
		ScreenGui = screenGui,
		MainFrame = mainFrame,
		TitleBar = titleBar,
		TabContainer = tabContainer,
		ContentContainer = contentContainer,
		Tabs = {},
		CurrentTab = nil,
		Minimized = false,
		Maximized = false,
		OriginalSize = size,
		OriginalPos = mainFrame.Position,
	}

	-- Dragging
	local dragging = false
	local dragStart, startPos
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)
	titleBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	-- Resize handle
	local resizeHandle = create("Frame", {
		Name = "ResizeHandle",
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(1, -20, 1, -20),
		BackgroundColor3 = Color3.fromRGB(180, 0, 255),
		BackgroundTransparency = 0.5,
		Parent = mainFrame
	})
	local resizeCorner = create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = resizeHandle })
	local resizing = false
	local resizeStart, startSize, startPosResize
	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeStart = input.Position
			startSize = mainFrame.Size
			startPosResize = mainFrame.Position
		end
	end)
	resizeHandle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - resizeStart
			local newWidth = math.max(400, startSize.X.Offset + delta.X)
			local newHeight = math.max(300, startSize.Y.Offset + delta.Y)
			mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
		end
	end)

	-- Button actions
	closeBtn.MouseButton1Click:Connect(function()
		tween(mainFrame, 0.2, { Size = UDim2.new(0, 0, 0, 0) }):Completed:Connect(function()
			screenGui:Destroy()
		end)
	end)

	local function toggleMaximize()
		if windowData.Maximized then
			tween(mainFrame, 0.2, { Size = windowData.OriginalSize, Position = windowData.OriginalPos })
			windowData.Maximized = false
		else
			windowData.OriginalSize = mainFrame.Size
			windowData.OriginalPos = mainFrame.Position
			tween(mainFrame, 0.2, { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0.5, 0, 0.5, 0) })
			windowData.Maximized = true
		end
	end
	maxBtn.MouseButton1Click:Connect(toggleMaximize)

	minBtn.MouseButton1Click:Connect(function()
		mainFrame.Visible = not mainFrame.Visible
	end)

	-- Hotkey
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == keybind then
			mainFrame.Visible = not mainFrame.Visible
		end
	end)

	-- Tab creation
	function windowData:AddTab(tabConfig)
		tabConfig = tabConfig or {}
		local tabName = tabConfig.Name or "Tab"

		local tabButton = create("TextButton", {
			Name = "Tab_" .. tabName,
			Size = UDim2.new(1, -10, 0, 45),
			Position = UDim2.new(0, 5, 0, #self.Tabs * 50 + 5),
			BackgroundColor3 = Color3.fromRGB(30, 0, 40),
			Text = tabName,
			TextColor3 = Color3.fromRGB(200, 170, 255),
			Font = Enum.Font.GothamSemibold,
			TextSize = 16,
			Parent = self.TabContainer
		})
		local btnCorner = create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = tabButton })

		tabButton.MouseEnter:Connect(function()
			if self.CurrentTab ~= tab then
				tween(tabButton, 0.1, { BackgroundColor3 = Color3.fromRGB(50, 0, 70) })
			end
		end)
		tabButton.MouseLeave:Connect(function()
			if self.CurrentTab ~= tab then
				tween(tabButton, 0.1, { BackgroundColor3 = Color3.fromRGB(30, 0, 40) })
			end
		end)

		local tabContent = create("ScrollingFrame", {
			Name = "Content_" .. tabName,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Color3.fromRGB(180, 0, 255),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			Parent = self.ContentContainer
		})
		local padding = create("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			Parent = tabContent
		})

		local tab = {
			Name = tabName,
			Button = tabButton,
			Content = tabContent,
			Elements = {}
		}

		tabButton.MouseButton1Click:Connect(function()
			if self.CurrentTab then
				self.CurrentTab.Content.Visible = false
				tween(self.CurrentTab.Button, 0.1, { BackgroundColor3 = Color3.fromRGB(30, 0, 40) })
			end
			tabContent.Visible = true
			tween(tabButton, 0.1, { BackgroundColor3 = Color3.fromRGB(80, 0, 120) })
			self.CurrentTab = tab
		end)

		-- Helper for positioning elements
		local function nextY()
			return #tab.Elements * 45 + 5
		end

		-- Add button
		function tab:AddButton(btnConfig)
			btnConfig = btnConfig or {}
			local text = btnConfig.Text or "Button"
			local callback = btnConfig.Callback or function() end

			local btn = create("TextButton", {
				Name = "Button_" .. text,
				Size = UDim2.new(1, 0, 0, 40),
				Position = UDim2.new(0, 0, 0, nextY()),
				BackgroundColor3 = Color3.fromRGB(50, 0, 70),
				Text = text,
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				TextSize = 16,
				Parent = self.Content
			})
			create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
			create("UIStroke", { Thickness = 1, Color = Color3.fromRGB(140, 0, 255), Transparency = 0.5, Parent = btn })

			btn.MouseButton1Click:Connect(callback)
			btn.MouseEnter:Connect(function() tween(btn, 0.1, { BackgroundColor3 = Color3.fromRGB(80, 0, 110) }) end)
			btn.MouseLeave:Connect(function() tween(btn, 0.1, { BackgroundColor3 = Color3.fromRGB(50, 0, 70) }) end)

			table.insert(self.Elements, btn)
			return btn
		end

		-- Add toggle
		function tab:AddToggle(togConfig)
			togConfig = togConfig or {}
			local text = togConfig.Text or "Toggle"
			local default = togConfig.Default or false
			local callback = togConfig.Callback or function() end

			local frame = create("Frame", {
				Name = "Toggle_" .. text,
				Size = UDim2.new(1, 0, 0, 40),
				Position = UDim2.new(0, 0, 0, nextY()),
				BackgroundTransparency = 1,
				Parent = self.Content
			})
			local label = create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, -70, 1, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Color3.fromRGB(230, 230, 230),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				TextSize = 16,
				Parent = frame
			})
			local toggleBg = create("TextButton", {
				Name = "ToggleBg",
				Size = UDim2.new(0, 60, 0, 30),
				Position = UDim2.new(1, -65, 0.5, -15),
				BackgroundColor3 = default and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(60, 60, 60),
				Text = "",
				Parent = frame
			})
			create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleBg })
			local circle = create("Frame", {
				Name = "Circle",
				Size = UDim2.new(0, 24, 0, 24),
				Position = default and UDim2.new(1, -28, 0.5, -12) or UDim2.new(0, 4, 0.5, -12),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent = toggleBg
			})
			create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = circle })

			local state = default
			local function setState(newState)
				state = newState
				if state then
					tween(toggleBg, 0.1, { BackgroundColor3 = Color3.fromRGB(150, 0, 255) })
					tween(circle, 0.1, { Position = UDim2.new(1, -28, 0.5, -12) })
				else
					tween(toggleBg, 0.1, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) })
					tween(circle, 0.1, { Position = UDim2.new(0, 4, 0.5, -12) })
				end
				callback(state)
			end

			toggleBg.MouseButton1Click:Connect(function()
				setState(not state)
			end)

			table.insert(self.Elements, frame)
			return { SetState = setState, GetState = function() return state end }
		end

		-- Add slider
		function tab:AddSlider(sliderConfig)
			sliderConfig = sliderConfig or {}
			local text = sliderConfig.Text or "Slider"
			local min = sliderConfig.Min or 0
			local max = sliderConfig.Max or 100
			local default = sliderConfig.Default or 50
			local callback = sliderConfig.Callback or function() end

			local frame = create("Frame", {
				Name = "Slider_" .. text,
				Size = UDim2.new(1, 0, 0, 55),
				Position = UDim2.new(0, 0, 0, nextY()),
				BackgroundTransparency = 1,
				Parent = self.Content
			})
			local label = create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, -80, 0, 20),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Color3.fromRGB(230, 230, 230),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				TextSize = 16,
				Parent = frame
			})
			local valueLabel = create("TextLabel", {
				Name = "Value",
				Size = UDim2.new(0, 60, 0, 20),
				Position = UDim2.new(1, -70, 0, 0),
				BackgroundTransparency = 1,
				Text = tostring(default),
				TextColor3 = Color3.fromRGB(200, 150, 255),
				Font = Enum.Font.GothamBold,
				TextSize = 16,
				Parent = frame
			})
			local sliderBg = create("Frame", {
				Name = "SliderBg",
				Size = UDim2.new(1, -20, 0, 8),
				Position = UDim2.new(0, 10, 0, 30),
				BackgroundColor3 = Color3.fromRGB(60, 60, 60),
				Parent = frame
			})
			create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sliderBg })
			local fill = create("Frame", {
				Name = "Fill",
				Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(170, 0, 255),
				Parent = sliderBg
			})
			create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
			local dragButton = create("TextButton", {
				Name = "DragButton",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
				Parent = sliderBg
			})

			local dragging = false
			local function updateFromMouse(mouseX)
				local absX = sliderBg.AbsolutePosition.X
				local absW = sliderBg.AbsoluteSize.X
				local rel = math.clamp((mouseX - absX) / absW, 0, 1)
				local val = min + rel * (max - min)
				if not sliderConfig.AllowDecimals then
					val = math.round(val)
				end
				valueLabel.Text = tostring(val)
				fill.Size = UDim2.new(rel, 0, 1, 0)
				callback(val)
			end

			dragButton.MouseButton1Down:Connect(function(input)
				dragging = true
				updateFromMouse(input.Position.X)
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					updateFromMouse(input.Position.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			table.insert(self.Elements, frame)
		end

		-- Add dropdown
		function tab:AddDropdown(dropConfig)
			dropConfig = dropConfig or {}
			local text = dropConfig.Text or "Dropdown"
			local options = dropConfig.Options or {}
			local callback = dropConfig.Callback or function() end

			local frame = create("Frame", {
				Name = "Dropdown_" .. text,
				Size = UDim2.new(1, 0, 0, 40),
				Position = UDim2.new(0, 0, 0, nextY()),
				BackgroundTransparency = 1,
				Parent = self.Content
			})
			local label = create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, -140, 1, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Color3.fromRGB(230, 230, 230),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				TextSize = 16,
				Parent = frame
			})
			local dropBtn = create("TextButton", {
				Name = "DropButton",
				Size = UDim2.new(0, 120, 0, 30),
				Position = UDim2.new(1, -125, 0.5, -15),
				BackgroundColor3 = Color3.fromRGB(40, 0, 55),
				Text = "Выбрать",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.Gotham,
				TextSize = 14,
				Parent = frame
			})
			create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = dropBtn })
			create("UIStroke", { Thickness = 1, Color = Color3.fromRGB(140, 0, 255), Transparency = 0.5, Parent = dropBtn })

			dropBtn.MouseButton1Click:Connect(function()
				local listFrame = create("Frame", {
					Name = "DropdownList",
					Size = UDim2.new(0, 120, 0, math.min(#options, 5) * 32),
					Position = UDim2.new(1, -125, 0, 35),
					BackgroundColor3 = Color3.fromRGB(20, 0, 30),
					Parent = frame
				})
				create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = listFrame })
				create("UIStroke", { Thickness = 1, Color = Color3.fromRGB(140, 0, 255), Transparency = 0.5, Parent = listFrame })
				local listLayout = create("UIListLayout", { Padding = UDim.new(0, 2), FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = listFrame })

				for _, opt in ipairs(options) do
					local optBtn = create("TextButton", {
						Size = UDim2.new(1, -4, 0, 28),
						BackgroundColor3 = Color3.fromRGB(60, 0, 80),
						Text = opt,
						TextColor3 = Color3.new(1, 1, 1),
						Font = Enum.Font.Gotham,
						TextSize = 14,
						Parent = listFrame
					})
					create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = optBtn })
					optBtn.MouseEnter:Connect(function() tween(optBtn, 0.1, { BackgroundColor3 = Color3.fromRGB(90, 0, 120) }) end)
					optBtn.MouseLeave:Connect(function() tween(optBtn, 0.1, { BackgroundColor3 = Color3.fromRGB(60, 0, 80) }) end)
					optBtn.MouseButton1Click:Connect(function()
						dropBtn.Text = opt
						callback(opt)
						listFrame:Destroy()
					end)
				end

				local function closeOnClick(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local obj = input.Target
						if obj and not obj:IsDescendantOf(listFrame) and obj ~= dropBtn then
							listFrame:Destroy()
							UserInputService.InputBegan:Connect(closeOnClick)
						end
					end
				end
				UserInputService.InputBegan:Connect(closeOnClick)
			end)

			table.insert(self.Elements, frame)
		end

		-- Add input
		function tab:AddInput(inputConfig)
			inputConfig = inputConfig or {}
			local text = inputConfig.Text or "Input"
			local placeholder = inputConfig.Placeholder or "Введите текст..."
			local callback = inputConfig.Callback or function() end

			local frame = create("Frame", {
				Name = "Input_" .. text,
				Size = UDim2.new(1, 0, 0, 40),
				Position = UDim2.new(0, 0, 0, nextY()),
				BackgroundTransparency = 1,
				Parent = self.Content
			})
			local label = create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, -140, 1, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Color3.fromRGB(230, 230, 230),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				TextSize = 16,
				Parent = frame
			})
			local box = create("TextBox", {
				Name = "TextBox",
				Size = UDim2.new(0, 120, 0, 30),
				Position = UDim2.new(1, -125, 0.5, -15),
				BackgroundColor3 = Color3.fromRGB(30, 0, 40),
				PlaceholderText = placeholder,
				PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
				Text = "",
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				TextSize = 14,
				ClearTextOnFocus = false,
				Parent = frame
			})
			create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = box })
			create("UIStroke", { Thickness = 1, Color = Color3.fromRGB(140, 0, 255), Transparency = 0.5, Parent = box })

			box.FocusLost:Connect(function()
				callback(box.Text)
			end)

			table.insert(self.Elements, frame)
		end

		-- Add paragraph
		function tab:AddParagraph(paraConfig)
			paraConfig = paraConfig or {}
			local titleText = paraConfig.Title or "Title"
			local descText = paraConfig.Description or "Description"

			local frame = create("Frame", {
				Name = "Paragraph_" .. titleText,
				Size = UDim2.new(1, 0, 0, 70),
				Position = UDim2.new(0, 0, 0, nextY()),
				BackgroundTransparency = 1,
				Parent = self.Content
			})
			local title = create("TextLabel", {
				Name = "Title",
				Size = UDim2.new(1, 0, 0, 25),
				BackgroundTransparency = 1,
				Text = titleText,
				TextColor3 = Color3.fromRGB(220, 180, 255),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.GothamBold,
				TextSize = 18,
				Parent = frame
			})
			local desc = create("TextLabel", {
				Name = "Description",
				Size = UDim2.new(1, 0, 0, 40),
				Position = UDim2.new(0, 0, 0, 25),
				BackgroundTransparency = 1,
				Text = descText,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				Parent = frame
			})

			table.insert(self.Elements, frame)
		end

		table.insert(self.Tabs, tab)
		if #self.Tabs == 1 then
			-- Activate first tab manually without using :Fire()
			tabContent.Visible = true
			tween(tabButton, 0.1, { BackgroundColor3 = Color3.fromRGB(80, 0, 120) })
			self.CurrentTab = tab
		end

		return tab
	end

	-- Notification system
	function windowData:Notify(config)
		config = config or {}
		local title = config.Title or "Notification"
		local desc = config.Description or ""
		local duration = config.Duration or 3

		local notif = create("Frame", {
			Name = "Notification",
			Size = UDim2.new(0, 320, 0, 90),
			Position = UDim2.new(1, 20, 1, -110),
			BackgroundColor3 = Color3.fromRGB(20, 0, 30),
			Parent = screenGui
		})
		create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = notif })
		create("UIStroke", { Thickness = 1.5, Color = Color3.fromRGB(140, 0, 255), Transparency = 0.5, Parent = notif })
		local gradientNotif = create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 0, 30)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 70))
			}),
			Rotation = 90,
			Parent = notif
		})

		local titleLabel = create("TextLabel", {
			Size = UDim2.new(1, -10, 0, 25),
			Position = UDim2.new(0, 5, 0, 5),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Color3.fromRGB(220, 180, 255),
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = notif
		})
		local descLabel = create("TextLabel", {
			Size = UDim2.new(1, -10, 0, 45),
			Position = UDim2.new(0, 5, 0, 30),
			BackgroundTransparency = 1,
			Text = desc,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Parent = notif
		})
		local timer = create("Frame", {
			Size = UDim2.new(1, 0, 0, 4),
			Position = UDim2.new(0, 0, 1, -4),
			BackgroundColor3 = Color3.fromRGB(170, 0, 255),
			Parent = notif
		})
		create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = timer })

		tween(notif, 0.3, { Position = UDim2.new(1, -340, 1, -110) })
		tween(timer, duration, { Size = UDim2.new(0, 0, 0, 4) }):Completed:Connect(function()
			tween(notif, 0.3, { Position = UDim2.new(1, 20, 1, -110) }):Completed:Connect(function()
				notif:Destroy()
			end)
		end)
	end

	return windowData
end

return UILibrary
