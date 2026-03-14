--[[
    MOON v2.5 — VISUAL MODULE (FIXED / IMPROVED)
]]

local Visual = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local BASE_W = 1920
local BASE_H = 1080

local auroraColors = {
    Color3.fromRGB(120, 40, 220),
    Color3.fromRGB(60, 120, 255),
    Color3.fromRGB(40, 200, 200),
    Color3.fromRGB(100, 60, 255),
    Color3.fromRGB(180, 60, 220),
    Color3.fromRGB(60, 180, 255),
}

function Visual.getAuroraColor(t, offset)
    offset = offset or 0
    local speed = 0.35
    local idx = ((t * speed + offset) % #auroraColors)
    local i1 = math.floor(idx) % #auroraColors + 1
    local i2 = (i1 % #auroraColors) + 1
    local frac = idx - math.floor(idx)
    return auroraColors[i1]:Lerp(auroraColors[i2], frac)
end

function Visual.getAuroraSequence(t)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Visual.getAuroraColor(t, 0)),
        ColorSequenceKeypoint.new(0.25, Visual.getAuroraColor(t, 1.2)),
        ColorSequenceKeypoint.new(0.5, Visual.getAuroraColor(t, 2.4)),
        ColorSequenceKeypoint.new(0.75, Visual.getAuroraColor(t, 3.6)),
        ColorSequenceKeypoint.new(1, Visual.getAuroraColor(t, 4.8)),
    })
end

local function safeParent(guiObject)
    local ok = false
    if gethui then
        ok = pcall(function()
            guiObject.Parent = gethui()
        end)
    end
    if not ok then
        pcall(function()
            guiObject.Parent = game.CoreGui
        end)
    end
    if not guiObject.Parent then
        guiObject.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

Visual.SoundIds = {
    Click = "rbxassetid://6895079853",
    Toggle = "rbxassetid://6895079483",
    Open = "rbxassetid://6895078171",
    Close = "rbxassetid://6895078747",
    Notify = "rbxassetid://6895079011",
    Kill = "rbxassetid://6895080427",
}

function Visual.PlaySound(name, volume, speed)
    local soundId = Visual.SoundIds[name]
    if not soundId then
        return
    end
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume or 0.35
    sound.PlaybackSpeed = speed or 1
    sound.RollOffMaxDistance = 0
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function()
        pcall(function()
            sound:Destroy()
        end)
    end)
end

for _, guiName in ipairs({
    "SakuraGUI_v19", "SakuraGUI_v18", "SakuraGUI", "SakuraGUI_v20",
    "MoonGUI_Main", "MoonGUI", "MoonOverlay", "MoonLoad"
}) do
    pcall(function()
        if game.CoreGui:FindFirstChild(guiName) then
            game.CoreGui[guiName]:Destroy()
        end
    end)
    pcall(function()
        if gethui and gethui():FindFirstChild(guiName) then
            gethui()[guiName]:Destroy()
        end
    end)
end

for _, effect in ipairs(Lighting:GetChildren()) do
    if effect.Name:find("SakuraMainBlur") or effect.Name:find("MoonBlur") or effect.Name:find("MoonLoadBlur") then
        pcall(function()
            effect:Destroy()
        end)
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoonOverlay"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 99999
screenGui.IgnoreGuiInset = true
safeParent(screenGui)
Visual.screenGui = screenGui

local scaleCache = 1
local scaleTime = 0
function Visual.getScale()
    if os.clock() - scaleTime < 0.35 then
        return scaleCache
    end
    local cam = workspace.CurrentCamera
    if cam then
        scaleCache = math.clamp(math.min(cam.ViewportSize.X / BASE_W, cam.ViewportSize.Y / BASE_H), 0.4, 4)
    end
    scaleTime = os.clock()
    return scaleCache
end

function Visual.S(v)
    return v * Visual.getScale()
end

function Visual.getVP()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(BASE_W, BASE_H)
end

function Visual.getCenter()
    local vp = Visual.getVP()
    return vp.X * 0.5, vp.Y * 0.5
end

local notifyList = Instance.new("Frame")
notifyList.Name = "NotifyList"
notifyList.Size = UDim2.new(0, 310, 1, -40)
notifyList.Position = UDim2.new(1, -330, 0, 20)
notifyList.BackgroundTransparency = 1
notifyList.ZIndex = 200
notifyList.Parent = screenGui

local notifyLayout = Instance.new("UIListLayout")
notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifyLayout.Padding = UDim.new(0, 8)
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyLayout.Parent = notifyList

function Visual.Notify(title, text, duration, col)
    duration = duration or 4
    col = col or Visual.getAuroraColor(os.clock())
    Visual.PlaySound("Notify", 0.28, 1.05)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 56)
    frame.BackgroundColor3 = Color3.fromRGB(8, 4, 16)
    frame.BackgroundTransparency = 0.04
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.ZIndex = 201
    frame.Parent = notifyList
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.2
    stroke.Transparency = 0.15
    stroke.Parent = frame
    local strokeGrad = Instance.new("UIGradient")
    strokeGrad.Color = Visual.getAuroraSequence(os.clock())
    strokeGrad.Parent = stroke

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title or ""
    titleLabel.Size = UDim2.new(1, -16, 0, 18)
    titleLabel.Position = UDim2.new(0, 12, 0, 7)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 202
    titleLabel.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Text = text or ""
    descLabel.Size = UDim2.new(1, -16, 0, 14)
    descLabel.Position = UDim2.new(0, 12, 0, 27)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = Color3.fromRGB(170, 160, 200)
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 202
    descLabel.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 2)
    bar.Position = UDim2.new(0, 0, 1, -2)
    bar.BorderSizePixel = 0
    bar.BackgroundColor3 = col
    bar.ZIndex = 202
    bar.Parent = frame
    local barGrad = Instance.new("UIGradient")
    barGrad.Color = Visual.getAuroraSequence(os.clock())
    barGrad.Parent = bar

    frame.Position = UDim2.new(1, 60, 0, 0)
    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    local progressTween = TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    })
    progressTween:Play()
    progressTween.Completed:Connect(function()
        local outTween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 60, 0, 0),
            BackgroundTransparency = 1
        })
        outTween:Play()
        outTween.Completed:Connect(function()
            pcall(function()
                frame:Destroy()
            end)
        end)
    end)
end

function Visual.Ripple(button, x, y)
    if not button or not button.Parent then
        return
    end

    local ripple = Instance.new("Frame")
    ripple.BackgroundColor3 = Color3.new(1, 1, 1)
    ripple.BackgroundTransparency = 0.35
    ripple.BorderSizePixel = 0
    ripple.ZIndex = (button.ZIndex or 1) + 5
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Position = UDim2.new(0, x or 0, 0, y or 0)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Parent = button
    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)

    local rippleGrad = Instance.new("UIGradient")
    rippleGrad.Color = Visual.getAuroraSequence(os.clock())
    rippleGrad.Rotation = math.random(0, 360)
    rippleGrad.Parent = ripple

    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    local tween = TweenService:Create(ripple, TweenInfo.new(0.55, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        pcall(function()
            ripple:Destroy()
        end)
    end)
end

local watermark = Instance.new("Frame")
watermark.Size = UDim2.new(0, 190, 0, 28)
watermark.Position = UDim2.new(0, 20, 0, 20)
watermark.BackgroundColor3 = Color3.fromRGB(6, 3, 12)
watermark.BackgroundTransparency = 0.06
watermark.BorderSizePixel = 0
watermark.ZIndex = 100
watermark.Parent = screenGui
Instance.new("UICorner", watermark).CornerRadius = UDim.new(0, 8)

local watermarkStroke = Instance.new("UIStroke")
watermarkStroke.Thickness = 1
watermarkStroke.Transparency = 0.2
watermarkStroke.Parent = watermark
local watermarkStrokeGrad = Instance.new("UIGradient")
watermarkStrokeGrad.Parent = watermarkStroke
Visual._wmStGrad = watermarkStrokeGrad

local watermarkTitle = Instance.new("TextLabel")
watermarkTitle.Size = UDim2.new(0, 80, 1, 0)
watermarkTitle.Position = UDim2.new(0, 8, 0, 0)
watermarkTitle.BackgroundTransparency = 1
watermarkTitle.Text = "MOON v2.5"
watermarkTitle.TextColor3 = Color3.fromRGB(220, 200, 255)
watermarkTitle.TextSize = 11
watermarkTitle.Font = Enum.Font.GothamBold
watermarkTitle.TextXAlignment = Enum.TextXAlignment.Left
watermarkTitle.ZIndex = 101
watermarkTitle.Parent = watermark

local watermarkTime = Instance.new("TextLabel")
watermarkTime.Size = UDim2.new(0, 80, 1, 0)
watermarkTime.Position = UDim2.new(1, -84, 0, 0)
watermarkTime.BackgroundTransparency = 1
watermarkTime.TextColor3 = Color3.fromRGB(100, 85, 140)
watermarkTime.TextSize = 9
watermarkTime.Font = Enum.Font.Code
watermarkTime.TextXAlignment = Enum.TextXAlignment.Right
watermarkTime.ZIndex = 101
watermarkTime.Text = ""
watermarkTime.Parent = watermark
Visual.wmTime = watermarkTime

function Visual.showLoadingScreen()
    local loadGui = Instance.new("ScreenGui")
    loadGui.Name = "MoonLoad"
    loadGui.ResetOnSpawn = false
    loadGui.DisplayOrder = 100000
    loadGui.IgnoreGuiInset = true
    safeParent(loadGui)

    local blur = Instance.new("BlurEffect")
    blur.Name = "MoonLoadBlur"
    blur.Size = 0
    blur.Parent = Lighting

    local dim = Instance.new("Frame")
    dim.Size = UDim2.new(1, 0, 1, 0)
    dim.BackgroundColor3 = Color3.fromRGB(3, 1, 8)
    dim.BackgroundTransparency = 0.15
    dim.BorderSizePixel = 0
    dim.Parent = loadGui

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 340, 0, 100)
    card.Position = UDim2.new(0.5, -170, 0.5, -50)
    card.BackgroundColor3 = Color3.fromRGB(10, 6, 20)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.Parent = loadGui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Thickness = 1.5
    cardStroke.Transparency = 1
    cardStroke.Parent = card
    local cardStrokeGrad = Instance.new("UIGradient")
    cardStrokeGrad.Parent = cardStroke

    local title = Instance.new("TextLabel")
    title.Text = "MOON"
    title.Size = UDim2.new(1, 0, 0, 24)
    title.Position = UDim2.new(0, 0, 0, 14)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(200, 170, 255)
    title.TextTransparency = 1
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = card

    local subtitle = Instance.new("TextLabel")
    subtitle.Text = "loading..."
    subtitle.Size = UDim2.new(1, 0, 0, 14)
    subtitle.Position = UDim2.new(0, 0, 0, 42)
    subtitle.BackgroundTransparency = 1
    subtitle.TextColor3 = Color3.fromRGB(140, 120, 170)
    subtitle.TextTransparency = 1
    subtitle.TextSize = 10
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.Parent = card

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0, 0, 0, 3)
    barBg.Position = UDim2.new(0.5, 0, 0, 68)
    barBg.AnchorPoint = Vector2.new(0.5, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(25, 15, 40)
    barBg.BackgroundTransparency = 1
    barBg.BorderSizePixel = 0
    barBg.Parent = card
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.new(1, 1, 1)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    local barGrad = Instance.new("UIGradient")
    barGrad.Parent = barFill

    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 16}):Play()
    TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.06}):Play()
    TweenService:Create(cardStroke, TweenInfo.new(0.5), {Transparency = 0.15}):Play()
    TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(subtitle, TweenInfo.new(0.5), {TextTransparency = 0.15}):Play()
    TweenService:Create(barBg, TweenInfo.new(0.4), {
        Size = UDim2.new(0, 260, 0, 3),
        BackgroundTransparency = 0.4
    }):Play()

    local stages = {
        {15, "mapping"},
        {30, "patching"},
        {50, "injecting"},
        {70, "bypassing"},
        {90, "loading"},
        {100, "ready"}
    }

    task.spawn(function()
        task.wait(0.6)
        for _, stage in ipairs(stages) do
            barGrad.Color = Visual.getAuroraSequence(os.clock())
            cardStrokeGrad.Color = Visual.getAuroraSequence(os.clock())
            TweenService:Create(barFill, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Size = UDim2.new(stage[1] / 100, 0, 1, 0)
            }):Play()
            subtitle.Text = stage[2]
            task.wait(math.random(10, 22) * 0.01)
        end
        subtitle.Text = "complete"
        subtitle.TextColor3 = Color3.fromRGB(140, 255, 180)
        task.wait(0.35)
        TweenService:Create(card, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(cardStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(subtitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(barFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(barBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(dim, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(blur, TweenInfo.new(0.3), {Size = 0}):Play()
        task.wait(0.4)
        pcall(function()
            blur:Destroy()
        end)
        pcall(function()
            loadGui:Destroy()
        end)
    end)
end

local blurMain = Instance.new("BlurEffect")
blurMain.Name = "MoonBlur"
blurMain.Size = 0
blurMain.Parent = Lighting
Visual.blurMain = blurMain

local gui = Instance.new("ScreenGui")
gui.Name = "MoonGUI_Main"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
safeParent(gui)
Visual.gui = gui

local guiScale = Instance.new("UIScale")
guiScale.Parent = gui
task.spawn(function()
    while gui and gui.Parent do
        guiScale.Scale = math.clamp(
            math.min(Visual.getVP().X / BASE_W, Visual.getVP().Y / BASE_H),
            0.5,
            3
        )
        task.wait(0.6)
    end
end)

local dimOverlay = Instance.new("Frame")
dimOverlay.Size = UDim2.new(1, 0, 1, 0)
dimOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
dimOverlay.BackgroundTransparency = 1
dimOverlay.BorderSizePixel = 0
dimOverlay.ZIndex = 8
dimOverlay.Visible = false
dimOverlay.Parent = gui
Visual.dimOverlay = dimOverlay

local bindsFrame = Instance.new("Frame")
bindsFrame.Size = UDim2.new(0, 150, 0, 24)
bindsFrame.Position = UDim2.new(1, -170, 0, 54)
bindsFrame.BackgroundColor3 = Color3.fromRGB(6, 3, 12)
bindsFrame.BackgroundTransparency = 0.06
bindsFrame.BorderSizePixel = 0
bindsFrame.ZIndex = 100
bindsFrame.ClipsDescendants = true
bindsFrame.Parent = screenGui
Instance.new("UICorner", bindsFrame).CornerRadius = UDim.new(0, 8)

local bindsStroke = Instance.new("UIStroke")
bindsStroke.Thickness = 1
bindsStroke.Transparency = 0.25
bindsStroke.Parent = bindsFrame
local bindsStrokeGrad = Instance.new("UIGradient")
bindsStrokeGrad.Parent = bindsStroke
Visual._bfStGrad = bindsStrokeGrad

local bindsTitle = Instance.new("TextLabel")
bindsTitle.Size = UDim2.new(1, -8, 0, 14)
bindsTitle.Position = UDim2.new(0, 6, 0, 2)
bindsTitle.BackgroundTransparency = 1
bindsTitle.Text = "BINDS"
bindsTitle.TextColor3 = Color3.fromRGB(160, 140, 200)
bindsTitle.TextSize = 8
bindsTitle.Font = Enum.Font.GothamBold
bindsTitle.TextXAlignment = Enum.TextXAlignment.Left
bindsTitle.ZIndex = 101
bindsTitle.Parent = bindsFrame

local bindsContent = Instance.new("Frame")
bindsContent.Size = UDim2.new(1, -8, 1, -16)
bindsContent.Position = UDim2.new(0, 4, 0, 16)
bindsContent.BackgroundTransparency = 1
bindsContent.ZIndex = 101
bindsContent.Parent = bindsFrame

local bindsLayout = Instance.new("UIListLayout")
bindsLayout.Padding = UDim.new(0, 1)
bindsLayout.SortOrder = Enum.SortOrder.LayoutOrder
bindsLayout.Parent = bindsContent

Visual._bfDrag = {drag = false, start = nil, pos = nil}
bindsFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Visual._bfDrag.drag = true
        Visual._bfDrag.start = input.Position
        Visual._bfDrag.pos = bindsFrame.Position
    end
end)
bindsFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Visual._bfDrag.drag = false
    end
end)

function Visual.updateActiveBinds(CFG, C, aimActive, tgtActive, spinActive)
    for _, child in ipairs(bindsContent:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local items = {}
    local function add(name, active)
        table.insert(items, {n = name, a = active})
    end

    add("Aimbot", CFG.Enabled)
    if aimActive then add("Locking", true) end
    if tgtActive then add("Target", true) end
    if spinActive then add("Spin", true) end
    add("Triggerbot", CFG.Triggerbot)
    add("ESP", CFG.ShowESP)
    add("Dash", CFG.DashEnabled)
    if CFG.RageDash then add("R.Dash", true) end
    if CFG.RageTarget then add("R.Target", true) end

    for index, item in ipairs(items) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 12)
        row.BackgroundTransparency = 1
        row.LayoutOrder = index
        row.ZIndex = 102
        row.Parent = bindsContent

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 4, 0, 4)
        dot.Position = UDim2.new(0, 0, 0.5, -2)
        dot.BackgroundColor3 = item.a and Visual.getAuroraColor(os.clock(), index * 0.5) or Color3.fromRGB(60, 50, 80)
        dot.BorderSizePixel = 0
        dot.ZIndex = 103
        dot.Parent = row
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = item.a and Color3.fromRGB(210, 200, 240) or Color3.fromRGB(80, 70, 100)
        label.TextSize = 9
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = item.n
        label.ZIndex = 103
        label.Parent = row
    end

    bindsFrame.Size = UDim2.new(0, 150, 0, math.max(#items * 13 + 20, 24))
end
Visual.bindsFrame = bindsFrame

local HUD_MAX = 16
local hudFrame = Instance.new("Frame")
hudFrame.Size = UDim2.new(0, 210, 0, 180)
hudFrame.Position = UDim2.new(0, 20, 0.5, -90)
hudFrame.BackgroundColor3 = Color3.fromRGB(6, 3, 12)
hudFrame.BackgroundTransparency = 0.15
hudFrame.BorderSizePixel = 0
hudFrame.ZIndex = 5
hudFrame.Visible = false
hudFrame.ClipsDescendants = true
hudFrame.Parent = gui
Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0, 10)

local hudStroke = Instance.new("UIStroke")
hudStroke.Thickness = 1
hudStroke.Transparency = 0.4
hudStroke.Parent = hudFrame
local hudStrokeGrad = Instance.new("UIGradient")
hudStrokeGrad.Parent = hudStroke
Visual._hudStGrad = hudStrokeGrad

local hudList = Instance.new("UIListLayout")
hudList.Padding = UDim.new(0, 2)
hudList.Parent = hudFrame

local hudPadding = Instance.new("UIPadding")
hudPadding.PaddingTop = UDim.new(0, 7)
hudPadding.PaddingLeft = UDim.new(0, 10)
hudPadding.PaddingRight = UDim.new(0, 10)
hudPadding.PaddingBottom = UDim.new(0, 7)
hudPadding.Parent = hudFrame

local hudLabels = {}
for i = 1, HUD_MAX do
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 13)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.Visible = false
    label.ZIndex = 6
    label.TextColor3 = Color3.fromRGB(220, 210, 250)
    label.Text = ""
    label.Parent = hudFrame
    hudLabels[i] = label
end

Visual.hudFrame = hudFrame
Visual.hudT = hudLabels
Visual.HUD_MAX = HUD_MAX

local WIN_MODES = {
    {w = 800, h = 550},
    {w = 620, h = 430},
    {w = 1050, h = 650}
}
Visual.WIN_MODES = WIN_MODES

function Visual.getWS(CFG)
    local mode = WIN_MODES[CFG.WindowMode] or WIN_MODES[1]
    return mode.w, mode.h
end

local windowW, windowH = 800, 550

local mainWindow = Instance.new("Frame")
mainWindow.Name = "W"
mainWindow.Size = UDim2.new(0, windowW, 0, windowH)
mainWindow.Position = UDim2.new(0.5, -windowW / 2, 0.5, -windowH / 2)
mainWindow.BackgroundColor3 = Color3.fromRGB(8, 4, 14)
mainWindow.BackgroundTransparency = 0.02
mainWindow.BorderSizePixel = 0
mainWindow.Visible = false
mainWindow.ZIndex = 10
mainWindow.ClipsDescendants = true
mainWindow.Parent = gui
Instance.new("UICorner", mainWindow).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.1
mainStroke.Parent = mainWindow
local mainStrokeGrad = Instance.new("UIGradient")
mainStrokeGrad.Parent = mainStroke
Visual._gStGrad = mainStrokeGrad
Visual.W = mainWindow
Visual.gSt = mainStroke

local auroraBackground = Instance.new("Frame")
auroraBackground.Size = UDim2.new(1, 0, 1, 0)
auroraBackground.BackgroundColor3 = Color3.new(1, 1, 1)
auroraBackground.BackgroundTransparency = 0.94
auroraBackground.BorderSizePixel = 0
auroraBackground.ZIndex = 10
auroraBackground.Parent = mainWindow
local auroraBackgroundGrad = Instance.new("UIGradient")
auroraBackgroundGrad.Rotation = 25
auroraBackgroundGrad.Parent = auroraBackground
Visual._auroraBgGrad = auroraBackgroundGrad

local stars = {}
for i = 1, 18 do
    local star = Instance.new("Frame")
    local size = math.random(1, 2)
    star.Size = UDim2.new(0, size, 0, size)
    star.Position = UDim2.new(0, math.random(10, windowW - 10), 0, math.random(55, windowH - 10))
    star.BackgroundColor3 = Color3.fromRGB(200, 190, 255)
    star.BackgroundTransparency = math.random(50, 80) / 100
    star.BorderSizePixel = 0
    star.ZIndex = 11
    star.Parent = mainWindow
    Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    stars[i] = star
end
Visual.guiStars = stars

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = Color3.fromRGB(4, 2, 10)
titleBar.BackgroundTransparency = 0.06
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 12
titleBar.Parent = mainWindow
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)
Visual.tB = titleBar

local titleLine = Instance.new("Frame")
titleLine.Size = UDim2.new(1, 0, 0, 2)
titleLine.Position = UDim2.new(0, 0, 1, -2)
titleLine.BackgroundColor3 = Color3.new(1, 1, 1)
titleLine.BackgroundTransparency = 0.1
titleLine.BorderSizePixel = 0
titleLine.ZIndex = 14
titleLine.Parent = titleBar
local titleLineGrad = Instance.new("UIGradient")
titleLineGrad.Parent = titleLine
Visual._tLGrad = titleLineGrad

local moonButton = Instance.new("Frame")
moonButton.Size = UDim2.new(0, 80, 0, 28)
moonButton.Position = UDim2.new(0, 10, 0.5, -14)
moonButton.BackgroundColor3 = Color3.new(1, 1, 1)
moonButton.BackgroundTransparency = 0.12
moonButton.BorderSizePixel = 0
moonButton.ZIndex = 15
moonButton.ClipsDescendants = true
moonButton.Parent = titleBar
Instance.new("UICorner", moonButton).CornerRadius = UDim.new(0, 8)
local moonButtonGrad = Instance.new("UIGradient")
moonButtonGrad.Parent = moonButton
Visual._moonBtnGrad = moonButtonGrad

local moonButtonText = Instance.new("TextLabel")
moonButtonText.Size = UDim2.new(1, 0, 1, 0)
moonButtonText.BackgroundTransparency = 1
moonButtonText.Text = "MOON"
moonButtonText.TextColor3 = Color3.new(1, 1, 1)
moonButtonText.TextSize = 13
moonButtonText.Font = Enum.Font.GothamBold
moonButtonText.ZIndex = 16
moonButtonText.Parent = moonButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "OFF"
statusLabel.Size = UDim2.new(0, 50, 0, 22)
statusLabel.Position = UDim2.new(0, 100, 0.5, -11)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 8, 8)
statusLabel.BackgroundTransparency = 0.3
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextSize = 10
statusLabel.Font = Enum.Font.GothamBold
statusLabel.BorderSizePixel = 0
statusLabel.ZIndex = 15
statusLabel.Parent = titleBar
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 6)
Visual.guiStatus = statusLabel

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Text = "60"
fpsLabel.Size = UDim2.new(0, 50, 0, 14)
fpsLabel.Position = UDim2.new(0, 162, 0.5, -7)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(100, 90, 130)
fpsLabel.TextSize = 9
fpsLabel.Font = Enum.Font.Code
fpsLabel.ZIndex = 15
fpsLabel.Parent = titleBar
Visual.guiFPS = fpsLabel

local killsLabel = Instance.new("TextLabel")
killsLabel.Text = "0 kills"
killsLabel.Size = UDim2.new(0, 55, 0, 14)
killsLabel.Position = UDim2.new(0, 214, 0.5, -7)
killsLabel.BackgroundTransparency = 1
killsLabel.TextColor3 = Color3.fromRGB(100, 90, 130)
killsLabel.TextSize = 9
killsLabel.Font = Enum.Font.Code
killsLabel.ZIndex = 15
killsLabel.Parent = titleBar
Visual.guiKills = killsLabel

local minimized = false
Visual._dragState = {drag = false, start = nil, pos = nil}

local function makeTitleButton(textValue, xOffset, callback)
    local button = Instance.new("TextButton")
    button.Text = textValue
    button.Size = UDim2.new(0, 32, 0, 26)
    button.Position = UDim2.new(1, xOffset, 0.5, -13)
    button.BackgroundColor3 = Color3.new(1, 1, 1)
    button.BackgroundTransparency = 0.88
    button.TextColor3 = Color3.fromRGB(220, 210, 250)
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.ZIndex = 16
    button.ClipsDescendants = true
    button.AutoButtonColor = false
    button.Parent = titleBar
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

    local buttonGrad = Instance.new("UIGradient")
    buttonGrad.Color = Visual.getAuroraSequence(os.clock())
    buttonGrad.Parent = button

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.88}):Play()
    end)
    button.MouseButton1Click:Connect(function()
        Visual.PlaySound("Click", 0.28, 1)
        Visual.Ripple(button, button.AbsoluteSize.X / 2, button.AbsoluteSize.Y / 2)
        if callback then
            callback()
        end
    end)

    return button, buttonGrad
end

Visual._onClose = nil
local closeButton, closeButtonGrad = makeTitleButton("×", -38, function()
    if Visual._onClose then
        Visual._onClose()
    end
end)
Visual._closeBtn = closeButton
Visual._closeBtnG = closeButtonGrad

local minimizeButton, minimizeButtonGrad = makeTitleButton("—", -74, function()
    minimized = not minimized
    TweenService:Create(mainWindow, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        Size = minimized and UDim2.new(0, windowW, 0, 44) or UDim2.new(0, windowW, 0, windowH)
    }):Play()
end)
Visual._minBtnG = minimizeButtonGrad

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Visual._dragState.drag = true
        Visual._dragState.start = input.Position
        Visual._dragState.pos = mainWindow.Position
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Visual._dragState.drag = false
    end
end)

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -44)
body.Position = UDim2.new(0, 0, 0, 44)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ZIndex = 11
body.Parent = mainWindow

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 36)
tabBar.BackgroundColor3 = Color3.fromRGB(4, 2, 10)
tabBar.BackgroundTransparency = 0.15
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 13
tabBar.Parent = body

local tabIndicator = Instance.new("Frame")
tabIndicator.Size = UDim2.new(0, 0, 0, 2)
tabIndicator.Position = UDim2.new(0, 0, 1, -2)
tabIndicator.BackgroundColor3 = Color3.new(1, 1, 1)
tabIndicator.BorderSizePixel = 0
tabIndicator.ZIndex = 15
tabIndicator.Parent = tabBar
local tabIndicatorGrad = Instance.new("UIGradient")
tabIndicatorGrad.Parent = tabIndicator
Visual._tabIndGrad = tabIndicatorGrad
Visual.tabInd = tabIndicator

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 1, -36)
tabContainer.Position = UDim2.new(0, 0, 0, 36)
tabContainer.BackgroundTransparency = 1
tabContainer.BorderSizePixel = 0
tabContainer.ZIndex = 12
tabContainer.Parent = body

local tabNames = {"Aim", "Trig", "ESP", "Visual", "Target", "Binds", "Cfg", "Patch"}
Visual.TabNames = tabNames

local tabButtons = {}
local tabPages = {}
local activeTab = 1

for i, name in ipairs(tabNames) do
    local page = Instance.new("ScrollingFrame")
    page.Name = "P" .. i
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(80, 50, 160)
    page.ScrollBarImageTransparency = 0.5
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.BorderSizePixel = 0
    page.Visible = (i == 1)
    page.ZIndex = 13
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.Parent = tabContainer

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 16)
    padding.PaddingRight = UDim.new(0, 16)
    padding.PaddingBottom = UDim.new(0, 16)
    padding.Parent = page

    tabPages[i] = page
end

local tabButtonWidth = math.floor(windowW / #tabNames)

local function switchTab(index)
    activeTab = index
    Visual.PlaySound("Click", 0.24, 1.04)
    for i, button in ipairs(tabButtons) do
        TweenService:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
            TextColor3 = (i == index) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 90, 130)
        }):Play()
        tabPages[i].Visible = (i == index)
    end
    TweenService:Create(tabIndicator, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0, (index - 1) * tabButtonWidth + 8, 1, -2),
        Size = UDim2.new(0, tabButtonWidth - 16, 0, 2)
    }):Play()
end

for i, name in ipairs(tabNames) do
    local button = Instance.new("TextButton")
    button.Text = name
    button.Size = UDim2.new(0, tabButtonWidth, 1, 0)
    button.Position = UDim2.new(0, (i - 1) * tabButtonWidth, 0, 0)
    button.BackgroundTransparency = 1
    button.TextColor3 = i == 1 and Color3.new(1, 1, 1) or Color3.fromRGB(100, 90, 130)
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.ZIndex = 15
    button.Parent = tabBar

    button.MouseEnter:Connect(function()
        if activeTab ~= i then
            TweenService:Create(button, TweenInfo.new(0.15), {
                TextColor3 = Color3.fromRGB(200, 190, 240)
            }):Play()
        end
    end)
    button.MouseLeave:Connect(function()
        if activeTab ~= i then
            TweenService:Create(button, TweenInfo.new(0.15), {
                TextColor3 = Color3.fromRGB(100, 90, 130)
            }):Play()
        end
    end)
    button.MouseButton1Click:Connect(function()
        switchTab(i)
    end)

    tabButtons[i] = button
end

tabIndicator.Size = UDim2.new(0, tabButtonWidth - 16, 0, 2)
tabIndicator.Position = UDim2.new(0, 8, 1, -2)

Visual.tBs = tabButtons
Visual.tPs = tabPages
Visual.switchTab = switchTab

local pageOrders = {}
for i = 1, #tabNames do
    pageOrders[i] = 0
end

local function nextOrder(pageIndex)
    pageOrders[pageIndex] = pageOrders[pageIndex] + 1
    return pageOrders[pageIndex]
end

Visual.themeCallbacks = {}
Visual._uiSoundsEnabled = true

local function makeInteractiveSound(button, soundType)
    button.MouseButton1Click:Connect(function()
        if Visual._uiSoundsEnabled then
            Visual.PlaySound(soundType or "Click", 0.22, 1)
        end
    end)
end

function Visual.makeSection(pageIndex, text, C)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 24)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = nextOrder(pageIndex)
    frame.ZIndex = 18
    frame.Parent = tabPages[pageIndex]

    local label = Instance.new("TextLabel")
    label.Text = string.upper(text)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 20
    label.TextColor3 = Visual.getAuroraColor(os.clock(), pageOrders[pageIndex] * 0.3)
    label.Parent = frame

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = Color3.new(1, 1, 1)
    line.BackgroundTransparency = 0.55
    line.BorderSizePixel = 0
    line.ZIndex = 20
    line.Parent = frame

    local lineGrad = Instance.new("UIGradient")
    lineGrad.Color = Visual.getAuroraSequence(os.clock())
    lineGrad.Parent = line

    table.insert(Visual.themeCallbacks, function()
        label.TextColor3 = Visual.getAuroraColor(os.clock(), pageOrders[pageIndex] * 0.3)
        lineGrad.Color = Visual.getAuroraSequence(os.clock())
    end)
end

function Visual.makeToggle(pageIndex, text, key, CFG, C, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(12, 7, 22)
    row.BackgroundTransparency = 0.4
    row.BorderSizePixel = 0
    row.ZIndex = 18
    row.LayoutOrder = nextOrder(pageIndex)
    row.ClipsDescendants = true
    row.Parent = tabPages[pageIndex]
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Text = text
    title.Size = UDim2.new(1, -56, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(220, 210, 250)
    title.TextSize = 11
    title.Font = Enum.Font.GothamSemibold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 20
    title.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 38, 0, 18)
    pill.Position = UDim2.new(1, -46, 0.5, -9)
    pill.BackgroundColor3 = Color3.new(1, 1, 1)
    pill.BackgroundTransparency = CFG[key] and 0.15 or 0.82
    pill.BorderSizePixel = 0
    pill.ZIndex = 20
    pill.Parent = row
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local pillGrad = Instance.new("UIGradient")
    pillGrad.Color = Visual.getAuroraSequence(os.clock())
    pillGrad.Parent = pill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = CFG[key] and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 21
    knob.Parent = pill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}):Play()
    end)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 22
    button.AutoButtonColor = false
    button.Parent = row
    makeInteractiveSound(button, "Toggle")

    button.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        local state = CFG[key]
        local mouse = UserInputService:GetMouseLocation()
        Visual.Ripple(row, mouse.X - row.AbsolutePosition.X, mouse.Y - row.AbsolutePosition.Y)
        TweenService:Create(pill, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            BackgroundTransparency = state and 0.15 or 0.82
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        }):Play()
        if callback then
            callback(state)
        end
    end)

    table.insert(Visual.themeCallbacks, function()
        pillGrad.Color = Visual.getAuroraSequence(os.clock())
    end)
end

function Visual.makeSlider(pageIndex, text, key, minVal, maxVal, step, CFG, C, allConnections)
    allConnections = allConnections or {}

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 40)
    row.BackgroundTransparency = 1
    row.ZIndex = 18
    row.LayoutOrder = nextOrder(pageIndex)
    row.Parent = tabPages[pageIndex]

    local title = Instance.new("TextLabel")
    title.Text = text
    title.Size = UDim2.new(0.55, 0, 0, 14)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(160, 150, 190)
    title.TextSize = 10
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 20
    title.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = step < 1 and string.format("%.2f", CFG[key]) or tostring(math.floor(CFG[key]))
    valueLabel.Size = UDim2.new(0.43, 0, 0, 14)
    valueLabel.Position = UDim2.new(0.55, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 20
    valueLabel.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 5)
    track.Position = UDim2.new(0, 0, 0, 22)
    track.BackgroundColor3 = Color3.fromRGB(20, 12, 35)
    track.BackgroundTransparency = 0.15
    track.BorderSizePixel = 0
    track.ZIndex = 20
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)

    local percent = math.clamp((CFG[key] - minVal) / (maxVal - minVal), 0, 1)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(1, 1, 1)
    fill.BorderSizePixel = 0
    fill.ZIndex = 21
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local fillGrad = Instance.new("UIGradient")
    fillGrad.Color = Visual.getAuroraSequence(os.clock())
    fillGrad.Parent = fill

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(percent, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.BorderSizePixel = 0
    knob.ZIndex = 23
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local knobGrad = Instance.new("UIGradient")
    knobGrad.Color = Visual.getAuroraSequence(os.clock())
    knobGrad.Parent = knob

    local dragging = false

    local function setValue(v)
        if step > 0 then
            v = math.floor(v / step + 0.5) * step
        end
        v = math.clamp(v, minVal, maxVal)
        CFG[key] = v
        local p = math.clamp((v - minVal) / (maxVal - minVal), 0, 1)
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, 0, 0.5, 0)
        valueLabel.Text = step < 1 and string.format("%.2f", v) or tostring(math.floor(v))
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Visual.PlaySound("Click", 0.15, 1.05)
        end
    end)

    table.insert(allConnections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))

    table.insert(allConnections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local width = track.AbsoluteSize.X
            if width > 0 then
                setValue(minVal + math.clamp((input.Position.X - track.AbsolutePosition.X) / width, 0, 1) * (maxVal - minVal))
            end
        end
    end))

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local width = track.AbsoluteSize.X
            if width > 0 then
                setValue(minVal + math.clamp((input.Position.X - track.AbsolutePosition.X) / width, 0, 1) * (maxVal - minVal))
                Visual.PlaySound("Click", 0.15, 1)
            end
        end
    end)

    table.insert(Visual.themeCallbacks, function()
        fillGrad.Color = Visual.getAuroraSequence(os.clock())
        knobGrad.Color = Visual.getAuroraSequence(os.clock())
    end)
end

function Visual.makeCycle(pageIndex, text, options, key, CFG, C, callback)
    local index = CFG[key] or 1

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(12, 7, 22)
    row.BackgroundTransparency = 0.4
    row.BorderSizePixel = 0
    row.ZIndex = 18
    row.LayoutOrder = nextOrder(pageIndex)
    row.ClipsDescendants = true
    row.Parent = tabPages[pageIndex]
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local leftLabel = Instance.new("TextLabel")
    leftLabel.Text = text
    leftLabel.Size = UDim2.new(0.5, 0, 1, 0)
    leftLabel.Position = UDim2.new(0, 12, 0, 0)
    leftLabel.BackgroundTransparency = 1
    leftLabel.TextColor3 = Color3.fromRGB(220, 210, 250)
    leftLabel.TextSize = 11
    leftLabel.Font = Enum.Font.GothamSemibold
    leftLabel.TextXAlignment = Enum.TextXAlignment.Left
    leftLabel.ZIndex = 20
    leftLabel.Parent = row

    local rightLabel = Instance.new("TextLabel")
    rightLabel.Text = tostring(options[index])
    rightLabel.Size = UDim2.new(0.42, 0, 1, 0)
    rightLabel.Position = UDim2.new(0.5, 0, 0, 0)
    rightLabel.BackgroundTransparency = 1
    rightLabel.TextColor3 = Visual.getAuroraColor(os.clock(), 1)
    rightLabel.TextSize = 11
    rightLabel.Font = Enum.Font.GothamBold
    rightLabel.TextXAlignment = Enum.TextXAlignment.Right
    rightLabel.ZIndex = 20
    rightLabel.Parent = row

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}):Play()
    end)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 22
    button.AutoButtonColor = false
    button.Parent = row
    makeInteractiveSound(button, "Click")

    button.MouseButton1Click:Connect(function()
        local mouse = UserInputService:GetMouseLocation()
        Visual.Ripple(row, mouse.X - row.AbsolutePosition.X, mouse.Y - row.AbsolutePosition.Y)
        index = index % #options + 1
        CFG[key] = index
        rightLabel.Text = tostring(options[index])
        rightLabel.TextColor3 = Visual.getAuroraColor(os.clock(), index)
        if callback then
            callback(index)
        end
    end)
end

function Visual.makeRebind(pageIndex, labelText, cfgKey, CFG, C, allConnections)
    allConnections = allConnections or {}

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(12, 7, 22)
    row.BackgroundTransparency = 0.4
    row.BorderSizePixel = 0
    row.ZIndex = 18
    row.LayoutOrder = nextOrder(pageIndex)
    row.ClipsDescendants = true
    row.Parent = tabPages[pageIndex]
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local leftLabel = Instance.new("TextLabel")
    leftLabel.Text = labelText
    leftLabel.Size = UDim2.new(0.5, 0, 1, 0)
    leftLabel.Position = UDim2.new(0, 12, 0, 0)
    leftLabel.BackgroundTransparency = 1
    leftLabel.TextColor3 = Color3.fromRGB(220, 210, 250)
    leftLabel.TextSize = 11
    leftLabel.Font = Enum.Font.GothamSemibold
    leftLabel.TextXAlignment = Enum.TextXAlignment.Left
    leftLabel.ZIndex = 20
    leftLabel.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = "[ " .. tostring(CFG[cfgKey]) .. " ]"
    valueLabel.Size = UDim2.new(0.44, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Visual.getAuroraColor(os.clock(), 0.5)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 20
    valueLabel.Parent = row

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}):Play()
    end)

    local rebinding = false
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 22
    button.AutoButtonColor = false
    button.Parent = row
    makeInteractiveSound(button, "Click")

    button.MouseButton1Click:Connect(function()
        Visual.Ripple(row, row.AbsoluteSize.X / 2, row.AbsoluteSize.Y / 2)
        valueLabel.Text = "..."
        valueLabel.TextColor3 = Color3.fromRGB(255, 210, 100)
        rebinding = true

        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local name = input.KeyCode.Name
                if name ~= "Unknown" then
                    CFG[cfgKey] = name
                    valueLabel.Text = "[ " .. name .. " ]"
                    valueLabel.TextColor3 = Visual.getAuroraColor(os.clock(), 0.5)
                    rebinding = false
                    if connection then
                        connection:Disconnect()
                    end
                end
            end
        end)

        task.delay(5, function()
            if rebinding then
                rebinding = false
                valueLabel.Text = "[ " .. tostring(CFG[cfgKey]) .. " ]"
                valueLabel.TextColor3 = Visual.getAuroraColor(os.clock(), 0.5)
                if connection then
                    connection:Disconnect()
                end
            end
        end)
    end)
end

function Visual.makeInfo(pageIndex, text, C)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, 14)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(100, 90, 130)
    label.TextSize = 9
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 20
    label.LayoutOrder = nextOrder(pageIndex)
    label.Parent = tabPages[pageIndex]
end

function Visual.makeLabel(pageIndex, C)
    local label = Instance.new("TextLabel")
    label.Text = ""
    label.Size = UDim2.new(1, -8, 0, 16)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 180, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 20
    label.LayoutOrder = nextOrder(pageIndex)
    label.Parent = tabPages[pageIndex]
    return label
end

local rageGui = Instance.new("Frame")
rageGui.Size = UDim2.new(0, 320, 0, 300)
rageGui.Position = UDim2.new(0.5, -160, 0.5, -150)
rageGui.BackgroundColor3 = Color3.fromRGB(14, 5, 5)
rageGui.BackgroundTransparency = 0.04
rageGui.BorderSizePixel = 0
rageGui.Visible = false
rageGui.ZIndex = 100
rageGui.ClipsDescendants = true
rageGui.Parent = gui
Instance.new("UICorner", rageGui).CornerRadius = UDim.new(0, 12)

local rageStroke = Instance.new("UIStroke")
rageStroke.Color = Color3.fromRGB(180, 30, 30)
rageStroke.Thickness = 1.5
rageStroke.Transparency = 0.25
rageStroke.Parent = rageGui

local rageTitleBar = Instance.new("Frame")
rageTitleBar.Size = UDim2.new(1, 0, 0, 38)
rageTitleBar.BackgroundColor3 = Color3.fromRGB(20, 6, 6)
rageTitleBar.BackgroundTransparency = 0.1
rageTitleBar.BorderSizePixel = 0
rageTitleBar.ZIndex = 101
rageTitleBar.Parent = rageGui
Instance.new("UICorner", rageTitleBar).CornerRadius = UDim.new(0, 12)

local rageTitle = Instance.new("TextLabel")
rageTitle.Text = "RAGE"
rageTitle.Size = UDim2.new(1, -16, 1, 0)
rageTitle.Position = UDim2.new(0, 14, 0, 0)
rageTitle.BackgroundTransparency = 1
rageTitle.TextColor3 = Color3.fromRGB(255, 70, 70)
rageTitle.TextSize = 13
rageTitle.Font = Enum.Font.GothamBold
rageTitle.TextXAlignment = Enum.TextXAlignment.Left
rageTitle.ZIndex = 102
rageTitle.Parent = rageTitleBar

local rageClose = Instance.new("TextButton")
rageClose.Text = "×"
rageClose.Size = UDim2.new(0, 28, 0, 22)
rageClose.Position = UDim2.new(1, -34, 0.5, -11)
rageClose.BackgroundColor3 = Color3.fromRGB(80, 15, 15)
rageClose.BackgroundTransparency = 0.3
rageClose.TextColor3 = Color3.fromRGB(255, 140, 140)
rageClose.TextSize = 12
rageClose.Font = Enum.Font.GothamBold
rageClose.BorderSizePixel = 0
rageClose.ZIndex = 103
rageClose.AutoButtonColor = false
rageClose.Parent = rageTitleBar
Instance.new("UICorner", rageClose).CornerRadius = UDim.new(0, 6)

rageClose.MouseButton1Click:Connect(function()
    Visual.PlaySound("Close", 0.24, 1)
    TweenService:Create(rageGui, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    task.delay(0.3, function()
        rageGui.Visible = false
    end)
end)

Visual._rageDragState = {drag = false, start = nil, pos = nil}
rageTitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Visual._rageDragState.drag = true
        Visual._rageDragState.start = input.Position
        Visual._rageDragState.pos = rageGui.Position
    end
end)
rageTitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Visual._rageDragState.drag = false
    end
end)

local rageContent = Instance.new("ScrollingFrame")
rageContent.Size = UDim2.new(1, 0, 1, -42)
rageContent.Position = UDim2.new(0, 0, 0, 42)
rageContent.BackgroundTransparency = 1
rageContent.ScrollBarThickness = 2
rageContent.BorderSizePixel = 0
rageContent.ZIndex = 101
rageContent.ScrollingDirection = Enum.ScrollingDirection.Y
rageContent.Parent = rageGui

local rageLayout = Instance.new("UIListLayout")
rageLayout.Padding = UDim.new(0, 4)
rageLayout.SortOrder = Enum.SortOrder.LayoutOrder
rageLayout.Parent = rageContent
rageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    rageContent.CanvasSize = UDim2.new(0, 0, 0, rageLayout.AbsoluteContentSize.Y + 16)
end)

local ragePadding = Instance.new("UIPadding")
ragePadding.PaddingTop = UDim.new(0, 8)
ragePadding.PaddingLeft = UDim.new(0, 12)
ragePadding.PaddingRight = UDim.new(0, 12)
ragePadding.Parent = rageContent

Visual.rageGui = rageGui
Visual.rageContent = rageContent

local rageOrder = 0

function Visual.rageSection(text)
    rageOrder = rageOrder + 1
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = string.upper(text)
    label.TextColor3 = Color3.fromRGB(255, 70, 70)
    label.TextSize = 9
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 102
    label.LayoutOrder = rageOrder
    label.Parent = rageContent
end

function Visual.rageToggle(text, key, CFG, callback)
    rageOrder = rageOrder + 1

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = Color3.fromRGB(25, 10, 10)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.ZIndex = 102
    row.LayoutOrder = rageOrder
    row.ClipsDescendants = true
    row.Parent = rageContent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local title = Instance.new("TextLabel")
    title.Text = text
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(220, 190, 190)
    title.TextSize = 10
    title.Font = Enum.Font.GothamSemibold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 103
    title.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 34, 0, 16)
    pill.Position = UDim2.new(1, -42, 0.5, -8)
    pill.BackgroundColor3 = CFG[key] and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(40, 18, 18)
    pill.BackgroundTransparency = 0.2
    pill.BorderSizePixel = 0
    pill.ZIndex = 103
    pill.Parent = row
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = CFG[key] and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 3, 0.5, -5)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 104
    knob.Parent = pill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 105
    button.AutoButtonColor = false
    button.Parent = row

    button.MouseButton1Click:Connect(function()
        Visual.PlaySound("Toggle", 0.25, 0.95)
        CFG[key] = not CFG[key]
        local state = CFG[key]
        TweenService:Create(pill, TweenInfo.new(0.25), {
            BackgroundColor3 = state and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(40, 18, 18)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
            Position = state and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 3, 0.5, -5)
        }):Play()
        if callback then
            callback(state)
        end
    end)
end

function Visual.rageInfo(text)
    rageOrder = rageOrder + 1
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 12)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(130, 90, 90)
    label.TextSize = 8
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 102
    label.LayoutOrder = rageOrder
    label.Parent = rageContent
end

local rageButton = Instance.new("TextButton")
rageButton.Size = UDim2.new(0, 90, 0, 30)
rageButton.Position = UDim2.new(0, 20, 1, -50)
rageButton.BackgroundColor3 = Color3.fromRGB(110, 14, 14)
rageButton.BackgroundTransparency = 0.1
rageButton.Text = "RAGE"
rageButton.TextColor3 = Color3.fromRGB(255, 90, 90)
rageButton.TextSize = 11
rageButton.Font = Enum.Font.GothamBold
rageButton.BorderSizePixel = 0
rageButton.ZIndex = 50
rageButton.Visible = false
rageButton.AutoButtonColor = false
rageButton.ClipsDescendants = true
rageButton.Parent = gui
Instance.new("UICorner", rageButton).CornerRadius = UDim.new(0, 8)

rageButton.MouseButton1Click:Connect(function()
    Visual.PlaySound("Click", 0.24, 1)
    Visual.Ripple(rageButton, rageButton.AbsoluteSize.X / 2, rageButton.AbsoluteSize.Y / 2)
    if rageGui.Visible then
        TweenService:Create(rageGui, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        task.delay(0.3, function()
            rageGui.Visible = false
        end)
    else
        rageGui.Visible = true
        rageGui.BackgroundTransparency = 1
        TweenService:Create(rageGui, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0.04
        }):Play()
    end
end)
Visual.rageBtn = rageButton

local menuOpen = false
Visual.isOpen = false
local savedMouseBehavior, savedMouseIconEnabled = nil, nil

function Visual.openMenu(CFG)
    menuOpen = true
    Visual.isOpen = true
    mainWindow.Visible = true
    dimOverlay.Visible = true
    rageButton.Visible = true

    windowW, windowH = Visual.getWS(CFG)

    dimOverlay.BackgroundTransparency = 1
    TweenService:Create(dimOverlay, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.45
    }):Play()

    mainWindow.Size = UDim2.new(0, windowW * 0.88, 0, windowH * 0.88)
    mainWindow.Position = UDim2.new(0.5, -windowW * 0.44, 0.5, -windowH * 0.44)
    mainWindow.BackgroundTransparency = 0.5

    TweenService:Create(mainWindow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, windowW, 0, windowH),
        Position = UDim2.new(0.5, -windowW / 2, 0.5, -windowH / 2),
        BackgroundTransparency = 0.02
    }):Play()

    TweenService:Create(blurMain, TweenInfo.new(0.3), {Size = 16}):Play()
    Visual.PlaySound("Open", 0.28, 1)

    pcall(function()
        savedMouseBehavior = UserInputService.MouseBehavior
        savedMouseIconEnabled = UserInputService.MouseIconEnabled
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end)
end

function Visual.closeMenu(CFG)
    menuOpen = false
    Visual.isOpen = false
    rageButton.Visible = false
    if rageGui.Visible then
        rageGui.Visible = false
    end

    TweenService:Create(dimOverlay, TweenInfo.new(0.2), {
        BackgroundTransparency = 1
    }):Play()

    TweenService:Create(mainWindow, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Size = UDim2.new(0, windowW * 0.88, 0, windowH * 0.88),
        BackgroundTransparency = 1
    }):Play()

    TweenService:Create(blurMain, TweenInfo.new(0.2), {Size = 0}):Play()
    Visual.PlaySound("Close", 0.22, 1)

    task.delay(0.3, function()
        if not menuOpen then
            mainWindow.Visible = false
            dimOverlay.Visible = false
        end
    end)

    pcall(function()
        if savedMouseBehavior then
            UserInputService.MouseBehavior = savedMouseBehavior
        end
        if savedMouseIconEnabled ~= nil then
            UserInputService.MouseIconEnabled = savedMouseIconEnabled
        end
    end)
end

local themeTimer = 0

function Visual.updateAnimations(dt, globalT)
    local sequence = Visual.getAuroraSequence(globalT)
    watermarkStrokeGrad.Color = sequence
    watermarkTime.Text = os.date("%H:%M")
    bindsStrokeGrad.Color = sequence

    if not menuOpen then
        return
    end

    auroraBackgroundGrad.Color = sequence
    mainStrokeGrad.Color = sequence
    titleLineGrad.Color = sequence
    tabIndicatorGrad.Color = sequence
    hudStrokeGrad.Color = sequence
    moonButtonGrad.Color = sequence

    if closeButtonGrad then
        closeButtonGrad.Color = sequence
    end
    if minimizeButtonGrad then
        minimizeButtonGrad.Color = sequence
    end

    themeTimer = themeTimer + dt
    if themeTimer > 0.5 then
        themeTimer = 0
        for _, callback in ipairs(Visual.themeCallbacks) do
            pcall(callback)
        end
    end

    for index, star in ipairs(stars) do
        star.BackgroundTransparency = 0.5 + math.sin(globalT * (1 + index * 0.2)) * 0.3
        star.BackgroundColor3 = Visual.getAuroraColor(globalT, index * 0.3)
    end
end

function Visual.handleDrag(inputPos)
    if Visual._dragState.drag and Visual._dragState.start and Visual._dragState.pos then
        local delta = inputPos - Visual._dragState.start
        mainWindow.Position = UDim2.new(
            Visual._dragState.pos.X.Scale, Visual._dragState.pos.X.Offset + delta.X,
            Visual._dragState.pos.Y.Scale, Visual._dragState.pos.Y.Offset + delta.Y
        )
    end

    if Visual._bfDrag.drag and Visual._bfDrag.start and Visual._bfDrag.pos then
        local delta = inputPos - Visual._bfDrag.start
        bindsFrame.Position = UDim2.new(
            Visual._bfDrag.pos.X.Scale, Visual._bfDrag.pos.X.Offset + delta.X,
            Visual._bfDrag.pos.Y.Scale, Visual._bfDrag.pos.Y.Offset + delta.Y
        )
    end

    if Visual._rageDragState.drag and Visual._rageDragState.start and Visual._rageDragState.pos then
        local delta = inputPos - Visual._rageDragState.start
        rageGui.Position = UDim2.new(
            Visual._rageDragState.pos.X.Scale, Visual._rageDragState.pos.X.Offset + delta.X,
            Visual._rageDragState.pos.Y.Scale, Visual._rageDragState.pos.Y.Offset + delta.Y
        )
    end
end

function Visual.destroy()
    pcall(function()
        blurMain:Destroy()
    end)
    pcall(function()
        gui:Destroy()
    end)
    pcall(function()
        screenGui:Destroy()
    end)
end

return Visual
