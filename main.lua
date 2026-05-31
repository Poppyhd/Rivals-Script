local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

------------------------------------------------
-- SETTINGS & MUTABLE HOTKEYS
------------------------------------------------
local KEY = "9095"
local TROLL_KEY = "4554"
local DISCORD = "https://discord.gg/aDbpyaN4Z6"
local LOGO_ASSET_ID = "rbxassetid://1234567890" 

-- Konfigurierbare Hotkeys
local menuHotkey = Enum.KeyCode.LeftControl
local tpHotkey = Enum.KeyCode.Y

local PLACES = {
    BRAINROT = 109983668079237,
    RANDOM = 109301239085011,
    BROOKHAVEN = 4924922222
}

local trollTabUnlocked = false
local scriptRunning = true
local connections = {}

------------------------------------------------
-- GUI BASE
------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "BitachiRivalsPremium"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 460, 0, 620)
main.Position = UDim2.new(0.5, -230, 0.5, -310)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
main.Visible = false
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0, 255, 200)
stroke.Thickness = 1.8

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 65)
topBar.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
topBar.Parent = main
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 18)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "BITACHI STUDIOS"
title.TextColor3 = Color3.new(0,0,0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = topBar

-- Draggable UI
local dragging, dragInput, dragStart
table.insert(connections, topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        dragInput = input
    end
end))
table.insert(connections, UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(0, main.Position.X.Offset + delta.X, 0, main.Position.Y.Offset + delta.Y)
    end
end))
table.insert(connections, topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end))

------------------------------------------------
-- NOTIFY SYSTEM
------------------------------------------------
local function notify(text)
    if not gui or not gui.Parent then return end
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0, 300, 0, 55)
    n.Position = UDim2.new(0.5, -150, 0.08, 0)
    n.BackgroundColor3 = Color3.fromRGB(15,15,20)
    n.TextColor3 = Color3.fromRGB(0,255,200)
    n.Text = text
    n.TextScaled = true
    n.Font = Enum.Font.GothamBold
    n.Parent = gui
    Instance.new("UICorner", n).CornerRadius = UDim.new(0,14)
    task.delay(2.8, function() pcall(function() n:Destroy() end) end)
end

------------------------------------------------
-- LOGIN SCREEN
------------------------------------------------
local login = Instance.new("Frame")
login.Size = UDim2.new(0, 360, 0, 310)
login.Position = UDim2.new(0.5, -180, 0.5, -155)
login.BackgroundColor3 = Color3.fromRGB(18,18,23)
login.Parent = gui
Instance.new("UICorner", login).CornerRadius = UDim.new(0, 18)

local logTitle = Instance.new("TextLabel")
logTitle.Size = UDim2.new(1,0,0,60)
logTitle.Text = "BITACHI STUDIOS"
logTitle.TextColor3 = Color3.fromRGB(0,255,200)
logTitle.BackgroundTransparency = 1
logTitle.TextScaled = true
logTitle.Font = Enum.Font.GothamBold
logTitle.Parent = login

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.85,0,0,45)
keyBox.Position = UDim2.new(0.075,0,0.26,0)
keyBox.PlaceholderText = "Enter Key"
keyBox.BackgroundColor3 = Color3.fromRGB(30,30,35)
keyBox.TextColor3 = Color3.new(1,1,1)
keyBox.Parent = login
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0,12)

local loginBtn = Instance.new("TextButton")
loginBtn.Size = UDim2.new(0.85,0,0,45)
loginBtn.Position = UDim2.new(0.075,0,0.46,0)
loginBtn.Text = "LOGIN"
loginBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
loginBtn.TextColor3 = Color3.new(0,0,0)
loginBtn.TextScaled = true
loginBtn.Font = Enum.Font.GothamBold
loginBtn.Parent = login
Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0,12)

local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0.85,0,0,45)
discordBtn.Position = UDim2.new(0.075,0,0.66,0)
discordBtn.Text = "Join the dc for the Key"
discordBtn.BackgroundColor3 = Color3.fromRGB(44, 47, 51)
discordBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
discordBtn.TextScaled = true
discordBtn.Font = Enum.Font.GothamBold
discordBtn.Parent = login
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0,12)

local isLoggedIn = false

table.insert(connections, loginBtn.MouseButton1Click:Connect(function()
    if keyBox.Text == KEY then
        isLoggedIn = true
        login:Destroy()
        main.Visible = true
        notify("Erfolgreich eingeloggt!")
    else
        player:Kick("Incorrect Premium Key.")
    end
end))

table.insert(connections, discordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(DISCORD)
        notify("Discord-Link in Zwischenablage kopiert!")
    else
        notify("Kopieren nicht unterstützt. Link: " .. DISCORD)
    end
end))

table.insert(connections, UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not scriptRunning then return end
    if input.KeyCode == menuHotkey then
        if isLoggedIn then
            main.Visible = not main.Visible
        else
            if login and login.Parent then
                login.Visible = not login.Visible
            end
        end
    end
end))

------------------------------------------------
-- TABS SYSTEM
------------------------------------------------
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(0.95,0,0,45)
tabFrame.Position = UDim2.new(0.025,0,0,75)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = main

local function createTab(name, x, width)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(width or 0.19, 0, 1, 0)
    tab.Position = UDim2.new(x,0,0,0)
    tab.Text = name
    tab.BackgroundColor3 = Color3.fromRGB(30,30,35)
    tab.TextColor3 = Color3.new(1,1,1)
    tab.TextScaled = true
    tab.Font = Enum.Font.GothamSemibold
    tab.Parent = tabFrame
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0,10)
    return tab
end

local movementTab = createTab("Move", 0, 0.18)
local combatTab = createTab("Combat", 0.19, 0.20)
local visualsTab = createTab("Visuals", 0.40, 0.20)
local hotkeyTab = createTab("Hotkey", 0.61, 0.19)
local trollTab = createTab("Place", 0.81, 0.19)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(0.95,0,0,460)
content.Position = UDim2.new(0.025,0,0,135)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 5
content.Parent = main
local list = Instance.new("UIListLayout", content)
list.Padding = UDim.new(0, 8)
list.SortOrder = Enum.SortOrder.LayoutOrder

local function makeButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 52)
    btn.BackgroundColor3 = Color3.fromRGB(30,30,37)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    table.insert(connections, btn.MouseButton1Click:Connect(function() callback(btn) end))
    return btn
end

-- ==================== MOVEMENT ====================
local infJumpEnabled = false
local currentSpeed = 16

table.insert(connections, movementTab.MouseButton1Click:Connect(function()
    content:ClearAllChildren()
    Instance.new("UIListLayout", content).Padding = UDim.new(0,8)

    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(1, -12, 0, 55)
    speedFrame.BackgroundColor3 = Color3.fromRGB(30,30,37)
    speedFrame.Parent = content
    Instance.new("UICorner", speedFrame).CornerRadius = UDim.new(0, 12)

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.4, 0, 1, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "WalkSpeed:"
    speedLabel.TextColor3 = Color3.new(1,1,1)
    speedLabel.TextScaled = true
    speedLabel.Font = Enum.Font.GothamSemibold
    speedLabel.Parent = speedFrame

    local speedInput = Instance.new("TextBox")
    speedInput.Size = UDim2.new(0.55, 0, 0.7, 0)
    speedInput.Position = UDim2.new(0.4, 0, 0.15, 0)
    speedInput.BackgroundColor3 = Color3.fromRGB(45,45,52)
    speedInput.Text = tostring(currentSpeed)
    speedInput.TextColor3 = Color3.fromRGB(0, 255, 200)
    speedInput.TextScaled = true
    speedInput.Font = Enum.Font.GothamBold
    speedInput.Parent = speedFrame
    Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 8)

    table.insert(connections, speedInput.FocusLost:Connect(function()
        local value = tonumber(speedInput.Text)
        if value then currentSpeed = value else speedInput.Text = tostring(currentSpeed) end
    end))

    makeButton("Infinity Jump: " .. (infJumpEnabled and "ON" or "OFF"), function(btn)
        infJumpEnabled = not infJumpEnabled
        btn.Text = "Infinity Jump: " .. (infJumpEnabled and "ON" or "OFF")
    end)
end))

table.insert(connections, RunService.PreRender:Connect(function(deltaTime)
    if not scriptRunning then return end
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart then
            humanoid.WalkSpeed = currentSpeed
            if humanoid.MoveDirection.Magnitude > 0 and currentSpeed > 16 then
                rootPart.CFrame = rootPart.CFrame + (humanoid.MoveDirection * (currentSpeed - 16) * deltaTime)
            end
        end
    end
end))

table.insert(connections, UIS.JumpRequest:Connect(function()
    if scriptRunning and infJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState("Jumping")
    end
end))

-- ==================== COMBAT (AIMBOT LOCK & WAFFEN POSITION FIX) ====================
local aimbotEnabled = false
local FOVRadius = 400

local function getClosestPlayerToCrosshair()
    local closestPlayer = nil
    local shortestDistance = FOVRadius
    local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Target entweder Kopf (wenn da) oder Torso
                local targetPart = p.Character:FindFirstChild("Head") or p.Character.HumanoidRootPart
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    raycastParams.FilterDescendantsInstances = {player.Character, camera, workspace:FindFirstChild("Camera")}
                    
                    local rayDirection = (targetPart.Position - camera.CFrame.Position)
                    local result = workspace:Raycast(camera.CFrame.Position, rayDirection, raycastParams)
                    
                    if not result or result.Instance:IsDescendantOf(p.Character) then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = targetPart -- Gibt das exakte Zielobjekt zurück
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

table.insert(connections, combatTab.MouseButton1Click:Connect(function()
    content:ClearAllChildren()
    Instance.new("UIListLayout", content).Padding = UDim.new(0,8)

    makeButton("Aimbot: " .. (aimbotEnabled and "ON" or "OFF"), function(btn)
        aimbotEnabled = not aimbotEnabled
        btn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
    end)
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -12, 0, 40)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Use configured Hotkey to Teleport Behind"
    infoLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.GothamBold
    infoLabel.Parent = content
end))

-- FIX: Ändert CFrame UND emuliert Mauswinkel, damit die Waffe dorthin schießt!
table.insert(connections, RunService.RenderStepped:Connect(function()
    if scriptRunning and aimbotEnabled then
        local targetPart = getClosestPlayerToCrosshair()
        if targetPart then
            -- Zwingt die Kamera direkt auf das Ziel
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPart.Position)
        end
    end
end))

table.insert(connections, UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not scriptRunning then return end
    if input.KeyCode == tpHotkey then
        local targetPart = getClosestPlayerToCrosshair()
        if targetPart and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = targetPart.Parent:FindFirstChild("HumanoidRootPart")
            if root then
                player.Character.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 0, 3.5) * CFrame.Angles(0, math.rad(180), 0)
                notify("Hinter Gegner teleportiert!")
            end
        else
            notify("Kein gültiges Ziel im FOV gefunden.")
        end
    end
end))

-- ==================== VISUALS ====================
local espEnabled = false

local function applyESP(p)
    if p == player then return end
    if espEnabled and p.Character then
        local char = p.Character
        if char:FindFirstChild("PlayerESP") then char.PlayerESP:Destroy() end
        local box = Instance.new("Highlight")
        box.Name = "PlayerESP"
        box.FillColor = Color3.fromRGB(0, 255, 200)
        box.FillTransparency = 0.5
        box.OutlineColor = Color3.fromRGB(255, 255, 255)
        box.Adornee = char
        box.Parent = char
    end
end

table.insert(connections, visualsTab.MouseButton1Click:Connect(function()
    content:ClearAllChildren()
    Instance.new("UIListLayout", content).Padding = UDim.new(0,8)

    makeButton("ESP & Wallhack: " .. (espEnabled and "ON" or "OFF"), function(btn)
        espEnabled = not espEnabled
        btn.Text = "ESP & Wallhack: " .. (espEnabled and "ON" or "OFF")
        if espEnabled then
            for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("PlayerESP") then p.Character.PlayerESP:Destroy() end
            end
        end
    end)
end))

-- ==================== HOTKEY & UNBIND TAB ====================
local listeningForMenu = false
local listeningForTP = false

hotkeyTab.MouseButton1Click:Connect(function()
    content:ClearAllChildren()
    Instance.new("UIListLayout", content).Padding = UDim.new(0,8)

    local menuBtn = makeButton("Menu Key: " .. menuHotkey.Name, function(btn)
        listeningForMenu = true
        listeningForTP = false
        btn.Text = "Press any key..."
    end)

    local tpBtn = makeButton("Teleport Key: " .. tpHotkey.Name, function(btn)
        listeningForTP = true
        listeningForMenu = false
        btn.Text = "Press any key..."
    end)

    local killBtn = Instance.new("TextButton")
    killBtn.Size = UDim2.new(1, -12, 0, 52)
    killBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    killBtn.Text = "EMERGENCY UNBIND & CLOSE"
    killBtn.TextColor3 = Color3.new(1,1,1)
    killBtn.TextScaled = true
    killBtn.Font = Enum.Font.GothamBold
    killBtn.Parent = content
    Instance.new("UICorner", killBtn).CornerRadius = UDim.new(0, 12)

    killBtn.MouseButton1Click:Connect(function()
        scriptRunning = false
        for _, c in ipairs(connections) do if c then c:Disconnect() end end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("PlayerESP") then p.Character.PlayerESP:Destroy() end
        end
        pcall(function()
            if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            end
        end)
        gui:Destroy()
    end)

    local inputConn
    inputConn = UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if listeningForMenu then
            menuHotkey = input.KeyCode
            listeningForMenu = false
            menuBtn.Text = "Menu Key: " .. menuHotkey.Name
            inputConn:Disconnect()
        elseif listeningForTP then
            tpHotkey = input.KeyCode
            listeningForTP = false
            tpBtn.Text = "Teleport Key: " .. tpHotkey.Name
            inputConn:Disconnect()
        end
    end)
end)

-- ==================== PLACE TP ====================
local function loadTeleportMenu()
    content:ClearAllChildren()
    Instance.new("UIListLayout", content).Padding = UDim.new(0,8)

    makeButton("Steal a Brainrot Public", function()
        pcall(function() TeleportService:Teleport(PLACES.BRAINROT, player) end)
    end)
    makeButton("Random Public", function()
        pcall(function() TeleportService:Teleport(PLACES.RANDOM, player) end)
    end)
    makeButton("Brookhaven Public", function()
        pcall(function() TeleportService:Teleport(PLACES.BROOKHAVEN, player) end)
    end)
end

trollTab.MouseButton1Click:Connect(function()
    content:ClearAllChildren()
    Instance.new("UIListLayout", content).Padding = UDim.new(0,8)

    if trollTabUnlocked then
        loadTeleportMenu()
    else
        local promptLabel = Instance.new("TextLabel")
        promptLabel.Size = UDim2.new(1, -12, 0, 45)
        promptLabel.BackgroundTransparency = 1
        promptLabel.Text = "Please enter the key"
        promptLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        promptLabel.TextScaled = true
        promptLabel.Font = Enum.Font.GothamSemibold
        promptLabel.Parent = content

        local secureInput = Instance.new("TextBox")
        secureInput.Size = UDim2.new(1, -12, 0, 50)
        secureInput.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        secureInput.Text = ""
        secureInput.PlaceholderText = "••••"
        secureInput.TextColor3 = Color3.fromRGB(0, 255, 200)
        secureInput.TextScaled = true
        secureInput.Font = Enum.Font.GothamBold
        secureInput.Parent = content
        Instance.new("UICorner", secureInput).CornerRadius = UDim.new(0, 10)

        makeButton("Unlock Options", function()
            if secureInput.Text == TROLL_KEY then
                trollTabUnlocked = true
                notify("Freigeschaltet!")
                loadTeleportMenu()
            else
                secureInput.Text = ""
                promptLabel.Text = "Access Denied."
                promptLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            end
        end)
    end
end)

movementTab.MouseButton1Click:Fire()
notify("Bitachi Studios Premium geladen!")
