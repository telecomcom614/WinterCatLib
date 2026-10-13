❄ WinterCatLib

A lightweight UI library for Roblox executors. No bloat, no weird dependencies, just a clean window with tabs, buttons, toggles, and sliders.

I built this because I got tired of rewriting the same GUI code over and over. It's not trying to be the next big thing — it just works.

Note: This is a .luau script meant for executor environments (Synapse, ScriptWare, etc.). It won't run in a normal Roblox game without an executor.

---

What's in the box

· Window — draggable, minimizable, fullscreen toggle, close button
· Tabs — organize your stuff
· Buttons — click and do something
· Toggles — on/off switches
· Sliders — pick a number between min and max
· Theming — dark winter palette by default, but you can override any color

The whole thing is under 260 lines of Luau. No frameworks, no external files.

---

Quick start

Paste this into your executor:

local WinterCatLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/telecomcom614/WinterCatLib/main/WinterCatLib.luau"))()

local Window = WinterCatLib:CreateWindow({
Title = "My Script",
Size = UDim2.fromOffset(600, 400),
ToggleKey = Enum.KeyCode.RightShift
})

local MainTab = Window:CreateTab({ Name = "Main" })

MainTab:AddButton({
Name = "Click me",
Callback = function()
print("Button clicked")
end
})

MainTab:AddToggle({
Name = "Enable something",
Default = false,
Callback = function(state)
print("Toggle is now:", state)
end
})

MainTab:AddSlider({
Name = "Speed",
Min = 0,
Max = 100,
Default = 50,
Callback = function(value)
print("Slider value:", value)
end
})

That's it. You get a window, a tab, and three controls.

---

API

WinterCatLib:CreateWindow(config)

Creates the main window. Returns a Window object.

Key Type Default What it does
Title string "WintherCatLib" Text in the header
Size UDim2 UDim2.fromOffset(620, 420) Window size
Theme table {} Override any color (see below)
ToggleKey KeyCode RightShift Key to minimize/restore
OnDestroy function — Runs when window closes
OnMinimize function — Runs when minimized
OnRestore function — Runs when restored

The window is draggable by its header. Minimize, fullscreen, and close buttons are in the top-right corner. The close button actually destroys the GUI, so don't call it if you plan to reopen the window.

---

Window:CreateTab(config)

Adds a tab to the left sidebar. Returns a Tab object.

local Tab = Window:CreateTab({ Name = "Settings" })

Only one tab is active at a time. The first tab you create is automatically selected.

---

Tab:AddButton(config)

A clickable button.

Tab:AddButton({
Name = "Do the thing",
Callback = function()
-- your code here
end
})

Returns the button instance if you need to mess with it later.

---

Tab:AddToggle(config)

An on/off switch. The callback receives the new boolean value.

local toggle = Tab:AddToggle({
Name = "Auto-farm",
Default = false,
Callback = function(value)
print("Auto-farm is", value and "ON" or "OFF")
end
})

-- You can also set/get the value programmatically:
toggle:Set(true)   -- triggers the callback
print(toggle:Get()) -- true

The knob animates. It's not fancy, but it looks fine.

---

Tab:AddSlider(config)

A horizontal slider. Callback fires every time the value changes.

local slider = Tab:AddSlider({
Name = "Volume",
Min = 0,
Max = 100,
Default = 75,
Callback = function(value)
print("Volume:", value)
end
})

slider:Set(30)      -- triggers callback
print(slider:Get()) -- 30

Values are clamped between Min and Max. The number display floors to two decimal places.

---

Window methods

Method What it does
Window:Destroy() Closes and removes the GUI
Window:Minimize() Minimizes the window
Window:Restore() Restores from minimized
Window:ToggleMinimize() Flips minimize state
Window:IsMinimized() Returns boolean
Window:Fullscreen() Goes fullscreen
Window:Unfullscreen() Exits fullscreen
Window:ToggleFullscreen() Flips fullscreen
Window:IsFullscreen() Returns boolean
Window:SetColor(key, color) Changes one theme color
Window:GetTheme() Returns current theme table

---

Theming

Default theme is a dark blue/winter palette:

{
Background = Color3.fromRGB(15, 22, 35),
SecondaryBackground = Color3.fromRGB(22, 32, 50),
TertiaryBackground = Color3.fromRGB(30, 42, 65),
Accent = Color3.fromRGB(120, 190, 255),
AccentDark = Color3.fromRGB(70, 140, 210),
AccentLight = Color3.fromRGB(180, 220, 255),
Text = Color3.fromRGB(235, 245, 255),
TextDim = Color3.fromRGB(160, 180, 200),
TextMuted = Color3.fromRGB(100, 120, 145),
Stroke = Color3.fromRGB(60, 90, 130),
Divider = Color3.fromRGB(45, 65, 95)
}

Change individual colors after creating the window:

Window:SetColor("Accent", Color3.fromRGB(255, 100, 100))

Or pass a theme table in the config:

local Window = WinterCatLib:CreateWindow({
Title = "My Script",
Theme = {
Accent = Color3.fromRGB(255, 100, 100),
Background = Color3.fromRGB(10, 10, 10)
}
})

Any key you don't override falls back to the default.

---

Full example

local WinterCatLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/telecomcom614/WinterCatLib/main/WinterCatLib.luau"))()

local Window = WinterCatLib:CreateWindow({
Title = "WinterCat Example",
Size = UDim2.fromOffset(640, 420),
ToggleKey = Enum.KeyCode.RightShift
})

local Main = Window:CreateTab({ Name = "Main" })
local Visuals = Window:CreateTab({ Name = "Visuals" })

Main:AddButton({
Name = "Print hello",
Callback = function()
print("Hello from WinterCatLib")
end
})

Main:AddToggle({
Name = "Infinite jump",
Default = false,
Callback = function(state)
-- your logic here
print("Infinite jump:", state)
end
})

Main:AddSlider({
Name = "WalkSpeed",
Min = 16,
Max = 200,
Default = 16,
Callback = function(value)
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end
})

Visuals:AddToggle({
Name = "Fullbright",
Default = false,
Callback = function(state)
if state then
game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
else
game.Lighting.Ambient = Color3.fromRGB(70, 70, 70)
game.Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
end
end
})

Visuals:AddButton({
Name = "Reset lighting",
Callback = function()
game.Lighting.Ambient = Color3.fromRGB(70, 70, 70)
game.Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
end
})

---

Notes

· Dragging works by holding the header.
· ToggleKey minimizes/restores the window. Default is RightShift.
· The close button calls Destroy(), which removes the GUI and unbinds the toggle key.
· If you want to reopen the window, just run the script again.
· No external assets, no HTTP requests besides loading the library itself.

---

License

Do whatever you want. Credit is nice but not required.
