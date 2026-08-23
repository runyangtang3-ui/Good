-- [[ Rscripts 风险提示 ]]
-- 此脚本未经 rscripts.net 验证。请谨慎使用。
--
-- 保持安全：
--   • 切勿在非官方 Roblox 网站或相似域名上登录。
--   • 真实的 Roblox 链接使用 roblox.com（请检查 .com 结尾）。
--   • 将伪造的 Roblox 登录/“领取奖励”页面视为钓鱼网站。
-- [[ 结束 Rscripts 风险提示 ]]
-- 加入获取更多免费脚本和执行器 https://discord.gg/daG5BF89GX
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = workspace.CurrentCamera
end)
local LocalPlayer = Players.LocalPlayer

local Settings = {
	Enabled = true,
	FOVRadius = 180,
	ESPEnabled = true,
	ESPMaxDistance = 2000,
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 1
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.NumSides = 64

local EntityService = require(ReplicatedStorage.Remote.EntityService)
local ClientShootableComponent = require(ReplicatedStorage.Client.CombatController.ClientComponent.ClientShootableComponent)

local function GetEntityPosition(EntityModel)
	local TargetPart = EntityModel:FindFirstChild("HumanoidRootPart") or EntityModel:FindFirstChild("Head")
	if TargetPart and TargetPart:IsA("BasePart") then
		return TargetPart, TargetPart.Position
	end
	return nil, nil
end

local function IsInFOV(WorldPosition)
	if not Camera then return false, math.huge end
	local ScreenPos, OnScreen = Camera:WorldToViewportPoint(WorldPosition)
	if not OnScreen then return false, math.huge end
	local MousePos = UserInputService:GetMouseLocation()
	local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
	return Distance <= Settings.FOVRadius, Distance
end

local function GetClosestEnemyInFOV()
	local LocalEntity = EntityService.GetLocalEntity()
	if not LocalEntity or not LocalEntity.World or not LocalEntity.World.EntitiesByTeam then return nil end
	local ClosestTarget = nil
	local ClosestDistance = math.huge
	for _, TeamDict in pairs(LocalEntity.World.EntitiesByTeam) do
		local Items = TeamDict._items or TeamDict
		for _, Entity in pairs(Items) do
			if not EntityService.IsLocalEntity(Entity) and Entity:IsAlive() then
				local Inst = Entity.Instance
				local Character = (Inst and Inst:IsA("Player")) and Inst.Character or Inst
				if Character then
					local Humanoid = Character:FindFirstChildOfClass("Humanoid")
					if Humanoid and Humanoid.Health > 0 then
						local Part, Position = GetEntityPosition(Character)
						if Position then
							local InFOV, Distance = IsInFOV(Position)
							if InFOV and Distance < ClosestDistance then
								ClosestTarget = { Part = Part, Position = Position }
								ClosestDistance = Distance
							end
						end
					end
				end
			end
		end
	end
	return ClosestTarget
end

local SilentTarget = nil

local OrigLocalShoot = ClientShootableComponent.LocalShoot
local OrigOriginFn, OrigTargetFn
for i = 1, 20 do
	local success, val = pcall(debug.getupvalue, OrigLocalShoot, i)
	if success and type(val) == "function" then
		local testSuccess, ret1, ret2, ret3 = pcall(val)
		if testSuccess then
			if typeof(ret1) == "CFrame" and typeof(ret3) == "table" then
				OrigOriginFn = val
			elseif typeof(ret1) == "Vector3" and typeof(ret2) == "Instance" then
				OrigTargetFn = val
			end
		end
	end
end

if OrigOriginFn then
	local OldOriginFn
	OldOriginFn = hookfunction(OrigOriginFn, function(...)
		local cf, pos, meta = OldOriginFn(...)
		if SilentTarget and Settings.Enabled then
			return CFrame.lookAt(cf.Position, SilentTarget.Position), pos, meta
		end
		return cf, pos, meta
	end)
end

if OrigTargetFn then
	local OldTargetFn
	OldTargetFn = hookfunction(OrigTargetFn, function(...)
		if SilentTarget and Settings.Enabled then
			return SilentTarget.Position, SilentTarget.Part
		end
		return OldTargetFn(...)
	end)
end

local OldLocalShoot
OldLocalShoot = hookfunction(ClientShootableComponent.LocalShoot, function(Self, ...)
	if Settings.Enabled then
		SilentTarget = GetClosestEnemyInFOV()
	end
	local Result = OldLocalShoot(Self, ...)
	SilentTarget = nil
	return Result
end)

-- ============================================================
-- ESP
-- ============================================================
local ESPData = {}

local function NewDrawing(kind, props)
	local d = Drawing.new(kind)
	d.Visible = false
	for k, v in pairs(props) do d[k] = v end
	return d
end

local function AddESP(player)
	if player == LocalPlayer or ESPData[player] then return end
	ESPData[player] = {
		Outline = NewDrawing("Square", {Color=Color3.new(0,0,0),          Thickness=3,   Filled=false}),
		Box     = NewDrawing("Square", {Color=Color3.fromRGB(255,50,50),   Thickness=1.5, Filled=false}),
		Name    = NewDrawing("Text",   {Color=Color3.fromRGB(255,255,255), Size=14, Center=true, Outline=true, OutlineColor=Color3.new(0,0,0), Text=player.Name}),
		Dist    = NewDrawing("Text",   {Color=Color3.fromRGB(180,180,180), Size=12, Center=true, Outline=true, OutlineColor=Color3.new(0,0,0)}),
		HpBg    = NewDrawing("Square", {Color=Color3.new(0,0,0),          Thickness=1,   Filled=true}),
		Hp      = NewDrawing("Square", {Color=Color3.fromRGB(50,255,50),   Thickness=1,   Filled=true}),
	}
end

local function DropESP(player)
	if ESPData[player] then
		for _, d in pairs(ESPData[player]) do d:Remove() end
		ESPData[player] = nil
	end
end

local function HideESP(t)
	for _, d in pairs(t) do d.Visible = false end
end

local function UpdateESP()
	if not Settings.ESPEnabled then
		for _, d in pairs(ESPData) do HideESP(d) end
		return
	end
	for player, d in pairs(ESPData) do
		local char = player.Character
		local head = char and char:FindFirstChild("Head")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum  = char and char:FindFirstChildOfClass("Humanoid")
		if not char or not head or not root or not hum or hum.Health <= 0 then
			HideESP(d); continue
		end
		local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local dist = localRoot and (localRoot.Position - root.Position).Magnitude or 0
		if dist > Settings.ESPMaxDistance then HideESP(d); continue end
		local topSP, topVis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, head.Size.Y/2, 0))
		local botSP, botVis = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
		if not topVis and not botVis then HideESP(d); continue end
		local h = math.abs(botSP.Y - topSP.Y)
		local w = h * 0.6
		local x = topSP.X - w/2
		local y = topSP.Y
		d.Outline.Size = Vector2.new(w,h); d.Outline.Position = Vector2.new(x,y); d.Outline.Visible = true
		d.Box.Size     = Vector2.new(w,h); d.Box.Position     = Vector2.new(x,y); d.Box.Visible     = true
		d.Name.Position = Vector2.new(x+w/2, y-16);       d.Name.Visible = true
		d.Dist.Text     = math.floor(dist).."m"
		d.Dist.Position = Vector2.new(x+w/2, y+h+2);      d.Dist.Visible = true
		local hp   = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
		local barX = x - 6
		d.HpBg.Size = Vector2.new(4,h); d.HpBg.Position = Vector2.new(barX,y); d.HpBg.Visible = true
		local fh = h * hp
		d.Hp.Size     = Vector2.new(4, fh)
		d.Hp.Position = Vector2.new(barX, y+(h-fh))
		d.Hp.Color    = Color3.fromRGB(math.floor(255*(1-hp)), math.floor(255*hp), 0)
		d.Hp.Visible  = true
	end
end

for _, p in ipairs(Players:GetPlayers()) do AddESP(p) end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(DropESP)

-- 单个 RenderStepped — FOV 圆圈 + ESP 一起，不阻塞任何输入
RunService.RenderStepped:Connect(function()
	local mousePos = UserInputService:GetMouseLocation()
	FOVCircle.Position = mousePos
	FOVCircle.Radius   = Settings.FOVRadius
	FOVCircle.Visible  = Settings.Enabled
	pcall(UpdateESP)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.F1 then
		Settings.ESPEnabled = not Settings.ESPEnabled
		print("[SA] ESP:", Settings.ESPEnabled)
	elseif input.KeyCode == Enum.KeyCode.F2 then
		Settings.Enabled = not Settings.Enabled
		print("[SA] 静默自瞄:", Settings.Enabled)
	end
end)

print("[Sniper Arena] 已加载 | F1 = ESP | F2 = 静默自瞄")