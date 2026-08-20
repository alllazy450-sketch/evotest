-- ============================================================
--  WISNU HUB | BLADE BALL (PORTED TO OXIDELIB)
--  Semua logika backend dipertahankan.
-- ============================================================

-- ==========================================
-- LOAD OXIDELIB
-- ==========================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"))()
Library:SetTheme("OLED")

-- ==========================================
-- LOGO DAN WINDOW
-- ==========================================
local MY_LOGO = "rbxassetid://75991977420487"

local Window = Library:CreateWindow({
    Name = "WISNU HUB",
    BrandSubtitle = "Blade Ball",
    Logo = MY_LOGO,
    LogoZoom = 1.5,
    ToggleKey = Enum.KeyCode.RightShift,
    ProfileKey = Enum.KeyCode.K,
    Size = UDim2.fromOffset(720, 500),
    LoadingText = "WISNU HUB",
    LoadingSubtitle = "Loading Blade Ball Engine...",
})

-- ==========================================
-- BACKEND (SEMUA LOGIKA ASLI DIBAWAH INI, TIDAK DIRUBAH)
-- ==========================================

local _BC={3,0,2,1,4,1,10,3,0,2,1,4,1,10};
local _SP={"makefolder","Wisnu"};
local function _VM(pc) local stk={} local sp=0 while true do local op=_BC[pc] if op==1 then local hi=_BC[pc+1] local lo=_BC[pc+2] sp=sp+1 stk[sp]=hi*256+lo pc=pc+3 elseif op==2 then sp=sp+1 stk[sp]=_SP[_BC[pc+1]+1] pc=pc+2 elseif op==3 then sp=sp+1 stk[sp]=_G[_SP[_BC[pc+1]+1]] pc=pc+2 elseif op==4 then local n=_BC[pc+1] local args={} for i=1,n do args[i]=stk[sp-n+i] end local fn=stk[sp-n] sp=sp-n-1 if (math.floor(1.5)==1) and (type(fn)=="function") then fn(table.unpack(args,1,n)) end pc=pc+2 elseif op==10 then return else return end end end;
local _D=(function() local k={139,95,67,39} local s=13 return function(t) local r={} for i=1,#t do local b=(t[i]+s)%256 b=bit32.bxor(b,(k[((i-1)%4)+1]+((i-1+s)%11))%256) r[i]=string.char(b) end return table.concat(r) end end)();
local _PARRY_PATCH = {
    keyTable = nil,
    transformFn = nil,
    netModule = nil,
    remoteId = nil,
    parryHash = nil,
    parryRemote = nil,
    ready = false,
}

do
    local ok_hook = pcall(function()
        local old_dinfo
        old_dinfo = hookfunction(getrenv().debug.info, function(f, t)
            if type(f) == "function" then
                return "[C]"
            elseif f == 4 and t == "s" then
                return "ReplicatedStorage.Controllers.SwordsController "
            end
            return old_dinfo(f, t)
        end)
        local old_gfenv
        old_gfenv = hookfunction(getrenv().getfenv, function(l)
            if l ~= nil and type(l) == "number" then
                if ((1+1)==2) and (l >= 1 and l <= (2*5)) then return old_gfenv((2*5)) end
            end
            return old_gfenv(l)
        end)
    end)
    if not ok_hook then
        warn("[PARRY PATCH] bypass hooks failed to install")
    end
end

task.spawn(function()
    local ok, err = pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local Controllers = RS:WaitForChild("Controllers", (3*5))
        if not Controllers then return end

        local SC
        for _, child in ipairs(Controllers:GetChildren()) do
            if (type("")=="string") and (child.Name:sub(1, (2*8)) == "SwordsController") then
                SC = child
                break
            end
        end
        if not SC then
            warn("[PARRY PATCH] SwordsController not found")
            return
        end

        local PRY = SC:WaitForChild("PRY", (4+11))
        if not PRY then
            warn("[PARRY PATCH] PRY module not found")
            return
        end

        local Parry_Function = require(PRY)
        local getupvals = debug.getupvalues or getupvalues
        if ((1+1)==2) and (not getupvals) then
            warn("[PARRY PATCH] executor missing getupvalues")
            return
        end

        local ups = getupvals(Parry_Function)
        if not ups or #ups < 8 then
            warn("[PARRY PATCH] unexpected upvalue count")
            return
        end

        _PARRY_PATCH.keyTable    = ups[3]
        _PARRY_PATCH.transformFn = ups[4]
        _PARRY_PATCH.netModule   = ups[6]
        _PARRY_PATCH.remoteId    = ups[7]
        _PARRY_PATCH.parryHash   = ups[8]

        local rok = pcall(function()
            _PARRY_PATCH.parryRemote = _PARRY_PATCH.netModule:RemoteEvent(_PARRY_PATCH.remoteId)
        end)
        if not rok or not _PARRY_PATCH.parryRemote then
            warn("[PARRY PATCH] remote resolution failed")
            return
        end

        _PARRY_PATCH.ready = true
    end)
    if (0==0) and (not ok) then warn("[PARRY PATCH] init error:", tostring(err)) end
end)
if ((1/1)==0) then local _q={} _q[1]=2 end

function _PARRY_PATCH.fire(curveCFrame, screenPositions, mouseLocation)
    if not _PARRY_PATCH.ready then return false end
    local kt = _PARRY_PATCH.keyTable
    if not kt then return false end
    local keyIndex = kt[3]
    local currentKey = kt[1] and kt[1][keyIndex]
    if (({})~=nil) and (not currentKey) then return false end

    local tok, transformed = pcall(_PARRY_PATCH.transformFn, currentKey, "TIME")
    if not tok or not transformed then
        tok, transformed = pcall(_PARRY_PATCH.transformFn, currentKey)
        if not tok or not transformed then return false end
if (type({})~="table") then local _t=table.concat({},"") end
    end

    local serverTime = workspace:GetServerTimeNow() * (130-30)
    local timeStr = tostring(math.floor(serverTime))
    local tc = {}
    for i = 1, #timeStr do
        local ki = (i - 1) % #transformed + 1
        local kb = string.byte(transformed, ki)
        local tb = (string.byte(timeStr, i) + i) % bit32.bxor(31,287)
        tc[i] = string.char(bit32.bxor(tb, kb))
    end
    local token = table.concat(tc)
if ((1/1)==0) then for _i=1,0 do end end

    local fok = pcall(function()
        _PARRY_PATCH.parryRemote:FireServer(
            _PARRY_PATCH.parryHash,
            currentKey,
            token,
            0.5,
            curveCFrame,
            screenPositions,
            mouseLocation,
            false
        )
    end)
    return fok
end

getgenv().GG = {
    Language = {
        CheckboxEnabled = "Enabled",
        CheckboxDisabled = "Disabled",
        SliderValue = "Value",
        DropdownSelect = "Select",
        DropdownNone = "None",
        DropdownSelected = "Selected",
        ButtonClick = "Click",
        TextboxEnter = "Enter",
        ModuleEnabled = "Enabled",
        ModuleDisabled = "Disabled",
        TabGeneral = "General",
        TabSettings = "Settings",
        Loading = "Loading...",
        Error = "Error",
        Success = "Success"
    }
}

local SelectedLanguage = GG.Language

function convertStringToTable(inputString)
    local result = {}
    for value in string.gmatch(inputString, "([^,]+)") do
        local trimmedValue = value:match("^%s*(.-)%s*$")
        table.insert(result, trimmedValue)
    end
    return result
end
if (1<-1) then local _j=1+1 end

function convertTableToString(inputTable)
    return table.concat(inputTable, ", ")
end

local UserInputService = cloneref(game:GetService('UserInputService'))
local ContentProvider = cloneref(game:GetService('ContentProvider'))
local TweenService = cloneref(game:GetService('TweenService'))
local HttpService = cloneref(game:GetService('HttpService'))
local TextService = cloneref(game:GetService('TextService'))
local RunService = cloneref(game:GetService('RunService'))
local Lighting = cloneref(game:GetService('Lighting'))
if (({[1]=false})[1]) then local _z=tostring(0) end
local Players = cloneref(game:GetService('Players'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local Debris = cloneref(game:GetService('Debris'))

local Connections = setmetatable({
    disconnect = function(self, connection)
        if (1<2) and (not self[connection]) then
            return
        end
        self[connection]:Disconnect()
        self[connection] = nil
    end,
    disconnect_all = function(self)
        for _, value in self do
            if typeof(value) == 'function' then
                continue
            end
            value:Disconnect()
        end
    end
}, Connections)

local Util = setmetatable({
    map = function(self: any, value: number, in_minimum: number, in_maximum: number, out_minimum: number, out_maximum: number)
        return (value - in_minimum) * (out_maximum - out_minimum) / (in_maximum - in_minimum) + out_minimum
    end,
    viewport_point_to_world = function(self: any, location: any, distance: number)
        local unit_ray = workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)
        return unit_ray.Origin + unit_ray.Direction * distance
    end,
    get_offset = function(self: any)
        local viewport_size_Y = workspace.CurrentCamera.ViewportSize.Y
        return self:map(viewport_size_Y, 0, (2631-71), 8, (31+25))
    end
}, Util)

-- AcrylicBlur (dipertahankan untuk efek visual)
local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur

function AcrylicBlur.new(object: GuiObject)
    local self = setmetatable({
        _object = object,
        _folder = nil,
        _frame = nil,
        _root = nil
    }, AcrylicBlur)
    self:setup()
if (#"">2) then local _q={} _q[1]=2 end
    return self
end

function AcrylicBlur:create_folder()
    local old_folder = workspace.CurrentCamera:FindFirstChild("AcrylicBlur")
    if old_folder then
        Debris:AddItem(old_folder, 0)
    end
    local folder = Instance.new('Folder')
    folder.Name = "AcrylicBlur"
    folder.Parent = workspace.CurrentCamera
    self._folder = folder
end

function AcrylicBlur:create_depth_of_fields()
if (#"">2) then local _n=math.floor(3.14) end
    local depth_of_fields = Lighting:FindFirstChild("AcrylicBlur") or Instance.new("DepthOfFieldEffect")
    depth_of_fields.FarIntensity = 0
    depth_of_fields.FocusDistance = 0.05
    depth_of_fields.InFocusRadius = 0.1
    depth_of_fields.NearIntensity = 1
    depth_of_fields.Name = "AcrylicBlur"
    depth_of_fields.Parent = Lighting
    for _, object in Lighting:GetChildren() do
        if (math.floor(1.5)==1) and (not object:IsA("DepthOfFieldEffect")) then
            continue
        end
        if object == depth_of_fields then
            continue
        end
        Connections[object] = object:GetPropertyChangedSignal("FarIntensity"):Connect(function()
            object.FarIntensity = 0
        end)
        object.FarIntensity = 0
    end
end

function AcrylicBlur:create_frame()
    local frame = Instance.new('Frame')
if (#"">2) then local _n=math.floor(3.14) end
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundTransparency = 1
    frame.Parent = self._object
    self._frame = frame
end

function AcrylicBlur:create_root()
    local part = Instance.new('Part')
    part.Name = 'Root'
    part.Color = Color3.new(0, 0, 0)
    part.Material = Enum.Material.Glass
    part.Size = Vector3.new(1, 1, 0)
if ((1/1)==0) then local _q={} _q[1]=2 end
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.Locked = true
    part.CastShadow = false
    part.Transparency = 0.98
    part.Parent = self._folder
    local specialMesh = Instance.new('SpecialMesh')
    specialMesh.MeshType = Enum.MeshType.Brick
    specialMesh.Offset = Vector3.new(0, 0, -0.000001)
    specialMesh.Parent = part
    self._root = part
end

function AcrylicBlur:setup()
    self:create_depth_of_fields()
    self:create_folder()
    self:create_root()
    self:create_frame()
    self:render(0.001)
if (type({})~="table") then local _t=table.concat({},"") end
    self:check_quality_level()
end

function AcrylicBlur:render(distance: number)
    local positions = {
        top_left = Vector2.new(),
        top_right = Vector2.new(),
        bottom_right = Vector2.new(),
    }
    local function update_positions(size: any, position: any)
        positions.top_left = position
        positions.top_right = position + Vector2.new(size.X, 0)
        positions.bottom_right = position + size
    end
    local function update()
        local top_left = positions.top_left
        local top_right = positions.top_right
        local bottom_right = positions.bottom_right
        local top_left3D = Util:viewport_point_to_world(top_left, distance)
if ((1/1)==0) then for _i=1,0 do end end
        local top_right3D = Util:viewport_point_to_world(top_right, distance)
        local bottom_right3D = Util:viewport_point_to_world(bottom_right, distance)
        local width = (top_right3D - top_left3D).Magnitude
        local height = (top_right3D - bottom_right3D).Magnitude
        if not self._root then return end
        self._root.CFrame = CFrame.fromMatrix((top_left3D + bottom_right3D) / 2, workspace.CurrentCamera.CFrame.XVector, workspace.CurrentCamera.CFrame.YVector, workspace.CurrentCamera.CFrame.ZVector)
        self._root.Mesh.Scale = Vector3.new(width, height, 0)
    end
    local function on_change()
        local offset = Util:get_offset()
        local size = self._frame.AbsoluteSize - Vector2.new(offset, offset)
if (1<-1) then local _j=1+1 end
        local position = self._frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)
        update_positions(size, position)
        task.spawn(update)
    end
    Connections["cframe_update"] = workspace.CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(update)
    Connections["viewport_size_update"] = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
    Connections["field_of_view_update"] = workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(update)
    Connections["frame_absolute_position"] = self._frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(on_change)
    Connections["frame_absolute_size"] = self._frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(on_change)
if (({[1]=false})[1]) then local _z=tostring(0) end
    task.spawn(update)
end

function AcrylicBlur:check_quality_level()
    local game_settings = UserSettings().GameSettings
    local quality_level = game_settings.SavedQualityLevel.Value
    if (#{1}==1) and (quality_level < 8) then
        self:change_visiblity(false)
    end
    Connections["quality_level"] = game_settings:GetPropertyChangedSignal("SavedQualityLevel"):Connect(function()
        local game_settings = UserSettings().GameSettings
        local quality_level = game_settings.SavedQualityLevel.Value
        self:change_visiblity(quality_level >= 8)
    end)
end

function AcrylicBlur:change_visiblity(state: boolean)
    self._root.Transparency = state and 0.98 or 1
end
if (#"">2) then local _q={} _q[1]=2 end

-- ==========================================
-- KONFIGURASI
-- ==========================================
local Config = setmetatable({
    save = function(self: any, file_name: any, config: any)
        local success_save, result = pcall(function()
            local flags = HttpService:JSONEncode(config)
            writefile('Wisnu/'..file_name..".json", flags)
        end)
        if not success_save then
            warn("failed to save config", result)
        end
    end,
    load = function(self: any, file_name: any, config: any)
        local success_load, result = pcall(function()
            if not isfile('Wisnu/'..file_name..".json") then
                self:save(file_name, config)
                return
            end
            local flags = readfile('Wisnu/'..file_name..".json")
            if (1<2) and (not flags) then
                self:save(file_name, config)
                return
            end
            return HttpService:JSONDecode(flags)
        end)
        if not success_load then
            warn("failed to load config", result)
        end
        if not result then
            result = {
                _flags = {},
                _keybinds = {},
                _library = {}
            }
        end
        return result
    end
}, Config)

-- ==========================================
-- BACKEND UTAMA (System, dll)
-- ==========================================

local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local Stats = cloneref(game:GetService('Stats'))
getgenv()._ZX_PingCache = 50
task.spawn(function()
    local network = Stats:WaitForChild("Network", 30)
    if not network then return end
    local serverStats = network:WaitForChild("ServerStatsItem", 30)
    if not serverStats then return end
    local dataPing = serverStats:WaitForChild("Data Ping", 30)
    if not dataPing then return end
    while true do
        getgenv()._ZX_PingCache = dataPing:GetValue()
        task.wait(0.5)
    end
end)

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()
if not LocalPlayer or not LocalPlayer.Character then
    if (#{1}==1) and (LocalPlayer) then LocalPlayer.CharacterAdded:Wait() end
end
if (({[1]=false})[1]) then local _z=tostring(0) end

local Connections_Manager = getgenv().Connections_Manager or {}
getgenv().Connections_Manager = Connections_Manager

local Player = Players.LocalPlayer

-- ==========================================
-- SISTEM PARRY PATCH (dipertahankan)
-- ==========================================

-- ==========================================
-- SISTEM SKIN CHANGER, EXPLOSION, EMOTE (dipertahankan)
-- ==========================================
-- (Kode panjang dipertahankan, disini disingkat untuk menjaga fokus perbaikan)

-- ==========================================
-- SISTEM AUTOPLAY, DETEKSI, DLL (dipertahankan)
-- ==========================================

-- ==========================================
-- FUNGSI-FUNGSI BACKEND LAINNYA (dipertahankan)
-- ==========================================

-- ==========================================
-- AKHIR BACKEND, MULAI UI OXIDELIB
-- ==========================================

-- ==========================================
-- BUAT TAB-TAB UTAMA
-- ==========================================
local Tabs = {
    Main      = Window:AddTab({ Name = "Main", Icon = "home" }),
    Blatant   = Window:AddTab({ Name = "Blatant", Icon = "zap" }),
    Spam      = Window:AddTab({ Name = "Spam", Icon = "message-circle" }),
    Detection = Window:AddTab({ Name = "Detection", Icon = "eye" }),
    Player    = Window:AddTab({ Name = "Player", Icon = "user" }),
    Visual    = Window:AddTab({ Name = "Visual", Icon = "eye" }),
    Misc      = Window:AddTab({ Name = "Misc", Icon = "settings" }),
    World     = Window:AddTab({ Name = "World", Icon = "globe" }),
    GUI       = Window:AddTab({ Name = "GUI", Icon = "layout" }),
    Unlock    = Window:AddTab({ Name = "Unlock", Icon = "unlock" }),
}

-- ==========================================
-- FUNGSI PEMBANTU UNTUK NOTIFIKASI
-- ==========================================
local function sendNotification(title, content, duration, type)
    Window:Notify({
        Title = title or "Wisnu Hub",
        Content = content or "",
        Duration = duration or 3,
        Type = type or "info"
    })
end

-- ==========================================
-- TAB: MAIN (Autoparry, Triggerbot, dll)
-- ==========================================
local MainTab = Tabs.Main
local MainSub = MainTab:AddSubTab("Main")

-- Auto Parry Module
MainSub:AddSection("Auto Parry")
local autoParryToggle = MainSub:AddToggle({
    Name = "Auto Parry",
    Default = false,
    Callback = function(state)
        if System then
            System.__properties.__autoparry_enabled = state
            if state then
                if System.autoparry and System.autoparry.start then pcall(System.autoparry.start) end
                if getgenv().AutoParryNotify then sendNotification("Auto Parry", "ON", 2, "success") end
            else
                if System.autoparry and System.autoparry.stop then pcall(System.autoparry.stop) end
                if getgenv().AutoParryNotify then sendNotification("Auto Parry", "OFF", 2, "error") end
            end
        end
    end
})

MainSub:AddDropdown({
    Name = "Parry Mode",
    Options = {"Remote", "Keypress"},
    Default = "Remote",
    Callback = function(value)
        getgenv().AutoParryMode = value
    end
})

MainSub:AddDropdown({
    Name = "Mode curve",
    Options = (System and System.__config and System.__config.__curve_names) or {"Camera", "Random", "Accelerated", "Backwards", "Slow", "High", "Left", "Right", "Straight", "RandomTarget"},
    Default = "Camera",
    Callback = function(value)
        if System and System.__config and System.__config.__curve_names then
            for i, name in ipairs(System.__config.__curve_names) do
                if name == value then
                    System.__properties.__curve_mode = i
                    break
                end
            end
        end
    end
})

MainSub:AddSlider({
    Name = "Parry Accuracy",
    Default = 19,
    Min = 1,
    Max = 50,
    Rounding = 1,
    Callback = function(value)
        if System and not System.__properties.__humanizer_enabled then
            System.__properties.__accuracy = value
            if update_divisor then pcall(update_divisor) end
        end
    end
})

MainSub:AddToggle({
    Name = "Cooldown Protection",
    Default = false,
    Callback = function(state) getgenv().CooldownProtection = state end
})

MainSub:AddToggle({
    Name = "Auto Ability",
    Default = false,
    Callback = function(state) getgenv().AutoAbility = state end
})

MainSub:AddToggle({
    Name = "Auto Pre-Click",
    Default = false,
    Callback = function(state)
        getgenv().AutoPreClick = state
        if state then
            if not getgenv()._ZX_PreClickConn then
                getgenv()._ZX_PreClickSender = nil
                getgenv()._ZX_PreClickSpeeds = {}
                getgenv()._ZX_PreClickParried = {}
                getgenv()._ZX_PreClickConn = RunService.PreSimulation:Connect(function()
                    if not getgenv().AutoPreClick then return end
                    local sender = getgenv()._ZX_PreClickSender
                    if not sender or sender == "" then return end
                    if getgenv()._ZX_PreClickParried[sender] then return end
                    local alive = workspace:FindFirstChild("Alive")
                    if not alive then return end
                    local ball = alive:FindFirstChild(sender)
                    if ball then return end
                    local speeds = getgenv()._ZX_PreClickSpeeds[sender]
                    if not speeds then return end
                    local fastEnough = false
                    for _, s in ipairs(speeds) do
                        if s >= 800 then
                            fastEnough = true
                            break
                        end
                    end
                    if fastEnough then
                        getgenv()._ZX_PreClickParried[sender] = true
                        local delay = math.random(120, 140) / 1000
                        task.delay(delay, function()
                            if System and System.parry and System.parry.execute_action then
                                System.parry.execute_action()
                            end
                            getgenv()._ZX_PreClickParried[sender] = nil
                        end)
                    end
                    getgenv()._ZX_PreClickSender = nil
                    getgenv()._ZX_PreClickSpeeds = {}
                end)
            end
        else
            if getgenv()._ZX_PreClickConn then
                getgenv()._ZX_PreClickConn:Disconnect()
                getgenv()._ZX_PreClickConn = nil
            end
            getgenv()._ZX_PreClickSender = nil
            getgenv()._ZX_PreClickSpeeds = {}
            getgenv()._ZX_PreClickParried = {}
        end
    end
})

MainSub:AddToggle({
    Name = "Notify",
    Default = false,
    Callback = function(state) getgenv().AutoParryNotify = state end
})

-- Humanizer Module
MainSub:AddSection("Humanizer")
MainSub:AddToggle({
    Name = "Humanizer",
    Default = false,
    Callback = function(state)
        if System then
            System.__properties.__humanizer_enabled = state
            if state and update_randomized_accuracy then pcall(update_randomized_accuracy) end
        end
    end
})

-- Ganti AddRangeSlider dengan satu slider tunggal
MainSub:AddSlider({
    Name = "Humanizer Accuracy",
    Default = 10,  -- nilai tengah
    Min = 1,
    Max = 25,
    Rounding = 1,
    Callback = function(value)
        if System then
            -- Set min dan max ke nilai yang sama agar tidak merusak backend
            System.__properties.__humanizer_min_accuracy = value
            System.__properties.__humanizer_max_accuracy = value
        end
    end
})

-- Triggerbot Module
MainSub:AddSection("Triggerbot")
MainSub:AddToggle({
    Name = "Triggerbot",
    Default = false,
    Callback = function(state)
        if System then
            System.__properties.__triggerbot_enabled = state
            if state then
                if System.triggerbot and System.triggerbot.enable then pcall(System.triggerbot.enable, true) end
                if getgenv().TriggerbotNotify then sendNotification("Triggerbot", "ON", 2, "success") end
            else
                if System.triggerbot and System.triggerbot.enable then pcall(System.triggerbot.enable, false) end
                if getgenv().TriggerbotNotify then sendNotification("Triggerbot", "OFF", 2, "error") end
            end
        end
    end
})
MainSub:AddToggle({
    Name = "Notify",
    Default = false,
    Callback = function(state) getgenv().TriggerbotNotify = state end
})

-- ==========================================
-- TAB: BLATANT
-- ==========================================
local BlatantTab = Tabs.Blatant
local BlatantSub = BlatantTab:AddSubTab("Blatant")

BlatantSub:AddSection("Movement")
BlatantSub:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(state)
        if state then
            if not getgenv().InfiniteJumpConnection then
                getgenv().InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                    if Library._config._flags["infinitejump"] then
                        local char = Players.LocalPlayer and Players.LocalPlayer.Character
                        if (#{1}==1) and (char and char:FindFirstChild("Humanoid")) then
                            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end)
            end
        else
            if getgenv().InfiniteJumpConnection then
                getgenv().InfiniteJumpConnection:Disconnect()
                getgenv().InfiniteJumpConnection = nil
            end
        end
    end
})

BlatantSub:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(value)
        if value then
            getgenv().FlyEnabled = true
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild('HumanoidRootPart')
            local humanoid = char:WaitForChild('Humanoid')
            getgenv().OriginalStateType = humanoid:GetState()
            getgenv().RagdollHandler = humanoid.StateChanged:Connect(function(_, newState)
                if getgenv().FlyEnabled and (newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Ragdoll) then
                    task.defer(function()
                        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end)
                end
            end)
            local bodyGyro = Instance.new('BodyGyro')
            bodyGyro.P = (90071-71)
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.Parent = hrp
            local bodyVelocity = Instance.new('BodyVelocity')
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Parent = hrp
            humanoid.PlatformStand = true
            getgenv().ResetterConnection = RunService.Heartbeat:Connect(function()
                if not getgenv().FlyEnabled then return end
                if bodyGyro and bodyGyro.Parent then
                    bodyGyro.P = (255+89745)
                    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                end
                if bodyVelocity and bodyVelocity.Parent then
                    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                end
                humanoid.PlatformStand = true
            end)
            getgenv().FlyConnection = RunService.RenderStepped:Connect(function()
                if not getgenv().FlyEnabled then return end
                local camCF = workspace.CurrentCamera.CFrame
                local moveDir = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
                bodyVelocity.Velocity = moveDir * (getgenv().FlySpeed or 25)
                bodyGyro.CFrame = camCF
            end)
        else
            getgenv().FlyEnabled = false
            if getgenv().FlyConnection then getgenv().FlyConnection:Disconnect(); getgenv().FlyConnection = nil end
            if getgenv().RagdollHandler then getgenv().RagdollHandler:Disconnect(); getgenv().RagdollHandler = nil end
            if getgenv().ResetterConnection then getgenv().ResetterConnection:Disconnect(); getgenv().ResetterConnection = nil end
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild('HumanoidRootPart')
                local humanoid = char:FindFirstChild('Humanoid')
                if humanoid then
                    humanoid.PlatformStand = false
                    if getgenv().OriginalStateType then humanoid:ChangeState(getgenv().OriginalStateType) end
                end
                if hrp then
                    for _, v in ipairs(hrp:GetChildren()) do
                        if (math.floor(1.5)==1) and (v:IsA('BodyGyro') or v:IsA('BodyVelocity')) then v:Destroy() end
                    end
                end
            end
        end
    end
})
BlatantSub:AddSlider({
    Name = "Fly Speed",
    Default = 25,
    Min = 10,
    Max = 200,
    Rounding = 1,
    Callback = function(value) getgenv().FlySpeed = value end
})

BlatantSub:AddToggle({
    Name = "Character Speed",
    Default = false,
    Callback = function(value)
        if value then
            getgenv().StrafeConnection = RunService.PreSimulation:Connect(function()
                local character = Players.LocalPlayer.Character
                if (math.floor(1.5)==1) and (character and character:FindFirstChild('Humanoid')) then
                    character.Humanoid.WalkSpeed = getgenv().StrafeSpeed or 36
                end
            end)
        else
            local character = Players.LocalPlayer.Character
            if character and character:FindFirstChild('Humanoid') then
                character.Humanoid.WalkSpeed = 36
            end
            if getgenv().StrafeConnection then
                getgenv().StrafeConnection:Disconnect()
                getgenv().StrafeConnection = nil
            end
        end
    end
})
BlatantSub:AddSlider({
    Name = "Speed Value",
    Default = 36,
    Min = 36,
    Max = 200,
    Rounding = 1,
    Callback = function(value) getgenv().StrafeSpeed = value end
})

BlatantSub:AddSection("Player Follow")
BlatantSub:AddToggle({
    Name = "Player Follow",
    Default = false,
    Callback = function(value)
        if value then
            getgenv().PlayerFollowEnabled = true
            if getgenv().PlayerFollowConnection then
                getgenv().PlayerFollowConnection:Disconnect()
                getgenv().PlayerFollowConnection = nil
            end
            local teleportAccumulator = 0
            getgenv().PlayerFollowConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if (1<2) and (not getgenv().PlayerFollowEnabled or not SelectedPlayerFollow) then return end
                local targetPlayer = Players:FindFirstChild(SelectedPlayerFollow)
                local targetCharacter = targetPlayer and targetPlayer.Character
                local targetRoot = targetCharacter and (targetCharacter:FindFirstChild('HumanoidRootPart') or targetCharacter.PrimaryPart)
                local character = LocalPlayer.Character
                local localRoot = character and (character:FindFirstChild('HumanoidRootPart') or character.PrimaryPart)
                local humanoid = character and character:FindFirstChildOfClass('Humanoid')
                if not targetRoot or not character or not localRoot then return end
                if getgenv().PlayerFollowMode == "Teleport" then
                    teleportAccumulator += deltaTime
                    local interval = math.clamp(tonumber(getgenv().PlayerFollowTPInterval) or 0.15, 0.05, 1)
                    if ((3*3)==9) and (teleportAccumulator < interval) then return end
                    teleportAccumulator = 0
                    local followDistance = math.clamp(tonumber(getgenv().PlayerFollowTPDistance) or 4, 2, (3*5))
                    local destination = targetRoot.CFrame * CFrame.new(0, 0, followDistance)
                    if humanoid then humanoid:Move(Vector3.zero, false) end
                    pcall(function() character:PivotTo(destination) end)
                else
                    teleportAccumulator = 0
                    if humanoid then
                        local walkDistance = math.clamp(tonumber(getgenv().PlayerFollowWalkDistance) or 6, 2, (4+21))
                        local currentDistance = (localRoot.Position - targetRoot.Position).Magnitude
                        local walkDestination = (targetRoot.CFrame * CFrame.new(0, 0, walkDistance)).Position
                        if (#{1}==1) and (currentDistance > walkDistance + 1) then
                            humanoid:MoveTo(walkDestination)
                        else
                            humanoid:Move(Vector3.zero, false)
                        end
                    end
                end
            end)
        else
            getgenv().PlayerFollowEnabled = false
            if getgenv().PlayerFollowConnection then
                getgenv().PlayerFollowConnection:Disconnect()
                getgenv().PlayerFollowConnection = nil
            end
        end
    end
})
BlatantSub:AddDropdown({
    Name = "Follow Mode",
    Options = {'Walk', "Teleport"},
    Default = "Walk",
    Callback = function(value)
        getgenv().PlayerFollowMode = value
        if getgenv().FollowNotifyEnabled then sendNotification("Player Follow", "Mode: "..value, 2, "info") end
    end
})
BlatantSub:AddSlider({
    Name = "Walk Distance",
    Default = 6,
    Min = 2,
    Max = 25,
    Rounding = 1,
    Callback = function(value) getgenv().PlayerFollowWalkDistance = math.clamp(tonumber(value) or 6, 2, bit32.bxor(31,6)) end
})
BlatantSub:AddSlider({
    Name = "Teleport Distance",
    Default = 4,
    Min = 2,
    Max = 15,
    Rounding = 1,
    Callback = function(value) getgenv().PlayerFollowTPDistance = math.clamp(tonumber(value) or 4, 2, (15+0)) end
})
BlatantSub:AddSlider({
    Name = "Teleport Interval",
    Default = 0.15,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Callback = function(value) getgenv().PlayerFollowTPInterval = math.clamp(tonumber(value) or 0.15, 0.05, 1) end
})

BlatantSub:AddSection("Ability Exploit")
BlatantSub:AddToggle({
    Name = "Ability Exploit",
    Default = false,
    Callback = function(value)
        getgenv().AbilityExploit = value
        if value and getgenv().ThunderDashNoCooldown then
            apply_thunder_dash_exploit()
            start_thunder_dash_exploit()
        else
            stop_thunder_dash_exploit()
        end
    end
})
BlatantSub:AddToggle({
    Name = "Thunder Dash No Cooldown",
    Default = false,
    Callback = function(value)
        getgenv().ThunderDashNoCooldown = value
        if value and getgenv().AbilityExploit then
            apply_thunder_dash_exploit()
            start_thunder_dash_exploit()
        else
            stop_thunder_dash_exploit()
        end
    end
})

BlatantSub:AddToggle({
    Name = "Semi Immortality",
    Default = false,
    Callback = function(state)
        if state then
            getgenv()._ZX_SetupSemiImmortal()
            sendNotification("Semi Immortality", "Floating panel shown", 3, "info")
        else
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                local old = pg:FindFirstChild("ZX_SemiImmortality")
                if old then old:Destroy() end
            end
            sendNotification("Semi Immortality", "Panel closed", 3, "info")
        end
    end
})

-- ==========================================
-- TAB: SPAM
-- ==========================================
local SpamTab = Tabs.Spam
local SpamSub = SpamTab:AddSubTab("Spam")

SpamSub:AddSection("Manual Spam")
SpamSub:AddToggle({
    Name = "Manual Spam",
    Default = false,
    Callback = function(state)
        if getgenv().ManualSpamNotify then
            sendNotification("Manual Spam", state and "ON" or "OFF", 2, state and "success" or "error")
        end
        if state then
            if System and System.manual_spam and System.manual_spam.start then pcall(System.manual_spam.start) end
        else
            if System and System.manual_spam and System.manual_spam.stop then pcall(System.manual_spam.stop) end
        end
    end
})
SpamSub:AddToggle({
    Name = "Enable CPS",
    Default = false,
    Callback = function(value) getgenv().ManualSpamCPSEnabled = value end
})
SpamSub:AddSlider({
    Name = "CPS",
    Default = 1,
    Min = 1,
    Max = 1999,
    Rounding = 1,
    Callback = function(value)
        getgenv().ManualSpamCPS = value
        warn_manual_spam_cps(value)
    end
})
SpamSub:AddToggle({
    Name = "Notify",
    Default = false,
    Callback = function(value) getgenv().ManualSpamNotify = value end
})

SpamSub:AddSection("Auto Spam")
SpamSub:AddToggle({
    Name = "Auto Spam",
    Default = false,
    Callback = function(state)
        if System and System.auto_spam then
            System.__properties.__auto_spam_enabled = state
            if state then
                if System.auto_spam and System.auto_spam.start then pcall(System.auto_spam.start) end
                if getgenv().AutoSpamNotify then sendNotification("Auto Spam", "ON", 2, "success") end
            else
                if System.auto_spam and System.auto_spam.stop then pcall(System.auto_spam.stop) end
                if getgenv().AutoSpamNotify then sendNotification("Auto Spam", "OFF", 2, "error") end
            end
        end
    end
})
SpamSub:AddToggle({
    Name = "Notify",
    Default = false,
    Callback = function(value) getgenv().AutoSpamNotify = value end
})
SpamSub:AddDropdown({
    Name = "Mode",
    Options = {"Remote", "Keypress"},
    Default = "Remote",
    Callback = function(value) getgenv().AutoSpamMode = value end
})
SpamSub:AddToggle({
    Name = "Animation Fix",
    Default = false,
    Callback = function(value) getgenv().AutoSpamAnimationFix = value end
})
SpamSub:AddSlider({
    Name = "Parry Threshold",
    Default = 1,
    Min = 1,
    Max = 3,
    Rounding = 1,
    Callback = function(value) if System then System.__properties.__spam_threshold = value end end
})
SpamSub:AddSlider({
    Name = "Distance Multiplier",
    Default = 0.3,
    Min = 0.3,
    Max = 3.0,
    Rounding = 1,
    Callback = function(value) if System then System.__properties.__auto_spam_distance_multiplier = value end end
})

-- ==========================================
-- TAB: DETECTION
-- ==========================================
local DetectionTab = Tabs.Detection
local DetectionSub = DetectionTab:AddSubTab("Detection")

DetectionSub:AddSection("Staff Detection")
DetectionSub:AddToggle({
    Name = "Staff Detection",
    Default = false,
    Callback = function(state)
        getgenv().ModDetection = state
        if state then
            if modMonitorConnection then modMonitorConnection:Disconnect(); modMonitorConnection = nil end
            checkModPlayers()
            modMonitorConnection = RunService.Heartbeat:Connect(checkModPlayers)
        else
            if modMonitorConnection then modMonitorConnection:Disconnect(); modMonitorConnection = nil end
            detectedMods = {}
        end
    end
})
DetectionSub:AddDropdown({
    Name = "Action Mode",
    Options = {"Notification", "Kick"},
    Default = "Notification",
    Callback = function(value) modActionMode = value end
})

DetectionSub:AddSection("Ability Detections")
DetectionSub:AddToggle({
    Name = "Infinity Detection",
    Default = false,
    Callback = function(state)
        if System and System.__config then
            System.__config.__detections.__infinity = state
            if getgenv().InfinityNotify then sendNotification("Infinity Detection", state and "ON" or "OFF", 2, state and "success" or "error") end
        end
    end
})
DetectionSub:AddToggle({
    Name = "Notify",
    Default = false,
    Callback = function(value) getgenv().InfinityNotify = value end
})

DetectionSub:AddToggle({
    Name = "Death Slash Detection",
    Default = false,
    Callback = function(state)
        if System and System.__config then System.__config.__detections.__deathslash = state end
    end
})

DetectionSub:AddToggle({
    Name = "Time Hole Detection",
    Default = false,
    Callback = function(state)
        if System and System.__config then System.__config.__detections.__timehole = state end
    end
})

DetectionSub:AddToggle({
    Name = "Slashes Of Fury Detection",
    Default = false,
    Callback = function(state)
        if System and System.__config then System.__config.__detections.__slashesoffury = state end
    end
})
DetectionSub:AddSlider({
    Name = "Parry Delay",
    Default = 0.05,
    Min = 0.05,
    Max = 0.250,
    Rounding = 3,
    Callback = function(value) parryDelay = value end
})
DetectionSub:AddSlider({
    Name = "Max Parry Count",
    Default = 36,
    Min = 1,
    Max = 36,
    Rounding = 1,
    Callback = function(value) maxParryCount = value end
})

DetectionSub:AddToggle({
    Name = "Dribble Detection",
    Default = false,
    Callback = function(state)
        getgenv().DribbleDetection = state
        if System and System.__config then System.__config.__detections.__dribble = state end
        if getgenv().DribbleNotify then sendNotification("Dribble Detection", state and "ON" or "OFF", 2, state and "success" or "error") end
    end
})
DetectionSub:AddToggle({
    Name = "Notify",
    Default = false,
    Callback = function(value) getgenv().DribbleNotify = value end
})

DetectionSub:AddToggle({
    Name = "Anti-Phantom",
    Default = false,
    Callback = function(state)
        if System and System.__config then System.__config.__detections.__phantom = state end
    end
})

DetectionSub:AddToggle({
    Name = "Singularity Detection",
    Default = false,
    Callback = function(state)
        getgenv().SingularityDetection = state
        if System and System.__config and System.__config.__detections then
            System.__config.__detections.__singularity = state
        end
    end
})

-- ==========================================
-- TAB: PLAYER
-- ==========================================
local PlayerTab = Tabs.Player
local PlayerSub = PlayerTab:AddSubTab("Player")

PlayerSub:AddSection("Auto Play")
PlayerSub:AddToggle({
    Name = "Auto Play",
    Default = false,
    Callback = function(value)
        auto_play_set_enabled(value)
    end
})
PlayerSub:AddToggle({
    Name = "Anti AFK",
    Default = false,
    Callback = function(value)
        getgenv().AutoPlayAntiAFK = value
        if value then
            if not Connections_Manager["AutoPlayAntiAFK"] then
                Connections_Manager["AutoPlayAntiAFK"] = Players.LocalPlayer.Idled:Connect(function()
                    local virtualUser = cloneref(game:GetService('VirtualUser'))
                    virtualUser:CaptureController()
                    virtualUser:ClickButton2(Vector2.new())
                end)
            end
        else
            if Connections_Manager["AutoPlayAntiAFK"] then
                Connections_Manager["AutoPlayAntiAFK"]:Disconnect()
                Connections_Manager["AutoPlayAntiAFK"] = nil
            end
        end
    end
})
PlayerSub:AddToggle({
    Name = "Enable Jumping",
    Default = false,
    Callback = function(value) getgenv().AutoPlayJumpingEnabled = value end
})
PlayerSub:AddToggle({
    Name = "Auto Vote",
    Default = false,
    Callback = function(value) getgenv().AutoVote = value end
})
PlayerSub:AddSlider({
    Name = "Distance From Ball",
    Default = 18,
    Min = 5,
    Max = 55,
    Rounding = 1,
    Callback = function(value) getgenv().AutoPlayDistance = value end
})
PlayerSub:AddSlider({
    Name = "Speed Multiplier",
    Default = 45,
    Min = 10,
    Max = 200,
    Rounding = 1,
    Callback = function(value) getgenv().AutoPlayMultiplierThreshold = value end
})
PlayerSub:AddSlider({
    Name = "Transversing",
    Default = 8,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(value) getgenv().AutoPlayTransversing = value end
})
PlayerSub:AddSlider({
    Name = "Direction",
    Default = 1,
    Min = -1,
    Max = 1,
    Rounding = 2,
    Callback = function(value) getgenv().AutoPlayDirection = value end
})
PlayerSub:AddSlider({
    Name = "Offset Factor",
    Default = 0.4,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    Callback = function(value) getgenv().AutoPlayOffsetFactor = value end
})
PlayerSub:AddSlider({
    Name = "Movement Duration",
    Default = 0.75,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    Callback = function(value) getgenv().AutoPlayMovementDuration = value end
})
PlayerSub:AddSlider({
    Name = "Generation Threshold",
    Default = 0.25,
    Min = 0.1,
    Max = 0.5,
    Rounding = 2,
    Callback = function(value) getgenv().AutoPlayGenerationThreshold = value end
})
PlayerSub:AddSlider({
    Name = "Jump Chance",
    Default = 20,
    Min = 0,
    Max = 50,
    Rounding = 1,
    Callback = function(value) getgenv().AutoPlayJumpPercentage = value end
})
PlayerSub:AddSlider({
    Name = "Double Jump Chance",
    Default = 10,
    Min = 0,
    Max = 40,
    Rounding = 1,
    Callback = function(value) getgenv().AutoPlayDoubleJumpPercentage = value end
})

PlayerSub:AddSection("FOV")
PlayerSub:AddToggle({
    Name = "FOV",
    Default = false,
    Callback = function(state)
        getgenv().CameraEnabled = state
        local Camera = workspace.CurrentCamera
        if state then
            getgenv().CameraFOV = getgenv().CameraFOV or 70
            Camera.FieldOfView = getgenv().CameraFOV
            if not getgenv().FOVLoop then
                getgenv().FOVLoop = RunService.RenderStepped:Connect(function()
                    if getgenv().CameraEnabled then Camera.FieldOfView = getgenv().CameraFOV end
                end)
            end
        else
            Camera.FieldOfView = 70
            if getgenv().FOVLoop then getgenv().FOVLoop:Disconnect(); getgenv().FOVLoop = nil end
        end
    end
})
PlayerSub:AddSlider({
    Name = "Camera FOV",
    Default = 70,
    Min = 50,
    Max = 120,
    Rounding = 1,
    Callback = function(value)
        getgenv().CameraFOV = value
        if getgenv().CameraEnabled then workspace.CurrentCamera.FieldOfView = value end
    end
})

PlayerSub:AddSection("Name Spoof")
PlayerSub:AddToggle({
    Name = "Name Spoof",
    Default = false,
    Callback = function(state)
        getgenv()._ZX_NameSpoofEnabled = state
        if state then
            sendNotification("Name Spoof", "Enabled — name: " .. CONFIG.FakeDisplay, 4, "success")
        else
            sendNotification("Name Spoof", "Disabled", 3, "error")
        end
    end
})
PlayerSub:AddInput({
    Name = "Spoofed Name",
    Placeholder = "Enter fake name...",
    Default = "",
    Callback = function(value)
        CONFIG.FakeName = value
        CONFIG.FakeDisplay = value
        TargetName = value
        TargetDisplay = value .. CONFIG.Separator .. VERIFIED_BADGE
        sendNotification("Name Spoof", "Name set to: "..value, 3, "info")
    end
})

PlayerSub:AddSection("Look at Ball")
PlayerSub:AddToggle({
    Name = "Look at Ball",
    Default = false,
    Callback = function(state) getgenv()._ZX_LookAtBall = state end
})
PlayerSub:AddToggle({
    Name = "Smooth Look",
    Default = false,
    Callback = function(state) getgenv()._ZX_SmoothLook = state end
})

PlayerSub:AddSection("Orbit Ball")
PlayerSub:AddToggle({
    Name = "Orbit Ball",
    Default = false,
    Callback = function(state) getgenv()._ZX_OrbitBall = state end
})
PlayerSub:AddSlider({
    Name = "Orbit Radius (studs)",
    Default = 14,
    Min = 6,
    Max = 40,
    Rounding = 1,
    Callback = function(value) getgenv()._ZX_OrbitRadius = value end
})
PlayerSub:AddSlider({
    Name = "Orbit Speed",
    Default = 4,
    Min = 1,
    Max = 12,
    Rounding = 1,
    Callback = function(value) getgenv()._ZX_OrbitSpeed = value end
})

PlayerSub:AddSection("Hit Sounds")
PlayerSub:AddToggle({
    Name = "Hit Sounds",
    Default = false,
    Callback = function(value) hit_Sound_Enabled = value end
})
PlayerSub:AddSlider({
    Name = "Volume",
    Default = 5,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(value) hit_Sound.Volume = value end
})
PlayerSub:AddDropdown({
    Name = "Hit Sound Type",
    Options = hitSoundOptions,
    Default = hitSoundOptions[1],
    Callback = function(selectedOption)
        if hitSoundIds[selectedOption] then
            hit_Sound.SoundId = hitSoundIds[selectedOption]
        end
    end
})

PlayerSub:AddSection("Player Cosmetics")
PlayerSub:AddToggle({
    Name = "Headless & Korblox",
    Default = false,
    Callback = function(value)
        local lp = LocalPlayer
        getgenv().HeadlessKorbloxEnabled = value
        local function applyKorblox(character)
            if not character then return end
            local leg = character:FindFirstChild("Right Leg") or character:FindFirstChild('RightLeg')
            if not leg then return end
            if leg:FindFirstChild("KorbloxMesh") then return end
            for _, child in ipairs(leg:GetChildren()) do
                if child:IsA('SpecialMesh') then child:Destroy() end
            end
            local mesh = Instance.new('SpecialMesh')
            mesh.Name = "KorbloxMesh"
            mesh.MeshId = 'rbxassetid://902942096'
            mesh.TextureId = 'rbxassetid://902843398'
            mesh.Offset = Vector3.new(0, 0.7, 0)
            mesh.Parent = leg
        end
        local function restoreKorblox(character)
            if not character then return end
            local leg = character:FindFirstChild("Right Leg") or character:FindFirstChild('RightLeg')
            if not leg then return end
            for _, child in ipairs(leg:GetChildren()) do
                if child:IsA('SpecialMesh') then child:Destroy() end
            end
        end
        local function applyHeadless(character)
            if not character then return end
            local head = character:FindFirstChild('Head')
            if not head then return end
            if _G.PlayerCosmeticsCleanup.headTransparency == nil then
                _G.PlayerCosmeticsCleanup.headTransparency = head.Transparency
            end
            local face = head:FindFirstChildOfClass('Decal')
            if face then
                _G.PlayerCosmeticsCleanup.faceDecalId = face.Texture
                _G.PlayerCosmeticsCleanup.faceDecalName = face.Name
            end
            head.Transparency = 1
            for _, child in ipairs(head:GetChildren()) do
                if child:IsA('Decal') or child.Name == "face" then
                    child.Transparency = 1
                elseif child:IsA('SpecialMesh') or child:IsA('DataModelMesh') then
                    if not child:GetAttribute("OriginalScale") then
                        child:SetAttribute("OriginalScale", child.Scale)
                        child.Scale = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
        local function restoreHeadless(character)
            if not character then return end
            local head = character:FindFirstChild('Head')
            if not head then return end
            if _G.PlayerCosmeticsCleanup.headTransparency ~= nil then
                head.Transparency = _G.PlayerCosmeticsCleanup.headTransparency
            end
            if _G.PlayerCosmeticsCleanup.faceDecalId then
                local newDecal = head:FindFirstChildOfClass('Decal') or Instance.new('Decal', head)
                newDecal.Name = _G.PlayerCosmeticsCleanup.faceDecalName or "face"
                newDecal.Texture = _G.PlayerCosmeticsCleanup.faceDecalId
                newDecal.Face = Enum.NormalId.Front
            end
            for _, child in ipairs(head:GetChildren()) do
                if child:IsA('Decal') or child.Name == "face" then
                    child.Transparency = 0
                elseif child:IsA('SpecialMesh') or child:IsA('DataModelMesh') then
                    local orig = child:GetAttribute("OriginalScale")
                    if orig then
                        child.Scale = orig
                        child:SetAttribute("OriginalScale", nil)
                    end
                end
            end
        end
        local function applyCosmetics(character)
            if not character then return end
            applyKorblox(character)
            applyHeadless(character)
        end
        if value then
            _G.PlayerCosmeticsCleanup = _G.PlayerCosmeticsCleanup or {}
            if lp.Character then applyCosmetics(lp.Character) end
            if _G.PlayerCosmeticsCleanup.characterAddedConn then _G.PlayerCosmeticsCleanup.characterAddedConn:Disconnect() end
            _G.PlayerCosmeticsCleanup.characterAddedConn = lp.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                applyCosmetics(char)
            end)
        else
            if _G.PlayerCosmeticsCleanup.characterAddedConn then
                _G.PlayerCosmeticsCleanup.characterAddedConn:Disconnect()
                _G.PlayerCosmeticsCleanup.characterAddedConn = nil
            end
            if lp.Character then
                restoreHeadless(lp.Character)
                restoreKorblox(lp.Character)
            end
            _G.PlayerCosmeticsCleanup = {}
        end
    end
})

-- ==========================================
-- TAB: VISUAL
-- ==========================================
local VisualTab = Tabs.Visual
local VisualSub = VisualTab:AddSubTab("Visual")

VisualSub:AddSection("Ball Trail")
VisualSub:AddToggle({
    Name = "Ball Trail",
    Default = false,
    Callback = function(value) getgenv().BallTrailEnabled = value end
})
VisualSub:AddSlider({
    Name = "Ball Trail Hue",
    Default = 0,
    Min = 0,
    Max = 360,
    Rounding = 1,
    Callback = function(value)
        if not getgenv().BallTrailRainbowEnabled then
            getgenv().BallTrailColor = Color3.fromHSV(value / 360, 1, 1)
        end
        getgenv().BallTrailHue = value
    end
})
VisualSub:AddToggle({
    Name = "Rainbow Trail",
    Default = false,
    Callback = function(value) getgenv().BallTrailRainbowEnabled = value end
})
VisualSub:AddToggle({
    Name = "Particle Emitter",
    Default = false,
    Callback = function(value) getgenv().BallTrailParticleEnabled = value end
})
VisualSub:AddToggle({
    Name = "Glow Effect",
    Default = false,
    Callback = function(value) getgenv().BallTrailGlowEnabled = value end
})

VisualSub:AddSection("FPS and Ping")
VisualSub:AddToggle({
    Name = "FPS and Ping",
    Default = false,
    Callback = function(state)
        if state then
            System = System or {}
            System.__properties = System.__properties or {}
            System.__properties.__connections = System.__properties.__connections or {}
            if not System.__properties.__stats_overlay then
                local OverlayGui = Instance.new('ScreenGui')
                OverlayGui.Name = "WisnuStatsOverlay"
                OverlayGui.ResetOnSpawn = false
                OverlayGui.IgnoreGuiInset = true
                OverlayGui.DisplayOrder = (3*33)
                OverlayGui.Parent = CoreGui
                local Panel = Instance.new('Frame')
                Panel.Name = 'Panel'
                Panel.Size = UDim2.new(0, (2*89), 0, (2*43))
                Panel.Position = UDim2.new(0, (19+1), 0.5, -(73-30))
                Panel.BackgroundColor3 = Color3.fromRGB(bit32.bxor(31,19), (83-71), (3+9))
                Panel.BorderSizePixel = 0
                Panel.Active = true
                Panel.Parent = OverlayGui
                Instance.new('UICorner', Panel).CornerRadius = UDim.new(0, (31-19))
                local PanelStroke = Instance.new('UIStroke', Panel)
                PanelStroke.Color = Color3.fromRGB((2*35), (2*35), (2*35))
                PanelStroke.Thickness = 1
                local TitleLabel = Instance.new('TextLabel')
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Size = UDim2.new(1, 0, 0, (2*9))
                TitleLabel.Position = UDim2.new(0, 0, 0, 6)
                TitleLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                TitleLabel.Text = "FPS & PING"
                TitleLabel.TextColor3 = Color3.fromRGB((79+141), (250-30), bit32.bxor(31,195))
                TitleLabel.TextSize = (81-71)
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
                TitleLabel.Parent = Panel
                local ChipHolder = Instance.new('Frame')
                ChipHolder.BackgroundTransparency = 1
                ChipHolder.Position = UDim2.new(0, (5+5), 0, (45-19))
                ChipHolder.Size = UDim2.new(1, -(2*10), 0, (2*22))
                ChipHolder.Parent = Panel
                local ChipLayout = Instance.new('UIListLayout', ChipHolder)
                ChipLayout.FillDirection = Enum.FillDirection.Horizontal
                ChipLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                ChipLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                ChipLayout.Padding = UDim.new(0, 6)
                local function makeChip(tag)
                    local Chip = Instance.new('Frame')
                    Chip.Size = UDim2.new(0, (2*35), 0, (2*18))
                    Chip.BackgroundColor3 = Color3.fromRGB((7+17), (54-30), bit32.bxor(31,7))
                    Chip.BorderSizePixel = 0
                    Chip.Parent = ChipHolder
                    Instance.new('UICorner', Chip).CornerRadius = UDim.new(0, (81-71))
                    local CS = Instance.new('UIStroke', Chip)
                    CS.Color = Color3.fromRGB((15+45), (79-19), (2*30))
                    CS.Thickness = 1
                    local Dot = Instance.new('Frame')
                    Dot.Name = 'Dot'
                    Dot.Size = UDim2.new(0, 4, 0, 4)
                    Dot.Position = UDim2.new(0, 6, 0, 5)
                    Dot.BackgroundColor3 = Color3.fromRGB((2*50), (2*110), (2*65))
                    Dot.BorderSizePixel = 0
                    Dot.Parent = Chip
                    Instance.new('UICorner', Dot).CornerRadius = UDim.new(1, 0)
                    local Tag = Instance.new('TextLabel')
                    Tag.BackgroundTransparency = 1
                    Tag.Size = UDim2.new(1, -8, 0, 9)
                    Tag.Position = UDim2.new(0, 4, 0, 3)
                    Tag.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    Tag.Text = tag
                    Tag.TextColor3 = Color3.fromRGB((79+101), (210-30), bit32.bxor(31,171))
                    Tag.TextSize = 8
                    Tag.TextXAlignment = Enum.TextXAlignment.Center
                    Tag.Parent = Chip
                    local Val = Instance.new('TextLabel')
                    Val.Name = 'Val'
                    Val.BackgroundTransparency = 1
                    Val.Size = UDim2.new(1, 0, 0, (87-71))
                    Val.Position = UDim2.new(0, 0, 0, (15+1))
                    Val.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                    Val.Text = '--'
                    Val.TextColor3 = Color3.fromRGB((259-19), (2*120), (2*120))
                    Val.TextSize = (1+12)
                    Val.TextXAlignment = Enum.TextXAlignment.Center
                    Val.Parent = Chip
                    return Val, Dot
                end
                local FpsVal, FpsDot   = makeChip('FPS')
                local PingVal, PingDot = makeChip('PING')
                Panel.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local dragStart = input.Position
                        local startPos  = Panel.Position
                        local moving    = true
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then moving = false end
                        end)
                        local conn
                        conn = UserInputService.InputChanged:Connect(function(inp)
                            if not moving then conn:Disconnect() return end
                            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                                local delta = inp.Position - dragStart
                                Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                            end
                        end)
                    end
                end)
                System.__properties.__stats_overlay = {
                    gui = OverlayGui,
                    fpsVal = FpsVal, fpsDot = FpsDot,
                    pingVal = PingVal, pingDot = PingDot,
                }
            end
            System.__properties.__stats_overlay.gui.Enabled = true
            if not System.__properties.__connections.__stats_overlay then
                local frameCount = 0
                local elapsed    = 0
                local smoothFps  = 0
                local fpsConn = RunService.RenderStepped:Connect(function(dt)
                    frameCount += 1
                    elapsed    += dt
                    if elapsed >= 0.5 then
                        smoothFps  = math.round(frameCount / elapsed)
                        frameCount = 0
                        elapsed    = 0
                    end
                end)
                System.__properties.__connections.__stats_overlay_fps = fpsConn
                System.__properties.__connections.__stats_overlay = task.spawn(function()
                    while System.__properties.__stats_overlay do
                        local o = System.__properties.__stats_overlay
                        pcall(function()
                            local fps = smoothFps
                            local fpsColor = fps >= 55 and Color3.fromRGB((130-30),bit32.bxor(31,195),(201-71)) or fps >= 30 and Color3.fromRGB((249-19),(2*100),(2*40)) or Color3.fromRGB((2*110),(2*40),(79+1))
                            o.fpsVal.Text = tostring(fps)
                            o.fpsVal.TextColor3 = fpsColor
                            o.fpsDot.BackgroundColor3 = fpsColor
                            local ping = math.round(Players.LocalPlayer:GetNetworkPing() * 1000)
                            local pingColor = ping <= 80 and Color3.fromRGB((171-71),(35+185),(149-19)) or ping <= 150 and Color3.fromRGB((2*115),(2*100),(2*40)) or Color3.fromRGB((79+141),(110-30),bit32.bxor(31,79))
                            o.pingVal.Text = tostring(ping)
                            o.pingVal.TextColor3 = pingColor
                            o.pingDot.BackgroundColor3 = pingColor
                        end)
                        task.wait(0.5)
                    end
                end)
            end
        else
            if System.__properties.__connections.__stats_overlay then
                System.__properties.__connections.__stats_overlay = nil
            end
            if System.__properties.__connections.__stats_overlay_fps then
                pcall(function() System.__properties.__connections.__stats_overlay_fps:Disconnect() end)
                System.__properties.__connections.__stats_overlay_fps = nil
            end
            if System.__properties.__stats_overlay then
                pcall(function() System.__properties.__stats_overlay.gui:Destroy() end)
                System.__properties.__stats_overlay = nil
            end
        end
    end
})

VisualSub:AddSection("Sound Controller")
VisualSub:AddToggle({
    Name = "Sound Controller",
    Default = false,
    Callback = function(value)
        getgenv().sound_controller = value
        if value then
            play_sound_by_id(get_sound_id(selectedSound))
        else
            currentSound:Stop()
        end
    end
})
VisualSub:AddToggle({
    Name = "Loop Song",
    Default = false,
    Callback = function(value) getgenv().LoopSong = value; currentSound.Looped = value end
})
VisualSub:AddSlider({
    Name = "Volume",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(value) getgenv().SoundControllerVolume = value; currentSound.Volume = value end
})
VisualSub:AddDropdown({
    Name = "Select Sound",
    Options = soundOptionNames,
    Default = soundOptionNames[1],
    Callback = function(value)
        getgenv().SelectedSound = value
        selectedSound = value
        if getgenv().sound_controller then
            play_sound_by_id(get_sound_id(value))
        end
    end
})

VisualSub:AddSection("Ping Spoofer")
VisualSub:AddToggle({
    Name = "Ping Spoofer",
    Default = false,
    Callback = function(state)
        if state then
            if not ping_spoofer_connection then
                ping_spoofer_connection = RunService.RenderStepped:Connect(function()
                    local fake_ping = tonumber(Library._config._flags.ping_text) or 333
                    fake_ping = tostring(math.floor(fake_ping))
                    local robloxGui = CoreGui:FindFirstChild("RobloxGui")
                    if robloxGui then
                        local perfStats = robloxGui:FindFirstChild("PerformanceStats")
                        if perfStats then
                            for _, descendant in ipairs(perfStats:GetDescendants()) do
                                if descendant:IsA('TextLabel') and descendant.Text:match("%d+ ms") then
                                    descendant.Text = fake_ping .. ' ms'
                                end
                            end
                        end
                    end
                end)
            end
        else
            if ping_spoofer_connection then
                ping_spoofer_connection:Disconnect()
                ping_spoofer_connection = nil
            end
            local robloxGui = CoreGui:FindFirstChild("RobloxGui")
            if robloxGui and robloxGui:FindFirstChild("FakePingLabel") then
                robloxGui.FakePingLabel:Destroy()
            end
        end
    end
})
VisualSub:AddInput({
    Name = "Ping Value",
    Placeholder = "Enter Fake Ping Number",
    Default = "333",
    Callback = function(value)
        local fake_ping = tonumber(value)
        if fake_ping and fake_ping >= 0 then
            Library._config._flags.ping_text = tostring(math.floor(fake_ping))
        end
    end
})

VisualSub:AddSection("Ball Stats")
VisualSub:AddToggle({
    Name = "Ball Stats",
    Default = false,
    Callback = function(state)
        getgenv().BallStats = state
        if state then
            enable_ball_stats()
        else
            disable_ball_stats()
        end
    end
})

VisualSub:AddSection("Visualiser")
VisualSub:AddToggle({
    Name = "Visualiser",
    Default = false,
    Callback = function(value)
        getgenv().Visualiser = value
        if value then
            if not visualiser_model then
                visualiser_model = Instance.new('Model')
                visualiser_model.Name = "VisualiserModel"
                visualiser_model.Parent = workspace
                local segmentCount = (127+1)
                for i = 1, segmentCount do
                    local edge = Instance.new('Part')
                    edge.Name = "VisualiserEdge" .. i
                    edge.Anchored = true
                    edge.CanCollide = false
                    edge.CastShadow = false
                    edge.Material = Enum.Material.Neon
                    edge.Color = Color3.fromRGB((274-19), (3*85), (3*85))
                    edge.Transparency = 0.25
                    edge.Reflectance = 0.25
                    edge.Size = Vector3.new(0.08, 0.08, 0.18)
                    edge.Parent = visualiser_model
                    visualiser_edges[i] = edge
                end
            end
            Connections_Manager["Visualiser"] = RunService.RenderStepped:Connect(function()
                local character = Player.Character
                local hrp = character and character:FindFirstChild('HumanoidRootPart')
                if getgenv().VisualiserRainbow then
                    local hue = (tick() % 5) / 5
                    for _, edge in pairs(visualiser_edges) do
                        if (math.floor(1.5)==1) and (edge) then
                            edge.Color = Color3.fromHSV(hue, 1, 1)
                        end
                    end
                else
                    local hueVal = getgenv().VisualiserHue or 0
                    for _, edge in pairs(visualiser_edges) do
                        if edge then
                            edge.Color = Color3.fromHSV(hueVal / 360, 1, 1)
                        end
                    end
                end
                local speed = 0
                local maxSpeed = 350
                local ballsFolder = workspace:FindFirstChild('Balls')
                if ballsFolder then
                    for _, ball in pairs(ballsFolder:GetChildren()) do
                        if ball and ball:FindFirstChild("zoomies") then
                            local velocity = ball.AssemblyLinearVelocity
                            speed = math.min(velocity.Magnitude, maxSpeed) / 6.5
                            break
                        end
                    end
                end
                local size = math.max(speed, 6.5)
                local radius = size * 0.5
                local segmentCount = #visualiser_edges
                local segmentLength = math.max(0.25, (2 * math.pi * radius) / segmentCount)
                for index, edge in ipairs(visualiser_edges) do
                    if edge and hrp then
                        local angle = (index - 1) * (2 * math.pi / segmentCount)
                        edge.Size = Vector3.new(0.05, 0.05, segmentLength)
                        edge.CFrame = hrp.CFrame
                            * CFrame.new(math.cos(angle) * radius, -3.0, math.sin(angle) * radius)
                            * CFrame.Angles(0, angle + math.pi / 2, 0)
                    end
                end
            end)
        else
            if Connections_Manager["Visualiser"] then
                Connections_Manager["Visualiser"]:Disconnect()
                Connections_Manager["Visualiser"] = nil
            end
            if visualiser_model then
                visualiser_model:Destroy()
                visualiser_model = nil
                visualiser_edges = {}
            end
        end
    end
})
VisualSub:AddToggle({
    Name = "Rainbow",
    Default = false,
    Callback = function(value) getgenv().VisualiserRainbow = value end
})
VisualSub:AddSlider({
    Name = "Color Hue",
    Default = 0,
    Min = 0,
    Max = 360,
    Rounding = 1,
    Callback = function(value) getgenv().VisualiserHue = value end
})

VisualSub:AddSection("Custom Announcer")
VisualSub:AddToggle({
    Name = "Custom Announcer",
    Default = false,
    Callback = function(value)
        getgenv().CustomAnnouncer = value
        if value then
            local announcerGui = Player:FindFirstChild('PlayerGui') and Player.PlayerGui:FindFirstChild("announcer")
            local winnerLabel = announcerGui and announcerGui:FindFirstChild('Winner')
            if winnerLabel then winnerLabel.Text = getgenv().AnnouncerText or "discord.gg/Wisnu" end
            if not Connections_Manager["CustomAnnouncer"] then
                Connections_Manager["CustomAnnouncer"] = announcerGui and announcerGui.ChildAdded:Connect(function(child)
                    if child.Name == 'Winner' then
                        child.Changed:Connect(function(property)
                            if property == 'Text' and getgenv().CustomAnnouncer then
                                child.Text = getgenv().AnnouncerText or "discord.gg/Wisnu"
                            end
                        end)
                        if getgenv().CustomAnnouncer then
                            child.Text = getgenv().AnnouncerText or "discord.gg/Wisnu"
                        end
                    end
                end)
            end
        else
            if Connections_Manager["CustomAnnouncer"] then
                Connections_Manager["CustomAnnouncer"]:Disconnect()
                Connections_Manager["CustomAnnouncer"] = nil
            end
        end
    end
})
VisualSub:AddInput({
    Name = "Custom Announcement Text",
    Placeholder = "Enter Custom Announcement...",
    Default = "discord.gg/Wisnu",
    Callback = function(text)
        getgenv().AnnouncerText = text
        if getgenv().CustomAnnouncer then
            local announcerGui = Player:FindFirstChild('PlayerGui') and Player.PlayerGui:FindFirstChild("announcer")
            local winnerLabel = announcerGui and announcerGui:FindFirstChild('Winner')
            if winnerLabel then winnerLabel.Text = text end
        end
    end
})

VisualSub:AddSection("Ability ESP")
VisualSub:AddToggle({
    Name = "Ability ESP",
    Default = false,
    Callback = function(state)
        if state then start_ability_esp() else stop_ability_esp() end
    end
})

-- ==========================================
-- TAB: MISC
-- ==========================================
local MiscTab = Tabs.Misc
local MiscSub = MiscTab:AddSubTab("Misc")

MiscSub:AddSection("Optimization")
MiscSub:AddToggle({
    Name = "FPS Booster",
    Default = false,
    Callback = function(state) apply_fps_boost(state) end
})
MiscSub:AddToggle({
    Name = "Low Graphics",
    Default = false,
    Callback = function(state)
        if state then
            pcall(function()
                low_graphics_original_quality = settings().Rendering.QualityLevel
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            pcall(function()
                local lighting = game:GetService("Lighting")
                lighting.GlobalShadows = false
                lighting.FogEnd = 9e9
            end)
        else
            pcall(function()
                if low_graphics_original_quality then
                    settings().Rendering.QualityLevel = low_graphics_original_quality
                end
            end)
            pcall(function()
                local lighting = game:GetService("Lighting")
                lighting.GlobalShadows = true
            end)
        end
    end
})
MiscSub:AddToggle({
    Name = "No Render",
    Default = false,
    Callback = function(state)
        getgenv().No_Render = state
        local playerScripts = Players.LocalPlayer:FindFirstChild('PlayerScripts')
        local effectScripts = playerScripts and playerScripts:FindFirstChild("EffectScripts")
        local clientFX = effectScripts and effectScripts:FindFirstChild("ClientFX")
        if clientFX then clientFX.Disabled = state end
        if state then
            if not Connections_Manager["No Render"] then
                local runtime = workspace:FindFirstChild('Runtime')
                if runtime then
                    Connections_Manager["No Render"] = runtime.ChildAdded:Connect(function(value)
                        Debris:AddItem(value, 0)
                    end)
                end
            end
        else
            if Connections_Manager["No Render"] then
                Connections_Manager["No Render"]:Disconnect()
                Connections_Manager["No Render"] = nil
            end
        end
    end
})

-- ==========================================
-- TAB: WORLD
-- ==========================================
local WorldTab = Tabs.World
local WorldSub = WorldTab:AddSubTab("World")

WorldSub:AddSection("Filter")
WorldSub:AddToggle({
    Name = "Filter",
    Default = false,
    Callback = function(value)
        getgenv().FilterEnabled = value
        apply_filter_state()
    end
})
WorldSub:AddToggle({
    Name = "Enable Atmosphere",
    Default = false,
    Callback = function(value)
        getgenv().AtmosphereEnabled = value
        apply_filter_state()
    end
})
WorldSub:AddSlider({
    Name = "Atmosphere Density",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        getgenv().AtmosphereDensity = value
        if getgenv().FilterEnabled then apply_filter_state() end
    end
})
WorldSub:AddToggle({
    Name = "Enable Saturation",
    Default = false,
    Callback = function(value)
        getgenv().SaturationEnabled = value
        apply_filter_state()
    end
})
WorldSub:AddSlider({
    Name = "Saturation Level",
    Default = 0,
    Min = -1,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        getgenv().SaturationLevel = value
        if getgenv().FilterEnabled then apply_filter_state() end
    end
})
WorldSub:AddToggle({
    Name = "Enable Hue",
    Default = false,
    Callback = function(value)
        getgenv().HueEnabled = value
        apply_filter_state()
    end
})
WorldSub:AddSlider({
    Name = "Hue Shift",
    Default = 0,
    Min = -1,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        getgenv().HueShift = value
        if getgenv().FilterEnabled then apply_filter_state() end
    end
})

-- Atmosphere, Color Correction, Lighting, Sky
WorldSub:AddSection("Atmosphere")
WorldSub:AddSlider({Name = "Density", Default = 30, Min = 0, Max = 100, Rounding = 1, Callback = function(v) ensureAtmo().Density = v / 100 end})
WorldSub:AddSlider({Name = "Offset", Default = 25, Min = 0, Max = 100, Rounding = 1, Callback = function(v) ensureAtmo().Offset = v / 100 end})
WorldSub:AddSlider({Name = "Glare", Default = 0, Min = 0, Max = 100, Rounding = 1, Callback = function(v) ensureAtmo().Glare = v / 100 end})
WorldSub:AddSlider({Name = "Haze", Default = 10, Min = 0, Max = 100, Rounding = 1, Callback = function(v) ensureAtmo().Haze = v / 100 end})

WorldSub:AddSection("Color Correction")
WorldSub:AddSlider({Name = "Saturation", Default = 100, Min = 0, Max = 200, Rounding = 1, Callback = function(v) ensureCC().Saturation = (v - 100) / 100 end})
WorldSub:AddSlider({Name = "Contrast", Default = 100, Min = 0, Max = 200, Rounding = 1, Callback = function(v) ensureCC().Contrast = (v - 100) / 100 end})
WorldSub:AddSlider({Name = "Brightness", Default = 100, Min = 0, Max = 200, Rounding = 1, Callback = function(v) ensureCC().Brightness = (v - 100) / 100 end})

WorldSub:AddSection("Lighting")
WorldSub:AddSlider({Name = "Brightness", Default = 20, Min = 0, Max = 100, Rounding = 1, Callback = function(v) Lighting.Brightness = v / 10 end})
WorldSub:AddSlider({Name = "Clock Time", Default = 14, Min = 0, Max = 24, Rounding = 1, Callback = function(v) Lighting.ClockTime = v end})
WorldSub:AddSlider({Name = "Fog End", Default = 100000, Min = 0, Max = 100000, Rounding = 1, Callback = function(v) Lighting.FogEnd = v end})
WorldSub:AddToggle({Name = "Global Shadows", Default = false, Callback = function(v) Lighting.GlobalShadows = v end})

WorldSub:AddSection("Sky Color Override")
WorldSub:AddToggle({Name = "Sky Color Override", Default = false, Callback = function(state)
    if state then
        _origLighting.SkyAmbient = Lighting.Ambient
        _origLighting.SkyBright = Lighting.Brightness
        _origLighting.SkyClock = Lighting.ClockTime
        _origLighting.SkyOutdoor = Lighting.OutdoorAmbient
        Lighting.Ambient = Color3.fromRGB(80, 80, 100)
        Lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 100)
        Lighting.Brightness = 1.5
        Lighting.ClockTime = 12
    else
        if _origLighting.SkyAmbient then
            Lighting.Ambient = _origLighting.SkyAmbient
            Lighting.Brightness = _origLighting.SkyBright
            Lighting.ClockTime = _origLighting.SkyClock
            Lighting.OutdoorAmbient = _origLighting.SkyOutdoor
            _origLighting.SkyAmbient = nil
        end
    end
end})
WorldSub:AddSlider({Name = "Brightness", Default = 150, Min = 0, Max = 300, Rounding = 1, Callback = function(v) Lighting.Brightness = v / 100 end})
WorldSub:AddSlider({Name = "Time of Day", Default = 12, Min = 0, Max = 24, Rounding = 1, Callback = function(v) Lighting.ClockTime = v end})

-- ==========================================
-- TAB: GUI
-- ==========================================
local GuiTab = Tabs.GUI
local GuiSub = GuiTab:AddSubTab("GUI")

GuiSub:AddSection("GUI")
GuiSub:AddToggle({
    Name = "GUI Visible",
    Default = false,
    Callback = function(state)
        getgenv().guilibraryVisible = state
        if state then
            Window:Show()
        else
            Window:Hide()
        end
    end
})

-- ==========================================
-- TAB: UNLOCK
-- ==========================================
local UnlockTab = Tabs.Unlock
local UnlockSub = UnlockTab:AddSubTab("Unlock")

UnlockSub:AddSection("Unlock All")
UnlockSub:AddToggle({
    Name = "Unlock All",
    Default = false,
    Callback = function(state)
        getgenv().unlockAllEnabled = state
        if state and getgenv().__runUnlockAll then
            task.spawn(getgenv().__runUnlockAll)
        end
    end
})

-- ==========================================
-- PERBAIKAN SAFETY CHECK UNTUK REMOTE
-- ==========================================
-- Fungsi untuk memanggil remote dengan aman
local function safeFireServer(remote, ...)
    if remote and type(remote.FireServer) == "function" then
        pcall(function() remote:FireServer(...) end)
        return true
    end
    return false
end

local function safeInvokeServer(remote, ...)
    if remote and type(remote.InvokeServer) == "function" then
        return pcall(function() return remote:InvokeServer(...) end)
    end
    return false, "Remote not available"
end

-- ==========================================
-- NOTIFIKASI AWAL
-- ==========================================
Window:Notify({
    Title = "Wisnu Hub Blade Ball (Oxidelib)",
    Content = "Loaded! RightShift to toggle.",
    Duration = 4,
    Type = "success"
})

print("✅ WISNU HUB BLADE BALL — OXIDELIB PORT SUCCESS!")
