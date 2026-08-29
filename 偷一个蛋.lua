-- [[ Rscripts 风险提示 ]]
-- 本脚本未经过 rscripts.net 验证，请谨慎使用。
--
-- 安全提醒：
--   • 切勿在非官方 Roblox 网站或仿冒域名上登录。
--   • 真正的 Roblox 链接使用 roblox.com（注意 .com 结尾）。
--   • 将虚假的 Roblox 登录 / “领取奖励” 页面视为钓鱼行为。
-- [[ Rscripts 风险提示结束 ]]
-- ScriptVerse Solara 兼容（自动）
do
	local g = (getgenv and getgenv()) or _G
	local C = rawget(g, "SVCompat")
	if type(C) ~= "table" or not C.__svcompat then
	local function executorName()
	local ok, n = pcall(function()
		return (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or ""
	end)
	return (ok and tostring(n) or ""):lower()
end
local exec = executorName()
local isSolara = exec:find("solara", 1, true) ~= nil
	or exec:find("xeno", 1, true) ~= nil
	or exec:find("micro", 1, true) ~= nil
local realRequire = require
C = {
	__svcompat = true,
	Executor = exec,
	IsSolara = isSolara,
	AllowRequire = true,
	AllowHooks = (not isSolara) and typeof(hookmetamethod) == "function",
	AllowGc = typeof(getgc) == "function",
	AllowDrawing = typeof(Drawing) == "table" and typeof(Drawing.new) == "function",
	rawRequire = realRequire,
}
function C.softRequire(mod)
	if mod == nil then return nil end
	-- 始终优先尝试真实 require（Flamework 中心需要它）。
	-- 仅在引擎报错后判断 Solara 缺陷。
		local ok, res = pcall(realRequire, mod)
	if ok then return res end
	local err = string.lower(tostring(res))
	if err:find("cannot require", 1, true)
		or err:find("cast string to bool", 1, true)
		or err:find("unable to cast", 1, true)
	then
		C.IsSolara = true
		C.AllowRequire = false
	end
	return nil
end
C.require = C.softRequire
C.rawRequire = realRequire
		function C.child(parent, ...)
			local cur = parent
			for i = 1, select("#", ...) do
				if typeof(cur) ~= "Instance" then return nil end
				cur = cur:FindFirstChild((select(i, ...)))
			end
			return cur
		end
		function C.softDrawing(class)
			if not C.AllowDrawing then return nil end
			local ok, obj = pcall(Drawing.new, class)
			return ok and obj or nil
		end
		function C.canHook() return C.AllowHooks == true end
		function C.canGc() return C.AllowGc == true end
		g.SVCompat = C
	end
end
local require = (function()
	local g = (getgenv and getgenv()) or _G
	local C = rawget(g, "SVCompat")
	if type(C) == "table" and type(C.require) == "function" then
		return C.require
	end
	return require
end)()

--[[
  ScriptVerse - 偷蛋
  场所ID: 107778070777162

  自动农场 - 步行偷取，返回地块，鸡蛋/宠物/基地自动化。
  客户端 AC：在移动前冻结检测表（filtergc / gmatch+GetFullName）。
]]
local PLACE_ID = 107778070777162
local genv = (getgenv and getgenv()) or _G

if type(genv.SV_SAE_SHUTDOWN) == "function" then
	pcall(genv.SV_SAE_SHUTDOWN)
	task.wait(0.1)
end
if genv.SV_SAE_RUNNING then
	return
end
genv.SV_SAE_RUNNING = true
print("[ScriptVerse] 偷蛋 - 加载中...")
-- 客户端检测绕过（偷蛋 / 养鸡斗士） - 感谢 Killa
local function bypassClientDetections()
	if typeof(filtergc) ~= "function" or typeof(debug) ~= "table" or typeof(debug.getupvalues) ~= "function" then
		return false, "没有 filtergc"
	end
	local ok, fn = pcall(function()
		return filtergc("function", {
			Constants = { "gmatch", "GetFullName" },
		}, true)
	end)
	if not ok or type(fn) ~= "function" then
		return false, "filter 未命中"
	end
	local setMeta = (typeof(setrawmetatable) == "function" and setrawmetatable)
		or (typeof(setmetatable) == "function" and setmetatable)
	if not setMeta then
		return false, "没有 setmeta"
	end
		local blocked = 0
	local okUv, ups = pcall(debug.getupvalues, fn)
	if not okUv or type(ups) ~= "table" then
		return false, "没有 upvalues"
	end
	for _, tbl in pairs(ups) do
		if typeof(tbl) == "table" then
			local okSet = pcall(setMeta, tbl, {
				__newindex = function() end,
			})
			if okSet then
				blocked += 1
			end
		end
	end
	return blocked > 0, blocked
end

local acOk, acInfo = bypassClientDetections()
if acOk then
	print("[ScriptVerse] 客户端 AC 已绕过（" .. tostring(acInfo) .. " 个表）")
else
	warn("[ScriptVerse] 客户端 AC 绕过跳过：" .. tostring(acInfo))
end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local HAS_DRAWING = typeof(Drawing) == "table" or typeof(Drawing) == "userdata"

-- UI 只存在于 PlayerGui 中。偷取 = 行走 + 近距离提示。
local function pinUiToPlayerGui()
	return LocalPlayer:WaitForChild("PlayerGui")
end

local SVUI = genv.SVUI or _G.SVUI
if not SVUI then
	pinUiToPlayerGui()
	local ok, lib = pcall(function()
		return loadstring(game:HttpGet("https://scriptversekey.xyz/svui.lua"))()
	end)
	if ok then
		SVUI = lib
	end
end
if not SVUI then
	warn("[ScriptVerse] SVUI 加载失败")
	genv.SV_SAE_RUNNING = nil
	return
end
local Accent = Color3.fromRGB(120, 220, 160)
local OkGreen = Color3.fromRGB(120, 220, 140)
local WarnOrange = Color3.fromRGB(255, 140, 80)

local function softRequire(inst)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	local ok, mod = pcall(require, inst)
	return ok and mod or nil
end

local Lib = ReplicatedStorage:WaitForChild("Library", 30)
local Client = Lib:WaitForChild("Client", 15)
local Util = Lib:WaitForChild("Util", 15)
local Globals = Lib:WaitForChild("Globals", 15)
local EggCmds = softRequire(Client:WaitForChild("EggCmds", 15))
local PlotCmds = softRequire(Client:WaitForChild("PlotCmds", 15))
local Network = softRequire(Client:WaitForChild("Network", 15))
local Guard = softRequire(Client:WaitForChild("ToolGameplayGuard", 15))
local Lookup = softRequire(Util:WaitForChild("GuardAreaLookupUtil", 15))
local Save = softRequire(Client:WaitForChild("Save", 15))
local BaseUpgrade = softRequire(Client:WaitForChild("BaseUpgradeClient", 15))
local AssetCmds = softRequire(Client:WaitForChild("AssetCmds", 15))
local Constants = softRequire(Globals:WaitForChild("Constants", 15))
local SpeedPowerProjection = softRequire(Client:FindFirstChild("SpeedPowerProjection"))
local TreadmillUtil = softRequire(Util:FindFirstChild("TreadmillUtil"))

if not EggCmds or not PlotCmds or not Guard or not Lookup then
	warn("[ScriptVerse] 偷蛋模块不可用")
	genv.SV_SAE_RUNNING = nil
	return
end
local NetMap = (Constants and Constants.NETWORK_MAP) or (Network and Network.NET_MAP)
local PivotKey = (NetMap and NetMap.ClientCharacter and NetMap.ClientCharacter.SET_PIVOT)
	or "ClientCharacter: SetPivot"
local ImpulseKey = (NetMap and NetMap.ClientCharacter and NetMap.ClientCharacter.BEGIN_IMPULSE)
	or "ClientCharacter: BeginImpulse"

local SeparationLine = nil
local cachedPlayPos, cachedSafePos

local function getSeparationLine()
	if SeparationLine and SeparationLine.Parent then
		return SeparationLine
	end
	local objs = Workspace:FindFirstChild("__OBJECTS") or Workspace:WaitForChild("__OBJECTS", 20)
	if not objs then
		return nil
	end
	local areas = objs:FindFirstChild("Areas")
	if not areas then
		return nil
	end
	SeparationLine = areas:FindFirstChild("SeparationLine")
	return SeparationLine
end
local function netInvoke(key, ...)
	if not Network or not key then
		return false
	end
	local args = table.pack(...)
	local ok, a = pcall(function()
		return Network.Invoke(key, table.unpack(args, 1, args.n))
	end)
	return ok and a == true
end

local function netFire(key, ...)
	if not Network or not key then
		return
	end
	local args = table.pack(...)
	pcall(function()
		Network.Fire(key, table.unpack(args, 1, args.n))
	end)
end

local conns = {}
local espPool = {}
local flyConn, noclipConn, infJumpConn
local State = {
	running = true,
	busy = false,
	busySince = nil,
	status = "空闲中",

	carrying = false,

	instantSteal = false,
	autofarm = false,
	preferHighValue = true,
	autoReturn = true,
	autoDrop = false,
	serverHop = false,
	hopTarget = "",
	allAreas = true,
	areaCursor = 1,

	autoSellEggs = false,
	autoPlace = false,
	autoHatch = false,
	autoEquipBest = false,
	autoFuse = false,
	autoSellPets = false,
	neverSellMutated = true,
	neverSellEquipped = true,
	claimOffline = false,
autoUpgrade = false,
autoTreadmill = false,
autoClaimIndex = false,
autoGroupReward = false,
autoBuyTrail = false,
autoEquipTrail = false,
autoEquipGear = false,

espWorldEgg = false,
espCarriedEgg = false,
espGuard = false,
espPet = false,
espPlayer = false,
espMachine = false,
espPlot = false,

speedOn = false,
walkSpeed = 32,
jumpOn = false,
jumpPower = 80,
infJump = false,
noclip = false,
fly = false,
flySpeed = 32,
antiAfk = true,
	travelSpeed = 16,
	lastSteal = 0,
	lastPlace = 0,
	lastHatch = 0,
	lastSell = 0,
	lastEquip = 0,
	lastUpgrade = 0,
	lastOffline = 0,
	lastIndex = 0,
	lastGroup = 0,
	lastTrail = 0,
	lastTreadmill = 0,
	lastFuse = 0,
	lastHop = 0,
	lastAfk = 0,
}

local function notify(title, content, color, dur)
	pcall(function()
		SVUI:Notify({
			Title = title,
			Content = content,
			Duration = dur or 2.2,
			Color = color or Accent,
		})
	end)
end
local function track(conn)
	table.insert(conns, conn)
	return conn
end

if EggCmds and EggCmds.AreaEggCarryStateChanged and type(EggCmds.AreaEggCarryStateChanged.Connect) == "function" then
	track(EggCmds.AreaEggCarryStateChanged:Connect(function(payload)
		if payload and payload.IsCarrying == true then
			State.carrying = true
		elseif payload and payload.IsCarrying == false then
			State.carrying = false
		end
	end))
end

local function root()
	local char = LocalPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function hum()
	local char = LocalPlayer.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end
local function zeroVel(part)
	if not part then
		return
	end
	part.AssemblyLinearVelocity = Vector3.zero
	part.AssemblyAngularVelocity = Vector3.zero
end

local function waitRoot(timeout)
	timeout = timeout or 15
	local char = LocalPlayer.Character
	if not char then
		char = LocalPlayer.CharacterAdded:Wait()
	end
	return char:WaitForChild("HumanoidRootPart", timeout)
end

local AssetsDirectory = nil
pcall(function()
	local Assets = require(ReplicatedStorage.Directory.Assets)
	AssetsDirectory = Assets and Assets.Directory
end)
local function burstPivot(cf, fires)
	local r = root()
	if not r or not cf then
		return
	end
	fires = fires or 2
	for _ = 1, fires do
		if Network and PivotKey then
			pcall(function()
				Network.Fire(PivotKey, cf)
			end)
		end
		r.CFrame = cf
		zeroVel(r)
		task.wait(0.014)
	end
end

local function smoothPath(goal, steps, firesPerStep)
	local r = root()
	if not r or not goal then
		return false
	end
	steps = steps or 16
	firesPerStep = firesPerStep or 2
	local from = r.Position
	for i = 1, steps do
		if not State.running then
			return false
		end
		r = root()
		if not r then
			return false
		end
		local p = from:Lerp(goal, i / steps)
		burstPivot(CFrame.new(p.X, math.max(p.Y, r.Position.Y), p.Z), firesPerStep)
	end
	return true
end
local function pivotTo(cf)
	burstPivot(cf, 3)
end

local function pivotPath(goal, steps)
	return smoothPath(goal, steps or 16, 2)
end

local function fastTp(cf)
	burstPivot(cf, 3)
	return true
end

local function lerpTp(from, to, steps)
	if typeof(to) == "Vector3" then
		return smoothPath(to, steps or 16, 2)
	end
	return smoothPath(to.Position, steps or 16, 2)
end

local function fastPath(goal, steps)
	local r = root()
	if not r or not goal then
		return false
	end
	steps = steps or 16
	local from = r.Position
	for i = 1, steps do
		if not State.running then
			return false
		end
		r = root()
		if not r then
			return false
		end
		local p = from:Lerp(goal, i / steps)
		local cf = CFrame.new(p.X, math.max(p.Y, r.Position.Y), p.Z)
		if Network and PivotKey then
			pcall(function()
				Network.Fire(PivotKey, cf)
			end)
		end
		r.CFrame = cf
		zeroVel(r)
		task.wait(0.009)
	end
	return true
end
local function travelTo(goal)
	local r = root()
	if not r then
		return false
	end
	if (r.Position - goal).Magnitude > 8 then
		smoothPath(goal, 18, 2)
	end
	burstPivot(CFrame.new(goal), 2)
	return true
end

local function inGameplay()
	if type(Guard.IsLocalPlayerInGameplayArea) == "function" then
		return Guard.IsLocalPlayerInGameplayArea() == true
	end
	return false
end

local function onGameplaySide(pos)
	local line = getSeparationLine()
	if not line or not pos then
		return false
	end
	if type(Lookup.IsInGameplaySide) == "function" then
		return Lookup.IsInGameplaySide(line, pos) == true
	end
	local rel = line.CFrame:PointToObjectSpace(pos)
	return rel.Z > 0
end
local function resolveArenaPoints()
	-- ... 略（已经长） 
end

local function walkRunTo(goal, speed, timeout) ... end
local function freezeSpeedPower() ... end
local function applySpeed() ... end
local function eggValue(rec) ... end
local function getAreaEggSnapshot() ... end
local function listGameplayEggs(filterName) ... end
local function crossToArena() ... end
local function findEggPrompt(uid, pos) ... end
local function holdProximityPrompt(prompt) ... end
local function eggIsCarried(uid) ... end
local function waitUntilCarrying(uid, timeout) ... end
local function pickNearestEgg() ... end
local function requestCarry(uid, rec) ... end
local function goNear(pos) ... end
local function grabEgg(rec) ... end
local function fleeToPlot() ... end
local function returnHomeAndClaim() ... end
local function walkTo(goal) ... end
local function ensureGameplay() ... end
local function goHome() ... end
local function stealOneCycle() ... end
local function tryCarryEgg(target) ... end
local function autofarmCycle() ... end
genv.SV_SAE_STEAL = stealOneCycle
local function doStealOnce() ... end
local function getPlotPlaceCFrame() ... end
local function placeInventoryEggs() ... end
local function hatchReadyEggs() ... end
local function petHasMutation(item) ... end
local function tryEquipBest() ... end
local function trySellPets() ... end
local function tryFuse() ... end
local function tryOffline() ... end
local function tryUpgrade() ... end
local function tryIndex() ... end
local function tryGroupReward() ... end
local function tryTrails() ... end
local function tryTreadmill() ... end
local function trySellEggs() ... end
local function farmTick() ... end
-- ESP 函数
local function clearEsp() ... end
local function addHighlight(inst, color, label) ... end
local function refreshEsp() ... end

-- 移动辅助
local function setNoclip(on) ... end
local function setFly(on) ... end
local function setInfJump(on) ... end

-- UI (PlayerGui only)
pinUiToPlayerGui()
task.wait(0.15)

local Window = SVUI:CreateWindow({
	Title = "偷蛋",
	Subtitle = "ScriptVerse",
})
-- ... 创建标签、开关、滑块等

-- 循环
track(LocalPlayer.CharacterAdded:Connect(...))
track(RunService.Heartbeat:Connect(...))
track(task.spawn(function() ... end))

genv.SV_SAE_SHUTDOWN = function()
	State.running = false
	-- ... 清理
end

notify("偷蛋", "角色 + ESP", OkGreen, 3)