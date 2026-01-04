local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/TanhIsMe/fluent-ui/refs/heads/main/Fluent.txt"))();

-- Âm thanh khởi động
local startupSound = Instance.new("Sound")
startupSound.SoundId = "rbxassetid://8594342648"
startupSound.Volume = 2 -- Điều chỉnh âm lượng nếu cần
startupSound.Looped = false -- Không lặp lại âm thanh
startupSound.Parent = game.CoreGui-- Đặt parent vào CoreGui để đảm bảo âm thanh phát
startupSound:Play() -- Phát âm thanh khi script chạy

-- Tạo cửa sổ chính
local Window = Library:CreateWindow{
    Title = "Menu Injector Roblox",
    SubTitle = "by NtanhNeConn",
    TabWidth = 160,
    Size = UDim2.fromOffset(1280, 860),
    Resize = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl -- Phím thu nhỏ
}



local MainTab = Window:AddTab({ Title = "Main", Icon = "hammer" })
local SvTab = Window:AddTab({ Title = "Server", Icon = "earth" })
local AimTab = Window:AddTab({ Title = "AimBot", Icon = "crosshair" })
local ESPTab = Window:AddTab({ Title = "Visual", Icon = "eye" })
local PlayerTab = Window:AddTab({ Title = "Player Visual", Icon = "sliders-horizontal" })
local OptTab = Window:AddTab({ Title = "FPS Locker", Icon = "atom" })
local CDVNTab = Window:AddTab({ Title = "CDVN Mode", Icon = "boxes" })
local TeleTab = Window:AddTab({ Title = "Set Postion", Icon = "log-in" })
local SettingTab = Window:AddTab({ Title = "Settings", Icon = "cog" })

-- Biến toàn cục
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Fluent = Library -- Gán biến Fluent

local scriptEnabled = false
local selectedPlayer = nil -- Biến lưu player được chọn cho Spectate và Tween Player
local playerTweenInfo = nil
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local aimbotEnabled = false
local aimbotFOV = 50 -- FOV mặc định
local RunService = game:GetService("RunService")
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ====== GLOBAL CONFIG ======
getgenv().AntiAttack = false
getgenv().AntiAttackForce = 1000

-- ====== INTERNAL VAR ======
local HeartbeatConn = nil
local Character = nil
local HumanoidRootPart = nil
local IgnoreList = nil

local PushRadius = 5.6

-- ====== CORE FUNCTION ======
local function AntiAttackLoop()
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end

    local region = Region3.new(
        HumanoidRootPart.Position - Vector3.new(PushRadius, PushRadius, PushRadius),
        HumanoidRootPart.Position + Vector3.new(PushRadius, PushRadius, PushRadius)
    )

    local parts = workspace:FindPartsInRegion3(region, IgnoreList, 100)

    for _, part in ipairs(parts) do
        if part:IsA("BasePart")
            and not part.Anchored
            and not Players:GetPlayerFromCharacter(part.Parent)
        then
            local dir = part.Position - HumanoidRootPart.Position
            if dir.Magnitude <= PushRadius then
                part.AssemblyLinearVelocity =
                    dir.Unit * getgenv().AntiAttackForce
            end
        end
    end
end

-- ====== CHARACTER HANDLE ======
local function OnCharacterAdded(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 5)
    IgnoreList = char

    if getgenv().AntiAttack then
        if HeartbeatConn then
            HeartbeatConn:Disconnect()
        end
        HeartbeatConn = RunService.Heartbeat:Connect(AntiAttackLoop)
    end
end

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character)
end

-- ====== FLUENT GUI ======
-- YÊU CẦU: MainTab PHẢI TỒN TẠI

MainTab:AddToggle("AntiAttackToggle", {
    Title = "Anti Attack",
    Default = false
}):OnChanged(function(v)
    getgenv().AntiAttack = v

    if v then
        if HumanoidRootPart then
            if HeartbeatConn then
                HeartbeatConn:Disconnect()
            end
            HeartbeatConn = RunService.Heartbeat:Connect(AntiAttackLoop)
        end
    else
        if HeartbeatConn then
            HeartbeatConn:Disconnect()
            HeartbeatConn = nil
        end
    end
end)

MainTab:AddSlider("AntiAttackForce", {
    Title = "Anti Attack Force",
    Min = 0,
    Max = 1000,
    Default = 200,
    Rounding = 0
}):OnChanged(function(v)
    getgenv().AntiAttackForce = v
end)

local playerDropdown = MainTab:AddDropdown("Chọn người chơi", {
    Title = "Chọn người chơi",
    Description = "Danh sách người chơi",
    Values = {}, -- Danh sách người chơi sẽ được cập nhật sau
    Callback = function(Value)
        local selected = Players:FindFirstChild(Value)
        if selected then
            selectedPlayer = selected
            print("Đã chọn người chơi:", Value)
        else
            selectedPlayer = nil
            print("Không tìm thấy người chơi: ", Value)
        end
    end
})

-- Hàm làm mới danh sách người chơi
local function refreshPlayerList()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    playerDropdown:SetValues(playerNames) -- Cập nhật danh sách người chơi
end

-- Thêm TextBox để tìm tên người chơi
local playerSearchBox = MainTab:AddInput("Tìm người chơi", {
    Title = "Tìm người chơi",
    Description = "Nhập tên người chơi để tìm kiếm",
    Callback = function(Value)
        -- Lọc danh sách người chơi dựa trên từ khóa
        local filteredPlayers = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and string.find(string.lower(player.Name), string.lower(Value)) then
                table.insert(filteredPlayers, player.Name)
            end
        end
        playerDropdown:SetValues(filteredPlayers) -- Cập nhật danh sách người chơi
    end
})

-- Nút Refresh
MainTab:AddButton({
    Title = "Refresh",
    Description = "Làm mới danh sách người chơi",
    Callback = function()
        refreshPlayerList()
    end
})

refreshPlayerList()
-- Tab Player - Nút Spectate
MainTab:AddToggle("Spectate", {
    Title = "Xem Player",
    Description = "Bật/Tắt Xem Player",
    Callback = function(Value)
        if Value then
            if selectedPlayer and selectedPlayer.Character then
                localplr = LocalPlayer
                localplr.CameraMaxZoomDistance = 100
                localplr.CameraMinZoomDistance = 0.1
                workspace.CurrentCamera.CameraSubject = selectedPlayer.Character
            end
        else
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character
        end
    end
})




MainTab:AddButton({
    Title = "Teleport Player",
    Description = "Chọn player để dịch chuyển",
    Callback = function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        local LocalPlayer = Players.LocalPlayer

        -- nếu đã có GUI cũ thì hủy (tránh thừa popup)
        local old = game.CoreGui:FindFirstChild("TeleFixAllGui")
        if old then
            old:Destroy()
        end

        -- Tạo GUI mới
        local gui = Instance.new("ScreenGui")
        gui.Name = "TeleFixAllGui"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.Parent = game.CoreGui

        -- Frame chính
        local frame = Instance.new("Frame", gui)
        frame.Size = UDim2.new(0, 450, 0, 320)
        frame.Position = UDim2.new(0.5, -225, 0.5, -160)
        frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        frame.BorderSizePixel = 0

        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0, 10)

        -- Header (dùng để kéo)
        local headerH = 34
        local header = Instance.new("Frame", frame)
        header.Size = UDim2.new(1, 0, 0, headerH)
        header.Position = UDim2.new(0, 0, 0, 0)
        header.BackgroundTransparency = 1

        local title = Instance.new("TextLabel", header)
        title.Size = UDim2.new(1, -40, 1, 0)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "Tele Panel"
        title.TextColor3 = Color3.new(1,1,1)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 18
        title.TextXAlignment = Enum.TextXAlignment.Left

        local closeBtn = Instance.new("TextButton", header)
        closeBtn.Size = UDim2.new(0, 28, 0, 20)
        closeBtn.Position = UDim2.new(1, -36, 0, 7)
        closeBtn.Text = "⏻"
        closeBtn.Font = Enum.Font.SourceSansBold
        closeBtn.TextSize = 18
        closeBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
        closeBtn.TextColor3 = Color3.new(1,1,1)
        local closeCorner = Instance.new("UICorner", closeBtn); closeCorner.CornerRadius = UDim.new(0,6)

        -- Container bên dưới header (chứa cột)
        local container = Instance.new("Frame", frame)
        container.Size = UDim2.new(1, -10, 1, - (headerH + 10))
        container.Position = UDim2.new(0, 5, 0, headerH + 5)
        container.BackgroundTransparency = 1

        -- giúp kéo (hỗ trợ chuột + touch)
        do
            local dragging = false
            local dragStart, startPos, dragInput
            local function update(input)
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
            header.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = frame.Position
                    dragInput = input
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input == dragInput then
                    update(input)
                end
            end)
        end

        -- store để disconnect sau
        local addedConn, removingConn
        local layoutConns = {} -- để lưu connection của AbsoluteContentSize

        -- debounce refresh (nếu có nhiều event cùng lúc)
        local refreshScheduled = false
        local function scheduleRefresh()
            if refreshScheduled then return end
            refreshScheduled = true
            task.spawn(function()
                task.wait(0.08) -- gom các sự kiện trong 0.08s
                refreshScheduled = false
                if gui.Parent then
                    doRefresh()
                end
            end)
        end

        -- Hàm tạo nút teleport (không dùng gui:GetChildren luẩn quẩn)
        local function createTeleportButton(parent, plr, layoutOrder)
            local b = Instance.new("TextButton")
            b.Name = "tele_" .. plr.UserId
            b.Text = plr.Name
            b.Size = UDim2.new(1, -8, 0, 30)
            b.LayoutOrder = layoutOrder or 0
            b.BackgroundColor3 = Color3.fromRGB(40,40,40)
            b.TextColor3 = Color3.new(1,1,1)
            b.AutoButtonColor = true
            b.Parent = parent

            local bc = Instance.new("UICorner", b)
            bc.CornerRadius = UDim.new(0,6)

            b.MouseButton1Click:Connect(function()
                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
                    and plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local target = plr.Character.HumanoidRootPart
                    local dist = (hrp.Position - target.Position).Magnitude

                    if dist < 2000 then
                        hrp.CFrame = target.CFrame + Vector3.new(0,3,0)
                    else
                        local TweenService = game:GetService("TweenService")
                        local speed = 250
                        local time = math.clamp(dist / speed, 2, 30)
                        local info = TweenInfo.new(time, Enum.EasingStyle.Linear)
                        local goal = {CFrame = target.CFrame + Vector3.new(0, 3, 0)}
                        local tween = TweenService:Create(hrp, info, goal)
                        tween:Play()
                    end
                end
                -- đóng GUI khi teleport (nếu muốn giữ GUI mở thì bỏ dòng dưới)
                if gui and gui.Parent then
                    gui:Destroy()
                end
            end)
        end

        -- Hàm resize canvas cho mỗi ScrollingFrame dựa trên UIListLayout
        local function bindAutoCanvas(scrollingFrame, listLayout)
            local conn = listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
            end)
            -- init
            scrollingFrame.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y + 8)
            table.insert(layoutConns, conn)
        end

        -- Hàm thực sự build GUI dựa trên danh sách hiện tại
        function doRefresh()
            -- xóa các connection layout cũ
            for _,c in ipairs(layoutConns) do
                if c and c.Disconnect then
                    c:Disconnect()
                end
            end
            layoutConns = {}

            -- clear container
            for _, child in ipairs(container:GetChildren()) do
                child:Destroy()
            end

            -- lấy player và loại bỏ Local
            local players = Players:GetPlayers()
            local filtered = {}
            for _, p in ipairs(players) do
                if p ~= LocalPlayer then
                    table.insert(filtered, p)
                end
            end

            local count = #filtered
            if count == 0 then
                -- hiển thị label rỗng
                local lbl = Instance.new("TextLabel", container)
                lbl.Size = UDim2.new(1,0,0,30)
                lbl.Position = UDim2.new(0,0,0,0)
                lbl.BackgroundTransparency = 1
                lbl.Text = "No other players"
                lbl.TextColor3 = Color3.fromRGB(200,200,200)
                lbl.Font = Enum.Font.SourceSans
                lbl.TextSize = 16
                return
            end

            -- tính số hàng có thể hiển thị (dựa vào chiều cao frame) -> giúp chia cột sao cho phù hợp popup
            local frameInnerH = frame.Size.Y.Offset - headerH - 20
            local approxBtnH = 30
            local padding = 5
            local rowsCapacity = math.max(1, math.floor(frameInnerH / (approxBtnH + padding)))
            -- tính số cột tối thiểu cần (giới hạn 1..3)
            local cols = math.clamp(math.ceil(count / rowsCapacity), 1, 3)

            -- build columns (ScrollingFrame)
            local columns = {}
            for i = 1, cols do
                local sc = Instance.new("ScrollingFrame", container)
                sc.Name = "Col"..i
                local width = 1/cols
                sc.Size = UDim2.new(width, -8, 1, 0)
                sc.Position = UDim2.new((i-1)*width, 4, 0, 0)
                sc.ScrollBarThickness = 6
                sc.BackgroundTransparency = 1
                sc.CanvasSize = UDim2.new(0,0,0,0)
                sc.VerticalScrollBarInset = Enum.ScrollBarInset.Always

                local uic = Instance.new("UIListLayout", sc)
                uic.Padding = UDim.new(0,5)
                uic.SortOrder = Enum.SortOrder.LayoutOrder

                bindAutoCanvas(sc, uic)
                table.insert(columns, sc)
            end

            -- gán player vào cột sao cho mỗi cột ~ đều
            local perCol = math.ceil(count / #columns)
            local idx = 0
            for _, plr in ipairs(filtered) do
                idx = idx + 1
                local colIndex = math.min(#columns, math.floor((idx-1) / perCol) + 1)
                local col = columns[colIndex]
                createTeleportButton(col, plr, idx)
            end
        end

        -- gọi lần đầu
        doRefresh()

        -- Kết nối cập nhật (và dùng debounce scheduling)
        addedConn = Players.PlayerAdded:Connect(function()
            scheduleRefresh()
        end)
        removingConn = Players.PlayerRemoving:Connect(function()
            scheduleRefresh()
        end)

        -- khi đóng bằng nút
        closeBtn.MouseButton1Click:Connect(function()
            if addedConn and addedConn.Disconnect then addedConn:Disconnect() end
            if removingConn and removingConn.Disconnect then removingConn:Disconnect() end
            for _,c in ipairs(layoutConns) do if c and c.Disconnect then c:Disconnect() end end
            if gui and gui.Parent then gui:Destroy() end
        end)

        -- nếu GUI bị destroy từ bên ngoài cũng disconnect (phòng trường hợp)
        gui.Destroying:Connect(function()
            if addedConn and addedConn.Disconnect then addedConn:Disconnect() end
            if removingConn and removingConn.Disconnect then removingConn:Disconnect() end
            for _,c in ipairs(layoutConns) do if c and c.Disconnect then c:Disconnect() end end
        end)
    end
})
-- Noclip
local noclipConn
MainTab:AddToggle("Noclip", {
    Title = "Wallhack",
    Description = "Đi xuyên tường",
    Callback = function(Value)
        if Value then
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConn then
                noclipConn:Disconnect()
                noclipConn = nil
            end
            -- reset lại CanCollide khi tắt
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})
-- Rejoin Server
SvTab:AddButton({
    Title = "Rejoin Server",
    Description = "Thoát và vào lại server hiện tại",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
    end
})

-- Server Hop (random server)
SvTab:AddButton({
    Title = "Server Hop",
    Description = "Thoát và join server ngẫu nhiên",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local servers = {}
        local succ, result = pcall(function()
            return game:HttpGet(url)
        end)
        if succ then
            local data = HttpService:JSONDecode(result)
            for _,srv in ipairs(data.data) do
                if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                    table.insert(servers, srv.id)
                end
            end
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)], Players.LocalPlayer)
            end
        end
    end
})


-- Small Server (server ít người nhất)
SvTab:AddButton({
    Title = "Small Server",
    Description = "Join server ít người nhất",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local succ, result = pcall(function()
            return game:HttpGet(url)
        end)
        if succ then
            local data = HttpService:JSONDecode(result)
            local lowest,serverId = math.huge,nil
            for _,srv in ipairs(data.data) do
                if srv.playing < lowest and srv.id ~= game.JobId then
                    lowest = srv.playing
                    serverId = srv.id
                end
            end
            if serverId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, Players.LocalPlayer)
            end
        end
    end
})
-- Auto Chat Toggle (Fluent)
local autoChatEnabled = false
local chatMessages = {
    "?"
}
local chatDelay = 2 -- giây

MainTab:AddToggle("AutoChat", {
    Title = "Auto Chat",
    Description = "Tự động spam chat theo thứ tự",
    Callback = function(Value)
        autoChatEnabled = Value
        if autoChatEnabled then
            task.spawn(function()
                local i = 1
                while autoChatEnabled do
                    if #chatMessages > 0 then
                        -- Gửi chat
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local TextChatService = game:GetService("TextChatService")

                        local function sendChat(message)
                            if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                                local general = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                                if general then
                                    pcall(function() general:SendAsync(message) end)
                                end
                            else
                                local sayReq = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and 
                                               ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                                if sayReq then
                                    pcall(function() sayReq:FireServer(message, "All") end)
                                end
                            end
                        end

                        sendChat(chatMessages[i])

                        i = i + 1
                        if i > #chatMessages then i = 1 end
                    end
                    task.wait(chatDelay)
                end
            end)
        end
    end
})
-- Freeze NPC (đứng im, không tăng hitbox)
local freezeNpcEnabled = false
local npcConn
local npcAnchored = {}

MainTab:AddToggle("FreezeNPC", {
    Title = "Freeze NPC",
    Description = "Làm tất cả NPC đứng im, không cử động",
    Callback = function(Value)
        freezeNpcEnabled = Value
        if freezeNpcEnabled then
            -- Đóng băng toàn bộ NPC hiện có
            for _, npc in ipairs(workspace:GetDescendants()) do
                if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                    if not Players:GetPlayerFromCharacter(npc) then
                        local hrp = npc.HumanoidRootPart
                        if not npcAnchored[hrp] then
                            npcAnchored[hrp] = hrp.Anchored
                            hrp.Anchored = true
                        end
                        local hum = npc:FindFirstChild("Humanoid")
                        if hum then
                            hum.WalkSpeed = 0
                            hum.JumpPower = 0
                        end
                    end
                end
            end

            -- Auto đóng băng NPC mới spawn
            npcConn = workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("Humanoid") and obj.Parent:FindFirstChild("HumanoidRootPart") then
                    local npc = obj.Parent
                    if not Players:GetPlayerFromCharacter(npc) and freezeNpcEnabled then
                        local hrp = npc.HumanoidRootPart
                        if not npcAnchored[hrp] then
                            npcAnchored[hrp] = hrp.Anchored
                            hrp.Anchored = true
                        end
                        local hum = npc:FindFirstChild("Humanoid")
                        if hum then
                            hum.WalkSpeed = 0
                            hum.JumpPower = 0
                        end
                    end
                end
            end)
        else
            -- Reset về trạng thái gốc
            for hrp, wasAnchored in pairs(npcAnchored) do
                if hrp and hrp.Parent then
                    hrp.Anchored = wasAnchored
                    local hum = hrp.Parent:FindFirstChild("Humanoid")
                    if hum then
                        hum.WalkSpeed = 16 -- mặc định Roblox
                        hum.JumpPower = 50
                    end
                end
            end
            npcAnchored = {}
            if npcConn then npcConn:Disconnect() npcConn=nil end
        end
    end
})
--// Infinity Jump
local UserInputService = game:GetService("UserInputService")
local infJumpEnabled = false
local infJumpConnection

MainTab:AddToggle("InfinityJump", {
    Title = "Infinity Jump",
    Description = "Nhảy vô hạn",
    Default = false,
    Callback = function(Value)
        infJumpEnabled = Value
        if infJumpEnabled then
            infJumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if infJumpConnection then
                infJumpConnection:Disconnect()
                infJumpConnection = nil
            end
        end
    end
})
local Camera = workspace.CurrentCamera
local defaultFOV = Camera.FieldOfView
local superCamEnabled = false
local customFOV = 120 

MainTab:AddSlider("CameraFOVSlider", {
    Title = "Độ rộng FOV (Camera)",
    Min = 70,
    Max = 1000,
    Default = 120,
    Callback = function(Value)
        customFOV = Value
        if superCamEnabled then
            Camera.FieldOfView = customFOV
        end
    end
})

MainTab:AddToggle("SuperCamera", {
    Title = "Super Camera",
    Description = "Bật để mở rộng góc nhìn camera (có slider FOV)",
    Default = false,
    Callback = function(Value)
        superCamEnabled = Value
        if superCamEnabled then
            Camera.FieldOfView = customFOV
        else
            Camera.FieldOfView = defaultFOV
        end
    end
})



-- Hitbox Extender
local hitboxEnabled = false
local hitboxConn
local originalHitbox = {}

-- Biến chỉnh size và trong suốt
local hitboxSize = 100
local hitboxTransparency = 1 -- mặc định trong suốt

-- Slider chỉnh size
AimTab:AddSlider("HitboxSize", {
    Title = "Hitbox Size",
    Min = 1,
    Max = 200,
    Default = 100,
    Callback = function(Value)
        hitboxSize = Value
    end
})

-- Input box chỉnh trong suốt
AimTab:AddInput("HitboxTransparencyInput", {
    Title = "Hitbox Transparency",
    Placeholder = "Nhập giá trị từ 0 đến 1",
    Default = "1",
    Numeric = true, -- chỉ cho phép nhập số
    Callback = function(Value)
        local num = tonumber(Value) -- chuyển từ string sang number
        if num then
            if num < 0 then num = 0 end
            if num > 1 then num = 1 end
            hitboxTransparency = num
        end
    end
})

-- Toggle Hitbox Extender
AimTab:AddToggle("HitboxExtender", {
    Title = "Silent Aim",
    Description = "silent aim",
    Callback = function(Value)
        hitboxEnabled = Value
        if hitboxEnabled then
            -- Bật
            hitboxConn = game:GetService("RunService").Stepped:Connect(function()
                for _,plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            -- Lưu size gốc nếu chưa lưu
                            if not originalHitbox[plr.Name] then
                                originalHitbox[plr.Name] = hrp.Size
                            end
                            -- Áp dụng size + trong suốt từ slider
                            hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                            hrp.Transparency = hitboxTransparency
                            hrp.BrickColor = BrickColor.new("White")
                            hrp.Material = Enum.Material.Neon
                            hrp.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- Tắt
            if hitboxConn then hitboxConn:Disconnect() hitboxConn=nil end
            -- Khôi phục size gốc
            for _,plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and originalHitbox[plr.Name] then
                        hrp.Size = originalHitbox[plr.Name]
                        hrp.Transparency = 1
                        hrp.CanCollide = true
                    end
                end
            end
            originalHitbox = {}
        end
    end
})
local aimbotEnabled = false
local lockCamera = false
local skipWall = false
local aimVisibleOnly = false
local damageAura = false
local aimbotFOV = 50
local smoothAlpha = 0.3 -- độ mượt xoay camera (0.1 = chậm, 1 = tức thì)

-- Vòng tròn FOV
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 0.8
fovCircle.Color = Color3.fromRGB(0, 255, 0)
fovCircle.Filled = false
fovCircle.Visible = false

-- Màu FOV tùy chỉnh
local fovColor = Color3.fromRGB(0,255,0)
AimTab:AddColorpicker("FOVColor", {
    Title = "FOV Color",
    Default = fovColor,
    Callback = function(Value)
        fovColor = Value
        fovCircle.Color = fovColor
    end
})
-- Toggle show/hide FOV circle
local showFOV = false
AimTab:AddToggle("ShowFOVToggle", {
    Title = "Show FOV",
    Default = false,
    Callback = function(Value)
        showFOV = Value
        fovCircle.Visible = Value
    end
})


local function updateFovCircle()
    if fovCircle.Visible then
        local screenSize = Camera.ViewportSize
        local center = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
        local radius = math.clamp(aimbotFOV * 2, 10, 500)
        fovCircle.Position = center
        fovCircle.Radius = radius
        fovCircle.Color = fovColor
    end
end



-- Slider chỉnh FOV
local fovSlider = AimTab:AddSlider("AimbotFOVSlider", {
    Title = "FOV",
    Default = aimbotFOV,
    Min = 10,
    Max = 500,
    Callback = function(Value)
        aimbotFOV = Value
    end
})


-- Toggle chính
AimTab:AddToggle("AimbotToggle", {
    Title = "Aimbot",
    Description = "Bật/tắt aim hỗ trợ",
    Callback = function(Value)
        aimbotEnabled = Value
        fovCircle.Visible = aimbotEnabled or showFOV
    end
})


AimTab:AddToggle("LockCameraToggle", {
    Title = "Force Lock",
    Description = "Khoá camera vào player",
    Callback = function(Value)
        lockCamera = Value
    end
})

AimTab:AddToggle("SkipWallToggle", {
    Title = "Aim Skip Wall",
    Description = "Bỏ qua player bị che khuất",
    Callback = function(Value)
        skipWall = Value
    end
})

AimTab:AddToggle("AimVisibleToggle", {
    Title = "Aim Visible",
    Description = "Chỉ aim khi bắn/nhấn màn hình",
    Callback = function(Value)
        aimVisibleOnly = Value
    end
})
-- Check line-of-sight
local function isVisible(targetPos, targetChar)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local direction = (targetPos - Camera.CFrame.Position)
    local result = workspace:Raycast(Camera.CFrame.Position, direction, rayParams)
    if result and result.Instance then
        return result.Instance:IsDescendantOf(targetChar)
    end
    return true
end

-- Phát hiện khi bắn / nhấn màn hình
local userInput = game:GetService("UserInputService")
local isFiring = false
userInput.InputBegan:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isFiring = true
    end
end)
userInput.InputEnded:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isFiring = false
    end
end)
local function isEnemy(plr)
    if not teamCheck then
        return true -- nếu tắt teamCheck thì mọi player đều là enemy
    end
    if LocalPlayer.Team and plr.Team then
        return LocalPlayer.Team ~= plr.Team
    end
    return true
end

-- Aimbot logic
RunService.RenderStepped:Connect(function()
    if not (aimbotEnabled or lockCamera) then return end
    updateFovCircle()

    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local camPos = Camera.CFrame.Position
    local camLook = Camera.CFrame.LookVector

    local closestPlayer, closestAngle = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer and isEnemy(plr) and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local targetPos = plr.Character.HumanoidRootPart.Position
                local dir = (targetPos - camPos)
                if dir.Magnitude > 0 then
                    local dirUnit = dir.Unit
                    local dot = math.clamp(camLook:Dot(dirUnit), -1, 1)
                    local angle = math.deg(math.acos(dot))
                    if angle < aimbotFOV and angle < closestAngle then
                        if skipWall then
                            if isVisible(targetPos, plr.Character) then
                                closestAngle = angle
                                closestPlayer = plr
                            end
                        else
                            closestAngle = angle
                            closestPlayer = plr
                        end
                    end
                end
            end
        end
    end

    if closestPlayer then
        if aimVisibleOnly and not isFiring then return end
        local targetPos = closestPlayer.Character.HumanoidRootPart.Position
        local curr = Camera.CFrame
        local goal = CFrame.new(curr.Position, targetPos)

        if lockCamera then
            Camera.CFrame = goal
        elseif aimbotEnabled then
            Camera.CFrame = curr:Lerp(goal, smoothAlpha)
        end
    end
end)



-- Tạo Toggle trong Fluent UI
MainTab:AddToggle("spamReset", {
    Title = "Auto Spam Reset",
    Description = "spamReset",
    Default = false,
    Callback = function(Value)
        spamReset = Value
        if spamReset then
            task.spawn(function()
                while spamReset do
-- Reset Character Script
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function resetCharacter()
    if player.Character then
        player.Character:BreakJoints() -- hủy khớp => reset
    end
end

-- Gọi thử khi chạy
resetCharacter()

                    task.wait(0) -- chạy liên tục
                end
            end)
        end
    end
})
MainTab:AddButton({
    Title = "Kick Game",
    Description = "",
    Callback = function()
local player = game.Players.LocalPlayer
player:Kick("Success !")
    end
})
MainTab:AddButton({
    Title = "Terminal",
    Description = "",
    Callback = function()
if _G.SimpleSpyExecuted and type(_G.SimpleSpyShutdown) == "function" then
	print(pcall(_G.SimpleSpyShutdown))
end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Highlight =
	loadstring(
		game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub-Backup/main/SimpleSpyV3/mobilehighlight.lua")
	)()


local SimpleSpy2 = Instance.new("ScreenGui")
local Background = Instance.new("Frame")
local LeftPanel = Instance.new("Frame")
local LogList = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local RemoteTemplate = Instance.new("Frame")
local ColorBar = Instance.new("Frame")
local Text = Instance.new("TextLabel")
local Button = Instance.new("TextButton")
local RightPanel = Instance.new("Frame")
local CodeBox = Instance.new("Frame")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIGridLayout = Instance.new("UIGridLayout")
local FunctionTemplate = Instance.new("Frame")
local ColorBar_2 = Instance.new("Frame")
local Text_2 = Instance.new("TextLabel")
local Button_2 = Instance.new("TextButton")
local TopBar = Instance.new("Frame")
local Simple = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local ImageLabel = Instance.new("ImageLabel")
local MaximizeButton = Instance.new("TextButton")
local ImageLabel_2 = Instance.new("ImageLabel")
local MinimizeButton = Instance.new("TextButton")
local ImageLabel_3 = Instance.new("ImageLabel")
local ToolTip = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local gui = Instance.new("ScreenGui",Background)
local nextb = Instance.new("ImageButton", gui)
local gui = Instance.new("UICorner", nextb)

--Properties:

SimpleSpy2.Name = "SimpleSpy2"
SimpleSpy2.ResetOnSpawn = false

local SpyFind = CoreGui:FindFirstChild(SimpleSpy2.Name)

if SpyFind and SpyFind ~= SimpleSpy2 then
  SpyFind:Destroy()
end

Background.Name = "Background"
Background.Parent = SimpleSpy2
Background.BackgroundColor3 = Color3.new(1, 1, 1)
Background.BackgroundTransparency = 1
Background.Position = UDim2.new(0, 160, 0, 100)
Background.Size = UDim2.new(0, 450, 0, 268)
Background.Active = true
Background.Draggable = true

nextb.Position = UDim2.new(0,100,0,60)
nextb.Size = UDim2.new(0,40,0,40)
nextb.BackgroundColor3 = Color3.fromRGB(53, 52, 55)
nextb.Image = "rbxassetid://7072720870"
nextb.Active = true
nextb.Draggable = true
nextb.MouseButton1Down:connect(function()
nextb.Image = (Background.Visible and "rbxassetid://7072720870") or "rbxassetid://7072719338"
Background.Visible = not Background.Visible
end)

LeftPanel.Name = "LeftPanel"
LeftPanel.Parent = Background
LeftPanel.BackgroundColor3 = Color3.fromRGB(53, 52, 55)
LeftPanel.BorderSizePixel = 0
LeftPanel.Position = UDim2.new(0, 0, 0, 19)
LeftPanel.Size = UDim2.new(0, 131, 0, 249)

LogList.Name = "LogList"
LogList.Parent = LeftPanel
LogList.Active = true
LogList.BackgroundColor3 = Color3.new(1, 1, 1)
LogList.BackgroundTransparency = 1
LogList.BorderSizePixel = 0
LogList.Position = UDim2.new(0, 0, 0, 9)
LogList.Size = UDim2.new(0, 131, 0, 232)
LogList.CanvasSize = UDim2.new(0, 0, 0, 0)
LogList.ScrollBarThickness = 4

UIListLayout.Parent = LogList
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

RemoteTemplate.Name = "RemoteTemplate"
RemoteTemplate.Parent = LogList
RemoteTemplate.BackgroundColor3 = Color3.new(1, 1, 1)
RemoteTemplate.BackgroundTransparency = 1
RemoteTemplate.Size = UDim2.new(0, 117, 0, 27)

ColorBar.Name = "ColorBar"
ColorBar.Parent = RemoteTemplate
ColorBar.BackgroundColor3 = Color3.fromRGB(255, 242, 0)
ColorBar.BorderSizePixel = 0
ColorBar.Position = UDim2.new(0, 0, 0, 1)
ColorBar.Size = UDim2.new(0, 7, 0, 18)
ColorBar.ZIndex = 2

Text.Name = "Text"
Text.Parent = RemoteTemplate
Text.BackgroundColor3 = Color3.new(1, 1, 1)
Text.BackgroundTransparency = 1
Text.Position = UDim2.new(0, 12, 0, 1)
Text.Size = UDim2.new(0, 105, 0, 18)
Text.ZIndex = 2
Text.Font = Enum.Font.SourceSans
Text.Text = "TEXT"
Text.TextColor3 = Color3.new(1, 1, 1)
Text.TextSize = 14
Text.TextXAlignment = Enum.TextXAlignment.Left
Text.TextWrapped = true

Button.Name = "Button"
Button.Parent = RemoteTemplate
Button.BackgroundColor3 = Color3.new(0, 0, 0)
Button.BackgroundTransparency = 0.75
Button.BorderColor3 = Color3.new(1, 1, 1)
Button.Position = UDim2.new(0, 0, 0, 1)
Button.Size = UDim2.new(0, 117, 0, 18)
Button.AutoButtonColor = false
Button.Font = Enum.Font.SourceSans
Button.Text = ""
Button.TextColor3 = Color3.new(0, 0, 0)
Button.TextSize = 14

RightPanel.Name = "RightPanel"
RightPanel.Parent = Background
RightPanel.BackgroundColor3 = Color3.fromRGB(37, 36, 38)
RightPanel.BorderSizePixel = 0
RightPanel.Position = UDim2.new(0, 131, 0, 19)
RightPanel.Size = UDim2.new(0, 319, 0, 249)

CodeBox.Name = "CodeBox"
CodeBox.Parent = RightPanel
CodeBox.BackgroundColor3 = Color3.new(0.0823529, 0.0745098, 0.0784314)
CodeBox.BorderSizePixel = 0
CodeBox.Size = UDim2.new(0, 319, 0, 119)

ScrollingFrame.Parent = RightPanel
ScrollingFrame.Active = true
ScrollingFrame.BackgroundColor3 = Color3.new(1, 1, 1)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 0, 0.5, 0)
ScrollingFrame.Size = UDim2.new(1, 0, 0.5, -9)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4

UIGridLayout.Parent = ScrollingFrame
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
UIGridLayout.CellSize = UDim2.new(0, 94, 0, 27)

FunctionTemplate.Name = "FunctionTemplate"
FunctionTemplate.Parent = ScrollingFrame
FunctionTemplate.BackgroundColor3 = Color3.new(1, 1, 1)
FunctionTemplate.BackgroundTransparency = 1
FunctionTemplate.Size = UDim2.new(0, 117, 0, 23)

ColorBar_2.Name = "ColorBar"
ColorBar_2.Parent = FunctionTemplate
ColorBar_2.BackgroundColor3 = Color3.new(1, 1, 1)
ColorBar_2.BorderSizePixel = 0
ColorBar_2.Position = UDim2.new(0, 7, 0, 10)
ColorBar_2.Size = UDim2.new(0, 7, 0, 18)
ColorBar_2.ZIndex = 3

Text_2.Name = "Text"
Text_2.Parent = FunctionTemplate
Text_2.BackgroundColor3 = Color3.new(1, 1, 1)
Text_2.BackgroundTransparency = 1
Text_2.Position = UDim2.new(0, 19, 0, 10)
Text_2.Size = UDim2.new(0, 69, 0, 18)
Text_2.ZIndex = 2
Text_2.Font = Enum.Font.SourceSans
Text_2.Text = "TEXT"
Text_2.TextColor3 = Color3.new(1, 1, 1)
Text_2.TextSize = 14
Text_2.TextStrokeColor3 = Color3.new(0.145098, 0.141176, 0.14902)
Text_2.TextXAlignment = Enum.TextXAlignment.Left
Text_2.TextWrapped = true

Button_2.Name = "Button"
Button_2.Parent = FunctionTemplate
Button_2.BackgroundColor3 = Color3.new(0, 0, 0)
Button_2.BackgroundTransparency = 0.69999998807907
Button_2.BorderColor3 = Color3.new(1, 1, 1)
Button_2.Position = UDim2.new(0, 7, 0, 10)
Button_2.Size = UDim2.new(0, 80, 0, 18)
Button_2.AutoButtonColor = false
Button_2.Font = Enum.Font.SourceSans
Button_2.Text = ""
Button_2.TextColor3 = Color3.new(0, 0, 0)
Button_2.TextSize = 14

TopBar.Name = "TopBar"
TopBar.Parent = Background
TopBar.BackgroundColor3 = Color3.fromRGB(37, 35, 38)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(0, 450, 0, 19)

Simple.Name = "Simple"
Simple.Parent = TopBar
Simple.BackgroundColor3 = Color3.new(1, 1, 1)
Simple.AutoButtonColor = false
Simple.BackgroundTransparency = 1
Simple.Position = UDim2.new(0, 5, 0, 0)
Simple.Size = UDim2.new(0, 57, 0, 18)
Simple.Font = Enum.Font.SourceSansBold
Simple.Text = "SimpleSpy For Mobile"
Simple.TextColor3 = Color3.new(0, 0, 1)
Simple.TextSize = 14
Simple.TextXAlignment = Enum.TextXAlignment.Left

CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.BackgroundColor3 = Color3.new(0.145098, 0.141176, 0.14902)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -19, 0, 0)
CloseButton.Size = UDim2.new(0, 19, 0, 19)
CloseButton.Font = Enum.Font.SourceSans
CloseButton.Text = ""
CloseButton.TextColor3 = Color3.new(0, 0, 0)
CloseButton.TextSize = 14

ImageLabel.Parent = CloseButton
ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Position = UDim2.new(0, 5, 0, 5)
ImageLabel.Size = UDim2.new(0, 9, 0, 9)
ImageLabel.Image = "http://www.roblox.com/asset/?id=5597086202"

MaximizeButton.Name = "MaximizeButton"
MaximizeButton.Parent = TopBar
MaximizeButton.BackgroundColor3 = Color3.new(0.145098, 0.141176, 0.14902)
MaximizeButton.BorderSizePixel = 0
MaximizeButton.Position = UDim2.new(1, -38, 0, 0)
MaximizeButton.Size = UDim2.new(0, 19, 0, 19)
MaximizeButton.Font = Enum.Font.SourceSans
MaximizeButton.Text = ""
MaximizeButton.TextColor3 = Color3.new(0, 0, 0)
MaximizeButton.TextSize = 14

ImageLabel_2.Parent = MaximizeButton
ImageLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel_2.BackgroundTransparency = 1
ImageLabel_2.Position = UDim2.new(0, 5, 0, 5)
ImageLabel_2.Size = UDim2.new(0, 9, 0, 9)
ImageLabel_2.Image = "http://www.roblox.com/asset/?id=5597108117"

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TopBar
MinimizeButton.BackgroundColor3 = Color3.new(0.145098, 0.141176, 0.14902)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -57, 0, 0)
MinimizeButton.Size = UDim2.new(0, 19, 0, 19)
MinimizeButton.Font = Enum.Font.SourceSans
MinimizeButton.Text = ""
MinimizeButton.TextColor3 = Color3.new(0, 0, 0)
MinimizeButton.TextSize = 14

ImageLabel_3.Parent = MinimizeButton
ImageLabel_3.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel_3.BackgroundTransparency = 1
ImageLabel_3.Position = UDim2.new(0, 5, 0, 5)
ImageLabel_3.Size = UDim2.new(0, 9, 0, 9)
ImageLabel_3.Image = "http://www.roblox.com/asset/?id=5597105827"

ToolTip.Name = "ToolTip"
ToolTip.Parent = SimpleSpy2
ToolTip.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
ToolTip.BackgroundTransparency = 0.1
ToolTip.BorderColor3 = Color3.new(1, 1, 1)
ToolTip.Size = UDim2.new(0, 200, 0, 50)
ToolTip.ZIndex = 3
ToolTip.Visible = false

TextLabel.Parent = ToolTip
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 2, 0, 2)
TextLabel.Size = UDim2.new(0, 196, 0, 46)
TextLabel.ZIndex = 3
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "This is some slightly longer text."
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextSize = 14
TextLabel.TextWrapped = true
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.TextYAlignment = Enum.TextYAlignment.Top

-------------------------------------------------------------------------------
-- init
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local TextService = game:GetService("TextService")
local Mouse

local selectedColor = Color3.new(0.321569, 0.333333, 1)
local deselectedColor = Color3.new(0.8, 0.8, 0.8)
--- So things are descending
local layoutOrderNum = 999999999
--- Whether or not the gui is closing
local mainClosing = false
--- Whether or not the gui is closed (defaults to false)
local closed = false
--- Whether or not the sidebar is closing
local sideClosing = false
--- Whether or not the sidebar is closed (defaults to true but opens automatically on remote selection)
local sideClosed = false
--- Whether or not the code box is maximized (defaults to false)
local maximized = false
--- The event logs to be read from
local logs = {}
--- The event currently selected.Log (defaults to nil)
local selected = nil
--- The blacklist (can be a string name or the Remote Instance)
local blacklist = {}
--- The block list (can be a string name or the Remote Instance)
local blocklist = {}
--- Whether or not to add getNil function
local getNil = false
--- Array of remotes (and original functions) connected to
local connectedRemotes = {}
--- True = hookfunction, false = namecall
local toggle = false
local gm
local original
--- used to prevent recursives
local prevTables = {}
--- holds logs (for deletion)
local remoteLogs = {}
--- used for hookfunction
local remoteEvent = Instance.new("RemoteEvent")
--- used for hookfunction
local remoteFunction = Instance.new("RemoteFunction")
local originalEvent = remoteEvent.FireServer
local originalFunction = remoteFunction.InvokeServer
--- the maximum amount of remotes allowed in logs
_G.SIMPLESPYCONFIG_MaxRemotes = 500
--- how many spaces to indent
local indent = 4
--- used for task scheduler
local scheduled = {}
--- RBXScriptConnect of the task scheduler
local schedulerconnect
local SimpleSpy = {}
local topstr = ""
local bottomstr = ""
local remotesFadeIn
local rightFadeIn
local codebox
local p
local getnilrequired = false

-- autoblock variables
local autoblock = false
local history = {}
local excluding = {}

-- function info variables
local funcEnabled = true

-- remote hooking/connecting api variables
local remoteSignals = {}
local remoteHooks = {}

-- original mouse icon
local oldIcon

-- if mouse inside gui
local mouseInGui = false

-- handy array of RBXScriptConnections to disconnect on shutdown
local connections = {}

-- whether or not SimpleSpy uses 'getcallingscript()' to get the script (default is false because detection)
local useGetCallingScript = false

--- used to enable/disable SimpleSpy's keyToString for remotes
local keyToString = false

-- determines whether return values are recorded
local recordReturnValues = false

-- functions

--- Converts arguments to a string and generates code that calls the specified method with them, recommended to be used in conjunction with ValueToString (method must be a string, e.g. `game:GetService("ReplicatedStorage").Remote.remote:FireServer`)
--- @param method string
--- @param args any[]
--- @return string
function SimpleSpy:ArgsToString(method, args)
	assert(typeof(method) == "string", "string expected, got " .. typeof(method))
	assert(typeof(args) == "table", "table expected, got " .. typeof(args))
	return v2v({ args = args }) .. "\n\n" .. method .. "(unpack(args))"
end

--- Converts a value to variables with the specified index as the variable name (if nil/invalid then the name will be assigned automatically)
--- @param t any[]
--- @return string
function SimpleSpy:TableToVars(t)
	assert(typeof(t) == "table", "table expected, got " .. typeof(t))
	return v2v(t)
end

--- Converts a value to a variable with the specified `variablename` (if nil/invalid then the name will be assigned automatically)
--- @param value any
--- @return string
function SimpleSpy:ValueToVar(value, variablename)
	assert(variablename == nil or typeof(variablename) == "string", "string expected, got " .. typeof(variablename))
	if not variablename then
		variablename = 1
	end
	return v2v({ [variablename] = value })
end

--- Converts any value to a string, cannot preserve function contents
--- @param value any
--- @return string
function SimpleSpy:ValueToString(value)
	return v2s(value)
end

--- Generates the simplespy function info
--- @param func function
--- @return string
function SimpleSpy:GetFunctionInfo(func)
	assert(typeof(func) == "function", "Instance expected, got " .. typeof(func))
	warn("Function info currently unavailable due to crashing in Synapse X")
	return v2v({ functionInfo = {
		info = debug.getinfo(func),
		constants = debug.getconstants(func),
	} })
end

--- Gets the ScriptSignal for a specified remote being fired
--- @param remote Instance
function SimpleSpy:GetRemoteFiredSignal(remote)
	assert(typeof(remote) == "Instance", "Instance expected, got " .. typeof(remote))
	if not remoteSignals[remote] then
		remoteSignals[remote] = newSignal()
	end
	return remoteSignals[remote]
end

--- Allows for direct hooking of remotes **THIS CAN BE VERY DANGEROUS**
--- @param remote Instance
--- @param f function
function SimpleSpy:HookRemote(remote, f)
	assert(typeof(remote) == "Instance", "Instance expected, got " .. typeof(remote))
	assert(typeof(f) == "function", "function expected, got " .. typeof(f))
	remoteHooks[remote] = f
end

--- Blocks the specified remote instance/string
--- @param remote any
function SimpleSpy:BlockRemote(remote)
	assert(
		typeof(remote) == "Instance" or typeof(remote) == "string",
		"Instance | string expected, got " .. typeof(remote)
	)
	blocklist[remote] = true
end

--- Excludes the specified remote from logs (instance/string)
--- @param remote any
function SimpleSpy:ExcludeRemote(remote)
	assert(
		typeof(remote) == "Instance" or typeof(remote) == "string",
		"Instance | string expected, got " .. typeof(remote)
	)
	blacklist[remote] = true
end

--- Creates a new ScriptSignal that can be connected to and fired
--- @return table
function newSignal()
	local connected = {}
	return {
		Connect = function(self, f)
			assert(connected, "Signal is closed")
			connected[tostring(f)] = f
			return {
				Connected = true,
				Disconnect = function(self)
					if not connected then
						warn("Signal is already closed")
					end
					self.Connected = false
					connected[tostring(f)] = nil
				end,
			}
		end,
		Wait = function(self)
			local thread = coroutine.running()
			local connection
			connection = self:Connect(function()
				connection:Disconnect()
				if coroutine.status(thread) == "suspended" then
					coroutine.resume(thread)
				end
			end)
			coroutine.yield()
		end,
		Fire = function(self, ...)
			for _, f in pairs(connected) do
				coroutine.wrap(f)(...)
			end
		end,
	}
end

--- Prevents remote spam from causing lag (clears logs after `_G.SIMPLESPYCONFIG_MaxRemotes` or 500 remotes)
function clean()
	local max = _G.SIMPLESPYCONFIG_MaxRemotes
	if not typeof(max) == "number" and math.floor(max) ~= max then
		max = 500
	end
	if #remoteLogs > max then
		for i = 100, #remoteLogs do
			local v = remoteLogs[i]
			if typeof(v[1]) == "RBXScriptConnection" then
				v[1]:Disconnect()
			end
			if typeof(v[2]) == "Instance" then
				v[2]:Destroy()
			end
		end
		local newLogs = {}
		for i = 1, 100 do
			table.insert(newLogs, remoteLogs[i])
		end
		remoteLogs = newLogs
	end
end

--- Scales the ToolTip to fit containing text
function scaleToolTip()
	local size = TextService:GetTextSize(
		TextLabel.Text,
		TextLabel.TextSize,
		TextLabel.Font,
		Vector2.new(196, math.huge)
	)
	TextLabel.Size = UDim2.new(0, size.X, 0, size.Y)
	ToolTip.Size = UDim2.new(0, size.X + 4, 0, size.Y + 4)
end

--- Executed when the toggle button (the SimpleSpy logo) is hovered over
function onToggleButtonHover()
	if not toggle then
		TweenService:Create(Simple, TweenInfo.new(0.5), { TextColor3 = Color3.fromRGB(252, 51, 51) }):Play()
	else
		TweenService:Create(Simple, TweenInfo.new(0.5), { TextColor3 = Color3.fromRGB(68, 206, 91) }):Play()
	end
end

--- Executed when the toggle button is unhovered over
function onToggleButtonUnhover()
	TweenService:Create(Simple, TweenInfo.new(0.5), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
end

--- Executed when the X button is hovered over
function onXButtonHover()
	TweenService:Create(CloseButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 60, 60) }):Play()
end

--- Executed when the X button is unhovered over
function onXButtonUnhover()
	TweenService:Create(CloseButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(37, 36, 38) }):Play()
end

--- Toggles the remote spy method (when button clicked)
function onToggleButtonClick()
	if toggle then
		TweenService:Create(Simple, TweenInfo.new(0.5), { TextColor3 = Color3.fromRGB(252, 51, 51) }):Play()
	else
		TweenService:Create(Simple, TweenInfo.new(0.5), { TextColor3 = Color3.fromRGB(68, 206, 91) }):Play()
	end
	toggleSpyMethod()
end

--- Reconnects bringBackOnResize if the current viewport changes and also connects it initially
function connectResize()
	local lastCam = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(bringBackOnResize)
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		lastCam:Disconnect()
		if workspace.CurrentCamera then
			lastCam = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(bringBackOnResize)
		end
	end)
end

--- Brings gui back if it gets lost offscreen (connected to the camera viewport changing)
function bringBackOnResize()
	validateSize()
	if sideClosed then
		minimizeSize()
	else
		maximizeSize()
	end
	local currentX = Background.AbsolutePosition.X
	local currentY = Background.AbsolutePosition.Y
	local viewportSize = workspace.CurrentCamera.ViewportSize
	if (currentX < 0) or (currentX > (viewportSize.X - (sideClosed and 131 or Background.AbsoluteSize.X))) then
		if currentX < 0 then
			currentX = 0
		else
			currentX = viewportSize.X - (sideClosed and 131 or Background.AbsoluteSize.X)
		end
	end
	if (currentY < 0) or (currentY > (viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - 36)) then
		if currentY < 0 then
			currentY = 0
		else
			currentY = viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - 36
		end
	end
	TweenService.Create(
		TweenService,
		Background,
		TweenInfo.new(0.1),
		{ Position = UDim2.new(0, currentX, 0, currentY) }
	):Play()
end

--- Drags gui (so long as mouse is held down)
--- @param input InputObject
function onBarInput(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local lastPos = UserInputService.GetMouseLocation(UserInputService)
		local mainPos = Background.AbsolutePosition
		local offset = mainPos - lastPos
		local currentPos = offset + lastPos
		RunService.BindToRenderStep(RunService, "drag", 1, function()
			local newPos = UserInputService.GetMouseLocation(UserInputService)
			if newPos ~= lastPos then
				local currentX = (offset + newPos).X
				local currentY = (offset + newPos).Y
				local viewportSize = workspace.CurrentCamera.ViewportSize
				if
					(currentX < 0 and currentX < currentPos.X)
					or (
						currentX > (viewportSize.X - (sideClosed and 131 or TopBar.AbsoluteSize.X))
						and currentX > currentPos.X
					)
				then
					if currentX < 0 then
						currentX = 0
					else
						currentX = viewportSize.X - (sideClosed and 131 or TopBar.AbsoluteSize.X)
					end
				end
				if
					(currentY < 0 and currentY < currentPos.Y)
					or (
						currentY > (viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - 36)
						and currentY > currentPos.Y
					)
				then
					if currentY < 0 then
						currentY = 0
					else
						currentY = viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - 36
					end
				end
				currentPos = Vector2.new(currentX, currentY)
				lastPos = newPos
				TweenService.Create(
					TweenService,
					Background,
					TweenInfo.new(0.1),
					{ Position = UDim2.new(0, currentPos.X, 0, currentPos.Y) }
				):Play()
			end
			-- if input.UserInputState ~= Enum.UserInputState.Begin then
			--     RunService.UnbindFromRenderStep(RunService, "drag")
			-- end
		end)
		table.insert(
			connections,
			UserInputService.InputEnded:Connect(function(inputE)
				if input == inputE then
					RunService:UnbindFromRenderStep("drag")
				end
			end)
		)
	end
end

--- Fades out the table of elements (and makes them invisible), returns a function to make them visible again
function fadeOut(elements)
	local data = {}
	for _, v in pairs(elements) do
		if typeof(v) == "Instance" and v:IsA("GuiObject") and v.Visible then
			coroutine.wrap(function()
				data[v] = {
					BackgroundTransparency = v.BackgroundTransparency,
				}
				TweenService:Create(v, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
				if v:IsA("TextBox") or v:IsA("TextButton") or v:IsA("TextLabel") then
					data[v].TextTransparency = v.TextTransparency
					TweenService:Create(v, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
				elseif v:IsA("ImageButton") or v:IsA("ImageLabel") then
					data[v].ImageTransparency = v.ImageTransparency
					TweenService:Create(v, TweenInfo.new(0.5), { ImageTransparency = 1 }):Play()
				end
				wait(0.5)
				v.Visible = false
				for i, x in pairs(data[v]) do
					v[i] = x
				end
				data[v] = true
			end)()
		end
	end
	return function()
		for i, _ in pairs(data) do
			coroutine.wrap(function()
				local properties = {
					BackgroundTransparency = i.BackgroundTransparency,
				}
				i.BackgroundTransparency = 1
				TweenService
					:Create(i, TweenInfo.new(0.5), { BackgroundTransparency = properties.BackgroundTransparency })
					:Play()
				if i:IsA("TextBox") or i:IsA("TextButton") or i:IsA("TextLabel") then
					properties.TextTransparency = i.TextTransparency
					i.TextTransparency = 1
					TweenService
						:Create(i, TweenInfo.new(0.5), { TextTransparency = properties.TextTransparency })
						:Play()
				elseif i:IsA("ImageButton") or i:IsA("ImageLabel") then
					properties.ImageTransparency = i.ImageTransparency
					i.ImageTransparency = 1
					TweenService
						:Create(i, TweenInfo.new(0.5), { ImageTransparency = properties.ImageTransparency })
						:Play()
				end
				i.Visible = true
			end)()
		end
	end
end

--- Expands and minimizes the gui (closed is the toggle boolean)
function toggleMinimize(override)
	if mainClosing and not override or maximized then
		return
	end
	mainClosing = true
	closed = not closed
	if closed then
		if not sideClosed then
			toggleSideTray(true)
		end
		LeftPanel.Visible = true
		TweenService:Create(LeftPanel, TweenInfo.new(0.5), { Size = UDim2.new(0, 131, 0, 0) }):Play()
		wait(0.5)
		remotesFadeIn = fadeOut(LeftPanel:GetDescendants())
		wait(0.5)
	else
		TweenService:Create(LeftPanel, TweenInfo.new(0.5), { Size = UDim2.new(0, 131, 0, 249) }):Play()
		wait(0.5)
		if remotesFadeIn then
			remotesFadeIn()
			remotesFadeIn = nil
		end
		bringBackOnResize()
	end
	mainClosing = false
end

--- Expands and minimizes the sidebar (sideClosed is the toggle boolean)
function toggleSideTray(override)
	if sideClosing and not override or maximized then
		return
	end
	sideClosing = true
	sideClosed = not sideClosed
	if sideClosed then
		rightFadeIn = fadeOut(RightPanel:GetDescendants())
		wait(0.5)
		minimizeSize(0.5)
		wait(0.5)
		RightPanel.Visible = false
	else
		if closed then
			toggleMinimize(true)
		end
		RightPanel.Visible = true
		maximizeSize(0.5)
		wait(0.5)
		if rightFadeIn then
			rightFadeIn()
		end
		bringBackOnResize()
	end
	sideClosing = false
end

--- Expands code box to fit screen for more convenient viewing
function toggleMaximize()
	if not sideClosed and not maximized then
		maximized = true
		local disable = Instance.new("TextButton")
		local prevSize = UDim2.new(0, CodeBox.AbsoluteSize.X, 0, CodeBox.AbsoluteSize.Y)
		local prevPos = UDim2.new(0, CodeBox.AbsolutePosition.X, 0, CodeBox.AbsolutePosition.Y)
		disable.Size = UDim2.new(1, 0, 1, 0)
		disable.BackgroundColor3 = Color3.new()
		disable.BorderSizePixel = 0
		disable.Text = 0
		disable.ZIndex = 3
		disable.BackgroundTransparency = 1
		disable.AutoButtonColor = false
		CodeBox.ZIndex = 4
		CodeBox.Position = prevPos
		CodeBox.Size = prevSize
		TweenService
			:Create(
				CodeBox,
				TweenInfo.new(0.5),
				{ Size = UDim2.new(0.5, 0, 0.5, 0), Position = UDim2.new(0.25, 0, 0.25, 0) }
			)
			:Play()
		TweenService:Create(disable, TweenInfo.new(0.5), { BackgroundTransparency = 0.5 }):Play()
		disable.MouseButton1Click:Connect(function()
			if
				UserInputService:GetMouseLocation().Y + 36 >= CodeBox.AbsolutePosition.Y
				and UserInputService:GetMouseLocation().Y + 36 <= CodeBox.AbsolutePosition.Y + CodeBox.AbsoluteSize.Y
				and UserInputService:GetMouseLocation().X >= CodeBox.AbsolutePosition.X
				and UserInputService:GetMouseLocation().X <= CodeBox.AbsolutePosition.X + CodeBox.AbsoluteSize.X
			then
				return
			end
			TweenService:Create(CodeBox, TweenInfo.new(0.5), { Size = prevSize, Position = prevPos }):Play()
			TweenService:Create(disable, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
			maximized = false
			wait(0.5)
			disable:Destroy()
			CodeBox.Size = UDim2.new(1, 0, 0.5, 0)
			CodeBox.Position = UDim2.new(0, 0, 0, 0)
			CodeBox.ZIndex = 0
		end)
	end
end

--- Adjusts the ui elements to the 'Maximized' size
function maximizeSize(speed)
	if not speed then
		speed = 0.05
	end
	TweenService
		:Create(
			LeftPanel,
			TweenInfo.new(speed),
			{ Size = UDim2.fromOffset(LeftPanel.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y) }
		)
		:Play()
	TweenService
		:Create(RightPanel, TweenInfo.new(speed), {
			Size = UDim2.fromOffset(
				Background.AbsoluteSize.X - LeftPanel.AbsoluteSize.X,
				Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y
			),
		})
		:Play()
	TweenService
		:Create(
			TopBar,
			TweenInfo.new(speed),
			{ Size = UDim2.fromOffset(Background.AbsoluteSize.X, TopBar.AbsoluteSize.Y) }
		)
		:Play()
	TweenService
		:Create(ScrollingFrame, TweenInfo.new(speed), {
			Size = UDim2.fromOffset(Background.AbsoluteSize.X - LeftPanel.AbsoluteSize.X, 110),
			Position = UDim2.fromOffset(0, Background.AbsoluteSize.Y - 119 - TopBar.AbsoluteSize.Y),
		})
		:Play()
	TweenService
		:Create(CodeBox, TweenInfo.new(speed), {
			Size = UDim2.fromOffset(
				Background.AbsoluteSize.X - LeftPanel.AbsoluteSize.X,
				Background.AbsoluteSize.Y - 119 - TopBar.AbsoluteSize.Y
			),
		})
		:Play()
	TweenService
		:Create(
			LogList,
			TweenInfo.new(speed),
			{ Size = UDim2.fromOffset(LogList.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y - 18) }
		)
		:Play()
end

--- Adjusts the ui elements to close the side
function minimizeSize(speed)
	if not speed then
		speed = 0.05
	end
	TweenService
		:Create(
			LeftPanel,
			TweenInfo.new(speed),
			{ Size = UDim2.fromOffset(LeftPanel.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y) }
		)
		:Play()
	TweenService
		:Create(
			RightPanel,
			TweenInfo.new(speed),
			{ Size = UDim2.fromOffset(0, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y) }
		)
		:Play()
	TweenService
		:Create(
			TopBar,
			TweenInfo.new(speed),
			{ Size = UDim2.fromOffset(LeftPanel.AbsoluteSize.X, TopBar.AbsoluteSize.Y) }
		)
		:Play()
	TweenService
		:Create(ScrollingFrame, TweenInfo.new(speed), {
			Size = UDim2.fromOffset(0, 119),
			Position = UDim2.fromOffset(0, Background.AbsoluteSize.Y - 119 - TopBar.AbsoluteSize.Y),
		})
		:Play()
	TweenService
		:Create(
			CodeBox,
			TweenInfo.new(speed),
			{ Size = UDim2.fromOffset(0, Background.AbsoluteSize.Y - 119 - TopBar.AbsoluteSize.Y) }
		)
		:Play()
	TweenService
		:Create(
			LogList,
			TweenInfo.new(speed),
			{ Size = UDim2.fromOffset(LogList.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y - 18) }
		)
		:Play()
end

--- Ensures size is within screensize limitations
function validateSize()
	local x, y = Background.AbsoluteSize.X, Background.AbsoluteSize.Y
	local screenSize = workspace.CurrentCamera.ViewportSize
	if x + Background.AbsolutePosition.X > screenSize.X then
		if screenSize.X - Background.AbsolutePosition.X >= 450 then
			x = screenSize.X - Background.AbsolutePosition.X
		else
			x = 450
		end
	elseif y + Background.AbsolutePosition.Y > screenSize.Y then
		if screenSize.X - Background.AbsolutePosition.Y >= 268 then
			y = screenSize.Y - Background.AbsolutePosition.Y
		else
			y = 268
		end
	end
	Background.Size = UDim2.fromOffset(x, y)
end

--- Gets the player an instance is descended from
function getPlayerFromInstance(instance)
	for _, v in pairs(Players:GetPlayers()) do
		if v.Character and (instance:IsDescendantOf(v.Character) or instance == v.Character) then
			return v
		end
	end
end

--- Runs on MouseButton1Click of an event frame
function eventSelect(frame)
	if selected and selected.Log and selected.Log.Button then
		TweenService
			:Create(selected.Log.Button, TweenInfo.new(0.5), { BackgroundColor3 = Color3.fromRGB(0, 0, 0) })
			:Play()
		selected = nil
	end
	for _, v in pairs(logs) do
		if frame == v.Log then
			selected = v
		end
	end
	if selected and selected.Log then
		TweenService
			:Create(frame.Button, TweenInfo.new(0.5), { BackgroundColor3 = Color3.fromRGB(92, 126, 229) })
			:Play()
		codebox:setRaw(selected.GenScript)
	end
	if sideClosed then
		toggleSideTray()
	end
end

--- Updates the canvas size to fit the current amount of function buttons
function updateFunctionCanvas()
	ScrollingFrame.CanvasSize = UDim2.fromOffset(UIGridLayout.AbsoluteContentSize.X, UIGridLayout.AbsoluteContentSize.Y)
end

--- Updates the canvas size to fit the amount of current remotes
function updateRemoteCanvas()
	LogList.CanvasSize = UDim2.fromOffset(UIListLayout.AbsoluteContentSize.X, UIListLayout.AbsoluteContentSize.Y)
end

--- Allows for toggling of the tooltip and easy setting of le description
--- @param enable boolean
--- @param text string
function makeToolTip(enable, text)
	if enable then
		if ToolTip.Visible then
			ToolTip.Visible = false
			RunService:UnbindFromRenderStep("ToolTip")
		end
		local first = true
		RunService:BindToRenderStep("ToolTip", 1, function()
			local topLeft = Vector2.new(Mouse.X + 20, Mouse.Y + 20)
			local bottomRight = topLeft + ToolTip.AbsoluteSize
			if topLeft.X < 0 then
				topLeft = Vector2.new(0, topLeft.Y)
			elseif bottomRight.X > workspace.CurrentCamera.ViewportSize.X then
				topLeft = Vector2.new(workspace.CurrentCamera.ViewportSize.X - ToolTip.AbsoluteSize.X, topLeft.Y)
			end
			if topLeft.Y < 0 then
				topLeft = Vector2.new(topLeft.X, 0)
			elseif bottomRight.Y > workspace.CurrentCamera.ViewportSize.Y - 35 then
				topLeft = Vector2.new(topLeft.X, workspace.CurrentCamera.ViewportSize.Y - ToolTip.AbsoluteSize.Y - 35)
			end
			if topLeft.X <= Mouse.X and topLeft.Y <= Mouse.Y then
				topLeft = Vector2.new(Mouse.X - ToolTip.AbsoluteSize.X - 2, Mouse.Y - ToolTip.AbsoluteSize.Y - 2)
			end
			if first then
				ToolTip.Position = UDim2.fromOffset(topLeft.X, topLeft.Y)
				first = false
			else
				ToolTip:TweenPosition(UDim2.fromOffset(topLeft.X, topLeft.Y), "Out", "Linear", 0.1)
			end
		end)
		TextLabel.Text = text
		ToolTip.Visible = true
	else
		if ToolTip.Visible then
			ToolTip.Visible = false
			RunService:UnbindFromRenderStep("ToolTip")
		end
	end
end

--- Creates new function button (below codebox)
--- @param name string
---@param description function
---@param onClick function
function newButton(name, description, onClick)
	local button = FunctionTemplate:Clone()
	button.Text.Text = name
	button.Button.MouseEnter:Connect(function()
		makeToolTip(true, description())
	end)
	button.Button.MouseLeave:Connect(function()
		makeToolTip(false)
	end)
	button.AncestryChanged:Connect(function()
		makeToolTip(false)
	end)
	button.Button.MouseButton1Click:Connect(function(...)
		onClick(button, ...)
	end)
	button.Parent = ScrollingFrame
	updateFunctionCanvas()
end

--- Adds new Remote to logs
--- @param name string The name of the remote being logged
--- @param type string The type of the remote being logged (either 'function' or 'event')
--- @param args any
--- @param remote any
--- @param function_info string
--- @param blocked any
function newRemote(type, name, args, remote, function_info, blocked, src, returnValue)
	local remoteFrame = RemoteTemplate:Clone()
	remoteFrame.Text.Text = string.sub(name, 1, 50)
	remoteFrame.ColorBar.BackgroundColor3 = type == "event" and Color3.new(255, 242, 0) or Color3.fromRGB(99, 86, 245)
	local id = Instance.new("IntValue")
	id.Name = "ID"
	id.Value = #logs + 1
	id.Parent = remoteFrame
	local weakRemoteTable = setmetatable({ remote = remote }, { __mode = "v" })
	local log = {
		Name = name,
		Function = function_info,
		Remote = weakRemoteTable,
		Log = remoteFrame,
		Blocked = blocked,
		Source = src,
		GenScript = "-- Generating, please wait... (click to reload)\n-- (If this message persists, the remote args are likely extremely long)",
		ReturnValue = returnValue,
	}
	logs[#logs + 1] = log
	schedule(function()
		log.GenScript = genScript(remote, args)
		if blocked then
			logs[#logs].GenScript = "-- THIS REMOTE WAS PREVENTED FROM FIRING THE SERVER BY SIMPLESPY\n\n"
				.. logs[#logs].GenScript
		end
	end)
	local connect = remoteFrame.Button.MouseButton1Click:Connect(function()
		eventSelect(remoteFrame)
	end)
	if layoutOrderNum < 1 then
		layoutOrderNum = 999999999
	end
	remoteFrame.LayoutOrder = layoutOrderNum
	layoutOrderNum = layoutOrderNum - 1
	remoteFrame.Parent = LogList
	table.insert(remoteLogs, 1, { connect, remoteFrame })
	clean()
	updateRemoteCanvas()
end

--- Generates a script from the provided arguments (first has to be remote path)
function genScript(remote, args)
	prevTables = {}
	local gen = ""
	if #args > 0 then
		if not pcall(function()
			gen = v2v({ args = args }) .. "\n"
		end) then
			gen = gen
				.. "-- TableToString failure! Reverting to legacy functionality (results may vary)\nlocal args = {"
			if
				not pcall(function()
					for i, v in pairs(args) do
						if type(i) ~= "Instance" and type(i) ~= "userdata" then
							gen = gen .. "\n    [object] = "
						elseif type(i) == "string" then
							gen = gen .. '\n    ["' .. i .. '"] = '
						elseif type(i) == "userdata" and typeof(i) ~= "Instance" then
							gen = gen .. "\n    [" .. string.format("nil --[[%s]]", typeof(v)) .. ")] = "
						elseif type(i) == "userdata" then
							gen = gen .. "\n    [game." .. i:GetFullName() .. ")] = "
						end
						if type(v) ~= "Instance" and type(v) ~= "userdata" then
							gen = gen .. "object"
						elseif type(v) == "string" then
							gen = gen .. '"' .. v .. '"'
						elseif type(v) == "userdata" and typeof(v) ~= "Instance" then
							gen = gen .. string.format("nil --[[%s]]", typeof(v))
						elseif type(v) == "userdata" then
							gen = gen .. "game." .. v:GetFullName()
						end
					end
					gen = gen .. "\n}\n\n"
				end)
			then
				gen = gen .. "}\n-- Legacy tableToString failure! Unable to decompile."
			end
		end
		if not remote:IsDescendantOf(game) and not getnilrequired then
			gen = "function getNil(name,class) for _,v in pairs(getnilinstances())do if v.ClassName==class and v.Name==name then return v;end end end\n\n"
				.. gen
		end
		if remote:IsA("RemoteEvent") then
			gen = gen .. v2s(remote) .. ":FireServer(unpack(args))"
		elseif remote:IsA("RemoteFunction") then
			gen = gen .. v2s(remote) .. ":InvokeServer(unpack(args))"
		end
	else
		if remote:IsA("RemoteEvent") then
			gen = gen .. v2s(remote) .. ":FireServer()"
		elseif remote:IsA("RemoteFunction") then
			gen = gen .. v2s(remote) .. ":InvokeServer()"
		end
	end
	gen = gen
	prevTables = {}
	return gen
end

--- value-to-string: value, string (out), level (indentation), parent table, var name, is from tovar
function v2s(v, l, p, n, vtv, i, pt, path, tables, tI)
	if not tI then
		tI = { 0 }
	else
		tI[1] += 1
	end
	if typeof(v) == "number" then
		if v == math.huge then
			return "math.huge"
		elseif tostring(v):match("nan") then
			return "0/0 --[[NaN]]"
		end
		return tostring(v)
	elseif typeof(v) == "boolean" then
		return tostring(v)
	elseif typeof(v) == "string" then
		return formatstr(v, l)
	elseif typeof(v) == "function" then
		return f2s(v)
	elseif typeof(v) == "table" then
		return t2s(v, l, p, n, vtv, i, pt, path, tables, tI)
	elseif typeof(v) == "Instance" then
		return i2p(v)
	elseif typeof(v) == "userdata" then
		return "newproxy(true)"
	elseif type(v) == "userdata" then
		return u2s(v)
	elseif type(v) == "vector" then
		return string.format("Vector3.new(%s, %s, %s)", v2s(v.X), v2s(v.Y), v2s(v.Z))
	else
		return "nil --[[" .. typeof(v) .. "]]"
	end
end

--- value-to-variable
--- @param t any
function v2v(t)
	topstr = ""
	bottomstr = ""
	getnilrequired = false
	local ret = ""
	local count = 1
	for i, v in pairs(t) do
		if type(i) == "string" and i:match("^[%a_]+[%w_]*$") then
			ret = ret .. "local " .. i .. " = " .. v2s(v, nil, nil, i, true) .. "\n"
		elseif tostring(i):match("^[%a_]+[%w_]*$") then
			ret = ret
				.. "local "
				.. tostring(i):lower()
				.. "_"
				.. tostring(count)
				.. " = "
				.. v2s(v, nil, nil, tostring(i):lower() .. "_" .. tostring(count), true)
				.. "\n"
		else
			ret = ret
				.. "local "
				.. type(v)
				.. "_"
				.. tostring(count)
				.. " = "
				.. v2s(v, nil, nil, type(v) .. "_" .. tostring(count), true)
				.. "\n"
		end
		count = count + 1
	end
	if getnilrequired then
		topstr = "function getNil(name,class) for _,v in pairs(getnilinstances())do if v.ClassName==class and v.Name==name then return v;end end end\n"
			.. topstr
	end
	if #topstr > 0 then
		ret = topstr .. "\n" .. ret
	end
	if #bottomstr > 0 then
		ret = ret .. bottomstr
	end
	return ret
end

--- table-to-string
--- @param t table
--- @param l number
--- @param p table
--- @param n string
--- @param vtv boolean
--- @param i any
--- @param pt table
--- @param path string
--- @param tables table
--- @param tI table
function t2s(t, l, p, n, vtv, i, pt, path, tables, tI)
	local globalIndex = table.find(getgenv(), t) -- checks if table is a global
	if type(globalIndex) == "string" then
		return globalIndex
	end
	if not tI then
		tI = { 0 }
	end
	if not path then -- sets path to empty string (so it doesn't have to manually provided every time)
		path = ""
	end
	if not l then -- sets the level to 0 (for indentation) and tables for logging tables it already serialized
		l = 0
		tables = {}
	end
	if not p then -- p is the previous table but doesn't really matter if it's the first
		p = t
	end
	for _, v in pairs(tables) do -- checks if the current table has been serialized before
		if n and rawequal(v, t) then
			bottomstr = bottomstr
				.. "\n"
				.. tostring(n)
				.. tostring(path)
				.. " = "
				.. tostring(n)
				.. tostring(({ v2p(v, p) })[2])
			return "{} --[[DUPLICATE]]"
		end
	end
	table.insert(tables, t) -- logs table to past tables
	local s = "{" -- start of serialization
	local size = 0
	l = l + indent -- set indentation level
	for k, v in pairs(t) do -- iterates over table
		size = size + 1 -- changes size for max limit
		if size > (_G.SimpleSpyMaxTableSize or 1000) then
			s = s
				.. "\n"
				.. string.rep(" ", l)
				.. "-- MAXIMUM TABLE SIZE REACHED, CHANGE '_G.SimpleSpyMaxTableSize' TO ADJUST MAXIMUM SIZE "
			break
		end
		if rawequal(k, t) then -- checks if the table being iterated over is being used as an index within itself (yay, lua)
			bottomstr = bottomstr
				.. "\n"
				.. tostring(n)
				.. tostring(path)
				.. "["
				.. tostring(n)
				.. tostring(path)
				.. "]"
				.. " = "
				.. (
					rawequal(v, k) and tostring(n) .. tostring(path)
					or v2s(v, l, p, n, vtv, k, t, path .. "[" .. tostring(n) .. tostring(path) .. "]", tables)
				)
			size -= 1
			continue
		end
		local currentPath = "" -- initializes the path of 'v' within 't'
		if type(k) == "string" and k:match("^[%a_]+[%w_]*$") then -- cleanly handles table path generation (for the first half)
			currentPath = "." .. k
		else
			currentPath = "[" .. k2s(k, l, p, n, vtv, k, t, path .. currentPath, tables, tI) .. "]"
		end
		if size % 100 == 0 then
			scheduleWait()
		end
		-- actually serializes the member of the table
		s = s
			.. "\n"
			.. string.rep(" ", l)
			.. "["
			.. k2s(k, l, p, n, vtv, k, t, path .. currentPath, tables, tI)
			.. "] = "
			.. v2s(v, l, p, n, vtv, k, t, path .. currentPath, tables, tI)
			.. ","
	end
	if #s > 1 then -- removes the last comma because it looks nicer (no way to tell if it's done 'till it's done so...)
		s = s:sub(1, #s - 1)
	end
	if size > 0 then -- cleanly indents the last curly bracket
		s = s .. "\n" .. string.rep(" ", l - indent)
	end
	return s .. "}"
end

--- key-to-string
function k2s(v, ...)
	if keyToString then
		if typeof(v) == "userdata" and getrawmetatable(v) then
			return string.format(
				'"<void> (%s)" --[[Potentially hidden data (tostring in SimpleSpy:HookRemote/GetRemoteFiredSignal at your own risk)]]',
				safetostring(v)
			)
		elseif typeof(v) == "userdata" then
			return string.format('"<void> (%s)"', safetostring(v))
		elseif type(v) == "userdata" and typeof(v) ~= "Instance" then
			return string.format('"<%s> (%s)"', typeof(v), tostring(v))
		elseif type(v) == "function" then
			return string.format('"<Function> (%s)"', tostring(v))
		end
	end
	return v2s(v, ...)
end

--- function-to-string
function f2s(f)
	for k, x in pairs(getgenv()) do
		local isgucci, gpath
		if rawequal(x, f) then
			isgucci, gpath = true, ""
		elseif type(x) == "table" then
			isgucci, gpath = v2p(f, x)
		end
		if isgucci and type(k) ~= "function" then
			if type(k) == "string" and k:match("^[%a_]+[%w_]*$") then
				return k .. gpath
			else
				return "getgenv()[" .. v2s(k) .. "]" .. gpath
			end
		end
	end
	if funcEnabled and debug.getinfo(f).name:match("^[%a_]+[%w_]*$") then
		return "function()end --[[" .. debug.getinfo(f).name .. "]]"
	end
	return "function()end --[[" .. tostring(f) .. "]]"
end

--- instance-to-path
--- @param i userdata
function i2p(i)
	local player = getplayer(i)
	local parent = i
	local out = ""
	if parent == nil then
		return "nil"
	elseif player then
		while true do
			if parent and parent == player.Character then
				if player == Players.LocalPlayer then
					return 'game:GetService("Players").LocalPlayer.Character' .. out
				else
					return i2p(player) .. ".Character" .. out
				end
			else
				if parent.Name:match("[%a_]+[%w+]*") ~= parent.Name then
					out = ":FindFirstChild(" .. formatstr(parent.Name) .. ")" .. out
				else
					out = "." .. parent.Name .. out
				end
			end
			parent = parent.Parent
		end
	elseif parent ~= game then
		while true do
			if parent and parent.Parent == game then
				local service = game:FindService(parent.ClassName)
				if service then
					if parent.ClassName == "Workspace" then
						return "workspace" .. out
					else
						return 'game:GetService("' .. service.ClassName .. '")' .. out
					end
				else
					if parent.Name:match("[%a_]+[%w_]*") then
						return "game." .. parent.Name .. out
					else
						return "game:FindFirstChild(" .. formatstr(parent.Name) .. ")" .. out
					end
				end
			elseif parent.Parent == nil then
				getnilrequired = true
				return "getNil(" .. formatstr(parent.Name) .. ', "' .. parent.ClassName .. '")' .. out
			elseif parent == Players.LocalPlayer then
				out = ".LocalPlayer" .. out
			else
				if parent.Name:match("[%a_]+[%w_]*") ~= parent.Name then
					out = ":FindFirstChild(" .. formatstr(parent.Name) .. ")" .. out
				else
					out = "." .. parent.Name .. out
				end
			end
			parent = parent.Parent
		end
	else
		return "game"
	end
end

--- userdata-to-string: userdata
--- @param u userdata
function u2s(u)
	if typeof(u) == "TweenInfo" then
		-- TweenInfo
		return "TweenInfo.new("
			.. tostring(u.Time)
			.. ", Enum.EasingStyle."
			.. tostring(u.EasingStyle)
			.. ", Enum.EasingDirection."
			.. tostring(u.EasingDirection)
			.. ", "
			.. tostring(u.RepeatCount)
			.. ", "
			.. tostring(u.Reverses)
			.. ", "
			.. tostring(u.DelayTime)
			.. ")"
	elseif typeof(u) == "Ray" then
		-- Ray
		return "Ray.new(" .. u2s(u.Origin) .. ", " .. u2s(u.Direction) .. ")"
	elseif typeof(u) == "NumberSequence" then
		-- NumberSequence
		local ret = "NumberSequence.new("
		for i, v in pairs(u.KeyPoints) do
			ret = ret .. tostring(v)
			if i < #u.Keypoints then
				ret = ret .. ", "
			end
		end
		return ret .. ")"
	elseif typeof(u) == "DockWidgetPluginGuiInfo" then
		-- DockWidgetPluginGuiInfo
		return "DockWidgetPluginGuiInfo.new(Enum.InitialDockState" .. tostring(u) .. ")"
	elseif typeof(u) == "ColorSequence" then
		-- ColorSequence
		local ret = "ColorSequence.new("
		for i, v in pairs(u.KeyPoints) do
			ret = ret .. "Color3.new(" .. tostring(v) .. ")"
			if i < #u.Keypoints then
				ret = ret .. ", "
			end
		end
		return ret .. ")"
	elseif typeof(u) == "BrickColor" then
		-- BrickColor
		return "BrickColor.new(" .. tostring(u.Number) .. ")"
	elseif typeof(u) == "NumberRange" then
		-- NumberRange
		return "NumberRange.new(" .. tostring(u.Min) .. ", " .. tostring(u.Max) .. ")"
	elseif typeof(u) == "Region3" then
		-- Region3
		local center = u.CFrame.Position
		local size = u.CFrame.Size
		local vector1 = center - size / 2
		local vector2 = center + size / 2
		return "Region3.new(" .. u2s(vector1) .. ", " .. u2s(vector2) .. ")"
	elseif typeof(u) == "Faces" then
		-- Faces
		local faces = {}
		if u.Top then
			table.insert(faces, "Enum.NormalId.Top")
		end
		if u.Bottom then
			table.insert(faces, "Enum.NormalId.Bottom")
		end
		if u.Left then
			table.insert(faces, "Enum.NormalId.Left")
		end
		if u.Right then
			table.insert(faces, "Enum.NormalId.Right")
		end
		if u.Back then
			table.insert(faces, "Enum.NormalId.Back")
		end
		if u.Front then
			table.insert(faces, "Enum.NormalId.Front")
		end
		return "Faces.new(" .. table.concat(faces, ", ") .. ")"
	elseif typeof(u) == "EnumItem" then
		return tostring(u)
	elseif typeof(u) == "Enums" then
		return "Enum"
	elseif typeof(u) == "Enum" then
		return "Enum." .. tostring(u)
	elseif typeof(u) == "RBXScriptSignal" then
		return "nil --[[RBXScriptSignal]]"
	elseif typeof(u) == "Vector3" then
		return string.format("Vector3.new(%s, %s, %s)", v2s(u.X), v2s(u.Y), v2s(u.Z))
	elseif typeof(u) == "CFrame" then
		local xAngle, yAngle, zAngle = u:ToEulerAnglesXYZ()
		return string.format(
			"CFrame.new(%s, %s, %s) * CFrame.Angles(%s, %s, %s)",
			v2s(u.X),
			v2s(u.Y),
			v2s(u.Z),
			v2s(xAngle),
			v2s(yAngle),
			v2s(zAngle)
		)
	elseif typeof(u) == "DockWidgetPluginGuiInfo" then
		return string.format(
			"DockWidgetPluginGuiInfo(%s, %s, %s, %s, %s, %s, %s)",
			"Enum.InitialDockState.Right",
			v2s(u.InitialEnabled),
			v2s(u.InitialEnabledShouldOverrideRestore),
			v2s(u.FloatingXSize),
			v2s(u.FloatingYSize),
			v2s(u.MinWidth),
			v2s(u.MinHeight)
		)
	elseif typeof(u) == "PathWaypoint" then
		return string.format("PathWaypoint.new(%s, %s)", v2s(u.Position), v2s(u.Action))
	elseif typeof(u) == "UDim" then
		return string.format("UDim.new(%s, %s)", v2s(u.Scale), v2s(u.Offset))
	elseif typeof(u) == "UDim2" then
		return string.format(
			"UDim2.new(%s, %s, %s, %s)",
			v2s(u.X.Scale),
			v2s(u.X.Offset),
			v2s(u.Y.Scale),
			v2s(u.Y.Offset)
		)
	elseif typeof(u) == "Rect" then
		return string.format("Rect.new(%s, %s)", v2s(u.Min), v2s(u.Max))
	else
		return string.format("nil --[[%s]]", typeof(u))
	end
end

--- Gets the player an instance is descended from
function getplayer(instance)
	for _, v in pairs(Players:GetPlayers()) do
		if v.Character and (instance:IsDescendantOf(v.Character) or instance == v.Character) then
			return v
		end
	end
end

--- value-to-path (in table)
function v2p(x, t, path, prev)
	if not path then
		path = ""
	end
	if not prev then
		prev = {}
	end
	if rawequal(x, t) then
		return true, ""
	end
	for i, v in pairs(t) do
		if rawequal(v, x) then
			if type(i) == "string" and i:match("^[%a_]+[%w_]*$") then
				return true, (path .. "." .. i)
			else
				return true, (path .. "[" .. v2s(i) .. "]")
			end
		end
		if type(v) == "table" then
			local duplicate = false
			for _, y in pairs(prev) do
				if rawequal(y, v) then
					duplicate = true
				end
			end
			if not duplicate then
				table.insert(prev, t)
				local found
				found, p = v2p(x, v, path, prev)
				if found then
					if type(i) == "string" and i:match("^[%a_]+[%w_]*$") then
						return true, "." .. i .. p
					else
						return true, "[" .. v2s(i) .. "]" .. p
					end
				end
			end
		end
	end
	return false, ""
end

--- format s: string, byte encrypt (for weird symbols)
function formatstr(s, indentation)
	if not indentation then
		indentation = 0
	end
	local handled, reachedMax = handlespecials(s, indentation)
	return '"'
		.. handled
		.. '"'
		.. (
			reachedMax
				and " --[[ MAXIMUM STRING SIZE REACHED, CHANGE '_G.SimpleSpyMaxStringSize' TO ADJUST MAXIMUM SIZE ]]"
			or ""
		)
end

--- Adds \'s to the text as a replacement to whitespace chars and other things because string.format can't yayeet
function handlespecials(value, indentation)
	local buildStr = {}
	local i = 1
	local char = string.sub(value, i, i)
	local indentStr
	while char ~= "" do
		if char == '"' then
			buildStr[i] = '\\"'
		elseif char == "\\" then
			buildStr[i] = "\\\\"
		elseif char == "\n" then
			buildStr[i] = "\\n"
		elseif char == "\t" then
			buildStr[i] = "\\t"
		elseif string.byte(char) > 126 or string.byte(char) < 32 then
			buildStr[i] = string.format("\\%d", string.byte(char))
		else
			buildStr[i] = char
		end
		i = i + 1
		char = string.sub(value, i, i)
		if i % 200 == 0 then
			indentStr = indentStr or string.rep(" ", indentation + indent)
			table.move({ '"\n', indentStr, '... "' }, 1, 3, i, buildStr)
			i += 3
		end
	end
	return table.concat(buildStr)
end

-- safe (ish) tostring
function safetostring(v: any)
	if typeof(v) == "userdata" or type(v) == "table" then
		local mt = getrawmetatable(v)
		local badtostring = mt and rawget(mt, "__tostring")
		if mt and badtostring then
			rawset(mt, "__tostring", nil)
			local out = tostring(v)
			rawset(mt, "__tostring", badtostring)
			return out
		end
	end
	return tostring(v)
end

--- finds script from 'src' from getinfo, returns nil if not found
--- @param src string
function getScriptFromSrc(src)
	local realPath
	local runningTest
	--- @type number
	local s, e
	local match = false
	if src:sub(1, 1) == "=" then
		realPath = game
		s = 2
	else
		runningTest = src:sub(2, e and e - 1 or -1)
		for _, v in pairs(getnilinstances()) do
			if v.Name == runningTest then
				realPath = v
				break
			end
		end
		s = #runningTest + 1
	end
	if realPath then
		e = src:sub(s, -1):find("%.")
		local i = 0
		repeat
			i += 1
			if not e then
				runningTest = src:sub(s, -1)
				local test = realPath.FindFirstChild(realPath, runningTest)
				if test then
					realPath = test
				end
				match = true
			else
				runningTest = src:sub(s, e)
				local test = realPath.FindFirstChild(realPath, runningTest)
				local yeOld = e
				if test then
					realPath = test
					s = e + 2
					e = src:sub(e + 2, -1):find("%.")
					e = e and e + yeOld or e
				else
					e = src:sub(e + 2, -1):find("%.")
					e = e and e + yeOld or e
				end
			end
		until match or i >= 50
	end
	return realPath
end

--- schedules the provided function (and calls it with any args after)
function schedule(f, ...)
	table.insert(scheduled, { f, ... })
end

--- yields the current thread until the scheduler gives the ok
function scheduleWait()
	local thread = coroutine.running()
	schedule(function()
		coroutine.resume(thread)
	end)
	coroutine.yield()
end

--- the big (well tbh small now) boi task scheduler himself, handles p much anything as quicc as possible
function taskscheduler()
	if not toggle then
		scheduled = {}
		return
	end
	if #scheduled > 1000 then
		table.remove(scheduled, #scheduled)
	end
	if #scheduled > 0 then
		local currentf = scheduled[1]
		table.remove(scheduled, 1)
		if type(currentf) == "table" and type(currentf[1]) == "function" then
			pcall(unpack(currentf))
		end
	end
end

--- Handles remote logs
function remoteHandler(hookfunction, methodName, remote, args, funcInfo, calling, returnValue)
	local validInstance, validClass = pcall(function()
		return remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")
	end)
	if validInstance and validClass then
		local func = funcInfo.func
		if not calling then
			_, calling = pcall(getScriptFromSrc, funcInfo.source)
		end
		coroutine.wrap(function()
			if remoteSignals[remote] then
				remoteSignals[remote]:Fire(args)
			end
		end)()
		if autoblock then
			if excluding[remote] then
				return
			end
			if not history[remote] then
				history[remote] = { badOccurances = 0, lastCall = tick() }
			end
			if tick() - history[remote].lastCall < 1 then
				history[remote].badOccurances += 1
				return
			else
				history[remote].badOccurances = 0
			end
			if history[remote].badOccurances > 3 then
				excluding[remote] = true
				return
			end
			history[remote].lastCall = tick()
		end
		local functionInfoStr
		local src
		if func and islclosure(func) then
			local functionInfo = {}
			functionInfo.info = funcInfo
			pcall(function()
				functionInfo.constants = debug.getconstants(func)
			end)
			pcall(function()
				functionInfoStr = v2v({ functionInfo = functionInfo })
			end)
			pcall(function()
				if type(calling) == "userdata" then
					src = calling
				end
			end)
		end
		if methodName:lower() == "fireserver" then
			newRemote(
				"event",
				remote.Name,
				args,
				remote,
				functionInfoStr,
				(blocklist[remote] or blocklist[remote.Name]),
				src
			)
		elseif methodName:lower() == "invokeserver" then
			newRemote(
				"function",
				remote.Name,
				args,
				remote,
				functionInfoStr,
				(blocklist[remote] or blocklist[remote.Name]),
				src,
				returnValue
			)
		end
	end
end

--- Used for hookfunction
function hookRemote(remoteType, remote, ...)
	if typeof(remote) == "Instance" then
		local args = { ... }
		local validInstance, remoteName = pcall(function()
			return remote.Name
		end)
		if validInstance and not (blacklist[remote] or blacklist[remoteName]) then
			local funcInfo = {}
			local calling
			if funcEnabled then
				funcInfo = debug.getinfo(4) or funcInfo
				calling = useGetCallingScript and getcallingscript() or nil
			end
			if recordReturnValues and remoteType == "RemoteFunction" then
				local thread = coroutine.running()
				local args = { ... }
				task.defer(function()
					local returnValue
					if remoteHooks[remote] then
						args = { remoteHooks[remote](unpack(args)) }
						returnValue = originalFunction(remote, unpack(args))
					else
						returnValue = originalFunction(remote, unpack(args))
					end
					schedule(
						remoteHandler,
						true,
						remoteType == "RemoteEvent" and "fireserver" or "invokeserver",
						remote,
						args,
						funcInfo,
						calling,
						returnValue
					)
					if blocklist[remote] or blocklist[remoteName] then
						coroutine.resume(thread)
					else
						coroutine.resume(thread, unpack(returnValue))
					end
				end)
			else
				schedule(
					remoteHandler,
					true,
					remoteType == "RemoteEvent" and "fireserver" or "invokeserver",
					remote,
					args,
					funcInfo,
					calling
				)
				if blocklist[remote] or blocklist[remoteName] then
					return
				end
			end
		end
	end
	if recordReturnValues and remoteType == "RemoteFunction" then
		return coroutine.yield()
	elseif remoteType == "RemoteEvent" then
		if remoteHooks[remote] then
			return originalEvent(remote, remoteHooks[remote](...))
		end
		return originalEvent(remote, ...)
	else
		if remoteHooks[remote] then
			return originalFunction(remote, remoteHooks[remote](...))
		end
		return originalFunction(remote, ...)
	end
end

local newnamecall = newcclosure(function(remote, ...)
	if typeof(remote) == "Instance" then
		local args = { ... }
		local methodName = getnamecallmethod()
		local validInstance, remoteName = pcall(function()
			return remote.Name
		end)
		if
			validInstance
			and (methodName == "FireServer" or methodName == "fireServer" or methodName == "InvokeServer" or methodName == "invokeServer")
			and not (blacklist[remote] or blacklist[remoteName])
		then
			local funcInfo = {}
			local calling
			if funcEnabled then
				funcInfo = debug.getinfo(3) or funcInfo
				calling = useGetCallingScript and getcallingscript() or nil
			end
			if recordReturnValues and (methodName == "InvokeServer" or methodName == "invokeServer") then
				local namecallThread = coroutine.running()
				local args = { ... }
				task.defer(function()
					local returnValue
					setnamecallmethod(methodName)
					if remoteHooks[remote] then
						args = { remoteHooks[remote](unpack(args)) }
						returnValue = { original(remote, unpack(args)) }
					else
						returnValue = { original(remote, unpack(args)) }
					end
					coroutine.resume(namecallThread, unpack(returnValue))
					coroutine.wrap(function()
						schedule(remoteHandler, false, methodName, remote, args, funcInfo, calling, returnValue)
					end)()
				end)
			else
				coroutine.wrap(function()
					schedule(remoteHandler, false, methodName, remote, args, funcInfo, calling)
				end)()
			end
		end
		if recordReturnValues and (methodName == "InvokeServer" or methodName == "invokeServer") then
			return coroutine.yield()
		elseif
			validInstance
			and (methodName == "FireServer" or methodName == "fireServer" or methodName == "InvokeServer" or methodName == "invokeServer")
			and (blocklist[remote] or blocklist[remoteName])
		then
			return nil
		elseif
			(not recordReturnValues or methodName ~= "InvokeServer" or methodName ~= "invokeServer")
			and validInstance
			and (methodName == "FireServer" or methodName == "fireServer" or methodName == "InvokeServer" or methodName == "invokeServer")
			and remoteHooks[remote]
		then
			return original(remote, remoteHooks[remote](...))
		else
			return original(remote, ...)
		end
	end
	return original(remote, ...)
end, original)

local newFireServer = newcclosure(function(...)
	return hookRemote("RemoteEvent", ...)
end, originalEvent)

local newInvokeServer = newcclosure(function(...)
	return hookRemote("RemoteFunction", ...)
end, originalFunction)

--- Toggles on and off the remote spy
function toggleSpy()
	if not toggle then
		if hookmetamethod then
			local oldNamecall = hookmetamethod(game, "__namecall", newnamecall)
			original = original or function(...)
				return oldNamecall(...)
			end
			_G.OriginalNamecall = original
		else
			gm = gm or getrawmetatable(game)
			original = original or function(...)
				return gm.__namecall(...)
			end
			setreadonly(gm, false)
			if not original then
				warn("SimpleSpy: namecall method not found!")
				onToggleButtonClick()
				return
			end
			gm.__namecall = newnamecall
			setreadonly(gm, true)
		end
		originalEvent = hookfunction(remoteEvent.FireServer, newFireServer)
		originalFunction = hookfunction(remoteFunction.InvokeServer, newInvokeServer)
	else
		if hookmetamethod then
			if original then
				hookmetamethod(game, "__namecall", original)
			end
		else
			gm = gm or getrawmetatable(game)
			setreadonly(gm, false)
			gm.__namecall = original
			setreadonly(gm, true)
		end
		hookfunction(remoteEvent.FireServer, originalEvent)
		hookfunction(remoteFunction.InvokeServer, originalFunction)
	end
end

--- Toggles between the two remotespy methods (hookfunction currently = disabled)
function toggleSpyMethod()
	toggleSpy()
	toggle = not toggle
end

--- Shuts down the remote spy
function shutdown()
	if schedulerconnect then
		schedulerconnect:Disconnect()
	end
	for _, connection in pairs(connections) do
		coroutine.wrap(function()
			connection:Disconnect()
		end)()
	end
	SimpleSpy2:Destroy()
	hookfunction(remoteEvent.FireServer, originalEvent)
	hookfunction(remoteFunction.InvokeServer, originalFunction)
	if hookmetamethod then
		if original then
			hookmetamethod(game, "__namecall", original)
		end
	else
		gm = gm or getrawmetatable(game)
		setreadonly(gm, false)
		gm.__namecall = original
		setreadonly(gm, true)
	end
	_G.SimpleSpyExecuted = false
end

-- main
if not _G.SimpleSpyExecuted then
	local succeeded, err = pcall(function()
		if not RunService:IsClient() then
			error("SimpleSpy cannot run on the server!")
		end
		if
			not hookfunction
			or not getrawmetatable
			or getrawmetatable and not getrawmetatable(game).__namecall
			or not setreadonly
		then
			local missing = {}
			if not hookfunction then
				table.insert(missing, "hookfunction")
			end
			if not getrawmetatable then
				table.insert(missing, "getrawmetatable")
			end
			if getrawmetatable and not getrawmetatable(game).__namecall then
				table.insert(missing, "getrawmetatable(game).__namecall")
			end
			if not setreadonly then
				table.insert(missing, "setreadonly")
			end
			shutdown()
			error(
				"This environment does not support method hooks!\n(Your exploit is not capable of running SimpleSpy)\nMissing: "
					.. table.concat(missing, ", ")
			)
		end
		_G.SimpleSpyShutdown = shutdown
		ContentProvider:PreloadAsync({
			"rbxassetid://6065821980",
			"rbxassetid://6065774948",
			"rbxassetid://6065821086",
			"rbxassetid://6065821596",
			ImageLabel,
			ImageLabel_2,
			ImageLabel_3,
		})
		-- if gethui then funcEnabled = false end
		onToggleButtonClick()
		RemoteTemplate.Parent = nil
		FunctionTemplate.Parent = nil
		codebox = Highlight.new(CodeBox)
		codebox:setRaw("")
		getgenv().SimpleSpy = SimpleSpy
		getgenv().getNil = function(name, class)
			for _, v in pairs(getnilinstances()) do
				if v.ClassName == class and v.Name == name then
					return v
				end
			end
		end
		TextLabel:GetPropertyChangedSignal("Text"):Connect(scaleToolTip)
		-- TopBar.InputBegan:Connect(onBarInput)
		MinimizeButton.MouseButton1Click:Connect(toggleMinimize)
		MaximizeButton.MouseButton1Click:Connect(toggleSideTray)
		Simple.MouseButton1Click:Connect(onToggleButtonClick)
		CloseButton.MouseEnter:Connect(onXButtonHover)
		CloseButton.MouseLeave:Connect(onXButtonUnhover)
		Simple.MouseEnter:Connect(onToggleButtonHover)
		Simple.MouseLeave:Connect(onToggleButtonUnhover)
		CloseButton.MouseButton1Click:Connect(shutdown)
		table.insert(connections, UserInputService.InputBegan:Connect(backgroundUserInput))
		connectResize()
		SimpleSpy2.Enabled = true
		coroutine.wrap(function()
			wait(1)
			onToggleButtonUnhover()
		end)()
		schedulerconnect = RunService.Heartbeat:Connect(taskscheduler)
		if syn and syn.protect_gui then
			pcall(syn.protect_gui, SimpleSpy2)
		end
		bringBackOnResize()
		SimpleSpy2.Parent = --[[gethui and gethui() or]]
			CoreGui
		_G.SimpleSpyExecuted = true
		if not Players.LocalPlayer then
			Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		end
		Mouse = Players.LocalPlayer:GetMouse()
		oldIcon = Mouse.Icon
		table.insert(connections, Mouse.Move:Connect(mouseMoved))
	end)
	if not succeeded then
		warn(
			"A fatal error has occured, SimpleSpy was unable to launch properly.\nPlease DM this error message to @exx#9394:\n\n"
				.. tostring(err)
		)
		SimpleSpy2:Destroy()
		hookfunction(remoteEvent.FireServer, originalEvent)
		hookfunction(remoteFunction.InvokeServer, originalFunction)
		if hookmetamethod then
			if original then
				hookmetamethod(game, "__namecall", original)
			end
		else
			setreadonly(gm, false)
			gm.__namecall = original
			setreadonly(gm, true)
		end
		return
	end
else
	SimpleSpy2:Destroy()
	return
end

----- ADD ONS ----- (easily add or remove additonal functionality to the RemoteSpy!)
--[[
    Some helpful things:
        - add your function in here, and create buttons for them through the 'newButton' function
        - the first argument provided is the TextButton the player clicks to run the function
        - generated scripts are generated when the namecall is initially fired and saved in remoteFrame objects
        - blacklisted remotes will be ignored directly in namecall (less lag)
        - the properties of a 'remoteFrame' object:
            {
                Name: (string) The name of the Remote
                GenScript: (string) The generated script that appears in the codebox (generated when namecall fired)
                Source: (Instance (LocalScript)) The script that fired/invoked the remote
                Remote: (Instance (RemoteEvent) | Instance (RemoteFunction)) The remote that was fired/invoked
                Log: (Instance (TextButton)) The button being used for the remote (same as 'selected.Log')
            }
        - globals list: (contact @exx#9394 for more information or if you have suggestions for more to be added)
            - closed: (boolean) whether or not the GUI is currently minimized
            - logs: (table[remoteFrame]) full of remoteFrame objects (properties listed above)
            - selected: (remoteFrame) the currently selected remoteFrame (properties listed above)
            - blacklist: (string[] | Instance[] (RemoteEvent) | Instance[] (RemoteFunction)) an array of blacklisted names and remotes
            - codebox: (Instance (TextBox)) the textbox that holds all the code- cleared often
]]
-- Copies the contents of the codebox
newButton("Copy Code", function()
	return "Click to copy code"
end, function()
	setclipboard(codebox:getString())
	TextLabel.Text = "Copied successfully!"
end)

--- Copies the source script (that fired the remote)
newButton("Copy Remote", function()
	return "Click to copy the path of the remote"
end, function()
	if selected then
		setclipboard(v2s(selected.Remote.remote))
		TextLabel.Text = "Copied!"
	end
end)

-- Executes the contents of the codebox through loadstring
newButton("Run Code", function()
	return "Click to execute code"
end, function()
	local orText = "Click to execute code"
	TextLabel.Text = "Executing..."
	local succeeded = pcall(function()
		return loadstring(codebox:getString())()
	end)
	if succeeded then
		TextLabel.Text = "Executed successfully!"
	else
		TextLabel.Text = "Execution error!"
	end
end)

--- Gets the calling script (not super reliable but w/e)
newButton("Get Script", function()
	return "Click to copy calling script to clipboard\nWARNING: Not super reliable, nil == could not find"
end, function()
	if selected then
		setclipboard(SimpleSpy:ValueToString(selected.Source))
		TextLabel.Text = "Done!"
	end
end)

--- Decompiles the script that fired the remote and puts it in the code box
newButton("Function Info", function()
	return "Click to view calling function information"
end, function()
	if selected then
		if selected.Function then
			codebox:setRaw(
				"-- Calling function info\n-- Generated by the SimpleSpy serializer\n\n" .. tostring(selected.Function)
			)
		end
		TextLabel.Text = "Done! Function info generated by the SimpleSpy Serializer."
	end
end)

--- Clears the Remote logs
newButton("Clr Logs", function()
	return "Click to clear logs"
end, function()
	TextLabel.Text = "Clearing..."
	logs = {}
	for _, v in pairs(LogList:GetChildren()) do
		if not v:IsA("UIListLayout") then
			v:Destroy()
		end
	end
	codebox:setRaw("")
	selected = nil
	TextLabel.Text = "Logs cleared!"
end)

--- Excludes the selected.Log Remote from the RemoteSpy
newButton("Exclude (i)", function()
	return "Click to exclude this Remote.\nExcluding a remote makes SimpleSpy ignore it, but it will continue to be usable."
end, function()
	if selected then
		blacklist[selected.Remote.remote] = true
		TextLabel.Text = "Excluded!"
	end
end)

--- Excludes all Remotes that share the same name as the selected.Log remote from the RemoteSpy
newButton("Exclude (n)", function()
	return "Click to exclude all remotes with this name.\nExcluding a remote makes SimpleSpy ignore it, but it will continue to be usable."
end, function()
	if selected then
		blacklist[selected.Name] = true
		TextLabel.Text = "Excluded!"
	end
end)

--- clears blacklist
newButton("Clr Blacklist", function()
	return "Click to clear the blacklist.\nExcluding a remote makes SimpleSpy ignore it, but it will continue to be usable."
end, function()
	blacklist = {}
	TextLabel.Text = "Blacklist cleared!"
end)

--- Prevents the selected.Log Remote from firing the server (still logged)
newButton("Block (i)", function()
	return "Click to stop this remote from firing.\nBlocking a remote won't remove it from SimpleSpy logs, but it will not continue to fire the server."
end, function()
	if selected then
		if selected.Remote.remote then
			blocklist[selected.Remote.remote] = true
			TextLabel.Text = "Excluded!"
		else
			TextLabel.Text = "Error! Instance may no longer exist, try using Block (n)."
		end
	end
end)

--- Prevents all remotes from firing that share the same name as the selected.Log remote from the RemoteSpy (still logged)
newButton("Block (n)", function()
	return "Click to stop remotes with this name from firing.\nBlocking a remote won't remove it from SimpleSpy logs, but it will not continue to fire the server."
end, function()
	if selected then
		blocklist[selected.Name] = true
		TextLabel.Text = "Excluded!"
	end
end)

--- clears blacklist
newButton("Clr Blocklist", function()
	return "Click to stop blocking remotes.\nBlocking a remote won't remove it from SimpleSpy logs, but it will not continue to fire the server."
end, function()
	blocklist = {}
	TextLabel.Text = "Blocklist cleared!"
end)

--- Attempts to decompile the source script
newButton("Decompile", function()
	return "Attempts to decompile source script\nWARNING: Not super reliable, nil == could not find"
end, function()
	if selected then
		if selected.Source then
			codebox:setRaw(decompile(selected.Source))
			TextLabel.Text = "Done!"
		else
			TextLabel.Text = "Source not found!"
		end
	end
end)

newButton("Disable Info", function()
	return string.format(
		"[%s] Toggle function info (because it can cause lag in some games)",
		funcEnabled and "ENABLED" or "DISABLED"
	)
end, function()
	funcEnabled = not funcEnabled
	TextLabel.Text = string.format(
		"[%s] Toggle function info (because it can cause lag in some games)",
		funcEnabled and "ENABLED" or "DISABLED"
	)
end)

newButton("Autoblock", function()
	return string.format(
		"[%s] [BETA] Intelligently detects and excludes spammy remote calls from logs",
		autoblock and "ENABLED" or "DISABLED"
	)
end, function()
	autoblock = not autoblock
	TextLabel.Text = string.format(
		"[%s] [BETA] Intelligently detects and excludes spammy remote calls from logs",
		autoblock and "ENABLED" or "DISABLED"
	)
	history = {}
	excluding = {}
end)

newButton("CallingScript", function()
	return string.format(
		"[%s] [UNSAFE] Uses 'getcallingscript' to get calling script for Decompile and GetScript. Much more reliable, but opens up SimpleSpy to detection and/or instability.",
		useGetCallingScript and "ENABLED" or "DISABLED"
	)
end, function()
	useGetCallingScript = not useGetCallingScript
	TextLabel.Text = string.format(
		"[%s] [UNSAFE] Uses 'getcallingscript' to get calling script for Decompile and GetScript. Much more reliable, but opens up SimpleSpy to detection and/or instability.",
		useGetCallingScript and "ENABLED" or "DISABLED"
	)
end)

newButton("KeyToString", function()
	return string.format(
		"[%s] [BETA] Uses an experimental new function to replicate Roblox's behavior when a non-primitive type is used as a key in a table. Still in development and may not properly reflect tostringed (empty) userdata.",
		keyToString and "ENABLED" or "DISABLED"
	)
end, function()
	keyToString = not keyToString
	TextLabel.Text = string.format(
		"[%s] [BETA] Uses an experimental new function to replicate Roblox's behavior when a non-primitive type is used as a key in a table. Still in development and may not properly reflect tostringed (empty) userdata.",
		keyToString and "ENABLED" or "DISABLED"
	)
end)

newButton("ToggleReturnValues", function()
	return string.format(
		"[%s] [EXPERIMENTAL] Enables recording of return values for 'GetReturnValue'\n\nUse this method at your own risk, as it could be detectable.",
		recordReturnValues and "ENABLED" or "DISABLED"
	)
end, function()
	recordReturnValues = not recordReturnValues
	TextLabel.Text = string.format(
		"[%s] [EXPERIMENTAL] Enables recording of return values for 'GetReturnValue'\n\nUse this method at your own risk, as it could be detectable.",
		recordReturnValues and "ENABLED" or "DISABLED"
	)
end)

newButton("GetReturnValue", function()
	return "[Experimental] If 'ReturnValues' is enabled, this will show the recorded return value for the RemoteFunction (if available)."
end, function()
	if selected then
		codebox:setRaw(SimpleSpy:ValueToVar(selected.ReturnValue, "returnValue"))
	end
end)
    end
})
MainTab:AddButton({
    Title = "Ghost",
    Description = "",
    Callback = function()
--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GhostGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

--// Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,65,0,60)
Frame.Position = UDim2.new(0.1,0,0.2,0)
Frame.BackgroundTransparency = 1
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local FrameBorder = Instance.new("UIStroke", Frame)
FrameBorder.Thickness = 3
FrameBorder.Color = Color3.fromRGB(0,255,255)

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0,15)

--// Title
local TextLabel = Instance.new("TextLabel")
TextLabel.Text = "Ghost"
TextLabel.Size = UDim2.new(1,0,0.4,0)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.TextScaled = true
TextLabel.Parent = Frame

--// Toggle Container
local Toggle = Instance.new("Frame")
Toggle.Size = UDim2.new(0.85,0,0.4,0)
Toggle.Position = UDim2.new(0.075,0,0.55,0)
Toggle.BackgroundTransparency = 1
Toggle.Parent = Frame

local ToggleBorder = Instance.new("UIStroke", Toggle)
ToggleBorder.Thickness = 3
ToggleBorder.Color = Color3.fromRGB(0,255,255)

local UICorner2 = Instance.new("UICorner", Toggle)
UICorner2.CornerRadius = UDim.new(1,0)

local ToggleBg = Instance.new("Frame", Toggle)
ToggleBg.Size = UDim2.new(1,0,1,0)
ToggleBg.BackgroundColor3 = Color3.fromRGB(60,60,60)

local ToggleBgCorner = Instance.new("UICorner", ToggleBg)
ToggleBgCorner.CornerRadius = UDim.new(1,0)

local Circle = Instance.new("Frame", Toggle)
Circle.Size = UDim2.new(0.45,0,1,0)
Circle.BackgroundColor3 = Color3.fromRGB(255,255,255)

local CircleCorner = Instance.new("UICorner", Circle)
CircleCorner.CornerRadius = UDim.new(1,0)

local ClickBtn = Instance.new("TextButton", Toggle)
ClickBtn.Size = UDim2.new(1,0,1,0)
ClickBtn.Text = ""
ClickBtn.BackgroundTransparency = 1

--// FakeLag logic
local Enabled = false
local anchoredParts = {}

local function enableFakeLag()
    anchoredParts = {}
    local char = LocalPlayer.Character
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not (char and obj:IsDescendantOf(char)) then
            if not obj.Anchored then
                obj.Anchored = true
                table.insert(anchoredParts, obj)
            end
        end
    end
end

local function disableFakeLag()
    for _, p in ipairs(anchoredParts) do
        if p and p.Parent then
            p.Anchored = false
        end
    end
    anchoredParts = {}
end

ClickBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    if Enabled then
        ToggleBg.BackgroundColor3 = Color3.fromRGB(0,255,0)
        Circle:TweenPosition(UDim2.new(0.55,0,0,0),"Out","Sine",0.25,true)
        enableFakeLag()
    else
        ToggleBg.BackgroundColor3 = Color3.fromRGB(60,60,60)
        Circle:TweenPosition(UDim2.new(0,0,0,0),"Out","Sine",0.25,true)
        disableFakeLag()
    end
end)

--// Teleport +20 button
local TPBtn = Instance.new("TextButton")
TPBtn.Size = UDim2.new(1,-10,0,18)
TPBtn.Position = UDim2.new(0,5,1,5)
TPBtn.Text = "tele"
TPBtn.TextScaled = true
TPBtn.BackgroundColor3 = Color3.fromRGB(0,200,255)
TPBtn.TextColor3 = Color3.fromRGB(0,0,0)
TPBtn.Parent = Frame

local TPCorner = Instance.new("UICorner", TPBtn)
TPCorner.CornerRadius = UDim.new(0,8)

TPBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame =
            char.HumanoidRootPart.CFrame * CFrame.new(0,0,-10)
    end
end)
end
})
MainTab:AddButton({
    Title = "Teleport VIP",
    Description = "",
    Callback = function()
-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- GUI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,65,0,60)
Frame.Position = UDim2.new(0.1,0,0.2,0)
Frame.BackgroundTransparency = 1
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local FrameBorder = Instance.new("UIStroke")
FrameBorder.Thickness = 3
FrameBorder.Color = Color3.fromRGB(0,255,255)
FrameBorder.Parent = Frame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,15)
UICorner.Parent = Frame

-- Text
local TextLabel = Instance.new("TextLabel")
TextLabel.Text = "Tele"
TextLabel.Size = UDim2.new(1,0,0.4,0)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.TextScaled = true
TextLabel.Parent = Frame

-- Toggle
local Toggle = Instance.new("Frame")
Toggle.Size = UDim2.new(0.85,0,0.4,0)
Toggle.Position = UDim2.new(0.075,0,0.55,0)
Toggle.BackgroundTransparency = 1
Toggle.Parent = Frame

local ToggleBorder = Instance.new("UIStroke")
ToggleBorder.Thickness = 3
ToggleBorder.Color = Color3.fromRGB(0,255,255)
ToggleBorder.Parent = Toggle

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(1,0)
UICorner2.Parent = Toggle

local Circle = Instance.new("Frame")
Circle.Size = UDim2.new(0.45,0,1,0)
Circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
Circle.Parent = Toggle

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(1,0)
UICorner3.Parent = Circle

local ToggleBg = Instance.new("Frame")
ToggleBg.Size = UDim2.new(1,0,1,0)
ToggleBg.Position = UDim2.new(0,0,0,0)
ToggleBg.BackgroundColor3 = Color3.fromRGB(60,60,60) -- màu nền OFF
ToggleBg.BackgroundTransparency = 0
ToggleBg.ZIndex = 0
ToggleBg.Parent = Toggle

local ToggleBgCorner = Instance.new("UICorner")
ToggleBgCorner.CornerRadius = UDim.new(1,0)
ToggleBgCorner.Parent = ToggleBg

local ClickBtn = Instance.new("TextButton")
ClickBtn.Size = UDim2.new(1,0,1,0)
ClickBtn.Text = ""
ClickBtn.BackgroundTransparency = 1
ClickBtn.Parent = Toggle

-- =========================
-- AUTO TP TWEEN LOGIC
-- =========================
local Enabled = false
local tpDelay = 0.6        -- thời gian giữa mỗi lần TP
local tweenTime = 0.4     -- thời gian bay mượt
local currentTween

local function getNearestEnemy()
    local char = LocalPlayer.Character
    if not char then return nil end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local nearest = nil
    local minDist = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer
        and isEnemy(plr)
        and plr.Character then

            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")

            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = plr
                end
            end
        end
    end

    return nearest
end

-- Toggle
ClickBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    if Enabled then
        -- UI ON
        ToggleBg.BackgroundTransparency = 0
        ToggleBg.BackgroundColor3 = Color3.fromRGB(0,255,0)
        Circle:TweenPosition(UDim2.new(0.55,0,0,0), "Out", "Sine", 0.3, true)

        task.spawn(function()
            while Enabled do
                local target = getNearestPlayer()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    if currentTween then currentTween:Cancel() end

                    local goalCF = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
                    local tweenInfo = TweenInfo.new(
                        tweenTime,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.Out
                    )

                    currentTween = TweenService:Create(root, tweenInfo, {CFrame = goalCF})
                    currentTween:Play()
                end
                task.wait(tpDelay)
            end
        end)

    else
        -- UI OFF
        ToggleBg.BackgroundTransparency = 1
        Circle:TweenPosition(UDim2.new(0,0,0,0), "Out", "Sine", 0.3, true)

        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end
    end
end)
    end
})
MainTab:AddButton({
    Title = "Auto Click",
    Description = "",
    Callback = function()
--// GUI Toggle Auto Right Click Script
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

-- GUI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,65,0,60)
Frame.Position = UDim2.new(0.1,0,0.2,0)
Frame.BackgroundTransparency = 1 -- trong suốt
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local FrameBorder = Instance.new("UIStroke")
FrameBorder.Thickness = 3
FrameBorder.Color = Color3.fromRGB(0, 255, 255) -- viền cyan
FrameBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
FrameBorder.Parent = Frame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,15)
UICorner.Parent = Frame

-- Text
local TextLabel = Instance.new("TextLabel")
TextLabel.Text = "AutoClick"
TextLabel.Size = UDim2.new(1,0,0.4,0)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.TextScaled = true
TextLabel.Parent = Frame

-- Toggle container
local Toggle = Instance.new("Frame")
Toggle.Size = UDim2.new(0.85,0,0.4,0)
Toggle.Position = UDim2.new(0.075,0,0.55,0)
Toggle.BackgroundTransparency = 1
Toggle.Parent = Frame

local ToggleBorder = Instance.new("UIStroke")
ToggleBorder.Thickness = 3
ToggleBorder.Color = Color3.fromRGB(0, 255, 255)
ToggleBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ToggleBorder.Parent = Toggle

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(1,0)
UICorner2.Parent = Toggle

-- Nút tròn trắng
local Circle = Instance.new("Frame")
Circle.Size = UDim2.new(0.45,0,1,0)
Circle.Position = UDim2.new(0,0,0,0)
Circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
Circle.Parent = Toggle

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(1,0)
UICorner3.Parent = Circle

-- Nền toggle
local ToggleBg = Instance.new("Frame")
ToggleBg.Size = UDim2.new(1,0,1,0)
ToggleBg.BackgroundTransparency = 1
ToggleBg.Parent = Toggle

local ToggleBgCorner = Instance.new("UICorner")
ToggleBgCorner.CornerRadius = UDim.new(1,0)
ToggleBgCorner.Parent = ToggleBg

ToggleBg.ZIndex = 0
Circle.ZIndex = 1

-- Invisible button để click
local ClickBtn = Instance.new("TextButton")
ClickBtn.Size = UDim2.new(1,0,1,0)
ClickBtn.Text = ""
ClickBtn.BackgroundTransparency = 1
ClickBtn.Parent = Toggle

-- Trạng thái toggle
local Enabled = false
local attackDelay = 0.1 -- tốc độ spam click phải

-- Toggle function
ClickBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    if Enabled then
        ToggleBg.BackgroundTransparency = 0
        ToggleBg.BackgroundColor3 = Color3.fromRGB(0,255,0) -- xanh lá khi bật
        Circle:TweenPosition(UDim2.new(0.55,0,0,0), "Out", "Sine", 0.3, true)

        -- Spam Right Click
        task.spawn(function()
            while Enabled do
                VirtualUser:ClickButton1(Vector2.new()) -- spam chuột phải
                task.wait(attackDelay)
            end
        end)
    else
        ToggleBg.BackgroundTransparency = 1
        Circle:TweenPosition(UDim2.new(0,0,0,0), "Out", "Sine", 0.3, true)
    end
end)
    end
})
OptTab:AddButton({
    Title = "Fix Lag Smooth",
    Description = "",
    Callback = function()

local ToDisable = {
	Textures = true,
	VisualEffects = true,
	Parts = true,
	Particles = true,
	Sky = true
}

local ToEnable = {
	FullBright = false
}

local Stuff = {}

for _, v in next, game:GetDescendants() do
	if ToDisable.Parts then
		if v:IsA("Part") or v:IsA("Union") or v:IsA("BasePart") then
			v.Material = Enum.Material.SmoothPlastic
			table.insert(Stuff, 1, v)
		end
	end
	
	if ToDisable.Particles then
		if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire") then
			v.Enabled = false
			table.insert(Stuff, 1, v)
		end
	end
	
	if ToDisable.VisualEffects then
		if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
			v.Enabled = false
			table.insert(Stuff, 1, v)
		end
	end
	
	if ToDisable.Textures then
		if v:IsA("Decal") or v:IsA("Texture") then
			v.Texture = ""
			table.insert(Stuff, 1, v)
		end
	end
	
	if ToDisable.Sky then
		if v:IsA("Sky") then
			v.Parent = nil
			table.insert(Stuff, 1, v)
		end
	end
end

game:GetService("TestService"):Message("Effects Disabler Script : Successfully disabled "..#Stuff.." assets / effects. Settings :")

for i, v in next, ToDisable do
	print(tostring(i)..": "..tostring(v))
end

if ToEnable.FullBright then
    local Lighting = game:GetService("Lighting")
    
    Lighting.FogColor = Color3.fromRGB(255, 255, 255)
    Lighting.FogEnd = math.huge
    Lighting.FogStart = math.huge
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.Brightness = 5
    Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
    Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Outlines = true
end
repeat
    wait()
until game:IsLoaded()
if game.PlaceId == 2753915549 then
    World1 = true
elseif game.PlaceId == 4442272183 then
    World2 = true
elseif game.PlaceId == 7449423635 then
    World3 = true
end
local function FPSBooster()
    local decalsyeeted = true
    local g = game
    local w = g.Workspace
    local l = g.Lighting
    local t = w.Terrain
    
    sethiddenproperty(l, "Technology", Enum.Technology.Compatibility)
    sethiddenproperty(t, "Decoration", false)
    
    t.WaterWaveSize = 0
    t.WaterWaveSpeed = 0
    t.WaterReflectance = 0
    t.WaterTransparency = 0
    
    l.GlobalShadows = false
    l.FogEnd = 9e9
    l.Brightness = 0
    
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    for _, v in pairs(g:GetDescendants()) do
        if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("MeshPart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        end
    end
    
    for _, e in pairs(l:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
            e.Enabled = false
        end
    end
end

FPSBooster()
            setfpscap(9999999999)
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            workspace.ChildAdded:Connect(function(obj)
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") then
                    obj.Enabled = false
                end
            end)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Kiểm tra object có phải là character của player
local function isPlayerCharacter(obj)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and obj:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

-- Xoá tất cả skin object không phải của player
local function removeNonPlayerSkins()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local lowerName = obj.Name:lower()
        -- Chỉ check object là Model / Mesh / Part có chữ "skin" trong tên
        if (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) and string.find(lowerName, "skin") then
            if not isPlayerCharacter(obj) then
                print("[Xóa Skin]:", obj:GetFullName()) -- In log để debug
                obj:Destroy()
            end
        end
    end
end

-- Gọi hàm xoá một lần
removeNonPlayerSkins()

-- Tự động xoá khi có skin mới spawn
Workspace.DescendantAdded:Connect(function(obj)
    local lowerName = obj.Name:lower()
    if (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) and string.find(lowerName, "skin") then
        if not isPlayerCharacter(obj) then
            print("[Xóa Skin mới spawn]:", obj:GetFullName())
            obj:Destroy()
        end
    end
end)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Kiểm tra object có phải là character player không
local function isPlayerCharacter(obj)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and obj:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

-- Hàm đổi màu skin không phải của player
local function recolorNonPlayerSkins()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local lowerName = obj.Name:lower()
        if (obj:IsA("Part") or obj:IsA("MeshPart")) and string.find(lowerName, "skin") then
            if not isPlayerCharacter(obj) then
                obj.Color = Color3.new(1, 1, 1) -- đổi thành màu trắng
                obj.Material = Enum.Material.SmoothPlastic
            end
        end
    end
end

-- Gọi một lần
recolorNonPlayerSkins()

-- Nếu muốn áp dụng cho skin mới xuất hiện
Workspace.DescendantAdded:Connect(function(obj)
    local lowerName = obj.Name:lower()
    if (obj:IsA("Part") or obj:IsA("MeshPart")) and string.find(lowerName, "skin") then
        if not isPlayerCharacter(obj) then
            obj.Color = Color3.new(1, 1, 1)
            obj.Material = Enum.Material.SmoothPlastic
        end
    end
end)

    end
})

-- Biến toàn cục lưu CFrame đã grab
local SavedPositionCFrame = nil

-- === MainTab Button: Grab Position ===
TeleTab:AddButton({
    Title = "Grab Position",
    Description = "Lấy tọa độ hiện tại (x, y, z) và copy vào clipboard",
    Callback = function()
        local lp = game.Players.LocalPlayer
        local char = lp.Character or lp.CharacterAdded:Wait()
        if char and char.PrimaryPart then
            local pos = char.PrimaryPart.Position
            SavedPositionCFrame = CFrame.new(pos.X, pos.Y, pos.Z)

            -- Copy vào clipboard dưới dạng CFrame.new(x, y, z)
            setclipboard(("CFrame.new(%f, %f, %f)"):format(pos.X, pos.Y, pos.Z))

            -- In ra console để debug
            print("[Grabbed Position]:", SavedPositionCFrame)
        else
            warn("Không tìm thấy nhân vật hoặc PrimaryPart!")
        end
    end
})

-- === TestTab Button: Teleport to Position ===
TeleTab:AddButton({
    Title = "Teleport to Position",
    Description = "Dịch chuyển tới vị trí đã grab",
    Callback = function()
        local lp = game.Players.LocalPlayer
        local char = lp.Character or lp.CharacterAdded:Wait()
        if SavedPositionCFrame and char and char.PrimaryPart then
            char:SetPrimaryPartCFrame(SavedPositionCFrame)
        else
            warn("Chưa có vị trí nào được grab hoặc không tìm thấy nhân vật!")
        end
    end
})

-- === TestTab Button: Reset Position ===
TeleTab:AddButton({
    Title = "Reset Position",
    Description = "Xóa vị trí đã grab (CFrame = nil)",
    Callback = function()
        SavedPositionCFrame = nil
        print("[Reset Position]: Đã xóa vị trí đã lưu.")
    end
})
OptTab:AddInput("FpsCap", {
    Title = "FPS Cap",
    Description = "Nhập số FPS muốn giới hạn",
    Default = "60", -- mặc định
    Placeholder = "Ví dụ: 120",
    Numeric = true,
    Finished = true, -- chỉ chạy khi bấm Enter/xong input
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            setfpscap(num)
        else

        end
    end
})
MainTab:AddButton({
    Title = "Open Fly Gui",
    Description = "",
    Callback = function()
local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local up = Instance.new("TextButton")
local down = Instance.new("TextButton")
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speed = Instance.new("TextLabel")
local mine = Instance.new("TextButton")
local closebutton = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local mini2 = Instance.new("TextButton")

main.Name = "main"
main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
Frame.Size = UDim2.new(0, 190, 0, 57)

up.Name = "up"
up.Parent = Frame
up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
up.Size = UDim2.new(0, 44, 0, 28)
up.Font = Enum.Font.SourceSans
up.Text = "UP"
up.TextColor3 = Color3.fromRGB(0, 0, 0)
up.TextSize = 14.000

down.Name = "down"
down.Parent = Frame
down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
down.Position = UDim2.new(0, 0, 0.491228074, 0)
down.Size = UDim2.new(0, 44, 0, 28)
down.Font = Enum.Font.SourceSans
down.Text = "DOWN"
down.TextColor3 = Color3.fromRGB(0, 0, 0)
down.TextSize = 14.000

onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
onof.Size = UDim2.new(0, 56, 0, 28)
onof.Font = Enum.Font.SourceSans
onof.Text = "fly"
onof.TextColor3 = Color3.fromRGB(0, 0, 0)
onof.TextSize = 14.000

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
TextLabel.Size = UDim2.new(0, 100, 0, 28)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "FLY GUI V3"
TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true

plus.Name = "plus"
plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
plus.Position = UDim2.new(0.231578946, 0, 0, 0)
plus.Size = UDim2.new(0, 45, 0, 28)
plus.Font = Enum.Font.SourceSans
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(0, 0, 0)
plus.TextScaled = true
plus.TextSize = 14.000
plus.TextWrapped = true

speed.Name = "speed"
speed.Parent = Frame
speed.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
speed.Position = UDim2.new(0.468421042, 0, 0.491228074, 0)
speed.Size = UDim2.new(0, 44, 0, 28)
speed.Font = Enum.Font.SourceSans
speed.Text = "1"
speed.TextColor3 = Color3.fromRGB(0, 0, 0)
speed.TextScaled = true
speed.TextSize = 14.000
speed.TextWrapped = true

mine.Name = "mine"
mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 0)
mine.Size = UDim2.new(0, 45, 0, 29)
mine.Font = Enum.Font.SourceSans
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(0, 0, 0)
mine.TextScaled = true
mine.TextSize = 14.000
mine.TextWrapped = true

closebutton.Name = "Close"
closebutton.Parent = main.Frame
closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
closebutton.Font = "SourceSans"
closebutton.Size = UDim2.new(0, 45, 0, 28)
closebutton.Text = "X"
closebutton.TextSize = 30
closebutton.Position =  UDim2.new(0, 0, -1, 27)

mini.Name = "minimize"
mini.Parent = main.Frame
mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
mini.Font = "SourceSans"
mini.Size = UDim2.new(0, 45, 0, 28)
mini.Text = "-"
mini.TextSize = 40
mini.Position = UDim2.new(0, 44, -1, 27)

mini2.Name = "minimize2"
mini2.Parent = main.Frame
mini2.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
mini2.Font = "SourceSans"
mini2.Size = UDim2.new(0, 45, 0, 28)
mini2.Text = "+"
mini2.TextSize = 40
mini2.Position = UDim2.new(0, 44, -1, 57)
mini2.Visible = false

speeds = 1

local speaker = game:GetService("Players").LocalPlayer

local chr = game.Players.LocalPlayer.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")

nowe = false


Frame.Active = true -- main = gui
Frame.Draggable = true

onof.MouseButton1Down:connect(function()

	if nowe == true then
		nowe = false

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	else 
		nowe = true



		for i = 1, speeds do
			spawn(function()

				local hb = game:GetService("RunService").Heartbeat	


				tpwalking = true
				local chr = game.Players.LocalPlayer.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end

			end)
		end
		game.Players.LocalPlayer.Character.Animate.Disabled = true
		local Char = game.Players.LocalPlayer.Character
		local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

		for i,v in next, Hum:GetPlayingAnimationTracks() do
			v:AdjustSpeed(0)
		end
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	end




	if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then



		local plr = game.Players.LocalPlayer
		local torso = plr.Character.Torso
		local flying = true
		local deb = true
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0


		local bg = Instance.new("BodyGyro", torso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = torso.CFrame
		local bv = Instance.new("BodyVelocity", torso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			game:GetService("RunService").RenderStepped:Wait()

			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end
			--	game.Players.LocalPlayer.Character.Animate.Disabled = true
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		game.Players.LocalPlayer.Character.Animate.Disabled = false
		tpwalking = false




	else
		local plr = game.Players.LocalPlayer
		local UpperTorso = plr.Character.UpperTorso
		local flying = true
		local deb = true
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0


		local bg = Instance.new("BodyGyro", UpperTorso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = UpperTorso.CFrame
		local bv = Instance.new("BodyVelocity", UpperTorso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			wait()

			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end

			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		game.Players.LocalPlayer.Character.Animate.Disabled = false
		tpwalking = false



	end





end)

local tis

up.MouseButton1Down:connect(function()
	tis = up.MouseEnter:connect(function()
		while tis do
			wait()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
		end
	end)
end)

up.MouseLeave:connect(function()
	if tis then
		tis:Disconnect()
		tis = nil
	end
end)

local dis

down.MouseButton1Down:connect(function()
	dis = down.MouseEnter:connect(function()
		while dis do
			wait()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
		end
	end)
end)

down.MouseLeave:connect(function()
	if dis then
		dis:Disconnect()
		dis = nil
	end
end)


game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
	wait(0.7)
	game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
	game.Players.LocalPlayer.Character.Animate.Disabled = false

end)


plus.MouseButton1Down:connect(function()
	speeds = speeds + 1
	speed.Text = speeds
	if nowe == true then


		tpwalking = false
		for i = 1, speeds do
			spawn(function()

				local hb = game:GetService("RunService").Heartbeat	


				tpwalking = true
				local chr = game.Players.LocalPlayer.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end

			end)
		end
	end
end)
mine.MouseButton1Down:connect(function()
	if speeds == 1 then
		speed.Text = 'cannot be less than 1'
		wait(1)
		speed.Text = speeds
	else
		speeds = speeds - 1
		speed.Text = speeds
		if nowe == true then
			tpwalking = false
			for i = 1, speeds do
				spawn(function()

					local hb = game:GetService("RunService").Heartbeat	


					tpwalking = true
					local chr = game.Players.LocalPlayer.Character
					local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
					while tpwalking and hb:Wait() and chr and hum and hum.Parent do
						if hum.MoveDirection.Magnitude > 0 then
							chr:TranslateBy(hum.MoveDirection)
						end
					end

				end)
			end
		end
	end
end)

closebutton.MouseButton1Click:Connect(function()
	main:Destroy()
end)

mini.MouseButton1Click:Connect(function()
	up.Visible = false
	down.Visible = false
	onof.Visible = false
	plus.Visible = false
	speed.Visible = false
	mine.Visible = false
	mini.Visible = false
	mini2.Visible = true
	main.Frame.BackgroundTransparency = 1
	closebutton.Position =  UDim2.new(0, 0, -1, 57)
end)

mini2.MouseButton1Click:Connect(function()
	up.Visible = true
	down.Visible = true
	onof.Visible = true
	plus.Visible = true
	speed.Visible = true
	mine.Visible = true
	mini.Visible = true
	mini2.Visible = false
	main.Frame.BackgroundTransparency = 0 
	closebutton.Position =  UDim2.new(0, 0, -1, 27)
end)
    end
})


MainTab:AddButton({
    Title = "Open Toggle",
    Description = "",
    Callback = function()
-- Biến cấu hình
local fakeLagActive = false
local fakeLagConn = nil
local anchoredParts = {}
local teleportRadius = 20
local teleportDelay = 0.4
local startupSoundEnabled = true
local timeStopDuration = 2.55
local teleKeybind = nil
local fakeLagKeybind = nil

-- Âm thanh startup
local startupSound = Instance.new("Sound")
startupSound.SoundId = "rbxassetid://1283290053"
startupSound.Volume = 2
startupSound.Looped = false
startupSound.Parent = workspace

-- Hàm teleport
local function teleportForward(button)
    if startupSoundEnabled then
        startupSound:Play()
    end
    button.Text = "..."
    task.delay(teleportDelay, function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local look = workspace.CurrentCamera.CFrame.LookVector
            hrp.CFrame = hrp.CFrame + (look * teleportRadius)
            if startupSoundEnabled then
                startupSound:Play()
            end
        end
        button.Text = "✅"
        task.delay(0.5, function()
            button.Text = "🧊"
        end)
    end)
end

--== GUI ==--
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "CustomGui"

local UserInputService = game:GetService("UserInputService")
local function makeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Nút Teleport
local teleBtn = Instance.new("TextButton", ScreenGui)
teleBtn.Size = UDim2.new(0, 50, 0, 50)
teleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
teleBtn.Text = "🧊"
teleBtn.Font = Enum.Font.SourceSansBold
teleBtn.TextSize = 20
teleBtn.TextColor3 = Color3.new(1,1,1)
teleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", teleBtn).CornerRadius = UDim.new(0,12)
makeDraggable(teleBtn)
teleBtn.MouseButton1Click:Connect(function()
    teleportForward(teleBtn)
end)

-- Nút FakeLag
local timeBtn = Instance.new("TextButton", ScreenGui)
timeBtn.Size = UDim2.new(0, 50, 0, 50)
timeBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
timeBtn.Text = "⚡️"
timeBtn.Font = Enum.Font.SourceSansBold
timeBtn.TextSize = 20
timeBtn.TextColor3 = Color3.new(1,1,1)
timeBtn.BackgroundColor3 = Color3.fromRGB(100,30,30)
Instance.new("UICorner", timeBtn).CornerRadius = UDim.new(0,12)
makeDraggable(timeBtn)

-- Countdown label
local countdownLabel = Instance.new("TextLabel", timeBtn)
countdownLabel.Size = UDim2.new(1, 0, 0, 20)
countdownLabel.Position = UDim2.new(0, 0, 0.3, 0)
countdownLabel.Text = ""
countdownLabel.Font = Enum.Font.SourceSansBold
countdownLabel.TextSize = 16
countdownLabel.TextColor3 = Color3.new(1,1,0)
countdownLabel.BackgroundTransparency = 1
countdownLabel.TextStrokeTransparency = 0.2

-- Hàm TimeStop
local function timeStop(button)
    if not fakeLagActive then
        fakeLagActive = true
        button.Text = "  "
        anchoredParts = {}

        if startupSoundEnabled then
            startupSound:Play()
        end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
                if obj.Anchored == false then
                    obj.Anchored = true
                    table.insert(anchoredParts, obj)
                end
            end
        end

        local duration = timeStopDuration
        local start = tick()
        fakeLagConn = game:GetService("RunService").RenderStepped:Connect(function()
            if not fakeLagActive then return end
            local remain = math.max(0, duration - (tick() - start))
            local intPart = math.floor(remain)
            local decPart = math.floor((remain - intPart) * 10)
            countdownLabel.Text = string.format("%d,%d", intPart, decPart)
            if remain <= 0 then
                timeStop(button)
            end
        end)
    else
        fakeLagActive = false
        for _, part in ipairs(anchoredParts) do
            if part and part.Parent then
                part.Anchored = false
            end
        end
        anchoredParts = {}
        if fakeLagConn then
            fakeLagConn:Disconnect()
            fakeLagConn = nil
        end
        countdownLabel.Text = ""
        if startupSoundEnabled then
            startupSound:Play()
        end
        button.Text = "✅"
        task.delay(0.5, function()
            if not fakeLagActive then
                button.Text = "⚡️"
            end
        end)
    end
end

timeBtn.MouseButton1Click:Connect(function()
    timeStop(timeBtn)
end)

--== Panel Settings ==--
local panel = Instance.new("Frame", ScreenGui)
panel.Size = UDim2.new(0, 265, 0, 280)
panel.Position = UDim2.new(0.25, 0, 0.4, 0)
panel.BackgroundColor3 = Color3.fromRGB(25,25,25)
panel.Visible = false
makeDraggable(panel)
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,10)

-- Checkbox Bật/Tắt Beep
local beepLabel = Instance.new("TextLabel", panel)
beepLabel.Text = "Bật tiếng beep:"
beepLabel.Size = UDim2.new(0,120,0,30)
beepLabel.Position = UDim2.new(0,10,0,10)
beepLabel.TextColor3 = Color3.new(1,1,1)
beepLabel.BackgroundTransparency = 1
beepLabel.TextXAlignment = Enum.TextXAlignment.Left

local beepCheckbox = Instance.new("TextButton", panel)
beepCheckbox.Size = UDim2.new(0,25,0,25)
beepCheckbox.Position = UDim2.new(0,150,0,10)
beepCheckbox.Text = startupSoundEnabled and "✔️" or ""
beepCheckbox.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", beepCheckbox).CornerRadius = UDim.new(0,5)

beepCheckbox.MouseButton1Click:Connect(function()
    startupSoundEnabled = not startupSoundEnabled
    beepCheckbox.Text = startupSoundEnabled and "✔️" or ""
    startupSound.SoundId = startupSoundEnabled and "rbxassetid://1283290053" or ""
end)

-- Input Tele Radius
local radiusLabel = Instance.new("TextLabel", panel)
radiusLabel.Text = "Khoảng cách tele:"
radiusLabel.Size = UDim2.new(0,80,0,30)
radiusLabel.Position = UDim2.new(0,10,0,40)
radiusLabel.TextColor3 = Color3.new(1,1,1)
radiusLabel.BackgroundTransparency = 1
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left

local radiusInput = Instance.new("TextBox", panel)
radiusInput.Size = UDim2.new(0,120,0,30)
radiusInput.Position = UDim2.new(0,100,0,40)
radiusInput.Text = tostring(teleportRadius)
radiusInput.ClearTextOnFocus = false
radiusInput.TextColor3 = Color3.new(1,1,1)
radiusInput.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", radiusInput).CornerRadius = UDim.new(0,8)
radiusInput.FocusLost:Connect(function()
    local num = tonumber(radiusInput.Text)
    if num then teleportRadius = num end
    radiusInput.Text = tostring(teleportRadius)
end)

-- Input Tele Delay
local delayLabel = Instance.new("TextLabel", panel)
delayLabel.Text = "Tele Delay (s):"
delayLabel.Size = UDim2.new(0,100,0,30)
delayLabel.Position = UDim2.new(0,10,0,80)
delayLabel.TextColor3 = Color3.new(1,1,1)
delayLabel.BackgroundTransparency = 1
delayLabel.TextXAlignment = Enum.TextXAlignment.Left

local delayInput = Instance.new("TextBox", panel)
delayInput.Size = UDim2.new(0,120,0,30)
delayInput.Position = UDim2.new(0,120,0,80)
delayInput.Text = tostring(teleportDelay)
delayInput.ClearTextOnFocus = false
delayInput.TextColor3 = Color3.new(1,1,1)
delayInput.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", delayInput).CornerRadius = UDim.new(0,8)
delayInput.FocusLost:Connect(function()
    local num = tonumber(delayInput.Text)
    if num then teleportDelay = num end
    delayInput.Text = tostring(teleportDelay)
end)

-- Input time Delay
local tsLabel = Instance.new("TextLabel", panel)
tsLabel.Text = "Time Stop: (s):"
tsLabel.Size = UDim2.new(0,100,0,30)
tsLabel.Position = UDim2.new(0,10,0,130)
tsLabel.TextColor3 = Color3.new(1,1,1)
tsLabel.BackgroundTransparency = 1
tsLabel.TextXAlignment = Enum.TextXAlignment.Left

local tsInput = Instance.new("TextBox", panel)
tsInput.Size = UDim2.new(0,120,0,30)
tsInput.Position = UDim2.new(0,120,0,130)
tsInput.Text = tostring(timeStopDuration)
tsInput.ClearTextOnFocus = false
tsInput.TextColor3 = Color3.new(1,1,1)
tsInput.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", tsInput).CornerRadius = UDim.new(0,8)
tsInput.FocusLost:Connect(function()
    local num = tonumber(tsInput.Text)
    if num then timeStopDuration = num end
    tsInput.Text = tostring(timeStopDuration)
end)

-- Nút mở Panel
local openBtn = Instance.new("TextButton", ScreenGui)
openBtn.Size = UDim2.new(0,60,0,60)
openBtn.Position = UDim2.new(0.05,0,0.7,0)
openBtn.Text = "⚙️"
openBtn.Font = Enum.Font.SourceSansBold
openBtn.TextSize = 24
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1,0)
makeDraggable(openBtn)
openBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)
-- Keybinds (mặc định nil)

-- GUI Panel Settings: thêm Input keybind
local teleKeyLabel = Instance.new("TextLabel", panel)
teleKeyLabel.Text = "Keybind Tele:"
teleKeyLabel.Size = UDim2.new(0,100,0,30)
teleKeyLabel.Position = UDim2.new(0,10,0,185)
teleKeyLabel.TextColor3 = Color3.new(1,1,1)
teleKeyLabel.BackgroundTransparency = 1
teleKeyLabel.TextXAlignment = Enum.TextXAlignment.Left

local teleKeyInput = Instance.new("TextBox", panel)
teleKeyInput.Size = UDim2.new(0,120,0,30)
teleKeyInput.Position = UDim2.new(0,120,0,185)
teleKeyInput.Text = teleKeybind and teleKeybind.Name or ""
teleKeyInput.ClearTextOnFocus = false
teleKeyInput.TextColor3 = Color3.new(1,1,1)
teleKeyInput.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", teleKeyInput).CornerRadius = UDim.new(0,8)
teleKeyInput.FocusLost:Connect(function()
    local keyName = teleKeyInput.Text
    if Enum.KeyCode[keyName] then
        teleKeybind = Enum.KeyCode[keyName]
    else
        teleKeybind = nil
        teleKeyInput.Text = ""
    end
end)

local fakeKeyLabel = Instance.new("TextLabel", panel)
fakeKeyLabel.Text = "Keybind FakeLag:"
fakeKeyLabel.Size = UDim2.new(0,120,0,30)
fakeKeyLabel.Position = UDim2.new(0,10,0,230)
fakeKeyLabel.TextColor3 = Color3.new(1,1,1)
fakeKeyLabel.BackgroundTransparency = 1
fakeKeyLabel.TextXAlignment = Enum.TextXAlignment.Left

local fakeKeyInput = Instance.new("TextBox", panel)
fakeKeyInput.Size = UDim2.new(0,120,0,30)
fakeKeyInput.Position = UDim2.new(0,140,0,220)
fakeKeyInput.Text = fakeLagKeybind and fakeLagKeybind.Name or ""
fakeKeyInput.ClearTextOnFocus = false
fakeKeyInput.TextColor3 = Color3.new(1,1,1)
fakeKeyInput.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", fakeKeyInput).CornerRadius = UDim.new(0,8)
fakeKeyInput.FocusLost:Connect(function()
    local keyName = fakeKeyInput.Text
    if Enum.KeyCode[keyName] then
        fakeLagKeybind = Enum.KeyCode[keyName]
    else
        fakeLagKeybind = nil
        fakeKeyInput.Text = ""
    end
end)

-- Lắng nghe phím
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == teleKeybind then
            teleportForward(teleBtn)
        elseif input.KeyCode == fakeLagKeybind then
            timeStop(timeBtn)
        end
    end
end)
    end
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local CurrentTarget = nil

local Connections = {
	CharacterAdded = {}
}

table.insert(Connections.CharacterAdded, LocalPlayer.CharacterAdded:Connect(function(Char)
	Character = Char
	Humanoid = Char:WaitForChild("Humanoid")
	HumanoidRootPart = Char:WaitForChild("HumanoidRootPart")
end))
local Esp = {}; do
    Instance.new("ScreenGui",game.CoreGui).Name = "Kaoru"
    local ChamsFolder = Instance.new("Folder")
    ChamsFolder.Name = "ChamsFolder"
    for _,v in next, game.CoreGui:GetChildren() do
        if v:IsA'ScreenGui' and v.Name == 'Kaoru' then
            ChamsFolder.Parent = v
        end
    end
    Players.PlayerRemoving:Connect(function(plr)
        if ChamsFolder:FindFirstChild(plr.Name) then
            ChamsFolder[plr.Name]:Destroy()
        end
    end)
    local Loops = {RenderStepped = {}, Heartbeat = {}, Stepped = {}}
    function Esp:BindToRenderStepped(id, callback)
        if not Loops.RenderStepped[id] then
            Loops.RenderStepped[id] = RunService.RenderStepped:Connect(callback)
        end
    end
    function Esp:UnbindFromRenderStepped(id)
        if Loops.RenderStepped[id] then
            Loops.RenderStepped[id]:Disconnect()
            Loops.RenderStepped[id] = nil
        end
    end
    function Esp:TeamCheck(Player, Toggle)
        if Toggle then
            return Player.Team ~= LocalPlayer.Team
        else
            return true
        end
    end
    function Esp:Update()
        for _, Player in next, Players:GetChildren() do
            if ChamsFolder:FindFirstChild(Player.Name) then
                Chams = ChamsFolder[Player.Name]
                Chams.Enabled = false
                Chams.FillColor = Color3.fromRGB(255, 255, 255)
                Chams.OutlineColor = Color3.fromHSV(tick()%5/5,1,1)
            end
            if Player ~= LocalPlayer and Player.Character then
                if ChamsFolder:FindFirstChild(Player.Name) == nil then
                    local chamfolder = Instance.new("Highlight")
                    chamfolder.Name = Player.Name
                    chamfolder.Parent = ChamsFolder
                    Chams = chamfolder
                end
                Chams.Enabled = true
                Chams.Adornee = Player.Character
                Chams.OutlineTransparency = 0
                Chams.DepthMode = Enum.HighlightDepthMode[(true and "AlwaysOnTop" or "Occluded")]
                Chams.FillTransparency = 1
            end
        end
    end
    function Esp:Toggle(boolean)
        if boolean then
            self:BindToRenderStepped("Esp", function()
                self:Update()
            end)
        else
            self:UnbindFromRenderStepped("Esp")
            ChamsFolder:ClearAllChildren()
        end
    end
end
-- Slider chỉnh size
PlayerTab:AddSlider("minDis", {
    Title = "Distance Telekill ( Min )",
    Min = 0,
    Max = 1000,
    Default = 10,
    Callback = function(Value)
        minDis = Value
    end
})
PlayerTab:AddSlider("maxDis", {
    Title = "Distance Telekill ( Max )",
    Min = 1,
    Max = 5000,
    Default = 200,
    Callback = function(Value)
        maxDis = Value
    end
})
-- Khoảng cách kéo player ra trước mặt
local pullDistance = 10
PlayerTab:AddSlider("PullDistance", {
    Title = "Khoảng cách kéo player",
    Min = 1,
    Max = 100,
    Rounding = 1,
    Default = 10,
    Callback = function(Value)
        pullDistance = Value
    end
})
-- Biến trạng thái
local alPlayer = false

-- Toggle trong MainTab
PlayerTab:AddToggle("alPlayer", {
    Title = "Telekill All",
    Callback = function(v)
        alPlayer = v
    end
})

-- Hàm kéo player
RunService.RenderStepped:Connect(function()
    if alPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myHRP = LocalPlayer.Character.HumanoidRootPart
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if isEnemy(plr) then
                    local hrp = plr.Character.HumanoidRootPart
                    local dist = (hrp.Position - myHRP.Position).Magnitude

                    if dist >= minDis and dist <= maxDis then
                        -- Kéo player về ngay trước mặt mình (cách 3 stud)
                        local frontPos = myHRP.CFrame * CFrame.new(0, 0, -pullDistance)
                        hrp.CFrame = frontPos
                    end
                end
            end
        end
    end
end)
SettingTab:AddToggle("TeamCheck", {
    Title = "Team Check",
    Default = true,
    Callback = function(v)
        teamCheck = v
    end
})

-- Hàm check team
local function isEnemy(plr)
    if not teamCheck then
        return true -- nếu tắt teamCheck thì luôn true
    end
    if LocalPlayer.Team and plr.Team then
        return LocalPlayer.Team ~= plr.Team
    end
    return true
end

ESPTab:AddToggle("esp", {
    Title = "Show Chams",
    Default = false,
    Callback = function(EspToggle)
        Esp:Toggle(EspToggle)
    end
})
ESPTab:AddToggle("tCheck", {
    Title = "Team Check Chams",
    Default = false,
    Callback = function(ESPTeamCheck)
        shared.ESPTeamCheck = ESPTeamCheck
    end
})

-- === AimTab: AL Player & AL NPC & AntiHit ===
local selectedAlPlayer = nil
local alPlayerEnabled = false

-- Dropdown chọn Player
local alPlayerDropdown = PlayerTab:AddDropdown("AlPlayerDropdown", {
    Title = "Chọn Player để kéo",
    Values = {}, -- sẽ được cập nhật
    Callback = function(Value)
        selectedAlPlayer = Players:FindFirstChild(Value)
    end
})

-- Hàm làm mới danh sách player
local function refreshAlPlayerList()
    local playerNames = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playerNames, p.Name)
        end
    end
    alPlayerDropdown:SetValues(playerNames)
end

-- Nút Refresh
PlayerTab:AddButton({
    Title = "Refresh Player List",
    Callback = function()
        refreshAlPlayerList()
    end
})

refreshAlPlayerList()

PlayerTab:AddToggle("AlPlayerToggle", {
    Title = "Telekill V2 (1Player)",
    Description = "vip",
    Callback = function(Value)
        alPlayerEnabled = Value
        task.spawn(function()
            while alPlayerEnabled do
                if selectedAlPlayer and selectedAlPlayer.Character and LocalPlayer.Character then
                    local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local targetHRP = selectedAlPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP and targetHRP then
                        local frontPos = myHRP.CFrame.Position + (Camera.CFrame.LookVector * 3)
                        targetHRP.CFrame = CFrame.new(frontPos)
                    end
                end
                task.wait(0.3)
            end
        end)
    end
})



-- === Show/Hide FPS + Ping (ổn định, chính xác) ===
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

-- GUI
local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "FPSPingGui"
fpsGui.Parent = game.CoreGui
fpsGui.ResetOnSpawn = false

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 160, 0, 25) -- thu chiều rộng lại
fpsLabel.Position = UDim2.new(0, 10, 0, 350) -- mặc định Y=350
fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- nền đen
fpsLabel.BorderSizePixel = 0
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.TextStrokeTransparency = 0.5
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.TextSize = 16
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Parent = fpsGui
fpsLabel.Visible = false

-- Biến FPS/Ping
local frames, elapsed, fps = 0, 0, 0

RunService.RenderStepped:Connect(function(dt)
    frames += 1
    elapsed += dt
end)

-- Rainbow toggle
local rainbowEnabled = false

task.spawn(function()
    local t = 0
    while task.wait(0.05) do
        if rainbowEnabled and fpsLabel.Visible then
            t = t + 0.01
            fpsLabel.TextColor3 = Color3.fromHSV(t % 1, 1, 1)
        end
    end
end)

-- Update text
task.spawn(function()
    while task.wait(1) do
        if fpsLabel.Visible then
            if elapsed > 0 then
                fps = math.floor(frames / elapsed)
            end
            frames, elapsed = 0, 0
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            fpsLabel.Text = string.format("FPS: %d | Ping: %d ms", fps, ping)
        end
    end
end)

-- Position sliders
local posX, posY = 10, 350
MainTab:AddSlider("FPSPosX", {
    Title = "FPS GUI X",
    Min = 0, Max = 1000, Default = posX,
    Callback = function(Value)
        posX = Value
        fpsLabel.Position = UDim2.new(0, posX, 0, posY)
    end
})

MainTab:AddSlider("FPSPosY", {
    Title = "FPS GUI Y",
    Min = 0, Max = 600, Default = posY,
    Callback = function(Value)
        posY = Value
        fpsLabel.Position = UDim2.new(0, posX, 0, posY)
    end
})

-- Toggle show/hide
MainTab:AddToggle("ShowFPSPing", {
    Title = "Show FPS & Ping",
    Callback = function(Value)
        fpsLabel.Visible = Value
    end
})

-- Toggle Rainbow text
MainTab:AddToggle("RainbowText", {
    Title = "Rainbow FPS Text",
    Callback = function(Value)
        rainbowEnabled = Value
    end
})
-- Dropdown đổi Theme
SettingTab:AddDropdown("ThemeDropdown", {
    Title = "Chọn Theme",
    Values = {"Amethyst", "Aqua", "Rose", "Light", "Dark", "Darker"},
    Multi = false,
    Default = "Dark",
    Callback = function(Value)
        Library:SetTheme(Value)
    end
})
-- Up Player (cố định trên trời)
local upPlayerEnabled = false
local upPlayerHeight = 200 -- mặc định 200 studs trên trời

PlayerTab:AddSlider("UpPlayerSlider", {
    Title = "Distance Up",
    Min = 50,
    Max = 1000,
    Default = 200,
    Callback = function(Value)
        upPlayerHeight = Value
    end
})

PlayerTab:AddToggle("UpPlayerToggle", {
    Title = "Up Player",
    Description = "Đưa tất cả player lên độ cao cố định trên trời",
    Callback = function(Value)
        upPlayerEnabled = Value
        task.spawn(function()
            while upPlayerEnabled do
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart
                        local pos = hrp.Position
                        -- set Y về giá trị cố định (upPlayerHeight)
                        hrp.CFrame = CFrame.new(pos.X, upPlayerHeight, pos.Z)
                    end
                end
                task.wait(0.5) -- update mỗi 0.5s để giữ cố định
            end
        end)
    end
})

-- WalkSpeed & JumpPower Settings
local wsEnabled = false
local jpEnabled = false
local wsValue = 16
local jpValue = 50

SettingTab:AddSlider("WalkSpeedSlider", {
    Title = "Speed Hack",
    Min = 16,
    Max = 500,
    Default = 16,
    Callback = function(Value)
        wsValue = Value
        if wsEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = wsValue
        end
    end
})

SettingTab:AddToggle("WalkSpeedToggle", {
    Title = "Inject Speed Hack",
    Description = "Bật để thay đổi tốc độ chạy",
    Callback = function(Value)
        wsEnabled = Value
        task.spawn(function()
            while wsEnabled do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = wsValue
                end
                task.wait(0.2)
            end
        end)
    end
})

SettingTab:AddSlider("JumpPowerSlider", {
    Title = "JumpPower",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(Value)
        jpValue = Value
        if jpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = jpValue
        end
    end
})

SettingTab:AddToggle("JumpPowerToggle", {
    Title = "Inject JumpPower",
    Description = "Bật để thay đổi sức nhảy",
    Callback = function(Value)
        jpEnabled = Value
        task.spawn(function()
            while jpEnabled do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.JumpPower = jpValue
                end
                task.wait(0.2)
            end
        end)
    end
})


--== ESP Player (Blissful#4992) ==--
local espEnabled = false
ESPTab:AddToggle("ESSP", {
    Title = "Show ESP",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then
            task.spawn(function()
                -- Made by Blissful#4992 | Modified by GPT
                local Settings = {
                    Box_Color = Color3.fromRGB(255, 0, 0),
                    Tracer_Color = Color3.fromRGB(255, 0, 0),
                    Tracer_Thickness = 1,
                    Box_Thickness = 1,
                    Tracer_Origin = "Top", -- sửa thành Top (đỉnh giữa màn hình)
                    Tracer_FollowMouse = false,
                    Tracers = true
                }

                local Team_Check = {
                    TeamCheck = false,
                    Green = Color3.fromRGB(0, 255, 0),
                    Red = Color3.fromRGB(255, 0, 0)
                }
                local TeamColor = true

                local player = game:GetService("Players").LocalPlayer
                local camera = game:GetService("Workspace").CurrentCamera
                local mouse = player:GetMouse()
                local Players = game:GetService("Players")


                local function NewLine(thickness, color)
                    local line = Drawing.new("Line")
                    line.Visible = false
                    line.Thickness = thickness
                    line.Color = color
                    return line
                end

                local function NewQuad(thickness, color)
                    local quad = Drawing.new("Quad")
                    quad.Visible = false
                    quad.Thickness = thickness
                    quad.Color = color
                    return quad
                end

                local function Visibility(state, lib)
                    for _, x in pairs(lib) do
                        x.Visible = state
                    end
                end

                --== ESP setup ==--
                local black = Color3.fromRGB(0,0,0)
                local function ESP(plr)
                    local library = {
                        blacktracer = NewLine(Settings.Tracer_Thickness*2, black),
                        tracer = NewLine(Settings.Tracer_Thickness, Settings.Tracer_Color),
                        black = NewQuad(Settings.Box_Thickness*2, black),
                        box = NewQuad(Settings.Box_Thickness, Settings.Box_Color),
                        healthbar = NewLine(3, black),
                        greenhealth = NewLine(1.5, black),
                    }

                    -- thêm corner box (8 line)
                    local corners = {}
                    for i = 1, 8 do
                        local c = NewLine(1.5, Settings.Box_Color)
                        corners[i] = c
                    end

                    -- thêm text [dist] Name
                    local infoText = Drawing.new("Text")
                    infoText.Size = 14
                    infoText.Center = true
                    infoText.Outline = true
                    infoText.Visible = false

                    local function Colorize(color)
                        for _, x in pairs(library) do
                            if x ~= library.healthbar and x ~= library.greenhealth and x ~= library.blacktracer and x ~= library.black then
                                x.Color = color
                            end
                        end
                        for _, c in pairs(corners) do c.Color = color end
                        infoText.Color = color
                    end

                    local function Updater()
                        local connection
                        connection = game:GetService("RunService").RenderStepped:Connect(function()
                            if not espEnabled then
                                Visibility(false, library)
                                for _, c in pairs(corners) do c.Visible = false end
                                infoText.Visible = false
                                connection:Disconnect()
                                return
                            end

                            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") then
                                local hrp = plr.Character.HumanoidRootPart
                                local head = plr.Character.Head
                                local HumPos, OnScreen = camera:WorldToViewportPoint(hrp.Position)
                                if OnScreen then
                                    local headPos = camera:WorldToViewportPoint(head.Position)
                                    local DistanceY = math.clamp((Vector2.new(headPos.X, headPos.Y) - Vector2.new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)

                                    -- vẽ box chính
                                    local function Size(item)
                                        item.PointA = Vector2.new(HumPos.X + DistanceY, HumPos.Y - DistanceY*2)
                                        item.PointB = Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2)
                                        item.PointC = Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2)
                                        item.PointD = Vector2.new(HumPos.X + DistanceY, HumPos.Y + DistanceY*2)
                                    end
                                    Size(library.box)
                                    Size(library.black)

                                    -- tracer line: đỉnh giữa màn hình
                                    if Settings.Tracers then
                                        local topCenter = Vector2.new(camera.ViewportSize.X*0.5, 0)
                                        library.tracer.From = topCenter
                                        library.blacktracer.From = topCenter
                                        library.tracer.To = Vector2.new(HumPos.X, HumPos.Y - DistanceY*2)
                                        library.blacktracer.To = Vector2.new(HumPos.X, HumPos.Y - DistanceY*2)
                                    end
                                    local d = (Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2) - Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2)).magnitude 
                                    local healthoffset = plr.Character.Humanoid.Health/plr.Character.Humanoid.MaxHealth * d

                                    library.greenhealth.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
                                    library.greenhealth.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2 - healthoffset)

                                    library.healthbar.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
                                    library.healthbar.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y - DistanceY*2)

                                    local green = Color3.fromRGB(0, 255, 0)
                                    local red = Color3.fromRGB(255, 0, 0)
                                    library.greenhealth.Color = red:lerp(green, plr.Character.Humanoid.Health/plr.Character.Humanoid.MaxHealth);


                                    -- corner box
                                    local width = DistanceY * 2
                                    local height = DistanceY * 4
                                    local leftX = HumPos.X - width/2
                                    local rightX = HumPos.X + width/2
                                    local topY = HumPos.Y - height/2
                                    local bottomY = HumPos.Y + height/2
                                    local cLen = width * 0.25

                                    local C = corners
                                    -- TL
                                    C[1].From = Vector2.new(leftX, topY)
                                    C[1].To = Vector2.new(leftX + cLen, topY)
                                    C[2].From = Vector2.new(leftX, topY)
                                    C[2].To = Vector2.new(leftX, topY + cLen)
                                    -- TR
                                    C[3].From = Vector2.new(rightX - cLen, topY)
                                    C[3].To = Vector2.new(rightX, topY)
                                    C[4].From = Vector2.new(rightX, topY)
                                    C[4].To = Vector2.new(rightX, topY + cLen)
                                    -- BL
                                    C[5].From = Vector2.new(leftX, bottomY)
                                    C[5].To = Vector2.new(leftX + cLen, bottomY)
                                    C[6].From = Vector2.new(leftX, bottomY - cLen)
                                    C[6].To = Vector2.new(leftX, bottomY)
                                    -- BR
                                    C[7].From = Vector2.new(rightX - cLen, bottomY)
                                    C[7].To = Vector2.new(rightX, bottomY)
                                    C[8].From = Vector2.new(rightX, bottomY - cLen)
                                    C[8].To = Vector2.new(rightX, bottomY)

                                    for i = 1, 8 do C[i].Visible = true end

                                    -- Info [dist] Name
                                    local dist = math.floor((camera.CFrame.Position - hrp.Position).Magnitude)
                                    infoText.Text = string.format("[%.0fm] %s", dist, plr.Name)
                                    infoText.Position = Vector2.new(HumPos.X, topY - 16)
                                    infoText.Visible = true

                                    -- Color theo team
                                    if Team_Check.TeamCheck then
                                        if plr.Team == player.Team then
                                            Colorize(Team_Check.Green)
                                        else
                                            Colorize(Team_Check.Red)
                                        end
                                    elseif TeamColor then
                                        Colorize(plr.TeamColor.Color)
                                    else
                                        Colorize(Settings.Box_Color)
                                    end

                                    Visibility(true, library)
                                else
                                    Visibility(false, library)
                                    for _, c in pairs(corners) do c.Visible = false end
                                    infoText.Visible = false
                                end
                            else
                                Visibility(false, library)
                                for _, c in pairs(corners) do c.Visible = false end
                                infoText.Visible = false
                                if not Players:FindFirstChild(plr.Name) then
                                    connection:Disconnect()
                                end
                            end
                        end)
                    end
                    coroutine.wrap(Updater)()
                end

                -- chạy ESP cho tất cả player hiện có
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= player then
                        coroutine.wrap(ESP)(v)
                    end
                end
                updateCount()

                -- auto update player join/respawn
                Players.PlayerAdded:Connect(function(p)
                    if p ~= player then
                        coroutine.wrap(ESP)(p)
                        p.CharacterAdded:Connect(function()
                            task.wait(0.5)
                            coroutine.wrap(ESP)(p)
                            updateCount()
                        end)
                    end
                end)
                Players.PlayerRemoving:Connect(function()
                    updateCount()
                end)
            end)
        else
            -- Tắt ESP
            for _, obj in pairs(getgc(true)) do
                if typeof(obj) == "userdata" and obj.Visible ~= nil then
                    pcall(function() obj.Visible = false end)
                end
            end
        end
    end
})
local teleportVIPEnabled = false
local teleportDistance = 3
local teleVipThreadId = 0

local function getNearestEnemy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local root = char.HumanoidRootPart

    local nearest, dist = nil, math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer
        and isEnemy(plr)
        and plr.Character
        and plr.Character:FindFirstChild("HumanoidRootPart")
        and plr.Character:FindFirstChild("Humanoid")
        and plr.Character.Humanoid.Health > 0 then
            local d = (plr.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if d < dist then
                dist = d
                nearest = plr
            end
        end
    end
    return nearest
end

PlayerTab:AddToggle("TeleportVIP", {
    Title = "Teleport VIP",
    Description = "Auto teleport enemy gần nhất (Team Check FIX)",
    Callback = function(v)
        teleportVIPEnabled = v
        teleVipThreadId += 1
        local id = teleVipThreadId

        if v then
            task.spawn(function()
                while teleportVIPEnabled and id == teleVipThreadId do
                    local target = getNearestEnemy()
                    if target and target.Character then
                        LocalPlayer.Character.HumanoidRootPart.CFrame =
                            target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-teleportDistance)
                    end
                    task.wait(0.35)
                end
            end)
        end
    end
})
PlayerTab:AddSlider("TeleportDistance", {
    Title = "Teleport Distance",
    Min = 1,
    Max = 999,
    Default = 3,
    Callback = function(v)
        teleportDistance = v
    end
})
local teleportTarget = nil
local teleportSelectedEnabled = false
local teleSelectedThreadId = 0

PlayerTab:AddToggle("TeleportSelected", {
    Title = "Teleport Selected Player",
    Description = "Teleport player đã chọn (Stop khi OFF)",
    Callback = function(v)
        teleportSelectedEnabled = v
        teleSelectedThreadId += 1
        local id = teleSelectedThreadId

        if v then
            task.spawn(function()
                while teleportSelectedEnabled and id == teleSelectedThreadId do
                    if teleportTarget
                    and teleportTarget.Character
                    and teleportTarget.Character:FindFirstChild("HumanoidRootPart")
                    and isEnemy(teleportTarget) then
                        LocalPlayer.Character.HumanoidRootPart.CFrame =
                            teleportTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-teleportDistance)
                    end
                    task.wait(0.35)
                end
            end)
        end
    end
})
local teleDropdown = PlayerTab:AddDropdown("TelePlayer", {
    Title = "Teleport Player",
    Values = {},
    Callback = function(v)
        teleportTarget = Players:FindFirstChild(v)
    end
})
PlayerTab:AddButton({
    Title = "Refresh Player",
    Callback = function()
        local list = {}
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(list, plr.Name)
            end
        end
        teleDropdown:SetValues(list)
    end
})
local teleSelectedThreadId = 0
local TweenService = game:GetService("TweenService")

local teleportVIPEnabled = false
local teleVipId = 0

-- offset vị trí so với địch
local offsetX = 0
local offsetY = 0
local offsetZ = -3

-- tốc độ tween
local tweenTime = 0.25

PlayerTab:AddSlider("TeleOffsetZ", {
    Title = "Teleport Offset (Front / Back)",
    Min = -50,
    Max = 50,
    Default = -3,
    Callback = function(v)
        offsetZ = v
    end
})
PlayerTab:AddSlider("TeleOffsetX", {
    Title = "Teleport Offset (Left / Right)",
    Min = -50,
    Max = 50,
    Default = 0,
    Callback = function(v)
        offsetX = v
    end
})
PlayerTab:AddSlider("TweenSpeed", {
    Title = "Tween Speed",
    Description = "Nhỏ = nhanh, lớn = chậm",
    Min = 0.05,
    Max = 1,
    Default = 0.25,
    Rounding = 2,
    Callback = function(v)
        tweenTime = v
    end
})
PlayerTab:AddSlider("TeleOffsetY", {
    Title = "Teleport Offset (Up / Down)",
    Min = -5,
    Max = 5,
    Default = 0,
    Callback = function(v)
        offsetY = v
    end
})
PlayerTab:AddToggle("TeleportVIP", {
    Title = "Teleport VIP (Tween To Enemy)",
    Description = "Tween bản thân lại gần enemy",
    Callback = function(v)
        teleportVIPEnabled = v
        teleVipId += 1
        local id = teleVipId

        if v then
            task.spawn(function()
                while teleportVIPEnabled and id == teleVipId do
                    local target = getNearestEnemy()
                    local char = LocalPlayer.Character

                    if target and target.Character and char then
                        local myRoot = char:FindFirstChild("HumanoidRootPart")
                        local enemyRoot = target.Character:FindFirstChild("HumanoidRootPart")
                        local hum = char:FindFirstChildOfClass("Humanoid")

                        if myRoot and enemyRoot and hum and hum.Health > 0 then
                            local goalCF =
                                enemyRoot.CFrame *
                                CFrame.new(offsetX, offsetY, offsetZ)

                            TweenService:Create(
                                myRoot,
                                TweenInfo.new(tweenTime, Enum.EasingStyle.Linear),
                                {CFrame = goalCF}
                            ):Play()
                        end
                    end
                    task.wait(0.3)
                end
            end)
        end
    end
})


--== Auto AFK với đếm ngược 540 giây ==--
local afkEnabled = false
local afkGui = nil
local afkConnection = nil
local vu = game:GetService("VirtualUser")
local cam = workspace.CurrentCamera
local plr = game:GetService("Players").LocalPlayer

CDVNTab:AddToggle("AFK", {
    Title = "Auto AFK",
    Description = "Tránh kick + đếm ngược 540s",
    Default = false,
    Callback = function(Value)
        afkEnabled = Value
        if afkEnabled then
            -- Tạo GUI nhỏ hiển thị thời gian
            afkGui = Instance.new("ScreenGui")
            afkGui.Name = "AFK_TimerUI"
            afkGui.Parent = plr:WaitForChild("PlayerGui")

            local afkLabel = Instance.new("TextLabel", afkGui)
            afkLabel.Size = UDim2.new(0, 200, 0, 40)
            afkLabel.Position = UDim2.new(0, 20, 0, 200)
            afkLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            afkLabel.TextColor3 = Color3.fromRGB(60, 255, 100)
            afkLabel.Font = Enum.Font.GothamBold
            afkLabel.TextScaled = true
            afkLabel.Text = "🕒 AFK: 285"

            Instance.new("UICorner", afkLabel).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", afkLabel).Color = Color3.fromRGB(60, 200, 100)

            -- Task đếm ngược
            afkConnection = task.spawn(function()
                while afkEnabled do
                    for i = 285, 0, -1 do
                        if not afkEnabled then break end
                        afkLabel.Text = "🕒 AFK: "..i.."s"
                        task.wait(1)
                    end
                    -- Khi hết 540s thì thực hiện một hành động để tránh kick
                    if afkEnabled then
                        vu:Button2Down(Vector2.new(), cam.CFrame)
                        task.wait(0.5)
                        vu:Button2Up(Vector2.new(), cam.CFrame)
                    end
                end
            end)
        else
            -- Tắt -> xoá GUI + dừng đếm
            if afkConnection then
                task.cancel(afkConnection)
                afkConnection = nil
            end
            if afkGui then afkGui:Destroy() afkGui=nil end
        end
    end
})

--// Prime Vip – Smooth Orbit AutoFarm (CityNPC Only)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = Character:WaitForChild("HumanoidRootPart")

--== Settings ==--
local orbitRadius = 5
local orbitSpeed = 2
local yOffset = 1
local retargetInterval = 1
local attackInterval = 0.3
local noclipEnabled = false
local autoFarmEnabled = false

--== Functions ==--
local function isAliveModel(model)
    return model and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") and model.Humanoid.Health > 0
end

local function getNearestBoss(pos)
    local nearest, dist = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "CityNPC" and isAliveModel(obj) then
            local root = obj:FindFirstChild("HumanoidRootPart")
            if root then
                local d = (root.Position - pos).Magnitude
                if d < dist then
                    dist = d
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

local moveTween = nil
local function moveSmoothlyTo(targetPos)
    if moveTween then moveTween:Cancel() end
    if not Character or not hrp then return end

    local distance = (hrp.Position - targetPos).Magnitude

    local time = math.clamp(distance / 2, 0.5, 3)


    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(targetPos)}
    )
    moveTween = tween
    tween:Play()
end

--== AutoFarm Loop ==--
local currentBoss, angle = nil, 0
local lastAttack, lastRetarget = 0, 0

RunService.Heartbeat:Connect(function(dt)
    if not autoFarmEnabled then return end
    Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    hrp = Character.HumanoidRootPart

    -- Noclip
    if noclipEnabled then
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Retarget
    lastRetarget += dt
    if (not currentBoss) or (not isAliveModel(currentBoss)) or lastRetarget >= retargetInterval then
        lastRetarget = 0
        local nearest = getNearestBoss(hrp.Position)
        if nearest ~= currentBoss and isAliveModel(nearest) then
            currentBoss = nearest
            local bossHRP = currentBoss:FindFirstChild("HumanoidRootPart")
            if bossHRP then
                moveSmoothlyTo(bossHRP.Position)
            end
        end
    end

    -- Orbit + Attack
    if currentBoss and isAliveModel(currentBoss) then
        local bossHRP = currentBoss:FindFirstChild("HumanoidRootPart")
        if bossHRP then
            angle += orbitSpeed * dt
            local orbitOffset = Vector3.new(math.cos(angle) * orbitRadius, yOffset, math.sin(angle) * orbitRadius)
            local targetPos = bossHRP.Position + orbitOffset

            Character:MoveTo(targetPos)

            local lookAt = Vector3.new(bossHRP.Position.X, hrp.Position.Y, bossHRP.Position.Z)
            hrp.CFrame = CFrame.lookAt(hrp.Position, lookAt)

            lastAttack += dt
            if lastAttack >= attackInterval then
                lastAttack = 0
                VirtualUser:ClickButton1(Vector2.new())
            end
        end
    end
end)

--== Fluent UI Toggles + Input ==--
CDVNTab:AddToggle("OrbitFarm", {
    Title = "TeleCityNPC",
    Description = "Bật xong tắt thật nhanh",
    Default = false,
    Callback = function(Value)
        autoFarmEnabled = Value
    end
})

-- Freeze NPC (đứng im, không thể gây damage)
local freezeNpcEnabled = false
local npcConn
local npcAnchored = {}

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local humPlayer = chr:WaitForChild("Humanoid")

-- Chặn NPC gây damage bằng cách reset Health về MaxHealth
local humConn
local function blockDamage(state)
    if state then
        humConn = humPlayer.HealthChanged:Connect(function()
            if freezeNpcEnabled and humPlayer.Health < humPlayer.MaxHealth then
                humPlayer.Health = humPlayer.MaxHealth
            end
        end)
    else
        if humConn then humConn:Disconnect() humConn = nil end
    end
end

-- Hàm đóng băng NPC
local function freezeNPC(npc)
    if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
        if not Players:GetPlayerFromCharacter(npc) then
            local hrp = npc.HumanoidRootPart
            local hum = npc.Humanoid

            -- Lưu trạng thái cũ
            if not npcAnchored[hrp] then
                npcAnchored[hrp] = {
                    Anchored = hrp.Anchored,
                    WalkSpeed = hum.WalkSpeed,
                    JumpPower = hum.JumpPower,
                    PlatformStand = hum.PlatformStand
                }
            end

            -- Đóng băng
            hrp.Anchored = true
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum.PlatformStand = true
            hum:ChangeState(Enum.HumanoidStateType.Physics)

            -- Stop animations
            for _, anim in ipairs(npc:GetDescendants()) do
                if anim:IsA("Animator") then
                    anim:Destroy()
                elseif anim:IsA("AnimationTrack") then
                    anim:Stop()
                end
            end
        end
    end
end

CDVNTab:AddToggle("FreezeNPC", {
    Title = "Freeze CityNPC",
    Description = "Làm tất cả NPC đứng im, không thể gây damage",
    Callback = function(Value)
        freezeNpcEnabled = Value
        if freezeNpcEnabled then
            -- Bật chặn damage
            blockDamage(true)

            -- Đóng băng NPC hiện có
            for _, npc in ipairs(workspace:GetDescendants()) do
                freezeNPC(npc)
            end

            -- Auto đóng băng NPC mới spawn
            npcConn = workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("Humanoid") and obj.Parent:FindFirstChild("HumanoidRootPart") then
                    local npc = obj.Parent
                    if not Players:GetPlayerFromCharacter(npc) and freezeNpcEnabled then
                        freezeNPC(npc)
                    end
                end
            end)
        else
            -- Tắt chặn damage
            blockDamage(false)

            -- Reset về trạng thái cũ
            for hrp, data in pairs(npcAnchored) do
                if hrp and hrp.Parent and data then
                    local hum = hrp.Parent:FindFirstChild("Humanoid")
                    if hum then
                        hum.WalkSpeed = data.WalkSpeed
                        hum.JumpPower = data.JumpPower
                        hum.PlatformStand = data.PlatformStand
                    end
                    hrp.Anchored = data.Anchored
                end
            end
            npcAnchored = {}
            if npcConn then npcConn:Disconnect() npcConn=nil end
        end
    end
})

CDVNTab:AddInput("OrbitSpeed", {
    Title = "Tốc độ quay",
    Default = tostring(orbitSpeed),
    Placeholder = "Nhập số",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local v = tonumber(Value)
        if v then orbitSpeed = v end
    end
})

CDVNTab:AddInput("OrbitRadius", {
    Title = "Khoảng cách",
    Default = tostring(orbitRadius),
    Placeholder = "Nhập số",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local v = tonumber(Value)
        if v then orbitRadius = v end
    end
})

CDVNTab:AddInput("OrbitYOffset", {
    Title = "Độ cao",
    Default = tostring(yOffset),
    Placeholder = "Nhập số",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local v = tonumber(Value)
        if v then yOffset = v end
    end
})

-- ESP ALL NPC
local ESP_NPC = {}
local espNpcConn = nil

local function createESPNpc(npc)
    if ESP_NPC[npc] then return end
    local Box = Drawing.new("Square")
    Box.Color = Color3.fromRGB(255,255,0) -- vàng
    Box.Thickness = 1
    Box.Filled = false
    Box.Visible = false

    local Line = Drawing.new("Line")
    Line.Color = Color3.fromRGB(255,255,0)
    Line.Thickness = 1.5
    Line.Visible = false

    local DistText = Drawing.new("Text")
    DistText.Size = 12
    DistText.Center = true
    DistText.Outline = true
    DistText.Color = Color3.fromRGB(255,255,0)
    DistText.Visible = false

    ESP_NPC[npc] = {Box=Box,Line=Line,Dist=DistText}
end

local function removeESPNpc(npc)
    if ESP_NPC[npc] then
        ESP_NPC[npc].Box:Remove()
        ESP_NPC[npc].Line:Remove()
        ESP_NPC[npc].Dist:Remove()
        ESP_NPC[npc] = nil
    end
end

MainTab:AddToggle("ESPNPC", {
    Title = "ESP ALL NPC",
    Description = "Hiện Box + Distance + Line cho toàn bộ NPC",
    Callback = function(Value)
        if Value then
            -- Tạo ESP cho NPC đang tồn tại
            for _, npc in ipairs(workspace:GetDescendants()) do
                if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                    if not game.Players:GetPlayerFromCharacter(npc) then
                        createESPNpc(npc)
                    end
                end
            end

            -- Render liên tục cho tất cả NPC
            espNpcConn = game:GetService("RunService").RenderStepped:Connect(function()
                for npc, esp in pairs(ESP_NPC) do
                    if npc and npc:FindFirstChild("HumanoidRootPart") then
                        local hrp = npc.HumanoidRootPart
                        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local top, _ = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
                            local bottom, _ = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,2,0))
                            local height = math.abs(top.Y-bottom.Y)
                            local width = height*0.6
                            esp.Box.Size = Vector2.new(width,height)
                            esp.Box.Position = Vector2.new(top.X-width/2, top.Y)
                            esp.Box.Visible = true

                            -- Line từ giữa màn hình
                            esp.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                            esp.Line.To = Vector2.new(pos.X,pos.Y)
                            esp.Line.Visible = true

                            -- Distance text
                            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                            esp.Dist.Text = string.format("%.0fm", dist)
                            esp.Dist.Position = Vector2.new(top.X, top.Y-15)
                            esp.Dist.Visible = true
                        else
                            esp.Box.Visible = false
                            esp.Line.Visible = false
                            esp.Dist.Visible = false
                        end
                    else
                        removeESPNpc(npc)
                    end
                end
            end)

            -- Auto add NPC mới spawn
            workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("Humanoid") and obj.Parent:FindFirstChild("HumanoidRootPart") then
                    local npc = obj.Parent
                    if not game.Players:GetPlayerFromCharacter(npc) then
                        createESPNpc(npc)
                    end
                end
            end)
        else
            if espNpcConn then espNpcConn:Disconnect() espNpcConn=nil end
            for npc,_ in pairs(ESP_NPC) do removeESPNpc(npc) end
        end
    end
})

--== ESP CityNPC ==--
local ESP_CityNPC = {}
local espNpcConn, npcAddedConn, npcRemovedConn

-- Kiểm tra NPC còn sống
local function isAliveModel(model)
    local hum = model:FindFirstChild("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    return hum and hrp and hum.Health > 0
end

-- Tạo ESP cho CityNPC
local function createESPCityNpc(npc)
    if ESP_CityNPC[npc] then return end
    if not isAliveModel(npc) then return end

    local Box = Drawing.new("Square")
    Box.Color = Color3.fromRGB(255,255,0)
    Box.Thickness = 1
    Box.Filled = false
    Box.Visible = false

    local Line = Drawing.new("Line")
    Line.Color = Color3.fromRGB(255,255,0)
    Line.Thickness = 1.5
    Line.Visible = false

    local DistText = Drawing.new("Text")
    DistText.Size = 12
    DistText.Center = true
    DistText.Outline = true
    DistText.Color = Color3.fromRGB(255,255,0)
    DistText.Visible = false

    ESP_CityNPC[npc] = {Box=Box,Line=Line,Dist=DistText}
end

-- Xoá ESP khi NPC biến mất
local function removeESPCityNpc(npc)
    if ESP_CityNPC[npc] then
        ESP_CityNPC[npc].Box:Remove()
        ESP_CityNPC[npc].Line:Remove()
        ESP_CityNPC[npc].Dist:Remove()
        ESP_CityNPC[npc] = nil
    end
end

-- Toggle ESP CityNPC
CDVNTab:AddToggle("ESPCityNPC", {
    Title = "ESP CityNPC",
    Description = "Box + Line + Distance cho CityNPC",
    Callback = function(Value)
        if Value then
            -- Quét CityNPC đang có
            for _, npc in ipairs(workspace:GetDescendants()) do
                if npc:IsA("Model") and npc.Name == "CityNPC" and isAliveModel(npc) then
                    createESPCityNpc(npc)
                end
            end

            -- Render
            espNpcConn = game:GetService("RunService").RenderStepped:Connect(function()
                for npc, esp in pairs(ESP_CityNPC) do
                    if isAliveModel(npc) then
                        local hrp = npc.HumanoidRootPart
                        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            -- Box
                            local top,_ = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
                            local bottom,_ = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,2,0))
                            local height = math.abs(top.Y-bottom.Y)
                            local width = height*0.6
                            esp.Box.Size = Vector2.new(width,height)
                            esp.Box.Position = Vector2.new(top.X-width/2, top.Y)
                            esp.Box.Visible = true

                            -- Line
                            esp.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                            esp.Line.To = Vector2.new(pos.X,pos.Y)
                            esp.Line.Visible = true

                            -- Distance
                            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                            esp.Dist.Text = string.format("%.0fm", dist)
                            esp.Dist.Position = Vector2.new(top.X, top.Y-15)
                            esp.Dist.Visible = true
                        else
                            esp.Box.Visible = false
                            esp.Line.Visible = false
                            esp.Dist.Visible = false
                        end
                    else
                        removeESPCityNpc(npc)
                    end
                end
            end)

            -- Auto thêm CityNPC spawn mới
            npcAddedConn = workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("Model") and obj.Name == "CityNPC" and isAliveModel(obj) then
                    createESPCityNpc(obj)
                end
            end)

            -- Xoá khi NPC bị remove
            npcRemovedConn = workspace.DescendantRemoving:Connect(function(obj)
                if obj:IsA("Model") and ESP_CityNPC[obj] then
                    removeESPCityNpc(obj)
                end
            end)

        else
            if espNpcConn then espNpcConn:Disconnect() espNpcConn=nil end
            if npcAddedConn then npcAddedConn:Disconnect() npcAddedConn=nil end
            if npcRemovedConn then npcRemovedConn:Disconnect() npcRemovedConn=nil end
            for npc,_ in pairs(ESP_CityNPC) do removeESPCityNpc(npc) end
        end
    end
})
-- Auto Space Jump
local autoSpace = false
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")

-- Toggle trong Fluent UI
CDVNTab:AddToggle("AutoSpace", {
    Title = "Auto Space",
    Description = "Tự động nhấn phím Space (nhảy liên tục)",
    Default = false,
    Callback = function(Value)
        autoSpace = Value
        if autoSpace then
            task.spawn(function()
                while autoSpace do
                    if hum and hum.Parent then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                    task.wait(0.6) -- delay giữa mỗi lần nhảy
                end
            end)
        end
    end
})