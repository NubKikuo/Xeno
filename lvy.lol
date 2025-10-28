--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local oob
local auto
local RunService = game:GetService("RunService")
local Player = game:GetService("Players").LocalPlayer
local a = game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:wait()

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

Library:Notify("Loading Ui...", 3)

local Window = Library:CreateWindow({
 Title = "Lvy.lol Hub", -- Изменено название
 Footer = "Script by Lvy.lol",
 Icon = 1,
 NotifySide = "Right",
 ShowCustomCursor = true,
})

local Tabs = {
 Main = Window:AddTab("Scripts", "user"),
 Visual = Window:AddTab("Visual", "user"),
 ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Functions", "boxes")
local Left2GroupBox = Tabs.Visual:AddLeftGroupbox("Visual", "boxes")
local RightGroupBox = Tabs.Main:AddRightGroupbox("Social networks [Telegram]", "boxes") -- Изменено название
local Right2GroupBox = Tabs.Main:AddRightGroupbox("Characters", "boxes")

Library:Notify("Loaded.", 5)

-- Старый ESP функция
local espEnabled = false
local espObjects = {}

local function createESP(player)
    local character = player.Character
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_" .. player.Name
    highlight.Adornee = character
    highlight.Parent = character
    highlight.FillColor = Color3.fromRGB(170, 0, 255)
    highlight.OutlineColor = Color3.fromRGB(85, 0, 127)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameTag_" .. player.Name
    billboard.Adornee = character:WaitForChild("Head")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Text = player.Name
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(170, 0, 255)
    textLabel.TextSize = 20
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Parent = billboard
    
    espObjects[player] = {highlight, billboard}
end

local function removeESP(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            if obj then
                obj:Destroy()
            end
        end
        espObjects[player] = nil
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        Library:Notify(" ESP ", 5)
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                createESP(player)
            end
        end
        game:GetService("Players").PlayerAdded:Connect(function(player)
            if espEnabled then
                player.CharacterAdded:Connect(function()
                    if espEnabled then
                        createESP(player)
                    end
                end)
            end
        end)
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                player.CharacterAdded:Connect(function()
                    if espEnabled then
                        wait(1)
                        createESP(player)
                    end
                end)
            end
        end
    else
        Library:Notify(" ESP ", 5)
        for player, objects in pairs(espObjects) do
            removeESP(player)
        end
        espObjects = {}
    end
end

-- Aimbot функция с фиолетовым кружком
local aimbotEnabled = false
local aimbotCircle = nil
local aimbotConnection = nil
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Workspace = game:GetService("Workspace")

local function createAimbotCircle()
    if aimbotCircle then
        aimbotCircle:Remove()
    end
    
    local circle = Drawing.new("Circle")
    circle.Visible = true
    circle.Thickness = 2
    circle.Color = Color3.fromRGB(170, 0, 255) -- ФИОЛЕТОВЫЙ цвет
    circle.Transparency = 1
    circle.Radius = 60 -- Меньший размер
    circle.Filled = false
    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    aimbotCircle = circle
    return circle
end

local function isPlayerVisible(player)
    if not player or not player.Character then return false end
    
    local head = player.Character:FindFirstChild("Head")
    if not head then return false end
    
    local origin = Camera.CFrame.Position
    local target = head.Position
    local direction = (target - origin).Unit
    local distance = (target - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
    raycastParams.IgnoreWater = true
    
    local raycastResult = Workspace:Raycast(origin, direction * distance, raycastParams)
    
    if not raycastResult then
        return true
    end
    
    if raycastResult.Instance:IsDescendantOf(player.Character) then
        return true
    end
    
    return false
end

local function getClosestPlayerInCircle()
    local closestPlayer = nil
    local closestDistance = math.huge
    local circleCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen and isPlayerVisible(player) then
                    local distanceToCircle = (Vector2.new(headPos.X, headPos.Y) - circleCenter).Magnitude
                    
                    -- Проверяем что игрок внутри круга
                    if distanceToCircle <= aimbotCircle.Radius then
                        local distanceToCamera = (head.Position - Camera.CFrame.Position).Magnitude
                        
                        if distanceToCamera < closestDistance then
                            closestDistance = distanceToCamera
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimAtHead(player)
    if not player or not player.Character then return false end
    
    local head = player.Character:FindFirstChild("Head")
    if not head then return false end
    
    local camera = workspace.CurrentCamera
    -- Мгновенное прицеливание без плавности
    camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
    return true
end

local function startAimbot()
    createAimbotCircle()
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then return end
        
        -- Обновляем позицию круга
        if aimbotCircle then
            aimbotCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
        
        -- Проверяем зажата ли кнопка E
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            local closestPlayer = getClosestPlayerInCircle()
            if closestPlayer then
                aimAtHead(closestPlayer)
            end
        end
    end)
end

local function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    
    if aimbotCircle then
        aimbotCircle:Remove()
        aimbotCircle = nil
    end
end

local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    
    if aimbotEnabled then
        Library:Notify("Aimbot [Beta] ", 5)
        startAimbot()
    else
        Library:Notify("Aimbot [Beta] ", 5)
        stopAimbot()
    end
end

-- Boost Jump функция на 60 метров
local boostJumpEnabled = false
local boostJumpConnection = nil

local function boostJump()
    if not Player.Character then return end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    local rootPart = Player.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and rootPart then
        -- Применяем мощный импульс вверх (60 метров = 180 studs)
        local jumpForce = Vector3.new(0, 180, 0)
        rootPart.Velocity = rootPart.Velocity + jumpForce
        
        Library:Notify(" Super Jump! ", 2)
    end
end

local function startBoostJump()
    boostJumpConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Space then
            boostJump()
        end
    end)
end

local function stopBoostJump()
    if boostJumpConnection then
        boostJumpConnection:Disconnect()
        boostJumpConnection = nil
    end
end

local function toggleBoostJump()
    boostJumpEnabled = not boostJumpEnabled
    
    if boostJumpEnabled then
        Library:Notify("Super Jump!", 5)
        startBoostJump()
    else
        Library:Notify("Super Jump ", 5)
        stopBoostJump()
    end
end

-- Обработка респавна (функции не выключаются)
LocalPlayer.CharacterAdded:Connect(function(character)
    if aimbotEnabled then
        wait(2) -- Ждем загрузки персонажа
        if aimbotConnection then
            aimbotConnection:Disconnect()
        end
        startAimbot()
    end
    if boostJumpEnabled then
        wait(2) -- Ждем загрузки персонажа
        if boostJumpConnection then
            boostJumpConnection:Disconnect()
        end
        startBoostJump()
    end
    if espEnabled then
        wait(2) -- Ждем загрузки персонажа
        -- Обновляем ESP для всех игроков
        for player, objects in pairs(espObjects) do
            removeESP(player)
        end
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                createESP(player)
            end
        end
    end
end)

-- Кнопка Aimbot [Beta]
local AimbotButton = LeftGroupBox:AddButton({
 Text = "Aimbot [Beta]", -- Изменено название
 Func = toggleAimbot,
 DoubleClick = false,
 Tooltip = "Hold E to aim at the closest player IN THE CIRCLE",
})

-- Кнопка Boost Jump
local BoostJumpButton = LeftGroupBox:AddButton({
 Text = "Super Jump!",
 Func = toggleBoostJump,
 DoubleClick = false,
 Tooltip = "Press SPACE to jump 60 meters up",
})

-- Кнопка ESP
local ESPButton = Left2GroupBox:AddButton({
 Text = "ESP",
 Func = toggleESP,
 DoubleClick = false,
 Tooltip = "Enable/Disable Player ESP",
})

-- Кнопка Rejoin
local RejoinButton = Left2GroupBox:AddButton({
 Text = "Rejoin",
 Func = function()
    Library:Notify("Rejoining game...", 5)
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
 end,
 DoubleClick = false,
 Tooltip = "Re-enter the same server",
})

-- Кнопка Server Hop
local ServerHopButton = Left2GroupBox:AddButton({
 Text = "Server Hop",
 Func = function()
    Library:Notify("Searching for new server...", 5)
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local API = "https://games.roblox.com/v1/games/"
    
    local _place = game.PlaceId
    local _servers = API.._place.."/servers/Public?sortOrder=Asc&limit=100"
    function ListServers(cursor)
        local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
        return Http:JSONDecode(Raw)
    end
    
    local Next; repeat
        local Servers = ListServers(Next)
        for i,v in next, Servers.data do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                TPS:TeleportToPlaceInstance(_place, v.id)
                return
            end
        end
        Next = Servers.nextPageCursor
    until not Next
 end,
 DoubleClick = false,
 Tooltip = "Switch to another server",
})

-- Кнопка Respawn
local RespawnButton = Right2GroupBox:AddButton({
 Text = "Respawn",
 Func = function()
    Library:Notify("Respawning character...", 3)
    Player.Character:BreakJoints()
 end,
 DoubleClick = false,
 Tooltip = "Kills your character",
})

-- Кнопки для Social networks [Telegram]
local TelegramButton1 = RightGroupBox:AddButton({
 Text = "My discord",
 Func = function()
    setclipboard("https://discord.com/users/1152893642315407391")
    Library:Notify("Link copied to clipboard!", 3)
 end,
 DoubleClick = false,
 Tooltip = "Copies the link to my discord",
})

local TelegramButton2 = RightGroupBox:AddButton({
 Text = "scriptblox.com",
 Func = function()
    setclipboard("https://scriptblox.com")
    Library:Notify("Link copied to clipboard!", 3)
 end,
 DoubleClick = false,
 Tooltip = "Copies the link",
})

local TelegramButton3 = RightGroupBox:AddButton({
 Text = "We Thai have nothing against English and other languages",
 Func = function()
    -- Ничего не делает
    Library:Notify("Мы thai не имеем ничего против английского и других языков кроме украинского", 3)
 end,
 DoubleClick = false,
 Tooltip = "Information button",
})

local LeftGroupBox2 = Tabs.Main:AddLeftGroupbox("Info")
LeftGroupBox2:AddLabel("By Lvy.lol Xd", true) -- Изменен текст

Library:OnUnload(function()
    for player, objects in pairs(espObjects) do
        removeESP(player)
    end
    espObjects = {}
    
    if aimbotEnabled then
        stopAimbot()
    end
    
    if boostJumpEnabled then
        stopBoostJump()
    end
    
    print("Unloaded!")
end)

-- UI Settings
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("UI Settings")
MenuGroup:AddLabel("Omg Xd", true) -- Изменен текст

Library:SetWindowSizeConstraint({
    MinSize = Vector2.new(500, 400),
    MaxSize = Vector2.new(600, 500),
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("specific-place")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

Library:SetWatermarkVisibility(false)
SaveManager:LoadAutoloadConfig()

-- Основной цикл
RunService.RenderStepped:Connect(function()
 if punch then
    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("player"):WaitForChild("local"):WaitForChild("punch"):FireServer()
 end
 if blood then
    local args = {[1] = "bloodmoon"}
    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("game"):WaitForChild("global"):WaitForChild("purchase"):FireServer(unpack(args))
 end
 if blout then
    local args = {[1] = "blackout"}
    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("game"):WaitForChild("global"):WaitForChild("purchase"):FireServer(unpack(args))
 end
 if outbreak then
    local args = {[1] = "outbreak"}
    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("game"):WaitForChild("global"):WaitForChild("purchase"):FireServer(unpack(args))
 end

 if doorRussia then
    local ohInstance1 = workspace.nn_russia.doors.interactable_door
    game:GetService("ReplicatedStorage").events.player.char.bashdoor:InvokeServer(ohInstance1, true)
    game.Players.LocalPlayer.Character.HumanoidRootPart.breakdoor.Volume = 0
 end

 if auto then
    Player.Character.HumanoidRootPart.CFrame = CFrame.new(-470, 240, -1116)
    task.wait(0.01)
    Player.Character.HumanoidRootPart.CFrame = CFrame.new(-470, 240, -1116)
    task.wait(0.01)
    Player.Character.HumanoidRootPart.CFrame = CFrame.new(-270, 240, -1116)
    task.wait(0.01)
    Player.Character.HumanoidRootPart.CFrame = CFrame.new(-370, 240, -916)
    task.wait(0.01)
    Player.Character.HumanoidRootPart.CFrame = CFrame.new(-70, 240, -1116)
 end
end)
