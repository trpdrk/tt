-- ==============================================================================
-- DELTA HUB - MM2 Mobile Full Version | บินชนฆาตกร v3
-- ==============================================================================

if not Drawing or not getgenv then
    print("❌ Executor ไม่รองรับ Drawing API")
    return
end

-- เคลียร์ระบบเก่า
if getgenv().MM2_LoadedUI then pcall(function() getgenv().MM2_LoadedUI:Destroy() end) end
if getgenv().MM2_Connection then getgenv().MM2_Connection:Disconnect() end
if getgenv().MM2_NoclipConnection then getgenv().MM2_NoclipConnection:Disconnect() end
if getgenv().MM2_CoinConnection then getgenv().MM2_CoinConnection:Disconnect() end
if getgenv().MM2_SpeedConnection then getgenv().MM2_SpeedConnection:Disconnect() end
if getgenv().MM2_AuraConnection then getgenv().MM2_AuraConnection:Disconnect() end
if getgenv().MM2_AimbotConnection then getgenv().MM2_AimbotConnection:Disconnect() end
if getgenv().MM2_FlingMurdererConn then getgenv().MM2_FlingMurdererConn:Disconnect() end
if getgenv().MM2_PlayerRemoving then getgenv().MM2_PlayerRemoving:Disconnect() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ⚙️ ตั้งค่า
local Settings = {
    Noclip = false,
    AutoCoin = false,
    WalkSpeed = false,
    AuraKill = false,
    Aimbot = false,
    FlingMurderer = false,
    SpeedValue = 27,
    CoinSpeed = 20,
    FlingSpeed = 20,
    AuraRange = 200,
    AimbotRange = 120,
    AimbotSmooth = 0.35
}

-- สร้าง UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_Mobile_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end
getgenv().MM2_LoadedUI = ScreenGui

-- 🔘 ปุ่มลอยเปิด-ปิดเมนู
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 65, 0, 65)
FloatingBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
FloatingBtn.Text = "🔪"
FloatingBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
FloatingBtn.TextSize = 30
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.Active = true
FloatingBtn.Draggable = true
FloatingBtn.Parent = ScreenGui
Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingBtn)
FloatStroke.Color = Color3.fromRGB(255, 90, 90)
FloatStroke.Thickness = 2

-- 📦 หน้าต่างเมนู
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 547)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -273)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "📱 MM2 Mobile Hub"
Title.TextColor3 = Color3.fromRGB(255, 90, 90)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -30, 0, 40)
StatusLabel.Position = UDim2.new(0, 15, 0, 55)
StatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
StatusLabel.Text = "บทบาท: ตรวจสอบ..."
StatusLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.Parent = MainFrame
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 10)

-- สลับเมนูเปิด-ปิด
FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ฟังก์ชันสร้างปุ่ม
local function MakeBtn(yPos, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 52)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

-- ปุ่มต่างๆ
local NoclipBtn = MakeBtn(105, "Noclip: ปิด ❌", function(btn)
    Settings.Noclip = not Settings.Noclip
    btn.Text = Settings.Noclip and "Noclip: เปิด ✅" or "Noclip: ปิด ❌"
    btn.BackgroundColor3 = Settings.Noclip and Color3.fromRGB(35, 120, 70) or Color3.fromRGB(40, 40, 55)
end)

local OriginalWalkSpeed = 16
local SpeedBtn = MakeBtn(167, "เดินเร็ว: ปิด ❌", function(btn)
    Settings.WalkSpeed = not Settings.WalkSpeed
    btn.Text = Settings.WalkSpeed and "เดินเร็ว: เปิด ✅" or "เดินเร็ว: ปิด ❌"
    btn.BackgroundColor3 = Settings.WalkSpeed and Color3.fromRGB(35, 120, 70) or Color3.fromRGB(40, 40, 55)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = Settings.WalkSpeed and Settings.SpeedValue or OriginalWalkSpeed end
end)

local CoinBtn = MakeBtn(229, "เก็บเหรียญ: ปิด ❌", function(btn)
    Settings.AutoCoin = not Settings.AutoCoin
    btn.Text = Settings.AutoCoin and "เก็บเหรียญ: เปิด ✅" or "เก็บเหรียญ: ปิด ❌"
    btn.BackgroundColor3 = Settings.AutoCoin and Color3.fromRGB(35, 120, 70) or Color3.fromRGB(40, 40, 55)
end)

local AuraBtn = MakeBtn(291, "มีดออโต้ (200): ปิด ❌", function(btn)
    Settings.AuraKill = not Settings.AuraKill
    btn.Text = Settings.AuraKill and "มีดออโต้ (200): เปิด ✅" or "มีดออโต้ (200): ปิด ❌"
    btn.BackgroundColor3 = Settings.AuraKill and Color3.fromRGB(35, 120, 70) or Color3.fromRGB(40, 40, 55)
end)

local AimbotBtn = MakeBtn(353, "Aimbot นายอำเภอ: ปิด ❌", function(btn)
    Settings.Aimbot = not Settings.Aimbot
    btn.Text = Settings.Aimbot and "Aimbot นายอำเภอ: เปิด ✅" or "Aimbot นายอำเภอ: ปิด ❌"
    btn.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(35, 120, 70) or Color3.fromRGB(40, 40, 55)
end)

local FlingMurdererBtn = MakeBtn(415, "บินชนฆาตกร: ปิด ❌", function(btn)
    Settings.FlingMurderer = not Settings.FlingMurderer
    btn.Text = Settings.FlingMurderer and "บินชนฆาตกร: เปิด ✅" or "บินชนฆาตกร: ปิด ❌"
    btn.BackgroundColor3 = Settings.FlingMurderer and Color3.fromRGB(35, 120, 70) or Color3.fromRGB(40, 40, 55)
end)

-- ระบบตรวจสอบบทบาท
local RoleCache = {}
local ESPCache = {}
local GunCache = {}

local function RemoveESP(player)
    if ESPCache[player] then
        if ESPCache[player].Box then ESPCache[player].Box:Remove() end
        if ESPCache[player].NameText then ESPCache[player].NameText:Remove() end
        ESPCache[player] = nil
    end
    RoleCache[player] = nil
end

local function RemoveGunESP(gun)
    if GunCache[gun] then
        if GunCache[gun].Box then GunCache[gun].Box:Remove() end
        if GunCache[gun].Text then GunCache[gun].Text:Remove() end
        GunCache[gun] = nil
    end
end

local function UpdatePlayerRole(player)
    local char = player.Character
    if not char then return "Innocent" end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return "Innocent" end

    local function checkContainer(container)
        if not container then return nil end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") or name:find("blade") or name:find("murderer") then
                    return "Murderer"
                elseif name:find("gun") or name:find("revolver") or name:find("sheriff") then
                    return "Sheriff"
                end
            end
        end
        return nil
    end

    local role = checkContainer(char)
    if role then return role end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        role = checkContainer(backpack)
        if role then return role end
    end
    
    return "Innocent"
end

-- ติดตามผู้เล่นเข้า-ออก
local function SetupPlayerTracking(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        RoleCache[player] = UpdatePlayerRole(player)
    end)
    RoleCache[player] = UpdatePlayerRole(player)
end

for _, p in ipairs(Players:GetPlayers()) do
    SetupPlayerTracking(p)
end

Players.PlayerAdded:Connect(SetupPlayerTracking)
getgenv().MM2_PlayerRemoving = Players.PlayerRemoving:Connect(RemoveESP)

-- ระบบ Noclip
local OriginalCanCollide = {}
getgenv().MM2_NoclipConnection = RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    if Settings.Noclip or Settings.AutoCoin then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if OriginalCanCollide[part] == nil then
                    OriginalCanCollide[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    else
        for part, canCollide in pairs(OriginalCanCollide) do
            if part:IsDescendantOf(Workspace) then
                part.CanCollide = canCollide
            end
        end
        table.clear(OriginalCanCollide)
    end
end)

-- ระบบเดินเร็ว
getgenv().MM2_SpeedConnection = RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum and hum.Health > 0 and Settings.WalkSpeed then
        hum.WalkSpeed = Settings.SpeedValue
    end
end)

-- ระบบ Aura Kill
getgenv().MM2_AuraConnection = RunService.Heartbeat:Connect(function()
    if not Settings.AuraKill then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    for _, p in ipairs(Players:GetPlayers()) do
        RoleCache[p] = UpdatePlayerRole(p)
    end
    local myRole = RoleCache[LocalPlayer] or UpdatePlayerRole(LocalPlayer)

    local activeTool = char:FindFirstChildOfClass("Tool")
    local toolName = activeTool and activeTool.Name:lower() or ""
    local holdingKnife = (myRole == "Murderer") or (toolName:find("knife") or toolName:find("blade"))

    if holdingKnife then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local pChar = player.Character
                local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart")
                local pHum = pChar and pChar:FindFirstChild("Humanoid")
                
                if pHrp and pHum and pHum.Health > 0 then
                    local dist = (hrp.Position - pHrp.Position).Magnitude
                    if dist <= Settings.AuraRange then
                        pcall(function()
                            if activeTool and activeTool:FindFirstChild("Handle") then
                                firetouchinterest(activeTool.Handle, pHrp, 0)
                                firetouchinterest(activeTool.Handle, pHrp, 1)
                            end
                        end)
                    end
                end
            end
        end
    end
end)

-- ระบบ Aimbot Sheriff
getgenv().MM2_AimbotConnection = RunService.RenderStepped:Connect(function()
    if not Settings.Aimbot then return end

    local myRole = RoleCache[LocalPlayer] or UpdatePlayerRole(LocalPlayer)
    if myRole ~= "Sheriff" then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChild("Humanoid")
    local activeTool = char:FindFirstChildOfClass("Tool")
    local holdingGun = activeTool and (activeTool.Name:lower():find("gun") or activeTool.Name:lower():find("revolver"))
    
    if not hrp or not head or not hum or hum.Health <= 0 or not holdingGun then return end

    local murderer = nil
    local closestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and RoleCache[player] == "Murderer" then
            local pChar = player.Character
            local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart")
            local pHead = pChar and pChar:FindFirstChild("Head")
            local pHum = pChar and pChar:FindFirstChild("Humanoid")
            
            if pHrp and pHead and pHum and pHum.Health > 0 then
                local dist = (hrp.Position - pHrp.Position).Magnitude
                if dist <= Settings.AimbotRange and dist < closestDist then
                    closestDist = dist
                    murderer = pHead
                end
            end
        end
    end

    if murderer then
        local targetCF = CFrame.new(Camera.CFrame.Position, murderer.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, Settings.AimbotSmooth)
        
        local dir = (murderer.Position - head.Position).Unit
        hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(dir.X, 0, dir.Z) + hrp.Position)
    end
end)

-- ระบบ Auto Coin
local ProcessedCoins = {}
local IsFlying = false

LocalPlayer.CharacterAdded:Connect(function()
    table.clear(ProcessedCoins)
    IsFlying = false
end)

getgenv().MM2_CoinConnection = RunService.Heartbeat:Connect(function()
    if not Settings.AutoCoin or IsFlying then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not hum or hum.Health <= 0 or not hrp then return end

    local CoinContainer = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("CoinContainer")
    if not CoinContainer then
        for _, v in ipairs(Workspace:GetChildren()) do
            if v:FindFirstChild("CoinContainer") then
                CoinContainer = v.CoinContainer
                break
            end
        end
    end

    if not CoinContainer then return end

    local CoinChildren = CoinContainer:GetChildren()
    if #CoinChildren == 0 then table.clear(ProcessedCoins) return end

    local ClosestCoin = nil
    local ShortestDist = math.huge

    for _, coin in ipairs(CoinChildren) do
        if not ProcessedCoins[coin] and (coin.Name == "Coin" or coin:FindFirstChild("CoinVisual")) then
            local coinPart = coin:IsA("BasePart") and coin or coin:FindFirstChildWhichIsA("BasePart")
            if coinPart then
                local dist = (hrp.Position - coinPart.Position).Magnitude
                if dist < ShortestDist then
                    ShortestDist = dist
                    ClosestCoin = coin
                end
            end
        end
    end

    if ClosestCoin then
        local coinPart = ClosestCoin:IsA("BasePart") and ClosestCoin or ClosestCoin:FindFirstChildWhichIsA("BasePart")
        if coinPart then
            ProcessedCoins[ClosestCoin] = true
            IsFlying = true
            
            local conn
            conn = RunService.RenderStepped:Connect(function()
                if not Settings.AutoCoin or not coinPart or not coinPart.Parent or not hrp or not hum or hum.Health <= 0 then
                    conn:Disconnect()
                    IsFlying = false
                    return
                end

                local dir = (coinPart.Position - hrp.Position)
                if dir.Magnitude < 3 then
                    conn:Disconnect()
                    IsFlying = false
                    hrp.Velocity = Vector3.new(0, 0, 0)
                else
                    hrp.Velocity = dir.Unit * Settings.CoinSpeed
                    hum:Move(Vector3.new(dir.X, 0, dir.Z).Unit * Settings.CoinSpeed)
                end
            end)
        end
    end
end)

-- ==============================================================================
-- 🚀 บินทะลุไปชนฆาตกร | ความเร็ว 20 เท่าเก็บเหรียญ
-- ==============================================================================
local FlingFlying = false

getgenv().MM2_FlingMurdererConn = RunService.RenderStepped:Connect(function()
    if not Settings.FlingMurderer or IsFlying then 
        FlingFlying = false
        return 
    end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return end
    
    local Values = Workspace:FindFirstChild("Values")
    local GameState = Values and Values:FindFirstChild("GameState")
    if not GameState then return end
    local State = GameState.Value
    
    -- ทำงานแค่ตอนนับถอยหลัง
    if State ~= "Intermission" and State ~= "Preparing" then
        FlingFlying = false
        return
    end
    
    -- หาฆาตกร
    local TargetPart = nil
    for _, Plr in ipairs(Players:GetPlayers()) do
        if Plr ~= LocalPlayer and RoleCache[Plr] == "Murderer" and Plr.Character then
            TargetPart = Plr.Character:FindFirstChild("HumanoidRootPart")
            if TargetPart then break end
        end
    end
    if not TargetPart then return end
    
    -- เริ่มบินไปหา
    FlingFlying = true
    
    local conn
    conn = RunService.RenderStepped:Connect(function()
        -- หยุดเมื่อปิดระบบ / เกมเริ่ม / ตัวหาย
        if not Settings.FlingMurderer 
            or not TargetPart or not TargetPart.Parent 
            or not hrp or not hum or hum.Health <= 0
            or (GameState.Value ~= "Intermission" and GameState.Value ~= "Preparing") then
            conn:Disconnect()
            FlingFlying = false
            hrp.Velocity = Vector3.new(0, 0, 0)
            -- คืนค่า CanCollide
            for _, Part in ipairs(char:GetDescendants()) do
                if Part:IsA("BasePart") and OriginalCanCollide[Part] ~= nil then
                    Part.CanCollide = OriginalCanCollide[Part]
                end
            end
            return
        end
        
        -- ทิศทางไปหาฆาตกร
        local dir = (TargetPart.Position - hrp.Position)
        
        -- ใกล้แล้ว → ชนแรง!
        if dir.Magnitude < 3.5 then
            conn:Disconnect()
            FlingFlying = false
            hrp.Velocity = dir.Unit * Settings.FlingSpeed + Vector3.new(0, 6, 0)
            task.delay(0.3, function()
                hrp.Velocity = Vector3.new(0, 0, 0)
            end)
        else
            -- บินทะลุไปหาเหมือนเก็บเหรียญ ความเร็ว 20
            hrp.Velocity = dir.Unit * Settings.FlingSpeed
            hum:Move(Vector3.new(dir.X, 0, dir.Z).Unit * Settings.FlingSpeed)
            -- ปิดการชนเพื่อทะลุผ่าน
            for _, Part in ipairs(char:GetDescendants()) do
                if Part:IsA("BasePart") then Part.CanCollide = false end
            end
        end
    end)
end)

-- ระบบ ESP หลัก
local LastUpdate = 0
getgenv().MM2_Connection = RunService.RenderStepped:Connect(function()
    local Now = os.clock()
    
    if Now - LastUpdate >= 0.2 then
        LastUpdate = Now
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                RoleCache[player] = UpdatePlayerRole(player)
            end
        end
    end

    local myRole = RoleCache[LocalPlayer] or UpdatePlayerRole(LocalPlayer)
    StatusLabel.Text = "บทบาท: " .. myRole

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- ESP ผู้เล่น
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pChar = player.Character
            if pChar and pChar:FindFirstChild("HumanoidRootPart") then
                local pHum = pChar:FindFirstChild("Humanoid")
                if pHum and pHum.Health > 0 then
                    local targetRole = RoleCache[player] or "Innocent"
                    local ShowBox = false
                    local BoxColor = Color3.fromRGB(231, 76, 60)

                    if myRole == "Innocent" then
                        if targetRole == "Murderer" then ShowBox = true; BoxColor = Color3.fromRGB(231, 76, 60) end
                        if targetRole == "Sheriff" then ShowBox = true; BoxColor = Color3.fromRGB(52, 152, 219) end
                    elseif myRole == "Murderer" then
                        if targetRole == "Sheriff" then ShowBox = true; BoxColor = Color3.fromRGB(52, 152, 219) end
                        if targetRole == "Innocent" then ShowBox = true; BoxColor = Color3.fromRGB(231, 76, 60) end
                    elseif myRole == "Sheriff" then
                        if targetRole == "Murderer" then ShowBox = true; BoxColor = Color3.fromRGB(231, 76, 60) end
                    end

                    if ShowBox then
                        local pHrp = pChar.HumanoidRootPart
                        local pHead = pChar:FindFirstChild("Head")
                        if pHead then
                            local Pos, OnScr = Camera:WorldToViewportPoint(pHead.Position)
                            
                            if OnScr then
                                if not ESPCache[player] then
                                    ESPCache[player] = {
                                        Box = Drawing.new("Square"),
                                        NameText = Drawing.new("Text")
                                    }
                                    ESPCache[player].Box.Thickness = 2
                                    ESPCache[player].Box.Filled = false
                                    ESPCache[player].NameText.Size = 13
                                    ESPCache[player].NameText.Center = true
                                end
                                
                                local Box = ESPCache[player].Box
                                local NameText = ESPCache[player].NameText
                                
                                local HPos, HOn = Camera:WorldToViewportPoint(pHead.Position)
                                local FPos, FOn = Camera:WorldToViewportPoint(pHrp.Position - Vector3.new(0, 1, 0))
                                
                                if HOn and FOn then
                                    local H = math.abs(HPos.Y - FPos.Y) * 1.8
                                    local W = H * 0.6
                                    Box.Color = BoxColor
                                    Box.Position = Vector2.new(HPos.X - W/2, HPos.Y - H/2)
                                    Box.Size = Vector2.new(W, H)
                                    Box.Visible = true
                                    
                                    local DistStr = myHrp and (" [" .. math.floor((myHrp.Position - pHrp.Position).Magnitude) .. "m]") or ""
                                    NameText.Text = targetRole .. DistStr
                                    NameText.Color = BoxColor
                                    NameText.Position = Vector2.new(HPos.X, HPos.Y - H - 18)
                                    NameText.Visible = true
                                end
                            elseif ESPCache[player] then
                                ESPCache[player].Box.Visible = false
                                ESPCache[player].NameText.Visible = false
                            end
                        end
                    elseif ESPCache[player] then
                        ESPCache[player].Box.Visible = false
                        ESPCache[player].NameText.Visible = false
                    end
                else
                    RemoveESP(player)
                end
            else
                RemoveESP(player)
            end
        end
    end

    -- ESP ปืนตกพื้น
    local ActiveGuns = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("revolver") or obj.Name:lower():find("drop")) then
            local IsEquipped = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and (obj:IsDescendantOf(p.Character) or obj:IsDescendantOf(p:FindFirstChild("Backpack"))) then
                    IsEquipped = true
                    break
                end
            end

            if not IsEquipped then
                ActiveGuns[obj] = true
                local Handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                if Handle then
                    local Pos, OnScr = Camera:WorldToViewportPoint(Handle.Position)
                    if OnScr then
                        if not GunCache[obj] then
                            GunCache[obj] = {
                                Box = Drawing.new("Square"),
                                Text = Drawing.new("Text")
                            }
                            GunCache[obj].Box.Color = Color3.fromRGB(255, 105, 180)
                            GunCache[obj].Box.Thickness = 1.5
                            GunCache[obj].Box.Filled = false
                            GunCache[obj].Text.Color = Color3.fromRGB(255, 105, 180)
                            GunCache[obj].Text.Size = 13
                            GunCache[obj].Text.Center = true
                        end
                        
                        local GunBox = GunCache[obj].Box
                        local GunText = GunCache[obj].Text
                        
                        GunBox.Size = Vector2.new(22, 22)
                        GunBox.Position = Vector2.new(Pos.X - 11, Pos.Y - 11)
                        GunBox.Visible = true
                        
                        local DistStr = myHrp and (" [" .. math.floor((myHrp.Position - Handle.Position).Magnitude) .. "m]") or ""
                        GunText.Text = "[ปืน] " .. DistStr
                        GunText.Position = Vector2.new(Pos.X, Pos.Y - 32)
                        GunText.Visible = true
                    elseif GunCache[obj] then
                        GunCache[obj].Box.Visible = false
                        GunCache[obj].Text.Visible = false
                    end
                end
            end
        end
    end

    for gun, _ in pairs(GunCache) do
        if not ActiveGuns[gun] or not gun.Parent then
            RemoveGunESP(gun)
        end
    end
end)

print("✅ MM2 Mobile Hub โหลดสำเร็จ! กดปุ่ม 🔪 เพื่อเปิดเมนู")
