# ❄ WinterCatLib

A lightweight UI library for Roblox executors. No bloat, no weird dependencies, just a clean window with tabs and a bunch of controls.

I built this because I got tired of rewriting the same GUI code over and over. It's not trying to be the next big thing — it just works.

Note: This is a .luau script meant for executor environments (Synapse, ScriptWare, etc.). It won't run in a normal Roblox game without an executor.

---

# What's in the box

· Window — draggable, minimizable, close button
· Tabs — organize your stuff
· Buttons — click and do something
· Toggles — on/off switches
· Sliders — pick a number between min and max
· Dropdowns — pick one option from a list
· KeyPickers — bind a key with Toggle or Hold mode
· ColorPickers — RGB sliders plus a hex input box
· TextBoxes — text input fields
· Notifications — toast-style popups
· Theming — dark palette by default, override any color
· Config save/load — serialize and deserialize Color3 and EnumItem

No frameworks, no external assets.

---

# Quick start

Paste this into your executor:

local WinterCatLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/telecomcom614/WinterCatLib/refs/heads/main/WinterCatLib.luau"))()

local Window = WinterCatLib:CreateWindow({
Title = "My Script",
Size = UDim2.fromOffset(600, 420),
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

# API

# WinterCatLib:Notify(config)

Shows a notification toast in the bottom-right corner. It slides in, waits for the duration, then slides out and destroys itself.

config keys:

· Title — string, default "WinterCatLib"
· Content — string, default ""
· Duration — number, default 5

Example:

WinterCatLib:Notify({
Title = "Done",
Content = "Script loaded successfully",
Duration = 5
})

---

# WinterCatLib:CreateWindow(config)

Creates the main window. Returns a Window object.

config keys:

· Title — string, default "WinterCatLib"
· Size — UDim2, default UDim2.fromOffset(600, 420)
· ToggleKey — KeyCode, default Enum.KeyCode.RightShift

The window is draggable by its top bar. The minimize button shrinks the window to just the top bar. The close button disables the GUI. The ToggleKey minimizes/restores the window.

Example:

local Window = WinterCatLib:CreateWindow({
Title = "WinterCat Example",
Size = UDim2.fromOffset(640, 420),
ToggleKey = Enum.KeyCode.RightShift
})

---

# Window:CreateTab(config)

Adds a tab to the left sidebar. Returns a Tab object.

config keys:

· Name — string, default "Tab"

Only one tab is visible at a time. The first tab you create is automatically activated.

Example:

local Tab = Window:CreateTab({ Name = "Settings" })

---

Tab:AddButton(config)

A clickable button.

config keys:

· Name — string, default "Button"
· Callback — function

Example:

Tab:AddButton({
Name = "Do the thing",
Callback = function()
print("Clicked")
end
})

---

# Tab:AddToggle(config)

An on/off switch. The callback receives the new boolean value.

config keys:

· Name — string, default "Toggle"
· Default — boolean, default false
· Callback — function(state)

Returns an element table with:

· Get() — returns current state
· Set(value, silent) — sets state, triggers callback unless silent is true

Example:

local toggle = Tab:AddToggle({
Name = "Auto-farm",
Default = false,
Callback = function(state)
print("Auto-farm:", state)
end
})

toggle:Set(true)
print(toggle:Get())

---

# Tab:AddSlider(config)

A horizontal slider. Callback fires every time the value changes.

config keys:

· Name — string, default "Slider"
· Min — number, default 0
· Max — number, default 100
· Default — number, default Min
· Callback — function(value)

Values are clamped between Min and Max. The number display floors to the nearest integer.

Returns an element table with:

· Get() — returns current value
· Set(value, silent) — sets value, triggers callback unless silent is true

Example:

local slider = Tab:AddSlider({
Name = "Volume",
Min = 0,
Max = 100,
Default = 75,
Callback = function(value)
print("Volume:", value)
end
})

slider:Set(30)
print(slider:Get())

---

# Tab:AddDropdown(config)

A dropdown list. Click the button to open a list of options, click an option to select it.

config keys:

· Name — string, default "Dropdown"
· Options — table, default {}
· Default — any, default Options[1]
· Callback — function(selectedOption)

Returns an element table with:

· Get() — returns current value
· Set(value, silent) — sets value, triggers callback unless silent is true
· UpdateOptions(newOptions) — replaces the options list and rebuilds the list

Example:

local dropdown = Tab:AddDropdown({
Name = "Mode",
Options = {"Fast", "Balanced", "Safe"},
Default = "Balanced",
Callback = function(option)
print("Selected:", option)
end
})

dropdown:UpdateOptions({"Normal", "Hard"})

---

# Tab:AddKeyPicker(config)

A keybind picker. Click the button, then press a key to bind it. The button shows the current key and mode.

config keys:

· Name — string, default "Keybind"
· Default — KeyCode, default Enum.KeyCode.E
· Mode — string, default "Toggle" (can be "Toggle" or "Hold")
· Callback — function

Returns an element table with:

· Get() — returns the current KeyCode
· GetMode() — returns the current mode string
· Set(key, silent) — sets the key
· SetMode(mode) — sets the mode

Example:

local key = Tab:AddKeyPicker({
Name = "Aimbot",
Default = Enum.KeyCode.Q,
Mode = "Toggle",
Callback = function()
print("Key pressed")
end
})

---

# Tab:AddColorPicker(config)

An RGB color picker with three sliders (R, G, B) and a hex input box.

config keys:

· Name — string, default "Color"
· Default — Color3, default Color3.fromRGB(255, 255, 255)
· Callback — function(color)

Click the swatch to open/close the picker. The frame resizes when the picker opens.

Returns an element table with:

· Get() — returns current Color3
· Set(color, silent) — sets the color, triggers callback unless silent is true

Example:

local color = Tab:AddColorPicker({
Name = "ESP Color",
Default = Color3.fromRGB(255, 0, 0),
Callback = function(c)
print("Color:", c)
end
})

---

# Tab:AddTextBox(config)

A text input field.

config keys:

· Name — string, default "TextBox"
· Default — string, default ""
· Placeholder — string, default ""
· MaxLength — number, default 50
· Callback — function(text)

Note: this function is defined in the source but the implementation appears to be incomplete in the current version.

---

# Theming

Default theme:

{
Background = Color3.fromRGB(18, 18, 24),
SecondaryBackground = Color3.fromRGB(26, 26, 34),
TertiaryBackground = Color3.fromRGB(36, 36, 46),
Accent = Color3.fromRGB(130, 170, 255),
Text = Color3.fromRGB(240, 240, 245),
TextDim = Color3.fromRGB(150, 150, 165),
Outline = Color3.fromRGB(46, 46, 58)
}

You can change the theme by modifying WinterCatLib.Theme directly before creating a window.

---

# Config save/load

The library includes serialize and deserialize helpers that support Color3 and EnumItem. There's also an ensureFolder function that creates a "WinterCatLib" folder using executor filesystem functions (writefile, makefolder, etc.) if they are available.

The serialize function converts Color3 to {__t = "Color3", r, g, b} and EnumItem to {__t = "EnumItem", enum, name}. The deserialize function reverses this.

Example:

local data = WinterCatLib.serialize({Color = Color3.fromRGB(255, 0, 0)})
local restored = WinterCatLib.deserialize(data)

Note: the save/load system is partially implemented — the serialize and deserialize functions exist but are not wired to any public save/load methods yet.

---

# Full example

local WinterCatLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/telecomcom614/WinterCatLib/refs/heads/main/WinterCatLib.luau"))()

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
WinterCatLib:Notify({
Title = "Hello",
Content = "Hello from WinterCatLib",
Duration = 3
})
end
})

Main:AddToggle({
Name = "Infinite jump",
Default = false,
Callback = function(state)
print("Infinite jump:", state)
end
})

Main:AddSlider({
Name = "WalkSpeed",
Min = 16,
Max = 200,
Default = 16,
Callback = function(value)
if game.Players.LocalPlayer.Character then
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end
end
})

Main:AddDropdown({
Name = "Speed mode",
Options = {"Normal", "Fast", "Insane"},
Default = "Normal",
Callback = function(option)
print("Mode:", option)
end
})

Visuals:AddColorPicker({
Name = "ESP Color",
Default = Color3.fromRGB(255, 0, 0),
Callback = function(c)
print("Color:", c)
end
})

Visuals:AddKeyPicker({
Name = "Fullbright",
Default = Enum.KeyCode.F,
Mode = "Toggle",
Callback = function()
print("Fullbright toggled")
end
})

---

# Notes

· Dragging works by holding the top bar.
· ToggleKey minimizes/restores the window. Default is RightShift.
· The close button disables the GUI (gui.Enabled = false).
· If you want to reopen the window, just run the script again.
· No external assets, no HTTP requests besides loading the library itself.
· Some functions (like AddTextBox) are defined but not fully implemented in the current version.
