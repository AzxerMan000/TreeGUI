--[[
	TreeUI - Roblox GUI Library
	A comprehensive single-file GUI library for creating beautiful interfaces in Roblox
	
	Version: 1.0.0
	Theme: Black & Cyan
	
	Features:
	- Complete component system
	- Smooth animations
	- Dark theme with cyan accents
	- Single file architecture
	- Easy to integrate and use
]]

local TreeUI = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- Library version and info
TreeUI.Version = "1.0.0"
TreeUI.Author = "TreeUI Library"

-- Theme configuration
local Theme = {
	colors = {
		primary = Color3.fromRGB(0, 255, 255), -- Cyan
		secondary = Color3.fromRGB(0, 200, 200), -- Darker cyan
		background = Color3.fromRGB(26, 26, 26), -- Dark gray
		surface = Color3.fromRGB(40, 40, 40), -- Lighter gray
		surfaceLight = Color3.fromRGB(60, 60, 60), -- Even lighter gray
		text = Color3.fromRGB(255, 255, 255), -- White
		textSecondary = Color3.fromRGB(180, 180, 180), -- Light gray
		success = Color3.fromRGB(0, 255, 127), -- Green cyan
		warning = Color3.fromRGB(255, 215, 0), -- Gold
		error = Color3.fromRGB(255, 69, 58), -- Red
		border = Color3.fromRGB(80, 80, 80), -- Gray border
		shadow = Color3.fromRGB(0, 0, 0) -- Black shadow
	},
	
	fonts = {
		primary = Enum.Font.Gotham,
		secondary = Enum.Font.GothamMedium,
		bold = Enum.Font.GothamBold
	},
	
	sizes = {
		borderRadius = 8,
		shadowOffset = Vector2.new(2, 4),
		padding = {
			small = 8,
			medium = 16,
			large = 24
		}
	},
	
	animations = {
		fast = 0.15,
		normal = 0.3,
		slow = 0.5
	}
}

-- Utility functions
local Utils = {
	-- Convert hex to Color3
	hexToColor3 = function(hex)
		hex = hex:gsub("#", "")
		local r = tonumber(hex:sub(1, 2), 16) / 255
		local g = tonumber(hex:sub(3, 4), 16) / 255
		local b = tonumber(hex:sub(5, 6), 16) / 255
		return Color3.new(r, g, b)
	end,
	
	-- Clamp value between min and max
	clamp = function(value, min, max)
		return math.max(min, math.min(max, value))
	end,
	
	-- Create glow effect
	createGlow = function(parent, color, intensity)
		intensity = intensity or 1
		local glow = Instance.new("Frame")
		glow.Name = "Glow"
		glow.Size = UDim2.new(1, 4, 1, 4)
		glow.Position = UDim2.new(0, -2, 0, -2)
		glow.BackgroundColor3 = color
		glow.BackgroundTransparency = 0.7
		glow.BorderSizePixel = 0
		glow.ZIndex = parent.ZIndex - 1
		glow.Parent = parent.Parent
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, Theme.sizes.borderRadius + 2)
		corner.Parent = glow
		
		-- Animate glow
		local glowTween = TweenService:Create(glow, 
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{BackgroundTransparency = 0.3}
		)
		glowTween:Play()
		
		return glow
	end
}

-- Initialize the library
function TreeUI.new(player)
	local player = player or Players.LocalPlayer
	if not player then
		warn("TreeUI: No player provided")
		return nil
	end
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TreeUIContainer"
	screenGui.Parent = player.PlayerGui
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	local self = {
		screenGui = screenGui,
		components = {},
		notifications = {}
	}
	
	setmetatable(self, {__index = TreeUI})
	return self
end

-- Window Component
function TreeUI:createWindow(config)
	config = config or {}
	
	local window = {
		frame = nil,
		titleBar = nil,
		titleText = nil,
		closeButton = nil,
		content = nil,
		shadow = nil,
		glow = nil
	}
	
	-- Create shadow
	window.shadow = Instance.new("Frame")
	window.shadow.Name = "Shadow"
	window.shadow.Size = config.size or UDim2.new(0, 400, 0, 300)
	window.shadow.Position = UDim2.new(
		(config.position or UDim2.new(0.5, -200, 0.5, -150)).X.Scale,
		(config.position or UDim2.new(0.5, -200, 0.5, -150)).X.Offset + Theme.sizes.shadowOffset.X,
		(config.position or UDim2.new(0.5, -200, 0.5, -150)).Y.Scale,
		(config.position or UDim2.new(0.5, -200, 0.5, -150)).Y.Offset + Theme.sizes.shadowOffset.Y
	)
	window.shadow.BackgroundColor3 = Theme.colors.shadow
	window.shadow.BackgroundTransparency = 0.7
	window.shadow.BorderSizePixel = 0
	window.shadow.Parent = self.screenGui
	
	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(0, Theme.sizes.borderRadius)
	shadowCorner.Parent = window.shadow
	
	-- Create main window frame
	window.frame = Instance.new("Frame")
	window.frame.Name = "TreeUIWindow"
	window.frame.Size = config.size or UDim2.new(0, 400, 0, 300)
	window.frame.Position = config.position or UDim2.new(0.5, -200, 0.5, -150)
	window.frame.BackgroundColor3 = Theme.colors.surface
	window.frame.BorderSizePixel = 0
	window.frame.Parent = self.screenGui
	
	-- Add corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Theme.sizes.borderRadius)
	corner.Parent = window.frame
	
	-- Add border stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.colors.primary
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	stroke.Parent = window.frame
	
	-- Create glow effect
	window.glow = Utils.createGlow(window.frame, Theme.colors.primary)
	
	-- Create title bar
	window.titleBar = Instance.new("Frame")
	window.titleBar.Name = "TitleBar"
	window.titleBar.Size = UDim2.new(1, 0, 0, 40)
	window.titleBar.Position = UDim2.new(0, 0, 0, 0)
	window.titleBar.BackgroundColor3 = Theme.colors.background
	window.titleBar.BorderSizePixel = 0
	window.titleBar.Parent = window.frame
	
	-- Title bar corner radius (top only)
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, Theme.sizes.borderRadius)
	titleCorner.Parent = window.titleBar
	
	-- Fix bottom corners of title bar
	local titleBarFix = Instance.new("Frame")
	titleBarFix.Size = UDim2.new(1, 0, 0.5, 0)
	titleBarFix.Position = UDim2.new(0, 0, 0.5, 0)
	titleBarFix.BackgroundColor3 = Theme.colors.background
	titleBarFix.BorderSizePixel = 0
	titleBarFix.Parent = window.titleBar
	
	-- Create title text
	window.titleText = Instance.new("TextLabel")
	window.titleText.Name = "Title"
	window.titleText.Size = UDim2.new(1, -50, 1, 0)
	window.titleText.Position = UDim2.new(0, 16, 0, 0)
	window.titleText.BackgroundTransparency = 1
	window.titleText.Text = config.title or "TreeUI Window"
	window.titleText.TextColor3 = Theme.colors.primary
	window.titleText.TextSize = 16
	window.titleText.Font = Theme.fonts.bold
	window.titleText.TextXAlignment = Enum.TextXAlignment.Left
	window.titleText.Parent = window.titleBar
	
	-- Create close button
	window.closeButton = Instance.new("TextButton")
	window.closeButton.Name = "CloseButton"
	window.closeButton.Size = UDim2.new(0, 30, 0, 30)
	window.closeButton.Position = UDim2.new(1, -35, 0, 5)
	window.closeButton.BackgroundColor3 = Theme.colors.error
	window.closeButton.BackgroundTransparency = 0.8
	window.closeButton.Text = "×"
	window.closeButton.TextColor3 = Theme.colors.text
	window.closeButton.TextSize = 18
	window.closeButton.Font = Theme.fonts.bold
	window.closeButton.Parent = window.titleBar
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0.5, 0)
	closeCorner.Parent = window.closeButton
	
	-- Create content area
	window.content = Instance.new("Frame")
	window.content.Name = "Content"
	window.content.Size = UDim2.new(1, 0, 1, -40)
	window.content.Position = UDim2.new(0, 0, 0, 40)
	window.content.BackgroundTransparency = 1
	window.content.Parent = window.frame
	
	-- Add padding to content
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, Theme.sizes.padding.medium)
	padding.PaddingBottom = UDim.new(0, Theme.sizes.padding.medium)
	padding.PaddingLeft = UDim.new(0, Theme.sizes.padding.medium)
	padding.PaddingRight = UDim.new(0, Theme.sizes.padding.medium)
	padding.Parent = window.content
	
	-- Setup window functionality
	self:_setupWindowDragging(window)
	self:_setupWindowClose(window)
	self:_playWindowEntrance(window)
	
	-- Window methods
	window.setTitle = function(title)
		window.titleText.Text = title
	end
	
	window.getContent = function()
		return window.content
	end
	
	window.close = function()
		self:_closeWindow(window)
	end
	
	window.destroy = function()
		if window.frame then window.frame:Destroy() end
		if window.shadow then window.shadow:Destroy() end
		if window.glow then window.glow:Destroy() end
	end
	
	table.insert(self.components, window)
	return window
end

-- Button Component
function TreeUI:createButton(parent, config)
	config = config or {}
	
	local button = {
		frame = nil,
		originalColor = nil
	}
	
	-- Create button frame
	button.frame = Instance.new("TextButton")
	button.frame.Name = config.name or "TreeUIButton"
	button.frame.Size = config.size or UDim2.new(0, 120, 0, 40)
	button.frame.Position = config.position or UDim2.new(0, 0, 0, 0)
	button.frame.BackgroundColor3 = config.color or Theme.colors.primary
	button.frame.BorderSizePixel = 0
	button.frame.Text = config.text or "Button"
	button.frame.TextColor3 = config.textColor or Theme.colors.background
	button.frame.TextSize = config.textSize or 14
	button.frame.Font = Theme.fonts.secondary
	button.frame.Parent = parent
	
	button.originalColor = button.frame.BackgroundColor3
	
	-- Add corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Theme.sizes.borderRadius)
	corner.Parent = button.frame
	
	-- Add glow effect
	local glow = Instance.new("Frame")
	glow.Name = "ButtonGlow"
	glow.Size = UDim2.new(1, 6, 1, 6)
	glow.Position = UDim2.new(0, -3, 0, -3)
	glow.BackgroundColor3 = button.originalColor
	glow.BackgroundTransparency = 1
	glow.BorderSizePixel = 0
	glow.ZIndex = button.frame.ZIndex - 1
	glow.Parent = parent
	
	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(0, Theme.sizes.borderRadius + 3)
	glowCorner.Parent = glow
	
	-- Setup button interactions
	button.frame.MouseEnter:Connect(function()
		local hoverColor = Color3.fromRGB(
			math.min(255, button.originalColor.R * 255 + 30),
			math.min(255, button.originalColor.G * 255 + 30),
			math.min(255, button.originalColor.B * 255 + 30)
		)
		
		local hoverTween = TweenService:Create(button.frame,
			TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = hoverColor}
		)
		
		local glowTween = TweenService:Create(glow,
			TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundTransparency = 0.8}
		)
		
		hoverTween:Play()
		glowTween:Play()
	end)
	
	button.frame.MouseLeave:Connect(function()
		local leaveTween = TweenService:Create(button.frame,
			TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = button.originalColor}
		)
		
		local glowTween = TweenService:Create(glow,
			TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundTransparency = 1}
		)
		
		leaveTween:Play()
		glowTween:Play()
	end)
	
	button.frame.MouseButton1Down:Connect(function()
		local clickTween = TweenService:Create(button.frame,
			TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = UDim2.new(button.frame.Size.X.Scale, button.frame.Size.X.Offset - 4, button.frame.Size.Y.Scale, button.frame.Size.Y.Offset - 4)}
		)
		clickTween:Play()
	end)
	
	button.frame.MouseButton1Up:Connect(function()
		local releaseTween = TweenService:Create(button.frame,
			TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{Size = config.size or UDim2.new(0, 120, 0, 40)}
		)
		releaseTween:Play()
	end)
	
	button.frame.Activated:Connect(function()
		if config.onClick then
			config.onClick(button)
		end
	end)
	
	-- Button methods
	button.setText = function(text)
		button.frame.Text = text
	end
	
	button.setColor = function(color)
		button.originalColor = color
		button.frame.BackgroundColor3 = color
		glow.BackgroundColor3 = color
	end
	
	button.setEnabled = function(enabled)
		button.frame.Active = enabled
		button.frame.BackgroundTransparency = enabled and 0 or 0.5
		button.frame.TextTransparency = enabled and 0 or 0.5
	end
	
	button.destroy = function()
		if button.frame then button.frame:Destroy() end
		if glow then glow:Destroy() end
	end
	
	return button
end

-- Text Component
function TreeUI:createText(parent, config)
	config = config or {}
	
	local text = {
		label = nil
	}
	
	text.label = Instance.new("TextLabel")
	text.label.Name = config.name or "TreeUIText"
	text.label.Size = config.size or UDim2.new(1, 0, 0, 30)
	text.label.Position = config.position or UDim2.new(0, 0, 0, 0)
	text.label.BackgroundTransparency = 1
	text.label.Text = config.text or "Text"
	text.label.TextColor3 = config.color or Theme.colors.text
	text.label.TextSize = config.textSize or 14
	text.label.Font = config.font or Theme.fonts.primary
	text.label.TextXAlignment = config.alignX or Enum.TextXAlignment.Left
	text.label.TextYAlignment = config.alignY or Enum.TextYAlignment.Center
	text.label.TextWrapped = config.wrapped or false
	text.label.Parent = parent
	
	-- Text methods
	text.setText = function(newText)
		text.label.Text = newText
	end
	
	text.setColor = function(color)
		text.label.TextColor3 = color
	end
	
	text.destroy = function()
		if text.label then text.label:Destroy() end
	end
	
	return text
end

-- Frame Component
function TreeUI:createFrame(parent, config)
	config = config or {}
	
	local frame = {
		frame = nil
	}
	
	frame.frame = Instance.new("Frame")
	frame.frame.Name = config.name or "TreeUIFrame"
	frame.frame.Size = config.size or UDim2.new(1, 0, 0, 100)
	frame.frame.Position = config.position or UDim2.new(0, 0, 0, 0)
	frame.frame.BackgroundColor3 = config.color or Theme.colors.surface
	frame.frame.BorderSizePixel = 0
	frame.frame.Parent = parent
	
	-- Add corner radius
	if config.cornerRadius ~= false then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, config.cornerRadius or Theme.sizes.borderRadius)
		corner.Parent = frame.frame
	end
	
	-- Add border if specified
	if config.border then
		local stroke = Instance.new("UIStroke")
		stroke.Color = config.borderColor or Theme.colors.border
		stroke.Thickness = config.borderThickness or 1
		stroke.Parent = frame.frame
	end
	
	-- Add padding
	if config.padding then
		local padding = Instance.new("UIPadding")
		local paddingValue = config.padding
		if type(paddingValue) == "number" then
			padding.PaddingTop = UDim.new(0, paddingValue)
			padding.PaddingBottom = UDim.new(0, paddingValue)
			padding.PaddingLeft = UDim.new(0, paddingValue)
			padding.PaddingRight = UDim.new(0, paddingValue)
		end
		padding.Parent = frame.frame
	end
	
	-- Frame methods
	frame.setColor = function(color)
		frame.frame.BackgroundColor3 = color
	end
	
	frame.getFrame = function()
		return frame.frame
	end
	
	frame.destroy = function()
		if frame.frame then frame.frame:Destroy() end
	end
	
	return frame
end

-- Input Component
function TreeUI:createInput(parent, config)
	config = config or {}
	
	local input = {
		container = nil,
		textBox = nil,
		stroke = nil
	}
	
	-- Create container
	input.container = Instance.new("Frame")
	input.container.Name = config.name or "TreeUIInput"
	input.container.Size = config.size or UDim2.new(1, 0, 0, 40)
	input.container.Position = config.position or UDim2.new(0, 0, 0, 0)
	input.container.BackgroundTransparency = 1
	input.container.Parent = parent
	
	-- Create input field
	input.textBox = Instance.new("TextBox")
	input.textBox.Size = UDim2.new(1, 0, 1, 0)
	input.textBox.Position = UDim2.new(0, 0, 0, 0)
	input.textBox.BackgroundColor3 = Theme.colors.background
	input.textBox.BorderSizePixel = 0
	input.textBox.Text = config.defaultText or ""
	input.textBox.PlaceholderText = config.placeholder or "Enter text..."
	input.textBox.TextColor3 = Theme.colors.text
	input.textBox.PlaceholderColor3 = Theme.colors.textSecondary
	input.textBox.TextSize = config.textSize or 14
	input.textBox.Font = Theme.fonts.primary
	input.textBox.TextXAlignment = Enum.TextXAlignment.Left
	input.textBox.ClearTextOnFocus = false
	input.textBox.Parent = input.container
	
	-- Add corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Theme.sizes.borderRadius)
	corner.Parent = input.textBox
	
	-- Add border
	input.stroke = Instance.new("UIStroke")
	input.stroke.Color = Theme.colors.border
	input.stroke.Thickness = 1
	input.stroke.Parent = input.textBox
	
	-- Add padding
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, Theme.sizes.padding.small)
	padding.PaddingRight = UDim.new(0, Theme.sizes.padding.small)
	padding.Parent = input.textBox
	
	-- Setup interactions
	input.textBox.Focused:Connect(function()
		local focusTween = TweenService:Create(input.stroke,
			TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Color = Theme.colors.primary, Thickness = 2}
		)
		focusTween:Play()
	end)
	
	input.textBox.FocusLost:Connect(function()
		local blurTween = TweenService:Create(input.stroke,
			TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Color = Theme.colors.border, Thickness = 1}
		)
		blurTween:Play()
		
		if config.onChanged then
			config.onChanged(input.textBox.Text, input)
		end
	end)
	
	-- Input methods
	input.getText = function()
		return input.textBox.Text
	end
	
	input.setText = function(text)
		input.textBox.Text = text
	end
	
	input.destroy = function()
		if input.container then input.container:Destroy() end
	end
	
	return input
end

-- Checkbox Component
function TreeUI:createCheckbox(parent, config)
	config = config or {}
	
	local checkbox = {
		container = nil,
		checkboxFrame = nil,
		checkmark = nil,
		label = nil,
		stroke = nil,
		checked = config.checked or false
	}
	
	-- Create container
	checkbox.container = Instance.new("Frame")
	checkbox.container.Name = config.name or "TreeUICheckbox"
	checkbox.container.Size = config.size or UDim2.new(1, 0, 0, 30)
	checkbox.container.Position = config.position or UDim2.new(0, 0, 0, 0)
	checkbox.container.BackgroundTransparency = 1
	checkbox.container.Parent = parent
	
	-- Create checkbox button
	checkbox.checkboxFrame = Instance.new("TextButton")
	checkbox.checkboxFrame.Size = UDim2.new(0, 20, 0, 20)
	checkbox.checkboxFrame.Position = UDim2.new(0, 0, 0.5, -10)
	checkbox.checkboxFrame.BackgroundColor3 = Theme.colors.background
	checkbox.checkboxFrame.BorderSizePixel = 0
	checkbox.checkboxFrame.Text = ""
	checkbox.checkboxFrame.Parent = checkbox.container
	
	-- Add corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = checkbox.checkboxFrame
	
	-- Add border
	checkbox.stroke = Instance.new("UIStroke")
	checkbox.stroke.Color = Theme.colors.border
	checkbox.stroke.Thickness = 2
	checkbox.stroke.Parent = checkbox.checkboxFrame
	
	-- Create checkmark
	checkbox.checkmark = Instance.new("TextLabel")
	checkbox.checkmark.Size = UDim2.new(1, 0, 1, 0)
	checkbox.checkmark.BackgroundTransparency = 1
	checkbox.checkmark.Text = "✓"
	checkbox.checkmark.TextColor3 = Theme.colors.background
	checkbox.checkmark.TextSize = 14
	checkbox.checkmark.Font = Theme.fonts.bold
	checkbox.checkmark.TextTransparency = 1
	checkbox.checkmark.Parent = checkbox.checkboxFrame
	
	-- Create label
	if config.label then
		checkbox.label = Instance.new("TextLabel")
		checkbox.label.Size = UDim2.new(1, -30, 1, 0)
		checkbox.label.Position = UDim2.new(0, 30, 0, 0)
		checkbox.label.BackgroundTransparency = 1
		checkbox.label.Text = config.label
		checkbox.label.TextColor3 = Theme.colors.text
		checkbox.label.TextSize = 14
		checkbox.label.Font = Theme.fonts.primary
		checkbox.label.TextXAlignment = Enum.TextXAlignment.Left
		checkbox.label.Parent = checkbox.container
	end
	
	-- Setup interactions
	checkbox.checkboxFrame.Activated:Connect(function()
		checkbox.checked = not checkbox.checked
		
		if checkbox.checked then
			-- Animate to checked state
			local bgTween = TweenService:Create(checkbox.checkboxFrame,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundColor3 = Theme.colors.primary}
			)
			
			local strokeTween = TweenService:Create(checkbox.stroke,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Color = Theme.colors.primary}
			)
			
			local checkTween = TweenService:Create(checkbox.checkmark,
				TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{TextTransparency = 0}
			)
			
			bgTween:Play()
			strokeTween:Play()
			checkTween:Play()
		else
			-- Animate to unchecked state
			local bgTween = TweenService:Create(checkbox.checkboxFrame,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundColor3 = Theme.colors.background}
			)
			
			local strokeTween = TweenService:Create(checkbox.stroke,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Color = Theme.colors.border}
			)
			
			local checkTween = TweenService:Create(checkbox.checkmark,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{TextTransparency = 1}
			)
			
			bgTween:Play()
			strokeTween:Play()
			checkTween:Play()
		end
		
		if config.onChanged then
			config.onChanged(checkbox.checked, checkbox)
		end
	end)
	
	-- Checkbox methods
	checkbox.setChecked = function(checked)
		checkbox.checked = checked
		-- Trigger the visual update
		checkbox.checkboxFrame.Activated:Fire()
	end
	
	checkbox.isChecked = function()
		return checkbox.checked
	end
	
	checkbox.destroy = function()
		if checkbox.container then checkbox.container:Destroy() end
	end
	
	-- Set initial state
	if checkbox.checked then
		checkbox.checkboxFrame.BackgroundColor3 = Theme.colors.primary
		checkbox.stroke.Color = Theme.colors.primary
		checkbox.checkmark.TextTransparency = 0
	end
	
	return checkbox
end

-- Slider Component
function TreeUI:createSlider(parent, config)
	config = config or {}
	
	local slider = {
		container = nil,
		track = nil,
		fill = nil,
		handle = nil,
		min = config.min or 0,
		max = config.max or 100,
		value = config.value or 0,
		step = config.step or 1
	}
	
	-- Create container
	slider.container = Instance.new("Frame")
	slider.container.Name = config.name or "TreeUISlider"
	slider.container.Size = config.size or UDim2.new(1, 0, 0, 40)
	slider.container.Position = config.position or UDim2.new(0, 0, 0, 0)
	slider.container.BackgroundTransparency = 1
	slider.container.Parent = parent
	
	-- Create track
	slider.track = Instance.new("Frame")
	slider.track.Size = UDim2.new(1, 0, 0, 6)
	slider.track.Position = UDim2.new(0, 0, 0.5, -3)
	slider.track.BackgroundColor3 = Theme.colors.border
	slider.track.BorderSizePixel = 0
	slider.track.Parent = slider.container
	
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 3)
	trackCorner.Parent = slider.track
	
	-- Create fill
	slider.fill = Instance.new("Frame")
	slider.fill.Size = UDim2.new(0, 0, 1, 0)
	slider.fill.Position = UDim2.new(0, 0, 0, 0)
	slider.fill.BackgroundColor3 = Theme.colors.primary
	slider.fill.BorderSizePixel = 0
	slider.fill.Parent = slider.track
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 3)
	fillCorner.Parent = slider.fill
	
	-- Create handle
	slider.handle = Instance.new("TextButton")
	slider.handle.Size = UDim2.new(0, 20, 0, 20)
	slider.handle.Position = UDim2.new(0, -10, 0.5, -10)
	slider.handle.BackgroundColor3 = Theme.colors.primary
	slider.handle.BorderSizePixel = 0
	slider.handle.Text = ""
	slider.handle.Parent = slider.container
	
	local handleCorner = Instance.new("UICorner")
	handleCorner.CornerRadius = UDim.new(0.5, 0)
	handleCorner.Parent = slider.handle
	
	-- Add handle glow
	local handleGlow = Utils.createGlow(slider.handle, Theme.colors.primary, 0.5)
	handleGlow.BackgroundTransparency = 1
	
	-- Setup interactions
	local dragging = false
	
	slider.handle.MouseEnter:Connect(function()
		local hoverTween = TweenService:Create(slider.handle,
			TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = UDim2.new(0, 24, 0, 24)}
		)
		local glowTween = TweenService:Create(handleGlow,
			TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundTransparency = 0.6}
		)
		hoverTween:Play()
		glowTween:Play()
	end)
	
	slider.handle.MouseLeave:Connect(function()
		if not dragging then
			local leaveTween = TweenService:Create(slider.handle,
				TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = UDim2.new(0, 20, 0, 20)}
			)
			local glowTween = TweenService:Create(handleGlow,
				TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundTransparency = 1}
			)
			leaveTween:Play()
			glowTween:Play()
		end
	end)
	
	slider.handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local trackPos = slider.track.AbsolutePosition.X
			local trackSize = slider.track.AbsoluteSize.X
			local relativeX = Utils.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
			
			local newValue = slider.min + (slider.max - slider.min) * relativeX
			newValue = math.floor(newValue / slider.step + 0.5) * slider.step
			
			slider.value = newValue
			local percentage = (newValue - slider.min) / (slider.max - slider.min)
			
			slider.handle.Position = UDim2.new(percentage, -10, 0.5, -10)
			slider.fill.Size = UDim2.new(percentage, 0, 1, 0)
			
			if config.onChanged then
				config.onChanged(newValue, slider)
			end
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	-- Slider methods
	slider.setValue = function(value)
		value = Utils.clamp(value, slider.min, slider.max)
		slider.value = value
		
		local percentage = (value - slider.min) / (slider.max - slider.min)
		slider.handle.Position = UDim2.new(percentage, -10, 0.5, -10)
		slider.fill.Size = UDim2.new(percentage, 0, 1, 0)
		
		if config.onChanged then
			config.onChanged(value, slider)
		end
	end
	
	slider.getValue = function()
		return slider.value
	end
	
	slider.destroy = function()
		if slider.container then slider.container:Destroy() end
		if handleGlow then handleGlow:Destroy() end
	end
	
	-- Set initial value
	slider:setValue(slider.value)
	
	return slider
end

-- Notification system
function TreeUI:notify(message, duration, notificationType)
	duration = duration or 3
	notificationType = notificationType or "info"
	
	local colors = {
		info = Theme.colors.primary,
		success = Theme.colors.success,
		warning = Theme.colors.warning,
		error = Theme.colors.error
	}
	
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(0, 300, 0, 60)
	notification.Position = UDim2.new(1, -320, 0, 20 + (#self.notifications * 70))
	notification.BackgroundColor3 = colors[notificationType] or colors.info
	notification.BorderSizePixel = 0
	notification.Parent = self.screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Theme.sizes.borderRadius)
	corner.Parent = notification
	
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Size = UDim2.new(1, -20, 1, 0)
	messageLabel.Position = UDim2.new(0, 10, 0, 0)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = message
	messageLabel.TextColor3 = Theme.colors.background
	messageLabel.TextSize = 14
	messageLabel.Font = Theme.fonts.secondary
	messageLabel.TextWrapped = true
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.Parent = notification
	
	table.insert(self.notifications, notification)
	
	-- Slide in animation
	notification.Position = UDim2.new(1, 20, 0, 20 + ((#self.notifications - 1) * 70))
	local slideIn = TweenService:Create(notification,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(1, -320, 0, 20 + ((#self.notifications - 1) * 70))}
	)
	slideIn:Play()
	
	-- Auto dismiss
	game:GetService("Debris"):AddItem(notification, duration)
	
	spawn(function()
		wait(duration - 0.3)
		local slideOut = TweenService:Create(notification,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{Position = UDim2.new(1, 20, 0, 20 + ((#self.notifications - 1) * 70))}
		)
		slideOut:Play()
		
		-- Remove from notifications list
		for i, notif in ipairs(self.notifications) do
			if notif == notification then
				table.remove(self.notifications, i)
				break
			end
		end
	end)
end

-- Animation functions
function TreeUI:fadeIn(object, duration)
	duration = duration or Theme.animations.normal
	
	object.BackgroundTransparency = 1
	if object:IsA("TextLabel") or object:IsA("TextButton") then
		object.TextTransparency = 1
	end
	
	local targets = {BackgroundTransparency = 0}
	if object:IsA("TextLabel") or object:IsA("TextButton") then
		targets.TextTransparency = 0
	end
	
	local tween = TweenService:Create(object,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		targets
	)
	tween:Play()
	return tween
end

function TreeUI:bounce(object, intensity)
	intensity = intensity or 1.2
	local originalSize = object.Size
	
	local scaleUp = TweenService:Create(object,
		TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = UDim2.new(originalSize.X.Scale * intensity, originalSize.X.Offset * intensity,
						  originalSize.Y.Scale * intensity, originalSize.Y.Offset * intensity)}
	)
	
	scaleUp:Play()
	scaleUp.Completed:Connect(function()
		local scaleDown = TweenService:Create(object,
			TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
			{Size = originalSize}
		)
		scaleDown:Play()
	end)
end

-- Private helper functions
function TreeUI:_setupWindowDragging(window)
	local dragging = false
	local dragStart = nil
	local startPos = nil
	
	window.titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = window.frame.Position
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			window.frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
			
			-- Update shadow and glow positions
			if window.shadow then
				window.shadow.Position = UDim2.new(
					window.frame.Position.X.Scale,
					window.frame.Position.X.Offset + Theme.sizes.shadowOffset.X,
					window.frame.Position.Y.Scale,
					window.frame.Position.Y.Offset + Theme.sizes.shadowOffset.Y
				)
			end
			
			if window.glow then
				window.glow.Position = UDim2.new(
					window.frame.Position.X.Scale,
					window.frame.Position.X.Offset - 3,
					window.frame.Position.Y.Scale,
					window.frame.Position.Y.Offset - 3
				)
			end
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

function TreeUI:_setupWindowClose(window)
	-- Hover effects for close button
	window.closeButton.MouseEnter:Connect(function()
		local hoverTween = TweenService:Create(window.closeButton,
			TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundTransparency = 0.2}
		)
		hoverTween:Play()
	end)
	
	window.closeButton.MouseLeave:Connect(function()
		local leaveTween = TweenService:Create(window.closeButton,
			TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundTransparency = 0.8}
		)
		leaveTween:Play()
	end)
	
	-- Close functionality
	window.closeButton.Activated:Connect(function()
		self:_closeWindow(window)
	end)
end

function TreeUI:_playWindowEntrance(window)
	-- Start with small scale and fade
	window.frame.Size = UDim2.new(0, 0, 0, 0)
	window.frame.BackgroundTransparency = 1
	window.shadow.BackgroundTransparency = 1
	
	if window.glow then
		window.glow.BackgroundTransparency = 1
	end
	
	-- Animate to full size
	local sizeTween = TweenService:Create(window.frame,
		TweenInfo.new(Theme.animations.normal, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = window.frame.Size, BackgroundTransparency = 0}
	)
	
	local shadowTween = TweenService:Create(window.shadow,
		TweenInfo.new(Theme.animations.normal, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0.7}
	)
	
	sizeTween:Play()
	shadowTween:Play()
	
	if window.glow then
		wait(0.1)
		local glowTween = TweenService:Create(window.glow,
			TweenInfo.new(Theme.animations.slow, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundTransparency = 0.8}
		)
		glowTween:Play()
	end
end

function TreeUI:_closeWindow(window)
	local closeTween = TweenService:Create(window.frame,
		TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}
	)
	
	if window.shadow then
		local shadowTween = TweenService:Create(window.shadow,
			TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{BackgroundTransparency = 1}
		)
		shadowTween:Play()
	end
	
	if window.glow then
		local glowTween = TweenService:Create(window.glow,
			TweenInfo.new(Theme.animations.fast, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{BackgroundTransparency = 1}
		)
		glowTween:Play()
	end
	
	closeTween:Play()
	closeTween.Completed:Connect(function()
		window:destroy()
	end)
end

-- Destroy the library and clean up
function TreeUI:destroy()
	if self.screenGui then
		self.screenGui:Destroy()
	end
	
	for _, component in ipairs(self.components) do
		if component.destroy then
			component:destroy()
		end
	end
	
	self.components = {}
	self.notifications = {}
end

return TreeUI
