local WintherCatLib = {}
WintherCatLib.__index = WintherCatLib

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local DefaultWinterTheme = {
    Background       = Color3.fromRGB(15, 22, 35),
    SecondaryBackground = Color3.fromRGB(22, 32, 50),
    TertiaryBackground  = Color3.fromRGB(30, 42, 65),
    Accent           = Color3.fromRGB(120, 190, 255),
    AccentDark       = Color3.fromRGB(70, 140, 210),
    AccentLight      = Color3.fromRGB(180, 220, 255),
    Text             = Color3.fromRGB(235, 245, 255),
    TextDim          = Color3.fromRGB(160, 180, 200),
    TextMuted        = Color3.fromRGB(100, 120, 145),
    Stroke           = Color3.fromRGB(60, 90, 130),
    Divider          = Color3.fromRGB(35, 50, 75),
    Shadow           = Color3.fromRGB(0, 0, 0),
    CloseButton      = Color3.fromRGB(220, 80, 80),
    MinimizeButton   = Color3.fromRGB(255, 200, 100),
    FullscreenButton = Color3.fromRGB(120, 220, 160),
}

local function Create(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function GetParentGui()
    local ok, core = pcall(function() return CoreGui end)
    if ok and core then
        local success = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = core
            test:Destroy()
        end)
        if success then return core end
    end
    local ok2, pg = pcall(function() return LocalPlayer:WaitForChild("PlayerGui") end)
    if ok2 and pg then return pg end
    return CoreGui
end

local function Corner(radius, parent)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function Stroke(color, thickness, parent)
    return Create("UIStroke", {
        Color = color or DefaultWinterTheme.Stroke,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function Padding(px, parent)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, px),
        PaddingBottom = UDim.new(0, px),
        PaddingLeft = UDim.new(0, px),
        PaddingRight = UDim.new(0, px),
        Parent = parent
    })
end

local function ListLayout(props, parent)
    return Create("UIListLayout", props or { Parent = parent })
end

function WintherCatLib:CreateWindow(config)
    config = config or {}
    
    local Title      = config.Title or "WintherCatLib"
    local Size       = config.Size or UDim2.fromOffset(620, 420)
    local Theme      = config.Theme or {}
    local ToggleKey  = config.ToggleKey or Enum.KeyCode.RightShift
    local OnDestroy  = config.OnDestroy
    local OnMinimize = config.OnMinimize
    local OnRestore  = config.OnRestore
    
    local T = {}
    for k, v in pairs(DefaultWinterTheme) do T[k] = v end
    for k, v in pairs(Theme) do T[k] = v end
    
    local ParentGui = GetParentGui()
    
    local ScreenGui = Create("ScreenGui", {
        Name = "WintherCatLib",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = ParentGui
    })
    
    local Main = Create("Frame", {
        Name = "Main",
        Size = Size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        Active = true,
        Draggable = false,
        Parent = ScreenGui
    })
    Corner(12, Main)
    Stroke(T.Stroke, 1.5, Main)
    
    local Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = T.SecondaryBackground,
        BorderSizePixel = 0,
        Parent = Main
    })
    Corner(12, Header)
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = T.SecondaryBackground,
        BorderSizePixel = 0,
        Parent = Header
    })
    
    local TitleLabel = Create("TextLabel", {
        Size = UDim2.new(1, -130, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = "❄  " .. Title,
        TextColor3 = T.Text,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    local ButtonContainer = Create("Frame", {
        Size = UDim2.new(0, 96, 0, 28),
        Position = UDim2.new(1, -104, 0, 6),
        BackgroundTransparency = 1,
        Parent = Header
    })
    ListLayout({
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = ButtonContainer
    })
    
    local function MakeWindowButton(color, symbol, tooltip)
        local btn = Create("TextButton", {
            Size = UDim2.fromOffset(26, 26),
            BackgroundColor3 = T.TertiaryBackground,
            Text = symbol,
            TextColor3 = color,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            Parent = ButtonContainer
        })
        Corner(13, btn)
        Stroke(T.Stroke, 1, btn)
        
        local origColor = T.TertiaryBackground
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = color }):Play()
            TweenService:Create(btn, TweenInfo.new(0.15), { TextColor3 = T.Background }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = origColor }):Play()
            TweenService:Create(btn, TweenInfo.new(0.15), { TextColor3 = color }):Play()
        end)
        return btn
    end
    
    local MinimizeBtn   = MakeWindowButton(T.MinimizeButton,   "—", "Свернуть (RightShift)")
    local FullscreenBtn = MakeWindowButton(T.FullscreenButton, "□", "На весь экран")
    local CloseBtn      = MakeWindowButton(T.CloseButton,      "✕", "Закрыть")
    
    local Body = Create("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = Main
    })
    
    local TabPanel = Create("Frame", {
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = T.SecondaryBackground,
        BorderSizePixel = 0,
        Parent = Body
    })
    Corner(0, TabPanel)
    
    Create("Frame", {
        Size = UDim2.new(0, 12, 1, 0),
        Position = UDim2.new(1, -12, 0, 0),
        BackgroundColor3 = T.SecondaryBackground,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = TabPanel
    })
    
    local TabList = Create("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Stroke,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = TabPanel
    })
    ListLayout({
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabList
    })
    Padding(4, TabList)
    
    local Content = Create("Frame", {
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        BackgroundTransparency = 1,
        Parent = Body
    })
    Padding(14, Content)
    
    local State = {
        Destroyed = false,
        Minimized = false,
        Fullscreen = false,
        SavedSize = Size,
        SavedPosition = Main.Position,
        Tabs = {},
        ActiveTab = nil,
    }
    
    local Connections = {}
    local function Track(conn)
        table.insert(Connections, conn)
        return conn
    end
    
    local function Destroy()
        if State.Destroyed then return end
        State.Destroyed = true
        
        for _, c in ipairs(Connections) do
            pcall(function() c:Disconnect() end)
        end
        Connections = {}
        
        local closeTween = TweenService:Create(
            Main,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Size = UDim2.new(Size.X.Scale, 0, Size.Y.Scale, 0), BackgroundTransparency = 1 }
        )
        closeTween:Play()
        
        for _, d in ipairs(Main:GetDescendants()) do
            if d:IsA("GuiObject") then
                pcall(function()
                    TweenService:Create(d, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
                end)
            end
        end
        
        task.delay(0.22, function()
            pcall(function() ScreenGui:Destroy() end)
            if typeof(OnDestroy) == "function" then
                task.spawn(function()
                    OnDestroy()
                end)
            end
        end)
    end
    
    local function SetMinimized(min)
        if State.Destroyed then return end
        State.Minimized = min
        
        if min then
            State.SavedSize = Main.Size
            State.SavedPosition = Main.Position
            TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(240, 42),
                Position = UDim2.new(0, 20, 0, 20),
                AnchorPoint = Vector2.new(0, 0),
            }):Play()
            TweenService:Create(Body, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
            Body.Visible = false
            if typeof(OnMinimize) == "function" then task.spawn(OnMinimize) end
        else
            Body.Visible = true
            TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = State.SavedSize,
                Position = State.SavedPosition,
                AnchorPoint = Vector2.new(0.5, 0.5),
            }):Play()
            TweenService:Create(Body, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
            if typeof(OnRestore) == "function" then task.spawn(OnRestore) end
        end
    end
    
    local function ToggleMinimize()
        SetMinimized(not State.Minimized)
    end
    
    local function SetFullscreen(full)
        if State.Destroyed then return end
        if full == State.Fullscreen then return end
        
        if full then
            State.Fullscreen = true
            if not State.Minimized then
                State.SavedSize = Main.Size
                State.SavedPosition = Main.Position
            end
            TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
            }):Play()
        else
            State.Fullscreen = false
            TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = State.SavedSize,
                Position = State.SavedPosition,
                AnchorPoint = Vector2.new(0.5, 0.5),
            }):Play()
        end
    end
    
    local function ToggleFullscreen()
        SetFullscreen(not State.Fullscreen)
    end
    
    Track(MinimizeBtn.MouseButton1Click:Connect(ToggleMinimize))
    Track(FullscreenBtn.MouseButton1Click:Connect(ToggleFullscreen))
    Track(CloseBtn.MouseButton1Click:Connect(Destroy))
    
    Track(UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == ToggleKey then
            ToggleMinimize()
        end
    end))
    
    local dragging, dragStart, startPos
    Track(Header.InputBegan:Connect(function(input)
        if State.Fullscreen or State.Minimized then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end))
    
    Track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))
    
    Track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    
    function WintherCatLib:CreateTab(cfg)
        cfg = cfg or {}
        local tabName = cfg.Name or "Tab"
        
        local TabButton = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = T.TertiaryBackground,
            BackgroundTransparency = 1,
            Text = "   " .. tabName,
            TextColor3 = T.TextDim,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Parent = TabList
        })
        Corner(8, TabButton)
        
        local TabIndicator = Create("Frame", {
            Size = UDim2.new(0, 3, 0, 18),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = T.Accent,
            BorderSizePixel = 0,
            Visible = false,
            Parent = TabButton
        })
        Corner(2, TabIndicator)
        
        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = T.Stroke,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = Content
        })
        ListLayout({
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Page
        })
        
        local Tab = {
            Name = tabName,
            Button = TabButton,
            Page = Page,
        }
        
        local function Activate()
            for _, t in pairs(State.Tabs) do
                t.Button.BackgroundTransparency = 1
                t.Button.TextColor3 = T.TextDim
                t.Page.Visible = false
            end
            TabButton.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = T.TertiaryBackground
            TabButton.TextColor3 = T.Text
            Page.Visible = true
            TabIndicator.Visible = true
            State.ActiveTab = Tab
        end
        
        Track(TabButton.MouseButton1Click:Connect(Activate))
        Track(TabButton.MouseEnter:Connect(function()
            if State.ActiveTab ~= Tab then
                TweenService:Create(TabButton, TweenInfo.new(0.15), { BackgroundTransparency = 0.85 }):Play()
            end
        end))
        Track(TabButton.MouseLeave:Connect(function()
            if State.ActiveTab ~= Tab then
                TweenService:Create(TabButton, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
            end
        end))
        
        State.Tabs[tabName] = Tab
        if not State.ActiveTab then Activate() end
        
        function Tab:AddButton(cfg2)
            cfg2 = cfg2 or {}
            local btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = T.TertiaryBackground,
                Text = cfg2.Name or "Button",
                TextColor3 = T.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                AutoButtonColor = false,
                Parent = Page
            })
            Corner(8, btn)
            Stroke(T.Stroke, 1, btn)
            
            Track(btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = T.AccentDark }):Play()
            end))
            Track(btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = T.TertiaryBackground }):Play()
            end))
            Track(btn.MouseButton1Click:Connect(function()
                if cfg2.Callback then task.spawn(cfg2.Callback) end
            end))
            return btn
        end
        
        function Tab:AddToggle(cfg2)
            cfg2 = cfg2 or {}
            local value = cfg2.Default or false
            
            local frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = T.TertiaryBackground,
                Parent = Page
            })
            Corner(8, frame)
            Stroke(T.Stroke, 1, frame)
            
            local label = Create("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = cfg2.Name or "Toggle",
                TextColor3 = T.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })
            
            local track = Create("Frame", {
                Size = UDim2.fromOffset(40, 20),
                Position = UDim2.new(1, -50, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = T.Divider,
                Parent = frame
            })
            Corner(10, track)
            
            local knob = Create("Frame", {
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.new(0, 2, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = T.Text,
                Parent = track
            })
            Corner(8, knob)
            
            local function Update(anim)
                local goal = value
                    and { Position = UDim2.new(1, -18, 0.5, 0), BackgroundColor3 = T.Accent }
                    or  { Position = UDim2.new(0, 2, 0.5, 0),   BackgroundColor3 = T.Text }
                local tweenInfo = anim and TweenInfo.new(0.2, Enum.EasingStyle.Quad) or TweenInfo.new(0)
                TweenService:Create(knob, tweenInfo, goal):Play()
                TweenService:Create(track, tweenInfo, {
                    BackgroundColor3 = value and T.AccentDark or T.Divider
                }):Play()
            end
            
            Update(false)
            
            local clickArea = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = frame
            })
            Track(clickArea.MouseButton1Click:Connect(function()
                value = not value
                Update(true)
                if cfg2.Callback then task.spawn(cfg2.Callback, value) end
            end))
            
            return {
                Set = function(_, v)
                    value = v
                    Update(true)
                    if cfg2.Callback then task.spawn(cfg2.Callback, value) end
                end,
                Get = function() return value end,
            }
        end
        
        function Tab:AddSlider(cfg2)
            cfg2 = cfg2 or {}
            local min = cfg2.Min or 0
            local max = cfg2.Max or 100
            local value = cfg2.Default or min
            
            local frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 46),
                BackgroundColor3 = T.TertiaryBackground,
                Parent = Page
            })
            Corner(8, frame)
            Stroke(T.Stroke, 1, frame)
            
            local label = Create("TextLabel", {
                Size = UDim2.new(1, -16, 0, 20),
                Position = UDim2.new(0, 12, 0, 4),
                BackgroundTransparency = 1,
                Text = cfg2.Name or "Slider",
                TextColor3 = T.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })
            
            local valueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 60, 0, 20),
                Position = UDim2.new(1, -72, 0, 4),
                BackgroundTransparency = 1,
                Text = tostring(value),
                TextColor3 = T.AccentLight,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = frame
            })
            
            local bar = Create("Frame", {
                Size = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 0, 32),
                BackgroundColor3 = T.Divider,
                Parent = frame
            })
            Corner(3, bar)
            
            local fill = Create("Frame", {
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = T.Accent,
                Parent = bar
            })
            Corner(3, fill)
            
            local function Update(v, anim)
                value = math.clamp(v, min, max)
                local alpha = (value - min) / (max - min)
                local info = anim and TweenInfo.new(0.1) or TweenInfo.new(0)
                TweenService:Create(fill, info, { Size = UDim2.new(alpha, 0, 1, 0) }):Play()
                valueLabel.Text = tostring(math.floor(value * 100) / 100)
            end
            
            local sliding = false
            Track(bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                end
            end))
            Track(UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end))
            Track(UserInputService.InputChanged:Connect(function(input)
                if not sliding then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement
                    and input.UserInputType ~= Enum.UserInputType.Touch then return end
                local rel = math.clamp(
                    (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1
                )
                Update(min + (max - min) * rel, false)
                if cfg2.Callback then cfg2.Callback(value) end
            end))
            
            return {
                Set = function(_, v) Update(v, true) end,
                Get = function() return value end,
            }
        end
        
        return Tab
    end
    
    local Window = {
        GUI            = ScreenGui,
        Frame          = Main,
        Title          = TitleLabel,
        Theme          = T,
        
        Destroy        = Destroy,
        Minimize       = function() SetMinimized(true)  end,
        Restore        = function() SetMinimized(false) end,
        ToggleMinimize = ToggleMinimize,
        IsMinimized    = function() return State.Minimized end,
        
        Fullscreen     = function() SetFullscreen(true)  end,
        Unfullscreen   = function() SetFullscreen(false) end,
        ToggleFullscreen = ToggleFullscreen,
        IsFullscreen   = function() return State.Fullscreen end,
        
        SetColor = function(_, key, color)
            if T[key] then
                T[key] = color
                if key == "Background" then Main.BackgroundColor3 = color end
                if key == "SecondaryBackground" then Header.BackgroundColor3 = color end
                if key == "Accent" then
                    for _, t in pairs(State.Tabs) do
                        if t.Page then
                            for _, c in ipairs(t.Page:GetDescendants()) do
                                if c:IsA("Frame") and c.BackgroundColor3 == T.Accent then
                                    c.BackgroundColor3 = color
                                end
                            end
                        end
                    end
                end
            end
        end,
        GetTheme = function() return T end,
        
        CreateTab = WintherCatLib.CreateTab,
    }
    
    return Window
end

_G.WintherCatLib = WintherCatLib
getgenv().WintherCatLib = WintherCatLib

return WintherCatLib
