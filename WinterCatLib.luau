local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local writefileFn, readfileFn, isfileFn, listfilesFn, makefolderFn, isfolderFn
pcall(function() writefileFn = writefile end)
pcall(function() readfileFn = readfile end)
pcall(function() isfileFn = isfile end)
pcall(function() listfilesFn = listfiles end)
pcall(function() makefolderFn = makefolder end)
pcall(function() isfolderFn = isfolder end)

local WinterCatLib = {}
WinterCatLib.Theme = {
    Background = Color3.fromRGB(18, 18, 24),
    SecondaryBackground = Color3.fromRGB(26, 26, 34),
    TertiaryBackground = Color3.fromRGB(36, 36, 46),
    Accent = Color3.fromRGB(130, 170, 255),
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(150, 150, 165),
    Outline = Color3.fromRGB(46, 46, 58)
}

local registry = {}
local keyBindings = {}
local bindingTarget = nil
local notifyContainer = nil
local CONFIG_FOLDER = "WinterCatLib"

local function ensureFolder()
    if isfolderFn and makefolderFn and not isfolderFn(CONFIG_FOLDER) then
        makefolderFn(CONFIG_FOLDER)
    end
end

local function getGuiParent()
    local ok, parent = pcall(function() return game:GetService("CoreGui") end)
    if ok and parent then return parent end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function createNotifyGui()
    if notifyContainer and notifyContainer.Parent then return notifyContainer end
    local gui = Instance.new("ScreenGui")
    gui.Name = "WinterCatNotify"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = getGuiParent() end)
    if not gui.Parent then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    notifyContainer = gui
    return gui
end

local function serialize(v)
    if typeof(v) == "Color3" then
        return {__t = "Color3", r = v.R, g = v.G, b = v.B}
    elseif typeof(v) == "EnumItem" then
        return {__t = "EnumItem", enum = tostring(v.EnumType), name = v.Name}
    elseif type(v) == "table" then
        local o = {}
        for k, val in pairs(v) do o[k] = serialize(val) end
        return o
    end
    return v
end

local function deserialize(v)
    if type(v) == "table" then
        if v.__t == "Color3" then return Color3.new(v.r, v.g, v.b) end
        if v.__t == "EnumItem" then
            local enum = Enum[v.enum]
            if enum then return enum[v.name] end
        end
        local o = {}
        for k, val in pairs(v) do o[k] = deserialize(val) end
        return o
    end
    return v
end

function WinterCatLib:Notify(config)
    local title = config.Title or "WinterCatLib"
    local content = config.Content or ""
    local duration = config.Duration or 5
    local gui = createNotifyGui()
    local notif = Instance.new("Frame")
    notif.Size = UDim2.fromOffset(300, 80)
    notif.Position = UDim2.new(1, 320, 1, -100)
    notif.BackgroundColor3 = self.Theme.SecondaryBackground
    notif.BorderSizePixel = 0
    notif.ZIndex = 100
    notif.Parent = gui
    local c1 = Instance.new("UICorner", notif)
    c1.CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = self.Theme.Outline
    stroke.Thickness = 1
    local accent = Instance.new("Frame", notif)
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = self.Theme.Accent
    accent.BorderSizePixel = 0
    accent.ZIndex = 101
    local cornerA = Instance.new("UICorner", accent)
    cornerA.CornerRadius = UDim.new(0, 2)
    local tl = Instance.new("TextLabel", notif)
    tl.Size = UDim2.new(1, -20, 0, 22)
    tl.Position = UDim2.new(0, 12, 0, 10)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = self.Theme.Text
    tl.TextSize = 15
    tl.Font = Enum.Font.GothamBold
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 101
    local cl = Instance.new("TextLabel", notif)
    cl.Size = UDim2.new(1, -20, 0, 36)
    cl.Position = UDim2.new(0, 12, 0, 34)
    cl.BackgroundTransparency = 1
    cl.Text = content
    cl.TextColor3 = self.Theme.TextDim
    cl.TextSize = 13
    cl.Font = Enum.Font.Gotham
    cl.TextXAlignment = Enum.TextXAlignment.Left
    cl.TextWrapped = true
    cl.ZIndex = 101
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -320, 1, -100)}):Play()
    task.delay(duration, function()
        if not notif.Parent then return end
        local t = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 320, 1, -100)})
        t:Play()
        t.Completed:Connect(function() notif:Destroy() end)
    end)
end

function WinterCatLib:CreateWindow(config)
    local theme = self.Theme
    local title = config.Title or "WinterCatLib"
    local size = config.Size or UDim2.fromOffset(600, 420)
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift

    local gui = Instance.new("ScreenGui")
    gui.Name = "WinterCatLib"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = getGuiParent() end)
    if not gui.Parent then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = size
    main.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
    main.BackgroundColor3 = theme.Background
    main.BorderSizePixel = 0
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = theme.Outline
    mainStroke.Thickness = 1

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 34)
    topBar.BackgroundColor3 = theme.SecondaryBackground
    topBar.BorderSizePixel = 0
    topBar.Parent = main
    local topCorner = Instance.new("UICorner", topBar)
    topCorner.CornerRadius = UDim.new(0, 10)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -80, 1, 0)
    titleLbl.Position = UDim2.new(0, 14, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextSize = 15
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = topBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(22, 22)
    closeBtn.Position = UDim2.new(1, -30, 0, 6)
    closeBtn.BackgroundColor3 = theme.TertiaryBackground
    closeBtn.Text = "×"
    closeBtn.TextColor3 = theme.Text
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = topBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.fromOffset(22, 22)
    minBtn.Position = UDim2.new(1, -58, 0, 6)
    minBtn.BackgroundColor3 = theme.TertiaryBackground
    minBtn.Text = "−"
    minBtn.TextColor3 = theme.Text
    minBtn.TextSize = 16
    minBtn.Font = Enum.Font.GothamBold
    minBtn.BorderSizePixel = 0
    minBtn.Parent = topBar
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(0, 150, 1, -44)
    tabBar.Position = UDim2.new(0, 10, 0, 40)
    tabBar.BackgroundColor3 = theme.SecondaryBackground
    tabBar.BorderSizePixel = 0
    tabBar.Parent = main
    Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)

    local tabList = Instance.new("UIListLayout", tabBar)
    tabList.Padding = UDim.new(0, 4)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local tabPad = Instance.new("UIPadding", tabBar)
    tabPad.PaddingTop = UDim.new(0, 8)

    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -180, 1, -50)
    contentArea.Position = UDim2.new(0, 170, 0, 40)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main

    local dragging, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            main.Size = UDim2.fromOffset(size.X.Offset, 34)
        else
            main.Size = size
        end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            gui.Enabled = not gui.Enabled
        end
    end)

    local Window = {}
    Window.Gui = gui
    Window.Frame = main
    local tabs = {}
    local activeTab = nil

    function Window:CreateTab(cfg)
        local tabName = cfg.Name or "Tab"
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 30)
        btn.BackgroundColor3 = theme.TertiaryBackground
        btn.Text = tabName
        btn.TextColor3 = theme.Text
        btn.TextSize = 13
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        btn.Parent = tabBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = theme.Accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.Parent = contentArea

        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        local pad = Instance.new("UIPadding", page)
        pad.PaddingTop = UDim.new(0, 8)
        pad.PaddingLeft = UDim.new(0, 6)
        pad.PaddingRight = UDim.new(0, 6)

        local Tab = {Name = tabName, Page = page, Content = page}

        local function activate()
            for _, t in ipairs(tabs) do
                t.Page.Visible = false
                t.Button.BackgroundColor3 = theme.TertiaryBackground
            end
            page.Visible = true
            btn.BackgroundColor3 = theme.Accent
            activeTab = Tab
        end
        btn.MouseButton1Click:Connect(activate)
        Tab.Button = btn
        table.insert(tabs, Tab)
        if not activeTab then activate() end

        function Tab:AddButton(cfg)
            local frame = Instance.new("TextButton")
            frame.Size = UDim2.new(1, -8, 0, 34)
            frame.BackgroundColor3 = theme.TertiaryBackground
            frame.Text = cfg.Name or "Button"
            frame.TextColor3 = theme.Text
            frame.TextSize = 14
            frame.Font = Enum.Font.Gotham
            frame.BorderSizePixel = 0
            frame.Parent = page
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
            frame.MouseButton1Click:Connect(function()
                if cfg.Callback then cfg.Callback() end
            end)
            return frame
        end

        function Tab:AddToggle(cfg)
            local name = cfg.Name or "Toggle"
            local state = cfg.Default or false
            local cb = cfg.Callback or function() end

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -8, 0, 32)
            frame.BackgroundColor3 = theme.TertiaryBackground
            frame.BorderSizePixel = 0
            frame.Parent = page
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1, -50, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = theme.Text
            lbl.TextSize = 14
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local indicator = Instance.new("Frame", frame)
            indicator.Size = UDim2.fromOffset(36, 18)
            indicator.Position = UDim2.new(1, -46, 0.5, -9)
            indicator.BackgroundColor3 = state and theme.Accent or theme.Outline
            indicator.BorderSizePixel = 0
            Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

            local dot = Instance.new("Frame", indicator)
            dot.Size = UDim2.fromOffset(14, 14)
            dot.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dot.BorderSizePixel = 0
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            local clickBtn = Instance.new("TextButton", frame)
            clickBtn.Size = UDim2.fromScale(1, 1)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text = ""

            local element = {
                Type = "Toggle",
                Name = name,
                Tab = Tab.Name,
                Frame = frame,
                Get = function() return state end,
                Set = function(v, silent)
                    state = v
                    indicator.BackgroundColor3 = state and theme.Accent or theme.Outline
                    dot.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                    if not silent then cb(state) end
                end,
                Visible = function(fn) element.visibleFn = fn end
            }
            clickBtn.MouseButton1Click:Connect(function()
                element.Set(not state)
            end)
            table.insert(registry, element)
            return element
        end

        function Tab:AddSlider(cfg)
            local name = cfg.Name or "Slider"
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            local value = cfg.Default or min
            local cb = cfg.Callback or function() end

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -8, 0, 50)
            frame.BackgroundColor3 = theme.TertiaryBackground
            frame.BorderSizePixel = 0
            frame.Parent = page
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1, -80, 0, 20)
            lbl.Position = UDim2.new(0, 12, 0, 4)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = theme.Text
            lbl.TextSize = 13
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local valueLbl = Instance.new("TextLabel", frame)
            valueLbl.Size = UDim2.new(0, 60, 0, 20)
            valueLbl.Position = UDim2.new(1, -70, 0, 4)
            valueLbl.BackgroundTransparency = 1
            valueLbl.Text = tostring(value)
            valueLbl.TextColor3 = theme.TextDim
            valueLbl.TextSize = 13
            valueLbl.Font = Enum.Font.Gotham
            valueLbl.TextXAlignment = Enum.TextXAlignment.Right

            local track = Instance.new("Frame", frame)
            track.Size = UDim2.new(1, -24, 0, 6)
            track.Position = UDim2.new(0, 12, 0, 32)
            track.BackgroundColor3 = theme.Outline
            track.BorderSizePixel = 0
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame", track)
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = theme.Accent
            fill.BorderSizePixel = 0
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", track)
            knob.Size = UDim2.fromOffset(14, 14)
            knob.Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local sliderBtn = Instance.new("TextButton", frame)
            sliderBtn.Size = UDim2.new(1, 0, 0, 22)
            sliderBtn.Position = UDim2.new(0, 0, 0, 24)
            sliderBtn.BackgroundTransparency = 1
            sliderBtn.Text = ""

            local dragging = false
            local function update(input)
                local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * relX + 0.5)
                fill.Size = UDim2.new(relX, 0, 1, 0)
                knob.Position = UDim2.new(relX, -7, 0.5, -7)
                valueLbl.Text = tostring(value)
                cb(value)
            end

            sliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    update(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)

            local element = {
                Type = "Slider",
                Name = name,
                Tab = Tab.Name,
                Frame = frame,
                Get = function() return value end,
                Set = function(v, silent)
                    value = math.clamp(v, min, max)
                    local relX = (value - min) / (max - min)
                    fill.Size = UDim2.new(relX, 0, 1, 0)
                    knob.Position = UDim2.new(relX, -7, 0.5, -7)
                    valueLbl.Text = tostring(value)
                    if not silent then cb(value) end
                end
            }
            table.insert(registry, element)
            return element
        end

        function Tab:AddDropdown(cfg)
            local name = cfg.Name or "Dropdown"
            local options = cfg.Options or {}
            local value = cfg.Default or options[1]
            local cb = cfg.Callback or function() end

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -8, 0, 58)
            frame.BackgroundTransparency = 1
            frame.ClipsDescendants = false
            frame.Parent = page
            frame.ZIndex = 5

            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1, 0, 0, 18)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = theme.Text
            lbl.TextSize = 13
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 6

            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.Position = UDim2.new(0, 0, 0, 22)
            btn.BackgroundColor3 = theme.TertiaryBackground
            btn.Text = "▼  " .. tostring(value)
            btn.TextColor3 = theme.Text
            btn.TextSize = 13
            btn.Font = Enum.Font.Gotham
            btn.BorderSizePixel = 0
            btn.ZIndex = 6
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

            local list = Instance.new("Frame", frame)
            list.Size = UDim2.new(1, 0, 0, 0)
            list.Position = UDim2.new(0, 0, 0, 56)
            list.BackgroundColor3 = theme.SecondaryBackground
            list.BorderSizePixel = 0
            list.Visible = false
            list.ZIndex = 10
            Instance.new("UICorner", list).CornerRadius = UDim.new(0, 6)
            local lLayout = Instance.new("UIListLayout", list)
            lLayout.Padding = UDim.new(0, 2)

            local open = false
            local function build()
                for _, c in ipairs(list:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, opt in ipairs(options) do
                    local ob = Instance.new("TextButton", list)
                    ob.Size = UDim2.new(1, 0, 0, 28)
                    ob.BackgroundColor3 = theme.SecondaryBackground
                    ob.Text = tostring(opt)
                    ob.TextColor3 = theme.Text
                    ob.TextSize = 12
                    ob.Font = Enum.Font.Gotham
                    ob.BorderSizePixel = 0
                    ob.ZIndex = 11
                    ob.MouseButton1Click:Connect(function()
                        value = opt
                        btn.Text = "▼  " .. tostring(opt)
                        open = false
                        list.Visible = false
                        list.Size = UDim2.new(1, 0, 0, 0)
                        cb(opt)
                    end)
                end
                list.Size = UDim2.new(1, 0, 0, #options * 30)
            end
            build()

            btn.MouseButton1Click:Connect(function()
                open = not open
                list.Visible = open
                if open then build() end
            end)

            local element = {
                Type = "Dropdown",
                Name = name,
                Tab = Tab.Name,
                Frame = frame,
                Get = function() return value end,
                Set = function(v, silent)
                    value = v
                    btn.Text = "▼  " .. tostring(v)
                    if not silent then cb(v) end
                end,
                UpdateOptions = function(newOptions)
                    options = newOptions
                    build()
                end
            }
            table.insert(registry, element)
            return element
        end

        function Tab:AddKeyPicker(cfg)
            local name = cfg.Name or "Keybind"
            local currentKey = cfg.Default or Enum.KeyCode.E
            local mode = cfg.Mode or "Toggle"
            local cb = cfg.Callback or function() end
            local state = false

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -8, 0, 32)
            frame.BackgroundColor3 = theme.TertiaryBackground
            frame.BorderSizePixel = 0
            frame.Parent = page
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1, -130, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = theme.Text
            lbl.TextSize = 13
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local keyBtn = Instance.new("TextButton", frame)
            keyBtn.Size = UDim2.fromOffset(110, 22)
            keyBtn.Position = UDim2.new(1, -118, 0.5, -11)
            keyBtn.BackgroundColor3 = theme.SecondaryBackground
            keyBtn.Text = currentKey.Name .. " [" .. mode .. "]"
            keyBtn.TextColor3 = theme.Text
            keyBtn.TextSize = 12
            keyBtn.Font = Enum.Font.Gotham
            keyBtn.BorderSizePixel = 0
            Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 5)

            local entry = {key = currentKey, mode = mode, callback = cb, state = state, name = name, btn = keyBtn}
            table.insert(keyBindings, entry)

            keyBtn.MouseButton1Click:Connect(function()
                bindingTarget = entry
                keyBtn.Text = "Нажмите..."
            end)

            local element = {
                Type = "KeyPicker",
                Name = name,
                Tab = Tab.Name,
                Frame = frame,
                Get = function() return entry.key end,
                GetMode = function() return entry.mode end,
                Set = function(key, silent)
                    entry.key = key
                    keyBtn.Text = key.Name .. " [" .. entry.mode .. "]"
                    if not silent then end
                end,
                SetMode = function(m)
                    entry.mode = m
                    keyBtn.Text = entry.key.Name .. " [" .. m .. "]"
                end
            }
            table.insert(registry, element)
            return element
        end

        function Tab:AddColorPicker(cfg)
            local name = cfg.Name or "Color"
            local color = cfg.Default or Color3.fromRGB(255, 255, 255)
            local cb = cfg.Callback or function() end

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -8, 0, 32)
            frame.BackgroundColor3 = theme.TertiaryBackground
            frame.BorderSizePixel = 0
            frame.Parent = page
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1, -60, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = theme.Text
            lbl.TextSize = 13
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local swatch = Instance.new("TextButton", frame)
            swatch.Size = UDim2.fromOffset(36, 22)
            swatch.Position = UDim2.new(1, -46, 0.5, -11)
            swatch.BackgroundColor3 = color
            swatch.Text = ""
            swatch.BorderSizePixel = 0
            swatch.Parent = frame
            Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 5)
            local swStroke = Instance.new("UIStroke", swatch)
            swStroke.Color = theme.Outline

            local picker = Instance.new("Frame", frame)
            picker.Size = UDim2.new(1, 0, 0, 130)
            picker.Position = UDim2.new(0, 0, 0, 36)
            picker.BackgroundColor3 = theme.SecondaryBackground
            picker.BorderSizePixel = 0
            picker.Visible = false
            picker.ZIndex = 10
            Instance.new("UICorner", picker).CornerRadius = UDim.new(0, 6)

            local rSl, gSl, bSl = color.R, color.G, color.B
            local updated = false
            local function push()
                color = Color3.new(rSl, gSl, bSl)
                swatch.BackgroundColor3 = color
                if updated then cb(color) end
            end

            local function makeRow(y, label, initVal, apply)
                local row = Instance.new("Frame", picker)
                row.Size = UDim2.new(1, -16, 0, 26)
                row.Position = UDim2.new(0, 8, 0, y)
                row.BackgroundTransparency = 1
                local lt = Instance.new("TextLabel", row)
                lt.Size = UDim2.fromOffset(20, 26)
                lt.BackgroundTransparency = 1
                lt.Text = label
                lt.TextColor3 = theme.Text
                lt.TextSize = 12
                lt.Font = Enum.Font.GothamBold
                local tr = Instance.new("Frame", row)
                tr.Size = UDim2.new(1, -30, 0, 6)
                tr.Position = UDim2.new(0, 26, 0.5, -3)
                tr.BackgroundColor3 = theme.Outline
                tr.BorderSizePixel = 0
                Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)
                local fl = Instance.new("Frame", tr)
                fl.Size = UDim2.new(initVal, 0, 1, 0)
                fl.BackgroundColor3 = theme.Accent
                fl.BorderSizePixel = 0
                Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
                local hit = Instance.new("TextButton", row)
                hit.Size = UDim2.new(1, -26, 1, 0)
                hit.Position = UDim2.new(0, 26, 0, 0)
                hit.BackgroundTransparency = 1
                hit.Text = ""
                local drag = false
                local function upd(inp)
                    local rx = math.clamp((inp.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
                    fl.Size = UDim2.new(rx, 0, 1, 0)
                    apply(rx)
                    push()
                end
                hit.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true upd(i) end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i) end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
                end)
            end

            makeRow(8, "R", rSl, function(v) rSl = v end)
            makeRow(38, "G", gSl, function(v) gSl = v end)
            makeRow(68, "B", bSl, function(v) bSl = v end)

            local hexBox = Instance.new("TextBox", picker)
            hexBox.Size = UDim2.new(1, -16, 0, 26)
            hexBox.Position = UDim2.new(0, 8, 0, 98)
            hexBox.BackgroundColor3 = theme.TertiaryBackground
            hexBox.Text = string.format("#%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
            hexBox.TextColor3 = theme.Text
            hexBox.TextSize = 12
            hexBox.Font = Enum.Font.Gotham
            hexBox.BorderSizePixel = 0
            hexBox.ClearTextOnFocus = false
            Instance.new("UICorner", hexBox).CornerRadius = UDim.new(0, 5)
            hexBox.FocusLost:Connect(function()
                local hex = hexBox.Text:gsub("#", "")
                local r = tonumber(hex:sub(1, 2), 16)
                local g = tonumber(hex:sub(3, 4), 16)
                local b = tonumber(hex:sub(5, 6), 16)
                if r and g and b then
                    color = Color3.fromRGB(r, g, b)
                    swatch.BackgroundColor3 = color
                    updated = true
                    cb(color)
                end
            end)

            updated = true
            local toggle = false
            swatch.MouseButton1Click:Connect(function()
                toggle = not toggle
                picker.Visible = toggle
                if toggle then frame.Size = UDim2.new(1, -8, 0, 172) else frame.Size = UDim2.new(1, -8, 0, 32) end
            end)

            local element = {
                Type = "ColorPicker",
                Name = name,
                Tab = Tab.Name,
                Frame = frame,
                Get = function() return color end,
                Set = function(c, silent)
                    color = c
                    rSl, gSl, bSl = c.R, c.G, c.B
                    swatch.BackgroundColor3 = c
                    hexBox.Text = string.format("#%02X%02X%02X", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
                    if not silent then cb(c) end
                end
            }
            table.insert(registry, element)
            return element
        end

        function Tab:AddTextBox(cfg)
            local name = cfg.Name or "TextBox"
            local value = cfg.Default or ""
            local placeholder = cfg.Placeholder or ""
            local maxLen = cfg.MaxLength or 50
            local cb = cfg.Callback or function() end

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -8, 0, 52)
            frame.BackgroundTransparency = 1
            frame.Parent = page

            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1, 0, 0, 18)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = theme.Text
            lbl.TextSize = 13
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local box = Instance.new("TextBox", frame)
            box.Size = UDim2.new(1, 0, 0, 30)
            box.Position = UDim2.new(0, 0, 0, 20)
            box.BackgroundColor3 = theme.TertiaryBackground
            box.Text = value
            box.PlaceholderText = placeholder
            box.PlaceholderColor3 = theme.TextDim
            box.TextColor3 = theme.Text
            box.TextSize = 13
            box.Font = Enum.Font.Gotham
            box.BorderSizePixel = 0
            box.ClearTextOnFocus = false
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
            box:GetPropertyChangedSignal("Text"):Connect(function()
                if #box.Text > maxLen then box.Text = box.Text:sub(1, maxLen) end
            end)
            box.FocusLost:Connect(function()
                value = box.Text
                cb(value)
            end)

            local element = {
                Type = "TextBox",
                Name = name,
                Tab = Tab.Name,
                Frame = frame,
                Get = function() return value end,
                Set = function(v, silent)
                    value = tostring(v)
                    box.Text = value
                    if not silent then cb(value) end
                end
            }
            table.insert(registry, element)
            return element
        end

        function Tab:AddGroupBox(cfg)
            local name = cfg.Name or "Group"
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -8, 0, 30)
            frame.BackgroundColor3 = theme.SecondaryBackground
            frame.BorderSizePixel = 0
            frame.AutomaticSize = Enum.AutomaticSize.Y
            frame.Parent = page
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
            local stroke = Instance.new("UIStroke", frame)
            stroke.Color = theme.Outline

            local title = Instance.new("TextLabel", frame)
            title.Size = UDim2.new(1, -20, 0, 26)
            title.Position = UDim2.new(0, 12, 0, 4)
            title.BackgroundTransparency = 1
            title.Text = name
            title.TextColor3 = theme.Accent
            title.TextSize = 13
            title.Font = Enum.Font.GothamBold
            title.TextXAlignment = Enum.TextXAlignment.Left

            local body = Instance.new("Frame", frame)
            body.Size = UDim2.new(1, -12, 0, 0)
            body.Position = UDim2.new(0, 6, 0, 30)
            body.BackgroundTransparency = 1
            body.AutomaticSize = Enum.AutomaticSize.Y
            local bl = Instance.new("UIListLayout", body)
            bl.Padding = UDim.new(0, 6)
            local bp = Instance.new("UIPadding", body)
            bp.PaddingBottom = UDim.new(0, 6)

            local Group = {Name = name, Frame = frame}

            function Group:AddToggle(c)
                local orig = Tab.AddToggle
                local pageSaved = page
                local ref = page
                page = body
                local el = Tab:AddToggle(c)
                page = pageSaved
                return el
            end
            function Group:AddSlider(c)
                local pageSaved = page
                page = body
                local el = Tab:AddSlider(c)
                page = pageSaved
                return el
            end
            function Group:AddButton(c)
                local pageSaved = page
                page = body
                local el = Tab:AddButton(c)
                page = pageSaved
                return el
            end
            function Group:AddDropdown(c)
                local pageSaved = page
                page = body
                local el = Tab:AddDropdown(c)
                page = pageSaved
                return el
            end
            function Group:AddColorPicker(c)
                local pageSaved = page
                page = body
                local el = Tab:AddColorPicker(c)
                page = pageSaved
                return el
            end
            function Group:AddTextBox(c)
                local pageSaved = page
                page = body
                local el = Tab:AddTextBox(c)
                page = pageSaved
                return el
            end
            function Group:AddKeyPicker(c)
                local pageSaved = page
                page = body
                local el = Tab:AddKeyPicker(c)
                page = pageSaved
                return el
            end

            return Group
        end

        return Tab
    end

    function Window:AddSearchBar(cfg)
        local placeholder = cfg.Placeholder or "Search..."
        local cb = cfg.Callback or function() end
        local bar = Instance.new("Frame", main)
        bar.Size = UDim2.new(1, -180, 0, 28)
        bar.Position = UDim2.new(0, 170, 1, -34)
        bar.BackgroundColor3 = theme.SecondaryBackground
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)
        local box = Instance.new("TextBox", bar)
        box.Size = UDim2.new(1, -20, 1, 0)
        box.Position = UDim2.new(0, 10, 0, 0)
        box.BackgroundTransparency = 1
        box.PlaceholderText = placeholder
        box.PlaceholderColor3 = theme.TextDim
        box.Text = ""
        box.TextColor3 = theme.Text
        box.TextSize = 13
        box.Font = Enum.Font.Gotham
        box.TextXAlignment = Enum.TextXAlignment.Left
        box:GetPropertyChangedSignal("Text"):Connect(function()
            cb(box.Text)
            local q = box.Text:lower()
            for _, el in ipairs(registry) do
                if el.Frame and el.Name then
                    if q == "" then
                        el.Frame.Visible = true
                    else
                        el.Frame.Visible = el.Name:lower():find(q, 1, true) ~= nil
                    end
                end
            end
        end)
        return bar
    end

    return Window
end

function WinterCatLib:SaveConfig(name)
    ensureFolder()
    local data = {}
    for _, el in ipairs(registry) do
        local key = (el.Tab or "Tab") .. "/" .. el.Name
        if el.Get then
            data[key] = serialize(el.Get())
        end
    end
    local encoded = HttpService:JSONEncode(data)
    if writefileFn then
        pcall(writefileFn, CONFIG_FOLDER .. "/" .. name .. ".json", encoded)
        return true
    end
    return false
end

function WinterCatLib:LoadConfig(name)
    ensureFolder()
    if not readfileFn then return false end
    local ok, raw = pcall(readfileFn, CONFIG_FOLDER .. "/" .. name .. ".json")
    if not ok or not raw then return false end
    local decoded
    local dok, d = pcall(function() return HttpService:JSONDecode(raw) end)
    if dok then decoded = d else return false end
    for _, el in ipairs(registry) do
        local key = (el.Tab or "Tab") .. "/" .. el.Name
        if decoded[key] ~= nil and el.Set then
            pcall(function() el.Set(deserialize(decoded[key]), true) end)
        end
    end
    return true
end

function WinterCatLib:GetConfigList()
    ensureFolder()
    if not listfilesFn then return {} end
    local ok, files = pcall(listfilesFn, CONFIG_FOLDER)
    if not ok then return {} end
    local out = {}
    for _, f in ipairs(files) do
        local n = f:match("([^/\\]+)%.json$")
        if n then table.insert(out, n) end
    end
    return out
end

function WinterCatLib:DeleteConfig(name)
    if delfile then
        pcall(delfile, CONFIG_FOLDER .. "/" .. name .. ".json")
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if bindingTarget then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            bindingTarget.key = input.KeyCode
            bindingTarget.btn.Text = input.KeyCode.Name .. " [" .. bindingTarget.mode .. "]"
            bindingTarget = nil
        end
        return
    end
    for _, entry in ipairs(keyBindings) do
        if entry.key == input.KeyCode then
            if entry.mode == "Toggle" then
                entry.state = not entry.state
                entry.callback(entry.state)
            elseif entry.mode == "Hold" then
                entry.state = true
                entry.callback(true)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    for _, entry in ipairs(keyBindings) do
        if entry.mode == "Hold" and entry.key == input.KeyCode then
            entry.state = false
            entry.callback(false)
        end
    end
end)

do
    local acc = 0
    RunService.Heartbeat:Connect(function(dt)
        acc = acc + dt
        if acc < 0.1 then return end
        acc = 0
        for _, el in ipairs(registry) do
            if el.visibleFn and el.Frame then
                local should = el.visibleFn() and true or false
                if el.Frame.Visible ~= should then
                    el.Frame.Visible = should
                end
            end
        end
    end)
end

return WinterCatLib
