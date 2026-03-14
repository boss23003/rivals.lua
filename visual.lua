local Visual = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
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
    Color3.fromRGB(60, 180, 255)
}

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
        ColorSequenceKeypoint.new(1, Visual.getAuroraColor(t, 4.8))
    })
end

Visual.SoundIds = {
    Click = "rbxassetid://6895079853",
    Toggle = "rbxassetid://6895079483",
    Open = "rbxassetid://6895078171",
    Close = "rbxassetid://6895078747",
    Notify = "rbxassetid://6895079011",
    Kill = "rbxassetid://6895080427",
    Tab = "rbxassetid://6895079749",
    Rage = "rbxassetid://6895080955"
}

function Visual.PlaySound(name, volume, speed)
    local id = Visual.SoundIds[name]
    if not id then
        return
    end
    local sound = Instance.new("Sound")
    sound.SoundId = id
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
    "MoonOverlay",
    "MoonLoad",
    "MoonGUI_Main",
    "MoonGUI",
    "SakuraGUI_v18",
    "SakuraGUI_v19",
    "SakuraGUI_v20",
    "SakuraGUI"
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

for _, child in ipairs(Lighting:GetChildren()) do
    if child.Name:find("MoonBlur") or child.Name:find("MoonLoadBlur") or child.Name:find("SakuraMainBlur") then
        pcall(function()
            child:Destroy()
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

    local grad = Instance.new("UIGradient")
    grad.Color = Visual.getAuroraSequence(os.clock())
    grad.Rotation = math.random(0, 360)
    grad.Parent = ripple

    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.4
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

local notifyList = Instance.new("Frame")
notifyList.Size = UDim2.new(0, 320, 1, -40)
notifyList.Position = UDim2.new(1, -340, 0, 20)
notifyList.BackgroundTransparency = 1
notifyList.ZIndex = 200
notifyList.Parent = screenGui

local notifyLayout = Instance.new("UIListLayout")
notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifyLayout.Padding = UDim.new(0, 8)
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyLayout.Parent = notifyList

function Visual.Notify(title, text, duration, color)
    duration = duration or 4
    color = color or Visual.getAuroraColor(os.clock())
    Visual.PlaySound("Notify", 0.24, 1.04)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 58)
    frame.BackgroundColor3 = Color3.fromRGB(8, 4, 16)
    frame.BackgroundTransparency = 0.06
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.ZIndex = 201
    frame.Parent = notifyList
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local gradFrame = Instance.new("UIGradient")
    gradFrame.Color = Visual.getAuroraSequence(os.clock())
    gradFrame.Rotation = 18
    gradFrame.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.2
    stroke.Transparency = 0.12
    stroke.Parent = frame
    local strokeGrad = Instance.new("UIGradient")
    strokeGrad.Color = Visual.getAuroraSequence(os.clock())
    strokeGrad.Parent = stroke

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -16, 0, 18)
    titleLabel.Position = UDim2.new(0, 12, 0, 7)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or ""
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 202
    titleLabel.Parent = frame

    local titleTextGrad = Instance.new("UIGradient")
    titleTextGrad.Color = Visual.getAuroraSequence(os.clock())
    titleTextGrad.Parent = titleLabel

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -16, 0, 14)
    descLabel.Position = UDim2.new(0, 12, 0, 28)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = text or ""
    descLabel.TextColor3 = Color3.fromRGB(210, 210, 255)
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 202
    descLabel.Parent = frame

    local descTextGrad = Instance.new("UIGradient")
    descTextGrad.Color = Visual.getAuroraSequence(os.clock())
    descTextGrad.Parent = descLabel

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 2)
    bar.Position = UDim2.new(0, 0, 1, -2)
    bar.BorderSizePixel = 0
    bar.BackgroundColor3 = color
    bar.ZIndex = 202
    bar.Parent = frame
    local barGrad = Instance.new("UIGradient")
    barGrad.Color = Visual.getAuroraSequence(os.clock())
    barGrad.Parent = bar

    frame.Position = UDim2.new(1, 60, 0, 0)
    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    local tween = TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    })
    tween:Play()
    tween.Completed:Connect(function()
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

local watermark = Instance.new("Frame")
watermark.Size = UDim2.new(0, 220, 0, 28)
watermark.Position = UDim2.new(0, 20, 0, 20)
watermark.BackgroundColor3 = Color3.new(1, 1, 1)
watermark.BackgroundTransparency = 0.08
watermark.BorderSizePixel = 0
watermark.ZIndex = 100
watermark.Parent = screenGui
Instance.new("UICorner", watermark).CornerRadius = UDim.new(0, 8)

local watermarkGrad = Instance.new("UIGradient")
watermarkGrad.Color = Visual.getAuroraSequence(os.clock())
watermarkGrad.Rotation = 15
watermarkGrad.Parent = watermark
Visual._wmGrad = watermarkGrad

local watermarkStroke = Instance.new("UIStroke")
watermarkStroke.Thickness = 1
watermarkStroke.Transparency = 0.15
watermarkStroke.Parent = watermark
local watermarkStrokeGrad = Instance.new("UIGradient")
watermarkStrokeGrad.Parent = watermarkStroke
Visual._wmStGrad = watermarkStrokeGrad

local watermarkTitle = Instance.new("TextLabel")
watermarkTitle.Size = UDim2.new(0, 100, 1, 0)
watermarkTitle.Position = UDim2.new(0, 10, 0, 0)
watermarkTitle.BackgroundTransparency = 1
watermarkTitle.Text = "LUNA v2.7"
watermarkTitle.TextColor3 = Color3.new(1, 1, 1)
watermarkTitle.TextSize = 11
watermarkTitle.Font = Enum.Font.GothamBold
watermarkTitle.TextXAlignment = Enum.TextXAlignment.Left
watermarkTitle.ZIndex = 101
watermarkTitle.Parent = watermark
local watermarkTitleGrad = Instance.new("UIGradient")
watermarkTitleGrad.Color = Visual.getAuroraSequence(os.clock())
watermarkTitleGrad.Parent = watermarkTitle
Visual._wmTitleGrad = watermarkTitleGrad

local watermarkTime = Instance.new("TextLabel")
watermarkTime.Size = UDim2.new(0, 90, 1, 0)
watermarkTime.Position = UDim2.new(1, -96, 0, 0)
watermarkTime.BackgroundTransparency = 1
watermarkTime.TextColor3 = Color3.new(1, 1, 1)
watermarkTime.TextSize = 9
watermarkTime.Font = Enum.Font.Code
watermarkTime.TextXAlignment = Enum.TextXAlignment.Right
watermarkTime.ZIndex = 101
watermarkTime.Parent = watermark
local watermarkTimeGrad = Instance.new("UIGradient")
watermarkTimeGrad.Color = Visual.getAuroraSequence(os.clock())
watermarkTimeGrad.Parent = watermarkTime
Visual._wmTimeGrad = watermarkTimeGrad
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
    dim.BackgroundColor3 = Color3.new(1, 1, 1)
    dim.BackgroundTransparency = 0.1
    dim.BorderSizePixel = 0
    dim.Parent = loadGui
    local dimGrad = Instance.new("UIGradient")
    dimGrad.Color = Visual.getAuroraSequence(os.clock())
    dimGrad.Rotation = 30
    dimGrad.Parent = dim

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 360, 0, 108)
    card.Position = UDim2.new(0.5, -180, 0.5, -54)
    card.BackgroundColor3 = Color3.new(1, 1, 1)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.Parent = loadGui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
    local cardGrad = Instance.new("UIGradient")
    cardGrad.Color = Visual.getAuroraSequence(os.clock())
    cardGrad.Rotation = 20
    cardGrad.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Thickness = 1.5
    cardStroke.Transparency = 1
    cardStroke.Parent = card
    local cardStrokeGrad = Instance.new("UIGradient")
    cardStrokeGrad.Parent = cardStroke

    local title = Instance.new("TextLabel")
    title.Text = "LUNA"
    title.Size = UDim2.new(1, 0, 0, 24)
    title.Position = UDim2.new(0, 0, 0, 14)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextTransparency = 1
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = card
    local titleGrad = Instance.new("UIGradient")
    titleGrad.Color = Visual.getAuroraSequence(os.clock())
    titleGrad.Parent = title

    local sub = Instance.new("TextLabel")
    sub.Text = "initializing..."
    sub.Size = UDim2.new(1, 0, 0, 14)
    sub.Position = UDim2.new(0, 0, 0, 44)
    sub.BackgroundTransparency = 1
    sub.TextColor3 = Color3.new(1, 1, 1)
    sub.TextTransparency = 1
    sub.TextSize = 10
    sub.Font = Enum.Font.Gotham
    sub.TextXAlignment = Enum.TextXAlignment.Center
    sub.Parent = card
    local subGrad = Instance.new("UIGradient")
    subGrad.Color = Visual.getAuroraSequence(os.clock())
    subGrad.Parent = sub

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0, 0, 0, 3)
    barBg.Position = UDim2.new(0.5, 0, 0, 72)
    barBg.AnchorPoint = Vector2.new(0.5, 0)
    barBg.BackgroundColor3 = Color3.new(1, 1, 1)
    barBg.BackgroundTransparency = 0.7
    barBg.BorderSizePixel = 0
    barBg.Parent = card
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
    local barBgGrad = Instance.new("UIGradient")
    barBgGrad.Color = Visual.getAuroraSequence(os.clock())
    barBgGrad.Parent = barBg

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.new(1, 1, 1)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
    local barFillGrad = Instance.new("UIGradient")
    barFillGrad.Color = Visual.getAuroraSequence(os.clock())
    barFillGrad.Parent = barFill

    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 18}):Play()
    TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.08}):Play()
    TweenService:Create(cardStroke, TweenInfo.new(0.5), {Transparency = 0.14}):Play()
    TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(sub, TweenInfo.new(0.5), {TextTransparency = 0.15}):Play()
    TweenService:Create(barBg, TweenInfo.new(0.4), {
        Size = UDim2.new(0, 280, 0, 3),
        BackgroundTransparency = 0.45
    }):Play()

    local stages = {
        {10, "mapping"},
        {25, "patching"},
        {45, "injecting"},
        {65, "calibrating"},
        {85, "loading"},
        {100, "ready"}
    }

    task.spawn(function()
        task.wait(0.6)
        for _, stage in ipairs(stages) do
            barFillGrad.Color = Visual.getAuroraSequence(os.clock())
            cardStrokeGrad.Color = Visual.getAuroraSequence(os.clock())
            TweenService:Create(barFill, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Size = UDim2.new(stage[1] / 100, 0, 1, 0)
            }):Play()
            sub.Text = stage[2]
            task.wait(math.random(10, 22) * 0.01)
        end

        sub.Text = "complete"
        sub.TextColor3 = Color3.fromRGB(255, 255, 255)

        task.wait(0.4)
        TweenService:Create(card, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(cardStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(sub, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
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

local fullAurora = Instance.new("Frame")
fullAurora.Size = UDim2.new(1, 0, 1, 0)
fullAurora.BackgroundColor3 = Color3.new(1, 1, 1)
fullAurora.BackgroundTransparency = 1
fullAurora.BorderSizePixel = 0
fullAurora.ZIndex = 7
fullAurora.Visible = false
fullAurora.Parent = gui
local fullAuroraGrad = Instance.new("UIGradient")
fullAuroraGrad.Color = Visual.getAuroraSequence(os.clock())
fullAuroraGrad.Rotation = 30
fullAuroraGrad.Parent = fullAurora
Visual._fullAurora = fullAurora
Visual._fullAuroraGrad = fullAuroraGrad

local dimOverlay = Instance.new("Frame")
dimOverlay.Size = UDim2.new(1, 0, 1, 0)
dimOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
dimOverlay.BackgroundTransparency = 1
dimOverlay.BorderSizePixel = 0
dimOverlay.ZIndex = 8
dimOverlay.Visible = false
dimOverlay.Parent = gui
Visual.dimOverlay = dimOverlay

local moonCanvas = Instance.new("Frame")
moonCanvas.Size = UDim2.new(0, 120, 0, 120)
moonCanvas.Position = UDim2.new(1, -148, 0, 90)
moonCanvas.BackgroundTransparency = 1
moonCanvas.ZIndex = 150
moonCanvas.Visible = false
moonCanvas.Parent = screenGui

local moonOuter = Instance.new("Frame")
moonOuter.Size = UDim2.new(0, 70, 0, 70)
moonOuter.Position = UDim2.new(0.5, -35, 0.5, -35)
moonOuter.BackgroundColor3 = Color3.new(1, 1, 1)
moonOuter.BackgroundTransparency = 0.15
moonOuter.BorderSizePixel = 0
moonOuter.ZIndex = 151
moonOuter.Parent = moonCanvas
Instance.new("UICorner", moonOuter).CornerRadius = UDim.new(1, 0)
local moonOuterGrad = Instance.new("UIGradient")
moonOuterGrad.Color = Visual.getAuroraSequence(os.clock())
moonOuterGrad.Parent = moonOuter
Visual._moonOuterGrad = moonOuterGrad

local moonCut = Instance.new("Frame")
moonCut.Size = UDim2.new(0, 58, 0, 58)
moonCut.Position = UDim2.new(0.5, -18, 0.5, -29)
moonCut.BackgroundColor3 = Color3.fromRGB(6, 3, 12)
moonCut.BackgroundTransparency = 0.05
moonCut.BorderSizePixel = 0
moonCut.ZIndex = 152
moonCut.Parent = moonCanvas
Instance.new("UICorner", moonCut).CornerRadius = UDim.new(1, 0)

Visual.moonCanvas = moonCanvas
Visual.moonOuter = moonOuter

local bindsFrame = Instance.new("Frame")
bindsFrame.Size = UDim2.new(0, 188, 0, 28)
bindsFrame.Position = UDim2.new(1, -210, 0, 56)
bindsFrame.BackgroundColor3 = Color3.new(1, 1, 1)
bindsFrame.BackgroundTransparency = 0.08
bindsFrame.BorderSizePixel = 0
bindsFrame.ZIndex = 100
bindsFrame.ClipsDescendants = true
bindsFrame.Parent = screenGui
Instance.new("UICorner", bindsFrame).CornerRadius = UDim.new(0, 10)

local bindsGrad = Instance.new("UIGradient")
bindsGrad.Color = Visual.getAuroraSequence(os.clock())
bindsGrad.Rotation = 20
bindsGrad.Parent = bindsFrame
Visual._bindsGrad = bindsGrad

local bindsStroke = Instance.new("UIStroke")
bindsStroke.Thickness = 1
bindsStroke.Transparency = 0.15
bindsStroke.Parent = bindsFrame
local bindsStrokeGrad = Instance.new("UIGradient")
bindsStrokeGrad.Parent = bindsStroke
Visual._bfStGrad = bindsStrokeGrad

local bindsTitle = Instance.new("TextLabel")
bindsTitle.Size = UDim2.new(1, -10, 0, 16)
bindsTitle.Position = UDim2.new(0, 8, 0, 4)
bindsTitle.BackgroundTransparency = 1
bindsTitle.Text = "BINDS"
bindsTitle.TextColor3 = Color3.new(1, 1, 1)
bindsTitle.TextSize = 9
bindsTitle.Font = Enum.Font.GothamBold
bindsTitle.TextXAlignment = Enum.TextXAlignment.Left
bindsTitle.ZIndex = 101
bindsTitle.Parent = bindsFrame
local bindsTitleGrad = Instance.new("UIGradient")
bindsTitleGrad.Color = Visual.getAuroraSequence(os.clock())
bindsTitleGrad.Parent = bindsTitle
Visual._bindsTitleGrad = bindsTitleGrad

local bindsContent = Instance.new("Frame")
bindsContent.Size = UDim2.new(1, -10, 1, -22)
bindsContent.Position = UDim2.new(0, 5, 0, 22)
bindsContent.BackgroundTransparency = 1
bindsContent.ZIndex = 101
bindsContent.Parent = bindsFrame

local bindsLayout = Instance.new("UIListLayout")
bindsLayout.Padding = UDim.new(0, 3)
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

Visual._bindsStateCache = {}

function Visual.pushBindEvent(text)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 0)
    row.BackgroundColor3 = Color3.new(1, 1, 1)
    row.BackgroundTransparency = 0.12
    row.BorderSizePixel = 0
    row.ZIndex = 104
    row.ClipsDescendants = true
    row.Parent = bindsContent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local rowGrad = Instance.new("UIGradient")
    rowGrad.Color = Visual.getAuroraSequence(os.clock())
    rowGrad.Rotation = 12
    rowGrad.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTransparency = 1
    label.ZIndex = 105
    label.Parent = row

    local labelGrad = Instance.new("UIGradient")
    labelGrad.Color = Visual.getAuroraSequence(os.clock())
    labelGrad.Parent = label

    TweenService:Create(row, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, 22)
    }):Play()
    TweenService:Create(label, TweenInfo.new(0.24), {
        TextTransparency = 0
    }):Play()

    task.delay(2.1, function()
        TweenService:Create(label, TweenInfo.new(0.2), {
            TextTransparency = 1
        }):Play()
        local outTween = TweenService:Create(row, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        })
        outTween:Play()
        outTween.Completed:Connect(function()
            pcall(function()
                row:Destroy()
            end)
        end)
    end)
end

function Visual.updateActiveBinds(CFG, C, aimActive, targetActive, spinActive, rageMode)
    local stateMap = {
        {"Aimbot", CFG.Enabled, "aim " .. (CFG.Enabled and "on" or "off") .. " (" .. tostring(CFG.AimKey or "?") .. ")"},
        {"Locking", aimActive, "aim lock (" .. tostring(CFG.AimKey or "?") .. ")"},
        {"Target", targetActive, "target on (" .. tostring(CFG.TargetKey or "?") .. ")"},
        {"Spin", spinActive, "spin on (" .. tostring(CFG.AimKey or "?") .. ")"},
        {"Triggerbot", CFG.Triggerbot, "trigger on"},
        {"ESP", CFG.ShowESP, "esp on"},
        {"Dash", CFG.DashEnabled, "dash ready (" .. tostring(CFG.DashKey or "?") .. ")"},
        {"Rage", rageMode, rageMode and "rage mode enabled" or "rage mode disabled"},
        {"R.Dash", CFG.RageDash, "rage dash on"},
        {"R.Target", CFG.RageTarget, "rage target on"}
    }

    for _, item in ipairs(stateMap) do
        local cacheKey = item[1]
        local current = item[2]
        if Visual._bindsStateCache[cacheKey] == nil then
            Visual._bindsStateCache[cacheKey] = current
        elseif Visual._bindsStateCache[cacheKey] ~= current then
            Visual._bindsStateCache[cacheKey] = current
            if current then
                Visual.pushBindEvent(item[3])
            end
        end
    end

    for _, child in ipairs(bindsContent:GetChildren()) do
        if child:IsA("Frame") and child.Name == "BindStateRow" then
            child:Destroy()
        end
    end

    local items = {}
    local function add(name, active, keyText)
        table.insert(items, {n = name, a = active, k = keyText or ""})
    end

    add("Aimbot", CFG.Enabled, CFG.AimKey)
    if aimActive then add("Locking", true, CFG.AimKey) end
    if targetActive then add("Target", true, CFG.TargetKey) end
    if spinActive then add("Spin", true, CFG.AimKey) end
    add("Trigger", CFG.Triggerbot, "")
    add("ESP", CFG.ShowESP, "")
    add("Dash", CFG.DashEnabled, CFG.DashKey)
    if rageMode then add("Rage", true, "") end
    if CFG.RageDash then add("R.Dash", true, "") end
    if CFG.RageTarget then add("R.Target", true, "") end

    local baseOrder = 1000
    for index, item in ipairs(items) do
        local row = Instance.new("Frame")
        row.Name = "BindStateRow"
        row.Size = UDim2.new(1, 0, 0, 18)
        row.BackgroundColor3 = Color3.new(1, 1, 1)
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        row.ZIndex = 102
        row.LayoutOrder = baseOrder + index
        row.Parent = bindsContent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

        local rowGrad = Instance.new("UIGradient")
        rowGrad.Color = Visual.getAuroraSequence(os.clock() + index)
        rowGrad.Rotation = 25
        rowGrad.Parent = row

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        local displayText = item.n
        if item.k ~= "" then
            displayText = item.n .. " (" .. item.k .. ")"
        end
        label.Text = displayText
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 9
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 103
        label.Parent = row
        local labelGrad = Instance.new("UIGradient")
        labelGrad.Color = Visual.getAuroraSequence(os.clock() + index * 0.2)
        labelGrad.Parent = label
    end

    local height = math.max(28 + #items * 21, 28)
    bindsFrame.Size = UDim2.new(0, 188, 0, math.min(height + 8, 220))
end

Visual.bindsFrame = bindsFrame

local HUD_MAX = 18
local hudFrame = Instance.new("Frame")
hudFrame.Size = UDim2.new(0, 220, 0, 180)
hudFrame.Position = UDim2.new(0, 20, 0.5, -90)
hudFrame.BackgroundColor3 = Color3.new(1, 1, 1)
hudFrame.BackgroundTransparency = 0.12
hudFrame.BorderSizePixel = 0
hudFrame.ZIndex = 5
hudFrame.Visible = false
hudFrame.ClipsDescendants = true
hudFrame.Parent = gui
Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0, 10)
local hudGrad = Instance.new("UIGradient")
hudGrad.Color = Visual.getAuroraSequence(os.clock())
hudGrad.Rotation = 15
hudGrad.Parent = hudFrame
Visual._hudGrad = hudGrad

local hudStroke = Instance.new("UIStroke")
hudStroke.Thickness = 1
hudStroke.Transparency = 0.18
hudStroke.Parent = hudFrame
local hudStrokeGrad = Instance.new("UIGradient")
hudStrokeGrad.Parent = hudStroke
Visual._hudStGrad = hudStrokeGrad

local hudLayout = Instance.new("UIListLayout")
hudLayout.Padding = UDim.new(0, 2)
hudLayout.Parent = hudFrame

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
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Parent = hudFrame
    local labelGrad = Instance.new("UIGradient")
    labelGrad.Color = Visual.getAuroraSequence(os.clock() + i * 0.1)
    labelGrad.Parent = label
    hudLabels[i] = label
end
Visual.hudFrame = hudFrame
Visual.hudT = hudLabels
Visual.HUD_MAX = HUD_MAX

local WIN_MODES = {
    {w = 860, h = 580},
    {w = 680, h = 460},
    {w = 1120, h = 700}
}
Visual.WIN_MODES = WIN_MODES

function Visual.getWS(CFG)
    local mode = WIN_MODES[CFG.WindowMode] or WIN_MODES[1]
    return mode.w, mode.h
end

local windowW, windowH = 860, 580

local mainWindow = Instance.new("Frame")
mainWindow.Name = "W"
mainWindow.Size = UDim2.new(0, windowW, 0, windowH)
mainWindow.Position = UDim2.new(0.5, -windowW / 2, 0.5, -windowH / 2)
mainWindow.BackgroundColor3 = Color3.new(1, 1, 1)
mainWindow.BackgroundTransparency = 0.06
mainWindow.BorderSizePixel = 0
mainWindow.Visible = false
mainWindow.ZIndex = 10
mainWindow.ClipsDescendants = true
mainWindow.Parent = gui
Instance.new("UICorner", mainWindow).CornerRadius = UDim.new(0, 14)

local mainGrad = Instance.new("UIGradient")
mainGrad.Color = Visual.getAuroraSequence(os.clock())
mainGrad.Rotation = 20
mainGrad.Parent = mainWindow
Visual._mainGrad = mainGrad

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.08
mainStroke.Parent = mainWindow
local mainStrokeGrad = Instance.new("UIGradient")
mainStrokeGrad.Parent = mainStroke
Visual._gStGrad = mainStrokeGrad
Visual.W = mainWindow
Visual.gSt = mainStroke

local rageOverlay = Instance.new("Frame")
rageOverlay.Size = UDim2.new(1, 0, 1, 0)
rageOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
rageOverlay.BackgroundTransparency = 1
rageOverlay.BorderSizePixel = 0
rageOverlay.ZIndex = 10
rageOverlay.Parent = mainWindow
local rageOverlayGrad = Instance.new("UIGradient")
rageOverlayGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 90)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 50, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 120))
})
rageOverlayGrad.Rotation = 45
rageOverlayGrad.Parent = rageOverlay
Visual._rageOverlay = rageOverlay

local stars = {}
for i = 1, 24 do
    local star = Instance.new("Frame")
    local size = math.random(1, 2)
    star.Size = UDim2.new(0, size, 0, size)
    star.Position = UDim2.new(0, math.random(10, windowW - 10), 0, math.random(60, windowH - 10))
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
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.BackgroundColor3 = Color3.new(1, 1, 1)
titleBar.BackgroundTransparency = 0.12
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 12
titleBar.Parent = mainWindow
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)
local titleBarGrad = Instance.new("UIGradient")
titleBarGrad.Color = Visual.getAuroraSequence(os.clock())
titleBarGrad.Rotation = 20
titleBarGrad.Parent = titleBar
Visual._titleBarGrad = titleBarGrad
Visual.tB = titleBar

local titleLine = Instance.new("Frame")
titleLine.Size = UDim2.new(1, 0, 0, 2)
titleLine.Position = UDim2.new(0, 0, 1, -2)
titleLine.BackgroundColor3 = Color3.new(1, 1, 1)
titleLine.BackgroundTransparency = 0.08
titleLine.BorderSizePixel = 0
titleLine.ZIndex = 14
titleLine.Parent = titleBar
local titleLineGrad = Instance.new("UIGradient")
titleLineGrad.Parent = titleLine
Visual._tLGrad = titleLineGrad

local moonButton = Instance.new("Frame")
moonButton.Size = UDim2.new(0, 96, 0, 30)
moonButton.Position = UDim2.new(0, 10, 0.5, -15)
moonButton.BackgroundColor3 = Color3.new(1, 1, 1)
moonButton.BackgroundTransparency = 0.08
moonButton.BorderSizePixel = 0
moonButton.ZIndex = 15
moonButton.ClipsDescendants = true
moonButton.Parent = titleBar
Instance.new("UICorner", moonButton).CornerRadius = UDim.new(0, 8)
local moonButtonGrad = Instance.new("UIGradient")
moonButtonGrad.Color = Visual.getAuroraSequence(os.clock())
moonButtonGrad.Parent = moonButton
Visual._moonBtnGrad = moonButtonGrad

local moonButtonText = Instance.new("TextLabel")
moonButtonText.Size = UDim2.new(1, 0, 1, 0)
moonButtonText.BackgroundTransparency = 1
moonButtonText.Text = "LUNA"
moonButtonText.TextColor3 = Color3.new(1, 1, 1)
moonButtonText.TextSize = 13
moonButtonText.Font = Enum.Font.GothamBold
moonButtonText.ZIndex = 16
moonButtonText.Parent = moonButton
local moonButtonTextGrad = Instance.new("UIGradient")
moonButtonTextGrad.Color = Visual.getAuroraSequence(os.clock())
moonButtonTextGrad.Parent = moonButtonText
Visual._moonBtnTxtGrad = moonButtonTextGrad
Visual.moonBtnTxt = moonButtonText

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "OFF"
statusLabel.Size = UDim2.new(0, 62, 0, 24)
statusLabel.Position = UDim2.new(0, 116, 0.5, -12)
statusLabel.BackgroundColor3 = Color3.new(1, 1, 1)
statusLabel.BackgroundTransparency = 0.08
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextSize = 10
statusLabel.Font = Enum.Font.GothamBold
statusLabel.BorderSizePixel = 0
statusLabel.ZIndex = 15
statusLabel.Parent = titleBar
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 6)
local statusGrad = Instance.new("UIGradient")
statusGrad.Color = Visual.getAuroraSequence(os.clock())
statusGrad.Parent = statusLabel
Visual._statusGrad = statusGrad
Visual.guiStatus = statusLabel

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Text = "60"
fpsLabel.Size = UDim2.new(0, 54, 0, 14)
fpsLabel.Position = UDim2.new(0, 188, 0.5, -7)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.new(1, 1, 1)
fpsLabel.TextSize = 9
fpsLabel.Font = Enum.Font.Code
fpsLabel.ZIndex = 15
fpsLabel.Parent = titleBar
local fpsGrad = Instance.new("UIGradient")
fpsGrad.Color = Visual.getAuroraSequence(os.clock())
fpsGrad.Parent = fpsLabel
Visual._fpsGrad = fpsGrad
Visual.guiFPS = fpsLabel

local killsLabel = Instance.new("TextLabel")
killsLabel.Text = "0 kills"
killsLabel.Size = UDim2.new(0, 60, 0, 14)
killsLabel.Position = UDim2.new(0, 246, 0.5, -7)
killsLabel.BackgroundTransparency = 1
killsLabel.TextColor3 = Color3.new(1, 1, 1)
killsLabel.TextSize = 9
killsLabel.Font = Enum.Font.Code
killsLabel.ZIndex = 15
killsLabel.Parent = titleBar
local killsGrad = Instance.new("UIGradient")
killsGrad.Color = Visual.getAuroraSequence(os.clock())
killsGrad.Parent = killsLabel
Visual._killsGrad = killsGrad
Visual.guiKills = killsLabel

local rageButton = Instance.new("TextButton")
rageButton.Size = UDim2.new(0, 98, 0, 28)
rageButton.Position = UDim2.new(0, 18, 1, -50)
rageButton.BackgroundColor3 = Color3.new(1, 1, 1)
rageButton.BackgroundTransparency = 0.08
rageButton.Text = "RAGE"
rageButton.TextColor3 = Color3.new(1, 1, 1)
rageButton.TextSize = 11
rageButton.Font = Enum.Font.GothamBold
rageButton.BorderSizePixel = 0
rageButton.ZIndex = 50
rageButton.Visible = true
rageButton.AutoButtonColor = false
rageButton.ClipsDescendants = true
rageButton.Parent = gui
Instance.new("UICorner", rageButton).CornerRadius = UDim.new(0, 8)
local rageButtonGrad = Instance.new("UIGradient")
rageButtonGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 90)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 50, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 120))
})
rageButtonGrad.Rotation = 20
rageButtonGrad.Parent = rageButton
Visual.rageBtn = rageButton
Visual._rageBtnGrad = rageButtonGrad

local minimized = false
Visual._dragState = {drag = false, start = nil, pos = nil}
Visual._onClose = nil
Visual._onRageToggle = nil

local function makeTitleButton(text, xOffset, callback)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(0, 32, 0, 26)
    button.Position = UDim2.new(1, xOffset, 0.5, -13)
    button.BackgroundColor3 = Color3.new(1, 1, 1)
    button.BackgroundTransparency = 0.08
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.ZIndex = 16
    button.ClipsDescendants = true
    button.AutoButtonColor = false
    button.Parent = titleBar
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

    local grad = Instance.new("UIGradient")
    grad.Color = Visual.getAuroraSequence(os.clock())
    grad.Parent = button

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.0}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.08}):Play()
    end)
    button.MouseButton1Click:Connect(function()
        Visual.PlaySound("Click", 0.25, 1)
        Visual.Ripple(button, button.AbsoluteSize.X / 2, button.AbsoluteSize.Y / 2)
        if callback then
            callback()
        end
    end)

    return button, grad
end

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
        Size = minimized and UDim2.new(0, windowW, 0, 48) or UDim2.new(0, windowW, 0, windowH)
    }):Play()
end)
Visual._minBtnG = minimizeButtonGrad

rageButton.MouseEnter:Connect(function()
    TweenService:Create(rageButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.0}):Play()
end)
rageButton.MouseLeave:Connect(function()
    TweenService:Create(rageButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.08}):Play()
end)
rageButton.MouseButton1Click:Connect(function()
    Visual.PlaySound("Rage", 0.28, 1)
    Visual.Ripple(rageButton, rageButton.AbsoluteSize.X / 2, rageButton.AbsoluteSize.Y / 2)
    if Visual._onRageToggle then
        Visual._onRageToggle()
    end
end)

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
body.Size = UDim2.new(1, 0, 1, -48)
body.Position = UDim2.new(0, 0, 0, 48)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ZIndex = 11
body.Parent = mainWindow

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 36)
tabBar.BackgroundColor3 = Color3.new(1, 1, 1)
tabBar.BackgroundTransparency = 0.12
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 13
tabBar.Parent = body
local tabBarGrad = Instance.new("UIGradient")
tabBarGrad.Color = Visual.getAuroraSequence(os.clock())
tabBarGrad.Rotation = 10
tabBarGrad.Parent = tabBar
Visual._tabBarGrad = tabBarGrad

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

Visual.NormalTabs = {"Combat", "Visual", "Binds", "Cfg", "Patch"}
Visual.RageTabs = {"Combat", "Visual", "Target", "Binds", "Cfg", "Patch"}

local tabButtons = {}
local tabPages = {}
local pageOrders = {}
local activeTab = 1
local currentTabs = {}
local isRageMode = false

for i = 1, 6 do
    local page = Instance.new("ScrollingFrame")
    page.Name = "P" .. i
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    page.ScrollBarImageTransparency = 0.35
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.BorderSizePixel = 0
    page.Visible = false
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
    pageOrders[i] = 0
end

local function nextOrder(pageIndex)
    pageOrders[pageIndex] = pageOrders[pageIndex] + 1
    return pageOrders[pageIndex]
end

Visual.themeCallbacks = {}
Visual._uiSoundsEnabled = true

local function bindClick(button, soundType)
    button.MouseButton1Click:Connect(function()
        if Visual._uiSoundsEnabled then
            Visual.PlaySound(soundType or "Click", 0.22, 1)
        end
    end)
end

function Visual.getMappedPage(tabIndex, rageMode)
    if rageMode then
        return tabIndex
    end
    if tabIndex <= 2 then
        return tabIndex
    end
    if tabIndex == 3 then
        return 4
    end
    if tabIndex == 4 then
        return 5
    end
    return 6
end

local function refreshTabButtons()
    for _, button in ipairs(tabButtons) do
        if button then
            button:Destroy()
        end
    end
    table.clear(tabButtons)

    currentTabs = isRageMode and Visual.RageTabs or Visual.NormalTabs
    Visual.TabNames = currentTabs

    local count = #currentTabs
    local width = math.floor(windowW / count)

    for i, name in ipairs(currentTabs) do
        local button = Instance.new("TextButton")
        button.Text = name
        button.Size = UDim2.new(0, width, 1, 0)
        button.Position = UDim2.new(0, (i - 1) * width, 0, 0)
        button.BackgroundTransparency = 1
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 11
        button.Font = Enum.Font.GothamBold
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.ZIndex = 15
        button.Parent = tabBar

        local textGrad = Instance.new("UIGradient")
        textGrad.Color = Visual.getAuroraSequence(os.clock() + i * 0.2)
        textGrad.Parent = button

        button.MouseEnter:Connect(function()
            if activeTab ~= i then
                TweenService:Create(button, TweenInfo.new(0.15), {
                    TextTransparency = 0.1
                }):Play()
            end
        end)

        button.MouseLeave:Connect(function()
            if activeTab ~= i then
                TweenService:Create(button, TweenInfo.new(0.15), {
                    TextTransparency = 0.35
                }):Play()
            end
        end)

        button.MouseButton1Click:Connect(function()
            Visual.PlaySound("Tab", 0.22, 1.02)
            activeTab = i

            for pageIndex = 1, 6 do
                tabPages[pageIndex].Visible = false
            end

            local mappedPage = Visual.getMappedPage(i, isRageMode)
            tabPages[mappedPage].Visible = true

            for bIndex, b in ipairs(tabButtons) do
                TweenService:Create(b, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                    TextTransparency = (bIndex == i) and 0 or 0.35
                }):Play()
            end

            TweenService:Create(tabIndicator, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
                Position = UDim2.new(0, (i - 1) * width + 8, 1, -2),
                Size = UDim2.new(0, width - 16, 0, 2)
            }):Play()
        end)

        button.TextTransparency = i == activeTab and 0 or 0.35
        tabButtons[i] = button
    end

    for pageIndex = 1, 6 do
        tabPages[pageIndex].Visible = false
    end
    local mappedPage = Visual.getMappedPage(activeTab, isRageMode)
    tabPages[mappedPage].Visible = true

    tabIndicator.Size = UDim2.new(0, width - 16, 0, 2)
    tabIndicator.Position = UDim2.new(0, (activeTab - 1) * width + 8, 1, -2)
end

function Visual.setRageMode(state)
    state = not not state
    isRageMode = state
    Visual.isRageMode = state

    TweenService:Create(rageOverlay, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        BackgroundTransparency = state and 0.88 or 1
    }):Play()

    TweenService:Create(fullAurora, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        BackgroundTransparency = state and 0.18 or 0.32
    }):Play()

    rageButton.Text = state and "RAGE ON" or "RAGE"
    moonButtonText.Text = state and "LUNA R" or "LUNA"

    if activeTab > #(state and Visual.RageTabs or Visual.NormalTabs) then
        activeTab = 1
    end

    refreshTabButtons()
end

Visual.tPs = tabPages
Visual.tBs = tabButtons
Visual.refreshTabs = refreshTabButtons
refreshTabButtons()

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
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Parent = frame

    local labelGrad = Instance.new("UIGradient")
    labelGrad.Color = Visual.getAuroraSequence(os.clock() + pageOrders[pageIndex] * 0.2)
    labelGrad.Parent = label

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = Color3.new(1, 1, 1)
    line.BackgroundTransparency = 0.4
    line.BorderSizePixel = 0
    line.ZIndex = 20
    line.Parent = frame

    local lineGrad = Instance.new("UIGradient")
    lineGrad.Color = Visual.getAuroraSequence(os.clock())
    lineGrad.Parent = line

    table.insert(Visual.themeCallbacks, function()
        labelGrad.Color = Visual.getAuroraSequence(os.clock() + pageOrders[pageIndex] * 0.2)
        lineGrad.Color = Visual.getAuroraSequence(os.clock())
    end)
end

function Visual.makeToggle(pageIndex, text, key, CFG, C, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 34)
    row.BackgroundColor3 = Color3.new(1, 1, 1)
    row.BackgroundTransparency = 0.12
    row.BorderSizePixel = 0
    row.ZIndex = 18
    row.LayoutOrder = nextOrder(pageIndex)
    row.ClipsDescendants = true
    row.Parent = tabPages[pageIndex]
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local rowGrad = Instance.new("UIGradient")
    rowGrad.Color = Visual.getAuroraSequence(os.clock())
    rowGrad.Rotation = 16
    rowGrad.Parent = row

    local title = Instance.new("TextLabel")
    title.Text = text
    title.Size = UDim2.new(1, -56, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 11
    title.Font = Enum.Font.GothamSemibold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 20
    title.Parent = row
    local titleGrad = Instance.new("UIGradient")
    titleGrad.Color = Visual.getAuroraSequence(os.clock())
    titleGrad.Parent = title

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 38, 0, 18)
    pill.Position = UDim2.new(1, -46, 0.5, -9)
    pill.BackgroundColor3 = Color3.new(1, 1, 1)
    pill.BackgroundTransparency = CFG[key] and 0.05 or 0.45
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
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.04}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.12}):Play()
    end)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 22
    button.AutoButtonColor = false
    button.Parent = row
    bindClick(button, "Toggle")

    button.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        local state = CFG[key]
        local mouse = UserInputService:GetMouseLocation()
        Visual.Ripple(row, mouse.X - row.AbsolutePosition.X, mouse.Y - row.AbsolutePosition.Y)
        TweenService:Create(pill, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            BackgroundTransparency = state and 0.05 or 0.45
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        }):Play()
        if callback then
            callback(state)
        end
    end)

    table.insert(Visual.themeCallbacks, function()
        rowGrad.Color = Visual.getAuroraSequence(os.clock())
        pillGrad.Color = Visual.getAuroraSequence(os.clock())
        titleGrad.Color = Visual.getAuroraSequence(os.clock())
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
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 10
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 20
    title.Parent = row
    local titleGrad = Instance.new("UIGradient")
    titleGrad.Color = Visual.getAuroraSequence(os.clock())
    titleGrad.Parent = title

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = step < 1 and string.format("%.2f", CFG[key]) or tostring(math.floor(CFG[key]))
    valueLabel.Size = UDim2.new(0.43, 0, 0, 14)
    valueLabel.Position = UDim2.new(0.55, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.new(1, 1, 1)
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 20
    valueLabel.Parent = row
    local valueGrad = Instance.new("UIGradient")
    valueGrad.Color = Visual.getAuroraSequence(os.clock())
    valueGrad.Parent = valueLabel

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 5)
    track.Position = UDim2.new(0, 0, 0, 22)
    track.BackgroundColor3 = Color3.new(1, 1, 1)
    track.BackgroundTransparency = 0.55
    track.BorderSizePixel = 0
    track.ZIndex = 20
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)
    local trackGrad = Instance.new("UIGradient")
    trackGrad.Color = Visual.getAuroraSequence(os.clock())
    trackGrad.Parent = track

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
    end))

    table.insert(Visual.themeCallbacks, function()
        titleGrad.Color = Visual.getAuroraSequence(os.clock())
        valueGrad.Color = Visual.getAuroraSequence(os.clock())
        trackGrad.Color = Visual.getAuroraSequence(os.clock())
        fillGrad.Color = Visual.getAuroraSequence(os.clock())
        knobGrad.Color = Visual.getAuroraSequence(os.clock())
    end)
end

function Visual.makeCycle(pageIndex, text, options, key, CFG, C, callback)
    local index = CFG[key] or 1

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 34)
    row.BackgroundColor3 = Color3.new(1, 1, 1)
    row.BackgroundTransparency = 0.12
    row.BorderSizePixel = 0
    row.ZIndex = 18
    row.LayoutOrder = nextOrder(pageIndex)
    row.ClipsDescendants = true
    row.Parent = tabPages[pageIndex]
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local rowGrad = Instance.new("UIGradient")
    rowGrad.Color = Visual.getAuroraSequence(os.clock())
    rowGrad.Parent = row

    local leftLabel = Instance.new("TextLabel")
    leftLabel.Text = text
    leftLabel.Size = UDim2.new(0.5, 0, 1, 0)
    leftLabel.Position = UDim2.new(0, 12, 0, 0)
    leftLabel.BackgroundTransparency = 1
    leftLabel.TextColor3 = Color3.new(1, 1, 1)
    leftLabel.TextSize = 11
    leftLabel.Font = Enum.Font.GothamSemibold
    leftLabel.TextXAlignment = Enum.TextXAlignment.Left
    leftLabel.ZIndex = 20
    leftLabel.Parent = row
    local leftGrad = Instance.new("UIGradient")
    leftGrad.Color = Visual.getAuroraSequence(os.clock())
    leftGrad.Parent = leftLabel

    local rightLabel = Instance.new("TextLabel")
    rightLabel.Text = tostring(options[index])
    rightLabel.Size = UDim2.new(0.42, 0, 1, 0)
    rightLabel.Position = UDim2.new(0.5, 0, 0, 0)
    rightLabel.BackgroundTransparency = 1
    rightLabel.TextColor3 = Color3.new(1, 1, 1)
    rightLabel.TextSize = 11
    rightLabel.Font = Enum.Font.GothamBold
    rightLabel.TextXAlignment = Enum.TextXAlignment.Right
    rightLabel.ZIndex = 20
    rightLabel.Parent = row
    local rightGrad = Instance.new("UIGradient")
    rightGrad.Color = Visual.getAuroraSequence(os.clock())
    rightGrad.Parent = rightLabel

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.04}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.12}):Play()
    end)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 22
    button.AutoButtonColor = false
    button.Parent = row
    bindClick(button, "Click")

    button.MouseButton1Click:Connect(function()
        local mouse = UserInputService:GetMouseLocation()
        Visual.Ripple(row, mouse.X - row.AbsolutePosition.X, mouse.Y - row.AbsolutePosition.Y)
        index = index % #options + 1
        CFG[key] = index
        rightLabel.Text = tostring(options[index])
        if callback then
            callback(index)
        end
    end)

    table.insert(Visual.themeCallbacks, function()
        rowGrad.Color = Visual.getAuroraSequence(os.clock())
        leftGrad.Color = Visual.getAuroraSequence(os.clock())
        rightGrad.Color = Visual.getAuroraSequence(os.clock())
    end)
end

function Visual.makeRebind(pageIndex, labelText, cfgKey, CFG, C, allConnections)
    allConnections = allConnections or {}

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 34)
    row.BackgroundColor3 = Color3.new(1, 1, 1)
    row.BackgroundTransparency = 0.12
    row.BorderSizePixel = 0
    row.ZIndex = 18
    row.LayoutOrder = nextOrder(pageIndex)
    row.ClipsDescendants = true
    row.Parent = tabPages[pageIndex]
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local rowGrad = Instance.new("UIGradient")
    rowGrad.Color = Visual.getAuroraSequence(os.clock())
    rowGrad.Parent = row

    local leftLabel = Instance.new("TextLabel")
    leftLabel.Text = labelText
    leftLabel.Size = UDim2.new(0.5, 0, 1, 0)
    leftLabel.Position = UDim2.new(0, 12, 0, 0)
    leftLabel.BackgroundTransparency = 1
    leftLabel.TextColor3 = Color3.new(1, 1, 1)
    leftLabel.TextSize = 11
    leftLabel.Font = Enum.Font.GothamSemibold
    leftLabel.TextXAlignment = Enum.TextXAlignment.Left
    leftLabel.ZIndex = 20
    leftLabel.Parent = row
    local leftGrad = Instance.new("UIGradient")
    leftGrad.Color = Visual.getAuroraSequence(os.clock())
    leftGrad.Parent = leftLabel

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = "[ " .. tostring(CFG[cfgKey]) .. " ]"
    valueLabel.Size = UDim2.new(0.44, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.new(1, 1, 1)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 20
    valueLabel.Parent = row
    local valueGrad = Instance.new("UIGradient")
    valueGrad.Color = Visual.getAuroraSequence(os.clock())
    valueGrad.Parent = valueLabel

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.04}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency = 0.12}):Play()
    end)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 22
    button.AutoButtonColor = false
    button.Parent = row
    bindClick(button, "Click")

    button.MouseButton1Click:Connect(function()
        Visual.Ripple(row, row.AbsoluteSize.X / 2, row.AbsoluteSize.Y / 2)
        valueLabel.Text = "..."
        local rebinding = true

        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local name = input.KeyCode.Name
                if name ~= "Unknown" then
                    CFG[cfgKey] = name
                    valueLabel.Text = "[ " .. name .. " ]"
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
                if connection then
                    connection:Disconnect()
                end
            end
        end)
    end)

    table.insert(Visual.themeCallbacks, function()
        rowGrad.Color = Visual.getAuroraSequence(os.clock())
        leftGrad.Color = Visual.getAuroraSequence(os.clock())
        valueGrad.Color = Visual.getAuroraSequence(os.clock())
    end)
end

function Visual.makeInfo(pageIndex, text, C)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, 14)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 9
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 20
    label.LayoutOrder = nextOrder(pageIndex)
    label.Parent = tabPages[pageIndex]
    local grad = Instance.new("UIGradient")
    grad.Color = Visual.getAuroraSequence(os.clock())
    grad.Parent = label
    table.insert(Visual.themeCallbacks, function()
        grad.Color = Visual.getAuroraSequence(os.clock())
    end)
end

function Visual.makeLabel(pageIndex, C)
    local label = Instance.new("TextLabel")
    label.Text = ""
    label.Size = UDim2.new(1, -8, 0, 16)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 20
    label.LayoutOrder = nextOrder(pageIndex)
    label.Parent = tabPages[pageIndex]
    local grad = Instance.new("UIGradient")
    grad.Color = Visual.getAuroraSequence(os.clock())
    grad.Parent = label
    table.insert(Visual.themeCallbacks, function()
        grad.Color = Visual.getAuroraSequence(os.clock())
    end)
    return label
end

local menuOpen = false
Visual.isOpen = false
Visual.isRageMode = false
local savedMouseBehavior = nil
local savedMouseIconEnabled = nil

function Visual.openMenu(CFG)
    menuOpen = true
    Visual.isOpen = true

    mainWindow.Visible = true
    dimOverlay.Visible = true
    fullAurora.Visible = true
    moonCanvas.Visible = true
    rageButton.Visible = true

    windowW, windowH = Visual.getWS(CFG)

    dimOverlay.BackgroundTransparency = 1
    fullAurora.BackgroundTransparency = 1

    TweenService:Create(dimOverlay, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.75
    }):Play()
    TweenService:Create(fullAurora, TweenInfo.new(0.35), {
        BackgroundTransparency = 0.32
    }):Play()

    mainWindow.Size = UDim2.new(0, windowW * 0.88, 0, windowH * 0.88)
    mainWindow.Position = UDim2.new(0.5, -windowW * 0.44, 0.5, -windowH * 0.44)
    mainWindow.BackgroundTransparency = 0.5

    TweenService:Create(mainWindow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, windowW, 0, windowH),
        Position = UDim2.new(0.5, -windowW / 2, 0.5, -windowH / 2),
        BackgroundTransparency = 0.06
    }):Play()

    TweenService:Create(blurMain, TweenInfo.new(0.3), {Size = 24}):Play()
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

    TweenService:Create(dimOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    TweenService:Create(fullAurora, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
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
            fullAurora.Visible = false
            moonCanvas.Visible = false
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

    watermarkGrad.Color = sequence
    watermarkStrokeGrad.Color = sequence
    watermarkTitleGrad.Color = sequence
    watermarkTimeGrad.Color = sequence
    watermarkTime.Text = os.date("%H:%M")

    bindsGrad.Color = sequence
    bindsStrokeGrad.Color = sequence
    bindsTitleGrad.Color = sequence

    hudGrad.Color = sequence
    hudStrokeGrad.Color = sequence

    titleBarGrad.Color = sequence
    titleLineGrad.Color = sequence
    tabBarGrad.Color = sequence
    tabIndicatorGrad.Color = sequence
    moonButtonGrad.Color = sequence
    moonButtonTextGrad.Color = sequence
    statusGrad.Color = sequence
    fpsGrad.Color = sequence
    killsGrad.Color = sequence
    mainGrad.Color = sequence
    mainStrokeGrad.Color = sequence
    fullAuroraGrad.Color = sequence
    moonOuterGrad.Color = sequence

    if closeButtonGrad then
        closeButtonGrad.Color = sequence
    end
    if minimizeButtonGrad then
        minimizeButtonGrad.Color = sequence
    end

    if not menuOpen then
        return
    end

    themeTimer = themeTimer + dt
    if themeTimer > 0.5 then
        themeTimer = 0
        for _, callback in ipairs(Visual.themeCallbacks) do
            pcall(callback)
        end
    end

    for index, star in ipairs(stars) do
        local pulse = 0.5 + math.sin(globalT * (1 + index * 0.2)) * 0.3
        star.BackgroundTransparency = pulse
        local colorValue
        if Visual.isRageMode then
            colorValue = Visual.getAuroraColor(globalT, index * 0.2):Lerp(Color3.fromRGB(255, 60, 90), 0.35)
        else
            colorValue = Visual.getAuroraColor(globalT, index * 0.3)
        end
        star.BackgroundColor3 = colorValue
    end

    moonCanvas.Rotation = math.sin(globalT * 0.6) * 6
    moonCanvas.Position = UDim2.new(
        1,
        -148 + math.floor(math.sin(globalT * 1.2) * 3),
        0,
        90 + math.floor(math.cos(globalT) * 2)
    )
end

function Visual.handleDrag(inputPos)
    if Visual._dragState.drag and Visual._dragState.start and Visual._dragState.pos then
        local delta = inputPos - Visual._dragState.start
        mainWindow.Position = UDim2.new(
            Visual._dragState.pos.X.Scale,
            Visual._dragState.pos.X.Offset + delta.X,
            Visual._dragState.pos.Y.Scale,
            Visual._dragState.pos.Y.Offset + delta.Y
        )
    end

    if Visual._bfDrag.drag and Visual._bfDrag.start and Visual._bfDrag.pos then
        local delta = inputPos - Visual._bfDrag.start
        bindsFrame.Position = UDim2.new(
            Visual._bfDrag.pos.X.Scale,
            Visual._bfDrag.pos.X.Offset + delta.X,
            Visual._bfDrag.pos.Y.Scale,
            Visual._bfDrag.pos.Y.Offset + delta.Y
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
```

local
```lua
local Visual = loadstring(game:HttpGet("https://raw.githubusercontent.com/boss23003/rivals.lua/refs/heads/main/visual.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Heartbeat = RunService.Heartbeat

local PI2 = math.pi * 2
local ESP_MAX = 40
local CFG_FILE = "MoonCFG.json"

local CFG = {
    Enabled = false,
    AimMode = 1,
    AimKey = "Q",
    FOV = 150,
    AimSpeed = 4,
    AimPart = 1,
    SmoothFactor = 0.60,
    AimRange = 200,
    AimVisCheck = false,
    FirstPersonOnly = false,
    StickTarget = false,

    RageMode = false,

    SpinEnabled = false,
    SpinMode = 1,
    SpinSpeed = 10,
    SpinJitter = 45,
    SpinDownPitch = 85,

    CustomCrosshair = false,
    CrosshairSize = 12,
    CrosshairGap = 4,
    CrosshairThick = 1.5,
    CrosshairDot = true,
    CrosshairColor_R = 200,
    CrosshairColor_G = 170,
    CrosshairColor_B = 255,

    Triggerbot = false,
    TrigBotRadius = 20,
    TrigBotDelay = 0.10,
    TrigBotVisOnly = true,

    TargetEnabled = true,
    TargetKey = "R",
    TargetRadius = 5.5,
    TargetSpeed = 22,
    TargetChaseSpeed = 30,
    TargetMaxRange = 60,
    TargetDirection = 1,
    TargetAutoSwitch = true,
    TargetSwitchTime = 2.0,
    TargetCamSmooth = 0.35,
    TargetCamHeight = 2.5,
    TargetCamBack = 7,
    TargetWallCheck = true,
    TargetAntiLookAt = true,
    TargetAntiLookAtAngle = 45,
    TargetFollowY = true,
    TargetYSmooth = 0.5,
    TargetFullYFollow = true,
    TargetAntiBackstab = true,
    TargetBackstabAngle = 60,

    DashEnabled = true,
    DashKey = "F",
    DashDuration = 0.18,
    DashBehindDist = 6,
    DashTurnCam = true,
    DashCooldown = 0.5,

    TeamCheck = true,

    ShowESP = true,
    ShowFOV = true,
    ShowBox3D = true,
    ShowSkeleton = false,
    ShowHeadDot = true,
    ShowTracers = false,
    ShowSnapLine = true,
    ShowName = true,
    ShowHP = true,
    ShowDist = true,
    ShowHitmarker = true,
    ShowTargetCircle = true,
    ShowHUD = true,
    ShowChams = true,

    ESPRange = 350,
    BoxThick = 1.5,
    NameSize = 13,
    HPBarWidth = 3,
    TracerThick = 1.5,
    NameOffsetY = -20,
    HPOffsetY = 4,
    DistOffsetY = 18,

    WindowMode = 1,

    RageDash = false,
    RageTarget = false
}

local C = {}
local function rebuildColors()
    C.BG = Color3.fromRGB(8, 4, 16)
    C.BG2 = Color3.fromRGB(12, 6, 24)
    C.PANEL = Color3.fromRGB(16, 10, 30)
    C.CARD2 = Color3.fromRGB(20, 12, 40)
    C.ACC = Color3.fromRGB(120, 60, 220)
    C.ACCD = Color3.fromRGB(80, 40, 160)
    C.ON = Color3.fromRGB(100, 255, 160)
    C.OFF = Color3.fromRGB(255, 80, 80)
    C.WARN = Color3.fromRGB(255, 210, 100)
    C.T1 = Color3.fromRGB(230, 220, 255)
    C.T2 = Color3.fromRGB(180, 170, 210)
    C.T3 = Color3.fromRGB(120, 110, 150)
    C.W = Color3.fromRGB(230, 220, 255)
end

local function getESPColor()
    return Visual.getAuroraColor(os.clock(), 0)
end

local function getCHColor()
    return Color3.fromRGB(CFG.CrosshairColor_R, CFG.CrosshairColor_G, CFG.CrosshairColor_B)
end

local function getKey(keyName)
    local ok, value = pcall(function()
        return Enum.KeyCode[keyName]
    end)
    return ok and value or Enum.KeyCode.Unknown
end

local function saveCFG()
    pcall(function()
        if writefile then
            writefile(CFG_FILE, HttpService:JSONEncode(CFG))
        end
    end)
end

local function loadCFG()
    pcall(function()
        if readfile and isfile and isfile(CFG_FILE) then
            local data = HttpService:JSONDecode(readfile(CFG_FILE))
            for key, value in pairs(data) do
                if CFG[key] ~= nil then
                    CFG[key] = value
                end
            end
        end
    end)
end

loadCFG()
rebuildColors()

local CameraController, FighterController, EnemyController = nil, nil, nil
pcall(function()
    CameraController = require(LocalPlayer.PlayerScripts.Controllers:WaitForChild("CameraController", 4))
end)
pcall(function()
    FighterController = require(LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController", 4))
end)
pcall(function()
    EnemyController = require(LocalPlayer.PlayerScripts.Controllers:WaitForChild("EnemyController", 4))
end)

local aimActive = false
local toggleState = false
local lastTrigger = 0
local allDrawings = {}
local allConnections = {}
local hitmarkerTime = 0
local fps = 60
local currentTarget = nil
local stickedTarget = nil
local killCount = 0
local trackedHP = {}

local targetActive = false
local targetEnemy = nil
local targetAngle = 0
local targetDirection = 1
local targetSavedSpeed = nil
local targetLastSwitch = 0
local targetSmoothY = nil

local blockWalkSpeed = false
local isDashing = false
local lastDashTime = 0

local globalT = 0
local spinYaw = 0
local spinPitch = 0
local spinActive = false
local spinTarget = nil
local spinRandomTimer = 0
local spinRandomYaw = 0
local spinRandomPitch = 0
local forceThirdPersonTick = 0

local chamsCache = {}

local function wrapAngle(a)
    return ((a + math.pi) % PI2) - math.pi
end

local function lerpAngle(from, to, speed)
    return from + wrapAngle(to - from) * speed
end

local function setCamRotation(targetPos, smooth, origin, forcedPitch, forcedYaw)
    smooth = math.clamp(smooth or 0.5, 0.01, 1)

    if CameraController and CameraController.SetRotation and CameraController.Rotation then
        local cam = workspace.CurrentCamera
        origin = origin or (function()
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            return hrp and (hrp.Position + Vector3.new(0, 1.5, 0)) or (cam and cam.CFrame.Position)
        end)()

        if not origin then
            return
        end

        local dir = targetPos - origin
        local flatDistance = math.sqrt(dir.X * dir.X + dir.Z * dir.Z)
        local goalYaw = forcedYaw or math.atan2(-dir.X, -dir.Z)
        local goalPitch = forcedPitch or math.atan2(dir.Y, flatDistance)
        local current = CameraController.Rotation

        pcall(function()
            CameraController:SetRotation(Vector2.new(
                current.X + (goalPitch - current.X) * smooth,
                lerpAngle(current.Y, goalYaw, smooth)
            ))
        end)
    else
        local cam = workspace.CurrentCamera
        if not cam then
            return
        end

        local camOrigin = origin or cam.CFrame.Position
        local lookTarget = targetPos

        if forcedYaw or forcedPitch then
            local yaw = forcedYaw or 0
            local pitch = forcedPitch or 0
            local forward = Vector3.new(
                -math.sin(yaw) * math.cos(pitch),
                math.sin(pitch),
                -math.cos(yaw) * math.cos(pitch)
            )
            lookTarget = camOrigin + forward * 20
        end

        cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(camOrigin, lookTarget), smooth)
    end
end

local function getHRP(character)
    return character and character:FindFirstChild("HumanoidRootPart") or nil
end

local function getAimPart(character)
    if not character then
        return nil
    end
    if CFG.AimPart == 1 then
        return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    elseif CFG.AimPart == 2 then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
end

local function getRigType(character)
    if not character then
        return "?"
    end
    if character:FindFirstChild("UpperTorso") then
        return "R15"
    end
    if character:FindFirstChild("Torso") then
        return "R6"
    end
    return "?"
end

local function isFirstPerson()
    local cam = workspace.CurrentCamera
    if not cam then
        return false
    end
    local character = LocalPlayer.Character
    if not character then
        return false
    end
    local head = character:FindFirstChild("Head")
    if head and (cam.CFrame.Position - head.Position).Magnitude < 2 then
        return true
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp and (cam.CFrame.Position - hrp.Position).Magnitude < 3 then
        return true
    end
    return false
end

local function forceThirdPerson()
    local cam = workspace.CurrentCamera
    local character = LocalPlayer.Character
    if not cam or not character then
        return
    end
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local base = (head and head.Position) or (hrp and hrp.Position)
    if not base then
        return
    end
    local desired = base + Vector3.new(0, 4, 10)
    cam.CFrame = cam.CFrame:Lerp(CFrame.new(desired, base), 0.12)
end

local function isPartVisible(part, myCharacter)
    if not part then
        return false
    end

    local cam = workspace.CurrentCamera
    if not cam then
        return true
    end

    myCharacter = myCharacter or LocalPlayer.Character
    local origin = cam.CFrame.Position
    local direction = part.Position - origin

    if direction.Magnitude < 0.5 then
        return true
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = myCharacter and {myCharacter} or {}

    local hit = workspace:Raycast(origin, direction * 0.999, params)
    if not hit then
        return true
    end

    local instance = hit.Instance
    while instance do
        if instance == part.Parent then
            return true
        end
        instance = instance.Parent
    end

    return false
end

local function posClear(fromPos, toPos, ignoreList)
    local direction = toPos - fromPos
    if direction.Magnitude < 0.1 then
        return true
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList or {}
    return workspace:Raycast(fromPos, direction, params) == nil
end

local function safeOrbitPos(center, angle, radius, goalY, ignoreList)
    local goalPos = Vector3.new(
        center.X + math.sin(angle) * radius,
        goalY,
        center.Z + math.cos(angle) * radius
    )

    if not CFG.TargetWallCheck then
        return goalPos
    end

    local castFrom = Vector3.new(center.X, goalY + 1, center.Z)
    if posClear(castFrom, goalPos + Vector3.new(0, 1, 0), ignoreList) then
        return goalPos
    end

    for step = 1, 6 do
        local reducedRadius = math.max(radius - step * 1.2, 2)
        local newPos = Vector3.new(
            center.X + math.sin(angle) * reducedRadius,
            goalY,
            center.Z + math.cos(angle) * reducedRadius
        )
        if posClear(castFrom, newPos + Vector3.new(0, 1, 0), ignoreList) then
            return newPos
        end
    end

    return Vector3.new(center.X + math.sin(angle) * 2, goalY, center.Z + math.cos(angle) * 2)
end

local function isTeammate(player, entity)
    if not CFG.TeamCheck then
        return false
    end

    if entity and FighterController and FighterController.LocalFighter then
        local ok, result = pcall(function()
            local localFighter = FighterController.LocalFighter
            if type(entity) ~= "table" or type(entity.Get) ~= "function" then
                return false
            end
            if type(localFighter.Get) ~= "function" then
                return false
            end

            local entityTeam = entity:Get("TeamID")
            local localTeam = localFighter:Get("TeamID")
            if localTeam and entityTeam and localTeam == entityTeam then
                return true
            end

            local entityEnv = entity:Get("EnvironmentID")
            local localEnv = localFighter:Get("EnvironmentID")
            if localEnv and entityEnv and localEnv ~= entityEnv then
                return true
            end

            local entityDuel = entity:Get("DuelID") or entity:Get("MatchID")
            local localDuel = localFighter:Get("DuelID") or localFighter:Get("MatchID")
            if localDuel and entityDuel and localDuel ~= entityDuel then
                return true
            end

            local state = entity:Get("State") or entity:Get("CombatState")
            if state and (state == "Dead" or state == "Downed" or state == "Spectating") then
                return true
            end

            return false
        end)

        if ok and result then
            return true
        end
    end

    if player and typeof(player) == "Instance" and player:IsA("Player") then
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            return true
        end
    end

    return false
end

local function updateKills()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            pcall(function()
                local character = player.Character
                if not character then
                    return
                end

                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid then
                    return
                end

                local previous = trackedHP[player.UserId]
                if previous and previous > 0 and humanoid.Health <= 0 and (aimActive or targetActive or os.clock() - lastTrigger < 2) then
                    killCount = killCount + 1
                    Visual.PlaySound("Kill", 0.28, 1)
                end

                trackedHP[player.UserId] = humanoid.Health
            end)
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    trackedHP[player.UserId] = nil
end)

local function getAllTargets()
    local result = {}

    if FighterController then
        pcall(function()
            local localFighter = FighterController.LocalFighter
            for _, fighter in pairs(FighterController.Objects) do
                pcall(function()
                    if fighter == localFighter then
                        return
                    end
                    if not fighter.Entity or not fighter.Entity.RootPart then
                        return
                    end

                    local humanoid = fighter.Entity.Humanoid
                    if not humanoid or humanoid.Health <= 0 then
                        return
                    end

                    local player = fighter.Entity.Player
                    if isTeammate(player, fighter) then
                        return
                    end

                    local character = fighter.Entity.RootPart.Parent
                    local aimPart = getAimPart(character) or fighter.Entity.RootPart

                    table.insert(result, {
                        part = aimPart,
                        hum = humanoid,
                        char = character,
                        hrp = fighter.Entity.RootPart,
                        name = player and (player.DisplayName or player.Name) or (character and character.Name) or "?",
                        isPlayer = true,
                        player = player,
                        vel = fighter.Entity.RootPart.AssemblyLinearVelocity
                    })
                end)
            end
        end)
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not isTeammate(player) then
                pcall(function()
                    local character = player.Character
                    if not character or not character.Parent then
                        return
                    end

                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if not hrp then
                        return
                    end

                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if not humanoid or humanoid.Health <= 0 then
                        return
                    end

                    local aimPart = getAimPart(character)
                    if not aimPart then
                        return
                    end

                    table.insert(result, {
                        part = aimPart,
                        hum = humanoid,
                        char = character,
                        hrp = hrp,
                        name = player.DisplayName or player.Name,
                        isPlayer = true,
                        player = player,
                        vel = hrp.AssemblyLinearVelocity
                    })
                end)
            end
        end
    end

    if EnemyController then
        pcall(function()
            for _, enemy in pairs(EnemyController.Objects) do
                pcall(function()
                    if not enemy.Entity or not enemy.Entity.RootPart then
                        return
                    end

                    local humanoid = enemy.Entity.Humanoid
                    if not humanoid or humanoid.Health <= 0 then
                        return
                    end

                    local character = enemy.Entity.RootPart.Parent
                    local aimPart = getAimPart(character) or enemy.Entity.RootPart

                    table.insert(result, {
                        part = aimPart,
                        hum = humanoid,
                        char = character,
                        hrp = enemy.Entity.RootPart,
                        name = character and character.Name or "NPC",
                        isPlayer = false,
                        vel = enemy.Entity.RootPart.AssemblyLinearVelocity
                    })
                end)
            end
        end)
    end

    return result
end

local function predictPos(target)
    if not target or not target.part then
        return nil
    end

    local basePos = target.part.Position
    local velocity = target.vel or (target.hrp and target.hrp.AssemblyLinearVelocity) or Vector3.zero
    local cam = workspace.CurrentCamera
    if not cam then
        return basePos
    end

    local distance = (cam.CFrame.Position - basePos).Magnitude
    local leadTime = math.clamp(distance / 900, 0, 0.18)
    return basePos + velocity * leadTime
end

local function getClosest(targets)
    local cam = workspace.CurrentCamera
    if not cam then
        return nil
    end

    local cx, cy = Visual.getCenter()
    local camPos = cam.CFrame.Position

    if CFG.StickTarget and stickedTarget then
        for _, target in ipairs(targets) do
            if target.char == stickedTarget.char and target.part and target.part.Parent and target.hum and target.hum.Health > 0 then
                if (camPos - target.part.Position).Magnitude <= CFG.AimRange then
                    return target
                end
            end
        end
        stickedTarget = nil
    end

    local best = nil
    local bestScore = math.huge

    for _, target in ipairs(targets) do
        if target.part and target.part.Parent then
            local targetPos = predictPos(target) or target.part.Position
            local worldDistance = (camPos - targetPos).Magnitude

            if worldDistance <= CFG.AimRange then
                local screenPos, onScreen = cam:WorldToViewportPoint(targetPos)
                if onScreen then
                    local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cx, cy)).Magnitude
                    if screenDistance <= CFG.FOV then
                        if not CFG.AimVisCheck or isPartVisible(target.part) then
                            local score = screenDistance + worldDistance * 0.015
                            if score < bestScore then
                                bestScore = score
                                best = target
                            end
                        end
                    end
                end
            end
        end
    end

    if best and CFG.StickTarget then
        stickedTarget = best
    end

    return best
end

local function getNearest(targets)
    local myCharacter = LocalPlayer.Character
    if not myCharacter then
        return nil
    end

    local myHRP = getHRP(myCharacter)
    if not myHRP then
        return nil
    end

    local best = nil
    local bestDistance = math.huge

    for _, target in ipairs(targets) do
        if target.hrp and target.hrp.Parent then
            local distance = (myHRP.Position - target.hrp.Position).Magnitude
            if distance < bestDistance then
                bestDistance = distance
                best = target
            end
        end
    end

    return best
end

local function doAim(targetPos, dt)
    if CFG.FirstPersonOnly and not isFirstPerson() then
        return
    end
    if targetActive then
        return
    end
    if spinActive then
        return
    end

    local cam = workspace.CurrentCamera
    if not cam then
        return
    end

    local distance = (cam.CFrame.Position - targetPos).Magnitude
    if distance > CFG.AimRange then
        return
    end

    local screenPos, onScreen = cam:WorldToViewportPoint(targetPos)
    if not onScreen then
        return
    end

    local cx, cy = Visual.getCenter()
    local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cx, cy)).Magnitude
    if screenDistance > CFG.FOV or screenDistance < 0.3 then
        return
    end

    local adaptive = math.clamp(screenDistance / math.max(CFG.FOV, 1), 0.15, 1)
    local smooth = math.clamp(
        ((CFG.AimSpeed / 20) * (1 - CFG.SmoothFactor) * adaptive) * math.clamp(dt * 60, 0.5, 3),
        0.02,
        0.92
    )

    setCamRotation(targetPos, smooth, cam.CFrame.Position)
end

local function runTriggerbot(targets)
    if not CFG.Triggerbot or not CFG.Enabled then
        return
    end

    local cam = workspace.CurrentCamera
    if not cam then
        return
    end

    if os.clock() - lastTrigger < CFG.TrigBotDelay then
        return
    end

    local cx, cy = Visual.getCenter()
    local myCharacter = LocalPlayer.Character
    local camPos = cam.CFrame.Position

    for _, target in ipairs(targets) do
        if target.part and target.part.Parent then
            local targetPos = predictPos(target) or target.part.Position
            local worldDistance = (camPos - targetPos).Magnitude
            if worldDistance <= CFG.AimRange then
                local screenPos, onScreen = cam:WorldToViewportPoint(targetPos)
                if onScreen then
                    local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cx, cy)).Magnitude
                    if screenDistance <= Visual.S(CFG.TrigBotRadius) then
                        if not CFG.TrigBotVisOnly or isPartVisible(target.part, myCharacter) then
                            lastTrigger = os.clock()
                            hitmarkerTime = os.clock()
                            if mouse1click then
                                pcall(mouse1click)
                            end
                            return
                        end
                    end
                end
            end
        end
    end
end

local function stopTarget()
    targetActive = false
    blockWalkSpeed = false
    targetSmoothY = nil

    pcall(function()
        if targetSavedSpeed then
            local myCharacter = LocalPlayer.Character
            if myCharacter then
                local humanoid = myCharacter:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = targetSavedSpeed
                end
            end
            targetSavedSpeed = nil
        end
    end)

    targetEnemy = nil
end

local function startTarget()
    if not CFG.RageMode then
        return false
    end

    local targets = getAllTargets()
    local nearest = getNearest(targets)
    if not nearest then
        return false
    end

    local myCharacter = LocalPlayer.Character
    if not myCharacter then
        return false
    end

    local myHRP = getHRP(myCharacter)
    local humanoid = myCharacter:FindFirstChildOfClass("Humanoid")
    if not myHRP or not humanoid or humanoid.Health <= 0 then
        return false
    end

    if not nearest.hrp or not nearest.hrp.Parent then
        return false
    end

    if not targetSavedSpeed then
        targetSavedSpeed = humanoid.WalkSpeed
    end

    local diff = myHRP.Position - nearest.hrp.Position
    targetAngle = math.atan2(diff.X, diff.Z)

    if CFG.TargetDirection == 1 then
        targetDirection = math.random() > 0.5 and 1 or -1
    elseif CFG.TargetDirection == 2 then
        targetDirection = 1
    else
        targetDirection = -1
    end

    targetActive = true
    targetEnemy = nearest
    targetLastSwitch = os.clock()
    targetSmoothY = myHRP.Position.Y
    blockWalkSpeed = true
    return true
end

local function teleportBehind(myHRP, enemyHRP, radius)
    local backDir = -enemyHRP.CFrame.LookVector
    local backPos = Vector3.new(
        enemyHRP.Position.X + backDir.X * radius,
        myHRP.Position.Y,
        enemyHRP.Position.Z + backDir.Z * radius
    )

    local ignoreList = {LocalPlayer.Character}
    if targetEnemy and targetEnemy.char then
        table.insert(ignoreList, targetEnemy.char)
    end

    if posClear(Vector3.new(enemyHRP.Position.X, myHRP.Position.Y + 1, enemyHRP.Position.Z), backPos + Vector3.new(0, 1, 0), ignoreList) then
        myHRP.CFrame = CFrame.new(backPos, Vector3.new(enemyHRP.Position.X, myHRP.Position.Y, enemyHRP.Position.Z))
        local diff = backPos - enemyHRP.Position
        targetAngle = math.atan2(diff.X, diff.Z)
    end
end

local function updateTarget(dt)
    if not targetActive or not CFG.TargetEnabled or not CFG.RageMode then
        stopTarget()
        return
    end

    local myCharacter = LocalPlayer.Character
    if not myCharacter or not myCharacter.Parent then
        stopTarget()
        return
    end

    local myHRP = getHRP(myCharacter)
    local humanoid = myCharacter:FindFirstChildOfClass("Humanoid")
    if not myHRP or not humanoid or humanoid.Health <= 0 then
        stopTarget()
        return
    end

    if not targetEnemy or not targetEnemy.hrp or not targetEnemy.hrp.Parent then
        stopTarget()
        return
    end

    if targetEnemy.hum and targetEnemy.hum.Health <= 0 then
        stopTarget()
        return
    end

    local enemyHRP = targetEnemy.hrp
    local enemyPos = enemyHRP.Position
    local distance = (myHRP.Position - enemyPos).Magnitude

    if distance > CFG.TargetMaxRange then
        stopTarget()
        return
    end

    blockWalkSpeed = true

    if CFG.TargetAntiLookAt then
        pcall(function()
            local toMe = myHRP.Position - enemyHRP.Position
            toMe = Vector3.new(toMe.X, 0, toMe.Z)
            if toMe.Magnitude > 0.1 then
                toMe = toMe.Unit
                local enemyLook = enemyHRP.CFrame.LookVector
                enemyLook = Vector3.new(enemyLook.X, 0, enemyLook.Z)
                if enemyLook.Magnitude > 0.1 then
                    enemyLook = enemyLook.Unit
                    if math.deg(math.acos(math.clamp(toMe:Dot(enemyLook), -1, 1))) < CFG.TargetAntiLookAtAngle then
                        teleportBehind(myHRP, enemyHRP, CFG.TargetRadius)
                    end
                end
            end
        end)
    end

    if CFG.TargetAntiBackstab then
        pcall(function()
            local toEnemy = enemyHRP.Position - myHRP.Position
            toEnemy = Vector3.new(toEnemy.X, 0, toEnemy.Z)
            if toEnemy.Magnitude > 0.1 then
                toEnemy = toEnemy.Unit
                local myLook = myHRP.CFrame.LookVector
                myLook = Vector3.new(myLook.X, 0, myLook.Z)
                if myLook.Magnitude > 0.1 then
                    myLook = myLook.Unit
                    if math.deg(math.acos(math.clamp(toEnemy:Dot(myLook), -1, 1))) > (180 - CFG.TargetBackstabAngle) then
                        local sideDir = enemyHRP.CFrame.RightVector
                        local sidePos = Vector3.new(
                            enemyPos.X + sideDir.X * CFG.TargetRadius,
                            myHRP.Position.Y,
                            enemyPos.Z + sideDir.Z * CFG.TargetRadius
                        )
                        local ignoreList = {myCharacter}
                        if targetEnemy.char then
                            table.insert(ignoreList, targetEnemy.char)
                        end
                        if posClear(Vector3.new(enemyPos.X, myHRP.Position.Y + 1, enemyPos.Z), sidePos + Vector3.new(0, 1, 0), ignoreList) then
                            myHRP.CFrame = CFrame.new(sidePos, Vector3.new(enemyPos.X, myHRP.Position.Y, enemyPos.Z))
                            local diff = sidePos - enemyPos
                            targetAngle = math.atan2(diff.X, diff.Z)
                        end
                    end
                end
            end
        end)
    end

    if CFG.TargetAutoSwitch and CFG.TargetDirection == 1 and os.clock() - targetLastSwitch > CFG.TargetSwitchTime then
        targetDirection = -targetDirection
        targetLastSwitch = os.clock()
    end

    local goalY = myHRP.Position.Y
    if CFG.TargetFollowY then
        if targetSmoothY == nil then
            targetSmoothY = myHRP.Position.Y
        end

        local desiredY = enemyPos.Y - 3
        local rate
        if CFG.TargetFullYFollow then
            local diffY = math.abs(desiredY - targetSmoothY)
            rate = math.clamp(CFG.TargetYSmooth * (1 + diffY * 0.1), 0.1, 0.95)
        else
            rate = math.clamp(CFG.TargetYSmooth, 0.05, 1)
        end

        targetSmoothY = targetSmoothY + (desiredY - targetSmoothY) * rate
        goalY = targetSmoothY
    end

    local radius = math.max(CFG.TargetRadius, 2)
    local chasing = distance > radius + 4

    if chasing then
        local leadOffset = enemyHRP.AssemblyLinearVelocity * math.clamp(dt * 4, 0, 0.12)
        local chaseDir = (enemyPos + leadOffset) - myHRP.Position
        chaseDir = Vector3.new(chaseDir.X, 0, chaseDir.Z)
        if chaseDir.Magnitude > 0.1 then
            humanoid:Move(chaseDir.Unit)
            humanoid.WalkSpeed = CFG.RageTarget and math.max(CFG.TargetChaseSpeed, 38) or CFG.TargetChaseSpeed
        end
        local diff = myHRP.Position - enemyPos
        targetAngle = math.atan2(diff.X, diff.Z)
    else
        local orbitSpeed = CFG.RageTarget and math.max(CFG.TargetSpeed, 30) or CFG.TargetSpeed
        targetAngle = targetAngle + (orbitSpeed / radius) * dt * targetDirection
        local ignoreList = {myCharacter}
        if targetEnemy.char then
            table.insert(ignoreList, targetEnemy.char)
        end
        local goalPos = safeOrbitPos(enemyPos, targetAngle, radius, goalY, ignoreList)
        local moveVec = goalPos - myHRP.Position
        moveVec = Vector3.new(moveVec.X, 0, moveVec.Z)
        if moveVec.Magnitude > 0.05 then
            humanoid:Move(moveVec.Unit)
            humanoid.WalkSpeed = orbitSpeed
        end
    end

    pcall(function()
        myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(enemyPos.X, myHRP.Position.Y, enemyPos.Z))
    end)

    local camTarget = enemyPos + Vector3.new(0, CFG.TargetCamHeight * 0.5, 0)
    local lookDir = Vector3.new(enemyPos.X - myHRP.Position.X, 0, enemyPos.Z - myHRP.Position.Z)
    local camOrigin = myHRP.Position

    if lookDir.Magnitude > 0.1 then
        lookDir = lookDir.Unit
        local camBack = math.max(CFG.TargetCamBack, 3)
        local rawOrigin = myHRP.Position + Vector3.new(0, CFG.TargetCamHeight + 1, 0) - lookDir * camBack
        local ignoreList = {myCharacter}
        if targetEnemy.char then
            table.insert(ignoreList, targetEnemy.char)
        end
        if posClear(myHRP.Position + Vector3.new(0, 1, 0), rawOrigin, ignoreList) then
            camOrigin = rawOrigin
        else
            camOrigin = myHRP.Position + Vector3.new(0, CFG.TargetCamHeight + 1, 0) - lookDir * (camBack * 0.35)
        end
    end

    setCamRotation(camTarget, math.clamp(CFG.TargetCamSmooth, 0.03, 1), camOrigin)
end

local function doDash()
    if not CFG.RageMode then
        return
    end
    if isDashing or (not CFG.RageDash and os.clock() - lastDashTime < CFG.DashCooldown) then
        return
    end

    local targets = getAllTargets()
    local nearest = getNearest(targets)
    if not nearest or not nearest.hrp or not nearest.hrp.Parent then
        return
    end

    local myCharacter = LocalPlayer.Character
    if not myCharacter then
        return
    end

    local myHRP = getHRP(myCharacter)
    local humanoid = myCharacter:FindFirstChildOfClass("Humanoid")
    if not myHRP or not humanoid or humanoid.Health <= 0 then
        return
    end

    if math.abs(nearest.hrp.AssemblyLinearVelocity.Y) > 2.5 then
        return
    end

    isDashing = true
    lastDashTime = os.clock()

    local enemyHRP = nearest.hrp
    local enemyPos = enemyHRP.Position
    local backDir = -enemyHRP.CFrame.LookVector
    local dashGoal = Vector3.new(
        enemyPos.X + backDir.X * CFG.DashBehindDist,
        myHRP.Position.Y,
        enemyPos.Z + backDir.Z * CFG.DashBehindDist
    )

    local ignoreList = {myCharacter}
    if nearest.char then
        table.insert(ignoreList, nearest.char)
    end

    local castFrom = Vector3.new(enemyPos.X, myHRP.Position.Y + 1, enemyPos.Z)
    if not posClear(castFrom, dashGoal + Vector3.new(0, 1, 0), ignoreList) then
        local frontDir = enemyHRP.CFrame.LookVector
        dashGoal = Vector3.new(
            enemyPos.X + frontDir.X * CFG.DashBehindDist,
            myHRP.Position.Y,
            enemyPos.Z + frontDir.Z * CFG.DashBehindDist
        )
        if not posClear(castFrom, dashGoal + Vector3.new(0, 1, 0), ignoreList) then
            local rightDir = enemyHRP.CFrame.RightVector
            dashGoal = Vector3.new(
                enemyPos.X + rightDir.X * CFG.DashBehindDist,
                myHRP.Position.Y,
                enemyPos.Z + rightDir.Z * CFG.DashBehindDist
            )
        end
    end

    local savedEnemy = nearest
    task.spawn(function()
        local startPos = myHRP.Position
        local startTime = os.clock()
        local duration = CFG.RageDash and 0.08 or math.clamp(CFG.DashDuration, 0.06, 0.4)

        while os.clock() - startTime < duration do
            local charNow = LocalPlayer.Character
            if not charNow then
                break
            end

            local hrpNow = getHRP(charNow)
            if not hrpNow then
                break
            end

            local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
            local eased = 1 - (1 - alpha) * (1 - alpha)
            local nextPos = startPos:Lerp(dashGoal, eased)
            nextPos = Vector3.new(nextPos.X, hrpNow.Position.Y, nextPos.Z)

            pcall(function()
                hrpNow.CFrame = CFrame.new(nextPos, Vector3.new(enemyPos.X, hrpNow.Position.Y, enemyPos.Z))
            end)

            Heartbeat:Wait()
        end

        if CFG.DashTurnCam and savedEnemy and savedEnemy.hrp and savedEnemy.hrp.Parent then
            pcall(function()
                local charNow = LocalPlayer.Character
                if not charNow then
                    return
                end
                local hrpNow = getHRP(charNow)
                if not hrpNow then
                    return
                end

                local targetPos = savedEnemy.hrp.Position
                local myPos = hrpNow.Position
                hrpNow.CFrame = CFrame.new(myPos, Vector3.new(targetPos.X, myPos.Y, targetPos.Z))

                local camDir = Vector3.new(targetPos.X - myPos.X, 0, targetPos.Z - myPos.Z)
                if camDir.Magnitude > 0.1 then
                    camDir = camDir.Unit
                    setCamRotation(
                        Vector3.new(targetPos.X, targetPos.Y + 2, targetPos.Z),
                        1.0,
                        myPos + Vector3.new(0, 3, 0) - camDir * 7
                    )
                end
            end)
        end

        isDashing = false
    end)
end

local function updateSpin(dt, targets)
    spinActive = CFG.Enabled and CFG.SpinEnabled and CFG.RageMode and not targetActive
    if not spinActive then
        return
    end

    spinTarget = getNearest(targets)

    local myCharacter = LocalPlayer.Character
    local myHRP = myCharacter and getHRP(myCharacter)
    if not myHRP then
        return
    end

    forceThirdPersonTick = forceThirdPersonTick + dt
    if forceThirdPersonTick > 0.02 then
        forceThirdPersonTick = 0
        forceThirdPerson()
    end

    local targetPos
    if spinTarget and spinTarget.hrp and spinTarget.hrp.Parent then
        targetPos = spinTarget.hrp.Position
    else
        targetPos = myHRP.Position + myHRP.CFrame.LookVector * 10
    end

    local baseYaw = math.atan2(-(targetPos.X - myHRP.Position.X), -(targetPos.Z - myHRP.Position.Z))
    local downPitch = math.rad(-math.clamp(CFG.SpinDownPitch, 45, 89))

    if CFG.SpinMode == 1 then
        spinYaw = spinYaw + dt * CFG.SpinSpeed * 8
        spinPitch = downPitch
    elseif CFG.SpinMode == 2 then
        spinYaw = spinYaw + dt * CFG.SpinSpeed * 11
        spinPitch = downPitch + math.rad((math.sin(os.clock() * 22) > 0 and 1 or -1) * CFG.SpinJitter * 0.25)
    elseif CFG.SpinMode == 3 then
        spinYaw = baseYaw + math.sin(os.clock() * (8 + CFG.SpinSpeed)) * math.rad(100 + CFG.SpinJitter)
        spinPitch = downPitch + math.cos(os.clock() * 12) * math.rad(8)
    else
        spinRandomTimer = spinRandomTimer - dt
        if spinRandomTimer <= 0 then
            spinRandomTimer = math.random(8, 18) * 0.03
            spinRandomYaw = baseYaw + math.rad(math.random(-180, 180))
            spinRandomPitch = downPitch + math.rad(math.random(-10, 10))
        end
        spinYaw = lerpAngle(spinYaw, spinRandomYaw, math.clamp(dt * (6 + CFG.SpinSpeed), 0.05, 1))
        spinPitch = spinPitch + (spinRandomPitch - spinPitch) * math.clamp(dt * 8, 0.05, 1)
    end

    local cam = workspace.CurrentCamera
    local origin = cam and cam.CFrame.Position or myHRP.Position
    setCamRotation(targetPos, 1, origin, spinPitch, spinYaw)
    runTriggerbot(targets)
end

local function NL(thickness, color, transparency)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Thickness = thickness or 1
    line.Color = color or C.W
    line.Transparency = transparency or 0
    table.insert(allDrawings, line)
    return line
end

local function NC(radius, color, filled, transparency)
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Radius = radius or 5
    circle.Color = color or C.W
    circle.Filled = filled or false
    circle.NumSides = 64
    circle.Thickness = filled and 0 or 1.5
    circle.Transparency = transparency or 0
    table.insert(allDrawings, circle)
    return circle
end

local function NT(size, color)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Size = size or 13
    text.Color = color or C.W
    text.Center = true
    pcall(function()
        text.Outline = true
        text.OutlineColor = Color3.new(0, 0, 0)
    end)
    table.insert(allDrawings, text)
    return text
end

local function NS(color, filled, transparency)
    local square = Drawing.new("Square")
    square.Visible = false
    square.Color = color or C.W
    square.Filled = filled or false
    square.Thickness = filled and 0 or 1
    square.Transparency = transparency or 0
    table.insert(allDrawings, square)
    return square
end

local fovCircle1 = NC(150, Color3.fromRGB(120, 60, 220), false, 0.45)
fovCircle1.Thickness = 1.2
local fovCircle2 = NC(153, Color3.fromRGB(120, 60, 220), false, 0.75)
fovCircle2.Thickness = 0.5

local snapShadow = NL(3, Color3.new(0, 0, 0), 0.7)
local snapLine = NL(1.5, Color3.fromRGB(120, 60, 220), 0.2)

local aimDot = NC(5, C.W, true, 0.1)
aimDot.NumSides = 16
local aimRing = NC(8, Color3.fromRGB(120, 60, 220), false, 0.3)
aimRing.NumSides = 24
aimRing.Thickness = 1

local hitLines = {}
for i = 1, 4 do
    hitLines[i] = NL(2, Color3.fromRGB(255, 80, 80), 0)
end

local crossShadows = {}
local crossLines = {}
for i = 1, 4 do
    crossShadows[i] = NL(3, Color3.new(0, 0, 0), 0.6)
    crossLines[i] = NL(1.5, C.W, 0)
end
local crossDotShadow = NC(3.5, Color3.new(0, 0, 0), true, 0.5)
local crossDot = NC(2, C.W, true, 0)

local targetCircle = NC(60, Color3.fromRGB(255, 200, 50), false, 0.4)
targetCircle.Thickness = 1.5
targetCircle.NumSides = 48
local targetDot = NC(6, Color3.fromRGB(80, 255, 160), true, 0.1)
targetDot.NumSides = 12
local targetText = NT(11, Color3.fromRGB(255, 220, 80))
local targetStatusText = NT(9, Color3.fromRGB(200, 200, 200))

local SK15 = {
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"},
    {"LeftLowerArm","LeftHand"}, {"UpperTorso","RightUpperArm"},
    {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"},
    {"LeftLowerLeg","LeftFoot"}, {"LowerTorso","RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"}
}
local SK6 = {
    {"Head","Torso"}, {"Torso","Left Arm"},
    {"Torso","Right Arm"}, {"Torso","Left Leg"}, {"Torso","Right Leg"}
}
local MAX_BONES = 14

local espSlots = {}
for i = 1, ESP_MAX do
    local slot = {}
    slot.bxL = {}
    slot.bxS = {}
    for j = 1, 12 do
        slot.bxS[j] = NL(2.5, Color3.new(0, 0, 0), 0.65)
        slot.bxL[j] = NL(1.5, C.W, 0)
    end

    slot.bn = {}
    slot.bnS = {}
    for j = 1, MAX_BONES do
        slot.bnS[j] = NL(2.2, Color3.new(0, 0, 0), 0.65)
        slot.bn[j] = NL(1.0, C.W, 0.05)
    end

    slot.hdS = NC(7, Color3.new(0, 0, 0), true, 0.6)
    slot.hd = NC(5, Color3.fromRGB(255, 80, 80), true, 0)
    slot.hpB = NS(Color3.fromRGB(8, 8, 8), true, 0.35)
    slot.hpF = NS(Color3.fromRGB(60, 210, 110), true, 0.10)
    slot.nT = NT(13, C.W)
    slot.hpT = NT(11, Color3.fromRGB(180, 240, 200))
    slot.dT = NT(10, Color3.fromRGB(160, 140, 200))
    slot.trS = NL(2.5, Color3.new(0, 0, 0), 0.65)
    slot.tr = NL(1.5, C.W, 0.25)

    espSlots[i] = slot
end

local function hideSlot(slot)
    for i = 1, 12 do
        slot.bxS[i].Visible = false
        slot.bxL[i].Visible = false
    end
    for i = 1, MAX_BONES do
        slot.bnS[i].Visible = false
        slot.bn[i].Visible = false
    end
    slot.hdS.Visible = false
    slot.hd.Visible = false
    slot.hpB.Visible = false
    slot.hpF.Visible = false
    slot.nT.Visible = false
    slot.hpT.Visible = false
    slot.dT.Visible = false
    slot.trS.Visible = false
    slot.tr.Visible = false
end

local function hideAll()
    for i = 1, ESP_MAX do
        hideSlot(espSlots[i])
    end
    snapShadow.Visible = false
    snapLine.Visible = false
    aimDot.Visible = false
    aimRing.Visible = false
    for _, line in ipairs(hitLines) do
        line.Visible = false
    end
end

local function hpCol(percent)
    if percent > 0.6 then
        return Color3.fromRGB(60, 215, 115)
    elseif percent > 0.3 then
        return Color3.fromRGB(255, 195, 50)
    end
    return Color3.fromRGB(255, 55, 55)
end

local BOX_EDGES = {
    {1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}
}

local function get3DBoxCorners(cf, size)
    local x = size.X * 0.5
    local y = size.Y * 0.5
    local z = size.Z * 0.5
    return {
        cf * CFrame.new(-x, -y, -z), cf * CFrame.new(x, -y, -z),
        cf * CFrame.new(x, y, -z), cf * CFrame.new(-x, y, -z),
        cf * CFrame.new(-x, -y, z), cf * CFrame.new(x, -y, z),
        cf * CFrame.new(x, y, z), cf * CFrame.new(-x, y, z)
    }
end

local function draw3DBox(slot, hrp, color)
    local cam = workspace.CurrentCamera
    if not cam or not hrp or not hrp.Parent then
        return
    end

    local corners = get3DBoxCorners(hrp.CFrame * CFrame.new(0, -0.5, 0), Vector3.new(4, 6, 2.5))
    local points = {}

    for i = 1, 8 do
        local screenPos, onScreen = cam:WorldToViewportPoint(corners[i].Position)
        if not onScreen then
            for j = 1, 12 do
                slot.bxS[j].Visible = false
                slot.bxL[j].Visible = false
            end
            return
        end
        points[i] = Vector2.new(screenPos.X, screenPos.Y)
    end

    for i = 1, 12 do
        local edge = BOX_EDGES[i]
        slot.bxS[i].From = points[edge[1]]
        slot.bxS[i].To = points[edge[2]]
        slot.bxS[i].Thickness = Visual.S(CFG.BoxThick + 1.2)
        slot.bxS[i].Visible = true

        slot.bxL[i].From = points[edge[1]]
        slot.bxL[i].To = points[edge[2]]
        slot.bxL[i].Color = color
        slot.bxL[i].Thickness = Visual.S(CFG.BoxThick)
        slot.bxL[i].Visible = true
    end
end

local function drawSkeleton(slot, character, color)
    local cam = workspace.CurrentCamera
    if not cam or not character or not character.Parent then
        return
    end

    local rig = getRigType(character)
    if rig == "?" then
        for i = 1, MAX_BONES do
            slot.bn[i].Visible = false
            slot.bnS[i].Visible = false
        end
        return
    end

    local boneList = rig == "R15" and SK15 or SK6
    local index = 0

    for _, pair in ipairs(boneList) do
        local a = character:FindFirstChild(pair[1])
        local b = character:FindFirstChild(pair[2])

        if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
            index = index + 1
            if index > MAX_BONES then
                break
            end

            local aScreen, aOn = cam:WorldToViewportPoint(a.Position)
            local bScreen, bOn = cam:WorldToViewportPoint(b.Position)

            if aOn and bOn then
                slot.bnS[index].From = Vector2.new(aScreen.X, aScreen.Y)
                slot.bnS[index].To = Vector2.new(bScreen.X, bScreen.Y)
                slot.bnS[index].Thickness = Visual.S(2.2)
                slot.bnS[index].Visible = true

                slot.bn[index].From = Vector2.new(aScreen.X, aScreen.Y)
                slot.bn[index].To = Vector2.new(bScreen.X, bScreen.Y)
                slot.bn[index].Color = color
                slot.bn[index].Visible = true
            else
                slot.bnS[index].Visible = false
                slot.bn[index].Visible = false
            end
        end
    end

    for i = index + 1, MAX_BONES do
        slot.bnS[i].Visible = false
        slot.bn[i].Visible = false
    end
end

local function drawHitmarker(cx, cy)
    local elapsed = os.clock() - hitmarkerTime
    local active = elapsed < 0.3
    local fade = active and math.clamp(1 - elapsed / 0.3, 0, 1) or 0

    local hitSize = Visual.S(12)
    local gap = Visual.S(6)
    local extra = (1 - fade) * Visual.S(4)

    local points = {
        {Vector2.new(cx - gap - hitSize - extra, cy), Vector2.new(cx - gap, cy)},
        {Vector2.new(cx + gap, cy), Vector2.new(cx + gap + hitSize + extra, cy)},
        {Vector2.new(cx, cy - gap - hitSize - extra), Vector2.new(cx, cy - gap)},
        {Vector2.new(cx, cy + gap), Vector2.new(cx, cy + gap + hitSize + extra)}
    }

    for i, pair in ipairs(points) do
        hitLines[i].From = pair[1]
        hitLines[i].To = pair[2]
        hitLines[i].Transparency = 1 - fade
        hitLines[i].Color = Color3.fromRGB(255, math.floor(70 + fade * 180), 70)
        hitLines[i].Thickness = Visual.S(1.5 + fade)
        hitLines[i].Visible = active and CFG.ShowHitmarker
    end
end

local function drawCrosshair(cx, cy)
    if not CFG.CustomCrosshair then
        for i = 1, 4 do
            crossShadows[i].Visible = false
            crossLines[i].Visible = false
        end
        crossDotShadow.Visible = false
        crossDot.Visible = false
        return
    end

    local color = getCHColor()
    local size = Visual.S(CFG.CrosshairSize)
    local gap = Visual.S(CFG.CrosshairGap)
    local thickness = Visual.S(CFG.CrosshairThick)

    local positions = {
        {Vector2.new(cx, cy - gap - size), Vector2.new(cx, cy - gap)},
        {Vector2.new(cx, cy + gap), Vector2.new(cx, cy + gap + size)},
        {Vector2.new(cx - gap - size, cy), Vector2.new(cx - gap, cy)},
        {Vector2.new(cx + gap, cy), Vector2.new(cx + gap + size, cy)}
    }

    for i = 1, 4 do
        crossShadows[i].From = positions[i][1]
        crossShadows[i].To = positions[i][2]
        crossShadows[i].Thickness = thickness + Visual.S(2)
        crossShadows[i].Visible = true

        crossLines[i].From = positions[i][1]
        crossLines[i].To = positions[i][2]
        crossLines[i].Thickness = thickness
        crossLines[i].Color = color
        crossLines[i].Visible = true
    end

    crossDotShadow.Position = Vector2.new(cx, cy)
    crossDotShadow.Radius = Visual.S(3.5)
    crossDotShadow.Visible = CFG.CrosshairDot

    crossDot.Position = Vector2.new(cx, cy)
    crossDot.Radius = Visual.S(2)
    crossDot.Color = color
    crossDot.Visible = CFG.CrosshairDot
end

local function drawTargetVisuals()
    if not targetActive or not CFG.ShowTargetCircle then
        targetCircle.Visible = false
        targetDot.Visible = false
        targetText.Visible = false
        targetStatusText.Visible = false
        return
    end

    local cam = workspace.CurrentCamera
    if not cam or not targetEnemy or not targetEnemy.hrp or not targetEnemy.hrp.Parent then
        targetCircle.Visible = false
        targetDot.Visible = false
        targetText.Visible = false
        targetStatusText.Visible = false
        return
    end

    local screenPos, onScreen = cam:WorldToViewportPoint(targetEnemy.hrp.Position)
    if onScreen then
        local radiusPoint = targetEnemy.hrp.Position + cam.CFrame.RightVector * CFG.TargetRadius
        local radiusScreen = cam:WorldToViewportPoint(radiusPoint)
        local screenRadius = math.max(math.abs(radiusScreen.X - screenPos.X), Visual.S(10))

        targetCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
        targetCircle.Radius = screenRadius
        targetCircle.Color = Visual.getAuroraColor(os.clock(), 2)
        targetCircle.Visible = true

        local myCharacter = LocalPlayer.Character
        if myCharacter then
            local myHRP = getHRP(myCharacter)
            if myHRP then
                local myScreen, myOnScreen = cam:WorldToViewportPoint(myHRP.Position)
                if myOnScreen then
                    targetDot.Position = Vector2.new(myScreen.X, myScreen.Y)
                    targetDot.Radius = Visual.S(5)
                    targetDot.Visible = true
                else
                    targetDot.Visible = false
                end
            else
                targetDot.Visible = false
            end
        else
            targetDot.Visible = false
        end

        local distance = 0
        pcall(function()
            local myHRP = getHRP(LocalPlayer.Character)
            if myHRP then
                distance = math.floor((myHRP.Position - targetEnemy.hrp.Position).Magnitude)
            end
        end)

        local chasing = distance > (CFG.TargetRadius + 4)
        targetText.Position = Vector2.new(screenPos.X, screenPos.Y - screenRadius - Visual.S(16))
        targetText.Text = (chasing and "CHASE" or "ORBIT") .. " " .. tostring(targetEnemy.name or "")
        targetText.Size = Visual.S(11)
        targetText.Color = chasing and Color3.fromRGB(255, 120, 80) or Visual.getAuroraColor(os.clock(), 1)
        targetText.Visible = true

        local enemyHP = 0
        pcall(function()
            if targetEnemy.hum then
                enemyHP = math.floor(targetEnemy.hum.Health)
            end
        end)
        targetStatusText.Position = Vector2.new(screenPos.X, screenPos.Y + screenRadius + Visual.S(6))
        targetStatusText.Text = enemyHP .. " HP  " .. distance .. "m"
        targetStatusText.Size = Visual.S(9)
        targetStatusText.Visible = true
    else
        targetCircle.Visible = false
        targetDot.Visible = false
        targetText.Visible = false
        targetStatusText.Visible = false
    end
end

local function getCham(part)
    if not part or not part:IsA("BasePart") then
        return nil
    end

    local cached = chamsCache[part]
    if cached and cached.Parent == part then
        return cached
    end

    local ok, highlight = pcall(function()
        local obj = Instance.new("Highlight")
        obj.Name = "MoonCham"
        obj.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        obj.FillTransparency = 0.7
        obj.OutlineTransparency = 0.25
        obj.Adornee = part.Parent
        obj.Parent = part
        return obj
    end)

    if ok and highlight then
        chamsCache[part] = highlight
        return highlight
    end

    return nil
end

local function updateChams(targets, aimed)
    for part, highlight in pairs(chamsCache) do
        if not part or not part.Parent or not CFG.ShowChams or not CFG.ShowESP then
            pcall(function()
                highlight:Destroy()
            end)
            chamsCache[part] = nil
        else
            highlight.Enabled = false
        end
    end

    if not CFG.ShowChams or not CFG.ShowESP then
        return
    end

    for _, target in ipairs(targets) do
        local hrp = target.hrp or getHRP(target.char)
        if hrp and hrp.Parent and target.char then
            local highlight = getCham(hrp)
            if highlight then
                local isAimTarget = aimed and target.char == aimed.char
                local isTargetLock = targetActive and targetEnemy and target.char == targetEnemy.char
                local color
                if isTargetLock then
                    color = Visual.getAuroraColor(os.clock(), 3):Lerp(Color3.fromRGB(255, 60, 90), 0.25)
                elseif isAimTarget then
                    color = Color3.fromRGB(255, 225, 80)
                else
                    color = Visual.getAuroraColor(os.clock(), 0)
                end
                highlight.Adornee = target.char
                highlight.FillColor = color
                highlight.OutlineColor = color:Lerp(Color3.new(1, 1, 1), 0.15)
                highlight.Enabled = true
            end
        end
    end
end

local function drawESP(targets, aimed)
    if not CFG.ShowESP then
        hideAll()
        return
    end

    local cam = workspace.CurrentCamera
    if not cam then
        return
    end

    local camPos = cam.CFrame.Position
    local viewport = Visual.getVP()
    local used = 0
    local espColor = getESPColor()

    for _, target in ipairs(targets) do
        if used >= ESP_MAX then
            break
        end

        local hrp = target.hrp or getHRP(target.char)
        if hrp and hrp.Parent then
            local distance = (camPos - hrp.Position).Magnitude
            if distance <= CFG.ESPRange then
                local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    used = used + 1
                    local slot = espSlots[used]

                    local hpPercent = 1
                    if target.hum and target.hum.MaxHealth > 0 then
                        hpPercent = math.clamp(target.hum.Health / target.hum.MaxHealth, 0, 1)
                    end

                    local isAimTarget = aimed and target.char == aimed.char
                    local isTargetLock = targetActive and targetEnemy and target.char == targetEnemy.char
                    local color
                    if isTargetLock then
                        color = Visual.getAuroraColor(os.clock(), 3):Lerp(Color3.fromRGB(255, 60, 90), 0.25)
                    elseif isAimTarget then
                        color = Color3.fromRGB(255, 225, 80)
                    else
                        color = espColor
                    end
                    local inRange = distance <= CFG.AimRange

                    if CFG.ShowBox3D then
                        draw3DBox(slot, hrp, color)
                    else
                        for i2 = 1, 12 do
                            slot.bxS[i2].Visible = false
                            slot.bxL[i2].Visible = false
                        end
                    end

                    if CFG.ShowSkeleton then
                        drawSkeleton(slot, target.char, color)
                    else
                        for i2 = 1, MAX_BONES do
                            slot.bnS[i2].Visible = false
                            slot.bn[i2].Visible = false
                        end
                    end

                    if CFG.ShowHeadDot then
                        local head = target.char and target.char:FindFirstChild("Head")
                        if head then
                            local headScreen, headOnScreen = cam:WorldToViewportPoint(head.Position)
                            if headOnScreen then
                                local headVec = Vector2.new(headScreen.X, headScreen.Y)
                                slot.hdS.Position = headVec
                                slot.hdS.Radius = Visual.S(6)
                                slot.hdS.Visible = true

                                slot.hd.Position = headVec
                                slot.hd.Radius = Visual.S(4)
                                if isTargetLock then
                                    slot.hd.Color = Visual.getAuroraColor(os.clock(), 4)
                                elseif isAimTarget then
                                    slot.hd.Color = Color3.fromRGB(255, 225, 80)
                                elseif inRange then
                                    slot.hd.Color = Color3.fromRGB(255, 80, 80)
                                else
                                    slot.hd.Color = Color3.fromRGB(100, 80, 140)
                                end
                                slot.hd.Visible = true
                            else
                                slot.hd.Visible = false
                                slot.hdS.Visible = false
                            end
                        else
                            slot.hd.Visible = false
                            slot.hdS.Visible = false
                        end
                    else
                        slot.hd.Visible = false
                        slot.hdS.Visible = false
                    end

                    if CFG.ShowTracers then
                        local targetVec = Vector2.new(screenPos.X, screenPos.Y)
                        local bottom = Vector2.new(viewport.X * 0.5, viewport.Y)
                        slot.trS.From = bottom
                        slot.trS.To = targetVec
                        slot.trS.Thickness = Visual.S(CFG.TracerThick + 1)
                        slot.trS.Visible = true

                        slot.tr.From = bottom
                        slot.tr.To = targetVec
                        slot.tr.Color = color
                        slot.tr.Thickness = Visual.S(CFG.TracerThick)
                        slot.tr.Visible = true
                    else
                        slot.tr.Visible = false
                        slot.trS.Visible = false
                    end

                    local topScreen = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3.5, 0))
                    local bottomScreen = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, -3.5, 0))
                    local boxHeight = math.abs(topScreen.Y - bottomScreen.Y)
                    local boxX = screenPos.X
                    local boxY = math.min(topScreen.Y, bottomScreen.Y)

                    if CFG.ShowHP and boxHeight >= Visual.S(8) then
                        local barWidth = Visual.S(CFG.HPBarWidth)
                        local barX = boxX - boxHeight * 0.3 - barWidth - Visual.S(5)
                        local fillHeight = math.max(boxHeight * hpPercent, 1)

                        slot.hpB.Position = Vector2.new(barX - 1, boxY - 1)
                        slot.hpB.Size = Vector2.new(barWidth + 2, boxHeight + 2)
                        slot.hpB.Visible = true

                        slot.hpF.Position = Vector2.new(barX, boxY + boxHeight - fillHeight)
                        slot.hpF.Size = Vector2.new(barWidth, fillHeight)
                        slot.hpF.Color = hpCol(hpPercent)
                        slot.hpF.Visible = true
                    else
                        slot.hpB.Visible = false
                        slot.hpF.Visible = false
                    end

                    if CFG.ShowName then
                        slot.nT.Text = tostring(target.name or "???")
                        slot.nT.Size = Visual.S(CFG.NameSize)
                        slot.nT.Position = Vector2.new(boxX, boxY + Visual.S(CFG.NameOffsetY))
                        if isTargetLock then
                            slot.nT.Color = Visual.getAuroraColor(os.clock(), 5)
                        elseif isAimTarget then
                            slot.nT.Color = Color3.fromRGB(255, 235, 80)
                        elseif inRange then
                            slot.nT.Color = C.W
                        else
                            slot.nT.Color = Color3.fromRGB(100, 90, 130)
                        end
                        slot.nT.Visible = true
                    else
                        slot.nT.Visible = false
                    end

                    if CFG.ShowHP and target.hum then
                        slot.hpT.Text = math.floor(target.hum.Health) .. "/" .. math.floor(target.hum.MaxHealth)
                        slot.hpT.Position = Vector2.new(boxX, boxY + boxHeight + Visual.S(CFG.HPOffsetY))
                        slot.hpT.Size = Visual.S(11)
                        slot.hpT.Color = hpCol(hpPercent)
                        slot.hpT.Visible = true
                    else
                        slot.hpT.Visible = false
                    end

                    if CFG.ShowDist then
                        slot.dT.Text = math.floor(distance) .. "m"
                        slot.dT.Position = Vector2.new(boxX, boxY + boxHeight + Visual.S(CFG.DistOffsetY))
                        slot.dT.Size = Visual.S(10)
                        if inRange then
                            slot.dT.Color = Color3.fromRGB(150, 140, 200)
                        else
                            slot.dT.Color = Color3.fromRGB(255, 80, 80)
                        end
                        slot.dT.Visible = true
                    else
                        slot.dT.Visible = false
                    end
                end
            end
        end
    end

    for i = used + 1, ESP_MAX do
        hideSlot(espSlots[i])
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.delay(1.5, function()
        targetActive = false
        targetEnemy = nil
        targetSavedSpeed = nil
        isDashing = false
        targetSmoothY = nil
        blockWalkSpeed = false
        spinTarget = nil
    end)
end)

Visual.showLoadingScreen()

local combatInfo1, combatInfo2

Visual.makeSection(1, "Aimbot", C)
Visual.makeToggle(1, "Enabled", "Enabled", CFG, C, function(state)
    if not state then
        toggleState = false
        stickedTarget = nil
        stopTarget()
    end
    saveCFG()
end)
Visual.makeCycle(1, "Aim Mode", {"Hold", "Toggle"}, "AimMode", CFG, C, function()
    toggleState = false
    saveCFG()
end)
Visual.makeCycle(1, "Aim Part", {"Head", "HRP", "Chest"}, "AimPart", CFG, C, function()
    saveCFG()
end)
Visual.makeRebind(1, "Aim Key", "AimKey", CFG, C, allConnections)
Visual.makeSlider(1, "Aim Range", "AimRange", 10, 500, 10, CFG, C, allConnections)
Visual.makeSlider(1, "Aim FOV", "FOV", 20, 500, 5, CFG, C, allConnections)
Visual.makeSlider(1, "Aim Speed", "AimSpeed", 1, 20, 1, CFG, C, allConnections)
Visual.makeSlider(1, "Aim Smooth", "SmoothFactor", 0, 0.95, 0.05, CFG, C, allConnections)
Visual.makeToggle(1, "Vis Check", "AimVisCheck", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(1, "Stick Target", "StickTarget", CFG, C, function(state)
    if not state then
        stickedTarget = nil
    end
    saveCFG()
end)

Visual.makeSection(1, "Trigger", C)
Visual.makeToggle(1, "Triggerbot", "Triggerbot", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(1, "Trigger Vis", "TrigBotVisOnly", CFG, C, function()
    saveCFG()
end)
Visual.makeSlider(1, "Trigger Radius", "TrigBotRadius", 3, 120, 2, CFG, C, allConnections)
Visual.makeSlider(1, "Trigger Delay", "TrigBotDelay", 0.02, 1, 0.01, CFG, C, allConnections)
Visual.makeToggle(1, "Hitmarker", "ShowHitmarker", CFG, C, function()
    saveCFG()
end)

Visual.makeSection(1, "Spinbot", C)
Visual.makeToggle(1, "Spinbot", "SpinEnabled", CFG, C, function()
    saveCFG()
end)
Visual.makeCycle(1, "Spin Mode", {"Spinbot", "Jitter", "Adaptive", "Random"}, "SpinMode", CFG, C, function()
    saveCFG()
end)
Visual.makeSlider(1, "Spin Speed", "SpinSpeed", 1, 30, 1, CFG, C, allConnections)
Visual.makeSlider(1, "Spin Jitter", "SpinJitter", 5, 90, 5, CFG, C, allConnections)
Visual.makeSlider(1, "Down Pitch", "SpinDownPitch", 45, 89, 1, CFG, C, allConnections)

Visual.makeSection(1, "Info", C)
combatInfo1 = Visual.makeLabel(1, C)
combatInfo1.Text = "off"
combatInfo2 = Visual.makeLabel(1, C)
combatInfo2.Text = ""

Visual.makeSection(2, "ESP", C)
Visual.makeToggle(2, "ESP", "ShowESP", CFG, C, function(state)
    if not state then
        hideAll()
    end
    saveCFG()
end)
Visual.makeToggle(2, "3D Box", "ShowBox3D", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(2, "Skeleton", "ShowSkeleton", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(2, "Head Dot", "ShowHeadDot", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(2, "Tracers", "ShowTracers", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(2, "Snap Line", "ShowSnapLine", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(2, "Names", "ShowName", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(2, "HP", "ShowHP", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(2, "Distance", "ShowDist", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(2, "FOV Circle", "ShowFOV", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(2, "Target Circle", "ShowTargetCircle", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(2, "HUD", "ShowHUD", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(2, "Chams", "ShowChams", CFG, C, function()
    saveCFG()
end)
Visual.makeSlider(2, "ESP Range", "ESPRange", 30, 800, 10, CFG, C, allConnections)
Visual.makeSlider(2, "Box Thick", "BoxThick", 0.5, 5, 0.5, CFG, C, allConnections)
Visual.makeSlider(2, "Name Size", "NameSize", 8, 24, 1, CFG, C, allConnections)
Visual.makeSlider(2, "HP Width", "HPBarWidth", 1, 10, 1, CFG, C, allConnections)

Visual.makeSection(2, "Crosshair", C)
Visual.makeToggle(2, "Crosshair", "CustomCrosshair", CFG, C, function()
    saveCFG()
end)
Visual.makeSlider(2, "Crosshair Size", "CrosshairSize", 4, 30, 1, CFG, C, allConnections)
Visual.makeSlider(2, "Crosshair Gap", "CrosshairGap", 0, 20, 1, CFG, C, allConnections)
Visual.makeSlider(2, "Crosshair Thick", "CrosshairThick", 0.5, 4, 0.5, CFG, C, allConnections)
Visual.makeToggle(2, "Crosshair Dot", "CrosshairDot", CFG, C, function()
    saveCFG()
end)
Visual.makeSlider(2, "Color R", "CrosshairColor_R", 0, 255, 5, CFG, C, allConnections)
Visual.makeSlider(2, "Color G", "CrosshairColor_G", 0, 255, 5, CFG, C, allConnections)
Visual.makeSlider(2, "Color B", "CrosshairColor_B", 0, 255, 5, CFG, C, allConnections)

Visual.makeSection(2, "Window", C)
Visual.makeCycle(2, "Window Size", {"Normal", "Compact", "Wide"}, "WindowMode", CFG, C, function()
    local newW, newH = Visual.getWS(CFG)
    TweenService:Create(Visual.W, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, newW, 0, newH),
        Position = UDim2.new(0.5, -newW / 2, 0.5, -newH / 2)
    }):Play()
    saveCFG()
end)

Visual.makeSection(3, "Target Lock", C)
Visual.makeToggle(3, "Target Lock", "TargetEnabled", CFG, C, function(state)
    if not state then
        stopTarget()
    end
    saveCFG()
end)
Visual.makeRebind(3, "Target Key", "TargetKey", CFG, C, allConnections)
Visual.makeSlider(3, "Radius", "TargetRadius", 2, 15, 0.5, CFG, C, allConnections)
Visual.makeSlider(3, "Speed", "TargetSpeed", 10, 40, 2, CFG, C, allConnections)
Visual.makeSlider(3, "Chase Speed", "TargetChaseSpeed", 14, 50, 2, CFG, C, allConnections)
Visual.makeSlider(3, "Max Range", "TargetMaxRange", 15, 100, 5, CFG, C, allConnections)
Visual.makeCycle(3, "Direction", {"Auto", "Left", "Right"}, "TargetDirection", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(3, "Auto Switch", "TargetAutoSwitch", CFG, C, function()
    saveCFG()
end)
Visual.makeSlider(3, "Switch Time", "TargetSwitchTime", 0.5, 5, 0.25, CFG, C, allConnections)
Visual.makeSlider(3, "Cam Smooth", "TargetCamSmooth", 0.03, 1, 0.02, CFG, C, allConnections)
Visual.makeSlider(3, "Cam Height", "TargetCamHeight", 0, 6, 0.5, CFG, C, allConnections)
Visual.makeSlider(3, "Cam Back", "TargetCamBack", 3, 16, 1, CFG, C, allConnections)
Visual.makeToggle(3, "Anti-LookAt", "TargetAntiLookAt", CFG, C, function()
    saveCFG()
end)
Visual.makeSlider(3, "LookAt Angle", "TargetAntiLookAtAngle", 15, 90, 5, CFG, C, allConnections)
Visual.makeToggle(3, "Anti-Backstab", "TargetAntiBackstab", CFG, C, function()
    saveCFG()
end)
Visual.makeSlider(3, "Backstab Angle", "TargetBackstabAngle", 30, 120, 10, CFG, C, allConnections)
Visual.makeToggle(3, "Follow Y", "TargetFollowY", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(3, "Full Y", "TargetFullYFollow", CFG, C, function()
    saveCFG()
end)
Visual.makeSlider(3, "Y Smooth", "TargetYSmooth", 0.05, 1, 0.05, CFG, C, allConnections)
Visual.makeToggle(3, "Wall Check", "TargetWallCheck", CFG, C, function()
    saveCFG()
end)

Visual.makeSection(3, "Dash", C)
Visual.makeToggle(3, "Dash", "DashEnabled", CFG, C, function()
    saveCFG()
end)
Visual.makeRebind(3, "Dash Key", "DashKey", CFG, C, allConnections)
Visual.makeSlider(3, "Duration", "DashDuration", 0.06, 0.5, 0.02, CFG, C, allConnections)
Visual.makeSlider(3, "Behind Dist", "DashBehindDist", 3, 12, 1, CFG, C, allConnections)
Visual.makeSlider(3, "Cooldown", "DashCooldown", 0.1, 3, 0.1, CFG, C, allConnections)
Visual.makeToggle(3, "Turn Cam", "DashTurnCam", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(3, "Rage Dash", "RageDash", CFG, C, function()
    saveCFG()
end)
Visual.makeToggle(3, "Rage Target", "RageTarget", CFG, C, function()
    saveCFG()
end)

Visual.makeSection(4, "Binds", C)
Visual.makeInfo(4, "[INSERT] Open Menu")
Visual.makeInfo(4, "[RAGE BTN] Rebuild GUI")
Visual.makeInfo(4, "Aim: " .. CFG.AimKey)
Visual.makeInfo(4, "Target: " .. CFG.TargetKey)
Visual.makeInfo(4, "Dash: " .. CFG.DashKey)

Visual.makeSection(5, "Config", C)
Visual.makeToggle(5, "Team Check", "TeamCheck", CFG, C, function()
    saveCFG()
end)
Visual.makeInfo(5, "Config: " .. CFG_FILE)
Visual.makeInfo(5, "Rage adds Target tab")
Visual.makeInfo(5, "Client: LUNA")
Visual.makeInfo(5, "CC=" .. (CameraController and "Y" or "N") .. " FC=" .. (FighterController and "Y" or "N") .. " EC=" .. (EnemyController and "Y" or "N"))

Visual.makeSection(6, "Patch", C)
Visual.makeInfo(6, "v2.7 — combat / visual base tabs")
Visual.makeInfo(6, "v2.7 — rage rebuild adds target tab")
Visual.makeInfo(6, "v2.7 — spin forced 3rd person handling")
Visual.makeInfo(6, "v2.7 — full aurora gui / binds / watermark")
Visual.makeInfo(6, "v2.7 — moon animation / full aurora backdrop")

Visual.setRageMode(CFG.RageMode)

Visual._onRageToggle = function()
    CFG.RageMode = not CFG.RageMode
    if not CFG.RageMode then
        stopTarget()
        CFG.RageTarget = false
        CFG.RageDash = false
    end
    Visual.setRageMode(CFG.RageMode)
    Visual.Notify(
        "LUNA",
        CFG.RageMode and "rage mode enabled" or "rage mode disabled",
        3,
        CFG.RageMode and Color3.fromRGB(255, 70, 90) or Visual.getAuroraColor(os.clock())
    )
    saveCFG()
end

local renderConnection

Visual._onClose = function()
    stopTarget()
    spinActive = false

    if renderConnection then
        pcall(function()
            renderConnection:Disconnect()
        end)
    end

    hideAll()

    pcall(function()
        fovCircle1.Visible = false
        fovCircle2.Visible = false
        targetCircle.Visible = false
        targetDot.Visible = false
        targetText.Visible = false
        targetStatusText.Visible = false
    end)

    pcall(function()
        for i = 1, 4 do
            crossShadows[i].Visible = false
            crossLines[i].Visible = false
        end
        crossDotShadow.Visible = false
        crossDot.Visible = false
    end)

    for _, drawing in ipairs(allDrawings) do
        pcall(function()
            drawing:Remove()
        end)
    end

    for _, connection in ipairs(allConnections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    for _, highlight in pairs(chamsCache) do
        pcall(function()
            highlight:Destroy()
        end)
    end

    Visual.closeMenu(CFG)
    task.delay(0.3, function()
        Visual.destroy()
    end)
end

local bindsUpdateTimer = 0

renderConnection = RunService.RenderStepped:Connect(function(dt)
    if not dt or dt <= 0 then
        dt = 0.016
    end

    fps = math.floor(1 / dt)
    globalT = globalT + dt

    local cam = workspace.CurrentCamera
    if not cam then
        return
    end

    local cx, cy = Visual.getCenter()
    local espColor = getESPColor()

    Visual.updateAnimations(dt, globalT)

    bindsUpdateTimer = bindsUpdateTimer + dt
    if bindsUpdateTimer > 0.25 then
        bindsUpdateTimer = 0
        Visual.updateActiveBinds(CFG, C, aimActive, targetActive, spinActive, CFG.RageMode)
    end

    local firstPersonBlocked = CFG.FirstPersonOnly and not isFirstPerson() and not spinActive
    local fovRadius = CFG.FOV * Visual.getScale()
    local auroraFov = Visual.getAuroraColor(globalT, 0)

    fovCircle1.Position = Vector2.new(cx, cy)
    fovCircle1.Radius = fovRadius
    fovCircle1.Color = auroraFov
    fovCircle1.Thickness = Visual.S(1.2)
    fovCircle1.Visible = CFG.ShowFOV and CFG.Enabled and not firstPersonBlocked

    fovCircle2.Position = Vector2.new(cx, cy)
    fovCircle2.Radius = fovRadius + Visual.S(3)
    fovCircle2.Color = Visual.getAuroraColor(globalT, 1.5)
    fovCircle2.Thickness = Visual.S(0.5)
    fovCircle2.Visible = CFG.ShowFOV and CFG.Enabled and not firstPersonBlocked

    local aimKey = getKey(CFG.AimKey)
    if CFG.AimMode == 1 then
        aimActive = CFG.Enabled and UserInputService:IsKeyDown(aimKey) and not firstPersonBlocked and not spinActive
    else
        aimActive = CFG.Enabled and toggleState and not firstPersonBlocked and not spinActive
    end

    local targets = getAllTargets()
    local aimed = nil

    updateKills()
    updateSpin(dt, targets)

    if targetActive then
        if UserInputService:IsKeyDown(Enum.KeyCode.A) and not UserInputService:IsKeyDown(Enum.KeyCode.D) then
            targetDirection = -1
        elseif UserInputService:IsKeyDown(Enum.KeyCode.D) and not UserInputService:IsKeyDown(Enum.KeyCode.A) then
            targetDirection = 1
        end
        updateTarget(dt)
    end

    drawTargetVisuals()

    if aimActive and not targetActive and not spinActive then
        aimed = getClosest(targets)
        currentTarget = aimed

        if aimed and aimed.part and aimed.part.Parent then
            local targetPos = predictPos(aimed) or aimed.part.Position
            doAim(targetPos, dt)

            local screenPos, onScreen = cam:WorldToViewportPoint(targetPos)
            if onScreen and CFG.ShowSnapLine then
                local aimVec = Vector2.new(screenPos.X, screenPos.Y)
                local originVec = Vector2.new(cx, Visual.getVP().Y)

                snapShadow.From = originVec
                snapShadow.To = aimVec
                snapShadow.Thickness = Visual.S(3)
                snapShadow.Visible = true

                snapLine.From = originVec
                snapLine.To = aimVec
                snapLine.Color = espColor
                snapLine.Thickness = Visual.S(1.5)
                snapLine.Visible = true

                aimDot.Position = aimVec
                aimDot.Radius = Visual.S(5)
                aimDot.Visible = true

                aimRing.Position = aimVec
                aimRing.Radius = Visual.S(8)
                aimRing.Color = espColor
                aimRing.Visible = true
            else
                snapShadow.Visible = false
                snapLine.Visible = false
                aimDot.Visible = false
                aimRing.Visible = false
            end

            fovCircle1.Color = Color3.fromRGB(80, 255, 160)
            fovCircle2.Color = Color3.fromRGB(80, 255, 160)

            if combatInfo1 then
                combatInfo1.Text = tostring(aimed.name or "???") .. " [" .. math.floor((cam.CFrame.Position - aimed.part.Position).Magnitude) .. "m]"
            end
            if combatInfo2 then
                combatInfo2.Text = math.floor(aimed.hum and aimed.hum.Health or 0) .. " hp"
            end
        else
            snapShadow.Visible = false
            snapLine.Visible = false
            aimDot.Visible = false
            aimRing.Visible = false
            fovCircle1.Color = auroraFov
            fovCircle2.Color = Visual.getAuroraColor(globalT, 1.5)
            currentTarget = nil
            stickedTarget = nil
            if combatInfo1 then
                combatInfo1.Text = "searching..."
            end
            if combatInfo2 then
                combatInfo2.Text = ""
            end
        end
    elseif targetActive then
        snapShadow.Visible = false
        snapLine.Visible = false
        aimDot.Visible = false
        aimRing.Visible = false

        if combatInfo1 and targetEnemy then
            combatInfo1.Text = "orbit: " .. tostring(targetEnemy.name or "???")
        end
        if combatInfo2 and targetEnemy then
            combatInfo2.Text = math.floor(targetEnemy.hum and targetEnemy.hum.Health or 0) .. " hp"
        end
    elseif spinActive then
        snapShadow.Visible = false
        snapLine.Visible = false
        aimDot.Visible = false
        aimRing.Visible = false

        if combatInfo1 then
            local spinName = "no target"
            if spinTarget then
                spinName = tostring(spinTarget.name or "???")
            end
            combatInfo1.Text = "spin: " .. spinName
        end

        if combatInfo2 then
            local modeText = "random"
            if CFG.SpinMode == 1 then
                modeText = "spinbot"
            elseif CFG.SpinMode == 2 then
                modeText = "jitter"
            elseif CFG.SpinMode == 3 then
                modeText = "adaptive"
            end
            combatInfo2.Text = modeText
        end
    else
        snapShadow.Visible = false
        snapLine.Visible = false
        aimDot.Visible = false
        aimRing.Visible = false

        fovCircle1.Color = auroraFov
        fovCircle2.Color = Visual.getAuroraColor(globalT, 1.5)
        currentTarget = nil

        if not CFG.StickTarget then
            stickedTarget = nil
        end

        if combatInfo1 then
            if not CFG.Enabled then
                combatInfo1.Text = "off"
            else
                combatInfo1.Text = "hold " .. CFG.AimKey
            end
        end
        if combatInfo2 then
            if CFG.RageMode then
                combatInfo2.Text = "rage gui active"
            else
                combatInfo2.Text = "normal gui active"
            end
        end
    end

    if Visual.guiStatus then
        if targetActive then
            Visual.guiStatus.Text = "TGT"
        elseif spinActive then
            Visual.guiStatus.Text = "SPN"
        elseif isDashing then
            Visual.guiStatus.Text = "DSH"
        elseif not CFG.Enabled then
            Visual.guiStatus.Text = "OFF"
        else
            if CFG.RageMode then
                Visual.guiStatus.Text = "RAGE"
            else
                Visual.guiStatus.Text = "RDY"
            end
        end
    end

    if Visual.guiFPS then
        Visual.guiFPS.Text = fps .. " fps"
    end
    if Visual.guiKills then
        Visual.guiKills.Text = killCount .. " kills"
    end

    if CFG.ShowHUD and Visual.hudFrame and Visual.hudFrame.Parent then
        local lines = {}
        local function addLine(text, color)
            table.insert(lines, {t = text, c = color})
        end

        addLine(CFG.Enabled and "AIMBOT ON" or "AIMBOT OFF", CFG.Enabled and C.ON or C.OFF)
        addLine(CFG.RageMode and "RAGE GUI ACTIVE" or "NORMAL GUI ACTIVE", CFG.RageMode and Color3.fromRGB(255, 120, 120) or C.T3)
        addLine("[" .. CFG.AimKey .. "] [" .. CFG.TargetKey .. "] [" .. CFG.DashKey .. "]", C.T3)

        if aimActive then
            addLine("AIMING...", Color3.fromRGB(80, 255, 160))
        end
        if targetActive then
            addLine("ORBIT ACTIVE", Color3.fromRGB(255, 200, 50))
        end
        if spinActive then
            addLine("ANTI-HIT SPIN", Color3.fromRGB(180, 130, 255))
        end
        if CFG.Triggerbot then
            addLine("TRIGGERBOT ON", C.ON)
        end
        if CFG.DashEnabled and CFG.RageMode then
            local cooldown = math.max(0, CFG.DashCooldown - (os.clock() - lastDashTime))
            local dashText
            local dashColor
            if cooldown > 0.05 then
                dashText = "DASH " .. string.format("%.1f", cooldown) .. "s"
                dashColor = C.T3
            else
                dashText = "DASH OK"
                dashColor = Color3.fromRGB(100, 200, 255)
            end
            addLine(dashText, dashColor)
        end
        if CFG.RageDash then
            addLine("RAGE DASH", Color3.fromRGB(255, 60, 60))
        end
        if CFG.RageTarget then
            addLine("RAGE TARGET", Color3.fromRGB(255, 60, 60))
        end

        local activeCount = 0
        for i = 1, Visual.HUD_MAX do
            if Visual.hudT and Visual.hudT[i] then
                if i <= #lines then
                    Visual.hudT[i].Text = lines[i].t
                    Visual.hudT[i].TextColor3 = lines[i].c
                    Visual.hudT[i].Visible = true
                    activeCount = activeCount + 1
                else
                    Visual.hudT[i].Visible = false
                end
            end
        end

        pcall(function()
            Visual.hudFrame.Size = UDim2.new(0, 220, 0, 16 + activeCount * 15)
            Visual.hudFrame.Visible = not Visual.isOpen
        end)
    else
        pcall(function()
            if Visual.hudFrame then
                Visual.hudFrame.Visible = false
            end
        end)
    end

    runTriggerbot(targets)
    drawHitmarker(cx, cy)
    drawCrosshair(cx, cy)
    drawESP(targets, aimed)
    updateChams(targets, aimed)
end)

table.insert(allConnections, renderConnection)

table.insert(allConnections, UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        Visual.handleDrag(input.Position)
    end
end))

table.insert(allConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == getKey(CFG.AimKey) and CFG.AimMode == 2 then
        toggleState = not toggleState
    end

    if input.KeyCode == getKey(CFG.TargetKey) and CFG.TargetEnabled and CFG.RageMode then
        if targetActive then
            stopTarget()
        else
            startTarget()
        end
    end

    if input.KeyCode == getKey(CFG.DashKey) and CFG.DashEnabled and CFG.RageMode then
        doDash()
    end

    if input.KeyCode == Enum.KeyCode.Insert then
        if Visual.isOpen then
            Visual.closeMenu(CFG)
        else
            Visual.openMenu(CFG)
        end
    end
end))

saveCFG()
Visual.Notify("LUNA", "v2.7 loaded — INSERT to open", 4, Visual.getAuroraColor(os.clock()))
