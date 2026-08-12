-- ===================== 服务加载 =====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- ===================== WindUI 加载 =====================
local cloneref = (cloneref or clonereference or function(instance) return instance end)
local ReplicatedStorage_clone = cloneref(ReplicatedStorage)

local WindUI
do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    if ok then
        WindUI = result
    else
        if cloneref(RunService):IsStudio() then
            WindUI = require(cloneref(ReplicatedStorage_clone:WaitForChild("WindUI"):WaitForChild("Init")))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

-- ===================== 创建 WindUI 窗口 =====================
local Window = WindUI:CreateWindow({
    Title = "GOC 私人脚本",
    Folder = "GOC_Hub",
    Icon = "crown",
    NewElements = true,
    HideSearchBar = true,
    OpenButton = {
        Title = "🔱 GOC",
        CornerRadius = UDim.new(0, 12),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 1.0,
        Size = UDim2.new(0, 180, 0, 60),
        Color = ColorSequence.new(Color3.fromHex("#FFD700"), Color3.fromHex("#FF6B00")),
    },
    Topbar = {
        Height = 48,
        ButtonsType = "Mac",
    },
})

-- ===================== 颜色常量 =====================
local Gold = Color3.fromHex("#FFD700")
local Orange = Color3.fromHex("#FF8C00")
local Green = Color3.fromHex("#00E676")
local Red = Color3.fromHex("#FF3D3D")
local Purple = Color3.fromHex("#B388FF")
local Blue = Color3.fromHex("#448AFF")

-- ===================== 🏠 首页标签页 =====================
local HomeTab = Window:Tab({
    Title = "🏠 首页",
    Desc = "GOC 私人脚本中心",
    Icon = "home",
    IconColor = Gold,
    IconShape = "Square",
})

local HomeSection = HomeTab:Section({Title = "欢迎使用"})
HomeSection:Space({Columns = 1})
HomeSection:Section({Title = "⚜️ GOC 私人脚本 ⚜️", TextSize = 28, FontWeight = Enum.FontWeight.Bold})
HomeSection:Space()
HomeSection:Section({Title = "━━━━━━━━━━━━━━━━━━━━━━━━", TextSize = 12, TextTransparency = 0.5})
HomeSection:Space()
HomeSection:Section({Title = "🔰 功能导航", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold})
HomeSection:Space()
HomeSection:Button({
    Title = "💰 自动刷钱控制",
    Description = "点击前往刷钱控制面板",
    Color = Green,
    Icon = "dollar-sign",
    Justify = "Left",
    Callback = function() print("[GOC] 请切换到'刷钱控制'标签页") end,
})
HomeSection:Space()
HomeSection:Button({
    Title = "🎵 音乐播放器",
    Description = "点击前往内置音乐库",
    Color = Purple,
    Icon = "music",
    Justify = "Left",
    Callback = function() print("[GOC] 请切换到'音乐播放器'标签页") end,
})
HomeSection:Space()
HomeSection:Section({Title = "━━━━━━━━━━━━━━━━━━━━━━━━", TextSize = 12, TextTransparency = 0.5})
HomeSection:Space()
HomeSection:Section({Title = "📋 脚本信息", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold})
HomeSection:Space()
HomeSection:Section({
    Title = "🧑‍💻 作者：GOC\n📅 版本：v2.0.0\n🕹️ 类型：自动农场 + 音乐播放\n💎 专属私人脚本\n\n⚠️ 请勿外传，仅供个人使用",
    TextSize = 14,
    TextTransparency = 0.3,
})
HomeSection:Space()
HomeSection:Section({Title = "━━━━━━━━━━━━━━━━━━━━━━━━", TextSize = 12, TextTransparency = 0.5})
HomeSection:Space()
HomeSection:Section({Title = "🌟 状态总览", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold})
HomeSection:Space()
local HomeStatusText = HomeSection:Section({
    Title = "自动刷钱：⚫ 未启动\n音乐播放：🎵 无",
    TextSize = 14,
    TextTransparency = 0.25,
})
HomeSection:Space()
HomeSection:Section({Title = "🔱 GOC Private Script © 2024 🔱", TextSize = 11, TextTransparency = 0.5})-- ===================== 💰 刷钱控制标签页（无车辆版） =====================
local FarmTab = Window:Tab({
    Title = "💰 刷钱控制",
    Desc = "自动农场循环脚本",
    Icon = "play",
    IconColor = Green,
    IconShape = "Square",
})

local FarmSection = FarmTab:Section({Title = "⚙️ 刷钱脚本"})
FarmSection:Section({Title = "点击下方按钮，直接开始无限循环刷钱", TextSize = 14, FontWeight = Enum.FontWeight.Medium})
FarmSection:Space()

FarmSection:Button({
    Title = "🔥 开始刷钱（无限循环）",
    Description = "点击后执行刷钱脚本，不会停止",
    Color = Green,
    Justify = "Center",
    Callback = function()
        task.spawn(function()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local pos1 = Vector3.new(6823.82, 17.58, 33.67)
            local pos2 = Vector3.new(6822.64, 17.63, 19.72)
            local pos3 = Vector3.new(6859.28, 17.58, -17.58)
            local pos4 = Vector3.new(6886.41, 17.38, 113.27)
            local pos4b = Vector3.new(39.27, 17.38, 137.08)
            local pos5 = Vector3.new(205.58, 17.40, -45.70)
            local pos6 = Vector3.new(64.16, 17.38, 101.49)
            local pos7 = Vector3.new(5064.40, 17.38, 149.43)
            local pos8 = Vector3.new(6883.75, 17.38, 126.79)
            local pos9 = Vector3.new(6810.84, 17.60, -36.79)

            local avacados = Workspace:WaitForChild("WorldBuyableItems"):WaitForChild("Crate Of Avacados")
            local diamondRing = Workspace:WaitForChild("WorldBuyableItems"):WaitForChild("Fake Diamond Ring")

            local buyRemote = ReplicatedStorage:WaitForChild("__remotes")
                :WaitForChild("WorldBuyableItemService")
                :WaitForChild("PurchaseWorldBuyableItem")

            local function noclip()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide == true then
                        v.CanCollide = false
                    end
                end
            end

            local function smoothMove(targetPos, speed)
                speed = speed or 4
                local startPos = hrp.Position
                local distance = (targetPos - startPos).Magnitude
                local steps = math.floor(distance / speed)
                steps = math.max(steps, 10)
                for i = 1, steps do
                    local t = i / steps
                    hrp.CFrame = CFrame.new(startPos:Lerp(targetPos, t))
                    task.wait(0.02)
                end
                hrp.CFrame = CFrame.new(targetPos)
            end

            local function teleport(pos)
                hrp.CFrame = CFrame.new(pos)
            end

            -- 售货（停留5秒）
            local function sellItems()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.Parent and v.Parent.Name:lower():find("sell") then
                        fireproximityprompt(v)
                        print("已触发售货，停留5秒...")
                        task.wait(5)
                        print("售货完成")
                        return
                    end
                end
                print("未找到售货点，停留5秒")
                task.wait(5)
            end

            -- 洗钱（停留4秒）
            local function interactWash()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") then
                        local dist = (v.Parent.Position - hrp.Position).Magnitude
                        if dist < 20 then
                            fireproximityprompt(v)
                            print("已触发洗钱: " .. v.Parent.Name .. "，停留4秒...")
                            task.wait(4)
                            print("洗钱完成")
                            return
                        end
                    end
                end
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("ClickDetector") then
                        local dist = (v.Parent.Position - hrp.Position).Magnitude
                        if dist < 20 then
                            fireclickdetector(v)
                            print("已触发洗钱: " .. v.Parent.Name .. "，停留4秒...")
                            task.wait(4)
                            print("洗钱完成")
                            return
                        end
                    end
                end
                print("未找到洗钱点，停留4秒")
                task.wait(4)
            end

            -- 主循环
            while true do
                char = player.Character or player.CharacterAdded:Wait()
                hrp = char:WaitForChild("HumanoidRootPart")

                -- 1. 买牛油果
                teleport(pos1)
                task.wait(0.5)
                buyRemote:FireServer(avacados)
                print("牛油果购买完成")

                -- 2. 买5次假钻戒
                teleport(pos2)
                task.wait(0.5)
                for i = 1, 5 do
                    buyRemote:FireServer(diamondRing)
                    task.wait(0.3)
                    print("假钻戒第" .. i .. "次购买完成")
                end

                -- 3. 瞬移到pos3（无车辆）
                teleport(pos3)
                task.wait(0.3)
                print("已传送到pos3")

                -- 4. 瞬移到pos4
                teleport(pos4)
                print("已传送到pos4")

                -- 5. 穿墙，平滑移动 pos4 -> pos4b -> pos5
                noclip()
                task.wait(0.2)
                smoothMove(pos4b, 4)
                print("移动到pos4b")
                smoothMove(pos5, 4)
                print("移动到pos5")

                -- 6. 售货（停留5秒）
                task.wait(0.5)
                sellItems()

                -- 7. 平滑移动 pos5 -> pos6 -> pos7 -> pos8 -> pos9
                smoothMove(pos6, 4)
                print("移动到pos6")
                smoothMove(pos7, 4)
                print("移动到pos7")
                smoothMove(pos8, 4)
                print("移动到pos8")
                smoothMove(pos9, 4)
                print("移动到pos9")

                -- 8. 洗钱（停留4秒）
                task.wait(0.5)
                interactWash()

                print("======== 本轮完成，开始新一轮 ========")
                task.wait(1)
            end
        end)
    end,
})-- ===================== 🎵 音乐播放器标签页 =====================
local MusicTab = Window:Tab({
    Title = "🎵 音乐",
    Desc = "内置音乐库",
    Icon = "music",
    IconColor = Purple,
    IconShape = "Square",
})

local MusicControl = MusicTab:Section({Title = "🎧 音乐控制"})

local currentSound = nil

local function stopMusic()
    if currentSound then
        currentSound:Stop()
        currentSound:Destroy()
        currentSound = nil
    end
end

local function playMusic(id, name)
    stopMusic()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(id)
    sound.Volume = 1
    sound.Parent = SoundService
    sound:Play()
    currentSound = sound
    sound.Ended:Connect(function()
        if currentSound == sound then
            currentSound = nil
        end
    end)
    print("正在播放: " .. name)
end

local function togglePause()
    if currentSound then
        if currentSound.IsPaused then
            currentSound:Resume()
            print("继续播放")
        else
            currentSound:Pause()
            print("暂停播放")
        end
    else
        print("当前无音乐播放")
    end
end

MusicControl:Button({
    Title = "⏯️ 暂停 / 继续",
    Description = "控制当前音乐播放/暂停",
    Color = Orange,
    Callback = togglePause,
})

MusicControl:Button({
    Title = "⏹️ 停止播放",
    Description = "停止当前音乐",
    Color = Red,
    Callback = stopMusic,
})

MusicControl:Space()

-- ==================== 歌曲列表 ====================
local MusicListSection = MusicTab:Section({Title = "📜 歌曲列表（可滚动）"})

local musicLibrary = {
    {id = 74173898692517, name = "唐人"},
    {id = 82736875196779, name = "牵丝戏"},
    {id = 75361870687357, name = "辞九门"},
    {id = 132524361907107, name = "把回忆"},
    {id = 102072818475050, name = "李昊"},
    {id = 79277371759525, name = "雨爱"},
    {id = 78963341533467, name = "雨泪"},
    {id = 88304207692432, name = "武家坡"},
    {id = 103206233912047, name = "你好，知道犯什么"},
    {id = 109693244185458, name = "1Q00"},
    {id = 114372452919028, name = "山楂树"},
    {id = 89795630567186, name = "陈浩南"},
    {id = 100856301638837, name = "落泪"},
    {id = 117225633780122, name = "海底"},
    {id = 110803009828636, name = "张信哲"},
    {id = 83422989427201, name = "错位时空"},
    {id = 111568038897020, name = "求佛"},
    {id = 80487039269735, name = "悠闲"},
    {id = 124044109756641, name = "精卫"},
    {id = 111027647468458, name = "迷人的危险"},
    {id = 120145064597801, name = "安和桥"},
    {id = 78626388620444, name = "做事要讲良心"},
    {id = 126922220277198, name = "redeye"},
    {id = 118896961448948, name = "后继者"},
    {id = 107341259483191, name = "lovestory"},
    {id = 96590819329722, name = "会呼吸的痛"},
    {id = 125615482496831, name = "青衣"},
    {id = 114476517052805, name = "铡美案"},
    {id = 138765729162919, name = "蜜雪"},
    {id = 128967751535556, name = "nig"},
    {id = 84348087757554, name = "嘉豪"},
    {id = 113879832755091, name = "大运"},
    {id = 113665010217108, name = "鸟之诗"},
    {id = 78707318606182, name = "大江大海"},
    {id = 79122285852432, name = "朋友的酒"},
    {id = 81381619096029, name = "小幸运"},
    {id = 116497979556639, name = "不得不爱"},
    {id = 112341295870756, name = "印度"},
    {id = 117642670292492, name = "我也不知道"},
    {id = 104923055259541, name = "你最近过的还好吗"},
    {id = 118957335322667, name = "共和时代"},
    {id = 135894830596180, name = "alone"},
    {id = 102757438805863, name = "骷髅"},
    {id = 113529393452088, name = "嘉豪"},
    {id = 2138529498012691, name = "豪大大"},
    {id = 119341948158777, name = "芒种"},
    {id = 110094177703357, name = "演员"},
    {id = 106036175444448, name = "红昭愿"},
    {id = 129089071772937, name = "桃花诺"},
    {id = 97285892199649, name = "把回忆"},
    {id = 81179274770282, name = "燕无歇"},
    {id = 93310151880263, name = "出山"},
    {id = 112834898401032, name = "离开我的依赖"},
    {id = 121374695318782, name = "彩虹小白马好像不能用了"},
    {id = 93898237895661, name = "得吃"},
    {id = 96144381780240, name = "拼好歌"},
    {id = 99498025749186, name = "起风了"},
    {id = 115023114157591, name = "辞九门"},
    {id = 132049153370517, name = "应该是莫问归期"},
    {id = 82518513365412, name = "川普"},
    {id = 1845918435, name = "国歌"},
    {id = 1840297174, name = "國歌"},
    {id = 124597524602869, name = "进步"},
    {id = 132772094469180, name = "游京"},
    {id = 103001052289903, name = "伤感"},
    {id = 3068736836, name = "教員"},
    {id = 121336636707861, name = "豪庭"},
    {id = 115262512648819, name = "漂移"},
    {id = 99519218846428, name = "科比"},
    {id = 130437050908450, name = "氛围"},
    {id = 138570939058838, name = "唯一"},
    {id = 134786908423441, name = "大东北"},
    {id = 124523430035974, name = "山歌"},
    {id = 5409360995, name = "新新"},
    {id = 3033155249, name = "悠闲"},
    {id = 135324082524426, name = "兰亭序"},
    {id = 126954452322127, name = "军中绿花"},
    {id = 89711807693889, name = "进击巨人"},
    {id = 91550314012338, name = "奈克赛斯主题曲"},
    {id = 93995930463751, name = "瞬DJ"},
    {id = 82485901858938, name = "小半原版"},
    {id = 79952652433579, name = "父亲"},
    {id = 99498025749186, name = "起风了di"},
    {id = 112834898401032, name = "离开我的依赖DJ"},
    {id = 79277371759525, name = "代码雨爱"},
    {id = 138570939058838, name = "唯一"},
    {id = 74180922359181, name = "啊米诺丝"},
    {id = 136536224579450, name = "冲刺"},
    {id = 80701295792893, name = "乌鲁鲁"},
    {id = 131309848078328, name = "buibuibui"},
    {id = 104923055259541, name = "还好吗"},
    {id = 99960601736776, name = "鸳鸯戏+1280"},
    {id = 98850529016454, name = "坠落"},
    {id = 87859225614251, name = "瓦瓦"},
    {id = 121832229737638, name = "猪妞"},
    {id = 124597524602869, name = "进步小曲"},
    {id = 95489036869789, name = "馕馕馕"},
    {id = 96590819329722, name = "会呼吸的痛"},
    {id = 110094177703357, name = "演员"},
    {id = 88457346646245, name = "福瑞"},
    {id = 134786908423441, name = "大东北"},
    {id = 132049153370517, name = "凌烈的刀锋出寒冬"},
    {id = 93898237895661, name = "得吃"},
    {id = 78626388620444, name = "讲良心"},
    {id = 102862957328067, name = "拜刀马"},
    {id = 100856301638837, name = "猜不透"},
    {id = 124384558101360, name = "辞九门回忆"},
    {id = 82152175089703, name = "单吃蛋"},
    {id = 132913406368504, name = "酒驾驾"},
    {id = 122569721737706, name = "哈喽大家好"},
    {id = 111431923179857, name = "我拿那个小刀"},
    {id = 132218995427356, name = "浴室"},
    {id = 109693244185458, name = "1Q00进行曲"},
    {id = 7418628592, name = "cnm"},
    {id = 132772094469180, name = "游京"},
    {id = 122407020110484, name = "爱情讯息DJ"},
    {id = 133260572775867, name = "萝莉进行曲炸麦"},
    {id = 78963341533467, name = "落泪"},
    {id = 124384558101360, name = "误闯天家DJ版"},
    {id = 111647270157086, name = "中长跑进行曲"},
    {id = 139960831487271, name = "晚安布布进行曲"},
    {id = 72230346939164, name = "库里之歌（柚子厨版）"},
    {id = 140648740956700, name = "苦茶子"},
    {id = 128815249670543, name = "大哥小曲哈基米版"},
    {id = 109138957141221, name = "情绪回收站FUNK"},
    {id = 117642670292492, name = "哈基米哦南北绿豆"},
    {id = 87918578744719, name = "大悲咒哈基米"},
    {id = 96491894597654, name = "灵感菇菇菇嘎嘎"},
    {id = 110019502835548, name = "donk哈基米"},
    {id = 7847207

-- 逐个创建按钮
for _, song in ipairs(musicLibrary) do
    MusicListSection:Button({
        Title = song.name,
        Description = "ID: " .. tostring(song.id),
        Color = Purple,
        Justify = "Left",
        Callback = function()
            playMusic(song.id, song.name)
        end,
    })
end
```
