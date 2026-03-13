--[[
    MOON v2.2 — VISUAL MODULE
    Aurora gradient theme, improved animations, no stripes
    Загружается из core.lua
]]

local Visual = {}

local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local BASE_W = 1920
local BASE_H = 1080

-- =============================================
--          AURORA COLOR SYSTEM
-- =============================================
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
    local idx = ((t * 0.4 + offset) % #auroraColors)
    local i1 = math.floor(idx) % #auroraColors + 1
    local i2 = (i1 % #auroraColors) + 1
    local frac = idx - math.floor(idx)
    return auroraColors[i1]:Lerp(auroraColors[i2], frac)
end

function Visual.getAuroraSequence(t)
    local c1 = Visual.getAuroraColor(t, 0)
    local c2 = Visual.getAuroraColor(t, 1.5)
    local c3 = Visual.getAuroraColor(t, 3)
    local c4 = Visual.getAuroraColor(t, 4.5)
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(0.33, c2),
        ColorSequenceKeypoint.new(0.66, c3),
        ColorSequenceKeypoint.new(1, c4),
    }
end

-- =============================================
--          SCREEN GUI SETUP
-- =============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoonGUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 99999
local parentOk = false
if gethui then parentOk = pcall(function() screenGui.Parent = gethui() end) end
if not parentOk then pcall(function() screenGui.Parent = game.CoreGui end) end
if not screenGui.Parent then screenGui.Parent = LP.PlayerGui end
Visual.screenGui = screenGui

-- =============================================
--          NOTIFICATION SYSTEM
-- =============================================
local nList = Instance.new("Frame", screenGui)
nList.Size = UDim2.new(0, 310, 1, 0)
nList.Position = UDim2.new(1, -330, 0, 20)
nList.BackgroundTransparency = 1
local nLayout = Instance.new("UIListLayout", nList)
nLayout.SortOrder = Enum.SortOrder.LayoutOrder
nLayout.Padding = UDim.new(0, 8)
nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

function Visual.Notify(title, text, dur, col)
    pcall(function()
        dur = dur or 4
        col = col or Color3.fromRGB(120, 60, 200)
        local nf = Instance.new("Frame", nList)
        nf.Size = UDim2.new(1, 0, 0, 60)
        nf.BackgroundColor3 = Color3.fromRGB(10, 6, 18)
        nf.BackgroundTransparency = 0.04
        nf.BorderSizePixel = 0
        nf.ClipsDescendants = true
        Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 12)
        local ns = Instance.new("UIStroke", nf)
        ns.Thickness = 1.5
        ns.Transparency = 0.2
        -- Aurora stroke gradient
        local nsGrad = Instance.new("UIGradient", ns)
        nsGrad.Color = Visual.getAuroraSequence(os.clock())

        local acBar = Instance.new("Frame", nf)
        acBar.Size = UDim2.new(0, 3, 0.6, 0)
        acBar.Position = UDim2.new(0, 0, 0.2, 0)
        acBar.BackgroundColor3 = col
        acBar.BorderSizePixel = 0
        Instance.new("UICorner", acBar).CornerRadius = UDim.new(0, 2)

        local iconGlow = Instance.new("Frame", nf)
        iconGlow.Size = UDim2.new(0, 24, 0, 24)
        iconGlow.Position = UDim2.new(0, 10, 0.5, -12)
        iconGlow.BackgroundColor3 = col
        iconGlow.BackgroundTransparency = 0.7
        iconGlow.BorderSizePixel = 0
        Instance.new("UICorner", iconGlow).CornerRadius = UDim.new(1, 0)

        local iconDot = Instance.new("Frame", iconGlow)
        iconDot.Size = UDim2.new(0, 8, 0, 8)
        iconDot.Position = UDim2.new(0.5, -4, 0.5, -4)
        iconDot.BackgroundColor3 = col
        iconDot.BackgroundTransparency = 0.1
        iconDot.BorderSizePixel = 0
        Instance.new("UICorner", iconDot).CornerRadius = UDim.new(1, 0)

        local tl = Instance.new("TextLabel", nf)
        tl.Text = title or ""
        tl.Size = UDim2.new(1, -48, 0, 20)
        tl.Position = UDim2.new(0, 40, 0, 8)
        tl.BackgroundTransparency = 1
        tl.TextColor3 = Color3.new(1, 1, 1)
        tl.TextSize = 13
        tl.Font = Enum.Font.GothamBold
        tl.TextXAlignment = Enum.TextXAlignment.Left

        local dl = Instance.new("TextLabel", nf)
        dl.Text = text or ""
        dl.Size = UDim2.new(1, -48, 0, 16)
        dl.Position = UDim2.new(0, 40, 0, 30)
        dl.BackgroundTransparency = 1
        dl.TextColor3 = Color3.fromRGB(180, 170, 200)
        dl.TextSize = 11
        dl.Font = Enum.Font.Gotham
        dl.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("Frame", nf)
        bar.Size = UDim2.new(1, 0, 0, 2)
        bar.Position = UDim2.new(0, 0, 1, -2)
        bar.BorderSizePixel = 0
        local barGrad = Instance.new("UIGradient", bar)
        barGrad.Color = Visual.getAuroraSequence(os.clock())
        bar.BackgroundColor3 = Color3.new(1, 1, 1)

        nf.Position = UDim2.new(1, 60, 0, 0)
        TS:Create(nf, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        local bt = TS:Create(bar, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 2)
        })
        bt:Play()
        local c
        c = bt.Completed:Connect(function()
            if c then pcall(function() c:Disconnect() end) end
            local outTween = TS:Create(nf, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 60, 0, 0), BackgroundTransparency = 1
            })
            outTween:Play()
            local c2
            c2 = outTween.Completed:Connect(function()
                if c2 then pcall(function() c2:Disconnect() end) end
                pcall(function() nf:Destroy() end)
            end)
        end)
    end)
end

-- =============================================
--          AURORA RIPPLE EFFECT
-- =============================================
function Visual.Ripple(btn, x, y, col)
    pcall(function()
        if not btn or not btn.Parent then return end
        local r = Instance.new("Frame", btn)
        r.BackgroundTransparency = 0.3
        r.BorderSizePixel = 0
        r.ZIndex = btn.ZIndex + 1
        r.ClipsDescendants = true
        Instance.new("UICorner", r).CornerRadius = UDim.new(1, 0)
        -- Aurora gradient on ripple
        local rGrad = Instance.new("UIGradient", r)
        rGrad.Color = Visual.getAuroraSequence(os.clock())
        rGrad.Rotation = math.random(0, 360)
        r.BackgroundColor3 = Color3.new(1, 1, 1)
        local maxSz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2
        r.Size = UDim2.new(0, 0, 0, 0)
        r.Position = UDim2.new(0, x or 0, 0, y or 0)
        r.AnchorPoint = Vector2.new(0.5, 0.5)
        local t = TS:Create(r, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, maxSz, 0, maxSz),
            BackgroundTransparency = 1
        })
        t:Play()
        local c
        c = t.Completed:Connect(function()
            if c then pcall(function() c:Disconnect() end) end
            pcall(function() r:Destroy() end)
        end)
    end)
end

-- =============================================
--          PULSE GLOW (AURORA)
-- =============================================
function Visual.PulseGlow(parent, col, duration)
    pcall(function()
        if not parent or not parent.Parent then return end
        duration = duration or 0.6
        local glow = Instance.new("Frame", parent)
        glow.Size = UDim2.new(1, 10, 1, 10)
        glow.Position = UDim2.new(0, -5, 0, -5)
        glow.BackgroundColor3 = Color3.new(1, 1, 1)
        glow.BackgroundTransparency = 0.6
        glow.BorderSizePixel = 0
        glow.ZIndex = parent.ZIndex - 1
        Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 12)
        local glowGrad = Instance.new("UIGradient", glow)
        glowGrad.Color = Visual.getAuroraSequence(os.clock())
        local t1 = TS:Create(glow, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Sine), {
            BackgroundTransparency = 0.3,
            Size = UDim2.new(1, 16, 1, 16),
            Position = UDim2.new(0, -8, 0, -8)
        })
        t1:Play()
        local c
        c = t1.Completed:Connect(function()
            if c then pcall(function() c:Disconnect() end) end
            local t2 = TS:Create(glow, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Sine), {
                BackgroundTransparency = 1
            })
            t2:Play()
            local c2
            c2 = t2.Completed:Connect(function()
                if c2 then pcall(function() c2:Disconnect() end) end
                pcall(function() glow:Destroy() end)
            end)
        end)
    end)
end

-- =============================================
--          WATERMARK (AURORA)
-- =============================================
local wm = Instance.new("Frame", screenGui)
wm.Size = UDim2.new(0, 210, 0, 30)
wm.Position = UDim2.new(0, 20, 0, 20)
wm.BackgroundColor3 = Color3.fromRGB(8, 4, 16)
wm.BackgroundTransparency = 0.08
wm.BorderSizePixel = 0
Instance.new("UICorner", wm).CornerRadius = UDim.new(0, 9)
local wmSt = Instance.new("UIStroke", wm)
wmSt.Thickness = 1
wmSt.Transparency = 0.3
local wmStGrad = Instance.new("UIGradient", wmSt)
Visual._wmStGrad = wmStGrad

local wmTxt = Instance.new("TextLabel", wm)
wmTxt.Size = UDim2.new(1, -16, 1, 0)
wmTxt.Position = UDim2.new(0, 8, 0, 0)
wmTxt.BackgroundTransparency = 1
wmTxt.Text = " MOON"
wmTxt.TextColor3 = Color3.fromRGB(200, 170, 255)
wmTxt.TextSize = 11
wmTxt.Font = Enum.Font.GothamMedium
wmTxt.TextXAlignment = Enum.TextXAlignment.Left

local wmLine = Instance.new("Frame", wm)
wmLine.Size = UDim2.new(1, 0, 0, 2)
wmLine.Position = UDim2.new(0, 0, 1, -2)
wmLine.BackgroundColor3 = Color3.new(1, 1, 1)
wmLine.BorderSizePixel = 0
Instance.new("UICorner", wmLine).CornerRadius = UDim.new(1, 0)
local wmGrad = Instance.new("UIGradient", wmLine)
Visual._wmGrad = wmGrad

local wmTime = Instance.new("TextLabel", wm)
wmTime.Size = UDim2.new(0, 50, 1, 0)
wmTime.Position = UDim2.new(1, -56, 0, 0)
wmTime.BackgroundTransparency = 1
wmTime.TextColor3 = Color3.fromRGB(140, 120, 170)
wmTime.TextSize = 9
wmTime.Font = Enum.Font.Code
wmTime.TextXAlignment = Enum.TextXAlignment.Right
wmTime.Text = ""
Visual.wmTime = wmTime

-- =============================================
--          LOADING SCREEN
-- =============================================
function Visual.showLoadingScreen()
    local loadGui = Instance.new("ScreenGui")
    loadGui.Name = "MoonLoad"
    loadGui.ResetOnSpawn = false
    loadGui.DisplayOrder = 10000
    loadGui.IgnoreGuiInset = true
    local ok2 = false
    if gethui then ok2 = pcall(function() loadGui.Parent = gethui() end) end
    if not ok2 then pcall(function() loadGui.Parent = game.CoreGui end) end
    if not loadGui.Parent then loadGui.Parent = LP.PlayerGui end

    local blur = Instance.new("BlurEffect")
    blur.Name = "MoonLoadBlur"; blur.Size = 0; blur.Parent = Lighting

    local loadDim = Instance.new("Frame", loadGui)
    loadDim.Size = UDim2.new(1, 0, 1, 0)
    loadDim.BackgroundColor3 = Color3.fromRGB(3, 1, 8)
    loadDim.BackgroundTransparency = 0.2
    loadDim.BorderSizePixel = 0

    local card = Instance.new("Frame", loadGui)
    card.Size = UDim2.new(0, 380, 0, 120)
    card.Position = UDim2.new(0.5, -190, 0.5, -60)
    card.BackgroundColor3 = Color3.fromRGB(10, 6, 20)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)
    local cSt = Instance.new("UIStroke", card)
    cSt.Thickness = 1.5; cSt.Transparency = 1
    local cStGrad = Instance.new("UIGradient", cSt)

    local loadMoon = Instance.new("Frame", card)
    loadMoon.Size = UDim2.new(0, 28, 0, 28)
    loadMoon.Position = UDim2.new(0.5, -60, 0, 16)
    loadMoon.BackgroundColor3 = Color3.fromRGB(200, 180, 255)
    loadMoon.BackgroundTransparency = 0.1; loadMoon.BorderSizePixel = 0
    Instance.new("UICorner", loadMoon).CornerRadius = UDim.new(1, 0)
    local loadMoonShadow = Instance.new("Frame", loadMoon)
    loadMoonShadow.Size = UDim2.new(0, 22, 0, 22)
    loadMoonShadow.Position = UDim2.new(0, 10, 0, -2)
    loadMoonShadow.BackgroundColor3 = Color3.fromRGB(10, 6, 20)
    loadMoonShadow.BorderSizePixel = 0
    Instance.new("UICorner", loadMoonShadow).CornerRadius = UDim.new(1, 0)

    local lTitle = Instance.new("TextLabel", card)
    lTitle.Text = "MOON"; lTitle.Size = UDim2.new(1, 0, 0, 24)
    lTitle.Position = UDim2.new(0, 0, 0, 18); lTitle.BackgroundTransparency = 1
    lTitle.TextColor3 = Color3.fromRGB(200, 170, 255); lTitle.TextTransparency = 1
    lTitle.TextSize = 20; lTitle.Font = Enum.Font.GothamBold
    lTitle.TextXAlignment = Enum.TextXAlignment.Center

    local lSub = Instance.new("TextLabel", card)
    lSub.Text = "initializing..."; lSub.Size = UDim2.new(1, 0, 0, 14)
    lSub.Position = UDim2.new(0, 0, 0, 48); lSub.BackgroundTransparency = 1
    lSub.TextColor3 = Color3.fromRGB(140, 120, 170); lSub.TextTransparency = 1
    lSub.TextSize = 10; lSub.Font = Enum.Font.Gotham
    lSub.TextXAlignment = Enum.TextXAlignment.Center

    local lBarBg = Instance.new("Frame", card)
    lBarBg.Size = UDim2.new(0, 0, 0, 4); lBarBg.Position = UDim2.new(0.5, 0, 0, 78)
    lBarBg.AnchorPoint = Vector2.new(0.5, 0)
    lBarBg.BackgroundColor3 = Color3.fromRGB(25, 15, 40)
    lBarBg.BackgroundTransparency = 1; lBarBg.BorderSizePixel = 0
    Instance.new("UICorner", lBarBg).CornerRadius = UDim.new(1, 0)

    local lBarFill = Instance.new("Frame", lBarBg)
    lBarFill.Size = UDim2.new(0, 0, 1, 0)
    lBarFill.BackgroundColor3 = Color3.new(1, 1, 1)
    lBarFill.BorderSizePixel = 0
    Instance.new("UICorner", lBarFill).CornerRadius = UDim.new(1, 0)
    local lBarGrad = Instance.new("UIGradient", lBarFill)

    local lVer = Instance.new("TextLabel", card)
    lVer.Text = "v2.2 Aurora"; lVer.Size = UDim2.new(1, 0, 0, 12)
    lVer.Position = UDim2.new(0, 0, 1, -18); lVer.BackgroundTransparency = 1
    lVer.TextColor3 = Color3.fromRGB(80, 60, 120); lVer.TextTransparency = 1
    lVer.TextSize = 8; lVer.Font = Enum.Font.Code
    lVer.TextXAlignment = Enum.TextXAlignment.Center

    TS:Create(blur, TweenInfo.new(0.5), {Size = 18}):Play()
    TS:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.06}):Play()
    TS:Create(cSt, TweenInfo.new(0.5), {Transparency = 0.15}):Play()
    TS:Create(lTitle, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
    TS:Create(lSub, TweenInfo.new(0.6), {TextTransparency = 0.15}):Play()
    TS:Create(lVer, TweenInfo.new(0.7), {TextTransparency = 0.4}):Play()
    TS:Create(lBarBg, TweenInfo.new(0.5), {Size = UDim2.new(0, 280, 0, 4), BackgroundTransparency = 0.4}):Play()

    local stages = {
        {12, "mapping modules"}, {28, "patching memory"}, {45, "injecting hooks"},
        {62, "spoofing identity"}, {78, "bypassing checks"}, {90, "loading assets"}, {100, "ready"}
    }

    task.spawn(function()
        task.wait(0.65)
        for _, s in ipairs(stages) do
            lBarGrad.Color = Visual.getAuroraSequence(os.clock())
            cStGrad.Color = Visual.getAuroraSequence(os.clock())
            TS:Create(lBarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                Size = UDim2.new(s[1] / 100, 0, 1, 0)
            }):Play()
            lSub.Text = s[2]
            task.wait(math.random(12, 28) * 0.01)
        end
        lSub.Text = " initialization complete"
        lSub.TextColor3 = Color3.fromRGB(140, 255, 180)
        task.wait(0.5)
        TS:Create(card, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TS:Create(cSt, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TS:Create(lTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TS:Create(lSub, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TS:Create(lVer, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TS:Create(lBarFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TS:Create(lBarBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TS:Create(loadDim, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TS:Create(blur, TweenInfo.new(0.4), {Size = 0}):Play()
        task.wait(0.5)
        pcall(function() blur:Destroy() end)
        pcall(function() loadGui:Destroy() end)
    end)
end

-- =============================================
--          CLEANUP OLD
-- =============================================
local oldNames = {"SakuraGUI_v19","SakuraGUI_v18","SakuraGUI","SakuraGUI_v20","MoonGUI_Main"}
for _, n in ipairs(oldNames) do
    pcall(function() if game.CoreGui:FindFirstChild(n) then game.CoreGui[n]:Destroy() end end)
    pcall(function() if gethui and gethui():FindFirstChild(n) then gethui()[n]:Destroy() end end)
end
for _, v in pairs(Lighting:GetChildren()) do
    if v.Name:find("SakuraMainBlur") or v.Name:find("MoonBlur") then pcall(function() v:Destroy() end) end
end

-- =============================================
--          SCALING
-- =============================================
local _sc, _scT = 1, 0
function Visual.getScale()
    if os.clock() - _scT < 0.5 then return _sc end
    local cam = workspace.CurrentCamera
    if cam then _sc = math.clamp(math.min(cam.ViewportSize.X / BASE_W, cam.ViewportSize.Y / BASE_H), 0.4, 4) end
    _scT = os.clock()
    return _sc
end
function Visual.S(v) return v * Visual.getScale() end
function Visual.getVP()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1920, 1080)
end
function Visual.getCenter()
    local vp = Visual.getVP()
    return vp.X * 0.5, vp.Y * 0.5
end

-- =============================================
--          MAIN GUI
-- =============================================
local blurMain = Instance.new("BlurEffect", Lighting)
blurMain.Name = "MoonBlur"; blurMain.Size = 0
Visual.blurMain = blurMain

local gui = Instance.new("ScreenGui")
gui.Name = "MoonGUI_Main"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999; gui.IgnoreGuiInset = true
local gOk = false
if gethui then gOk = pcall(function() gui.Parent = gethui() end) end
if not gOk then pcall(function() gui.Parent = game.CoreGui end) end
if not gui.Parent then gui.Parent = LP.PlayerGui end
Visual.gui = gui

local guiScale = Instance.new("UIScale", gui)
task.spawn(function()
    while gui and gui.Parent do
        pcall(function() guiScale.Scale = math.clamp(math.min(Visual.getVP().X / BASE_W, Visual.getVP().Y / BASE_H), 0.5, 3) end)
        task.wait(1)
    end
end)

-- Dim overlay
local dimOverlay = Instance.new("Frame", gui)
dimOverlay.Size = UDim2.new(1, 0, 1, 0)
dimOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
dimOverlay.BackgroundTransparency = 1
dimOverlay.BorderSizePixel = 0; dimOverlay.ZIndex = 8; dimOverlay.Visible = false
Visual.dimOverlay = dimOverlay

-- =============================================
--       ACTIVE BINDS WINDOW (AURORA)
-- =============================================
local bindsWindow = Instance.new("Frame", screenGui)
bindsWindow.Size = UDim2.new(0, 185, 0, 30)
bindsWindow.Position = UDim2.new(1, -205, 0.5, -60)
bindsWindow.BackgroundColor3 = Color3.fromRGB(8, 4, 16)
bindsWindow.BackgroundTransparency = 0.06
bindsWindow.BorderSizePixel = 0; bindsWindow.ZIndex = 50; bindsWindow.ClipsDescendants = true
Instance.new("UICorner", bindsWindow).CornerRadius = UDim.new(0, 10)
local bwStroke = Instance.new("UIStroke", bindsWindow)
bwStroke.Thickness = 1; bwStroke.Transparency = 0.25
local bwStGrad = Instance.new("UIGradient", bwStroke)
Visual._bwStGrad = bwStGrad

local bwTopLine = Instance.new("Frame", bindsWindow)
bwTopLine.Size = UDim2.new(1, 0, 0, 2)
bwTopLine.Position = UDim2.new(0, 0, 0, 0)
bwTopLine.BackgroundColor3 = Color3.new(1, 1, 1)
bwTopLine.BorderSizePixel = 0; bwTopLine.ZIndex = 53
local bwTopGrad = Instance.new("UIGradient", bwTopLine)
Visual._bwTopGrad = bwTopGrad

local bwTitle = Instance.new("TextLabel", bindsWindow)
bwTitle.Size = UDim2.new(1, -8, 0, 20)
bwTitle.Position = UDim2.new(0, 8, 0, 5)
bwTitle.BackgroundTransparency = 1; bwTitle.Text = " MOON"
bwTitle.TextColor3 = Color3.fromRGB(200, 170, 255)
bwTitle.TextSize = 10; bwTitle.Font = Enum.Font.GothamBold
bwTitle.TextXAlignment = Enum.TextXAlignment.Left; bwTitle.ZIndex = 52

local bwContent = Instance.new("Frame", bindsWindow)
bwContent.Size = UDim2.new(1, -8, 1, -28)
bwContent.Position = UDim2.new(0, 4, 0, 26)
bwContent.BackgroundTransparency = 1; bwContent.ZIndex = 51
local bwLayout = Instance.new("UIListLayout", bwContent)
bwLayout.Padding = UDim.new(0, 2); bwLayout.SortOrder = Enum.SortOrder.LayoutOrder

Visual._bwDragState = {drag = false, start = nil, pos = nil}
bindsWindow.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        Visual._bwDragState.drag = true
        Visual._bwDragState.start = i.Position
        Visual._bwDragState.pos = bindsWindow.Position
    end
end)
bindsWindow.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then Visual._bwDragState.drag = false end
end)
Visual.bindsWindow = bindsWindow; Visual.bwContent = bwContent

function Visual.updateActiveBinds(CFG, C, aimActive, tgtActive)
    for _, v in pairs(bwContent:GetChildren()) do
        if v:IsA("Frame") then pcall(function() v:Destroy() end) end
    end
    local items = {}
    if CFG.Enabled then table.insert(items, {name = "Aimbot", col = C.ON}) end
    if aimActive then table.insert(items, {name = "Aiming [" .. CFG.AimKey .. "]", col = Color3.fromRGB(80, 255, 160)}) end
    if tgtActive then table.insert(items, {name = "Target [" .. CFG.TargetKey .. "]", col = Color3.fromRGB(255, 200, 50)}) end
    if CFG.Triggerbot then table.insert(items, {name = "Triggerbot", col = Color3.fromRGB(255, 150, 100)}) end
    if CFG.DashEnabled then table.insert(items, {name = "Dash [" .. CFG.DashKey .. "]", col = Color3.fromRGB(100, 200, 255)}) end
    if CFG.ShowESP then table.insert(items, {name = "ESP", col = Color3.fromRGB(160, 140, 255)}) end
    if CFG.RageDash then table.insert(items, {name = "Rage Dash", col = Color3.fromRGB(255, 60, 60)}) end
    if CFG.RageTarget then table.insert(items, {name = "Rage Target", col = Color3.fromRGB(255, 60, 60)}) end

    for idx, item in ipairs(items) do
        local lbl = Instance.new("Frame", bwContent)
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.BackgroundTransparency = 1; lbl.ZIndex = 52; lbl.LayoutOrder = idx

        -- Aurora colored dot instead of static
        local dot = Instance.new("Frame", lbl)
        dot.Size = UDim2.new(0, 6, 0, 6)
        dot.Position = UDim2.new(0, 3, 0.5, -3)
        dot.BackgroundColor3 = Visual.getAuroraColor(os.clock(), idx * 0.5)
        dot.BorderSizePixel = 0; dot.ZIndex = 53
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local txt = Instance.new("TextLabel", lbl)
        txt.Size = UDim2.new(1, -14, 1, 0)
        txt.Position = UDim2.new(0, 14, 0, 0)
        txt.BackgroundTransparency = 1; txt.TextColor3 = item.col
        txt.TextSize = 9; txt.Font = Enum.Font.GothamSemibold
        txt.TextXAlignment = Enum.TextXAlignment.Left; txt.Text = item.name
        txt.ZIndex = 53

        -- Smooth slide-in animation from right
        lbl.Position = UDim2.new(0, 30, 0, 0)
        TS:Create(lbl, TweenInfo.new(0.35 + idx * 0.05, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        txt.TextTransparency = 1
        TS:Create(txt, TweenInfo.new(0.3 + idx * 0.05, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    end

    local totalH = 30 + #items * 18
    TS:Create(bindsWindow, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 185, 0, math.max(totalH, 32))
    }):Play()
end

-- =============================================
--          HUD FRAME
-- =============================================
local HUD_MAX = 14
local hudFrame = Instance.new("Frame", gui)
hudFrame.Size = UDim2.new(0, 200, 0, 180)
hudFrame.Position = UDim2.new(0, 20, 0.5, -90)
hudFrame.BackgroundColor3 = Color3.fromRGB(8, 4, 16)
hudFrame.BackgroundTransparency = 0.2; hudFrame.BorderSizePixel = 0
hudFrame.ZIndex = 5; hudFrame.Visible = false
Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0, 10)
local hudSt = Instance.new("UIStroke", hudFrame)
hudSt.Thickness = 1; hudSt.Transparency = 0.4
local hudStGrad = Instance.new("UIGradient", hudSt)
Visual._hudStGrad = hudStGrad
Instance.new("UIListLayout", hudFrame).Padding = UDim.new(0, 2)
local hp2 = Instance.new("UIPadding", hudFrame)
hp2.PaddingTop = UDim.new(0, 7); hp2.PaddingLeft = UDim.new(0, 10)
hp2.PaddingRight = UDim.new(0, 10); hp2.PaddingBottom = UDim.new(0, 7)

local hudT = {}
for i = 1, HUD_MAX do
    local l = Instance.new("TextLabel", hudFrame)
    l.Size = UDim2.new(1, 0, 0, 13); l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left; l.Font = Enum.Font.GothamBold
    l.TextSize = 10; l.Visible = false; l.ZIndex = 6
    l.TextColor3 = Color3.fromRGB(230, 220, 255); l.Text = ""
    hudT[i] = l
end
Visual.hudFrame = hudFrame; Visual.hudT = hudT; Visual.hudSt = hudSt; Visual.HUD_MAX = HUD_MAX

-- =============================================
--          MAIN WINDOW FRAME (NO STRIPES, AURORA BG)
-- =============================================
local WIN_MODES = {{w = 800, h = 550}, {w = 600, h = 420}, {w = 1050, h = 650}}
Visual.WIN_MODES = WIN_MODES

function Visual.getWS(CFG)
    local m = WIN_MODES[CFG.WindowMode] or WIN_MODES[1]
    return m.w, m.h
end

local wW, wH = 800, 550
local W = Instance.new("Frame", gui)
W.Name = "W"; W.Size = UDim2.new(0, wW, 0, wH)
W.Position = UDim2.new(0.5, -wW/2, 0.5, -wH/2)
W.BackgroundColor3 = Color3.fromRGB(8, 4, 16)
W.BackgroundTransparency = 0.04; W.BorderSizePixel = 0
W.Visible = false; W.ZIndex = 10; W.ClipsDescendants = true
Instance.new("UICorner", W).CornerRadius = UDim.new(0, 14)
local gSt = Instance.new("UIStroke", W)
gSt.Thickness = 1.5; gSt.Transparency = 0.15
local gStGrad = Instance.new("UIGradient", gSt)
Visual._gStGrad = gStGrad
Visual.W = W; Visual.gSt = gSt

-- Aurora background gradient overlay
local auroraBg = Instance.new("Frame", W)
auroraBg.Size = UDim2.new(1, 0, 1, 0)
auroraBg.BackgroundColor3 = Color3.new(1, 1, 1)
auroraBg.BackgroundTransparency = 0.92
auroraBg.BorderSizePixel = 0; auroraBg.ZIndex = 10
auroraBg.ClipsDescendants = true
Instance.new("UICorner", auroraBg).CornerRadius = UDim.new(0, 14)
local auroraBgGrad = Instance.new("UIGradient", auroraBg)
auroraBgGrad.Rotation = 25
Visual._auroraBgGrad = auroraBgGrad

-- Moon decoration
local moonContainer = Instance.new("Frame", W)
moonContainer.Size = UDim2.new(0, 130, 0, 130)
moonContainer.Position = UDim2.new(1, -140, 0, -15)
moonContainer.BackgroundTransparency = 1; moonContainer.BorderSizePixel = 0
moonContainer.ZIndex = 11; moonContainer.Visible = false
Visual.moonContainer = moonContainer

local moonGlow2 = Instance.new("Frame", moonContainer)
moonGlow2.Size = UDim2.new(0, 110, 0, 110)
moonGlow2.Position = UDim2.new(1, -110, 0, -25)
moonGlow2.BackgroundColor3 = Color3.fromRGB(80, 40, 160)
moonGlow2.BackgroundTransparency = 0.86; moonGlow2.BorderSizePixel = 0; moonGlow2.ZIndex = 10
Instance.new("UICorner", moonGlow2).CornerRadius = UDim.new(1, 0)
Visual.moonGlow2 = moonGlow2

local moonGlowFrame = Instance.new("Frame", moonContainer)
moonGlowFrame.Size = UDim2.new(0, 75, 0, 75)
moonGlowFrame.Position = UDim2.new(1, -90, 0, -8)
moonGlowFrame.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
moonGlowFrame.BackgroundTransparency = 0.72; moonGlowFrame.BorderSizePixel = 0; moonGlowFrame.ZIndex = 11
Instance.new("UICorner", moonGlowFrame).CornerRadius = UDim.new(1, 0)
Visual.moonGlowFrame = moonGlowFrame

local moonBody = Instance.new("Frame", moonContainer)
moonBody.Size = UDim2.new(0, 50, 0, 50)
moonBody.Position = UDim2.new(1, -78, 0, 4)
moonBody.BackgroundColor3 = Color3.fromRGB(220, 200, 255)
moonBody.BackgroundTransparency = 0.04; moonBody.BorderSizePixel = 0; moonBody.ZIndex = 12
Instance.new("UICorner", moonBody).CornerRadius = UDim.new(1, 0)
local moonCrescent = Instance.new("Frame", moonBody)
moonCrescent.Size = UDim2.new(0, 40, 0, 40)
moonCrescent.Position = UDim2.new(0, 17, 0, -2)
moonCrescent.BackgroundColor3 = Color3.fromRGB(8, 4, 16)
moonCrescent.BackgroundTransparency = 0.02; moonCrescent.BorderSizePixel = 0; moonCrescent.ZIndex = 13
Instance.new("UICorner", moonCrescent).CornerRadius = UDim.new(1, 0)
local function makeCrater(px, py, sz, tr)
    local cr = Instance.new("Frame", moonBody)
    cr.Size = UDim2.new(0, sz, 0, sz); cr.Position = UDim2.new(0, px, 0, py)
    cr.BackgroundColor3 = Color3.fromRGB(190, 170, 230); cr.BackgroundTransparency = tr
    cr.BorderSizePixel = 0; cr.ZIndex = 13
    Instance.new("UICorner", cr).CornerRadius = UDim.new(1, 0)
end
makeCrater(6, 12, 6, 0.3); makeCrater(10, 28, 4, 0.4); makeCrater(3, 34, 5, 0.35)
makeCrater(14, 8, 3, 0.5); makeCrater(2, 22, 3, 0.45)

-- Stars (subtle, no stripes)
local guiStars = {}
for i = 1, 25 do
    local star = Instance.new("Frame", W)
    local sz = math.random(1, 2)
    star.Size = UDim2.new(0, sz, 0, sz)
    star.Position = UDim2.new(0, math.random(10, wW - 10), 0, math.random(50, wH - 10))
    star.BackgroundColor3 = Color3.fromRGB(200 + math.random(-30, 30), 180 + math.random(-20, 20), 255)
    star.BackgroundTransparency = math.random(45, 80) / 100
    star.BorderSizePixel = 0; star.ZIndex = 11
    Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    table.insert(guiStars, star)
end
Visual.guiStars = guiStars

-- =============================================
--          TITLE BAR (AURORA)
-- =============================================
local tB = Instance.new("Frame", W)
tB.Size = UDim2.new(1, 0, 0, 48)
tB.BackgroundColor3 = Color3.fromRGB(6, 3, 14)
tB.BackgroundTransparency = 0.1; tB.BorderSizePixel = 0; tB.ZIndex = 12
Instance.new("UICorner", tB).CornerRadius = UDim.new(0, 14)
Visual.tB = tB

local tL = Instance.new("Frame", tB)
tL.Size = UDim2.new(1, 0, 0, 2); tL.Position = UDim2.new(0, 0, 1, -2)
tL.BackgroundColor3 = Color3.new(1, 1, 1); tL.BackgroundTransparency = 0.2
tL.BorderSizePixel = 0; tL.ZIndex = 14
local tLGrad = Instance.new("UIGradient", tL)
Visual.tL = tL; Visual._tLGrad = tLGrad

local tT = Instance.new("TextLabel", tB)
tT.Text = " MOON"; tT.Size = UDim2.new(0, 180, 1, 0)
tT.Position = UDim2.new(0, 16, 0, 0); tT.BackgroundTransparency = 1
tT.TextColor3 = Color3.fromRGB(200, 170, 255); tT.TextSize = 15
tT.Font = Enum.Font.GothamBold; tT.TextXAlignment = Enum.TextXAlignment.Left; tT.ZIndex = 15

local guiStatus = Instance.new("TextLabel", tB)
guiStatus.Text = "OFF"; guiStatus.Size = UDim2.new(0, 58, 0, 22)
guiStatus.Position = UDim2.new(0, 180, 0.5, -11)
guiStatus.BackgroundColor3 = Color3.fromRGB(35, 10, 10)
guiStatus.TextColor3 = Color3.fromRGB(255, 80, 80); guiStatus.TextSize = 10
guiStatus.Font = Enum.Font.GothamBold; guiStatus.BorderSizePixel = 0; guiStatus.ZIndex = 15
Instance.new("UICorner", guiStatus).CornerRadius = UDim.new(0, 6)
Visual.guiStatus = guiStatus

local guiFPS = Instance.new("TextLabel", tB)
guiFPS.Text = "60 fps"; guiFPS.Size = UDim2.new(0, 50, 0, 14)
guiFPS.Position = UDim2.new(0, 248, 0.5, -7); guiFPS.BackgroundTransparency = 1
guiFPS.TextColor3 = Color3.fromRGB(100, 90, 130); guiFPS.TextSize = 9
guiFPS.Font = Enum.Font.Code; guiFPS.ZIndex = 15
Visual.guiFPS = guiFPS

local guiKills = Instance.new("TextLabel", tB)
guiKills.Text = "0 kills"; guiKills.Size = UDim2.new(0, 50, 0, 14)
guiKills.Position = UDim2.new(0, 302, 0.5, -7); guiKills.BackgroundTransparency = 1
guiKills.TextColor3 = Color3.fromRGB(100, 90, 130); guiKills.TextSize = 9
guiKills.Font = Enum.Font.Code; guiKills.ZIndex = 15
Visual.guiKills = guiKills

-- Title bar buttons
local isMin = false
Visual._dragState = {drag = false, start = nil, pos = nil}

local function mkTitleBtn(tx, xO, bg, cb)
    local b = Instance.new("TextButton", tB)
    b.Text = tx; b.Size = UDim2.new(0, 34, 0, 28)
    b.Position = UDim2.new(1, xO, 0.5, -14); b.BackgroundColor3 = bg
    b.BackgroundTransparency = 0.4; b.TextColor3 = Color3.fromRGB(230, 220, 255)
    b.TextSize = 14; b.Font = Enum.Font.GothamBold; b.BorderSizePixel = 0
    b.ZIndex = 16; b.ClipsDescendants = true; b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseEnter:Connect(function() TS:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.1}):Play() end)
    b.MouseLeave:Connect(function() TS:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.4}):Play() end)
    b.MouseButton1Click:Connect(function()
        Visual.Ripple(b, b.AbsoluteSize.X / 2, b.AbsoluteSize.Y / 2)
        if cb then cb() end
    end)
    return b
end

Visual._onClose = nil
Visual._closeBtn = mkTitleBtn("", -40, Color3.fromRGB(140, 30, 40), function()
    if Visual._onClose then Visual._onClose() end
end)

mkTitleBtn("", -80, Color3.fromRGB(30, 20, 55), function()
    isMin = not isMin
    TS:Create(W, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
        Size = isMin and UDim2.new(0, wW, 0, 48) or UDim2.new(0, wW, 0, wH)
    }):Play()
end)

tB.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        Visual._dragState.drag = true; Visual._dragState.start = i.Position; Visual._dragState.pos = W.Position
    end
end)
tB.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then Visual._dragState.drag = false end
end)

-- =============================================
--          TAB SYSTEM
-- =============================================
local body = Instance.new("Frame", W)
body.Size = UDim2.new(1, 0, 1, -48); body.Position = UDim2.new(0, 0, 0, 48)
body.BackgroundTransparency = 1; body.BorderSizePixel = 0; body.ZIndex = 11

local tabBar = Instance.new("Frame", body)
tabBar.Size = UDim2.new(1, 0, 0, 38)
tabBar.BackgroundColor3 = Color3.fromRGB(6, 3, 14)
tabBar.BackgroundTransparency = 0.2; tabBar.BorderSizePixel = 0; tabBar.ZIndex = 13

local tabInd = Instance.new("Frame", tabBar)
tabInd.Size = UDim2.new(0, 0, 0, 2); tabInd.Position = UDim2.new(0, 0, 1, -2)
tabInd.BackgroundColor3 = Color3.new(1, 1, 1); tabInd.BorderSizePixel = 0; tabInd.ZIndex = 15
local tabIndGrad = Instance.new("UIGradient", tabInd)
Visual._tabIndGrad = tabIndGrad
Visual.tabInd = tabInd

local tabCon = Instance.new("Frame", body)
tabCon.Size = UDim2.new(1, 0, 1, -38); tabCon.Position = UDim2.new(0, 0, 0, 38)
tabCon.BackgroundTransparency = 1; tabCon.BorderSizePixel = 0; tabCon.ZIndex = 12

local TN = {"Aim", "Trig", "ESP", "Visual", "Target", "Binds", "Cfg", "Patch"}
Visual.TabNames = TN
local tBs, tPs = {}, {}
local aTab = 1

for i, nm in ipairs(TN) do
    local pg = Instance.new("ScrollingFrame", tabCon)
    pg.Name = "P" .. i; pg.Size = UDim2.new(1, 0, 1, 0)
    pg.BackgroundTransparency = 1; pg.ScrollBarThickness = 3
    pg.ScrollBarImageColor3 = Color3.fromRGB(100, 60, 200)
    pg.ScrollBarImageTransparency = 0.5; pg.CanvasSize = UDim2.new(0, 0, 0, 0)
    pg.BorderSizePixel = 0; pg.Visible = (i == 1); pg.ZIndex = 13
    pg.ScrollingDirection = Enum.ScrollingDirection.Y
    local ll = Instance.new("UIListLayout", pg)
    ll.Padding = UDim.new(0, 5); ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pg.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 24)
    end)
    local pd = Instance.new("UIPadding", pg)
    pd.PaddingTop = UDim.new(0, 12); pd.PaddingLeft = UDim.new(0, 18)
    pd.PaddingRight = UDim.new(0, 18); pd.PaddingBottom = UDim.new(0, 18)
    tPs[i] = pg
end

local tbw = math.floor(wW / #TN)
local function switchTab(idx)
    aTab = idx
    for i, b in ipairs(tBs) do
        local ac = Visual.getAuroraColor(os.clock(), i * 0.3)
        TS:Create(b, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
            TextColor3 = (i == idx) and ac or Color3.fromRGB(140, 130, 170)
        }):Play()
        tPs[i].Visible = (i == idx)
    end
    TS:Create(tabInd, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0, (idx - 1) * tbw + 10, 1, -2),
        Size = UDim2.new(0, tbw - 20, 0, 2)
    }):Play()
end

for i, nm in ipairs(TN) do
    local b = Instance.new("TextButton", tabBar)
    b.Text = nm; b.Size = UDim2.new(0, tbw, 1, 0)
    b.Position = UDim2.new(0, (i - 1) * tbw, 0, 0); b.BackgroundTransparency = 1
    b.TextColor3 = i == 1 and Color3.fromRGB(120, 60, 220) or Color3.fromRGB(140, 130, 170)
    b.TextSize = 11; b.Font = Enum.Font.GothamBold; b.BorderSizePixel = 0
    b.AutoButtonColor = false; b.ZIndex = 15
    b.MouseEnter:Connect(function()
        if aTab ~= i then TS:Create(b, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(220, 210, 255)}):Play() end
    end)
    b.MouseLeave:Connect(function()
        if aTab ~= i then TS:Create(b, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(140, 130, 170)}):Play() end
    end)
    b.MouseButton1Click:Connect(function() switchTab(i) end)
    tBs[i] = b
end
tabInd.Size = UDim2.new(0, tbw - 20, 0, 2)
tabInd.Position = UDim2.new(0, 10, 1, -2)
Visual.tBs = tBs; Visual.tPs = tPs; Visual.switchTab = switchTab

-- =============================================
--          UI BUILDERS
-- =============================================
local pO = {}
for i = 1, #TN do pO[i] = 0 end
local function po(pi) pO[pi] = pO[pi] + 1; return pO[pi] end
Visual.themeCallbacks = {}

function Visual.makeSection(pi, tx, C)
    C = C or {ACC = Color3.fromRGB(130, 70, 220)}
    local f = Instance.new("Frame", tPs[pi])
    f.Size = UDim2.new(1, -4, 0, 26); f.BackgroundTransparency = 1
    f.LayoutOrder = po(pi); f.ZIndex = 18
    local l = Instance.new("TextLabel", f)
    l.Text = string.upper(tx); l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1; l.TextColor3 = C.ACC
    l.TextSize = 10; l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 20
    local ln = Instance.new("Frame", f)
    ln.Size = UDim2.new(1, 0, 0, 1); ln.Position = UDim2.new(0, 0, 1, -1)
    ln.BackgroundColor3 = Color3.new(1, 1, 1); ln.BackgroundTransparency = 0.5
    ln.BorderSizePixel = 0; ln.ZIndex = 20
    local lnGrad = Instance.new("UIGradient", ln)
    lnGrad.Color = Visual.getAuroraSequence(os.clock())
    table.insert(Visual.themeCallbacks, function(newC)
        l.TextColor3 = newC.ACC
        lnGrad.Color = Visual.getAuroraSequence(os.clock())
    end)
end

function Visual.makeToggle(pi, tx, k, CFG, C, cb)
    C = C or {CARD2 = Color3.fromRGB(24,16,45), T1 = Color3.fromRGB(230,220,255), ON = Color3.fromRGB(100,255,160), T3 = Color3.fromRGB(120,110,150), W = Color3.fromRGB(230,220,255), OFF = Color3.fromRGB(255,80,80)}
    local rw = Instance.new("Frame", tPs[pi])
    rw.Size = UDim2.new(1, -4, 0, 36); rw.BackgroundColor3 = Color3.fromRGB(14, 8, 28)
    rw.BackgroundTransparency = 0.4; rw.BorderSizePixel = 0; rw.ZIndex = 18
    rw.LayoutOrder = po(pi); rw.ClipsDescendants = true
    Instance.new("UICorner", rw).CornerRadius = UDim.new(0, 8)

    -- Aurora accent bar
    local ind = Instance.new("Frame", rw)
    ind.Size = UDim2.new(0, 3, 0.5, 0); ind.Position = UDim2.new(0, 0, 0.25, 0)
    ind.BackgroundColor3 = CFG[k] and C.ON or C.T3; ind.BorderSizePixel = 0
    ind.ZIndex = 20; ind.BackgroundTransparency = CFG[k] and 0 or 0.6
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 2)

    local tl = Instance.new("TextLabel", rw)
    tl.Text = tx; tl.Size = UDim2.new(1, -60, 1, 0)
    tl.Position = UDim2.new(0, 14, 0, 0); tl.BackgroundTransparency = 1
    tl.TextColor3 = C.T1; tl.TextSize = 11; tl.Font = Enum.Font.GothamSemibold
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 20

    local pl = Instance.new("Frame", rw)
    pl.Size = UDim2.new(0, 40, 0, 20); pl.Position = UDim2.new(1, -48, 0.5, -10)
    pl.BackgroundColor3 = CFG[k] and C.ON or Color3.fromRGB(30, 18, 50)
    pl.BackgroundTransparency = CFG[k] and 0.15 or 0.35; pl.BorderSizePixel = 0; pl.ZIndex = 20
    Instance.new("UICorner", pl).CornerRadius = UDim.new(1, 0)

    local kb = Instance.new("Frame", pl)
    kb.Size = UDim2.new(0, 14, 0, 14)
    kb.Position = CFG[k] and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    kb.BackgroundColor3 = C.W; kb.BorderSizePixel = 0; kb.ZIndex = 21
    Instance.new("UICorner", kb).CornerRadius = UDim.new(1, 0)

    rw.MouseEnter:Connect(function() TS:Create(rw, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play() end)
    rw.MouseLeave:Connect(function() TS:Create(rw, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play() end)

    local bn = Instance.new("TextButton", rw)
    bn.Size = UDim2.new(1, 0, 1, 0); bn.BackgroundTransparency = 1; bn.Text = ""
    bn.ZIndex = 22; bn.ClipsDescendants = true
    bn.MouseButton1Click:Connect(function()
        CFG[k] = not CFG[k]
        local on = CFG[k]
        -- Aurora ripple at click position
        local mx = UIS:GetMouseLocation()
        local rx = mx.X - rw.AbsolutePosition.X
        local ry = mx.Y - rw.AbsolutePosition.Y
        Visual.Ripple(rw, rx, ry, on and C.ON or C.OFF)
        TS:Create(pl, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            BackgroundColor3 = on and C.ON or Color3.fromRGB(30, 18, 50),
            BackgroundTransparency = on and 0.15 or 0.35
        }):Play()
        TS:Create(kb, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Position = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
        TS:Create(ind, TweenInfo.new(0.2), {
            BackgroundColor3 = on and C.ON or C.T3,
            BackgroundTransparency = on and 0 or 0.6
        }):Play()
        if on then Visual.PulseGlow(rw, C.ON, 0.5) end
        if cb then cb(on) end
    end)
end

function Visual.makeSlider(pi, tx, k, mn, mx, st, CFG, C, allConnections)
    C = C or {T2 = Color3.fromRGB(180,170,210), ACC = Color3.fromRGB(130,70,220), W = Color3.fromRGB(230,220,255)}
    allConnections = allConnections or {}
    local rw = Instance.new("Frame", tPs[pi])
    rw.Size = UDim2.new(1, -4, 0, 44); rw.BackgroundTransparency = 1
    rw.ZIndex = 18; rw.LayoutOrder = po(pi)
    local ll = Instance.new("TextLabel", rw)
    ll.Text = tx; ll.Size = UDim2.new(0.55, 0, 0, 14)
    ll.BackgroundTransparency = 1; ll.TextColor3 = C.T2
    ll.TextSize = 10; ll.Font = Enum.Font.Gotham
    ll.TextXAlignment = Enum.TextXAlignment.Left; ll.ZIndex = 20
    local vl = Instance.new("TextLabel", rw)
    vl.Text = st < 1 and string.format("%.2f", CFG[k]) or tostring(math.floor(CFG[k]))
    vl.Size = UDim2.new(0.43, 0, 0, 14); vl.Position = UDim2.new(0.55, 0, 0, 0)
    vl.BackgroundTransparency = 1; vl.TextColor3 = C.ACC; vl.TextSize = 11
    vl.Font = Enum.Font.GothamBold; vl.TextXAlignment = Enum.TextXAlignment.Right; vl.ZIndex = 20

    local tr = Instance.new("Frame", rw)
    tr.Size = UDim2.new(1, 0, 0, 6); tr.Position = UDim2.new(0, 0, 0, 24)
    tr.BackgroundColor3 = Color3.fromRGB(25, 15, 40); tr.BackgroundTransparency = 0.2
    tr.BorderSizePixel = 0; tr.ZIndex = 20
    Instance.new("UICorner", tr).CornerRadius = UDim.new(0, 4)

    local pc = math.clamp((CFG[k] - mn) / (mx - mn), 0, 1)
    local fl = Instance.new("Frame", tr)
    fl.Size = UDim2.new(pc, 0, 1, 0); fl.BackgroundColor3 = Color3.new(1, 1, 1)
    fl.BorderSizePixel = 0; fl.ZIndex = 21
    Instance.new("UICorner", fl).CornerRadius = UDim.new(0, 4)
    local flGrad = Instance.new("UIGradient", fl)
    flGrad.Color = Visual.getAuroraSequence(os.clock())

    local kn = Instance.new("TextButton", tr)
    kn.Size = UDim2.new(0, 16, 0, 16); kn.AnchorPoint = Vector2.new(0.5, 0.5)
    kn.Position = UDim2.new(pc, 0, 0.5, 0); kn.BackgroundColor3 = C.W
    kn.Text = ""; kn.AutoButtonColor = false; kn.BorderSizePixel = 0; kn.ZIndex = 23
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
    local ks = Instance.new("UIStroke", kn)
    ks.Thickness = 1.5
    local ksGrad = Instance.new("UIGradient", ks)

    table.insert(Visual.themeCallbacks, function(newC)
        vl.TextColor3 = newC.ACC
        flGrad.Color = Visual.getAuroraSequence(os.clock())
        ksGrad.Color = Visual.getAuroraSequence(os.clock())
    end)

    local iD = false
    local function sV(v)
        if st > 0 then v = math.floor(v / st + 0.5) * st end
        v = math.clamp(v, mn, mx)
        CFG[k] = v
        local p = (v - mn) / (mx - mn)
        TS:Create(fl, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(p, 0, 1, 0)}):Play()
        TS:Create(kn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(p, 0, 0.5, 0)}):Play()
        vl.Text = st < 1 and string.format("%.2f", v) or tostring(math.floor(v))
    end
    kn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            iD = true
            TS:Create(kn, TweenInfo.new(0.15), {Size = UDim2.new(0, 20, 0, 20)}):Play()
        end
    end)
    table.insert(allConnections, UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and iD then
            iD = false; TS:Create(kn, TweenInfo.new(0.15), {Size = UDim2.new(0, 16, 0, 16)}):Play()
        end
    end))
    table.insert(allConnections, UIS.InputChanged:Connect(function(i)
        if iD and i.UserInputType == Enum.UserInputType.MouseMovement then
            local w = tr.AbsoluteSize.X
            if w > 0 then sV(mn + math.clamp((i.Position.X - tr.AbsolutePosition.X) / w, 0, 1) * (mx - mn)) end
        end
    end))
    tr.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local w = tr.AbsoluteSize.X
            if w > 0 then sV(mn + math.clamp((i.Position.X - tr.AbsolutePosition.X) / w, 0, 1) * (mx - mn)) end
        end
    end)
end

function Visual.makeCycle(pi, tx, opts, k, CFG, C, cb)
    C = C or {CARD2 = Color3.fromRGB(24,16,45), T1 = Color3.fromRGB(230,220,255), ACC = Color3.fromRGB(130,70,220)}
    local idx = CFG[k] or 1
    local rw = Instance.new("Frame", tPs[pi])
    rw.Size = UDim2.new(1, -4, 0, 36); rw.BackgroundColor3 = Color3.fromRGB(14, 8, 28)
    rw.BackgroundTransparency = 0.4; rw.BorderSizePixel = 0; rw.ZIndex = 18
    rw.LayoutOrder = po(pi); rw.ClipsDescendants = true
    Instance.new("UICorner", rw).CornerRadius = UDim.new(0, 8)
    local ll = Instance.new("TextLabel", rw)
    ll.Text = tx; ll.Size = UDim2.new(0.5, 0, 1, 0)
    ll.Position = UDim2.new(0, 12, 0, 0); ll.BackgroundTransparency = 1
    ll.TextColor3 = C.T1; ll.TextSize = 11; ll.Font = Enum.Font.GothamSemibold
    ll.TextXAlignment = Enum.TextXAlignment.Left; ll.ZIndex = 20
    local rl = Instance.new("TextLabel", rw)
    rl.Text = tostring(opts[idx]); rl.Size = UDim2.new(0.42, 0, 1, 0)
    rl.Position = UDim2.new(0.5, 0, 0, 0); rl.BackgroundTransparency = 1
    rl.TextColor3 = C.ACC; rl.TextSize = 11; rl.Font = Enum.Font.GothamBold
    rl.TextXAlignment = Enum.TextXAlignment.Right; rl.ZIndex = 20
    rw.MouseEnter:Connect(function() TS:Create(rw, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play() end)
    rw.MouseLeave:Connect(function() TS:Create(rw, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play() end)
    local bn = Instance.new("TextButton", rw)
    bn.Size = UDim2.new(1, 0, 1, 0); bn.BackgroundTransparency = 1; bn.Text = ""; bn.ZIndex = 22
    bn.MouseButton1Click:Connect(function()
        local mx = UIS:GetMouseLocation()
        Visual.Ripple(rw, mx.X - rw.AbsolutePosition.X, mx.Y - rw.AbsolutePosition.Y, C.ACC)
        idx = idx % #opts + 1; CFG[k] = idx; rl.Text = tostring(opts[idx])
        if cb then cb(idx) end
    end)
    table.insert(Visual.themeCallbacks, function(newC) rl.TextColor3 = newC.ACC end)
end

function Visual.makeRebind(pi, lb, ck, CFG, C, allConnections)
    C = C or {CARD2 = Color3.fromRGB(24,16,45), T1 = Color3.fromRGB(230,220,255), ACC = Color3.fromRGB(130,70,220), WARN = Color3.fromRGB(255,210,100)}
    allConnections = allConnections or {}
    local rw = Instance.new("Frame", tPs[pi])
    rw.Size = UDim2.new(1, -4, 0, 36); rw.BackgroundColor3 = Color3.fromRGB(14, 8, 28)
    rw.BackgroundTransparency = 0.4; rw.BorderSizePixel = 0; rw.ZIndex = 18
    rw.LayoutOrder = po(pi); rw.ClipsDescendants = true
    Instance.new("UICorner", rw).CornerRadius = UDim.new(0, 8)
    local ll = Instance.new("TextLabel", rw)
    ll.Text = lb; ll.Size = UDim2.new(0.5, 0, 1, 0); ll.Position = UDim2.new(0, 12, 0, 0)
    ll.BackgroundTransparency = 1; ll.TextColor3 = C.T1; ll.TextSize = 11
    ll.Font = Enum.Font.GothamSemibold; ll.TextXAlignment = Enum.TextXAlignment.Left; ll.ZIndex = 20
    local vl = Instance.new("TextLabel", rw)
    vl.Text = "[ " .. CFG[ck] .. " ]"; vl.Size = UDim2.new(0.44, 0, 1, 0)
    vl.Position = UDim2.new(0.5, 0, 0, 0); vl.BackgroundTransparency = 1
    vl.TextColor3 = C.ACC; vl.TextSize = 12; vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Right; vl.ZIndex = 20
    rw.MouseEnter:Connect(function() TS:Create(rw, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play() end)
    rw.MouseLeave:Connect(function() TS:Create(rw, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play() end)
    local rebinding = false
    local bn = Instance.new("TextButton", rw)
    bn.Size = UDim2.new(1, 0, 1, 0); bn.BackgroundTransparency = 1; bn.Text = ""; bn.ZIndex = 22
    bn.MouseButton1Click:Connect(function()
        Visual.Ripple(rw, rw.AbsoluteSize.X / 2, rw.AbsoluteSize.Y / 2, C.WARN)
        vl.Text = "press..."; vl.TextColor3 = C.WARN; rebinding = true
        local cn
        cn = UIS.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                local n = inp.KeyCode.Name
                if n ~= "Unknown" then
                    CFG[ck] = n; vl.Text = "[ " .. n .. " ]"; vl.TextColor3 = C.ACC
                    rebinding = false; pcall(function() cn:Disconnect() end)
                end
            end
        end)
        task.delay(5, function()
            if rebinding then rebinding = false; vl.Text = "[ " .. CFG[ck] .. " ]"; vl.TextColor3 = C.ACC; pcall(function() cn:Disconnect() end) end
        end)
    end)
    table.insert(Visual.themeCallbacks, function(newC) vl.TextColor3 = newC.ACC end)
    return rebinding
end

function Visual.makeInfo(pi, tx, C)
    C = C or {T3 = Color3.fromRGB(120, 110, 150)}
    local l = Instance.new("TextLabel", tPs[pi])
    l.Size = UDim2.new(1, -4, 0, 14); l.BackgroundTransparency = 1; l.Text = tx
    l.TextColor3 = C.T3; l.TextSize = 9; l.Font = Enum.Font.Code
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 20; l.LayoutOrder = po(pi)
end

function Visual.makeLabel(pi, C)
    C = C or {ACC = Color3.fromRGB(130, 70, 220)}
    local lbl = Instance.new("TextLabel", tPs[pi])
    lbl.Text = ""; lbl.Size = UDim2.new(1, -8, 0, 18); lbl.BackgroundTransparency = 1
    lbl.TextColor3 = C.ACC; lbl.TextSize = 13; lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 20; lbl.LayoutOrder = po(pi)
    return lbl
end

-- =============================================
--          RAGE WINDOW
-- =============================================
local rageOpen = false
local rageGui = Instance.new("Frame", gui)
rageGui.Size = UDim2.new(0, 360, 0, 320); rageGui.Position = UDim2.new(0.5, -180, 0.5, -160)
rageGui.BackgroundColor3 = Color3.fromRGB(16, 6, 6); rageGui.BackgroundTransparency = 0.04
rageGui.BorderSizePixel = 0; rageGui.Visible = false; rageGui.ZIndex = 100; rageGui.ClipsDescendants = true
Instance.new("UICorner", rageGui).CornerRadius = UDim.new(0, 14)
local rageStroke = Instance.new("UIStroke", rageGui)
rageStroke.Color = Color3.fromRGB(200, 40, 40); rageStroke.Thickness = 1.5; rageStroke.Transparency = 0.3

local rageTB = Instance.new("Frame", rageGui)
rageTB.Size = UDim2.new(1, 0, 0, 42); rageTB.BackgroundColor3 = Color3.fromRGB(25, 8, 8)
rageTB.BackgroundTransparency = 0.1; rageTB.BorderSizePixel = 0; rageTB.ZIndex = 101
Instance.new("UICorner", rageTB).CornerRadius = UDim.new(0, 14)
local rageTitle = Instance.new("TextLabel", rageTB)
rageTitle.Text = " RAGE MODE"; rageTitle.Size = UDim2.new(1, -16, 1, 0)
rageTitle.Position = UDim2.new(0, 16, 0, 0); rageTitle.BackgroundTransparency = 1
rageTitle.TextColor3 = Color3.fromRGB(255, 80, 80); rageTitle.TextSize = 14
rageTitle.Font = Enum.Font.GothamBold; rageTitle.TextXAlignment = Enum.TextXAlignment.Left; rageTitle.ZIndex = 102
local rageLine = Instance.new("Frame", rageTB)
rageLine.Size = UDim2.new(1, 0, 0, 2); rageLine.Position = UDim2.new(0, 0, 1, -2)
rageLine.BackgroundColor3 = Color3.fromRGB(255, 40, 40); rageLine.BorderSizePixel = 0; rageLine.ZIndex = 102

local rageClose = Instance.new("TextButton", rageTB)
rageClose.Text = ""; rageClose.Size = UDim2.new(0, 32, 0, 26)
rageClose.Position = UDim2.new(1, -38, 0.5, -13); rageClose.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
rageClose.BackgroundTransparency = 0.35; rageClose.TextColor3 = Color3.fromRGB(255, 150, 150)
rageClose.TextSize = 12; rageClose.Font = Enum.Font.GothamBold; rageClose.BorderSizePixel = 0
rageClose.ZIndex = 103; rageClose.ClipsDescendants = true; rageClose.AutoButtonColor = false
Instance.new("UICorner", rageClose).CornerRadius = UDim.new(0, 7)
rageClose.MouseEnter:Connect(function() TS:Create(rageClose, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play() end)
rageClose.MouseLeave:Connect(function() TS:Create(rageClose, TweenInfo.new(0.2), {BackgroundTransparency = 0.35}):Play() end)
rageClose.MouseButton1Click:Connect(function()
    rageOpen = false
    TS:Create(rageGui, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 180, 0, 160), BackgroundTransparency = 1
    }):Play()
    task.delay(0.35, function() rageGui.Visible = false end)
end)

Visual._rageDragState = {drag = false, start = nil, pos = nil}
rageTB.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        Visual._rageDragState.drag = true; Visual._rageDragState.start = i.Position; Visual._rageDragState.pos = rageGui.Position
    end
end)
rageTB.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then Visual._rageDragState.drag = false end
end)

local rageContent = Instance.new("ScrollingFrame", rageGui)
rageContent.Size = UDim2.new(1, 0, 1, -46); rageContent.Position = UDim2.new(0, 0, 0, 46)
rageContent.BackgroundTransparency = 1; rageContent.ScrollBarThickness = 3
rageContent.ScrollBarImageColor3 = Color3.fromRGB(255, 60, 60); rageContent.ScrollBarImageTransparency = 0.5
rageContent.BorderSizePixel = 0; rageContent.ZIndex = 101; rageContent.ScrollingDirection = Enum.ScrollingDirection.Y
local rageLayout = Instance.new("UIListLayout", rageContent)
rageLayout.Padding = UDim.new(0, 6); rageLayout.SortOrder = Enum.SortOrder.LayoutOrder
rageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    rageContent.CanvasSize = UDim2.new(0, 0, 0, rageLayout.AbsoluteContentSize.Y + 20)
end)
local ragePad = Instance.new("UIPadding", rageContent)
ragePad.PaddingTop = UDim.new(0, 10); ragePad.PaddingLeft = UDim.new(0, 14)
ragePad.PaddingRight = UDim.new(0, 14); ragePad.PaddingBottom = UDim.new(0, 14)

Visual.rageGui = rageGui; Visual.rageContent = rageContent; Visual.rageOpen = rageOpen

local rageOrder = 0
function Visual.rageSection(tx)
    rageOrder = rageOrder + 1
    local f = Instance.new("Frame", rageContent)
    f.Size = UDim2.new(1, -4, 0, 24); f.BackgroundTransparency = 1
    f.LayoutOrder = rageOrder; f.ZIndex = 102
    local l = Instance.new("TextLabel", f)
    l.Text = string.upper(tx); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(255, 80, 80); l.TextSize = 10; l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 103
    local ln = Instance.new("Frame", f)
    ln.Size = UDim2.new(1, 0, 0, 1); ln.Position = UDim2.new(0, 0, 1, -1)
    ln.BackgroundColor3 = Color3.fromRGB(255, 60, 60); ln.BackgroundTransparency = 0.6
    ln.BorderSizePixel = 0; ln.ZIndex = 103
end

function Visual.rageToggle(tx, k, CFG, cb)
    rageOrder = rageOrder + 1
    local rw = Instance.new("Frame", rageContent)
    rw.Size = UDim2.new(1, -4, 0, 36); rw.BackgroundColor3 = Color3.fromRGB(30, 12, 12)
    rw.BackgroundTransparency = 0.3; rw.BorderSizePixel = 0; rw.ZIndex = 102
    rw.LayoutOrder = rageOrder; rw.ClipsDescendants = true
    Instance.new("UICorner", rw).CornerRadius = UDim.new(0, 8)
    local ind = Instance.new("Frame", rw)
    ind.Size = UDim2.new(0, 3, 0.5, 0); ind.Position = UDim2.new(0, 0, 0.25, 0)
    ind.BackgroundColor3 = CFG[k] and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(120, 110, 150)
    ind.BorderSizePixel = 0; ind.ZIndex = 104; ind.BackgroundTransparency = CFG[k] and 0 or 0.6
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 2)
    local tl = Instance.new("TextLabel", rw)
    tl.Text = tx; tl.Size = UDim2.new(1, -58, 1, 0); tl.Position = UDim2.new(0, 14, 0, 0)
    tl.BackgroundTransparency = 1; tl.TextColor3 = Color3.fromRGB(230, 200, 200)
    tl.TextSize = 11; tl.Font = Enum.Font.GothamSemibold; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 103
    local pl = Instance.new("Frame", rw)
    pl.Size = UDim2.new(0, 40, 0, 20); pl.Position = UDim2.new(1, -48, 0.5, -10)
    pl.BackgroundColor3 = CFG[k] and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(40, 20, 20)
    pl.BackgroundTransparency = CFG[k] and 0.15 or 0.4; pl.BorderSizePixel = 0; pl.ZIndex = 103
    Instance.new("UICorner", pl).CornerRadius = UDim.new(1, 0)
    local kb = Instance.new("Frame", pl)
    kb.Size = UDim2.new(0, 14, 0, 14)
    kb.Position = CFG[k] and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    kb.BackgroundColor3 = Color3.fromRGB(255, 230, 230); kb.BorderSizePixel = 0; kb.ZIndex = 104
    Instance.new("UICorner", kb).CornerRadius = UDim.new(1, 0)
    rw.MouseEnter:Connect(function() TS:Create(rw, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play() end)
    rw.MouseLeave:Connect(function() TS:Create(rw, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play() end)
    local bn = Instance.new("TextButton", rw)
    bn.Size = UDim2.new(1, 0, 1, 0); bn.BackgroundTransparency = 1; bn.Text = ""; bn.ZIndex = 105; bn.ClipsDescendants = true
    bn.MouseButton1Click:Connect(function()
        CFG[k] = not CFG[k]
        local on = CFG[k]
        local mpos = UIS:GetMouseLocation()
        Visual.Ripple(rw, mpos.X - rw.AbsolutePosition.X, mpos.Y - rw.AbsolutePosition.Y,
            on and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(100, 40, 40))
        TS:Create(pl, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            BackgroundColor3 = on and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(40, 20, 20),
            BackgroundTransparency = on and 0.15 or 0.4
        }):Play()
        TS:Create(kb, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Position = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
        TS:Create(ind, TweenInfo.new(0.2), {
            BackgroundColor3 = on and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(120, 110, 150),
            BackgroundTransparency = on and 0 or 0.6
        }):Play()
        if cb then cb(on) end
    end)
end

function Visual.rageInfo(tx)
    rageOrder = rageOrder + 1
    local l = Instance.new("TextLabel", rageContent)
    l.Size = UDim2.new(1, -4, 0, 14); l.BackgroundTransparency = 1; l.Text = tx
    l.TextColor3 = Color3.fromRGB(150, 100, 100); l.TextSize = 9; l.Font = Enum.Font.Code
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 103; l.LayoutOrder = rageOrder
end

-- Rage button
local rageBtn = Instance.new("TextButton", gui)
rageBtn.Size = UDim2.new(0, 110, 0, 34); rageBtn.Position = UDim2.new(0, 20, 1, -54)
rageBtn.BackgroundColor3 = Color3.fromRGB(120, 16, 16); rageBtn.BackgroundTransparency = 0.12
rageBtn.Text = " RAGE"; rageBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
rageBtn.TextSize = 12; rageBtn.Font = Enum.Font.GothamBold; rageBtn.BorderSizePixel = 0
rageBtn.ZIndex = 50; rageBtn.Visible = false; rageBtn.AutoButtonColor = false; rageBtn.ClipsDescendants = true
Instance.new("UICorner", rageBtn).CornerRadius = UDim.new(0, 10)
local rageBtnStroke = Instance.new("UIStroke", rageBtn)
rageBtnStroke.Color = Color3.fromRGB(200, 40, 40); rageBtnStroke.Thickness = 1; rageBtnStroke.Transparency = 0.4
rageBtn.MouseEnter:Connect(function() TS:Create(rageBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play() end)
rageBtn.MouseLeave:Connect(function() TS:Create(rageBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.12}):Play() end)
rageBtn.MouseButton1Click:Connect(function()
    Visual.Ripple(rageBtn, rageBtn.AbsoluteSize.X / 2, rageBtn.AbsoluteSize.Y / 2, Color3.fromRGB(255, 60, 60))
    if rageOpen then
        rageOpen = false
        TS:Create(rageGui, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 180, 0, 160), BackgroundTransparency = 1
        }):Play()
        task.delay(0.35, function() rageGui.Visible = false end)
    else
        rageOpen = true; rageGui.Visible = true
        rageGui.Size = UDim2.new(0, 180, 0, 160); rageGui.BackgroundTransparency = 1
        TS:Create(rageGui, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 360, 0, 320), BackgroundTransparency = 0.04
        }):Play()
    end
end)
Visual.rageBtn = rageBtn

-- =============================================
--          OPEN / CLOSE MENU (CURSOR FIX)
-- =============================================
local isOpen = false
Visual.isOpen = false
local savedMouseBehavior = nil
local savedMouseIcon = nil

function Visual.openMenu(CFG)
    isOpen = true; Visual.isOpen = true
    W.Visible = true; moonContainer.Visible = true
    dimOverlay.Visible = true; rageBtn.Visible = true
    wW, wH = Visual.getWS(CFG)
    dimOverlay.BackgroundTransparency = 1
    TS:Create(dimOverlay, TweenInfo.new(0.35), {BackgroundTransparency = 0.5}):Play()
    W.Size = UDim2.new(0, wW * 0.85, 0, wH * 0.85)
    W.Position = UDim2.new(0.5, -wW * 0.425, 0.5, -wH * 0.425)
    W.BackgroundTransparency = 0.5
    TS:Create(W, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, wW, 0, wH),
        Position = UDim2.new(0.5, -wW / 2, 0.5, -wH / 2),
        BackgroundTransparency = 0.04
    }):Play()
    TS:Create(blurMain, TweenInfo.new(0.35), {Size = 18}):Play()

    -- Save current mouse state and unlock
    pcall(function()
        savedMouseBehavior = UIS.MouseBehavior
        savedMouseIcon = UIS.MouseIconEnabled
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = true
    end)
    Visual.Notify("Moon", "INSERT to close", 2, Visual.getAuroraColor(os.clock()))
end

function Visual.closeMenu(CFG)
    isOpen = false; Visual.isOpen = false
    moonContainer.Visible = false; rageBtn.Visible = false
    if rageOpen then rageOpen = false; rageGui.Visible = false end
    TS:Create(dimOverlay, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    TS:Create(W, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Size = UDim2.new(0, wW * 0.85, 0, wH * 0.85),
        Position = UDim2.new(0.5, -wW * 0.425, 0.5, -wH * 0.425),
        BackgroundTransparency = 1
    }):Play()
    TS:Create(blurMain, TweenInfo.new(0.25), {Size = 0}):Play()
    task.delay(0.35, function()
        pcall(function()
            if not isOpen then W.Visible = false; dimOverlay.Visible = false end
        end)
    end)

    -- Restore mouse to saved state (proper fix)
    pcall(function()
        if savedMouseBehavior then
            UIS.MouseBehavior = savedMouseBehavior
        else
            UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
        if savedMouseIcon ~= nil then
            UIS.MouseIconEnabled = savedMouseIcon
        end
    end)
end

-- =============================================
--      ANIMATION UPDATE (AURORA EVERYWHERE)
-- =============================================
function Visual.updateAnimations(dt, globalT)
    local aSeq = Visual.getAuroraSequence(globalT)

    -- Watermark aurora
    pcall(function() Visual._wmGrad.Color = aSeq end)
    pcall(function() Visual._wmStGrad.Color = aSeq end)
    pcall(function() Visual.wmTime.Text = os.date("%H:%M") end)

    if not isOpen then return end

    -- Window aurora gradient background
    pcall(function()
        Visual._auroraBgGrad.Color = aSeq
        Visual._auroraBgGrad.Rotation = 25 + math.sin(globalT * 0.15) * 20
    end)

    -- Window stroke aurora
    pcall(function() Visual._gStGrad.Color = aSeq end)

    -- Title line aurora
    pcall(function() Visual._tLGrad.Color = aSeq end)

    -- Tab indicator aurora
    pcall(function() Visual._tabIndGrad.Color = aSeq end)

    -- Binds window aurora
    pcall(function() Visual._bwStGrad.Color = aSeq end)
    pcall(function() Visual._bwTopGrad.Color = aSeq end)

    -- HUD stroke aurora
    pcall(function() Visual._hudStGrad.Color = aSeq end)

    -- Stars twinkling
    for idx, star in ipairs(guiStars) do
        pcall(function()
            star.BackgroundTransparency = 0.45 + math.sin(globalT * (1.2 + idx * 0.25)) * 0.3
            star.BackgroundColor3 = Visual.getAuroraColor(globalT, idx * 0.4)
        end)
    end

    -- Moon float + aurora glow
    pcall(function()
        moonContainer.Position = UDim2.new(1, -140, 0, -15 + math.sin(globalT * 0.5) * 6)
        moonGlowFrame.BackgroundTransparency = 0.65 + math.sin(globalT * 0.6) * 0.15
        moonGlowFrame.BackgroundColor3 = Visual.getAuroraColor(globalT, 2)
        moonGlowFrame.Size = UDim2.new(0, 75 + math.sin(globalT * 0.4) * 6, 0, 75 + math.sin(globalT * 0.4) * 6)
        moonGlowFrame.Position = UDim2.new(1, -90 - math.sin(globalT * 0.4) * 3, 0, -8 - math.sin(globalT * 0.4) * 3)
        moonGlow2.BackgroundTransparency = 0.82 + math.sin(globalT * 0.3) * 0.08
        moonGlow2.BackgroundColor3 = Visual.getAuroraColor(globalT, 0.5)
    end)
end

-- =============================================
--      DRAG HANDLER
-- =============================================
function Visual.handleDrag(inputPos)
    if Visual._dragState.drag and Visual._dragState.start and Visual._dragState.pos then
        local d = inputPos - Visual._dragState.start
        W.Position = UDim2.new(Visual._dragState.pos.X.Scale, Visual._dragState.pos.X.Offset + d.X, Visual._dragState.pos.Y.Scale, Visual._dragState.pos.Y.Offset + d.Y)
    end
    if Visual._bwDragState.drag and Visual._bwDragState.start and Visual._bwDragState.pos then
        local d = inputPos - Visual._bwDragState.start
        bindsWindow.Position = UDim2.new(Visual._bwDragState.pos.X.Scale, Visual._bwDragState.pos.X.Offset + d.X, Visual._bwDragState.pos.Y.Scale, Visual._bwDragState.pos.Y.Offset + d.Y)
    end
    if Visual._rageDragState.drag and Visual._rageDragState.start and Visual._rageDragState.pos then
        local d = inputPos - Visual._rageDragState.start
        rageGui.Position = UDim2.new(Visual._rageDragState.pos.X.Scale, Visual._rageDragState.pos.X.Offset + d.X, Visual._rageDragState.pos.Y.Scale, Visual._rageDragState.pos.Y.Offset + d.Y)
    end
end

function Visual.destroy()
    pcall(function() blurMain:Destroy() end)
    pcall(function() gui:Destroy() end)
    pcall(function() screenGui:Destroy() end)
end

return Visual
