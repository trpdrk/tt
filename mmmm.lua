-- ==============================================================================
-- DELTA HUB - MM2 | บินชนฆาตกร ตรงจุดที่ต้องการ
-- ทำงาน: เกมสุ่มบทบาทเสร็จ → นับถอยหลังเริ่ม → บินทันที ก่อนเกมเริ่มจริง
-- ==============================================================================

if not Drawing or not getgenv then
    print("❌ Executor ไม่รองรับ")
    return
end

-- เคลียร์ระบบเก่า
if getgenv().MM2_Loaded then
    for _, v in pairs(getconnections(game:GetService("RunService").Heartbeat)) do v:Disable() end
    for _, v in pairs(getconnections(game:GetService("RunService").RenderStepped)) do v:Disable() end
end
getgenv().MM2_Loaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ตัวแปรหลัก
local Settings = {
    Noclip = false,
    AutoCoin = false,
    WalkSpeed = false,
    AuraKnife = false,
    Aimbot = false,
    FlingMurderer = false,
    SpeedValue = 27,
    CoinSpeed = 20,
    FlingSpeed = 20,
    AuraRange = 200,
    AimbotRange = 120,
    AimbotSmooth = 0.35
}

local RoleCache = {}
local ESPCache = {}
local GunCache = {}
local IsFlying = false
local OriginalCanCollide = {}
local RoleAssigned = false
local GameStarted = false

-- สร้าง UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2Hub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 560)
MainFrame.Position = UDim2.new(0.02, 0, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
Title.Text = "  🔪 DELTA HUB - MM2"
Title.TextColor3 = Color3.fromRGB(255, 90, 90)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -30, 0, 30)
StatusLabel.Position = UDim2.new(0, 15, 0, 65)
StatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
StatusLabel.Text = "สถานะ: รอสุ่มบทบาท..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 8)

-- ฟังก์ชันสร้างปุ่ม
local function CreateButton(name, posY, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -30, 0, 55)
    Btn.Position = UDim2.new(0, 15, 0, posY)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Btn.Text = name .. ": ปิด ❌"
    Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 16
    Btn.AutoButtonColor = false
    Btn.Parent = MainFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(function()
        local newState = not Settings[name]
        Settings[name] = newState
        Btn.Text = name .. ": " .. (newState and "เปิด ✅" or "ปิด ❌")
        Btn.BackgroundColor3 = newState and Color3.fromRGB(30, 90, 60) or Color3.fromRGB(40, 40, 60)
        callback(newState)
    end)
    return Btn
end

-- ปุ่มต่างๆ
CreateButton("Noclip", 110, function(state) Settings.Noclip = state end)
CreateButton("WalkSpeed", 175, function(state) Settings.WalkSpeed = state end)
CreateButton("AutoCoin", 240, function(state) Settings.AutoCoin = state end)
CreateButton("AuraKnife", 305, function(state) Settings.AuraKnife = state end)
CreateButton("Aimbot", 370, function(state) Settings.Aimbot = state end)
CreateButton("FlingMurderer", 435, function(state) Settings.FlingMurderer = state end)

-- ตรวจสอบบทบาทจากค่าในตัวละคร
local function RefreshRoles()
    RoleAssigned = false
    local MurdererFound = false
    
    for _, Plr in ipairs(Players:GetPlayers()) do
        if Plr ~= LocalPlayer and Plr.Character then
            local RoleVal = Plr.Character:FindFirstChild("Role")
            if RoleVal and RoleVal:IsA("StringValue") then
                local OldRole = RoleCache[Plr]
                RoleCache[Plr] = RoleVal.Value
                
                -- ถ้าเพิ่งได้บทบาท แสดงว่าสุ่มเสร็จแล้ว
                if not OldRole or OldRole == "" then
                    if RoleVal.Value == "Murderer" then MurdererFound = true end
                    RoleAssigned = true
                end
            end
        end
    end
    return MurdererFound
end

-- ลบ ESP
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

Players.PlayerRemoving:Connect(RemoveESP)

-- ระบบทะลุผ่าน
RunService.Stepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char then return end
    local Hum = Char:FindFirstChild("Humanoid")
    local Root = Char:FindFirstChild("HumanoidRootPart")
    if not Hum or Hum.Health <= 0 or not Root then return end

    if Settings.Noclip then
        for _, Part in ipairs(Char:GetDescendants()) do
            if Part:IsA("BasePart") then Part.CanCollide = false end
        end
    else
        for Part, Orig in pairs(OriginalCanCollide) do
            if Part and Part.Parent then Part.CanCollide = Orig end
        end
    end

    if Settings.WalkSpeed then Hum.WalkSpeed = Settings.SpeedValue end
end)

-- ระบบเก็บเหรียญ
local ProcessedCoins = {}
LocalPlayer.CharacterAdded:Connect(function() 
    ProcessedCoins = {} 
    RoleAssigned = false
    GameStarted = false
end)

RunService.Heartbeat:Connect(function()
    if not Settings.AutoCoin or IsFlying then return end
    
    local Char = LocalPlayer.Character
    if not Char then return end
    local Hum = Char:FindFirstChild("Humanoid")
    local Root = Char:FindFirstChild("HumanoidRootPart")
    if not Hum or Hum.Health <= 0 or not Root then return end

    local NearestCoin, Dist = nil, math.huge
    
    for _, Desc in ipairs(Workspace:GetDescendants()) do
        if Desc.Name == "Coin" and Desc:IsA("BasePart") and not ProcessedCoins[Desc] then
            local CDist = (Root.Position - Desc.Position).Magnitude
            if CDist < Dist then
                Dist = CDist
                NearestCoin = Desc
            end
        end
    end
    
    if not NearestCoin then return end
    IsFlying = true
    
    local Conn
    Conn = RunService.RenderStepped:Connect(function()
        if not Settings.AutoCoin or not NearestCoin or not NearestCoin.Parent then
            Conn:Disconnect()
            IsFlying = false
            Root.Velocity = Vector3.new(0, 0, 0)
            return
        end
        
        local Dir = (NearestCoin.Position - Root.Position)
        if Dir.Magnitude < 2.5 then
            ProcessedCoins[NearestCoin] = true
            Conn:Disconnect()
            IsFlying = false
            Root.Velocity = Vector3.new(0, 0, 0)
        else
            Root.Velocity = Dir.Unit * Settings.CoinSpeed
        end
    end)
end)

-- ==============================================================================
-- 🚀 บินชนฆาตกร - ตรงจุดตามที่ต้องการ
-- ลำดับ: รอสุ่มบทบาทเสร็จ → นับถอยหลังเริ่ม → บินทันที
-- ==============================================================================
local FlingActive = false
local FlingConn = nil

-- รีเซ็ตเมื่อเริ่มตาใหม่
LocalPlayer.CharacterAdded:Connect(function()
    RoleAssigned = false
    GameStarted = false
    FlingActive = false
    if FlingConn then FlingConn:Disconnect() end
end)

RunService.RenderStepped:Connect(function()
    -- ปิดระบบเมื่อปิดปุ่ม
    if not Settings.FlingMurderer then
        FlingActive = false
        return
    end
    
    local Char = LocalPlayer.Character
    if not Char then return end
    local Hum = Char:FindFirstChild("Humanoid")
    local Root = Char:FindFirstChild("HumanoidRootPart")
    if not Hum or not Root or Hum.Health <= 0 then return end
    
    -- อ่านสถานะเกม
    local Values = Workspace:FindFirstChild("Values")
    local GameState = Values and Values:FindFirstChild("GameState")
    local State = GameState and GameState.Value or ""
    
    -- ตรวจสอบว่าสุ่มบทบาทเสร็จหรือยัง
    RefreshRoles()
    
    -- อัปเดตสถานะใน UI
    if State == "Intermission" then
        StatusLabel.Text = "⏳ รอสุ่มบทบาทให้ผู้เล่น..."
    elseif State == "Preparing" then
        if not RoleAssigned then
            StatusLabel.Text = "⏳ กำลังสุ่มบทบาท..."
        else
            StatusLabel.Text = "✅ บทบาทเสร็จ! นับถอยหลัง → บินไป!"
        end
    elseif State == "Playing" then
        StatusLabel.Text = "🎮 เกมเริ่มแล้ว"
        GameStarted = true
        FlingActive = false
        return
    end
    
    -- ================= ส่วนสำคัญที่สุด =================
    -- เงื่อนไขบิน: สุ่มบทบาทเสร็จแล้ว + อยู่ในช่วงนับถอยหลัง + ยังไม่เริ่มเกม
    if RoleAssigned and State == "Preparing" and not GameStarted then
        
        -- หาตำแหน่งฆาตกร
        local MurdererPart = nil
        for _, Plr in ipairs(Players:GetPlayers()) do
            if Plr ~= LocalPlayer and RoleCache[Plr] == "Murderer" then
                if Plr.Character then
                    MurdererPart = Plr.Character:FindFirstChild("HumanoidRootPart")
                    if MurdererPart then break end
                end
            end
        end
        
        if not MurdererPart then return end
        
        -- เริ่มบิน
        if not FlingActive then
            FlingActive = true
            StatusLabel.Text = "🚀 กำลังบินไปหาฆาตกร!"
        end
        
        -- คำนวณทิศทางและระยะ
        local Dir = (MurdererPart.Position - Root.Position)
        local Dist = Dir.Magnitude
        Dir = Dir.Unit
        
        -- บินทะลุไปหา ความเร็ว 20 เท่าเก็บเหรียญ
        if Dist > 3.5 then
            Root.Velocity = Dir * Settings.FlingSpeed
            Hum:MoveTo(MurdererPart.Position)
            -- ปิดการชนเพื่อทะลุผ่าน
            for _, Part in ipairs(Char:GetDescendants()) do
                if Part:IsA("BasePart") then Part.CanCollide = false end
            end
        else
            -- ถึงแล้ว → พุ่งชนแรงๆ ก่อนเกมเริ่ม!
            Root.Velocity = Dir * 35 + Vector3.new(0, 8, 0)
            task.delay(0.5, function()
                if Root then Root.Velocity = Vector3.new(0, 0, 0) end
            end)
        end
        
    elseif State == "Playing" then
        -- เกมเริ่มแล้ว หยุดทันที
        FlingActive = false
    end
end)

-- ระบบ ESP
RunService.RenderStepped:Connect(function()
    local MyChar = LocalPlayer.Character
    local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
    
    -- แสดงระยะฆาตกร
    local MurdererDist = ""
    for Plr, Role in pairs(RoleCache) do
        if Role == "Murderer" and Plr.Character and MyRoot then
            local PRoot = Plr.Character:FindFirstChild("HumanoidRootPart")
            if PRoot then 
                MurdererDist = " | Murderer [" .. math.floor((MyRoot.Position - PRoot.Position).Magnitude) .. "m]" 
            end
        end
    end
    if MurdererDist ~= "" then
        StatusLabel.Text = StatusLabel.Text .. MurdererDist
    end

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

                    if targetRole == "Innocent" then
                        -- ไม่แสดง ESP คนธรรมดา
                    elseif targetRole == "Murderer" then
                        ShowBox = true
                        BoxColor = Color3.fromRGB(231, 76, 60)
                    elseif targetRole == "Sheriff" then
                        ShowBox = true
                        BoxColor = Color3.fromRGB(52, 152, 219)
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
                                    
                                    local DistStr = MyRoot and (" [" .. math.floor((MyRoot.Position - pHrp.Position).Magnitude) .. "m]") or ""
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
        if obj:IsA("Tool") and (string.lower(obj.Name):find("gun") or string.lower(obj.Name):find("revolver") or string.lower(obj.Name):find("drop")) then
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
                        
                        local DistStr = MyRoot and (" [" .. math.floor((MyRoot.Position - Handle.Position).Magnitude) .. "m]") or ""
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

print("✅ โหลดสำเร็จ! บินจะเริ่มตอนนับถอยหลังทันทีที่สุ่มบทบาทเสร็จ")
