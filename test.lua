-- [[ WISNU HUB | OXIDELIB UI & BACKEND FIXED ]] --

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"))()
Library:SetTheme("OLED")

local Window = Library:CreateWindow({
    Name = "WISNU HUB",
    BrandSubtitle = "evomon v3",
    Logo = "rbxassetid://75991977420487",
    LogoZoom = 1.5,
    Size = UDim2.fromOffset(720, 500)
})

-- Watermark Transparency
task.spawn(function()
    task.wait(0.5)
    if Window.Watermark then Window.Watermark.ImageTransparency = 0.4 end
end)

local Svc = {
    Players  = game:GetService("Players"),
    Run      = game:GetService("RunService"),
    UIS      = game:GetService("UserInputService"),
    VIM      = game:GetService("VirtualInputManager"),
    Http     = game:GetService("HttpService"),
    Teleport = game:GetService("TeleportService"),
}

local plr  = Svc.Players.LocalPlayer
local PGui = plr:WaitForChild("PlayerGui")

local S = {
    AutoCatch         = false,
    AutoFarm          = false,
    AutoLeave         = false,
    TpFarm            = false,
    PlayerESP         = false,
    ChestFarm         = false,
    NoBall            = false,
    AutoKingBall      = false,
    AutoAdvBall       = false,
    AutoPrismBall     = false,
    PrisAutoKingBall  = false,
    PrisAutoAdvBall   = false,
    PrisAutoPrismBall = false,
    ShowPityOverlay   = false,
    CatchShinyOnly    = false,
    CatchShinyPris    = false,
    PrisReady         = false,
    Running           = true,
    Closed            = false,
    ChestDelay        = 4,
    ScanRadius        = 500,
    LoopDelay         = 2,
    DebugMode         = true,
    LastDebug         = 0,
    DebugInterval     = 0.5,
    ChestIdx          = 0,
    ESPCache          = {},
    LastPetName       = nil,
    BattleSpeedup     = false,
}

local isSpamming = false
local selBoss    = nil
local selPlayer  = nil
local S_BossLoop = false

local cToggle, farmToggle, lToggle, tpToggle = nil, nil, nil, nil
local noBallToggle = nil
local ballDropdown = nil
local prisBallDropdown = nil
local shinyOnlyToggle_ref, shinyPrisToggle_ref = nil, nil

-- ==========================================
-- BOSS LIST
-- ==========================================
local BOSS_LIST = {
    { configId=10001, battlePoolId=9000001,  name="1. Pebgolem"     },
    { configId=10002, battlePoolId=9000002,  name="2. Clamspire"    },
    { configId=10004, battlePoolId=9000003,  name="3. Empixy"       },
    { configId=10005, battlePoolId=9000004,  name="4. Datunymph"    },
    { configId=10008, battlePoolId=9000005,  name="5. Glacitadel"   },
    { configId=10009, battlePoolId=9000006,  name="6. Volcrest"     },
    { configId=10011, battlePoolId=9000007,  name="7. Tinkore"      },
    { configId=10012, battlePoolId=9000008,  name="8. Frostseer"    },
    { configId=10014, battlePoolId=9000009,  name="9. Chitaladin"   },
    { configId=10016, battlePoolId=9000010,  name="10. Viparch"     },
    { configId=10017, battlePoolId=9000011,  name="11. Starmuse"    },
    { configId=10019, battlePoolId=9000012,  name="12. Spikumane"   },
    { configId=10020, battlePoolId=9000014,  name="13. Sundercrene" },
    { configId=10021, battlePoolId=9000013,  name="14. Arcapex"     },
}
local bossNames, bossMap = {}, {}
for _, b in ipairs(BOSS_LIST) do
    table.insert(bossNames, b.name)
    bossMap[b.name] = b
end
selBoss = bossMap[bossNames[1]]

-- ==========================================
-- DYNAMIC PET CONFIG LOADER
-- ==========================================
local PetConfig = (function()
    local ok, mod = pcall(function()
        return require(game:GetService("ReplicatedStorage")
            :WaitForChild("Config")
            :WaitForChild("PetConfig"))
    end)
    if ok and type(mod) == "table" then return mod end
    warn("[PetConfig] Failed to load PetConfig module")
    return {}
end)()

local PET_CONFIG_MAP    = {}
local PetNames          = {}
local CONFIG_TO_DISPLAY = {}
local DISPLAY_TO_CONFIG = {}

local function isAsciiOnly(s)
    return s:match("^[ -~]+$") ~= nil
end

local function isPetModelFallback(s)
    return s:match("^Pet%d*_%d+$") ~= nil
end

for _, data in pairs(PetConfig) do
    if type(data) ~= "table" then continue end

    local modelName = data.name
    local configId = tonumber(data.id)
    if not configId then continue end
    
    local configStr = tostring(configId)
    if not configStr:match("^100%d%d%d%d$") then continue end

    if type(modelName) ~= "string" then continue end

    local displayName = data.displayName or modelName

    if isPetModelFallback(displayName) then continue end
    if not isAsciiOnly(displayName) then continue end

    PET_CONFIG_MAP[modelName]      = configId
    PetNames[modelName]            = displayName
    CONFIG_TO_DISPLAY[configId]    = displayName
    DISPLAY_TO_CONFIG[displayName] = configId
end

local PET_DROPDOWN_LIST = {}
for dname in pairs(DISPLAY_TO_CONFIG) do
    table.insert(PET_DROPDOWN_LIST, dname)
end
table.sort(PET_DROPDOWN_LIST)

local S_SelectedConfigId = DISPLAY_TO_CONFIG[PET_DROPDOWN_LIST[1]] or nil

-- ==========================================
-- SKILL SYSTEM
-- ==========================================
local AUTO_SKILL_ENABLED = false
local SKILL_DEBUG        = true
local SKILL_CLICK_DELAY  = 0.5
local SKILL_ENTRY_DELAY  = 2.5
local SKILL_SLOT_DELAY   = { [1]=1.2, [2]=1.2, [3]=1.2, [4]=1.2 }

local SKILL_KEYCODES = {
    [1] = Enum.KeyCode.One,
    [2] = Enum.KeyCode.Two,
    [3] = Enum.KeyCode.Three,
    [4] = Enum.KeyCode.Four,
}

local SKILL_CONFIG_ENABLED = false
local SKILL_QUEUE          = {}
local skillQueueIdx        = 1
local listSkilConfig       = nil
local _cachedScrollView    = nil

local function getScrollView()
    if _cachedScrollView and _cachedScrollView.Parent then return _cachedScrollView end
    local prefabs = PGui:FindFirstChild("UIPrefabs", true)
    if not prefabs then return nil end
    local bw = prefabs:FindFirstChild("MainBattleWindow", true)
    if not bw then return nil end
    local sv = bw:FindFirstChild("PetNormalSkillScrollView", true)
    if sv and sv.Parent then _cachedScrollView = sv return sv end
    return nil
end

local function getSkillButtons()
    local sv = getScrollView()
    if not sv then return {} end
    local buttons = {}
    for _, item in ipairs(sv:GetChildren()) do
        if item.Name == "PetSkillItem" then
            local frame = item:FindFirstChild("ItemFrame")
            local btn   = frame and frame:FindFirstChild("SkillButton")
            if btn and btn.Visible and btn.Parent then
                table.insert(buttons, btn)
            end
        end
    end
    return buttons
end

local function fireSkillSlot(slotIndex, btn)
    local kc = SKILL_KEYCODES[slotIndex]
    if kc then
        local ok = pcall(function()
            Svc.VIM:SendKeyEvent(true,  kc, false, game)
            task.wait(0.05)
            Svc.VIM:SendKeyEvent(false, kc, false, game)
        end)
        return ok
    end
    if not btn or not btn.Parent then return false end
    local ok = pcall(function()
        local ap = btn.AbsolutePosition
        local as = btn.AbsoluteSize
        Svc.VIM:SendMouseButtonEvent(ap.X + as.X/2, ap.Y + as.Y/2, 0, true,  game, 1)
        task.wait(0.05)
        Svc.VIM:SendMouseButtonEvent(ap.X + as.X/2, ap.Y + as.Y/2, 0, false, game, 1)
    end)
    return ok
end

local function updateSkillConfigLabel()
    if not listSkilConfig then return end
    if #SKILL_QUEUE == 0 then
        pcall(function() listSkilConfig:SetText("Skill List: (empty)") end)
        return
    end
    local parts = {}
    for i, entry in ipairs(SKILL_QUEUE) do table.insert(parts, "Skill " .. entry.slot) end
    pcall(function() listSkilConfig:SetText("Skill List: " .. table.concat(parts, " → ")) end)
end

-- ==========================================
-- CACHE SCAN
-- ==========================================
local function findPetUidByConfig(targetConfigId)
    local rc    = workspace:FindFirstChild("RuntimeCache")
    local rcs   = rc  and rc:FindFirstChild("RuntimeCacheServer")
    local cache = rcs and rcs:FindFirstChild("CreatureModelCache")
    if not cache then
        warn("[TargetFarm] CreatureModelCache not found")
        return nil
    end

    local children = cache:GetChildren()
    for i = #children, 2, -1 do
        local j = math.random(i)
        children[i], children[j] = children[j], children[i]
    end

    for _, entry in ipairs(children) do
        local rawCid =
            entry:GetAttribute("configid") or entry:GetAttribute("configId") or
            entry:GetAttribute("ConfigId") or entry:GetAttribute("ConfigID")
        local cid = tonumber(rawCid)
        if cid == targetConfigId then
            local uid =
                entry:GetAttribute("creatureUid") or entry:GetAttribute("creatureuid") or
                entry:GetAttribute("CreatureUid")  or entry:GetAttribute("CreatureUID")
            if uid then
                S.LastPetName = CONFIG_TO_DISPLAY[targetConfigId] or tostring(targetConfigId)
                return tostring(uid)
            end
        end
        task.wait(0)
    end

    return nil
end

local function enterPetBattle(creatureUid)
    local ok, err = pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Remote"):WaitForChild("Battle")
            :WaitForChild("ReqEnterPetBattle"):FireServer(creatureUid)
    end)
    return ok
end

local islandDisplayNames   = {}
local islandAssetByDisplay = {}

if not _G.NR_hooked then
    _G.NR_hooked = true
    local ok, err = pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local ok2, name = pcall(function() return self.Name end)
            if ok2 and name == "ReqSetMainPet" and method == "InvokeServer" then
                local args = {...}
                if args[1] and type(args[1]) == "string" then _G.NR_petUID = args[1] end
            end
            return oldNamecall(self, ...)
        end)
    end)
end
_G.NR_petUID = nil

task.spawn(function()
    task.wait(1)
    Svc.VIM:SendKeyEvent(true,  Enum.KeyCode.Two, false, game) task.wait(0.1)
    Svc.VIM:SendKeyEvent(false, Enum.KeyCode.Two, false, game) task.wait(0.3)
    Svc.VIM:SendKeyEvent(true,  Enum.KeyCode.One, false, game) task.wait(0.1)
    Svc.VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game)
end)

local function pressKey(k, dur)
    pcall(function()
        Svc.VIM:SendKeyEvent(true,  k, false, game) task.wait(dur or 0.05)
        Svc.VIM:SendKeyEvent(false, k, false, game)
    end)
end

local cachedPris  = { cur = nil, max = nil }
local cachedShiny = { cur = nil, max = nil }

local function getPityInfo()
    local sp = PGui:FindFirstChild("SparklePityText", true)
    if sp then
        local c, m = sp.Text:match("(%d+)/(%d+)")
        if c and m then cachedPris.cur = tonumber(c) cachedPris.max = tonumber(m) end
    end
    return cachedPris.cur, cachedPris.max
end

local function getShinyPityInfo()
    local sp = PGui:FindFirstChild("ShinyPityText", true)
    if sp then
        local c, m = sp.Text:match("(%d+)/(%d+)")
        if c and m then cachedShiny.cur = tonumber(c) cachedShiny.max = tonumber(m) end
    end
    return cachedShiny.cur, cachedShiny.max
end

local _catchCache, _catchCacheTime = false, 0
local function catchVisible()
    local now = os.clock()
    if now - _catchCacheTime < 0.3 then return _catchCache end
    _catchCacheTime = now
    _catchCache = (
        PGui:FindFirstChild("Catch",       true) ~= nil or
        PGui:FindFirstChild("CatchButton", true) ~= nil or
        PGui:FindFirstChild("Catch(2/2)",  true) ~= nil or
        PGui:FindFirstChild("BattleGui",   true) ~= nil
    )
    return _catchCache
end

local function findPet()
    local char = plr.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil, nil end
    local bM, bP, bD = nil, nil, S.ScanRadius
    for _, obj in pairs(workspace:GetDescendants()) do
        if not obj.Name:match("^Pet0_%d+$") then continue end
        if not obj:IsA("Model") then continue end
        if obj == char then continue end
        if Svc.Players:GetPlayerFromCharacter(obj) then continue end
        local fp = obj:GetFullName()
        if not fp:find("RuntimeCacheServer") then continue end
        if not fp:find("CreatureModelCache")  then continue end
        local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
        local hum  = obj:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.Health > 0 then
            local d = (root.Position - hrp.Position).Magnitude
            if d < bD then bD=d bM=obj bP=root end
        end
    end
    return bM, bP, bD
end

-- ==========================================
-- PITY OVERLAY
-- ==========================================
local pityOverlayGui = Instance.new("ScreenGui")
pityOverlayGui.Name           = "NRPityOverlay"
pityOverlayGui.ResetOnSpawn   = false
pityOverlayGui.IgnoreGuiInset = true
pityOverlayGui.DisplayOrder   = 50
pityOverlayGui.Enabled        = false
pityOverlayGui.Parent         = PGui

local pityOverlayLbl = Instance.new("TextLabel")
pityOverlayLbl.AnchorPoint            = Vector2.new(0.5, 0)
pityOverlayLbl.Position               = UDim2.new(0.5, 0, 0, 68)
pityOverlayLbl.Size                   = UDim2.new(0.25, 0, 0, 80)
pityOverlayLbl.BackgroundTransparency = 1
pityOverlayLbl.Text                   = "💎 —/—\n✨ —/—"
pityOverlayLbl.TextScaled             = true
pityOverlayLbl.Font                   = Enum.Font.GothamBold
pityOverlayLbl.TextColor3             = Color3.new(1,1,1)
pityOverlayLbl.TextStrokeTransparency = 0
pityOverlayLbl.TextStrokeColor3       = Color3.new(0,0,0)
pityOverlayLbl.TextXAlignment         = Enum.TextXAlignment.Center
pityOverlayLbl.TextYAlignment         = Enum.TextYAlignment.Top
pityOverlayLbl.Parent                 = pityOverlayGui

-- ==========================================
-- SOUND
-- ==========================================
local function playSound(double)
    task.spawn(function()
        pcall(function()
            local ss    = game:GetService("SoundService")
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://4612359460"
            sound.Volume  = 1
            sound.Parent  = ss
            sound.Loaded:Wait()
            sound:Play()
            if double then task.wait(sound.TimeLength + 0.2) sound:Play() end
            task.wait(sound.TimeLength + 0.5)
            sound:Destroy()
        end)
    end)
end

-- ==========================================
-- SYNC HELPERS
-- ==========================================
local function setAutoLeaveSync(v)
    S.AutoLeave = v
    if lToggle then pcall(function() lToggle:SetValue(v) end) end
end
local function setAutoCatchSync(v)
    S.AutoCatch = v
    if cToggle then pcall(function() cToggle:SetValue(v) end) end
end
local function setAutoFarmSync(v)
    S.AutoFarm = v
    if farmToggle then pcall(function() farmToggle:SetValue(v) end) end
end
local function setTpFarmSync(v)
    S.TpFarm = v
    if tpToggle then pcall(function() tpToggle:SetValue(v) end) end
end

-- ==========================================
-- CONFLICT VALIDATOR
-- ==========================================
local CONFLICT_RULES = {
    {
        source  = "AutoLeave",
        check   = function() return S.AutoLeave end,
        kills   = function() return S.AutoCatch end,
        apply   = function() setAutoCatchSync(false) end,
        msg     = "Auto Catch dimatiin — Auto Leave aktif. Keduanya ga bisa nyala bareng.",
    },
    {
        source  = "AutoCatch",
        check   = function() return S.AutoCatch end,
        kills   = function() return S.AutoLeave end,
        apply   = function() setAutoLeaveSync(false) end,
        msg     = "Auto Leave dimatiin — Auto Catch aktif. Pilih salah satu.",
    },
    {
        source  = "CatchShinyOnly",
        check   = function() return S.CatchShinyOnly end,
        kills   = function() return S.CatchShinyPris end,
        apply   = function()
            S.CatchShinyPris = false
            if shinyPrisToggle_ref then pcall(function() shinyPrisToggle_ref:SetValue(false) end) end
        end,
        msg     = "Catch Shiny & Prismatic dimatiin — Catch Shiny Only aktif.",
    },
    {
        source  = "CatchShinyPris",
        check   = function() return S.CatchShinyPris end,
        kills   = function() return S.CatchShinyOnly end,
        apply   = function()
            S.CatchShinyOnly = false
            if shinyOnlyToggle_ref then pcall(function() shinyOnlyToggle_ref:SetValue(false) end) end
        end,
        msg     = "Catch Shiny Only dimatiin — Catch Shiny & Prismatic aktif.",
    },
    {
        source  = "NoBall",
        check   = function() return S.NoBall end,
        kills   = function()
            return S.AutoKingBall or S.AutoAdvBall or S.AutoPrismBall
                or S.PrisAutoKingBall or S.PrisAutoAdvBall or S.PrisAutoPrismBall
        end,
        apply   = function()
            S.AutoKingBall      = false
            S.AutoAdvBall       = false
            S.AutoPrismBall     = false
            S.PrisAutoKingBall  = false
            S.PrisAutoAdvBall   = false
            S.PrisAutoPrismBall = false
            if ballDropdown     then pcall(function() ballDropdown:SetValue("None")     end) end
            if prisBallDropdown then pcall(function() prisBallDropdown:SetValue("None") end) end
        end,
        msg     = "Semua ball selection direset ke None — No Ball aktif.",
    },
    {
        source  = "TpFarm",
        check   = function() return S.TpFarm and not S.AutoFarm end,
        kills   = function() return true end,
        apply   = function() setAutoFarmSync(true) end,
        msg     = "Auto Farm dinyalain otomatis — Teleport Farm Mode butuh Auto Farm aktif.",
    },
    {
        source  = "AutoFarm",
        check   = function() return not S.AutoFarm and S.TpFarm end,
        kills   = function() return true end,
        apply   = function() setTpFarmSync(false) end,
        msg     = "Teleport Farm dimatiin — Auto Farm OFF, TP Farm ga bisa jalan sendiri.",
    },
}

local _validating = false
local function validateConflicts(source)
    if _validating then return end
    _validating = true
    for _, rule in ipairs(CONFLICT_RULES) do
        if rule.source == source and rule.check() and rule.kills() then
            rule.apply()
            if Window then
                pcall(function()
                    Library:Notify({
                        Title    = "⚠️ Konflik Toggle",
                        Description  = rule.msg,
                        Duration = 4,
                    })
                end)
            end
        end
    end
    _validating = false
end

-- ==========================================
-- DETECTION HELPERS
-- ==========================================
local S_AutoStopShiny     = false
local S_AutoStopPrismatic = false

local _shinyFiredThisBattle     = false
local _prismaticFiredThisBattle = false
local _wasBattle                = false

local function isShinyPending()
    if not PGui:FindFirstChild("BattleGui", true) then return false end
    local sc, sm = getShinyPityInfo()
    return sc ~= nil and sm ~= nil and sc >= (sm - 1)
end

local function isPrismaticPending()
    if not PGui:FindFirstChild("BattleGui", true) then return false end
    local cur, max = getPityInfo()
    return cur ~= nil and max ~= nil and cur >= (max - 1)
end

-- ==========================================
-- SHINY DETECTED
-- ==========================================
local function onShinyDetected()
    warn("✨ SHINY DETECTED!")
    isSpamming  = false
    S.PrisReady = false

    local ballKey = S.AutoKingBall  and Enum.KeyCode.Three
        or S.AutoAdvBall   and Enum.KeyCode.Two
        or S.AutoPrismBall and Enum.KeyCode.Four

    setAutoCatchSync(false)
    setAutoFarmSync(false)
    setAutoLeaveSync(false)
    if S.TpFarm then setTpFarmSync(false) end
    playSound(false)

    task.spawn(function()
        task.wait(0.5)
        if ballKey and not S.NoBall then
            pressKey(ballKey, 0.1)
            task.wait(0.5)
        end
        isSpamming = true
        for _ = 1, 30 do
            pressKey(Enum.KeyCode.E, 0.05)
            task.wait(0.15)
        end
        isSpamming = false
    end)
end

-- ==========================================
-- PRISMATIC DETECTED
-- ==========================================
local function onPrismaticDetected()
    warn("💎 PRISMATIC DETECTED!")
    isSpamming  = false
    S.PrisReady = false

    local ballKey = S.PrisAutoKingBall  and Enum.KeyCode.Three
        or S.PrisAutoAdvBall   and Enum.KeyCode.Two
        or S.PrisAutoPrismBall and Enum.KeyCode.Four

    setAutoCatchSync(false)
    setAutoFarmSync(false)
    setAutoLeaveSync(false)
    if S.TpFarm then setTpFarmSync(false) end
    playSound(true)

    task.spawn(function()
        task.wait(0.5)
        if ballKey and not S.NoBall then
            pressKey(ballKey, 0.1)
            task.wait(0.5)
        end
        isSpamming = true
        for _ = 1, 30 do
            pressKey(Enum.KeyCode.E, 0.05)
            task.wait(0.15)
        end
        isSpamming = false
    end)
end

-- ==========================================
-- HANDLE CATCH
-- ==========================================
local function handleCatch()
    if S_AutoStopPrismatic and not _prismaticFiredThisBattle and isPrismaticPending() then
        _prismaticFiredThisBattle = true
        warn("💎 PRISMATIC DETECTED — Auto Stop triggered")
        playSound(true)

        isSpamming = false
        S.PrisReady = false
        setAutoCatchSync(false)
        setAutoFarmSync(false)
        setAutoLeaveSync(false)
        if S.TpFarm then setTpFarmSync(false) end
        if S_TargetFarm then
            S_TargetFarm = false
            pcall(function()
                Library:Notify({
                    Title    = "💎 Prismatic Detected",
                    Description  = "Auto Stop aktif — semua farm dihentikan. Tangkap manual!",
                    Duration = 6,
                })
            end)
        end
        return
    end

    if S_AutoStopShiny and not _shinyFiredThisBattle and isShinyPending() then
        _shinyFiredThisBattle = true
        warn("✨ SHINY DETECTED — Auto Stop triggered")
        playSound(false)

        isSpamming = false
        S.PrisReady = false
        setAutoCatchSync(false)
        setAutoFarmSync(false)
        setAutoLeaveSync(false)
        if S.TpFarm then setTpFarmSync(false) end
        if S_TargetFarm then
            S_TargetFarm = false
            pcall(function()
                Library:Notify({
                    Title    = "✨ Shiny Detected",
                    Description  = "Auto Stop aktif — semua farm dihentikan. Tangkap manual!",
                    Duration = 6,
                })
            end)
        end
        return
    end

    if S.CatchShinyPris and not _prismaticFiredThisBattle and isPrismaticPending() then
        _prismaticFiredThisBattle = true
        onPrismaticDetected()
        return
    end

    if (S.CatchShinyOnly or S.CatchShinyPris) and not _shinyFiredThisBattle and isShinyPending() then
        _shinyFiredThisBattle = true
        onShinyDetected()
        return
    end

    if S.AutoLeave then
        local ballKey = nil
        if isShinyPending() then
            ballKey = S.AutoKingBall  and Enum.KeyCode.Three
                or   S.AutoAdvBall   and Enum.KeyCode.Two
                or   S.AutoPrismBall and Enum.KeyCode.Four
        end
        if ballKey and not S.NoBall then
            pressKey(ballKey, 0.1)
            task.wait(0.4)
        end
        pressKey(Enum.KeyCode.C, 0.1)
        return
    end

    if not S.NoBall then
        pressKey(Enum.KeyCode.E, 0.05)
        task.wait(0.1)
    end
end

-- ==========================================
-- TP FARM
-- ==========================================
local function tpFarmTick()
    local char = plr.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local m, p, d = findPet()
    if not (m and p) then return end
    S.LastPetName = PetNames[m.Name] or m.Name
    hrp.CFrame = p.CFrame * CFrame.new(0, 0, 2.5)
    task.wait(0.15)
    local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
    for _ = 1, 3 do
        local k = keys[math.random(1,4)]
        Svc.VIM:SendKeyEvent(true,  k, false, game) task.wait(0.08)
        Svc.VIM:SendKeyEvent(false, k, false, game) task.wait(0.05)
    end
    pressKey(Enum.KeyCode.E, 0.05)
    task.wait(0.3)
    if not catchVisible() then
        hrp.CFrame = p.CFrame * CFrame.new(0, 0, 1)
        task.wait(0.1)
        pressKey(Enum.KeyCode.E, 0.05)
    end
end

local function doEnterBattle(boss)
    pcall(function()
        local rc    = workspace:FindFirstChild("RuntimeCache")
        local rcs   = rc  and rc:FindFirstChild("RuntimeCacheServer")
        local cache = rcs and rcs:FindFirstChild("CreatureModelCache")
        if cache then
            for _, child in ipairs(cache:GetChildren()) do
                local cid = child:GetAttribute("configId") or child:GetAttribute("ConfigId")
                if tonumber(cid) == boss.configId then
                    local pm = child:FindFirstChildWhichIsA("Model")
                    local br = pm and (pm:FindFirstChild("HumanoidRootPart") or pm.PrimaryPart)
                    local char = plr.Character
                    local mr = char and char:FindFirstChild("HumanoidRootPart")
                    if br and mr then mr.CFrame = br.CFrame * CFrame.new(0,0,4) end
                    break
                end
            end
        end
    end)
    task.wait(0.2)
    if not _G.NR_petUID then return false end
    local ok = pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Remote"):WaitForChild("Battle")
            :WaitForChild("ReqEnterNpcBattle")
            :FireServer(boss.configId, boss.battlePoolId, _G.NR_petUID)
    end)
    if ok then
        local waited = 0
        repeat task.wait(0.5) waited += 0.5 until waited >= 15
    end
    return ok
end

-- ==========================================
-- ESP
-- ==========================================
local function createESP(player)
    if player == plr or S.ESPCache[player] then return end
    local con = {}
    local function apply(char)
        if not char then return end
        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.fromRGB(0,170,255) hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.new(1,1,1) hl.Adornee = char hl.Enabled = S.PlayerESP hl.Parent = char
        con.hl = hl
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0,160,0,40) bb.AlwaysOnTop = true
        bb.ExtentsOffset = Vector3.new(0,2.5,0) bb.Enabled = S.PlayerESP bb.Parent = char
        con.bb = bb
        local l = Instance.new("TextLabel", bb)
        l.Size = UDim2.fromScale(1,1) l.BackgroundTransparency = 1 l.TextSize = 12
        l.Font = Enum.Font.SourceSansBold l.TextColor3 = Color3.new(1,1,1) l.TextStrokeTransparency = 0
        con.lbl = l
        local rp = char:WaitForChild("HumanoidRootPart", 5)
        if rp then bb.Adornee = rp end
    end
    if player.Character then apply(player.Character) end
    player.CharacterAdded:Connect(apply)
    S.ESPCache[player] = con
end

local function removeESP(player)
    local c = S.ESPCache[player]
    if c then
        pcall(function() if c.hl then c.hl:Destroy() end if c.bb then c.bb:Destroy() end end)
        S.ESPCache[player] = nil
    end
end

for _, p in ipairs(Svc.Players:GetPlayers()) do createESP(p) end
Svc.Players.PlayerAdded:Connect(createESP)
Svc.Players.PlayerRemoving:Connect(removeESP)

Svc.Run.RenderStepped:Connect(function()
    if not S.PlayerESP then return end
    local char   = plr.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for tgt, obj in pairs(S.ESPCache) do
        local tc = tgt.Character
        local tr = tc and tc:FindFirstChild("HumanoidRootPart")
        if tr and obj.bb and obj.lbl then
            obj.bb.Enabled = true
            obj.lbl.Text = tgt.Name .. "\n[" .. string.format("%.1f", (tr.Position-myRoot.Position).Magnitude*0.28) .. " m]"
        elseif obj.bb then obj.bb.Enabled = false end
    end
end)

-- ==========================================
-- BATTLE STATE DETECTION
-- ==========================================
local function getBattleCharacterModel()
    local rc  = workspace:FindFirstChild("RuntimeCache")
    local rcc = rc and rc:FindFirstChild("RuntimeCacheClient")
    local bcm = rcc and rcc:FindFirstChild("BattleCharacterModel")
    if not bcm then return nil end
    return bcm:FindFirstChild(plr.Name)
end

local function isBattle()
    return getBattleCharacterModel() ~= nil
end

-- ==========================================
-- MAIN LOOPS
-- ==========================================
task.spawn(function()
    while task.wait(S.LoopDelay) do
        if not S.Running then break end
        if not (S.AutoFarm or S.AutoCatch or S.AutoLeave or S.TpFarm) then continue end
        if catchVisible() then
            if S.AutoCatch or S.AutoLeave then handleCatch() end
            continue
        end
        if S.AutoFarm then
            if S.TpFarm then
                pcall(tpFarmTick)
            else
                pcall(function()
                    local m, p, d = findPet()
                    if m and p then
                        S.LastPetName = PetNames[m.Name] or m.Name
                        local char = plr.Character
                        local hum  = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            local keys = {Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D}
                            for _ = 1, math.random(2,4) do
                                local k = keys[math.random(1,4)]
                                Svc.VIM:SendKeyEvent(true,  k, false, game) task.wait(math.random(10,25)/100)
                                Svc.VIM:SendKeyEvent(false, k, false, game) task.wait(0.05)
                            end
                            hum:MoveTo(p.Position)
                        end
                    end
                end)
            end
        elseif S.TpFarm then
            pcall(tpFarmTick)
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if not S.Running then break end
        if (S.AutoCatch or S.AutoLeave or S.CatchShinyOnly or S.CatchShinyPris) and catchVisible() then
            handleCatch()
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if not S.Running then break end
        if S.ChestFarm then
            local rc  = workspace:FindFirstChild("RuntimeCache")
            local rcc = rc and rc:FindFirstChild("RuntimeCacheClient")
            local dir = rcc and rcc:FindFirstChild("Chest")
            if dir then
                local list = {}
                for _, c in ipairs(dir:GetChildren()) do
                    if c:IsA("Folder") or c:IsA("Model") then table.insert(list, c) end
                end
                if #list > 0 then
                    S.ChestIdx = S.ChestIdx + 1
                    if S.ChestIdx > #list then S.ChestIdx = 1 end
                    local bp   = list[S.ChestIdx]:FindFirstChildWhichIsA("BasePart", true)
                    local char = plr.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if bp and root then root.CFrame = bp.CFrame * CFrame.new(0,3,0) end
                end
            end
            local el = 0
            while el < S.ChestDelay and S.ChestFarm do
                pressKey(Enum.KeyCode.E, 0.05) task.wait(0.05) el += 0.2
            end
        else task.wait(0.05) end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if not S.Running then break end
        if not S_BossLoop or not selBoss then continue end
        doEnterBattle(selBoss)
        if S_BossLoop then task.wait(1) end
    end
end)

-- ==========================================
-- PITY WATCHER
-- ==========================================
task.spawn(function()
    while task.wait(0.3) do
        if not S.Running then break end

        local nowBattle = isBattle()

        if nowBattle and not _wasBattle then
            _shinyFiredThisBattle     = false
            _prismaticFiredThisBattle = false
        end

        _wasBattle = nowBattle

        if S.ShowPityOverlay then
            local petLabel  = S.LastPetName and ("[" .. S.LastPetName .. "]") or ""
            local cur, max  = getPityInfo()
            local prisText  = (cur and max) and string.format("💎 %d/%d", cur, max) or "💎 —/—"
            local sc, sm    = getShinyPityInfo()
            local shinyText = (sc and sm) and string.format("✨ %d/%d", sc, sm) or "✨ —/—"
            pityOverlayLbl.Text = petLabel ~= ""
                and (petLabel.."\n"..prisText.."\n"..shinyText)
                or  (prisText.."\n"..shinyText)
        end
    end
end)

-- ==========================================
-- AUTO SKILL LOOP
-- ==========================================
task.spawn(function()
    local entryWaited = false
    while S.Running do
        task.wait(0.1)
        if not AUTO_SKILL_ENABLED then entryWaited = false continue end
        if not isBattle() then
            _cachedScrollView = nil
            entryWaited       = false
            continue
        end
        if not entryWaited then
            task.wait(SKILL_ENTRY_DELAY)
            entryWaited   = true
            skillQueueIdx = 1
        end
        local buttons = getSkillButtons()
        if #buttons == 0 then
            task.wait(0.5)
            continue
        end
        if SKILL_CONFIG_ENABLED and #SKILL_QUEUE > 0 then
            if skillQueueIdx > #SKILL_QUEUE then skillQueueIdx = 1 end
            local entry     = SKILL_QUEUE[skillQueueIdx]
            local targetIdx = entry.slot
            if targetIdx > #buttons then
                skillQueueIdx += 1
                task.wait(0.1)
                continue
            end
            fireSkillSlot(targetIdx, buttons[targetIdx])
            local delay = SKILL_SLOT_DELAY[targetIdx] or 1.2
            skillQueueIdx += 1
            task.wait(delay)
        else
            local ri = math.random(1, #buttons)
            if SKILL_DEBUG then warn(string.format("[SKILL] random | slot %d", ri)) end
            fireSkillSlot(ri, buttons[ri])
            task.wait(SKILL_CLICK_DELAY)
        end
    end
end)

-- ==========================================
-- TARGET FARM LOOP
-- ==========================================
local S_TargetFarm        = false
local S_SelectedConfigIds = {}
local S_TargetFarmIdx     = 1
local S_TargetFarmSignal  = Instance.new("BindableEvent")

task.spawn(function()
    while true do
        if not S.Running then break end
        if not S_TargetFarm or #S_SelectedConfigIds == 0 then
            S_TargetFarmSignal.Event:Wait()
            continue
        end
        if isBattle() then
            repeat task.wait(0.5) until not isBattle() or not S_TargetFarm
            continue
        end

        if S_TargetFarmIdx > #S_SelectedConfigIds then S_TargetFarmIdx = 1 end
        local configId = S_SelectedConfigIds[S_TargetFarmIdx]

        local uid = findPetUidByConfig(configId)
        if uid then
            local ok = enterPetBattle(uid)
            if ok then
                local ws = os.clock()
                repeat task.wait(0.2) until isBattle() or (os.clock() - ws) >= 3

                local fired = false
                local conn  = S_TargetFarmSignal.Event:Connect(function() fired = true end)
                repeat task.wait(0.3) until not isBattle() or not S_TargetFarm or fired
                conn:Disconnect()

                if not fired then
                    local delayTime = S.TargetFarmNextDelay or 1
                    if delayTime > 0 then
                        task.wait(delayTime)
                    end
                    S_TargetFarmIdx = (S_TargetFarmIdx % #S_SelectedConfigIds) + 1
                end
            else
                warn("[TargetFarm] enterPetBattle failed — retry in 0.5s")
                task.wait(0.5)
            end
        else
            warn(string.format("[TargetFarm] configId %d (%s) not found in cache — rescan in 0.5s",
                configId, CONFIG_TO_DISPLAY[configId] or "?"))
            task.wait(0.5)
        end
    end
end)

local S_AutoChestClaim  = false
local CHEST_CLAIM_CYCLE = 4

local function claimAllChests()
    local rc  = workspace:FindFirstChild("RuntimeCache")
    local rcc = rc  and rc:FindFirstChild("RuntimeCacheClient")
    local dir = rcc and rcc:FindFirstChild("Chest")
    local remote = game:GetService("ReplicatedStorage")
        :WaitForChild("Remote"):WaitForChild("Chest"):WaitForChild("ReqClaimExploreReward")
    local claimed = 0
    for _, child in ipairs(dir:GetChildren()) do
        local ok, err = pcall(function() remote:InvokeServer(child.Name) end)
        if ok then claimed += 1 task.wait(0.15)
        else warn("[ChestClaim] Gagal claim " .. child.Name .. " | " .. tostring(err)) end
    end
    return claimed
end

task.spawn(function()
    while S.Running do
        task.wait(CHEST_CLAIM_CYCLE)
        if not S_AutoChestClaim then continue end
        local n = claimAllChests()
    end
end)

-- ==========================================
-- AUTO X2 SPEED
-- ==========================================
local _sessionPrefs      = nil
local _battleSettings    = nil
local _BattleService     = nil
local _ReqAutoBattle     = nil
local _battleSpeedupConn = nil

local function injectAutoBattle()
    pcall(function()
        if not _BattleService then
            pcall(function()
                local Script = game:GetService("ReplicatedStorage"):WaitForChild("Script")
                _BattleService = require(Script:WaitForChild("Battle"):WaitForChild("BattleService"))
            end)
        end
        if not _ReqAutoBattle then
            pcall(function()
                _ReqAutoBattle = game:GetService("ReplicatedStorage")
                    :WaitForChild("Remote"):WaitForChild("Battle")
                    :WaitForChild("ReqAutoBattle")
            end)
        end
        _sessionPrefs   = nil
        _battleSettings = nil
        for _, obj in pairs(getgc(true)) do
            if type(obj) == "table" then
                if not _sessionPrefs   and rawget(obj, "preferBattleSpeed")   ~= nil then _sessionPrefs   = obj end
                if not _battleSettings and rawget(obj, "battleSpeedEnabled")   ~= nil then _battleSettings = obj end
            end
            if _sessionPrefs and _battleSettings then break end
        end

        if _sessionPrefs  then _sessionPrefs.preferBattleSpeed    = true end
        if _battleSettings then _battleSettings.battleSpeedEnabled = true end
    end)
end

-- ==========================================
-- AUTO RELEASE
-- ==========================================
local S_AutoRelease = false
local S_ReleaseSet  = {}

local function shouldReleasePet(petUuid)
    if not next(S_ReleaseSet) then return false end

    local PS  = getPetStorage()
    local PGS = getPetGroupStorage()
    if not PS then return false end

    local groupedUuids = {}
    if PGS then
        local ok, group = pcall(function() return PGS.getPetGroup() end)
        if ok and group and group.petGroupList then
            for _, g in pairs(group.petGroupList) do
                for _, uuid in ipairs(g.petUuids or {}) do
                    groupedUuids[uuid] = true
                end
            end
        end
    end

    local ok, petList = pcall(function() return PS.getPetList() end)
    if not ok or not petList then return false end

    local pet = petList[petUuid]
    if not pet then return false end

    local grade = pet.grade or "D"
    return S_ReleaseSet[grade] == true and not groupedUuids[petUuid]
end

local function tryReleasePet(petUuid)
    local ok, err = pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Remote"):WaitForChild("Pet")
            :WaitForChild("ReqRemovePets"):InvokeServer({ petUuid })
    end)
    return ok
end

task.spawn(function()
    while task.wait(3) do
        if not S.Running then break end
        if not S_AutoRelease or not next(S_ReleaseSet) then continue end

        local PS = getPetStorage()
        if not PS then continue end

        local ok, petList = pcall(function() return PS.getPetList() end)
        if not ok or not petList then continue end

        for uuid in pairs(petList) do
            if not S_AutoRelease then break end
            if shouldReleasePet(uuid) then
                tryReleasePet(uuid)
                task.wait(0.1)
            end
        end
    end
end)

local _PetStorage      = nil
local _PetGroupStorage = nil

local function getPetStorage()
    if _PetStorage then return _PetStorage end
    local ok, mod = pcall(function()
        return require(game:GetService("ReplicatedStorage")
            :WaitForChild("Storage")
            :WaitForChild("PetStorage"))
    end)
    if ok and mod then _PetStorage = mod end
    return _PetStorage
end

local function getPetGroupStorage()
    if _PetGroupStorage then return _PetGroupStorage end
    local ok, mod = pcall(function()
        return require(game:GetService("ReplicatedStorage")
            :WaitForChild("Storage")
            :WaitForChild("PetGroupStorage"))
    end)
    if ok and mod then _PetGroupStorage = mod end
    return _PetGroupStorage
end

-- ==========================================
-- MISC FUNCTIONS
-- ==========================================
local MiscS = {
    AntiAFK=false, Noclip=false, FullBright=false, InfiniteJump=false,
    SpeedEnabled=false, JumpEnabled=false, SpeedValue=16, JumpValue=50,
    FlingEnabled=false, FlingPower=100, GravityEnabled=false, GravityValue=196.2,
    TimeEnabled=false, TimeValue=14, FogEnabled=false, FogValue=100000,
    ThirdPerson=false, TPDist=15,
}

local _origLighting = {
    Brightness     = game:GetService("Lighting").Brightness,
    Ambient        = game:GetService("Lighting").Ambient,
    OutdoorAmbient = game:GetService("Lighting").OutdoorAmbient,
    FogEnd         = game:GetService("Lighting").FogEnd,
    ClockTime      = game:GetService("Lighting").ClockTime,
}

local function getChar() return plr.Character end
local function getHRP()  local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function applySpeed(v) local h = getHum() if h then h.WalkSpeed = v end end
local function applyJump(v)  local h = getHum() if h then h.JumpPower  = v end end

plr.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 5) task.wait(0.5)
    if MiscS.SpeedEnabled then applySpeed(MiscS.SpeedValue) end
    if MiscS.JumpEnabled   then applyJump(MiscS.JumpValue)  end
end)

local antiAFKConn = nil
local function setAntiAFK(v)
    MiscS.AntiAFK = v
    if v then
        if antiAFKConn then antiAFKConn:Disconnect() end
        antiAFKConn = Svc.Run.Heartbeat:Connect(function()
            pcall(function() Svc.VIM:SendMouseMoveEvent(0, 0, game) end)
        end)
    else if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn = nil end end
end

local noclipConn = nil
local function setNoclip(v)
    MiscS.Noclip = v
    if v then
        noclipConn = Svc.Run.Stepped:Connect(function()
            local char = getChar()
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        local char = getChar()
        if char then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
    end
end

local function setFullBright(v)
    MiscS.FullBright = v
    local L = game:GetService("Lighting")
    if v then L.Brightness=2 L.Ambient=Color3.new(1,1,1) L.OutdoorAmbient=Color3.new(1,1,1)
    else L.Brightness=_origLighting.Brightness L.Ambient=_origLighting.Ambient L.OutdoorAmbient=_origLighting.OutdoorAmbient end
end

local ijConn = nil
local function setInfiniteJump(v)
    MiscS.InfiniteJump = v
    if v then
        ijConn = Svc.UIS.JumpRequest:Connect(function()
            local h = getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else if ijConn then ijConn:Disconnect() ijConn = nil end end
end

local function applyGravity(v) workspace.Gravity = v end
local function applyTime(v) game:GetService("Lighting").ClockTime = v end
local function applyFog(v)  game:GetService("Lighting").FogEnd = v end

local camConn = nil
local function setThirdPerson(v, dist)
    MiscS.ThirdPerson = v
    if camConn then camConn:Disconnect() camConn = nil end
    if v then
        local cam = workspace.CurrentCamera
        camConn = Svc.Run.RenderStepped:Connect(function()
            if cam.CameraType == Enum.CameraType.Custom then
                cam.CameraMinZoomDistance = dist
                cam.CameraMaxZoomDistance = dist
            end
        end)
    else
        workspace.CurrentCamera.CameraMinZoomDistance = 0.5
        workspace.CurrentCamera.CameraMaxZoomDistance = 400
    end
end

-- ==========================================
-- ANTI-LAG
-- ==========================================
local AntiLagS = {
    Enabled=false, ShadowsKilled=false, ParticlesKilled=false,
    TexturesLow=false, RenderDist=500, FPSCapEnabled=false, FPSCapValue=60,
}
local _origRender = {
    QualityLevel   = settings().Rendering.QualityLevel,
    MeshPartLOD    = settings().Rendering.MeshPartDetailLevel,
    ShadowSoftness = game:GetService("Lighting").ShadowSoftness,
    GlobalShadows  = game:GetService("Lighting").GlobalShadows,
}
local fpsCapConn = nil

local function killParticles(v)
    AntiLagS.ParticlesKilled = v
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = not v
        end
    end
end
local function setLowTextures(v)
    AntiLagS.TexturesLow = v
    local r = settings().Rendering
    if v then r.QualityLevel=Enum.QualityLevel.Level01 r.MeshPartDetailLevel=Enum.MeshPartDetailLevel.Disabled
    else r.QualityLevel=_origRender.QualityLevel r.MeshPartDetailLevel=_origRender.MeshPartLOD end
end
local function setShadows(v)
    AntiLagS.ShadowsKilled = v
    local L = game:GetService("Lighting")
    if v then L.GlobalShadows=false L.ShadowSoftness=0
    else L.GlobalShadows=true L.ShadowSoftness=_origRender.ShadowSoftness end
end
local function setFPSCap(enabled, cap)
    if fpsCapConn then fpsCapConn:Disconnect() fpsCapConn = nil end
    AntiLagS.FPSCapEnabled = enabled
    if not enabled then return end
    local interval = 1 / cap
    local last = os.clock()
    fpsCapConn = Svc.Run.RenderStepped:Connect(function()
        if (os.clock() - last) < interval then
            repeat task.wait() until (os.clock() - last) >= interval
        end
        last = os.clock()
    end)
end
local function applyAntiLagPreset(v)
    AntiLagS.Enabled = v
    killParticles(v) setLowTextures(v) setShadows(v)
    if v then pcall(function() workspace.StreamingMinRadius = AntiLagS.RenderDist end)
    else if _origRender.MaxDistance then pcall(function() workspace.StreamingMinRadius = _origRender.MaxDistance end) end end
end

workspace.DescendantAdded:Connect(function(obj)
    if not AntiLagS.ParticlesKilled then return end
    if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
        obj.Enabled = false
    end
end)

-- ==========================================
-- BUILD UI — OXIDELIB (tanpa AddSection)
-- ==========================================

-- TABS
local farmingTab = Window:AddTab({Name = "Farming", Icon = "swords"})
local shinyTab = Window:AddTab({Name = "Shiny", Icon = "sparkles"})
local espTab = Window:AddTab({Name = "ESP", Icon = "eye"})
local bossTab = Window:AddTab({Name = "Boss", Icon = "sword"})
local chestTab = Window:AddTab({Name = "Chest", Icon = "package"})
local teleportTab = Window:AddTab({Name = "Teleport", Icon = "map-pin"})
local rewardsTab = Window:AddTab({Name = "Rewards", Icon = "gift"})
local miscTab = Window:AddTab({Name = "Misc", Icon = "wrench"})
local uiSettingsTab = Window:AddTab({Name = "UI Settings", Icon = "settings-2"})

-- ==========================================
-- TAB: FARMING
-- ==========================================
farmingTab:AddLabel({Text = "Automation"})

farmToggle = farmingTab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(v)
        S.AutoFarm = v
        validateConflicts("AutoFarm")
    end
})

cToggle = farmingTab:AddToggle({
    Name = "Auto Catch",
    Default = false,
    Callback = function(v)
        S.AutoCatch = v
        validateConflicts("AutoCatch")
    end
})

lToggle = farmingTab:AddToggle({
    Name = "Auto Leave",
    Default = false,
    Callback = function(v)
        S.AutoLeave = v
        validateConflicts("AutoLeave")
    end
})

tpToggle = farmingTab:AddToggle({
    Name = "Teleport Farm Mode",
    Default = false,
    Callback = function(v)
        S.TpFarm = v
        validateConflicts("TpFarm")
    end
})

noBallToggle = farmingTab:AddToggle({
    Name = "Manual Catch (No Ball)",
    Default = false,
    Callback = function(v)
        S.NoBall = v
        validateConflicts("NoBall")
    end
})

farmingTab:AddToggle({
    Name = "Auto x2 Speed",
    Default = false,
    Callback = function(v)
        S.BattleSpeedup = v
        if _battleSpeedupConn then _battleSpeedupConn:Disconnect() _battleSpeedupConn = nil end
        if v then
            task.spawn(injectAutoBattle)
            task.spawn(function()
                while S.BattleSpeedup and S.Running do
                    task.wait(3)
                    if S.BattleSpeedup and isBattle() then pcall(injectAutoBattle) end
                end
            end)
        end
    end
})

farmingTab:AddDivider()

farmingTab:AddLabel({Text = "Status"})

local farmStatLbl = farmingTab:AddLabel({Text = "Farm: Idle"})
local petStatLbl = farmingTab:AddLabel({Text = "Last Pet: —"})

task.spawn(function()
    while task.wait(1) do
        if not S.Running then break end
        local state = "Idle"
        if     S.CatchShinyOnly           then state = "✨ Shiny Hunt"
        elseif S.CatchShinyPris           then state = "💎 Shiny+Pris Hunt"
        elseif S.AutoFarm and S.TpFarm    then state = "🚀 TP Farming"
        elseif S.AutoFarm                 then state = "🏃 Walking Farm"
        elseif S.AutoCatch                then state = "🎯 Auto Catch"
        elseif S.AutoLeave                then state = "↩ Auto Leave" end
        pcall(function() farmStatLbl:SetText("Farm: "..state) end)
        if S.LastPetName then pcall(function() petStatLbl:SetText("Last Pet: "..S.LastPetName) end) end
    end
end)

farmingTab:AddDivider()

farmingTab:AddLabel({Text = "Auto Farm (Selected)"})

local targetRotationLabel = farmingTab:AddLabel({Text = "Rotation: (none)"})

local function updateTargetRotationLabel()
    if #S_SelectedConfigIds == 0 then
        pcall(function() targetRotationLabel:SetText("Rotation: (none)") end)
        return
    end
    local names = {}
    for _, cid in ipairs(S_SelectedConfigIds) do
        table.insert(names, CONFIG_TO_DISPLAY[cid] or tostring(cid))
    end
    pcall(function() targetRotationLabel:SetText("Rotation: " .. table.concat(names, " → ")) end)
end

farmingTab:AddDropdown({
    Name = "Select Target Pet(s)",
    Options = PET_DROPDOWN_LIST,
    Default = {},
    Multi = true,
    Searchable = true,
    Callback = function(v)
        local selected = {}
        if type(v) == "table" then
            for k, val in pairs(v) do
                if type(k) == "string" and val == true then
                    table.insert(selected, k)
                elseif type(val) == "string" then
                    table.insert(selected, val)
                end
            end
        end
        table.sort(selected)

        S_SelectedConfigIds = {}
        S_TargetFarmIdx     = 1
        for _, dname in ipairs(selected) do
            local cid = DISPLAY_TO_CONFIG[dname]
            if cid then table.insert(S_SelectedConfigIds, cid) end
        end

        updateTargetRotationLabel()
        if S_TargetFarm and #S_SelectedConfigIds > 0 then S_TargetFarmSignal:Fire() end
    end
})

farmingTab:AddInput({
    Name = "Next Pet Delay",
    Default = "2.0",
    Placeholder = "0.5 - 10",
    Callback = function(text)
        local val = tonumber(text)
        if val then
            S.TargetFarmNextDelay = val
        end
    end
})

farmingTab:AddToggle({
    Name = "Auto Farm (Selected)",
    Default = false,
    Callback = function(v)
        S_TargetFarm = v
        S_TargetFarmIdx = 1
        if v and #S_SelectedConfigIds > 0 then S_TargetFarmSignal:Fire() end
    end
})

farmingTab:AddDivider()

farmingTab:AddLabel({Text = "Auto Release"})

farmingTab:AddDropdown({
    Name = "Select Grade",
    Options = {"D", "C", "B", "A", "S", "SSS"},
    Default = {},
    Multi = true,
    Searchable = true,
    Callback = function(v)
        S_ReleaseSet = {}
        if type(v) == "table" then
            for k, val in pairs(v) do
                if type(k) == "string" and val == true then
                    S_ReleaseSet[k] = true
                elseif type(val) == "string" then
                    S_ReleaseSet[val] = true
                end
            end
        end
    end
})

farmingTab:AddToggle({
    Name = "Auto Release",
    Default = false,
    Callback = function(v)
        S_AutoRelease = v
        if v and not next(S_ReleaseSet) then
            Library:Notify({
                Title = "⚠️ Auto Release",
                Description = "Pilih grade yang mau di-release dulu.",
                Duration = 4
            })
        end
    end
})

farmingTab:AddDivider()

farmingTab:AddLabel({Text = "Skill Configuration"})

listSkilConfig = farmingTab:AddLabel({Text = "Skill List: (empty)"})

local function makeSkillButton(slot, name)
    farmingTab:AddButton({
        Name = name,
        Callback = function()
            table.insert(SKILL_QUEUE, { slot=slot })
            Library:Notify({
                Title = "Skill Config",
                Description = name.." → pos "..#SKILL_QUEUE,
                Duration = 1.5
            })
            updateSkillConfigLabel()
        end
    })
end

makeSkillButton(1, "Add Skill 1")
makeSkillButton(2, "Add Skill 2")
makeSkillButton(3, "Add Skill 3")
makeSkillButton(4, "Add Skill 4")

farmingTab:AddInput({
    Name = "Skill Delay (s) — Config Mode",
    Default = "5.0",
    Placeholder = "0.5 - 10",
    Callback = function(text)
        local val = tonumber(text)
        if val then
            for i=1,4 do SKILL_SLOT_DELAY[i] = val end
        end
    end
})

farmingTab:AddInput({
    Name = "Entry Delay (s)",
    Default = "3.0",
    Placeholder = "0.5 - 10",
    Callback = function(text)
        local val = tonumber(text)
        if val then SKILL_ENTRY_DELAY = val end
    end
})

farmingTab:AddButton({
    Name = "Clear Queue",
    Callback = function()
        SKILL_QUEUE={} skillQueueIdx=1 updateSkillConfigLabel()
        Library:Notify({ Title="Skill Config", Description="Queue cleared.", Duration=1.5 })
    end
})

farmingTab:AddToggle({
    Name = "Auto Skill",
    Default = false,
    Callback = function(v) AUTO_SKILL_ENABLED = v end
})

farmingTab:AddToggle({
    Name = "Use Skill Config",
    Default = false,
    Callback = function(v)
        SKILL_CONFIG_ENABLED = v
        skillQueueIdx = 1
    end
})

farmingTab:AddLabel({Text = "Info: Entry delay = delay before first skill."})

-- ==========================================
-- TAB: SHINY
-- ==========================================
shinyTab:AddLabel({Text = "Detection Modes"})

shinyTab:AddToggle({
    Name = "Show Pity Overlay",
    Default = false,
    Callback = function(v)
        S.ShowPityOverlay = v
        pityOverlayGui.Enabled = v
    end
})

shinyOnlyToggle_ref = shinyTab:AddToggle({
    Name = "Catch Shiny Only",
    Default = false,
    Callback = function(v)
        S.CatchShinyOnly = v
        if v then
            setAutoFarmSync(true)
            setAutoCatchSync(true)
            setAutoLeaveSync(true)
        else
            setAutoFarmSync(false)
            setAutoCatchSync(false)
            setAutoLeaveSync(false)
        end
        validateConflicts("CatchShinyOnly")
    end
})

shinyPrisToggle_ref = shinyTab:AddToggle({
    Name = "Catch Shiny & Prismatic",
    Default = false,
    Callback = function(v)
        S.CatchShinyPris = v
        if v then
            setAutoFarmSync(true)
            setAutoCatchSync(true)
            setAutoLeaveSync(false)
        else
            S.PrisReady = false
            setAutoFarmSync(false)
            setAutoCatchSync(false)
            setAutoLeaveSync(false)
        end
        validateConflicts("CatchShinyPris")
    end
})

shinyTab:AddDivider()

shinyTab:AddLabel({Text = "Auto Stop Catch"})

shinyTab:AddToggle({
    Name = "Auto Stop on Shiny",
    Default = false,
    Callback = function(v)
        S_AutoStopShiny = v
        if v and S.CatchShinyOnly then
            S.CatchShinyOnly = false
            if shinyOnlyToggle_ref then
                pcall(function() shinyOnlyToggle_ref:SetValue(false) end)
            end
        end
    end
})

shinyTab:AddToggle({
    Name = "Auto Stop on Prismatic",
    Default = false,
    Callback = function(v)
        S_AutoStopPrismatic = v
        if v and S.CatchShinyPris then
            S.CatchShinyPris = false
            if shinyPrisToggle_ref then
                pcall(function() shinyPrisToggle_ref:SetValue(false) end)
            end
        end
    end
})

shinyTab:AddDivider()

shinyTab:AddLabel({Text = "Ball on Detect"})

local BALL_OPTIONS = { "None", "King Ball", "Advanced Ball", "Prismatic Ball" }

local function applyBallSelection(v)
    S.AutoKingBall  = (v == "King Ball")
    S.AutoAdvBall   = (v == "Advanced Ball")
    S.AutoPrismBall = (v == "Prismatic Ball")
    if v ~= "None" and S.NoBall then
        S.NoBall = false
        if noBallToggle then pcall(function() noBallToggle:SetValue(false) end) end
        Library:Notify({
            Title = "⚠️ Konflik Toggle",
            Description = "No Ball dimatiin — ball dipilih dari dropdown.",
            Duration = 3
        })
    end
end

local function applyPrisBallSelection(v)
    S.PrisAutoKingBall  = (v == "King Ball")
    S.PrisAutoAdvBall   = (v == "Advanced Ball")
    S.PrisAutoPrismBall = (v == "Prismatic Ball")
    if v ~= "None" and S.NoBall then
        S.NoBall = false
        if noBallToggle then pcall(function() noBallToggle:SetValue(false) end) end
        Library:Notify({
            Title = "⚠️ Konflik Toggle",
            Description = "No Ball dimatiin — ball dipilih dari dropdown.",
            Duration = 3
        })
    end
end

ballDropdown = shinyTab:AddDropdown({
    Name = "Shiny Ball",
    Options = BALL_OPTIONS,
    Default = "None",
    Searchable = true,
    Callback = applyBallSelection
})

prisBallDropdown = shinyTab:AddDropdown({
    Name = "Prismatic Ball",
    Options = BALL_OPTIONS,
    Default = "None",
    Searchable = true,
    Callback = applyPrisBallSelection
})

shinyTab:AddDivider()

shinyTab:AddLabel({Text = "Pity Counter"})

local pityDisplayLbl = shinyTab:AddLabel({Text = "💎 Prismatic: —/—\n✨ Shiny: —/—"})

task.spawn(function()
    while task.wait(1) do
        if not S.Running then break end
        local cur, max  = getPityInfo()
        local prisText  = (cur and max) and string.format("💎 Prismatic: %d/%d%s", cur, max, cur>=(max-1) and " ⚠️" or "") or "💎 Prismatic: —/—"
        local sc, sm    = getShinyPityInfo()
        local shinyText = (sc and sm) and string.format("✨ Shiny: %d/%d%s", sc, sm, sc>=sm and " ⚠️" or "") or "✨ Shiny: —/—"
        pcall(function() pityDisplayLbl:SetText(prisText.."\n"..shinyText) end)
    end
end)

-- ==========================================
-- TAB: ESP
-- ==========================================
espTab:AddLabel({Text = "Player ESP"})

espTab:AddToggle({
    Name = "Player Highlight + Name + Distance",
    Default = false,
    Callback = function(v)
        S.PlayerESP = v
        for _, obj in pairs(S.ESPCache) do
            if obj.hl then obj.hl.Enabled = v end
            if obj.bb then obj.bb.Enabled = v end
        end
    end
})

espTab:AddLabel({Text = "Blue highlight + name + distance (meters) realtime."})

-- ==========================================
-- TAB: BOSS
-- ==========================================
bossTab:AddLabel({Text = "Boss Farm"})

bossTab:AddDropdown({
    Name = "Select Boss",
    Options = bossNames,
    Default = bossNames[1],
    Searchable = true,
    Callback = function(v) selBoss = bossMap[v] end
})

bossTab:AddButton({
    Name = "Enter Battle (1x)",
    Callback = function()
        if not selBoss then
            Library:Notify({ Title="Boss", Description="Select a boss first!", Duration=2 })
            return
        end
        if S_BossLoop then
            Library:Notify({ Title="Boss", Description="Turn off Loop for manual 1x.", Duration=2 })
            return
        end
        if not _G.NR_petUID then
            Library:Notify({ Title="Boss", Description="No Pet UID!", Duration=3 })
            return
        end
        task.spawn(function()
            Library:Notify({ Title="Boss", Description="Entering "..selBoss.name.."...", Duration=2 })
            local ok = doEnterBattle(selBoss)
            Library:Notify({ Title="Boss", Description=ok and (selBoss.name.." done!") or "Battle failed.", Duration=2 })
        end)
    end
})

bossTab:AddToggle({
    Name = "Auto Boss Battle",
    Default = false,
    Callback = function(v)
        S_BossLoop = v
        if v and not selBoss then selBoss = bossMap[bossNames[1]] end
    end
})

-- ==========================================
-- TAB: CHEST
-- ==========================================
chestTab:AddLabel({Text = "Chest Farm"})

chestTab:AddToggle({
    Name = "Auto Farm Chest",
    Default = false,
    Callback = function(v) S.ChestFarm = v end
})

chestTab:AddButton({
    Name = "Next Chest (Manual)",
    Callback = function()
        local rc  = workspace:FindFirstChild("RuntimeCache")
        local rcc = rc  and rc:FindFirstChild("RuntimeCacheClient")
        local dir = rcc and rcc:FindFirstChild("Chest")
        if not dir then
            Library:Notify({ Title="Chest", Description="No chest folder found.", Duration=2 })
            return
        end
        local list = {}
        for _, c in ipairs(dir:GetChildren()) do if c:IsA("Folder") or c:IsA("Model") then table.insert(list,c) end end
        if #list==0 then return end
        S.ChestIdx = S.ChestIdx+1
        if S.ChestIdx>#list then S.ChestIdx=1 end
        local bp   = list[S.ChestIdx]:FindFirstChildWhichIsA("BasePart", true)
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if bp and root then root.CFrame = bp.CFrame * CFrame.new(0,3,0) end
    end
})

chestTab:AddButton({
    Name = "Claim All Chests (Now)",
    Callback = function()
        task.spawn(function()
            Library:Notify({ Title="Chest", Description="Claiming all chests...", Duration=2 })
            local n = claimAllChests()
            Library:Notify({ Title="Chest", Description=string.format("Claimed %d chest(s)!", n), Duration=3 })
        end)
    end
})

chestTab:AddToggle({
    Name = "Auto Claim All Chests",
    Default = false,
    Callback = function(v) S_AutoChestClaim = v end
})

chestTab:AddInput({
    Name = "Claim Cycle Delay (s)",
    Default = "4",
    Placeholder = "1 - 30",
    Callback = function(text)
        local val = tonumber(text)
        if val then CHEST_CLAIM_CYCLE = val end
    end
})

-- ==========================================
-- TAB: TELEPORT
-- ==========================================
teleportTab:AddLabel({Text = "Teleport to Player"})

teleportTab:AddDropdown({
    Name = "Select Player",
    Options = {},
    Default = nil,
    Searchable = true,
    Callback = function(v) selPlayer = v end,
    OptionsProvider = function()
        local names = {}
        for _, p in ipairs(Svc.Players:GetPlayers()) do if p~=plr then table.insert(names,p.Name) end end
        if #names==0 then table.insert(names,"(No players)") end
        return names
    end
})

teleportTab:AddButton({
    Name = "Teleport to Player",
    Callback = function()
        if not selPlayer or selPlayer=="(No players)" then
            Library:Notify({ Title="Teleport", Description="No player selected!", Duration=2 })
            return
        end
        local tgt  = Svc.Players:FindFirstChild(selPlayer)
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if tgt and root then
            local tc = tgt.Character
            local tr = tc and tc:FindFirstChild("HumanoidRootPart")
            if tr then
                root.CFrame = tr.CFrame * CFrame.new(0,0,3)
                Library:Notify({ Title="Teleport", Description="Teleported to "..selPlayer, Duration=2 })
            end
        end
    end
})

teleportTab:AddDivider()

teleportTab:AddLabel({Text = "Teleport to Island"})

local IslandConfig = (function()
    local ok, cfg = pcall(function()
        return require(game:GetService("ReplicatedStorage"):WaitForChild("Config"):WaitForChild("IslandConfig"))
    end)
    if ok and type(cfg)=="table" then return cfg end
end)()

local islandFolder = workspace:FindFirstChild("Scene") and workspace.Scene:FindFirstChild("Island")
islandDisplayNames   = {}
islandAssetByDisplay = {}

if islandFolder then
    for _, entry in ipairs(IslandConfig) do
        if entry.displayName and entry.assetName then
            if islandFolder:FindFirstChild(entry.assetName) then
                table.insert(islandDisplayNames, entry.displayName)
                islandAssetByDisplay[entry.displayName] = entry.assetName
            end
        end
    end
end

local selIsland = islandDisplayNames[1] or nil

if #islandDisplayNames==0 then
    teleportTab:AddLabel({Text = "⚠️ No islands found in scene."})
else
    teleportTab:AddDropdown({
        Name = "Select Island",
        Options = islandDisplayNames,
        Default = islandDisplayNames[1],
        Searchable = true,
        Callback = function(v) selIsland = v end
    })
    
    teleportTab:AddButton({
        Name = "Teleport to Island",
        Callback = function()
            if not selIsland then
                Library:Notify({ Title="Island TP", Description="Select an island first!", Duration=2 })
                return
            end
            local assetName = islandAssetByDisplay[selIsland]
            if not assetName then
                Library:Notify({ Title="Island TP", Description="Asset not mapped: "..selIsland, Duration=3 })
                return
            end
            local folder = workspace:FindFirstChild("Scene") and workspace.Scene:FindFirstChild("Island")
            if not folder then
                Library:Notify({ Title="Island TP", Description="workspace.Scene.Island missing.", Duration=3 })
                return
            end
            local targetModel = folder:FindFirstChild(assetName)
            if not targetModel then
                Library:Notify({ Title="Island TP", Description=assetName.." unloaded — rejoin.", Duration=4 })
                return
            end
            local landPart = targetModel:FindFirstChildWhichIsA("BasePart", true)
            if not landPart then
                Library:Notify({ Title="Island TP", Description="No BasePart in "..assetName, Duration=2 })
                return
            end
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then
                Library:Notify({ Title="Island TP", Description="Character not ready.", Duration=2 })
                return
            end
            root.CFrame = CFrame.new(landPart.Position + Vector3.new(0,5,0))
            Library:Notify({ Title="Island TP", Description="Teleported to "..selIsland.." ("..assetName..")", Duration=3 })
        end
    })
    
    teleportTab:AddLabel({Text = string.format("%d island(s) available.", #islandDisplayNames)})
end

-- ==========================================
-- TAB: REWARDS
-- ==========================================
rewardsTab:AddLabel({Text = "Claim Rewards"})

rewardsTab:AddButton({
    Name = "Claim All Daily Quest",
    Callback = function()
        local remote = game:GetService("ReplicatedStorage")
            :WaitForChild("Remote"):WaitForChild("Task"):WaitForChild("ReqCompleteTask")
        local claimed = 0
        for i = 1, 8 do
            local taskId = 2000000 + (i * 1000) + 1
            local ok, err = pcall(function() remote:InvokeServer(taskId) end)
            if ok then claimed += 1 end
            task.wait(0.2)
        end
        Library:Notify({ Title="Daily Quest", Description=string.format("Claimed %d/8 quest(s)!", claimed), Duration=3 })
    end
})

rewardsTab:AddButton({
    Name = "Claim All Achievement",
    Callback = function()
        local remote = game:GetService("ReplicatedStorage")
            :WaitForChild("Remote"):WaitForChild("Task"):WaitForChild("ReqCompleteTask")
        local claimed = 0
        for i = 1, 28 do
            local achieveId = 4000000 + (i * 1000) + 1
            local ok, err = pcall(function() remote:InvokeServer(achieveId) end)
            if ok then claimed += 1 end
            task.wait(0.2)
        end
        Library:Notify({ Title="Achievement", Description=string.format("Claimed %d/28 achievement(s)!", claimed), Duration=3 })
    end
})

rewardsTab:AddButton({
    Name = "Claim All BattlePass",
    Callback = function()
        local remote = game:GetService("ReplicatedStorage")
            :WaitForChild("Remote"):WaitForChild("BattlePass"):WaitForChild("ReqClaimBattlePassReward")
        local claimed = 0
        local TOTAL_TIERS = 50
        for i = 1, TOTAL_TIERS do
            local rewardId = 1000000 + i
            local ok, err = pcall(function() remote:InvokeServer(rewardId) end)
            if ok then claimed += 1 end
            task.wait(0.2)
        end
        Library:Notify({ Title="Battle Pass", Description=string.format("Claimed %d/%d reward(s)!", claimed, TOTAL_TIERS), Duration=3 })
    end
})

rewardsTab:AddButton({
    Name = "Claim All LevelReward",
    Callback = function()
        local remote = game:GetService("ReplicatedStorage")
            :WaitForChild("Remote"):WaitForChild("PlayerLevelReward"):WaitForChild("ReqClaimPlayerLevelReward")
        local claimed = 0
        for i = 1, 70 do
            local ok, err = pcall(function() remote:InvokeServer(i) end)
            if ok then claimed += 1 end
            task.wait(0.2)
        end
        Library:Notify({ Title="Level Reward", Description=string.format("Claimed %d/70 reward(s)!", claimed), Duration=3 })
    end
})

-- ==========================================
-- TAB: MISC
-- ==========================================
miscTab:AddLabel({Text = "Player"})

miscTab:AddToggle({
    Name = "Anti AFK",
    Default = false,
    Callback = function(v) setAntiAFK(v) end
})

miscTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(v) setInfiniteJump(v) end
})

miscTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(v) setNoclip(v) end
})

miscTab:AddToggle({
    Name = "WalkSpeed Override",
    Default = false,
    Callback = function(v)
        MiscS.SpeedEnabled = v
        if v then applySpeed(MiscS.SpeedValue) else applySpeed(16) end
    end
})

miscTab:AddInput({
    Name = "WalkSpeed",
    Default = "16",
    Placeholder = "2 - 500",
    Callback = function(text)
        local val = tonumber(text)
        if val then
            MiscS.SpeedValue = val
            if MiscS.SpeedEnabled then applySpeed(val) end
        end
    end
})

miscTab:AddToggle({
    Name = "JumpPower Override",
    Default = false,
    Callback = function(v)
        MiscS.JumpEnabled = v
        if v then applyJump(MiscS.JumpValue) else applyJump(50) end
    end
})

miscTab:AddInput({
    Name = "JumpPower",
    Default = "50",
    Placeholder = "10 - 500",
    Callback = function(text)
        local val = tonumber(text)
        if val then
            MiscS.JumpValue = val
            if MiscS.JumpEnabled then applyJump(val) end
        end
    end
})

miscTab:AddToggle({
    Name = "Custom Gravity",
    Default = false,
    Callback = function(v)
        MiscS.GravityEnabled = v
        if v then applyGravity(MiscS.GravityValue) else applyGravity(196.2) end
    end
})

miscTab:AddInput({
    Name = "Gravity",
    Default = "196",
    Placeholder = "0 - 500",
    Callback = function(text)
        local val = tonumber(text)
        if val then
            MiscS.GravityValue = val
            if MiscS.GravityEnabled then applyGravity(val) end
        end
    end
})

miscTab:AddDivider()

miscTab:AddLabel({Text = "World"})

miscTab:AddToggle({
    Name = "Fullbright",
    Default = false,
    Callback = function(v) setFullBright(v) end
})

miscTab:AddToggle({
    Name = "No Fog",
    Default = false,
    Callback = function(v)
        MiscS.FogEnabled = v
        if v then applyFog(1e9) else applyFog(_origLighting.FogEnd) end
    end
})

miscTab:AddToggle({
    Name = "Time of Day Override",
    Default = false,
    Callback = function(v)
        MiscS.TimeEnabled = v
        if not v then applyTime(_origLighting.ClockTime) end
    end
})

miscTab:AddInput({
    Name = "Clock Time (0–24)",
    Default = "14",
    Placeholder = "0 - 24",
    Callback = function(text)
        local val = tonumber(text)
        if val then
            MiscS.TimeValue = val
            if MiscS.TimeEnabled then applyTime(val) end
        end
    end
})

miscTab:AddDivider()

miscTab:AddLabel({Text = "Anti Lag"})

miscTab:AddToggle({
    Name = "Anti Lag (Preset — all below)",
    Default = false,
    Callback = function(v) applyAntiLagPreset(v) end
})

miscTab:AddToggle({
    Name = "Kill Shadows",
    Default = false,
    Callback = function(v) setShadows(v) end
})

miscTab:AddToggle({
    Name = "Kill Particles / Fire / Smoke",
    Default = false,
    Callback = function(v) killParticles(v) end
})

miscTab:AddToggle({
    Name = "Low Textures + Mesh LOD",
    Default = false,
    Callback = function(v) setLowTextures(v) end
})

miscTab:AddToggle({
    Name = "Frame Rate Cap",
    Default = false,
    Callback = function(v)
        AntiLagS.FPSCapEnabled = v
        setFPSCap(v, AntiLagS.FPSCapValue)
    end
})

miscTab:AddInput({
    Name = "FPS Cap Value",
    Default = "60",
    Placeholder = "15 - 240",
    Callback = function(text)
        local val = tonumber(text)
        if val then
            AntiLagS.FPSCapValue = val
            if AntiLagS.FPSCapEnabled then setFPSCap(true, val) end
        end
    end
})

miscTab:AddDivider()

miscTab:AddLabel({Text = "Session"})

miscTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        Library:Notify({ Title="Session", Description="Rejoining...", Duration=2 })
        task.wait(1)
        Svc.Teleport:Teleport(game.PlaceId, plr)
    end
})

miscTab:AddButton({
    Name = "Server Hop",
    Callback = function()
        Library:Notify({ Title="Session", Description="Looking for server...", Duration=2 })
        task.spawn(function()
            pcall(function()
                local servers = {}
                for _, v in ipairs(game:GetService("TeleportService"):GetServerList()) do
                    table.insert(servers, v)
                end
                if #servers > 0 then
                    local target = servers[math.random(1, #servers)]
                    Svc.Teleport:TeleportToServerInstance(game.PlaceId, target)
                end
            end)
        end)
    end
})

miscTab:AddButton({
    Name = "Copy UserID",
    Callback = function()
        pcall(function() setclipboard(tostring(plr.UserId)) end)
        Library:Notify({ Title="Misc", Description="UserID copied: "..plr.UserId, Duration=2 })
    end
})

miscTab:AddButton({
    Name = "Copy PlaceID",
    Callback = function()
        pcall(function() setclipboard(tostring(game.PlaceId)) end)
        Library:Notify({ Title="Misc", Description="PlaceID copied: "..game.PlaceId, Duration=2 })
    end
})

-- ==========================================
-- TAB: UI SETTINGS
-- ==========================================
uiSettingsTab:AddLabel({Text = "Menu"})

uiSettingsTab:AddToggle({
    Name = "Custom Cursor",
    Default = true,
    Callback = function(v) Library.ShowCustomCursor = v end
})

uiSettingsTab:AddDropdown({
    Name = "Notification Side",
    Options = {"Left","Right"},
    Default = "Right",
    Searchable = true,
    Callback = function(v) Library:SetNotifySide(v) end
})

uiSettingsTab:AddDropdown({
    Name = "DPI Scale",
    Options = {"50%","75%","85%","100%","125%","150%"},
    Default = "85%",
    Searchable = true,
    Callback = function(v)
        v = v:gsub("%%","")
        Library:SetDPIScale(tonumber(v))
    end
})

uiSettingsTab:AddToggle({
    Name = "Glow AccentBar",
    Default = true,
    Callback = function(v) Window:SetHeaderGlow(v) end
})

uiSettingsTab:AddToggle({
    Name = "Show Profile",
    Default = true,
    Callback = function(v) Window:SetProfileVisible(v) end
})

uiSettingsTab:AddDivider()

uiSettingsTab:AddLabel({Text = "Menu bind"})

uiSettingsTab:AddButton({
    Name = "Unload script",
    Callback = function() Library:Unload() end
})

-- ==========================================
-- INIT NOTIFICATION
-- ==========================================
Library:Notify({
    Title = "Wisnu Hub Evomon v3",
    Description = "Loaded! RightShift to toggle.",
    Duration = 4
})

print("⚡ J4rzz Evomon v3 — Oxidelib UI Loaded!")
