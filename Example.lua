--[[
	TreeUI Example
	Demonstrates how to use the TreeUI library
]]

local TreeUI = require(script.TreeUI) -- Adjust path as needed

-- Initialize TreeUI
local gui = TreeUI.new()

-- Create main window
local window = gui:createWindow({
	title = "TreeUI Demo",
	size = UDim2.new(0, 500, 0, 400),
	position = UDim2.new(0.5, -250, 0.5, -200)
})

local content = window:getContent()

-- Add title
local title = gui:createText(content, {
	text = "Welcome to TreeUI!",
	textSize = 20,
	font = Enum.Font.GothamBold,
	size = UDim2.new(1, 0, 0, 30),
	alignX = Enum.TextXAlignment.Center,
	color = Color3.fromRGB(0, 255, 255) -- Cyan
})

-- Add subtitle
local subtitle = gui:createText(content, {
	text = "A modern GUI library for Roblox",
	textSize = 14,
	position = UDim2.new(0, 0, 0, 35),
	size = UDim2.new(1, 0, 0, 20),
	alignX = Enum.TextXAlignment.Center,
	color = Color3.fromRGB(180, 180, 180)
})

-- Add interactive button
local button = gui:createButton(content, {
	text = "Click for Magic! ✨",
	size = UDim2.new(0, 200, 0, 40),
	position = UDim2.new(0.5, -100, 0, 70),
	onClick = function(btn)
		gui:notify("TreeUI is awesome! 🚀", 3, "success")
		gui:bounce(btn.frame)
	end
})

-- Add input field
local input = gui:createInput(content, {
	placeholder = "Enter your name...",
	size = UDim2.new(1, 0, 0, 40),
	position = UDim2.new(0, 0, 0, 130),
	onChanged = function(text, inputField)
		if text ~= "" then
			button:setText("Hello, " .. text .. "! 👋")
		else
			button:setText("Click for Magic! ✨")
		end
	end
})

-- Add settings frame
local settingsFrame = gui:createFrame(content, {
	name = "Settings",
	size = UDim2.new(1, 0, 0, 120),
	position = UDim2.new(0, 0, 0, 190),
	border = true,
	borderColor = Color3.fromRGB(0, 255, 255),
	padding = 16
})

-- Settings title
gui:createText(settingsFrame:getFrame(), {
	text = "Settings",
	textSize = 16,
	font = Enum.Font.GothamBold,
	size = UDim2.new(1, 0, 0, 25),
	color = Color3.fromRGB(0, 255, 255)
})

-- Volume slider
gui:createText(settingsFrame:getFrame(), {
	text = "Volume: 75%",
	position = UDim2.new(0, 0, 0, 30),
	size = UDim2.new(1, 0, 0, 20)
})

local volumeSlider = gui:createSlider(settingsFrame:getFrame(), {
	position = UDim2.new(0, 0, 0, 55),
	size = UDim2.new(1, 0, 0, 25),
	min = 0,
	max = 100,
	value = 75,
	onChanged = function(value)
		-- Update volume text
		for _, child in pairs(settingsFrame:getFrame():GetChildren()) do
			if child:IsA("TextLabel") and child.Text:find("Volume:") then
				child.Text = "Volume: " .. math.floor(value) .. "%"
				break
			end
		end
	end
})

-- Enable notifications checkbox
local notificationsCheckbox = gui:createCheckbox(settingsFrame:getFrame(), {
	label = "Enable notifications",
	position = UDim2.new(0, 0, 0, 85),
	checked = true,
	onChanged = function(checked)
		local message = checked and "Notifications enabled" or "Notifications disabled"
		gui:notify(message, 2, checked and "success" or "warning")
	end
})

-- Add some style with a cool animation
spawn(function()
	wait(1)
	for i = 1, 3 do
		gui:bounce(title.label, 1.1)
		wait(0.5)
	end
end)

print("TreeUI Demo loaded successfully!")
