-- [[ Rscripts 风险提示 ]]
-- 此脚本未经 rscripts.net 验证。请谨慎使用。
--
-- 安全须知：
--   • 切勿在非官方 Roblox 网站或仿冒域名上登录。
--   • 真正的 Roblox 链接使用 roblox.com（请确认 .com 结尾）。
--   • 将伪造的 Roblox 登录/“领取奖励”页面视为钓鱼网站。
-- [[ Rscripts 风险提示结束 ]]

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 预先清理以避免重复
if CoreGui:FindFirstChild("BloxStrikeTacticalHub") then
    CoreGui.BloxStrikeTacticalHub:Destroy()
end

-- 状态变量
getgenv().Config = {
    Aimlock = false,
    HeadAim = false,
    WallCheck = false,
    ESP = false,
    TeamCheck = true,
    HitboxExpander = false,
    HitboxSize = 2
}

-- 主界面（现代原生窗口样式）
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxStrikeTacticalHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ==========================================
-- 浮动按钮
-- ==========================================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 46, 0, 46)
ToggleBtn.Position = UDim2.new(0, 20, 0, 100)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
ToggleBtn.Text = "BS"
ToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

-- 浮动按钮圆角
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleBtn

-- 浮动按钮描边
local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(50, 50, 60)
ToggleStroke.Thickness = 1.5
ToggleStroke.Parent = ToggleBtn

-- ==========================================
-- 主菜单
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 440)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Visible = false
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- 主菜单圆角
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- 主菜单描边
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- 顶部栏
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

-- 标题标签
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BloxStrike 战术中心"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- 浮动按钮点击事件（切换菜单显示/隐藏）
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 滚动页面
local Page = Instance.new("ScrollingFrame")
Page.Size = UDim2.new(1, -20, 1, -55)
Page.Position = UDim2.new(0, 10, 0, 45)
Page.BackgroundTransparency = 1
Page.ScrollBarThickness = 2
Page.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 85)
Page.Parent = MainFrame

-- 列表布局
local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Page

-- ==========================================
-- 开关创建器
-- ==========================================
local function createToggle(text, configKey, defaultState)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = Page
    
    -- 创建圆角
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    -- 创建描边
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 40, 50)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    -- 创建文本标签
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(210, 210, 220)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn

    -- 创建开关背景
    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 36, 0, 20)
    switchBg.Position = UDim2.new(1, -46, 0.5, -10)
    switchBg.BackgroundColor3 = defaultState and Color3.fromRGB(0, 120, 212) or Color3.fromRGB(45, 45, 55)
    switchBg.Parent = btn

    -- 开关背景圆角
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBg

    -- 创建开关滑块
    local switchCircle = Instance.new("Frame")
    switchCircle.Size = UDim2.new(0, 16, 0, 16)
    switchCircle.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    switchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    switchCircle.Parent = switchBg

    -- 滑块圆角
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = switchCircle
    
    local state = defaultState
    
    -- 按钮点击事件
    btn.MouseButton1Click:Connect(function()
        getgenv().Config[configKey] = not getgenv().Config[configKey]
        state = getgenv().Config[configKey]
        
        if state then
            switchBg.BackgroundColor3 = Color3.fromRGB(0, 120, 212)
            switchCircle:TweenPosition(UDim2.new(1, -18, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        else
            switchBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            switchCircle:TweenPosition(UDim2.new(0, 2, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        end
    end)
end

-- 创建各个功能开关
createToggle("大师级自瞄", "Aimlock", false)
createToggle("仅瞄准头部", "HeadAim", false)
createToggle("墙体检测（可见性）", "WallCheck", false)
createToggle("实体透视系统", "ESP", false)
createToggle("队伍检测（纯净）", "TeamCheck", true)
createToggle("命中框扩展", "HitboxExpander", false)

-- ==========================================
-- 命中框大小输入框
-- ==========================================
local BoxContainer = Instance.new("Frame")
BoxContainer.Size = UDim2.new(1, -10, 0, 42)
BoxContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
BoxContainer.Parent = Page

-- 输入框容器圆角
local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = BoxContainer

-- 输入框容器描边
local BoxStroke = Instance.new("UIStroke")
BoxStroke.Color = Color3.fromRGB(40, 40, 50)
BoxStroke.Thickness = 1
BoxStroke.Parent = BoxContainer

-- 输入框标签
local BoxLabel = Instance.new("TextLabel")
BoxLabel.Size = UDim2.new(0.6, 0, 1, 0)
BoxLabel.Position = UDim2.new(0, 12, 0, 0)
BoxLabel.BackgroundTransparency = 1
BoxLabel.Text = "命中框大小（最大4）："
BoxLabel.TextColor3 = Color3.fromRGB(210, 210, 220)
BoxLabel.Font = Enum.Font.GothamMedium
BoxLabel.TextSize = 13
BoxLabel.TextXAlignment = Enum.TextXAlignment.Left
BoxLabel.Parent = BoxContainer

-- 大小输入文本框
local SizeTextBox = Instance.new("TextBox")
SizeTextBox.Size = UDim2.new(0, 45, 0, 26)
SizeTextBox.Position = UDim2.new(1, -55, 0.5, -13)
SizeTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SizeTextBox.Text = "2"
SizeTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeTextBox.Font = Enum.Font.GothamBold
SizeTextBox.TextSize = 13
SizeTextBox.ClearTextOnFocus = false
SizeTextBox.Parent = BoxContainer

-- 文本框圆角
local TextCorner = Instance.new("UICorner")
TextCorner.CornerRadius = UDim.new(0, 4)
TextCorner.Parent = SizeTextBox

-- 文本框失去焦点事件（验证输入值）
SizeTextBox.FocusLost:Connect(function()
    local num = tonumber(SizeTextBox.Text)
    if not num or num < 1 then
        num = 1
    elseif num > 4 then
        num = 4
    end
    SizeTextBox.Text = tostring(num)
    getgenv().Config.HitboxSize = num
end)

-- ==========================================
-- 集成战术引擎
-- ==========================================
local MainLoop = RunService.RenderStepped:Connect(function()
    pcall(function()
        
        -- 判断是否为队友
        local function isAlly(player)
            if not getgenv().Config.TeamCheck then return false end
            if player.Team and LocalPlayer.Team then
                return player.Team == LocalPlayer.Team
            end
            if player:GetAttribute("Team") and LocalPlayer:GetAttribute("Team") then
                return player:GetAttribute("Team") == LocalPlayer:GetAttribute("Team")
            end
            return false
        end

        -- 1. 更稳定、更快速的自瞄
        if getgenv().Config.Aimlock then
            local target = nil
            local shortestDistance = math.huge
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        
                        if not isAlly(player) then
                            local hrp = player.Character.HumanoidRootPart
                            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                            
                            if onScreen then
                                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                                if magnitude < shortestDistance then
                                    shortestDistance = magnitude
                                    target = player.Character
                                end
                            end
                        end
                    end
                end
            end
            
            if target then
                local aimPart = target:FindFirstChild("HumanoidRootPart")
                if getgenv().Config.HeadAim and target:FindFirstChild("Head") then
                    aimPart = target.Head
                end
                
                if aimPart then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPart.Position), 0.85)
                end
            end
        end

        -- 2. 安全的命中框扩展
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                if getgenv().Config.HitboxExpander and not isAlly(player) then
                    local s = getgenv().Config.HitboxSize
                    head.Size = Vector3.new(s, s, s)
                    head.Transparency = 0.5
                    head.CanCollide = false
                else
                    head.Size = Vector3.new(2, 1, 1)
                    head.Transparency = 0
                end
            end
        end

        -- 3. 带白色距离显示的战术透视
        if getgenv().Config.ESP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if not isAlly(player) then
                        if not player.Character:FindFirstChild("TacticalHighlight") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "TacticalHighlight"
                            hl.FillColor = Color3.fromRGB(255, 40, 40)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.Parent = player.Character
                        end
                        
                        local hrp = player.Character.HumanoidRootPart
                        local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
                        
                        local bg = player.Character:FindFirstChild("TacticalDistGui")
                        if not bg then
                            bg = Instance.new("BillboardGui")
                            bg.Name = "TacticalDistGui"
                            bg.Size = UDim2.new(0, 100, 0, 40)
                            bg.StudsOffset = Vector3.new(0, 3, 0)
                            bg.AlwaysOnTop = true
                            bg.Parent = player.Character
                            
                            local txt = Instance.new("TextLabel")
                            txt.Name = "DistText"
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                            txt.TextStrokeTransparency = 0
                            txt.Font = Enum.Font.GothamBold
                            txt.TextSize = 14
                            txt.Parent = bg
                        end
                        
                        local textLabel = bg:FindFirstChild("DistText")
                        if textLabel then
                            textLabel.Text = dist .. "m"
                        end
                        
                    else
                        if player.Character:FindFirstChild("TacticalHighlight") then
                            player.Character.TacticalHighlight:Destroy()
                        end
                        if player.Character:FindFirstChild("TacticalDistGui") then
                            player.Character.TacticalDistGui:Destroy()
                        end
                    end
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    if player.Character:FindFirstChild("TacticalHighlight") then
                        player.Character.TacticalHighlight:Destroy()
                    end
                    if player.Character:FindFirstChild("TacticalDistGui") then
                        player.Character.TacticalDistGui:Destroy()
                    end
                end
            end
        end
        
    end)
end)

-- ==========================================
-- 完全关闭按钮
-- ==========================================
local TerminateBtn = Instance.new("TextButton")
TerminateBtn.Size = UDim2.new(1, -10, 0, 42)
TerminateBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
TerminateBtn.AutoButtonColor = false
TerminateBtn.Text = "终止脚本"
TerminateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TerminateBtn.Font = Enum.Font.GothamBold
TerminateBtn.TextSize = 13
TerminateBtn.Parent = Page

-- 终止按钮圆角
local TermCorner = Instance.new("UICorner")
TermCorner.CornerRadius = UDim.new(0, 6)
TermCorner.Parent = TerminateBtn

-- 终止按钮点击事件（清理并关闭脚本）
TerminateBtn.MouseButton1Click:Connect(function()
    for key, _ in pairs(getgenv().Config) do
        getgenv().Config[key] = false
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            if player.Character:FindFirstChild("TacticalHighlight") then
                player.Character.TacticalHighlight:Destroy()
            end
            if player.Character:FindFirstChild("TacticalDistGui") then
                player.Character.TacticalDistGui:Destroy()
            end
            if player.Character:FindFirstChild("Head") then
                player.Character.Head.Size = Vector3.new(2, 1, 1)
                player.Character.Head.Transparency = 0
            end
        end
    end
    if MainLoop then
        MainLoop:Disconnect()
    end
    ScreenGui:Destroy()
end)