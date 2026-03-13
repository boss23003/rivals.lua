--[[
    MOON v2.3 — VISUAL MODULE
    Full aurora gradient, fixed toggles, redesigned binds
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
    local speed = 0.35
    local idx = ((t * speed + offset) % #auroraColors)
    local i1 = math.floor(idx) % #auroraColors + 1
    local i2 = (i1 % #auroraColors) + 1
    local frac = idx - math.floor(idx)
    return auroraColors[i1]:Lerp(auroraColors[i2], frac)
end

function Visual.getAuroraSequence(t)
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0, Visual.getAuroraColor(t, 0)),
        ColorSequenceKeypoint.new(0.33, Visual.getAuroraColor(t, 1.5)),
        ColorSequenceKeypoint.new(0.66, Visual.getAuroraColor(t, 3)),
        ColorSequenceKeypoint.new(1, Visual.getAuroraColor(t, 4.5)),
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
        ns.Thickness = 1.5; ns.Transparency = 0.2
        local nsGrad = Instance.new("UIGradient", ns)
        nsGrad.Color = Visual.getAuroraSequence(os.clock())
        local tl = Instance.new("TextLabel", nf)
        tl.Text = title or ""; tl.Size = UDim2.new(1, -16, 0, 20)
        tl.Position = UDim2.new(0, 12, 0, 8); tl.BackgroundTransparency = 1
        tl.TextColor3 = Color3.new(1, 1, 1); tl.TextSize = 13
        tl.Font = Enum.Font.GothamBold; tl.TextXAlignment = Enum.TextXAlignment.Left
        local dl = Instance.new("TextLabel", nf)
        dl.Text = text or ""; dl.Size = UDim2.new(1, -16, 0, 16)
        dl.Position = UDim2.new(0, 12, 0, 30); dl.BackgroundTransparency = 1
        dl.TextColor3 = Color3.fromRGB(180, 170, 200); dl.TextSize = 11
        dl.Font = Enum.Font.Gotham; dl.TextXAlignment = Enum.TextXAlignment.Left
        local bar = Instance.new("Frame", nf)
        bar.Size = UDim2.new(1, 0, 0, 2); bar.Position = UDim2.new(0, 0, 1, -2)
        bar.BorderSizePixel = 0; bar.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UIGradient", bar).Color = Visual.getAuroraSequence(os.clock())
        nf.Position = UDim2.new(1, 60, 0, 0)
        TS:Create(nf, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        local bt = TS:Create(bar, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)})
        bt:Play()
        local c; c = bt.Completed:Connect(function()
            pcall(function() c:Disconnect() end)
            local ot = TS:Create(nf, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 60, 0, 0), BackgroundTransparency = 1})
            ot:Play()
            local c2; c2 = ot.Completed:Connect(function() pcall(function() c2:Disconnect() end); pcall(function() nf:Destroy() end) end)
        end)
    end)
end

-- =============================================
--          AURORA RIPPLE (AT CLICK POS)
-- =============================================
function Visual.Ripple(btn, x, y)
    pcall(function()
        if not btn or not btn.Parent then return end
        local r = Instance.new("Frame", btn)
        r.BackgroundColor3 = Color3.new(1, 1, 1); r.BackgroundTransparency = 0.2
        r.BorderSizePixel = 0; r.ZIndex = btn.ZIndex + 1
        Instance.new("UICorner", r).CornerRadius = UDim.new(1, 0)
        local rGrad = Instance.new("UIGradient", r)
        rGrad.Color = Visual.getAuroraSequence(os.clock())
        rGrad.Rotation = math.random(0, 360)
        local maxSz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.2
        r.Size = UDim2.new(0, 0, 0, 0)
        r.Position = UDim2.new(0, x or 0, 0, y or 0)
        r.AnchorPoint = Vector2.new(0.5, 0.5)
        local t = TS:Create(r, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, maxSz, 0, maxSz), BackgroundTransparency = 1})
        t:Play()
        local c; c = t.Completed:Connect(function() pcall(function() c:Disconnect() end); pcall(function() r:Destroy() end) end)
    end)
end

-- =============================================
--          SCALING
-- =============================================
local _sc, _scT = 1, 0
function Visual.getScale()
    if os.clock() - _scT < 0.5 then return _sc end
    local cam = workspace.CurrentCamera
    if cam then _sc = math.clamp(math.min(cam.ViewportSize.X / BASE_W, cam.ViewportSize.Y / BASE_H), 0.4, 4) end
    _scT = os.clock(); return _sc
end
function Visual.S(v) return v * Visual.getScale() end
function Visual.getVP()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1920, 1080)
end
function Visual.getCenter()
    local vp = Visual.getVP(); return vp.X * 0.5, vp.Y * 0.5
end

-- =============================================
--          WATERMARK
-- =============================================
local wm = Instance.new("Frame", screenGui)
wm.Size = UDim2.new(0, 180, 0, 28)
wm.Position = UDim2.new(0, 20, 0, 20)
wm.BackgroundColor3 = Color3.fromRGB(6, 3, 12)
wm.BackgroundTransparency = 0.06; wm.BorderSizePixel = 0
Instance.new("UICorner", wm).CornerRadius = UDim.new(0, 8)
local wmSt = Instance.new("UIStroke", wm); wmSt.Thickness = 1; wmSt.Transparency = 0.2
local wmStGrad = Instance.new("UIGradient", wmSt)
Visual._wmStGrad = wmStGrad
local wmTxt = Instance.new("TextLabel", wm)
wmTxt.Size = UDim2.new(1, -60, 1, 0); wmTxt.Position = UDim2.new(0, 8, 0, 0)
wmTxt.BackgroundTransparency = 1; wmTxt.Text = "MOON"
wmTxt.TextColor3 = Color3.fromRGB(220, 200, 255); wmTxt.TextSize = 11
wmTxt.Font = Enum.Font.GothamBold; wmTxt.TextXAlignment = Enum.TextXAlignment.Left
local wmTime = Instance.new("TextLabel", wm)
wmTime.Size = UDim2.new(0, 48, 1, 0); wmTime.Position = UDim2.new(1, -52, 0, 0)
wmTime.BackgroundTransparency = 1; wmTime.TextColor3 = Color3.fromRGB(120, 100, 160)
wmTime.TextSize = 9; wmTime.Font = Enum.Font.Code; wmTime.TextXAlignment = Enum.TextXAlignment.Right
wmTime.Text = ""
Visual.wmTime = wmTime

-- =============================================
--          LOADING SCREEN
-- =============================================
function Visual.showLoadingScreen()
    local loadGui = Instance.new("ScreenGui"); loadGui.Name = "MoonLoad"
    loadGui.ResetOnSpawn = false; loadGui.DisplayOrder = 10000; loadGui.IgnoreGuiInset = true
    local ok2 = false
    if gethui then ok2 = pcall(function() loadGui.Parent = gethui() end) end
    if not ok2 then pcall(function() loadGui.Parent = game.CoreGui end) end
    if not loadGui.Parent then loadGui.Parent = LP.PlayerGui end
    local blur = Instance.new("BlurEffect"); blur.Name = "MoonLoadBlur"; blur.Size = 0; blur.Parent = Lighting
    local loadDim = Instance.new("Frame", loadGui)
    loadDim.Size = UDim2.new(1, 0, 1, 0); loadDim.BackgroundColor3 = Color3.fromRGB(3, 1, 8)
    loadDim.BackgroundTransparency = 0.2; loadDim.BorderSizePixel = 0
    local card = Instance.new("Frame", loadGui)
    card.Size = UDim2.new(0, 340, 0, 100); card.Position = UDim2.new(0.5, -170, 0.5, -50)
    card.BackgroundColor3 = Color3.fromRGB(10, 6, 20); card.BackgroundTransparency = 1; card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
    local cSt = Instance.new("UIStroke", card); cSt.Thickness = 1.5; cSt.Transparency = 1
    local cStGrad = Instance.new("UIGradient", cSt)
    local lTitle = Instance.new("TextLabel", card)
    lTitle.Text = "MOON"; lTitle.Size = UDim2.new(1, 0, 0, 24)
    lTitle.Position = UDim2.new(0, 0, 0, 14); lTitle.BackgroundTransparency = 1
    lTitle.TextColor3 = Color3.fromRGB(200, 170, 255); lTitle.TextTransparency = 1
    lTitle.TextSize = 18; lTitle.Font = Enum.Font.GothamBold; lTitle.TextXAlignment = Enum.TextXAlignment.Center
    local lSub = Instance.new("TextLabel", card)
    lSub.Text = "loading..."; lSub.Size = UDim2.new(1, 0, 0, 14)
    lSub.Position = UDim2.new(0, 0, 0, 42); lSub.BackgroundTransparency = 1
    lSub.TextColor3 = Color3.fromRGB(140, 120, 170); lSub.TextTransparency = 1
    lSub.TextSize = 10; lSub.Font = Enum.Font.Gotham; lSub.TextXAlignment = Enum.TextXAlignment.Center
    local lBarBg = Instance.new("Frame", card)
    lBarBg.Size = UDim2.new(0, 0, 0, 3); lBarBg.Position = UDim2.new(0.5, 0, 0, 68)
    lBarBg.AnchorPoint = Vector2.new(0.5, 0); lBarBg.BackgroundColor3 = Color3.fromRGB(25, 15, 40)
    lBarBg.BackgroundTransparency = 1; lBarBg.BorderSizePixel = 0
    Instance.new("UICorner", lBarBg).CornerRadius = UDim.new(1, 0)
    local lBarFill = Instance.new("Frame", lBarBg)
    lBarFill.Size = UDim2.new(0, 0, 1, 0); lBarFill.BackgroundColor3 = Color3.new(1, 1, 1)
    lBarFill.BorderSizePixel = 0; Instance.new("UICorner", lBarFill).CornerRadius = UDim.new(1, 0)
    local lBarGrad = Instance.new("UIGradient", lBarFill)
    TS:Create(blur, TweenInfo.new(0.5), {Size = 16}):Play()
    TS:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.06}):Play()
    TS:Create(cSt, TweenInfo.new(0.5), {Transparency = 0.15}):Play()
    TS:Create(lTitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TS:Create(lSub, TweenInfo.new(0.5), {TextTransparency = 0.15}):Play()
    TS:Create(lBarBg, TweenInfo.new(0.4), {Size = UDim2.new(0, 260, 0, 3), BackgroundTransparency = 0.4}):Play()
    local stages = {{15,"mapping"},{30,"patching"},{50,"injecting"},{70,"bypassing"},{90,"loading"},{100,"ready"}}
    task.spawn(function()
        task.wait(0.6)
        for _, s in ipairs(stages) do
            lBarGrad.Color = Visual.getAuroraSequence(os.clock())
            cStGrad.Color = Visual.getAuroraSequence(os.clock())
            TS:Create(lBarFill, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(s[1]/100, 0, 1, 0)}):Play()
            lSub.Text = s[2]; task.wait(math.random(10, 22) * 0.01)
        end
        lSub.Text = "complete"; lSub.TextColor3 = Color3.fromRGB(140, 255, 180)
        task.wait(0.4)
        TS:Create(card, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TS:Create(cSt, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TS:Create(lTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TS:Create(lSub, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TS:Create(lBarFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TS:Create(lBarBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TS:Create(loadDim, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TS:Create(blur, TweenInfo.new(0.3), {Size = 0}):Play()
        task.wait(0.4)
        pcall(function() blur:Destroy() end); pcall(function() loadGui:Destroy() end)
    end)
end

-- =============================================
--          CLEANUP OLD
-- =============================================
for _, n in ipairs({"SakuraGUI_v19","SakuraGUI_v18","SakuraGUI","SakuraGUI_v20","MoonGUI_Main"}) do
    pcall(function() if game.CoreGui:FindFirstChild(n) then game.CoreGui[n]:Destroy() end end)
    pcall(function() if gethui and gethui():FindFirstChild(n) then gethui()[n]:Destroy() end end)
end
for _, v in pairs(Lighting:GetChildren()) do
    if v.Name:find("SakuraMainBlur") or v.Name:find("MoonBlur") then pcall(function() v:Destroy() end) end
end

-- =============================================
--          MAIN GUI
-- =============================================
local blurMain = Instance.new("BlurEffect", Lighting); blurMain.Name = "MoonBlur"; blurMain.Size = 0
Visual.blurMain = blurMain

local gui = Instance.new("ScreenGui"); gui.Name = "MoonGUI_Main"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.DisplayOrder = 999; gui.IgnoreGuiInset = true
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

local dimOverlay = Instance.new("Frame", gui)
dimOverlay.Size = UDim2.new(1, 0, 1, 0); dimOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
dimOverlay.BackgroundTransparency = 1; dimOverlay.BorderSizePixel = 0; dimOverlay.ZIndex = 8; dimOverlay.Visible = false
Visual.dimOverlay = dimOverlay

-- =============================================
--      BINDS DISPLAY (REDESIGNED — COMPACT)
-- =============================================
local bindsFrame = Instance.new("Frame", screenGui)
bindsFrame.Size = UDim2.new(0, 160, 0, 24)
bindsFrame.Position = UDim2.new(1, -180, 0, 54)
bindsFrame.BackgroundColor3 = Color3.fromRGB(6, 3, 12)
bindsFrame.BackgroundTransparency = 0.06; bindsFrame.BorderSizePixel = 0; bindsFrame.ZIndex = 50
bindsFrame.ClipsDescendants = true
Instance.new("UICorner", bindsFrame).CornerRadius = UDim.new(0, 8)
local bfSt = Instance.new("UIStroke", bindsFrame); bfSt.Thickness = 1; bfSt.Transparency = 0.25
local bfStGrad = Instance.new("UIGradient", bfSt)
Visual._bfStGrad = bfStGrad
local bfContent = Instance.new("Frame", bindsFrame)
bfContent.Size = UDim2.new(1, -8, 1, -4); bfContent.Position = UDim2.new(0, 4, 0, 2)
bfContent.BackgroundTransparency = 1; bfContent.ZIndex = 51
local bfLayout = Instance.new("UIListLayout", bfContent)
bfLayout.Padding = UDim.new(0, 1); bfLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Drag
Visual._bfDrag = {drag = false, start = nil, pos = nil}
bindsFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        Visual._bfDrag.drag = true; Visual._bfDrag.start = i.Position; Visual._bfDrag.pos = bindsFrame.Position
    end
end)
bindsFrame.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then Visual._bfDrag.drag = false end
end)

function Visual.updateActiveBinds(CFG, C, aimActive, tgtActive)
    for _, v in pairs(bfContent:GetChildren()) do
        if v:IsA("TextLabel") then pcall(function() v:Destroy() end) end
    end
    local items = {}
    if CFG.Enabled then table.insert(items, "AIM") end
    if aimActive then table.insert(items, "LOCK") end
    if tgtActive then table.insert(items, "TGT") end
    if CFG.Triggerbot then table.insert(items, "TRIG") end
    if CFG.ShowESP then table.insert(items, "ESP") end
    if CFG.DashEnabled then table.insert(items, "DASH") end
    if #items == 0 then table.insert(items, "IDLE") end
    for idx, name in ipairs(items) do
        local lbl = Instance.new("TextLabel", bfContent)
        lbl.Size = UDim2.new(1, 0, 0, 13); lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Visual.getAuroraColor(os.clock(), idx * 0.7)
        lbl.TextSize = 9; lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text = "▸ " .. name
        lbl.ZIndex = 52; lbl.LayoutOrder = idx
    end
    local totalH = math.max(#items * 14 + 6, 24)
    bindsFrame.Size = UDim2.new(0, 160, 0, totalH)
end
Visual.bindsFrame = bindsFrame

-- =============================================
--          HUD
-- =============================================
local HUD_MAX = 14
local hudFrame = Instance.new("Frame", gui)
hudFrame.Size = UDim2.new(0, 200, 0, 180); hudFrame.Position = UDim2.new(0, 20, 0.5, -90)
hudFrame.BackgroundColor3 = Color3.fromRGB(6, 3, 12); hudFrame.BackgroundTransparency = 0.15
hudFrame.BorderSizePixel = 0; hudFrame.ZIndex = 5; hudFrame.Visible = false
Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0, 10)
local hudSt = Instance.new("UIStroke", hudFrame); hudSt.Thickness = 1; hudSt.Transparency = 0.4
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
    l.TextSize = 10; l.Visible = false; l.ZIndex = 6; l.TextColor3 = Color3.fromRGB(220, 210, 250); l.Text = ""
    hudT[i] = l
end
Visual.hudFrame = hudFrame; Visual.hudT = hudT; Visual.hudSt = hudSt; Visual.HUD_MAX = HUD_MAX

-- =============================================
--          MAIN WINDOW
-- =============================================
local WIN_MODES = {{w = 800, h = 550}, {w = 600, h = 420}, {w = 1050, h = 650}}
Visual.WIN_MODES = WIN_MODES
function Visual.getWS(CFG)
    local m = WIN_MODES[CFG.WindowMode] or WIN_MODES[1]; return m.w, m.h
end

local wW, wH = 800, 550
local W = Instance.new("Frame", gui)
W.Name = "W"; W.Size = UDim2.new(0, wW, 0, wH)
W.Position = UDim2.new(0.5, -wW/2, 0.5, -wH/2)
W.BackgroundColor3 = Color3.fromRGB(6, 3, 12); W.BackgroundTransparency = 0.02
W.BorderSizePixel = 0; W.Visible = false; W.ZIndex = 10; W.ClipsDescendants = true
Instance.new("UICorner", W).CornerRadius = UDim.new(0, 14)
local gSt = Instance.new("UIStroke", W); gSt.Thickness = 1.5; gSt.Transparency = 0.1
local gStGrad = Instance.new("UIGradient", gSt)
Visual._gStGrad = gStGrad; Visual.W = W; Visual.gSt = gSt

-- Aurora BG — subtle overlay, fixed rotation
local auroraBg = Instance.new("Frame", W)
auroraBg.Size = UDim2.new(1.4, 0, 1.4, 0); auroraBg.Position = UDim2.new(-0.2, 0, -0.2, 0)
auroraBg.BackgroundColor3 = Color3.new(1, 1, 1); auroraBg.BackgroundTransparency = 0.93
auroraBg.BorderSizePixel = 0; auroraBg.ZIndex = 10
local auroraBgGrad = Instance.new("UIGradient", auroraBg)
auroraBgGrad.Rotation = 30
Visual._auroraBgGrad = auroraBgGrad

-- Stars
local guiStars = {}
for i = 1, 20 do
    local star = Instance.new("Frame", W)
    local sz = math.random(1, 2); star.Size = UDim2.new(0, sz, 0, sz)
    star.Position = UDim2.new(0, math.random(10, wW - 10), 0, math.random(55, wH - 10))
    star.BackgroundColor3 = Color3.fromRGB(200, 190, 255)
    star.BackgroundTransparency = math.random(50, 80) / 100
    star.BorderSizePixel = 0; star.ZIndex = 11
    Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    table.insert(guiStars, star)
end
Visual.guiStars = guiStars

-- =============================================
--          TITLE BAR
-- =============================================
local tB = Instance.new("Frame", W)
tB.Size = UDim2.new(1, 0, 0, 44); tB.BackgroundColor3 = Color3.fromRGB(4, 2, 10)
tB.BackgroundTransparency = 0.08; tB.BorderSizePixel = 0; tB.ZIndex = 12
Instance.new("UICorner", tB).CornerRadius = UDim.new(0, 14)
Visual.tB = tB

-- Aurora line under title
local tL = Instance.new("Frame", tB)
tL.Size = UDim2.new(1, 0, 0, 2); tL.Position = UDim2.new(0, 0, 1, -2)
tL.BackgroundColor3 = Color3.new(1, 1, 1); tL.BackgroundTransparency = 0.15
tL.BorderSizePixel = 0; tL.ZIndex = 14
local tLGrad = Instance.new("UIGradient", tL)
Visual.tL = tL; Visual._tLGrad = tLGrad

-- MOON title button — full aurora gradient
local moonBtn = Instance.new("Frame", tB)
moonBtn.Size = UDim2.new(0, 80, 0, 28); moonBtn.Position = UDim2.new(0, 10, 0.5, -14)
moonBtn.BackgroundColor3 = Color3.new(1, 1, 1); moonBtn.BackgroundTransparency = 0.15
moonBtn.BorderSizePixel = 0; moonBtn.ZIndex = 15
Instance.new("UICorner", moonBtn).CornerRadius = UDim.new(0, 8)
local moonBtnGrad = Instance.new("UIGradient", moonBtn)
Visual._moonBtnGrad = moonBtnGrad
local moonBtnTxt = Instance.new("TextLabel", moonBtn)
moonBtnTxt.Size = UDim2.new(1, 0, 1, 0); moonBtnTxt.BackgroundTransparency = 1
moonBtnTxt.Text = "MOON"; moonBtnTxt.TextColor3 = Color3.new(1, 1, 1)
moonBtnTxt.TextSize = 13; moonBtnTxt.Font = Enum.Font.GothamBold; moonBtnTxt.ZIndex = 16

local guiStatus = Instance.new("TextLabel", tB)
guiStatus.Text = "OFF"; guiStatus.Size = UDim2.new(0, 50, 0, 22)
guiStatus.Position = UDim2.new(0, 100, 0.5, -11)
guiStatus.BackgroundColor3 = Color3.fromRGB(20, 8, 8); guiStatus.BackgroundTransparency = 0.3
guiStatus.TextColor3 = Color3.fromRGB(255, 80, 80); guiStatus.TextSize = 10
guiStatus.Font = Enum.Font.GothamBold; guiStatus.BorderSizePixel = 0; guiStatus.ZIndex = 15
Instance.new("UICorner", guiStatus).CornerRadius = UDim.new(0, 6)
Visual.guiStatus = guiStatus

local guiFPS = Instance.new("TextLabel", tB)
guiFPS.Text = "60"; guiFPS.Size = UDim2.new(0, 40, 0, 14)
guiFPS.Position = UDim2.new(0, 160, 0.5, -7); guiFPS.BackgroundTransparency = 1
guiFPS.TextColor3 = Color3.fromRGB(100, 90, 130); guiFPS.TextSize = 9
guiFPS.Font = Enum.Font.Code; guiFPS.ZIndex = 15
Visual.guiFPS = guiFPS

local guiKills = Instance.new("TextLabel", tB)
guiKills.Text = "0k"; guiKills.Size = UDim2.new(0, 30, 0, 14)
guiKills.Position = UDim2.new(0, 200, 0.5, -7); guiKills.BackgroundTransparency = 1
guiKills.TextColor3 = Color3.fromRGB(100, 90, 130); guiKills.TextSize = 9
guiKills.Font = Enum.Font.Code; guiKills.ZIndex = 15
Visual.guiKills = guiKills

-- Title buttons
local isMin = false
Visual._dragState = {drag = false, start = nil, pos = nil}

local function mkTBtn(tx, xO, cb)
    local b = Instance.new("TextButton", tB)
    b.Text = tx; b.Size = UDim2.new(0, 32, 0, 26)
    b.Position = UDim2.new(1, xO, 0.5, -13)
    b.BackgroundColor3 = Color3.new(1, 1, 1); b.BackgroundTransparency = 0.85
    b.TextColor3 = Color3.fromRGB(220, 210, 250); b.TextSize = 13
    b.Font = Enum.Font.GothamBold; b.BorderSizePixel = 0; b.ZIndex = 16
    b.ClipsDescendants = true; b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    local bGrad = Instance.new("UIGradient", b)
    bGrad.Color = Visual.getAuroraSequence(os.clock())
    b.MouseEnter:Connect(function() TS:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play() end)
    b.MouseLeave:Connect(function() TS:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = 0.85}):Play() end)
    b.MouseButton1Click:Connect(function()
        Visual.Ripple(b, b.AbsoluteSize.X/2, b.AbsoluteSize.Y/2)
        if cb then cb() end
    end)
    return b
end

Visual._onClose = nil
Visual._closeBtn = mkTBtn("×", -38, function() if Visual._onClose then Visual._onClose() end end)
mkTBtn("—", -74, function()
    isMin = not isMin
    TS:Create(W, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
        Size = isMin and UDim2.new(0, wW, 0, 44) or UDim2.new(0, wW, 0, wH)
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
body.Size = UDim2.new(1, 0, 1, -44); body.Position = UDim2.new(0, 0, 0, 44)
body.BackgroundTransparency = 1; body.BorderSizePixel = 0; body.ZIndex = 11

local tabBar = Instance.new("Frame", body)
tabBar.Size = UDim2.new(1, 0, 0, 36); tabBar.BackgroundColor3 = Color3.fromRGB(4, 2, 10)
tabBar.BackgroundTransparency = 0.15; tabBar.BorderSizePixel = 0; tabBar.ZIndex = 13

local tabInd = Instance.new("Frame", tabBar)
tabInd.Size = UDim2.new(0, 0, 0, 2); tabInd.Position = UDim2.new(0, 0, 1, -2)
tabInd.BackgroundColor3 = Color3.new(1, 1, 1); tabInd.BorderSizePixel = 0; tabInd.ZIndex = 15
local tabIndGrad = Instance.new("UIGradient", tabInd)
Visual._tabIndGrad = tabIndGrad; Visual.tabInd = tabInd

local tabCon = Instance.new("Frame", body)
tabCon.Size = UDim2.new(1, 0, 1, -36); tabCon.Position = UDim2.new(0, 0, 0, 36)
tabCon.BackgroundTransparency = 1; tabCon.BorderSizePixel = 0; tabCon.ZIndex = 12

local TN = {"Aim", "Trig", "ESP", "Visual", "Target", "Binds", "Cfg", "Patch"}
Visual.TabNames = TN
local tBs, tPs = {}, {}
local aTab = 1

for i, nm in ipairs(TN) do
    local pg = Instance.new("ScrollingFrame", tabCon)
    pg.Name = "P"..i; pg.Size = UDim2.new(1, 0, 1, 0); pg.BackgroundTransparency = 1
    pg.ScrollBarThickness = 3; pg.ScrollBarImageColor3 = Color3.fromRGB(80, 50, 160)
    pg.ScrollBarImageTransparency = 0.5; pg.CanvasSize = UDim2.new(0, 0, 0, 0)
    pg.BorderSizePixel = 0; pg.Visible = (i == 1); pg.ZIndex = 13
    pg.ScrollingDirection = Enum.ScrollingDirection.Y
    local ll = Instance.new("UIListLayout", pg)
    ll.Padding = UDim.new(0, 4); ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pg.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 20)
    end)
    local pd = Instance.new("UIPadding", pg)
    pd.PaddingTop = UDim.new(0, 10); pd.PaddingLeft = UDim.new(0, 16)
    pd.PaddingRight = UDim.new(0, 16); pd.PaddingBottom = UDim.new(0, 16)
    tPs[i] = pg
end

local tbw = math.floor(wW / #TN)
local function switchTab(idx)
    aTab = idx
    for i, b in ipairs(tBs) do
        TS:Create(b, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
            TextColor3 = (i == idx) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 110, 150)
        }):Play()
        tPs[i].Visible = (i == idx)
    end
    TS:Create(tabInd, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0, (idx-1)*tbw + 8, 1, -2), Size = UDim2.new(0, tbw - 16, 0, 2)
    }):Play()
end

for i, nm in ipairs(TN) do
    local b = Instance.new("TextButton", tabBar)
    b.Text = nm; b.Size = UDim2.new(0, tbw, 1, 0)
    b.Position = UDim2.new(0, (i-1)*tbw, 0, 0); b.BackgroundTransparency = 1
    b.TextColor3 = i == 1 and Color3.new(1,1,1) or Color3.fromRGB(120, 110, 150)
    b.TextSize = 11; b.Font = Enum.Font.GothamBold; b.BorderSizePixel = 0
    b.AutoButtonColor = false; b.ZIndex = 15
    b.MouseEnter:Connect(function()
        if aTab ~= i then TS:Create(b, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(200, 190, 240)}):Play() end
    end)
    b.MouseLeave:Connect(function()
        if aTab ~= i then TS:Create(b, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(120, 110, 150)}):Play() end
    end)
    b.MouseButton1Click:Connect(function() switchTab(i) end)
    tBs[i] = b
end
tabInd.Size = UDim2.new(0, tbw - 16, 0, 2); tabInd.Position = UDim2.new(0, 8, 1, -2)
Visual.tBs = tBs; Visual.tPs = tPs; Visual.switchTab = switchTab

-- =============================================
--          UI BUILDERS
-- =============================================
local pO = {}
for i = 1, #TN do pO[i] = 0 end
local function po(pi) pO[pi] = pO[pi] + 1; return pO[pi] end
Visual.themeCallbacks = {}

function Visual.makeSection(pi, tx, C)
    local f = Instance.new("Frame", tPs[pi])
    f.Size = UDim2.new(1, -4, 0, 24); f.BackgroundTransparency = 1
    f.LayoutOrder = po(pi); f.ZIndex = 18
    local l = Instance.new("TextLabel", f)
    l.Text = string.upper(tx); l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1; l.TextSize = 10; l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 20
    l.TextColor3 = Visual.getAuroraColor(os.clock(), po(pi) * 0.5)
    local ln = Instance.new("Frame", f)
    ln.Size = UDim2.new(1, 0, 0, 1); ln.Position = UDim2.new(0, 0, 1, -1)
    ln.BackgroundColor3 = Color3.new(1,1,1); ln.BackgroundTransparency = 0.5
    ln.BorderSizePixel = 0; ln.ZIndex = 20
    local lnGrad = Instance.new("UIGradient", ln)
    lnGrad.Color = Visual.getAuroraSequence(os.clock())
    table.insert(Visual.themeCallbacks, function()
        l.TextColor3 = Visual.getAuroraColor(os.clock(), 0.5)
        lnGrad.Color = Visual.getAuroraSequence(os.clock())
    end)
end

function Visual.makeToggle(pi, tx, k, CFG, C, cb)
    local rw = Instance.new("Frame", tPs[pi])
    rw.Size = UDim2.new(1, -4, 0, 34); rw.BackgroundColor3 = Color3.fromRGB(12, 7, 22)
    rw.BackgroundTransparency = 0.35; rw.BorderSizePixel = 0; rw.ZIndex = 18
    rw.LayoutOrder = po(pi); rw.ClipsDescendants = true
    Instance.new("UICorner", rw).CornerRadius = UDim.new(0, 8)

    local tl = Instance.new("TextLabel", rw)
    tl.Text = tx; tl.Size = UDim2.new(1, -56, 1, 0)
    tl.Position = UDim2.new(0, 12, 0, 0); tl.BackgroundTransparency = 1
    tl.TextColor3 = Color3.fromRGB(220, 210, 250); tl.TextSize = 11
    tl.Font = Enum.Font.GothamSemibold; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 20

    -- AURORA TOGGLE PILL
    local pl = Instance.new("Frame", rw)
    pl.Size = UDim2.new(0, 38, 0, 18); pl.Position = UDim2.new(1, -46, 0.5, -9)
    pl.BackgroundColor3 = Color3.new(1, 1, 1)
    pl.BackgroundTransparency = CFG[k] and 0.2 or 0.75; pl.BorderSizePixel = 0; pl.ZIndex = 20
    Instance.new("UICorner", pl).CornerRadius = UDim.new(1, 0)
    local plGrad = Instance.new("UIGradient", pl)
    plGrad.Color = Visual.getAuroraSequence(os.clock())

    local kb = Instance.new("Frame", pl)
    kb.Size = UDim2.new(0, 12, 0, 12)
    kb.Position = CFG[k] and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    kb.BackgroundColor3 = Color3.new(1, 1, 1); kb.BorderSizePixel = 0; kb.ZIndex = 21
    Instance.new("UICorner", kb).CornerRadius = UDim.new(1, 0)

    rw.MouseEnter:Connect(function() TS:Create(rw, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play() end)
    rw.MouseLeave:Connect(function() TS:Create(rw, TweenInfo.new(0.15), {BackgroundTransparency = 0.35}):Play() end)

    local bn = Instance.new("TextButton", rw)
    bn.Size = UDim2.new(1, 0, 1, 0); bn.BackgroundTransparency = 1; bn.Text = ""
    bn.ZIndex = 22; bn.ClipsDescendants = true
    bn.MouseButton1Click:Connect(function()
        CFG[k] = not CFG[k]
        local on = CFG[k]
        local mx = UIS:GetMouseLocation()
        Visual.Ripple(rw, mx.X - rw.AbsolutePosition.X, mx.Y - rw.AbsolutePosition.Y)
        TS:Create(pl, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            BackgroundTransparency = on and 0.2 or 0.75
        }):Play()
        TS:Create(kb, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Position = on and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        }):Play()
        if cb then cb(on) end
    end)

    table.insert(Visual.themeCallbacks, function()
        plGrad.Color = Visual.getAuroraSequence(os.clock())
    end)
end

function Visual.makeSlider(pi, tx, k, mn, mx, st, CFG, C, allConnections)
    allConnections = allConnections or {}
    local rw = Instance.new("Frame", tPs[pi])
    rw.Size = UDim2.new(1, -4, 0, 40); rw.BackgroundTransparency = 1
    rw.ZIndex = 18; rw.LayoutOrder = po(pi)
    local ll = Instance.new("TextLabel", rw)
    ll.Text = tx; ll.Size = UDim2.new(0.55, 0, 0, 14); ll.BackgroundTransparency = 1
    ll.TextColor3 = Color3.fromRGB(160, 150, 190); ll.TextSize = 10; ll.Font = Enum.Font.Gotham
    ll.TextXAlignment = Enum.TextXAlignment.Left; ll.ZIndex = 20
    local vl = Instance.new("TextLabel", rw)
    vl.Text = st < 1 and string.format("%.2f", CFG[k]) or tostring(math.floor(CFG[k]))
    vl.Size = UDim2.new(0.43, 0, 0, 14); vl.Position = UDim2.new(0.55, 0, 0, 0)
    vl.BackgroundTransparency = 1; vl.TextColor3 = Color3.fromRGB(200, 180, 255)
    vl.TextSize = 11; vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Right; vl.ZIndex = 20

    local tr = Instance.new("Frame", rw)
    tr.Size = UDim2.new(1, 0, 0, 5); tr.Position = UDim2.new(0, 0, 0, 22)
    tr.BackgroundColor3 = Color3.fromRGB(20, 12, 35); tr.BackgroundTransparency = 0.15
    tr.BorderSizePixel = 0; tr.ZIndex = 20
    Instance.new("UICorner", tr).CornerRadius = UDim.new(0, 3)

    local pc = math.clamp((CFG[k] - mn) / (mx - mn), 0, 1)
    local fl = Instance.new("Frame", tr)
    fl.Size = UDim2.new(pc, 0, 1, 0); fl.BackgroundColor3 = Color3.new(1,1,1)
    fl.BorderSizePixel = 0; fl.ZIndex = 21
    Instance.new("UICorner", fl).CornerRadius = UDim.new(0, 3)
    local flGrad = Instance.new("UIGradient", fl)
    flGrad.Color = Visual.getAuroraSequence(os.clock())

    local kn = Instance.new("TextButton", tr)
    kn.Size = UDim2.new(0, 14, 0, 14); kn.AnchorPoint = Vector2.new(0.5, 0.5)
    kn.Position = UDim2.new(pc, 0, 0.5, 0); kn.BackgroundColor3 = Color3.new(1,1,1)
    kn.Text = ""; kn.AutoButtonColor = false; kn.BorderSizePixel = 0; kn.ZIndex = 23
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
    local knGrad = Instance.new("UIGradient", kn)
    knGrad.Color = Visual.getAuroraSequence(os.clock())

    table.insert(Visual.themeCallbacks, function()
        flGrad.Color = Visual.getAuroraSequence(os.clock())
        knGrad.Color = Visual.getAuroraSequence(os.clock())
    end)

    local iD = false
    local function sV(v)
        if st > 0 then v = math.floor(v / st + 0.5) * st end
        v = math.clamp(v, mn, mx); CFG[k] = v
        local p = (v - mn) / (mx - mn)
        fl.Size = UDim2.new(p, 0, 1, 0)
        kn.Position = UDim2.new(p, 0, 0.5, 0)
        vl.Text = st < 1 and string.format("%.2f", v) or tostring(math.floor(v))
    end
    kn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then iD = true end
    end)
    table.insert(allConnections, UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and iD then iD = false end
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
    local idx = CFG[k] or 1
    local rw = Instance.new("Frame", tPs[pi])
    rw.Size = UDim2.new(1, -4, 0, 34); rw.BackgroundColor3 = Color3.fromRGB(12, 7, 22)
    rw.BackgroundTransparency = 0.35; rw.BorderSizePixel = 0; rw.ZIndex = 18
    rw.LayoutOrder = po(pi); rw.ClipsDescendants = true
    Instance.new("UICorner", rw).CornerRadius = UDim.new(0, 8)
    local ll = Instance.new("TextLabel", rw)
    ll.Text = tx; ll.Size = UDim2.new(0.5, 0, 1, 0); ll.Position = UDim2.new(0, 12, 0, 0)
    ll.BackgroundTransparency = 1; ll.TextColor3 = Color3.fromRGB(220, 210, 250)
    ll.TextSize = 11; ll.Font = Enum.Font.GothamSemibold; ll.TextXAlignment = Enum.TextXAlignment.Left; ll.ZIndex = 20
    local rl = Instance.new("TextLabel", rw)
    rl.Text = tostring(opts[idx]); rl.Size = UDim2.new(0.42, 0, 1, 0)
    rl.Position = UDim2.new(0.5, 0, 0, 0); rl.BackgroundTransparency = 1
    rl.TextColor3 = Visual.getAuroraColor(os.clock(), 1); rl.TextSize = 11
    rl.Font = Enum.Font.GothamBold; rl.TextXAlignment = Enum.TextXAlignment.Right; rl.ZIndex = 20
    rw.MouseEnter:Connect(function() TS:Create(rw, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play() end)
    rw.MouseLeave:Connect(function() TS:Create(rw, TweenInfo.new(0.15), {BackgroundTransparency = 0.35}):Play() end)
    local bn = Instance.new("TextButton", rw)
    bn.Size = UDim2.new(1, 0, 1, 0); bn.BackgroundTransparency = 1; bn.Text = ""; bn.ZIndex = 22
    bn.MouseButton1Click:Connect(function()
        local mx = UIS:GetMouseLocation()
        Visual.Ripple(rw, mx.X - rw.AbsolutePosition.X, mx.Y - rw.AbsolutePosition.Y)
        idx = idx % #opts + 1; CFG[k] = idx; rl.Text = tostring(opts[idx])
        rl.TextColor3 = Visual.getAuroraColor(os.clock(), idx)
        if cb then cb(idx) end
    end)
end

function Visual.makeRebind(pi, lb, ck, CFG, C, allConnections)
    allConnections = allConnections or {}
    local rw = Instance.new("Frame", tPs[pi])
    rw.Size = UDim2.new(1, -4, 0, 34); rw.BackgroundColor3 = Color3.fromRGB(12, 7, 22)
    rw.BackgroundTransparency = 0.35; rw.BorderSizePixel = 0; rw.ZIndex = 18
    rw.LayoutOrder = po(pi); rw.ClipsDescendants = true
    Instance.new("UICorner", rw).CornerRadius = UDim.new(0, 8)
    local ll = Instance.new("TextLabel", rw)
    ll.Text = lb; ll.Size = UDim2.new(0.5, 0, 1, 0); ll.Position = UDim2.new(0, 12, 0, 0)
    ll.BackgroundTransparency = 1; ll.TextColor3 = Color3.fromRGB(220, 210, 250)
    ll.TextSize = 11; ll.Font = Enum.Font.GothamSemibold; ll.TextXAlignment = Enum.TextXAlignment.Left; ll.ZIndex = 20
    local vl = Instance.new("TextLabel", rw)
    vl.Text = "[ " .. CFG[ck] .. " ]"; vl.Size = UDim2.new(0.44, 0, 1, 0)
    vl.Position = UDim2.new(0.5, 0, 0, 0); vl.BackgroundTransparency = 1
    vl.TextColor3 = Visual.getAuroraColor(os.clock(), 0.5); vl.TextSize = 12
    vl.Font = Enum.Font.GothamBold; vl.TextXAlignment = Enum.TextXAlignment.Right; vl.ZIndex = 20
    rw.MouseEnter:Connect(function() TS:Create(rw, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play() end)
    rw.MouseLeave:Connect(function() TS:Create(rw, TweenInfo.new(0.15), {BackgroundTransparency = 0.35}):Play() end)
    local rebinding = false
    local bn = Instance.new("TextButton", rw)
    bn.Size = UDim2.new(1, 0, 1, 0); bn.BackgroundTransparency = 1; bn.Text = ""; bn.ZIndex = 22
    bn.MouseButton1Click:Connect(function()
        Visual.Ripple(rw, rw.AbsoluteSize.X/2, rw.AbsoluteSize.Y/2)
        vl.Text = "..."; vl.TextColor3 = Color3.fromRGB(255, 210, 100); rebinding = true
        local cn; cn = UIS.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                local n = inp.KeyCode.Name
                if n ~= "Unknown" then
                    CFG[ck] = n; vl.Text = "[ " .. n .. " ]"
                    vl.TextColor3 = Visual.getAuroraColor(os.clock(), 0.5)
                    rebinding = false; pcall(function() cn:Disconnect() end)
                end
            end
        end)
        task.delay(5, function()
            if rebinding then rebinding = false; vl.Text = "[ " .. CFG[ck] .. " ]"
                vl.TextColor3 = Visual.getAuroraColor(os.clock(), 0.5); pcall(function() cn:Disconnect() end) end
        end)
    end)
end

function Visual.makeInfo(pi, tx)
    local l = Instance.new("TextLabel", tPs[pi])
    l.Size = UDim2.new(1, -4, 0, 13); l.BackgroundTransparency = 1; l.Text = tx
    l.TextColor3 = Color3.fromRGB(100, 90, 130); l.TextSize = 9; l.Font = Enum.Font.Code
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 20; l.LayoutOrder = po(pi)
end

function Visual.makeLabel(pi)
    local lbl = Instance.new("TextLabel", tPs[pi])
    lbl.Text = ""; lbl.Size = UDim2.new(1, -8, 0, 16); lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200, 180, 255); lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 20; lbl.LayoutOrder = po(pi)
    return lbl
end

-- =============================================
--          RAGE WINDOW (simplified)
-- =============================================
local rageGui = Instance.new("Frame", gui)
rageGui.Size = UDim2.new(0, 320, 0, 250); rageGui.Position = UDim2.new(0.5, -160, 0.5, -125)
rageGui.BackgroundColor3 = Color3.fromRGB(14, 5, 5); rageGui.BackgroundTransparency = 0.04
rageGui.BorderSizePixel = 0; rageGui.Visible = false; rageGui.ZIndex = 100; rageGui.ClipsDescendants = true
Instance.new("UICorner", rageGui).CornerRadius = UDim.new(0, 12)
local rageSt = Instance.new("UIStroke", rageGui); rageSt.Color = Color3.fromRGB(180, 30, 30); rageSt.Thickness = 1.5; rageSt.Transparency = 0.25
local rageTB = Instance.new("Frame", rageGui)
rageTB.Size = UDim2.new(1, 0, 0, 38); rageTB.BackgroundColor3 = Color3.fromRGB(20, 6, 6)
rageTB.BackgroundTransparency = 0.1; rageTB.BorderSizePixel = 0; rageTB.ZIndex = 101
Instance.new("UICorner", rageTB).CornerRadius = UDim.new(0, 12)
local rTitle = Instance.new("TextLabel", rageTB)
rTitle.Text = "RAGE"; rTitle.Size = UDim2.new(1, -16, 1, 0); rTitle.Position = UDim2.new(0, 14, 0, 0)
rTitle.BackgroundTransparency = 1; rTitle.TextColor3 = Color3.fromRGB(255, 70, 70); rTitle.TextSize = 13
rTitle.Font = Enum.Font.GothamBold; rTitle.TextXAlignment = Enum.TextXAlignment.Left; rTitle.ZIndex = 102
local rClose = Instance.new("TextButton", rageTB)
rClose.Text = "×"; rClose.Size = UDim2.new(0, 28, 0, 22); rClose.Position = UDim2.new(1, -34, 0.5, -11)
rClose.BackgroundColor3 = Color3.fromRGB(80, 15, 15); rClose.BackgroundTransparency = 0.3
rClose.TextColor3 = Color3.fromRGB(255, 140, 140); rClose.TextSize = 12; rClose.Font = Enum.Font.GothamBold
rClose.BorderSizePixel = 0; rClose.ZIndex = 103; rClose.AutoButtonColor = false
Instance.new("UICorner", rClose).CornerRadius = UDim.new(0, 6)
rClose.MouseButton1Click:Connect(function()
    TS:Create(rageGui, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    task.delay(0.3, function() rageGui.Visible = false end)
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
local rContent = Instance.new("ScrollingFrame", rageGui)
rContent.Size = UDim2.new(1, 0, 1, -42); rContent.Position = UDim2.new(0, 0, 0, 42)
rContent.BackgroundTransparency = 1; rContent.ScrollBarThickness = 2; rContent.BorderSizePixel = 0
rContent.ZIndex = 101; rContent.ScrollingDirection = Enum.ScrollingDirection.Y
local rLayout = Instance.new("UIListLayout", rContent); rLayout.Padding = UDim.new(0, 4); rLayout.SortOrder = Enum.SortOrder.LayoutOrder
rLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    rContent.CanvasSize = UDim2.new(0, 0, 0, rLayout.AbsoluteContentSize.Y + 16)
end)
local rPad = Instance.new("UIPadding", rContent)
rPad.PaddingTop = UDim.new(0, 8); rPad.PaddingLeft = UDim.new(0, 12); rPad.PaddingRight = UDim.new(0, 12)
Visual.rageGui = rageGui; Visual.rageContent = rContent

local rageOrder = 0
function Visual.rageSection(tx)
    rageOrder = rageOrder + 1
    local l = Instance.new("TextLabel", rContent)
    l.Size = UDim2.new(1, 0, 0, 18); l.BackgroundTransparency = 1; l.Text = string.upper(tx)
    l.TextColor3 = Color3.fromRGB(255, 70, 70); l.TextSize = 9; l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 102; l.LayoutOrder = rageOrder
end
function Visual.rageToggle(tx, k, CFG, cb)
    rageOrder = rageOrder + 1
    local rw = Instance.new("Frame", rContent)
    rw.Size = UDim2.new(1, 0, 0, 30); rw.BackgroundColor3 = Color3.fromRGB(25, 10, 10)
    rw.BackgroundTransparency = 0.3; rw.BorderSizePixel = 0; rw.ZIndex = 102
    rw.LayoutOrder = rageOrder; rw.ClipsDescendants = true
    Instance.new("UICorner", rw).CornerRadius = UDim.new(0, 7)
    local tl = Instance.new("TextLabel", rw)
    tl.Text = tx; tl.Size = UDim2.new(1, -50, 1, 0); tl.Position = UDim2.new(0, 10, 0, 0)
    tl.BackgroundTransparency = 1; tl.TextColor3 = Color3.fromRGB(220, 190, 190)
    tl.TextSize = 10; tl.Font = Enum.Font.GothamSemibold; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 103
    local pl = Instance.new("Frame", rw)
    pl.Size = UDim2.new(0, 34, 0, 16); pl.Position = UDim2.new(1, -42, 0.5, -8)
    pl.BackgroundColor3 = CFG[k] and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(40, 18, 18)
    pl.BackgroundTransparency = 0.2; pl.BorderSizePixel = 0; pl.ZIndex = 103
    Instance.new("UICorner", pl).CornerRadius = UDim.new(1, 0)
    local kb = Instance.new("Frame", pl)
    kb.Size = UDim2.new(0, 10, 0, 10)
    kb.Position = CFG[k] and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 3, 0.5, -5)
    kb.BackgroundColor3 = Color3.new(1,1,1); kb.BorderSizePixel = 0; kb.ZIndex = 104
    Instance.new("UICorner", kb).CornerRadius = UDim.new(1, 0)
    local bn = Instance.new("TextButton", rw)
    bn.Size = UDim2.new(1, 0, 1, 0); bn.BackgroundTransparency = 1; bn.Text = ""; bn.ZIndex = 105
    bn.MouseButton1Click:Connect(function()
        CFG[k] = not CFG[k]; local on = CFG[k]
        TS:Create(pl, TweenInfo.new(0.25), {BackgroundColor3 = on and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(40, 18, 18)}):Play()
        TS:Create(kb, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
            Position = on and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 3, 0.5, -5)
        }):Play()
        if cb then cb(on) end
    end)
end
function Visual.rageInfo(tx)
    rageOrder = rageOrder + 1
    local l = Instance.new("TextLabel", rContent)
    l.Size = UDim2.new(1, 0, 0, 12); l.BackgroundTransparency = 1; l.Text = tx
    l.TextColor3 = Color3.fromRGB(130, 90, 90); l.TextSize = 8; l.Font = Enum.Font.Code
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 102; l.LayoutOrder = rageOrder
end

-- Rage button
local rageBtn = Instance.new("TextButton", gui)
rageBtn.Size = UDim2.new(0, 90, 0, 30); rageBtn.Position = UDim2.new(0, 20, 1, -50)
rageBtn.BackgroundColor3 = Color3.fromRGB(110, 14, 14); rageBtn.BackgroundTransparency = 0.1
rageBtn.Text = "RAGE"; rageBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
rageBtn.TextSize = 11; rageBtn.Font = Enum.Font.GothamBold; rageBtn.BorderSizePixel = 0
rageBtn.ZIndex = 50; rageBtn.Visible = false; rageBtn.AutoButtonColor = false; rageBtn.ClipsDescendants = true
Instance.new("UICorner", rageBtn).CornerRadius = UDim.new(0, 8)
rageBtn.MouseButton1Click:Connect(function()
    Visual.Ripple(rageBtn, rageBtn.AbsoluteSize.X/2, rageBtn.AbsoluteSize.Y/2)
    if rageGui.Visible then
        TS:Create(rageGui, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        task.delay(0.3, function() rageGui.Visible = false end)
    else
        rageGui.Visible = true; rageGui.BackgroundTransparency = 1
        TS:Create(rageGui, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.04}):Play()
    end
end)
Visual.rageBtn = rageBtn

-- =============================================
--          OPEN / CLOSE (CURSOR FIX)
-- =============================================
local isOpen = false
Visual.isOpen = false
local savedMB, savedMI = nil, nil

function Visual.openMenu(CFG)
    isOpen = true; Visual.isOpen = true
    W.Visible = true; dimOverlay.Visible = true; rageBtn.Visible = true
    wW, wH = Visual.getWS(CFG)
    dimOverlay.BackgroundTransparency = 1
    TS:Create(dimOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.45}):Play()
    W.Size = UDim2.new(0, wW * 0.88, 0, wH * 0.88)
    W.Position = UDim2.new(0.5, -wW*0.44, 0.5, -wH*0.44)
    W.BackgroundTransparency = 0.4
    TS:Create(W, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, wW, 0, wH), Position = UDim2.new(0.5, -wW/2, 0.5, -wH/2), BackgroundTransparency = 0.02
    }):Play()
    TS:Create(blurMain, TweenInfo.new(0.3), {Size = 16}):Play()
    pcall(function()
        savedMB = UIS.MouseBehavior; savedMI = UIS.MouseIconEnabled
        UIS.MouseBehavior = Enum.MouseBehavior.Default; UIS.MouseIconEnabled = true
    end)
    Visual.Notify("Moon", "INSERT to close", 2)
end

function Visual.closeMenu(CFG)
    isOpen = false; Visual.isOpen = false; rageBtn.Visible = false
    if rageGui.Visible then rageGui.Visible = false end
    TS:Create(dimOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    TS:Create(W, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Size = UDim2.new(0, wW*0.88, 0, wH*0.88), BackgroundTransparency = 1
    }):Play()
    TS:Create(blurMain, TweenInfo.new(0.2), {Size = 0}):Play()
    task.delay(0.3, function()
        pcall(function() if not isOpen then W.Visible = false; dimOverlay.Visible = false end end)
    end)
    pcall(function()
        if savedMB then UIS.MouseBehavior = savedMB end
        if savedMI ~= nil then UIS.MouseIconEnabled = savedMI end
    end)
end

-- =============================================
--          ANIMATION UPDATE
-- =============================================
function Visual.updateAnimations(dt, globalT)
    local aSeq = Visual.getAuroraSequence(globalT)
    pcall(function() Visual._wmStGrad.Color = aSeq end)
    pcall(function() Visual.wmTime.Text = os.date("%H:%M") end)
    if not isOpen then return end
    pcall(function() Visual._auroraBgGrad.Color = aSeq; Visual._auroraBgGrad.Offset = Vector2.new(math.sin(globalT * 0.08) * 0.15, math.cos(globalT * 0.06) * 0.1) end)
    pcall(function() Visual._gStGrad.Color = aSeq end)
    pcall(function() Visual._tLGrad.Color = aSeq end)
    pcall(function() Visual._tabIndGrad.Color = aSeq end)
    pcall(function() Visual._bfStGrad.Color = aSeq end)
    pcall(function() Visual._hudStGrad.Color = aSeq end)
    pcall(function() Visual._moonBtnGrad.Color = aSeq end)
    for idx, star in ipairs(guiStars) do
        pcall(function()
            star.BackgroundTransparency = 0.5 + math.sin(globalT * (1 + idx * 0.2)) * 0.3
            star.BackgroundColor3 = Visual.getAuroraColor(globalT, idx * 0.3)
        end)
    end
end

function Visual.handleDrag(inputPos)
    if Visual._dragState.drag and Visual._dragState.start and Visual._dragState.pos then
        local d = inputPos - Visual._dragState.start
        W.Position = UDim2.new(Visual._dragState.pos.X.Scale, Visual._dragState.pos.X.Offset + d.X, Visual._dragState.pos.Y.Scale, Visual._dragState.pos.Y.Offset + d.Y)
    end
    if Visual._bfDrag.drag and Visual._bfDrag.start and Visual._bfDrag.pos then
        local d = inputPos - Visual._bfDrag.start
        bindsFrame.Position = UDim2.new(Visual._bfDrag.pos.X.Scale, Visual._bfDrag.pos.X.Offset + d.X, Visual._bfDrag.pos.Y.Scale, Visual._bfDrag.pos.Y.Offset + d.Y)
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
