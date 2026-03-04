-- ╔══════════════════════════════════════════════════════════════════╗
-- ║              NEXUS ADMIN  v3.0  —  NexusScripts                 ║
-- ║  Tabs: Main | Fun | Troll | Settings                            ║
-- ║  Troll: Player dropdown → pick command → Run                    ║
-- ╚══════════════════════════════════════════════════════════════════╝

local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local Lighting        = game:GetService("Lighting")
local StarterGui      = game:GetService("StarterGui")

local LP     = Players.LocalPlayer
local PGui   = LP:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────────
--  HELPERS
-- ─────────────────────────────────────────────
local function tween(obj, props, t, style, dir)
    local ti = TweenInfo.new(t or .3, Enum.EasingStyle[style or "Quart"], Enum.EasingDirection[dir or "Out"])
    local tw = TweenService:Create(obj, ti, props); tw:Play(); return tw
end

local function getChar()   return LP.Character end
local function getHRP()    local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()    local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRig()    local c=getChar(); return c and c:FindFirstChild("Humanoid") and c:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator") end

-- ─────────────────────────────────────────────
--  NOTIFICATION SYSTEM
-- ─────────────────────────────────────────────
local notifY = 0
local function Notif(title, msg, kind)
    kind = kind or "info"
    local palette = {
        info    = {bg=Color3.fromRGB(40,80,160),  fg=Color3.fromRGB(130,180,255), icon="ℹ"},
        success = {bg=Color3.fromRGB(30,110,70),  fg=Color3.fromRGB(80,230,140),  icon="✓"},
        warn    = {bg=Color3.fromRGB(120,80,10),  fg=Color3.fromRGB(255,195,50),  icon="⚠"},
        error   = {bg=Color3.fromRGB(120,30,30),  fg=Color3.fromRGB(255,80,80),   icon="✕"},
    }
    local p = palette[kind] or palette.info

    local sg = Instance.new("ScreenGui")
    sg.Name = "NxNotif"; sg.ResetOnSpawn=false; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=PGui

    notifY = notifY + 1
    local slot = notifY

    local f = Instance.new("Frame")
    f.Size=UDim2.new(0,310,0,62); f.Position=UDim2.new(1,8,1,-80-(slot-1)*72)
    f.BackgroundColor3=Color3.fromRGB(12,12,20); f.BorderSizePixel=0; f.Parent=sg
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,12)
    local st=Instance.new("UIStroke",f); st.Color=p.fg; st.Thickness=1.2; st.Transparency=0.6

    local bar=Instance.new("Frame",f)
    bar.Size=UDim2.new(0,4,0.65,0); bar.Position=UDim2.new(0,0,0.175,0)
    bar.BackgroundColor3=p.fg; bar.BorderSizePixel=0
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)

    local ic=Instance.new("TextLabel",f)
    ic.Size=UDim2.new(0,32,0,32); ic.Position=UDim2.new(0,12,0.5,-16)
    ic.BackgroundColor3=p.bg; ic.BackgroundTransparency=0.3
    ic.Text=p.icon; ic.TextColor3=p.fg; ic.TextSize=15; ic.Font=Enum.Font.GothamBold; ic.BorderSizePixel=0
    Instance.new("UICorner",ic).CornerRadius=UDim.new(1,0)

    local tl=Instance.new("TextLabel",f)
    tl.Size=UDim2.new(1,-60,0,20); tl.Position=UDim2.new(0,52,0,10)
    tl.BackgroundTransparency=1; tl.Text=title
    tl.TextColor3=Color3.fromRGB(235,235,255); tl.TextSize=12; tl.Font=Enum.Font.GothamBold
    tl.TextXAlignment=Enum.TextXAlignment.Left

    local ml=Instance.new("TextLabel",f)
    ml.Size=UDim2.new(1,-60,0,18); ml.Position=UDim2.new(0,52,0,30)
    ml.BackgroundTransparency=1; ml.Text=msg
    ml.TextColor3=Color3.fromRGB(140,140,170); ml.TextSize=10; ml.Font=Enum.Font.Gotham
    ml.TextXAlignment=Enum.TextXAlignment.Left

    -- progress bar
    local prog=Instance.new("Frame",f)
    prog.Size=UDim2.new(1,0,0,2); prog.Position=UDim2.new(0,0,1,-2)
    prog.BackgroundColor3=p.fg; prog.BorderSizePixel=0
    Instance.new("UICorner",prog).CornerRadius=UDim.new(1,0)

    tween(f,{Position=UDim2.new(1,-318,1,-80-(slot-1)*72)},.4,"Back","Out")
    tween(prog,{Size=UDim2.new(0,0,0,2)},3,"Linear","Out")
    task.delay(3,function()
        tween(f,{Position=UDim2.new(1,8,1,-80-(slot-1)*72)},.3,"Quart","In")
        task.wait(.35); sg:Destroy(); notifY=math.max(0,notifY-1)
    end)
end

-- ─────────────────────────────────────────────
--  BUILD SCREENGUI
-- ─────────────────────────────────────────────
local SG = Instance.new("ScreenGui")
SG.Name="NexusAdminV3"; SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.Parent=PGui

-- ── Main Window ──────────────────────────────
local W = Instance.new("Frame",SG)
W.Name="Window"; W.Size=UDim2.new(0,620,0,450)
W.Position=UDim2.new(0.5,-310,0.5,-225)
W.BackgroundColor3=Color3.fromRGB(9,9,16)
W.BorderSizePixel=0; W.Active=true; W.Draggable=true
Instance.new("UICorner",W).CornerRadius=UDim.new(0,16)
local ws=Instance.new("UIStroke",W); ws.Color=Color3.fromRGB(50,50,90); ws.Thickness=1.5

-- Subtle gradient
local wg=Instance.new("UIGradient",W)
wg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(13,13,24)),ColorSequenceKeypoint.new(1,Color3.fromRGB(7,7,14))}
wg.Rotation=150

-- ── Title Bar ────────────────────────────────
local TB = Instance.new("Frame",W)
TB.Size=UDim2.new(1,0,0,50); TB.BackgroundColor3=Color3.fromRGB(15,15,26); TB.BorderSizePixel=0
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,16)
local tbfix=Instance.new("Frame",TB); tbfix.Size=UDim2.new(1,0,0,16); tbfix.Position=UDim2.new(0,0,1,-16); tbfix.BackgroundColor3=Color3.fromRGB(15,15,26); tbfix.BorderSizePixel=0

-- rainbow accent line
local ral=Instance.new("Frame",TB); ral.Size=UDim2.new(1,0,0,2); ral.Position=UDim2.new(0,0,1,-2); ral.BackgroundColor3=Color3.fromRGB(255,255,255); ral.BorderSizePixel=0
local ralg=Instance.new("UIGradient",ral)
ralg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(80,120,255)),ColorSequenceKeypoint.new(0.33,Color3.fromRGB(160,80,255)),ColorSequenceKeypoint.new(0.66,Color3.fromRGB(255,80,160)),ColorSequenceKeypoint.new(1,Color3.fromRGB(80,200,255))}

-- Logo badge
local logo=Instance.new("Frame",TB); logo.Size=UDim2.new(0,34,0,34); logo.Position=UDim2.new(0,12,0.5,-17); logo.BackgroundColor3=Color3.fromRGB(80,110,255); logo.BorderSizePixel=0
Instance.new("UICorner",logo).CornerRadius=UDim.new(0,8)
local logoG=Instance.new("UIGradient",logo); logoG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(100,130,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(160,80,255))}; logoG.Rotation=135
local logoT=Instance.new("TextLabel",logo); logoT.Size=UDim2.new(1,0,1,0); logoT.BackgroundTransparency=1; logoT.Text="N"; logoT.TextColor3=Color3.fromRGB(255,255,255); logoT.TextSize=18; logoT.Font=Enum.Font.GothamBlack

local titleL=Instance.new("TextLabel",TB); titleL.Size=UDim2.new(0,220,0,22); titleL.Position=UDim2.new(0,54,0,6); titleL.BackgroundTransparency=1; titleL.Text="NEXUS ADMIN"; titleL.TextColor3=Color3.fromRGB(225,225,255); titleL.TextSize=16; titleL.Font=Enum.Font.GothamBlack; titleL.TextXAlignment=Enum.TextXAlignment.Left
local subL=Instance.new("TextLabel",TB); subL.Size=UDim2.new(0,220,0,16); subL.Position=UDim2.new(0,54,0,28); subL.BackgroundTransparency=1; subL.Text="v3.0  •  Enhanced Command Suite"; subL.TextColor3=Color3.fromRGB(90,90,130); subL.TextSize=10; subL.Font=Enum.Font.Gotham; subL.TextXAlignment=Enum.TextXAlignment.Left

-- Window controls
local function makeWinBtn(xOff, col, symbol)
    local b=Instance.new("TextButton",TB)
    b.Size=UDim2.new(0,26,0,26); b.Position=UDim2.new(1,xOff,0.5,-13)
    b.BackgroundColor3=col; b.Text=symbol; b.TextColor3=Color3.fromRGB(255,255,255); b.TextSize=11; b.Font=Enum.Font.GothamBold; b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseEnter:Connect(function() tween(b,{BackgroundTransparency=0.3},.1) end)
    b.MouseLeave:Connect(function() tween(b,{BackgroundTransparency=0},.1) end)
    return b
end
local CloseBtn = makeWinBtn(-36, Color3.fromRGB(210,55,55), "✕")
local MinBtn   = makeWinBtn(-68, Color3.fromRGB(50,50,80),  "─")

-- ── Sidebar ───────────────────────────────────
local SB = Instance.new("Frame",W)
SB.Size=UDim2.new(0,138,1,-50); SB.Position=UDim2.new(0,0,0,50)
SB.BackgroundColor3=Color3.fromRGB(11,11,20); SB.BorderSizePixel=0
local sbRight=Instance.new("Frame",SB); sbRight.Size=UDim2.new(0,1,1,0); sbRight.Position=UDim2.new(1,-1,0,0); sbRight.BackgroundColor3=Color3.fromRGB(35,35,60); sbRight.BorderSizePixel=0

-- ── Content Area ──────────────────────────────
local CA = Instance.new("Frame",W)
CA.Size=UDim2.new(1,-138,1,-50); CA.Position=UDim2.new(0,138,0,50)
CA.BackgroundTransparency=1

-- ── Footer ─────────────────────────────────────
local FT = Instance.new("Frame",W)
FT.Size=UDim2.new(1,0,0,52); FT.Position=UDim2.new(0,0,1,-52)
FT.BackgroundColor3=Color3.fromRGB(11,11,20); FT.BorderSizePixel=0; FT.ZIndex=10
Instance.new("UICorner",FT).CornerRadius=UDim.new(0,16)
local ftTop=Instance.new("Frame",FT); ftTop.Size=UDim2.new(1,0,0,16); ftTop.BackgroundColor3=Color3.fromRGB(11,11,20); ftTop.BorderSizePixel=0; ftTop.ZIndex=10
local ftLine=Instance.new("Frame",FT); ftLine.Size=UDim2.new(1,0,0,1); ftLine.BackgroundColor3=Color3.fromRGB(35,35,60); ftLine.BorderSizePixel=0; ftLine.ZIndex=11

local avFrame=Instance.new("Frame",FT); avFrame.Size=UDim2.new(0,36,0,36); avFrame.Position=UDim2.new(0,12,0.5,-18); avFrame.BackgroundColor3=Color3.fromRGB(80,100,255); avFrame.BorderSizePixel=0; avFrame.ZIndex=12
Instance.new("UICorner",avFrame).CornerRadius=UDim.new(1,0)
local avImg=Instance.new("ImageLabel",avFrame); avImg.Size=UDim2.new(1,0,1,0); avImg.BackgroundTransparency=1; avImg.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..LP.UserId.."&width=48&height=48&format=png"; avImg.ZIndex=13
Instance.new("UICorner",avImg).CornerRadius=UDim.new(1,0)

-- online dot
local dot=Instance.new("Frame",avFrame); dot.Size=UDim2.new(0,10,0,10); dot.Position=UDim2.new(1,-10,1,-10); dot.BackgroundColor3=Color3.fromRGB(60,220,110); dot.BorderSizePixel=0; dot.ZIndex=14
Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
local dotStroke=Instance.new("UIStroke",dot); dotStroke.Color=Color3.fromRGB(11,11,20); dotStroke.Thickness=2

local welL=Instance.new("TextLabel",FT); welL.Size=UDim2.new(0,260,0,18); welL.Position=UDim2.new(0,56,0,8); welL.BackgroundTransparency=1; welL.Text="Welcome back,"; welL.TextColor3=Color3.fromRGB(110,110,150); welL.TextSize=10; welL.Font=Enum.Font.Gotham; welL.TextXAlignment=Enum.TextXAlignment.Left; welL.ZIndex=12
local unameL=Instance.new("TextLabel",FT); unameL.Size=UDim2.new(0,300,0,22); unameL.Position=UDim2.new(0,56,0,24); unameL.BackgroundTransparency=1; unameL.Text="⭐  "..LP.Name; unameL.TextColor3=Color3.fromRGB(220,220,255); unameL.TextSize=14; unameL.Font=Enum.Font.GothamBold; unameL.TextXAlignment=Enum.TextXAlignment.Left; unameL.ZIndex=12

local shiftHint=Instance.new("TextLabel",FT); shiftHint.Size=UDim2.new(0,140,0,18); shiftHint.Position=UDim2.new(1,-148,0.5,-9); shiftHint.BackgroundTransparency=1; shiftHint.Text="[RShift] Toggle"; shiftHint.TextColor3=Color3.fromRGB(60,60,90); shiftHint.TextSize=10; shiftHint.Font=Enum.Font.Gotham; shiftHint.TextXAlignment=Enum.TextXAlignment.Right; shiftHint.ZIndex=12

-- ─────────────────────────────────────────────
--  PAGES & TABS
-- ─────────────────────────────────────────────
local TABS = {
    {name="Main",     icon="⌂",  color=Color3.fromRGB(80,150,255)},
    {name="Fun",      icon="★",  color=Color3.fromRGB(150,80,255)},
    {name="Troll",    icon="☠",  color=Color3.fromRGB(255,70,110)},
    {name="Settings", icon="⚙",  color=Color3.fromRGB(60,200,170)},
}

local pages   = {}
local tabBtns = {}
local activeTab = "Main"

-- Sidebar list
local sbList=Instance.new("Frame",SB); sbList.Size=UDim2.new(1,0,1,-10); sbList.Position=UDim2.new(0,0,0,10); sbList.BackgroundTransparency=1
local sbLayout=Instance.new("UIListLayout",sbList); sbLayout.Padding=UDim.new(0,3); sbLayout.SortOrder=Enum.SortOrder.LayoutOrder
local sbPad=Instance.new("UIPadding",sbList); sbPad.PaddingLeft=UDim.new(0,8); sbPad.PaddingRight=UDim.new(0,8)

-- Build pages
for _, tab in ipairs(TABS) do
    local pg = Instance.new("ScrollingFrame",CA)
    pg.Name=tab.name.."Page"; pg.Size=UDim2.new(1,0,1,-52)
    pg.Position=UDim2.new(0,0,0,0); pg.BackgroundTransparency=1
    pg.BorderSizePixel=0; pg.ScrollBarThickness=3
    pg.ScrollBarImageColor3=tab.color; pg.Visible=false
    pg.CanvasSize=UDim2.new(0,0,0,0); pg.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local pgL=Instance.new("UIListLayout",pg); pgL.Padding=UDim.new(0,7); pgL.SortOrder=Enum.SortOrder.LayoutOrder
    local pgP=Instance.new("UIPadding",pg); pgP.PaddingLeft=UDim.new(0,14); pgP.PaddingRight=UDim.new(0,14); pgP.PaddingTop=UDim.new(0,12); pgP.PaddingBottom=UDim.new(0,14)
    pages[tab.name] = pg
end

-- Build tab buttons
for i, tab in ipairs(TABS) do
    local btn=Instance.new("TextButton",sbList)
    btn.Name=tab.name.."Tab"; btn.Size=UDim2.new(1,0,0,44); btn.BackgroundColor3=Color3.fromRGB(16,16,28); btn.Text=""; btn.BorderSizePixel=0; btn.LayoutOrder=i
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)

    local aBar=Instance.new("Frame",btn); aBar.Name="ABar"; aBar.Size=UDim2.new(0,3,0.55,0); aBar.Position=UDim2.new(0,0,0.225,0); aBar.BackgroundColor3=tab.color; aBar.BorderSizePixel=0; aBar.Visible=false
    Instance.new("UICorner",aBar).CornerRadius=UDim.new(1,0)

    local ic=Instance.new("TextLabel",btn); ic.Size=UDim2.new(0,28,0,28); ic.Position=UDim2.new(0,9,0.5,-14); ic.BackgroundTransparency=1; ic.Text=tab.icon; ic.TextColor3=Color3.fromRGB(180,180,220); ic.TextSize=17; ic.Font=Enum.Font.GothamBold

    local nl=Instance.new("TextLabel",btn); nl.Name="NL"; nl.Size=UDim2.new(1,-44,1,0); nl.Position=UDim2.new(0,42,0,0); nl.BackgroundTransparency=1; nl.Text=tab.name; nl.TextColor3=Color3.fromRGB(120,120,160); nl.TextSize=12; nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left

    tabBtns[tab.name]={btn=btn,color=tab.color,nl=nl,abar=aBar,ic=ic}

    btn.MouseButton1Click:Connect(function()
        for _,t in ipairs(TABS) do
            local tb=tabBtns[t.name]
            tween(tb.btn,{BackgroundColor3=Color3.fromRGB(16,16,28)},.15)
            tb.nl.TextColor3=Color3.fromRGB(120,120,160); tb.abar.Visible=false; tb.ic.TextColor3=Color3.fromRGB(180,180,220)
            pages[t.name].Visible=false
        end
        tween(btn,{BackgroundColor3=Color3.fromRGB(22,22,38)},.15)
        tabBtns[tab.name].nl.TextColor3=tab.color; aBar.Visible=true; ic.TextColor3=tab.color
        pages[tab.name].Visible=true; activeTab=tab.name
    end)
end
-- activate first
do
    local t=TABS[1]; local tb=tabBtns[t.name]
    tb.btn.BackgroundColor3=Color3.fromRGB(22,22,38); tb.nl.TextColor3=t.color; tb.abar.Visible=true; tb.ic.TextColor3=t.color
    pages[t.name].Visible=true
end

-- ─────────────────────────────────────────────
--  PAGE HEADER
-- ─────────────────────────────────────────────
local function PageHeader(page, title, sub, col)
    local h=Instance.new("Frame",page); h.Size=UDim2.new(1,0,0,52); h.BackgroundColor3=Color3.fromRGB(16,16,28); h.BorderSizePixel=0
    Instance.new("UICorner",h).CornerRadius=UDim.new(0,12)
    local hb=Instance.new("Frame",h); hb.Size=UDim2.new(0,4,0.6,0); hb.Position=UDim2.new(0,0,0.2,0); hb.BackgroundColor3=col; hb.BorderSizePixel=0
    Instance.new("UICorner",hb).CornerRadius=UDim.new(1,0)
    local tl=Instance.new("TextLabel",h); tl.Size=UDim2.new(1,-16,0,22); tl.Position=UDim2.new(0,14,0,8); tl.BackgroundTransparency=1; tl.Text=title; tl.TextColor3=Color3.fromRGB(225,225,255); tl.TextSize=14; tl.Font=Enum.Font.GothamBlack; tl.TextXAlignment=Enum.TextXAlignment.Left
    local sl=Instance.new("TextLabel",h); sl.Size=UDim2.new(1,-16,0,16); sl.Position=UDim2.new(0,14,0,32); sl.BackgroundTransparency=1; sl.Text=sub; sl.TextColor3=Color3.fromRGB(90,90,130); sl.TextSize=10; sl.Font=Enum.Font.Gotham; sl.TextXAlignment=Enum.TextXAlignment.Left
end

-- ─────────────────────────────────────────────
--  SECTION LABEL
-- ─────────────────────────────────────────────
local function SectionLabel(page, text)
    local sl=Instance.new("TextLabel",page); sl.Size=UDim2.new(1,0,0,20); sl.BackgroundTransparency=1; sl.Text="  "..text; sl.TextColor3=Color3.fromRGB(80,80,120); sl.TextSize=10; sl.Font=Enum.Font.GothamBold; sl.TextXAlignment=Enum.TextXAlignment.Left
end

-- ─────────────────────────────────────────────
--  SLIDER CARD
-- ─────────────────────────────────────────────
local function SliderCard(page, label, desc, col, minV, maxV, defV, onChange)
    local card=Instance.new("Frame",page); card.Size=UDim2.new(1,0,0,76); card.BackgroundColor3=Color3.fromRGB(16,16,28); card.BorderSizePixel=0
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,12)
    local cs=Instance.new("UIStroke",card); cs.Color=Color3.fromRGB(38,38,62); cs.Thickness=1

    local cBar=Instance.new("Frame",card); cBar.Size=UDim2.new(0,4,0.6,0); cBar.Position=UDim2.new(0,0,0.2,0); cBar.BackgroundColor3=col; cBar.BorderSizePixel=0
    Instance.new("UICorner",cBar).CornerRadius=UDim.new(1,0)

    local nameL=Instance.new("TextLabel",card); nameL.Size=UDim2.new(0.6,0,0,22); nameL.Position=UDim2.new(0,14,0,8); nameL.BackgroundTransparency=1; nameL.Text=label; nameL.TextColor3=Color3.fromRGB(220,220,255); nameL.TextSize=12; nameL.Font=Enum.Font.GothamBold; nameL.TextXAlignment=Enum.TextXAlignment.Left
    local descL=Instance.new("TextLabel",card); descL.Size=UDim2.new(0.6,0,0,16); descL.Position=UDim2.new(0,14,0,28); descL.BackgroundTransparency=1; descL.Text=desc; descL.TextColor3=Color3.fromRGB(90,90,130); descL.TextSize=10; descL.Font=Enum.Font.Gotham; descL.TextXAlignment=Enum.TextXAlignment.Left

    local valL=Instance.new("TextLabel",card); valL.Size=UDim2.new(0,50,0,22); valL.Position=UDim2.new(1,-60,0,8); valL.BackgroundTransparency=1; valL.Text=tostring(defV); valL.TextColor3=col; valL.TextSize=13; valL.Font=Enum.Font.GothamBlack; valL.TextXAlignment=Enum.TextXAlignment.Center

    -- track
    local track=Instance.new("Frame",card); track.Size=UDim2.new(1,-28,0,6); track.Position=UDim2.new(0,14,0,54); track.BackgroundColor3=Color3.fromRGB(28,28,48); track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame",track); fill.Size=UDim2.new((defV-minV)/(maxV-minV),0,1,0); fill.BackgroundColor3=col; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local fillG=Instance.new("UIGradient",fill); fillG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,col),ColorSequenceKeypoint.new(1,Color3.new(math.min(col.R+0.2,1),math.min(col.G+0.2,1),math.min(col.B+0.2,1)))}

    local thumb=Instance.new("Frame",track); thumb.Size=UDim2.new(0,14,0,14); thumb.BackgroundColor3=Color3.fromRGB(255,255,255); thumb.BorderSizePixel=0; thumb.ZIndex=5
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local ts=Instance.new("UIStroke",thumb); ts.Color=col; ts.Thickness=2

    local function setVal(v)
        v=math.clamp(math.floor(v),minV,maxV)
        local pct=(v-minV)/(maxV-minV)
        tween(fill,{Size=UDim2.new(pct,0,1,0)},.05)
        thumb.Position=UDim2.new(pct,-(thumb.AbsoluteSize.X/2),0.5,-(thumb.AbsoluteSize.Y/2))
        valL.Text=tostring(v)
        onChange(v)
    end

    local dragging=false
    thumb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local tAbs=track.AbsolutePosition; local tSize=track.AbsoluteSize
            local pct=math.clamp((i.Position.X-tAbs.X)/tSize.X,0,1)
            setVal(minV+pct*(maxV-minV))
        end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local pct=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            setVal(minV+pct*(maxV-minV))
        end
    end)
    task.defer(function() setVal(defV) end)
end

-- ─────────────────────────────────────────────
--  TOGGLE CARD
-- ─────────────────────────────────────────────
local function ToggleCard(page, label, desc, col, onEnable, onDisable)
    local card=Instance.new("Frame",page); card.Size=UDim2.new(1,0,0,64); card.BackgroundColor3=Color3.fromRGB(16,16,28); card.BorderSizePixel=0
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,12)
    local cs=Instance.new("UIStroke",card); cs.Color=Color3.fromRGB(38,38,62); cs.Thickness=1

    local cBar=Instance.new("Frame",card); cBar.Size=UDim2.new(0,4,0.6,0); cBar.Position=UDim2.new(0,0,0.2,0); cBar.BackgroundColor3=col; cBar.BorderSizePixel=0
    Instance.new("UICorner",cBar).CornerRadius=UDim.new(1,0)

    local nameL=Instance.new("TextLabel",card); nameL.Size=UDim2.new(0.65,0,0,22); nameL.Position=UDim2.new(0,14,0,10); nameL.BackgroundTransparency=1; nameL.Text=label; nameL.TextColor3=Color3.fromRGB(220,220,255); nameL.TextSize=12; nameL.Font=Enum.Font.GothamBold; nameL.TextXAlignment=Enum.TextXAlignment.Left
    local descL=Instance.new("TextLabel",card); descL.Size=UDim2.new(0.65,0,0,18); descL.Position=UDim2.new(0,14,0,32); descL.BackgroundTransparency=1; descL.Text=desc; descL.TextColor3=Color3.fromRGB(90,90,130); descL.TextSize=10; descL.Font=Enum.Font.Gotham; descL.TextXAlignment=Enum.TextXAlignment.Left

    -- toggle pill
    local pill=Instance.new("Frame",card); pill.Size=UDim2.new(0,46,0,24); pill.Position=UDim2.new(1,-60,0.5,-12); pill.BackgroundColor3=Color3.fromRGB(30,30,50); pill.BorderSizePixel=0
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local pknob=Instance.new("Frame",pill); pknob.Size=UDim2.new(0,18,0,18); pknob.Position=UDim2.new(0,3,0.5,-9); pknob.BackgroundColor3=Color3.fromRGB(100,100,140); pknob.BorderSizePixel=0
    Instance.new("UICorner",pknob).CornerRadius=UDim.new(1,0)

    local on=false
    local clickable=Instance.new("TextButton",card); clickable.Size=UDim2.new(1,0,1,0); clickable.BackgroundTransparency=1; clickable.Text=""
    clickable.MouseButton1Click:Connect(function()
        on=not on
        if on then
            tween(pill,{BackgroundColor3=col},.2)
            tween(pknob,{Position=UDim2.new(1,-21,0.5,-9),BackgroundColor3=Color3.fromRGB(255,255,255)},.2,"Back","Out")
            onEnable()
        else
            tween(pill,{BackgroundColor3=Color3.fromRGB(30,30,50)},.2)
            tween(pknob,{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.fromRGB(100,100,140)},.2)
            onDisable()
        end
    end)
end

-- ─────────────────────────────────────────────
--  BUTTON CARD
-- ─────────────────────────────────────────────
local function ButtonCard(page, label, desc, col, btnText, onRun)
    local card=Instance.new("Frame",page); card.Size=UDim2.new(1,0,0,64); card.BackgroundColor3=Color3.fromRGB(16,16,28); card.BorderSizePixel=0
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,12)
    local cs=Instance.new("UIStroke",card); cs.Color=Color3.fromRGB(38,38,62); cs.Thickness=1

    local cBar=Instance.new("Frame",card); cBar.Size=UDim2.new(0,4,0.6,0); cBar.Position=UDim2.new(0,0,0.2,0); cBar.BackgroundColor3=col; cBar.BorderSizePixel=0
    Instance.new("UICorner",cBar).CornerRadius=UDim.new(1,0)

    local nameL=Instance.new("TextLabel",card); nameL.Size=UDim2.new(0.62,0,0,22); nameL.Position=UDim2.new(0,14,0,10); nameL.BackgroundTransparency=1; nameL.Text=label; nameL.TextColor3=Color3.fromRGB(220,220,255); nameL.TextSize=12; nameL.Font=Enum.Font.GothamBold; nameL.TextXAlignment=Enum.TextXAlignment.Left
    local descL=Instance.new("TextLabel",card); descL.Size=UDim2.new(0.62,0,0,18); descL.Position=UDim2.new(0,14,0,32); descL.BackgroundTransparency=1; descL.Text=desc; descL.TextColor3=Color3.fromRGB(90,90,130); descL.TextSize=10; descL.Font=Enum.Font.Gotham; descL.TextXAlignment=Enum.TextXAlignment.Left

    local btn=Instance.new("TextButton",card); btn.Size=UDim2.new(0,78,0,30); btn.Position=UDim2.new(1,-88,0.5,-15); btn.BackgroundColor3=col; btn.Text=btnText or "Run"; btn.TextColor3=Color3.fromRGB(255,255,255); btn.TextSize=11; btn.Font=Enum.Font.GothamBold; btn.BorderSizePixel=0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7)
    local bg=Instance.new("UIGradient",btn); bg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(math.min(col.R+0.15,1),math.min(col.G+0.15,1),math.min(col.B+0.15,1))),ColorSequenceKeypoint.new(1,col)}; bg.Rotation=90

    btn.MouseButton1Click:Connect(function()
        tween(btn,{BackgroundTransparency=0.4},.08)
        task.delay(.15,function() tween(btn,{BackgroundTransparency=0},.1) end)
        onRun()
    end)
    btn.MouseEnter:Connect(function() tween(btn,{Size=UDim2.new(0,82,0,32),Position=UDim2.new(1,-90,0.5,-16)},.1,"Back","Out") end)
    btn.MouseLeave:Connect(function() tween(btn,{Size=UDim2.new(0,78,0,30),Position=UDim2.new(1,-88,0.5,-15)},.1) end)
end

-- ─────────────────────────────────────────────
--  GLOBAL STATES
-- ─────────────────────────────────────────────
_G.NX = _G.NX or {}
local NX = _G.NX

local function stopConn(key) if NX[key] then NX[key]:Disconnect(); NX[key]=nil end end
local function killConn(key) if NX[key] then task.cancel(NX[key]); NX[key]=nil end end

-- ─────────────────────────────────────────────
--  ═══════════  MAIN TAB  ═══════════
-- ─────────────────────────────────────────────
PageHeader(pages["Main"],"Main Commands","Movement, survival & utility",Color3.fromRGB(80,150,255))

-- WalkSpeed slider
SectionLabel(pages["Main"],"⚡  Movement")
SliderCard(pages["Main"],"Walk Speed","Adjust your walk speed",Color3.fromRGB(80,160,255),2,250,16,function(v)
    local h=getHum(); if h then h.WalkSpeed=v end
end)
SliderCard(pages["Main"],"Jump Power","Adjust your jump power",Color3.fromRGB(100,200,255),0,400,50,function(v)
    local h=getHum(); if h then h.JumpPower=v end
end)

SectionLabel(pages["Main"],"🛡  Survival")
ToggleCard(pages["Main"],"God Mode","Regen HP every frame",Color3.fromRGB(255,165,50),
    function()
        NX.god=true; NX.godConn=RunService.Heartbeat:Connect(function() if not NX.god then return end local h=getHum(); if h then h.Health=h.MaxHealth end end)
        Notif("God Mode","You are immortal!","success")
    end,
    function() NX.god=false; stopConn("godConn"); Notif("God Mode","Disabled.","warn") end
)
ToggleCard(pages["Main"],"Infinite Jump","Jump from mid-air",Color3.fromRGB(100,220,120),
    function()
        NX.ij=true; NX.ijConn=UserInputService.JumpRequest:Connect(function() if NX.ij then local h=getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
        Notif("Infinite Jump","Jump anywhere!","success")
    end,
    function() NX.ij=false; stopConn("ijConn"); Notif("Infinite Jump","Disabled.","warn") end
)
ToggleCard(pages["Main"],"Noclip","Phase through walls",Color3.fromRGB(170,100,255),
    function()
        NX.nc=true; NX.ncConn=RunService.Stepped:Connect(function() if not NX.nc then return end local c=getChar(); if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end)
        Notif("Noclip","Phase through walls!","success")
    end,
    function()
        NX.nc=false; stopConn("ncConn"); local c=getChar(); if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
        Notif("Noclip","Disabled.","warn")
    end
)

SectionLabel(pages["Main"],"✈  Flight")
ToggleCard(pages["Main"],"Fly","Use WASD+Space/Ctrl to fly",Color3.fromRGB(80,160,255),
    function()
        local c=LP.Character or LP.CharacterAdded:Wait()
        local hrp=c:WaitForChild("HumanoidRootPart")
        local bv=Instance.new("BodyVelocity",hrp); bv.Name="NxFlyBV"; bv.Velocity=Vector3.new(0,0,0); bv.MaxForce=Vector3.new(1e5,1e5,1e5)
        local bg=Instance.new("BodyGyro",hrp); bg.Name="NxFlyBG"; bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.CFrame=hrp.CFrame
        NX.fly=true
        NX.flyConn=RunService.RenderStepped:Connect(function()
            if not NX.fly then return end
            local cam=workspace.CurrentCamera; local spd=50; local d=Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then d=d-Vector3.new(0,1,0) end
            bv.Velocity=d.Magnitude>0 and d.Unit*spd or Vector3.new(0,0,0)
            bg.CFrame=cam.CFrame
        end)
        Notif("Fly Enabled","WASD + Space/Ctrl","success")
    end,
    function()
        NX.fly=false; stopConn("flyConn")
        local c=getChar(); local hrp=c and c:FindFirstChild("HumanoidRootPart")
        if hrp then local b=hrp:FindFirstChild("NxFlyBV"); local g=hrp:FindFirstChild("NxFlyBG"); if b then b:Destroy() end if g then g:Destroy() end end
        Notif("Fly","Landed.","warn")
    end
)

SectionLabel(pages["Main"],"🔧  Utility")
ButtonCard(pages["Main"],"Respawn","Reload your character",Color3.fromRGB(80,200,200),"Respawn",function() LP:LoadCharacter(); Notif("Respawn","Character reloaded.","info") end)
ButtonCard(pages["Main"],"Rejoin","Rejoin the current server",Color3.fromRGB(80,160,255),"Rejoin",function()
    local ts=game:GetService("TeleportService"); ts:Teleport(game.PlaceId,LP); Notif("Rejoin","Rejoining...","info")
end)

-- ─────────────────────────────────────────────
--  ═══════════  FUN TAB  ═══════════
-- ─────────────────────────────────────────────
PageHeader(pages["Fun"],"Fun Commands","Visual effects & fun stuff",Color3.fromRGB(150,80,255))

SectionLabel(pages["Fun"],"🎨  Visual")
ToggleCard(pages["Fun"],"Rainbow Body","Cycle hue across all parts",Color3.fromRGB(255,80,150),
    function()
        NX.rainbowHue=0; NX.rbConn=RunService.Heartbeat:Connect(function() NX.rainbowHue=(NX.rainbowHue or 0)+0.004; local c=getChar(); if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Color=Color3.fromHSV(NX.rainbowHue%1,1,1) end end end end)
        Notif("Rainbow Body","Disco time!","success")
    end,
    function() stopConn("rbConn"); Notif("Rainbow Body","Off.","info") end
)
ToggleCard(pages["Fun"],"Seizure Mode","Rapid random color changes",Color3.fromRGB(255,220,40),
    function()
        NX.seiz=true
        task.spawn(function() while NX.seiz do local c=getChar(); if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Color=Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255)) end end end task.wait(0.04) end end)
        Notif("Seizure Mode","🎉","warn")
    end,
    function() NX.seiz=false; Notif("Seizure Mode","Stopped.","info") end
)
ToggleCard(pages["Fun"],"Invisible","Full body transparency",Color3.fromRGB(100,180,240),
    function()
        NX.inv=true; local c=getChar(); if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Transparency=1 end end end
        Notif("Invisible","👻 Now you see me...","success")
    end,
    function()
        NX.inv=false; local c=getChar(); if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Transparency=0 end end end
        Notif("Visible","Back to normal.","info")
    end
)

SectionLabel(pages["Fun"],"📐  Scale")
ToggleCard(pages["Fun"],"Big Head","Giant head mode",Color3.fromRGB(255,120,200),
    function() local h=getHum(); if h then h.HeadScale.Value=4 end; Notif("Big Head","Massive cranium activated!","success") end,
    function() local h=getHum(); if h then h.HeadScale.Value=1 end; Notif("Big Head","Restored.","info") end
)
ToggleCard(pages["Fun"],"Tiny Mode","Shrink to ant size",Color3.fromRGB(160,255,100),
    function()
        local h=getHum(); if h then h.BodyDepthScale.Value=0.15; h.BodyHeightScale.Value=0.15; h.BodyWidthScale.Value=0.15; h.HeadScale.Value=0.15 end
        Notif("Tiny Mode","You're microscopic!","success")
    end,
    function()
        local h=getHum(); if h then h.BodyDepthScale.Value=1; h.BodyHeightScale.Value=1; h.BodyWidthScale.Value=1; h.HeadScale.Value=1 end
        Notif("Tiny Mode","Normal size restored.","info")
    end
)

SectionLabel(pages["Fun"],"🎭  Actions")
ButtonCard(pages["Fun"],"Rocket Launch","YEET upward",Color3.fromRGB(255,140,40),"Launch!",function()
    local hrp=getHRP(); if hrp then local bv=Instance.new("BodyVelocity",hrp); bv.Velocity=Vector3.new(0,220,0); bv.MaxForce=Vector3.new(0,1e6,0); task.delay(0.35,function() bv:Destroy() end) end
    Notif("Rocket Launch","🚀 To the moon!","success")
end)
ToggleCard(pages["Fun"],"Spin","Spin your character",Color3.fromRGB(60,200,255),
    function()
        NX.spinConn=RunService.RenderStepped:Connect(function() local hrp=getHRP(); if hrp then hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(7),0) end end)
        Notif("Spin","🌀 Wheee!","success")
    end,
    function() stopConn("spinConn"); Notif("Spin","Stopped.","info") end
)
ToggleCard(pages["Fun"],"Freeze","Anchor yourself in place",Color3.fromRGB(60,200,240),
    function() local hrp=getHRP(); if hrp then hrp.Anchored=true end; Notif("Frozen","🧊 Frozen solid!","warn") end,
    function() local hrp=getHRP(); if hrp then hrp.Anchored=false end; Notif("Frozen","Unfrozen!","success") end
)

-- ─────────────────────────────────────────────
--  ═══════════  TROLL TAB  ═══════════
-- ─────────────────────────────────────────────
PageHeader(pages["Troll"],"Troll Commands","Select a player → pick a troll → Run!",Color3.fromRGB(255,70,110))

-- ── Player Selector ───────────────────────────
local selectorCard=Instance.new("Frame",pages["Troll"])
selectorCard.Size=UDim2.new(1,0,0,110); selectorCard.BackgroundColor3=Color3.fromRGB(16,16,28); selectorCard.BorderSizePixel=0
Instance.new("UICorner",selectorCard).CornerRadius=UDim.new(0,12)
local scs=Instance.new("UIStroke",selectorCard); scs.Color=Color3.fromRGB(255,70,110); scs.Thickness=1.5; scs.Transparency=0.5

local selTitle=Instance.new("TextLabel",selectorCard); selTitle.Size=UDim2.new(1,-16,0,20); selTitle.Position=UDim2.new(0,14,0,8); selTitle.BackgroundTransparency=1; selTitle.Text="🎯  SELECT TARGET PLAYER"; selTitle.TextColor3=Color3.fromRGB(255,90,130); selTitle.TextSize=11; selTitle.Font=Enum.Font.GothamBold; selTitle.TextXAlignment=Enum.TextXAlignment.Left

-- Dropdown button
local dropBtn=Instance.new("TextButton",selectorCard)
dropBtn.Size=UDim2.new(1,-28,0,32); dropBtn.Position=UDim2.new(0,14,0,32)
dropBtn.BackgroundColor3=Color3.fromRGB(22,22,40); dropBtn.Text=""; dropBtn.BorderSizePixel=0
Instance.new("UICorner",dropBtn).CornerRadius=UDim.new(0,8)
local dbs=Instance.new("UIStroke",dropBtn); dbs.Color=Color3.fromRGB(60,60,100); dbs.Thickness=1

local selName=Instance.new("TextLabel",dropBtn); selName.Size=UDim2.new(1,-40,1,0); selName.Position=UDim2.new(0,12,0,0); selName.BackgroundTransparency=1; selName.Text="No player selected..."; selName.TextColor3=Color3.fromRGB(140,140,180); selName.TextSize=11; selName.Font=Enum.Font.Gotham; selName.TextXAlignment=Enum.TextXAlignment.Left
local dropArrow=Instance.new("TextLabel",dropBtn); dropArrow.Size=UDim2.new(0,24,1,0); dropArrow.Position=UDim2.new(1,-28,0,0); dropArrow.BackgroundTransparency=1; dropArrow.Text="▾"; dropArrow.TextColor3=Color3.fromRGB(255,70,110); dropArrow.TextSize=14; dropArrow.Font=Enum.Font.GothamBold

-- Refresh + selected avatar
local selAvFrame=Instance.new("Frame",selectorCard); selAvFrame.Size=UDim2.new(0,30,0,30); selAvFrame.Position=UDim2.new(0,14,0,72); selAvFrame.BackgroundColor3=Color3.fromRGB(255,70,110); selAvFrame.BorderSizePixel=0; selAvFrame.BackgroundTransparency=0.6
Instance.new("UICorner",selAvFrame).CornerRadius=UDim.new(1,0)
local selAvImg=Instance.new("ImageLabel",selAvFrame); selAvImg.Size=UDim2.new(1,0,1,0); selAvImg.BackgroundTransparency=1; selAvImg.Image=""
Instance.new("UICorner",selAvImg).CornerRadius=UDim.new(1,0)

local selInfoL=Instance.new("TextLabel",selectorCard); selInfoL.Size=UDim2.new(1,-60,0,22); selInfoL.Position=UDim2.new(0,52,0,78); selInfoL.BackgroundTransparency=1; selInfoL.Text="No target selected"; selInfoL.TextColor3=Color3.fromRGB(100,100,140); selInfoL.TextSize=10; selInfoL.Font=Enum.Font.Gotham; selInfoL.TextXAlignment=Enum.TextXAlignment.Left

-- Dropdown list (scroll)
local dropFrame=Instance.new("Frame",SG)
dropFrame.Name="TrollDropdown"; dropFrame.Size=UDim2.new(0,260,0,0); dropFrame.BackgroundColor3=Color3.fromRGB(18,18,32); dropFrame.BorderSizePixel=0; dropFrame.Visible=false; dropFrame.ZIndex=50
Instance.new("UICorner",dropFrame).CornerRadius=UDim.new(0,10)
local dfs=Instance.new("UIStroke",dropFrame); dfs.Color=Color3.fromRGB(255,70,110); dfs.Thickness=1.5; dfs.Transparency=0.4

local dropScroll=Instance.new("ScrollingFrame",dropFrame); dropScroll.Size=UDim2.new(1,-4,1,-4); dropScroll.Position=UDim2.new(0,2,0,2); dropScroll.BackgroundTransparency=1; dropScroll.BorderSizePixel=0; dropScroll.ScrollBarThickness=3; dropScroll.ScrollBarImageColor3=Color3.fromRGB(255,70,110); dropScroll.CanvasSize=UDim2.new(0,0,0,0); dropScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; dropScroll.ZIndex=51
local dropLayout=Instance.new("UIListLayout",dropScroll); dropLayout.Padding=UDim.new(0,2); dropLayout.SortOrder=Enum.SortOrder.LayoutOrder
local dropPad=Instance.new("UIPadding",dropScroll); dropPad.PaddingLeft=UDim.new(0,4); dropPad.PaddingRight=UDim.new(0,4); dropPad.PaddingTop=UDim.new(0,4); dropPad.PaddingBottom=UDim.new(0,4)

local selectedTarget = nil
local dropOpen = false

local function closeDropdown()
    dropOpen=false
    tween(dropFrame,{Size=UDim2.new(0,260,0,0)},.2,"Quart","In")
    task.delay(.21,function() dropFrame.Visible=false end)
    tween(dropArrow,{Rotation=0},.2)
end

local function refreshPlayers()
    for _,c in ipairs(dropScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _,plr in ipairs(Players:GetPlayers()) do
        local pb=Instance.new("TextButton",dropScroll)
        pb.Size=UDim2.new(1,0,0,36); pb.BackgroundColor3=Color3.fromRGB(22,22,38); pb.Text=""; pb.BorderSizePixel=0; pb.ZIndex=52
        Instance.new("UICorner",pb).CornerRadius=UDim.new(0,7)

        local av=Instance.new("ImageLabel",pb); av.Size=UDim2.new(0,26,0,26); av.Position=UDim2.new(0,6,0.5,-13); av.BackgroundTransparency=1; av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..plr.UserId.."&width=48&height=48&format=png"; av.ZIndex=53
        Instance.new("UICorner",av).CornerRadius=UDim.new(1,0)

        local nl=Instance.new("TextLabel",pb); nl.Size=UDim2.new(1,-44,1,0); nl.Position=UDim2.new(0,38,0,0); nl.BackgroundTransparency=1; nl.Text=plr.Name; nl.TextColor3=plr==LP and Color3.fromRGB(255,200,80) or Color3.fromRGB(210,210,240); nl.TextSize=12; nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=53
        if plr==LP then local you=Instance.new("TextLabel",pb); you.Size=UDim2.new(0,30,0,16); you.Position=UDim2.new(1,-36,0.5,-8); you.BackgroundColor3=Color3.fromRGB(255,180,30); you.Text="YOU"; you.TextColor3=Color3.fromRGB(0,0,0); you.TextSize=8; you.Font=Enum.Font.GothamBold; you.BorderSizePixel=0; you.ZIndex=53; Instance.new("UICorner",you).CornerRadius=UDim.new(0,4) end

        pb.MouseEnter:Connect(function() tween(pb,{BackgroundColor3=Color3.fromRGB(30,30,54)},.1) end)
        pb.MouseLeave:Connect(function() tween(pb,{BackgroundColor3=Color3.fromRGB(22,22,38)},.1) end)
        pb.MouseButton1Click:Connect(function()
            selectedTarget=plr
            selName.Text="🎯  "..plr.Name
            selName.TextColor3=Color3.fromRGB(220,220,255)
            selAvImg.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..plr.UserId.."&width=48&height=48&format=png"
            selInfoL.Text=plr.Name.." • UserId: "..plr.UserId
            selInfoL.TextColor3=Color3.fromRGB(255,90,130)
            closeDropdown()
        end)
    end
end

dropBtn.MouseButton1Click:Connect(function()
    refreshPlayers()
    if dropOpen then closeDropdown(); return end
    dropOpen=true
    local abs=dropBtn.AbsolutePosition; local absSz=dropBtn.AbsoluteSize
    local maxH=math.min(#Players:GetPlayers()*40+12,200)
    dropFrame.Position=UDim2.new(0,abs.X,0,abs.Y+absSz.Y+4)
    dropFrame.Size=UDim2.new(0,260,0,0)
    dropFrame.Visible=true
    tween(dropFrame,{Size=UDim2.new(0,260,0,maxH)},.25,"Back","Out")
    tween(dropArrow,{Rotation=180},.2)
end)

UserInputService.InputBegan:Connect(function(inp,proc)
    if proc then return end
    if inp.UserInputType==Enum.UserInputType.MouseButton1 and dropOpen then
        local mPos=UserInputService:GetMouseLocation()
        local df=dropFrame.AbsolutePosition; local ds=dropFrame.AbsoluteSize
        if not (mPos.X>=df.X and mPos.X<=df.X+ds.X and mPos.Y>=df.Y and mPos.Y<=df.Y+ds.Y) then
            closeDropdown()
        end
    end
end)

-- ── Troll Command List ────────────────────────
local trollLabel=Instance.new("TextLabel",pages["Troll"]); trollLabel.Size=UDim2.new(1,0,0,20); trollLabel.BackgroundTransparency=1; trollLabel.Text="  ☠  TROLL COMMANDS  —  pick target first!"; trollLabel.TextColor3=Color3.fromRGB(80,80,120); trollLabel.TextSize=10; trollLabel.Font=Enum.Font.GothamBold; trollLabel.TextXAlignment=Enum.TextXAlignment.Left

local function getTarget()
    if not selectedTarget then Notif("No Target","Select a player first!","error"); return nil end
    local found = Players:FindFirstChild(selectedTarget.Name)
    if not found then Notif("Target Gone","That player left!","error"); return nil end
    return found
end

local function TrollBtn(label, desc, col, btnTxt, onRun)
    local card=Instance.new("Frame",pages["Troll"]); card.Size=UDim2.new(1,0,0,64); card.BackgroundColor3=Color3.fromRGB(16,16,28); card.BorderSizePixel=0
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,12)
    local cs=Instance.new("UIStroke",card); cs.Color=Color3.fromRGB(60,20,30); cs.Thickness=1

    local cBar=Instance.new("Frame",card); cBar.Size=UDim2.new(0,4,0.6,0); cBar.Position=UDim2.new(0,0,0.2,0); cBar.BackgroundColor3=col; cBar.BorderSizePixel=0
    Instance.new("UICorner",cBar).CornerRadius=UDim.new(1,0)

    local nl=Instance.new("TextLabel",card); nl.Size=UDim2.new(0.62,0,0,22); nl.Position=UDim2.new(0,14,0,10); nl.BackgroundTransparency=1; nl.Text=label; nl.TextColor3=Color3.fromRGB(220,220,255); nl.TextSize=12; nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left
    local dl=Instance.new("TextLabel",card); dl.Size=UDim2.new(0.62,0,0,18); dl.Position=UDim2.new(0,14,0,32); dl.BackgroundTransparency=1; dl.Text=desc; dl.TextColor3=Color3.fromRGB(90,90,130); dl.TextSize=10; dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left

    local btn=Instance.new("TextButton",card); btn.Size=UDim2.new(0,78,0,30); btn.Position=UDim2.new(1,-88,0.5,-15); btn.BackgroundColor3=col; btn.Text=btnTxt or "Troll"; btn.TextColor3=Color3.fromRGB(255,255,255); btn.TextSize=11; btn.Font=Enum.Font.GothamBold; btn.BorderSizePixel=0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7)

    btn.MouseButton1Click:Connect(function()
        local tgt=getTarget(); if not tgt then return end
        tween(btn,{BackgroundTransparency=0.5},.08); task.delay(.15,function() tween(btn,{BackgroundTransparency=0},.1) end)
        onRun(tgt)
    end)
    btn.MouseEnter:Connect(function() tween(btn,{Size=UDim2.new(0,82,0,32),Position=UDim2.new(1,-90,0.5,-16)},.1,"Back","Out") end)
    btn.MouseLeave:Connect(function() tween(btn,{Size=UDim2.new(0,78,0,30),Position=UDim2.new(1,-88,0.5,-15)},.1) end)
end

-- ── Troll Commands ────────────────────────────
TrollBtn("☠  Kill","Respawn the target",Color3.fromRGB(220,40,60),"Kill",function(tgt)
    local c=tgt.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
    if h then h.Health=0; Notif("Kill","☠ "..tgt.Name.." has been eliminated!","success")
    else Notif("Kill","Can't find their character.","error") end
end)

TrollBtn("💥  Fling","Launch them across the map",Color3.fromRGB(255,100,40),"Fling",function(tgt)
    local c=tgt.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bv=Instance.new("BodyVelocity",hrp); bv.Velocity=Vector3.new(math.random(-300,300),500,math.random(-300,300)); bv.MaxForce=Vector3.new(1e6,1e6,1e6); bv.Name="NxFling"
        task.delay(0.2,function() if bv.Parent then bv:Destroy() end end)
        Notif("Fling","💥 "..tgt.Name.." got yoinked!","success")
    else Notif("Fling","Target has no HRP.","error") end
end)

TrollBtn("👁  Big Head","Give them a giant head",Color3.fromRGB(255,80,180),"BigHead",function(tgt)
    local c=tgt.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
    if h then h.HeadScale.Value=4; Notif("Big Head",tgt.Name.." has a massive head now 👁","success")
    else Notif("Big Head","Failed.","error") end
end)

TrollBtn("🐜  Small Head","Shrink their head tiny",Color3.fromRGB(160,255,80),"SmHead",function(tgt)
    local c=tgt.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
    if h then h.HeadScale.Value=0.2; Notif("Small Head",tgt.Name.." has a pinhead 🐜","success")
    else Notif("Small Head","Failed.","error") end
end)

TrollBtn("🏔  Big Body","Make their body massive",Color3.fromRGB(255,140,40),"BigBody",function(tgt)
    local c=tgt.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
    if h then h.BodyDepthScale.Value=4; h.BodyHeightScale.Value=4; h.BodyWidthScale.Value=4; h.HeadScale.Value=4
        Notif("Big Body","GIANT "..tgt.Name,"success")
    else Notif("Big Body","Failed.","error") end
end)

TrollBtn("🦟  Small Body","Shrink them to nothing",Color3.fromRGB(100,220,80),"SmBody",function(tgt)
    local c=tgt.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
    if h then h.BodyDepthScale.Value=0.15; h.BodyHeightScale.Value=0.15; h.BodyWidthScale.Value=0.15; h.HeadScale.Value=0.15
        Notif("Small Body",tgt.Name.." is microscopic 🦟","success")
    else Notif("Small Body","Failed.","error") end
end)

TrollBtn("🌀  Spin Them","Spin the target around",Color3.fromRGB(60,200,255),"Spin",function(tgt)
    local c=tgt.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart")
    if hrp then
        local key="spin_"..tgt.Name
        if NX[key] then NX[key]:Disconnect(); NX[key]=nil; Notif("Spin","Stopped spinning "..tgt.Name..".","info"); return end
        NX[key]=RunService.Heartbeat:Connect(function()
            if not hrp or not hrp.Parent then stopConn(key) return end
            hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(10),0)
        end)
        Notif("Spin","🌀 "..tgt.Name.." is spinning!","success")
    else Notif("Spin","No HRP found.","error") end
end)

TrollBtn("❄  Freeze","Anchor them in place",Color3.fromRGB(60,200,240),"Freeze",function(tgt)
    local c=tgt.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored=not hrp.Anchored
        Notif("Freeze",hrp.Anchored and "❄ "..tgt.Name.." is frozen!" or tgt.Name.." is unfrozen.","warn")
    else Notif("Freeze","No HRP.","error") end
end)

TrollBtn("🏃  Speed Hack","Set their speed to 200",Color3.fromRGB(255,210,40),"SpeedHax",function(tgt)
    local c=tgt.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed=200; Notif("Speed Hack","🏃 "..tgt.Name.." is zooming!","success")
    else Notif("Speed Hack","Failed.","error") end
end)

TrollBtn("👻  Invisible","Make them vanish",Color3.fromRGB(130,130,200),"Vanish",function(tgt)
    local c=tgt.Character
    if c then
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Transparency=1 end end
        Notif("Invisible","👻 "..tgt.Name.." has vanished!","success")
    else Notif("Invisible","Failed.","error") end
end)

TrollBtn("🚀  Rocket","Launch them into orbit",Color3.fromRGB(255,80,40),"Launch",function(tgt)
    local c=tgt.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bv=Instance.new("BodyVelocity",hrp); bv.Velocity=Vector3.new(0,500,0); bv.MaxForce=Vector3.new(0,1e7,0)
        task.delay(0.3,function() if bv.Parent then bv:Destroy() end end)
        Notif("Rocket","🚀 "..tgt.Name.." is in orbit!","success")
    else Notif("Rocket","Failed.","error") end
end)

-- ─────────────────────────────────────────────
--  ═══════════  SETTINGS TAB  ═══════════
-- ─────────────────────────────────────────────
PageHeader(pages["Settings"],"Settings","Lighting, display & resets",Color3.fromRGB(60,200,170))

SectionLabel(pages["Settings"],"💡  Lighting")
ToggleCard(pages["Settings"],"Fullbright","Max ambient light",Color3.fromRGB(255,220,60),
    function()
        Lighting.Brightness=10; Lighting.Ambient=Color3.fromRGB(255,255,255); Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
        Notif("Fullbright","🌟 Max visibility!","success")
    end,
    function()
        Lighting.Brightness=1; Lighting.Ambient=Color3.fromRGB(70,70,70); Lighting.OutdoorAmbient=Color3.fromRGB(140,140,140)
        Notif("Fullbright","Lighting restored.","info")
    end
)

SectionLabel(pages["Settings"],"🛡  Anti-Kick")
ToggleCard(pages["Settings"],"Anti-AFK","Prevent AFK kick",Color3.fromRGB(100,220,100),
    function()
        NX.antiAfk=true
        task.spawn(function()
            while NX.antiAfk do
                local ok,_ = pcall(function() local VU=game:GetService("VirtualUser"); VU:Button1Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end)
                task.wait(55)
            end
        end)
        Notif("Anti-AFK","You won't be kicked! ⏰","success")
    end,
    function() NX.antiAfk=false; Notif("Anti-AFK","Disabled.","warn") end
)

SectionLabel(pages["Settings"],"🔁  Reset")
ButtonCard(pages["Settings"],"Reset Character","Reload your character",Color3.fromRGB(80,200,200),"Reset",function() LP:LoadCharacter(); Notif("Reset","Character reloaded.","info") end)
ButtonCard(pages["Settings"],"Reset All Effects","Undo all active effects",Color3.fromRGB(60,200,170),"Reset All",function()
    -- Kill all NX connections
    for k,v in pairs(NX) do if type(v)=="RBXScriptConnection" then v:Disconnect() end NX[k]=nil end
    local c=LP.Character; local h=c and c:FindFirstChildOfClass("Humanoid"); local hrp=c and c:FindFirstChild("HumanoidRootPart")
    if h then h.WalkSpeed=16; h.JumpPower=50; h.BodyDepthScale.Value=1; h.BodyHeightScale.Value=1; h.BodyWidthScale.Value=1; h.HeadScale.Value=1 end
    if hrp then hrp.Anchored=false; for _,b in ipairs(hrp:GetChildren()) do if b:IsA("BodyMover") then b:Destroy() end end end
    if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Transparency=0; p.CanCollide=true; p.Anchored=false end end end
    Lighting.Brightness=1; Lighting.Ambient=Color3.fromRGB(70,70,70); Lighting.OutdoorAmbient=Color3.fromRGB(140,140,140)
    Notif("Reset All","All effects cleared ✓","success")
end)

-- ─────────────────────────────────────────────
--  WINDOW CONTROLS
-- ─────────────────────────────────────────────
CloseBtn.MouseButton1Click:Connect(function()
    tween(W,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)},.3,"Back","In")
    Notif("Nexus Admin","Menu closed — press RShift to reopen.","info")
    task.delay(.32,function()
        W.Visible=false; W.Size=UDim2.new(0,620,0,450); W.Position=UDim2.new(0.5,-310,0.5,-225)
    end)
end)

local minimized=false
MinBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    if minimized then
        tween(W,{Size=UDim2.new(0,620,0,50)},.25,"Quart","Out")
        MinBtn.Text="□"
    else
        tween(W,{Size=UDim2.new(0,620,0,450)},.3,"Back","Out")
        MinBtn.Text="─"
    end
end)

UserInputService.InputBegan:Connect(function(inp,proc)
    if proc then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then
        W.Visible=not W.Visible
        if W.Visible then
            W.Size=UDim2.new(0,0,0,0); W.Position=UDim2.new(0.5,0,0.5,0)
            tween(W,{Size=UDim2.new(0,620,0,450),Position=UDim2.new(0.5,-310,0.5,-225)},.4,"Back","Out")
            Notif("Nexus Admin","Welcome back, "..LP.Name.."!","success")
        else
            Notif("Nexus Admin","Menu hidden — RShift to show.","info")
        end
    end
end)

-- ─────────────────────────────────────────────
--  ANIMATE LOGO
-- ─────────────────────────────────────────────
task.spawn(function()
    local hue=0
    while true do
        hue=(hue+0.003)%1
        local c=Color3.fromHSV(hue,0.7,1)
        logoG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,c),ColorSequenceKeypoint.new(1,Color3.fromHSV((hue+0.2)%1,0.8,1))}
        task.wait()
    end
end)

-- ─────────────────────────────────────────────
--  OPEN ANIMATION + WELCOME
-- ─────────────────────────────────────────────
W.Size=UDim2.new(0,0,0,0); W.Position=UDim2.new(0.5,0,0.5,0)
tween(W,{Size=UDim2.new(0,620,0,450),Position=UDim2.new(0.5,-310,0.5,-225)},.5,"Back","Out")
task.delay(0.8,function()
    Notif("Welcome, "..LP.Name.."! 👋","Nexus Admin v3.0 loaded successfully!","success")
end)
