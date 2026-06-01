local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService") -- Für das Speichern der Settings
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

------------------------------------------------
-- SETTINGS, CODES & HOTKEYS
------------------------------------------------
local PREMIUM_KEY = "9597"
local ULTI_CODE = "3883"
local DISCORD = "https://discord.gg/aDbpyaN4Z6"

local SOUND_CLICK_ID = "rbxassetid://139719503904449"
local SOUND_ACTION_ID = "rbxassetid://99777940032182"
local soundVolume = 1.0 

local menuHotkey = Enum.KeyCode.LeftControl
local autoShootHotkey = Enum.KeyCode.H
local savePtHotkey = Enum.KeyCode.V
local tpPtHotkey = Enum.KeyCode.B

local scriptRunning = true
local connections = {}

local listeningForMenu = false
local listeningForShoot = false
local listeningForSave = false
local listeningForTp = false

local isUltiUnlocked = false
local ghostEnabled = false
local tpBehindEnabled = false 
local infJumpEnabled = false
local aimbotEnabled = false
local autoShootEnabled = false

-- Visuals Settings (Bezieht sich auf image_ef7305.jpg)
local espEnabled = false
local snaplinesEnabled = false 

local speedEnabled = false
local walkSpeedValue = 32

local savedCFrame = nil

------------------------------------------------
-- SAVE / LOAD CONFIGURATION ENGINE
------------------------------------------------
local function saveSettingsToFile()
    if not writefile then 
        notify("Dein Executor unterstützt 'writefile' nicht!") 
        return 
    end
    
    local config = {
        walkSpeedValue = walkSpeedValue,
        speedEnabled = speedEnabled,
        infJumpEnabled = infJumpEnabled,
        aimbotEnabled = aimbotEnabled,
        espEnabled = espEnabled,
        snaplinesEnabled = snaplinesEnabled,
        soundVolume = soundVolume,
        menuHotkey = menuHotkey.Name,
        autoShootHotkey = autoShootHotkey.Name
    }
    
    local success, json = pcall(function() return HttpService:JSONEncode(config) end)
    if success then
        writefile("bitachi_config.json", json)
        notify("Settings erfolgreich gespeichert!")
        playLocalSound(SOUND_ACTION_ID)
    else
        notify("Fehler beim Codieren der Settings.")
    end
end

local function loadSettingsFromFile()
    if not readfile or not isfile then 
        notify("Dein Executor unterstützt Dateisysteme nicht!") 
        return 
    end
    
    if not isfile("bitachi_config.json") then
        notify("Keine gespeicherten Settings gefunden!")
        return
    end
    
    local json = readfile("bitachi_config.json")
    local success, config = pcall(function() return HttpService:JSONDecode(json) end)
    
    if success and config then
        walkSpeedValue = config.walkSpeedValue or walkSpeedValue
        speedEnabled = config.speedEnabled or speedEnabled
        infJumpEnabled = config.infJumpEnabled or infJumpEnabled
        aimbotEnabled = config.aimbotEnabled or aimbotEnabled
        espEnabled = config.espEnabled or espEnabled
        snaplinesEnabled = config.snaplinesEnabled or snaplinesEnabled
        soundVolume = config.soundVolume or soundVolume
        
        if config.menuHotkey then menuHotkey = Enum.KeyCode[config.menuHotkey] end
        if config.autoShootHotkey then autoShootHotkey = Enum.KeyCode[config.autoShootHotkey] end
        
        notify("Settings erfolgreich geladen!")
        playLocalSound(SOUND_ACTION_ID)
    else
        notify("Fehler beim Laden der Konfigurationsdatei.")
    end
end

------------------------------------------------
-- SOUND UTILITY
------------------------------------------------
function playLocalSound(soundId)
    if not scriptRunning or soundVolume <= 0 then return end
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = soundVolume
    sound.Parent = SoundService 
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

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
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.BackgroundTransparency = 0.35
main.Visible = false
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0, 255, 200)
stroke.Thickness = 1.2
stroke.Transparency = 0.4

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 65)
topBar.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
topBar.BackgroundTransparency = 0.7
topBar.Parent = main
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 18)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "BITACHI STUDIOS"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = topBar

-- Dragging Engine
local dragToggle = false
local dragStart = nil
local startPos = nil

table.insert(connections, topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end))

table.insert(connections, UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragToggle then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end))

------------------------------------------------
-- NOTIFY SYSTEM
------------------------------------------------
function notify(text)
    if not gui or not gui.Parent then return end
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0, 320, 0, 55)
    n.Position = UDim2.new(0.5, -160, 0.08, 0)
    n.BackgroundColor3 = Color3.fromRGB(10,10,15)
    n.BackgroundTransparency = 0.4
    n.TextColor3 = Color3.fromRGB(0,255,200)
    n.Text = text
    n.TextScaled = true
    n.Font = Enum.Font.GothamBold
    n.Parent = gui
    Instance.new("UICorner", n).CornerRadius = UDim.new(0,14)
    local nStroke = Instance.new("UIStroke", n)
    nStroke.Color = Color3.fromRGB(0, 255, 200)
    nStroke.Transparency = 0.5
    task.delay(2.8, function() pcall(function() n:Destroy() end) end)
end

------------------------------------------------
-- TELEPORT ENGINE LOGIC
------------------------------------------------
local function saveCurrentPosition()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedCFrame = player.Character.HumanoidRootPart.CFrame
        playLocalSound(SOUND_ACTION_ID)
        notify("Position gespeichert!")
    end
end

local function teleportToSavedPosition()
    if savedCFrame and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = savedCFrame
        playLocalSound(SOUND_ACTION_ID)
    else
        notify("Keine Position gespeichert!")
    end
end

------------------------------------------------
-- TARGET FINDER UTILITY (Closest to Crosshair)
------------------------------------------------
local function getClosestPlayerToCrosshair()
    local closestTarget = nil
    local shortestDistance = 600
    local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local targetPart = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Head")
                if targetPart then
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestTarget = p.Character
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

------------------------------------------------
-- ADVANCED VISUALS SYSTEM: SNAPLINES (TRACERS) & INFO
------------------------------------------------
local activeTracers = {}

local function createTracer(targetPlayer)
    if activeTracers[targetPlayer] then return end

    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Color = Color3.fromRGB(0, 255, 100)
    line.Transparency = 0.8
    line.Visible = false

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 160, 0, 70)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Parent = CoreGui

    local infoLabel = Instance.new("TextLabel", billboard)
    infoLabel.Size = UDim2.new(1, 0, 1, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextScaled = true
    infoLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    infoLabel.Font = Enum.Font.GothamBold

    activeTracers[targetPlayer] = {Line = line, Billboard = billboard, Label = infoLabel}
end

local function removeTracer(targetPlayer)
    if activeTracers[targetPlayer] then
        activeTracers[targetPlayer].Line:Remove()
        activeTracers[targetPlayer].Billboard:Destroy()
        activeTracers[targetPlayer].Deleted = true
        activeTracers[targetPlayer] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= player then createTracer(p) end end
table.insert(connections, Players.PlayerAdded:Connect(function(p) if p ~= player then createTracer(p) end end))
table.insert(connections, Players.PlayerRemoving:Connect(removeTracer))

table.insert(connections, RunService.RenderStepped:Connect(function()
    if not scriptRunning then return end

    -- Speed Hack Logic
    if speedEnabled and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = walkSpeedValue
            if humanoid.MoveDirection.Magnitude > 0 and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                hrp.AssemblyLinearVelocity = Vector3.new(
                    humanoid.MoveDirection.X * walkSpeedValue, 
                    hrp.AssemblyLinearVelocity.Y, 
                    humanoid.MoveDirection.Z * walkSpeedValue
                )
            end
        end
    end

    -- Teleport Behind Logic
    if tpBehindEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local targetChar = getClosestPlayerToCrosshair()
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            local targetHRP = targetChar.HumanoidRootPart
            local myHRP = player.Character.HumanoidRootPart
            local behindPosition = targetHRP.Position - (targetHRP.CFrame.LookVector * 3)
            myHRP.CFrame = CFrame.lookAt(behindPosition, targetHRP.Position)
        end
    end

    -- Visual Striche & Info Zeichner Engine
    for targetPlayer, data in pairs(activeTracers) do
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = targetPlayer.Character
            local hrp = char.HumanoidRootPart
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            local hrpScreenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            local myPos = player.Character.HumanoidRootPart.Position
            local distance = math.floor((myPos - hrp.Position).Magnitude)

            if onScreen and snaplinesEnabled and hum and hum.Health > 0 then
                data.Line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                data.Line.To = Vector2.new(hrpScreenPos.X, hrpScreenPos.Y)
                data.Line.Visible = true

                data.Billboard.Adornee = char:FindFirstChild("Head") or hrp
                data.Billboard.Enabled = true
                data.Label.Text = string.format("%d HP\n%s\n%d studs", hum.Health, targetPlayer.Name, distance)
            else
                data.Line.Visible = false
                data.Billboard.Enabled = false
            end
        else
            data.Line.Visible = false
            data.Billboard.Enabled = false
        end
    end
end))

------------------------------------------------
-- LOGIN SCREEN
------------------------------------------------
local login = Instance.new("Frame")
login.Size = UDim2.new(0, 360, 0, 310)
login.Position = UDim2.new(0.5, -180, 0.5, -155)
login.BackgroundColor3 = Color3.fromRGB(10,10,15)
login.BackgroundTransparency = 0.35
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
keyBox.BackgroundColor3 = Color3.fromRGB(20,20,25)
keyBox.BackgroundTransparency = 0.5
keyBox.TextColor3 = Color3.new(1,1,1)
keyBox.Parent = login
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0,12)

local loginBtn = Instance.new("TextButton")
loginBtn.Size = UDim2.new(0.85,0,0,45)
loginBtn.Position = UDim2.new(0.075,0,0.46,0)
loginBtn.Text = "LOGIN"
loginBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
loginBtn.BackgroundTransparency = 0.4
loginBtn.TextColor3 = Color3.new(1,1,1)
loginBtn.TextScaled = true
loginBtn.Font = Enum.Font.GothamBold
loginBtn.Parent = login
Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0,12)

local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0.85,0,0,45)
discordBtn.Position = UDim2.new(0.075,0,0.66,0)
discordBtn.Text = "Join Discord for Key"
discordBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
discordBtn.BackgroundTransparency = 0.5
discordBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
discordBtn.TextScaled = true
discordBtn.Font = Enum.Font.GothamBold
discordBtn.Parent = login
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0,12)

local isLoggedIn = false
table.insert(connections, loginBtn.MouseButton1Click:Connect(function()
    playLocalSound(SOUND_CLICK_ID)
    if keyBox.Text == PREMIUM_KEY then
        isLoggedIn = true
        login:Destroy()
        main.Visible = true
        notify("Erfolgreich eingeloggt!")
    else
        player:Kick("Incorrect Premium Key.")
    end
end))

table.insert(connections, discordBtn.MouseButton1Click:Connect(function()
    playLocalSound(SOUND_CLICK_ID)
    if setclipboard then
        setclipboard(DISCORD)
        notify("Discord-Link kopiert!")
    else
        notify("Link: " .. DISCORD)
    end
end))

------------------------------------------------
-- GLOBAL HOTKEY INPUT ENGINE
------------------------------------------------
local loadHotkeyMenu

table.insert(connections, UIS.InputBegan:Connect(function(input, gpe)
    if not scriptRunning then return end
    
    if listeningForMenu and input.UserInputType == Enum.UserInputType.Keyboard then
        menuHotkey = input.KeyCode
        listeningForMenu = false
        notify("Menü-Taste: " .. menuHotkey.Name)
        loadHotkeyMenu()
        return
    elseif listeningForShoot and input.UserInputType == Enum.UserInputType.Keyboard then
        autoShootHotkey = input.KeyCode
        listeningForShoot = false
        notify("Auto-Shoot-Taste: " .. autoShootHotkey.Name)
        loadHotkeyMenu()
        return
    elseif listeningForSave and input.UserInputType == Enum.UserInputType.Keyboard then
        savePtHotkey = input.KeyCode
        listeningForSave = false
        notify("Save Point Taste: " .. savePtHotkey.Name)
        loadHotkeyMenu()
        return
    elseif listeningForTp and input.UserInputType == Enum.UserInputType.Keyboard then
        tpPtHotkey = input.KeyCode
        listeningForTp = false
        notify("Teleport Taste: " .. tpPtHotkey.Name)
        loadHotkeyMenu()
        return
    end

    if gpe then return end

    if input.KeyCode == menuHotkey then
        if isLoggedIn then main.Visible = not main.Visible end
    elseif input.KeyCode == savePtHotkey then
        saveCurrentPosition()
    elseif input.KeyCode == tpPtHotkey then
        teleportToSavedPosition()
    end
end))

------------------------------------------------
-- NAVIGATION TABS SYSTEM
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
    tab.BackgroundColor3 = Color3.fromRGB(20,20,25)
    tab.BackgroundTransparency = 0.5
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
local hotkeyTab = createTab("Tastenkurzel", 0.61, 0.19)
local ultiTab = createTab("Ulti Cheat", 0.81, 0.19)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(0.95,0,0,460)
content.Position = UDim2.new(0.025,0,0,135)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 2
content.Parent = main

function makeButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 52)
    btn.BackgroundColor3 = Color3.fromRGB(20,20,25)
    btn.BackgroundTransparency = 0.5
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    table.insert(connections, btn.MouseButton1Click:Connect(function() 
        playLocalSound(SOUND_CLICK_ID)
        callback(btn) 
    end))
    return btn
end

-- ==================== MOVE MENU ====================
local function loadMovementMenu()
    content:ClearAllChildren()
    Instance.new("UIListLayout", content).Padding = UDim.new(0,8)
    
    makeButton("Infinity Jump: " .. (infJumpEnabled and "ON" or "OFF"), function(btn)
        playLocalSound(SOUND_ACTION_ID)
        infJumpEnabled = not infJumpEnabled
        btn.Text = "Infinity Jump: " .. (infJumpEnabled and "ON" or "OFF")
    end)

    makeButton("Speed Hack: " .. (speedEnabled and "ON" or "OFF"), function(btn)
        playLocalSound(SOUND_ACTION_ID)
        speedEnabled = not speedEnabled
        btn.Text = "Speed Hack: " .. (speedEnabled and "ON" or "OFF")
        if not speedEnabled and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end)

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(1, -12, 0, 52)
    speedBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    speedBox.BackgroundTransparency = 0.4
    speedBox.PlaceholderText = "Klicke hier um Speed einzutippen..."
    speedBox.Text = "Speed: " .. walkSpeedValue
    speedBox.TextColor3 = Color3.fromRGB(0, 255, 200)
    speedBox.TextScaled = true
    speedBox.Font = Enum.Font.GothamSemibold
    speedBox.Parent = content
    Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 12)

    table.insert(connections, speedBox.FocusLost:Connect(function(enterPressed)
        local num = tonumber(speedBox.Text)
        if num then
            walkSpeedValue = num
            speedBox.Text = "Speed: " .. walkSpeedValue
            playLocalSound(SOUND_ACTION_ID)
            notify("Geschwindigkeit auf " .. walkSpeedValue .. " gesetzt!")
        else
            speedBox.Text = "Speed: " .. walkSpeedValue
            notify("Bitte nur Zahlen eingeben!")
        end
    end))

    makeButton("Save Teleport Point", function()
        saveCurrentPosition()
    end)

    makeButton("Teleport to Point", function()
        teleportToSavedPosition()
    end)
end
table.insert(connections, movementTab.MouseButton1Click:Connect(loadMovementMenu))

table.insert(connections, UIS.JumpRequest:Connect(function()
    if scriptRunning and infJumpEnabled and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end))

-- ==================== COMBAT MENU ====================
table.insert(connections, combatTab.MouseButton1Click:Connect(function()
    content:ClearAllChildren()
    Instance.new("UIListLayout", content).Padding = UDim.new(0,8)
    
    makeButton("Aimbot: " .. (aimbotEnabled and "ON" or "OFF"), function(btn)
        playLocalSound(SOUND_ACTION_ID)
        aimbotEnabled = not aimbotEnabled
        btn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
    end)
end))

table.insert(connections, UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not scriptRunning then return end
    if input.KeyCode == autoShootHotkey then autoShootEnabled = true end
end))

table.insert(connections, UIS.InputEnded:Connect(function(input)
    if input.KeyCode == autoShootHotkey then autoShootEnabled = false end
end))

table.insert(connections, RunService.RenderStepped:Connect(function()
    if not scriptRunning then return end
    if aimbotEnabled or autoShootEnabled then
        local targetChar = getClosestPlayerToCrosshair()
        if targetChar then
            local targetPart = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")
            if targetPart then
                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPart.Position)
                if autoShootEnabled then
                    local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
    end
end))

-- ==================== VISUALS MENU ====================
local espContainer = Instance.new("Folder")
espContainer.Name = "BitachiESP"
espContainer.Parent = CoreGui

local function createESP(p)
    if p == player then return end
    local function applyESP(char)
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end
        if espContainer:FindFirstChild(p.Name) then espContainer[p.Name]:Destroy() end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = p.Name
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(0, 255, 200)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.OutlineTransparency = 0.1
        highlight.Enabled = espEnabled
        highlight.Parent = espContainer
    end
    p.CharacterAdded:Connect(applyESP)
    if p.Character then applyESP(p.Character) end
end

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
table.insert(connections, Players.PlayerAdded:Connect(createESP))

table.insert(connections, visualsTab.MouseButton1Click:Connect(function()
    content:ClearAllChildren()
    Instance.new("UIListLayout", content).Padding = UDim.new(0,8)
    
    makeButton("ESP Highlight: " .. (espEnabled and "ON" or "OFF"), function(btn)
        playLocalSound(SOUND_ACTION_ID)
        espEnabled = not espEnabled
        btn.Text = "ESP Highlight: " .. (espEnabled and "ON" or "OFF")
        for _, h in ipairs(espContainer:GetChildren()) do
            if h:IsA("Highlight") then h.Enabled = espEnabled end
        end
    end)

    makeButton("Snaplines (Striche zu Spielern): " .. (snaplinesEnabled and "ON" or "OFF"), function(btn)
        playLocalSound(SOUND_ACTION_ID)
        snaplinesEnabled = not snaplinesEnabled
        btn.Text = "Snaplines (Striche zu Spielern): " .. (snaplinesEnabled and "ON" or "OFF")
    end)

    -- NEUE SETTINGS BUTTONS FÜR DIE SIMULATION VON AUTO-LOAD
    local saveBtn = makeButton("💾 Save Current Settings", function()
        saveSettingsToFile()
    end)
    saveBtn.TextColor3 = Color3.fromRGB(0, 255, 150)

    local loadBtn = makeButton("📂 Load Saved Settings", function()
        loadSettingsFromFile()
    end)
    loadBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
end))

-- ==================== TASTENKÜRZEL SYSTEM ====================
loadHotkeyMenu = function()
    content:ClearAllChildren()
    Instance.new("UIListLayout", content).Padding = UDim.new(0,8)
    
    local menuBtn
    menuBtn = makeButton("Menu Key: " .. menuHotkey.Name, function()
        listeningForMenu = true listeningForShoot = false listeningForSave = false listeningForTp = false
        menuBtn.Text = "Drücke eine Taste..."
    end)
    
    local shootBtn
    shootBtn = makeButton("Auto Shoot Key: " .. autoShootHotkey.Name, function()
        listeningForShoot = true listeningForMenu = false listeningForSave = false listeningForTp = false
        shootBtn.Text = "Drücke eine Taste..."
    end)

    local saveBtn
    saveBtn = makeButton("Save Point Key: " .. savePtHotkey.Name, function()
        listeningForSave = true listeningForMenu = false listeningForShoot = false listeningForTp = false
        saveBtn.Text = "Drücke eine Taste..."
    end)

    local tpBtn
    tpBtn = makeButton("Teleport Key: " .. tpPtHotkey.Name, function()
        listeningForTp = true listeningForMenu = false listeningForShoot = false listeningForSave = false
        tpBtn.Text = "Drücke eine Taste..."
    end)

    local space = Instance.new("Frame")
    space.Size = UDim2.new(1, 0, 0, 5)
    space.BackgroundTransparency = 1
    space.Parent = content

    local volDownBtn
    volDownBtn = makeButton("Volume leiser (-0.5) | Aktuell: " .. soundVolume, function()
        soundVolume = math.max(0, soundVolume - 0.5)
        volDownBtn.Text = "Volume leiser (-0.5) | Aktuell: " .. soundVolume
        notify("Lautstärke verringert!")
    end)

    local volUpBtn
    volUpBtn = makeButton("Volume lauter (+0.5) | Aktuell: " .. soundVolume, function()
        soundVolume = math.min(4.0, soundVolume + 0.5)
        volUpBtn.Text = "Volume lauter (+0.5) | Aktuell: " .. soundVolume
        playLocalSound(SOUND_ACTION_ID)
    end)
end
table.insert(connections, hotkeyTab.MouseButton1Click:Connect(loadHotkeyMenu))

-- ==================== ULTI CHEAT MENU ====================
local function loadUltiMenu()
    content:ClearAllChildren()
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0,8)

    if not isUltiUnlocked then
        local codeBox = Instance.new("TextBox")
        codeBox.Size = UDim2.new(1, -12, 0, 52)
        codeBox.PlaceholderText = "Enter Hidden Code"
        codeBox.Text = ""
        codeBox.TextColor3 = Color3.new(1, 1, 1)
        codeBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        codeBox.BackgroundTransparency = 0.5
        codeBox.TextScaled = true
        codeBox.Font = Enum.Font.GothamSemibold
        codeBox.Parent = content
        Instance.new("UICorner", codeBox).CornerRadius = UDim.new(0, 12)

        codeBox:GetPropertyChangedSignal("Text"):Connect(function()
            local currentText = codeBox.Text
            if #currentText > 0 and not currentText:match("^•+$") then
                local cleanText = currentText:gsub("•", "")
                codeBox:SetAttribute("RealText", (codeBox:GetAttribute("RealText") or "") .. cleanText)
                codeBox.Text = string.rep("•", #codeBox:GetAttribute("RealText"))
            elseif #currentText == 0 then
                codeBox:SetAttribute("RealText", "")
            end
        end)

        makeButton("Verify Code", function()
            local entered = codeBox:GetAttribute("RealText") or ""
            if entered == ULTI_CODE then
                isUltiUnlocked = true
                loadUltiMenu()
                notify("Ulti Cheat freigeschaltet!")
            else
                notify("Falscher Code!")
                codeBox.Text = ""
                codeBox:SetAttribute("RealText", "")
            end
        end)

        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, -12, 0, 40)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = "Make a Ticket for the Code"
        infoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        infoLabel.TextScaled = true
        infoLabel.Font = Enum.Font.GothamBold
        infoLabel.Parent = content

        makeButton("Click to copy Discord Link", function()
            if setclipboard then
                setclipboard(DISCORD)
                notify("Discord Link kopiert!")
            else
                notify(DISCORD)
            end
        end)
    else
        makeButton("Ghost (Durch Wände laufen): " .. (ghostEnabled and "ON" or "OFF"), function(btn)
            ghostEnabled = not ghostEnabled
            btn.Text = "Ghost (Durch Wände laufen): " .. (ghostEnabled and "ON" or "OFF")
            
            if ghostEnabled then
                local ghostConn
                ghostConn = RunService.Stepped:Connect(function()
                    if not ghostEnabled or not scriptRunning then
                        ghostConn:Disconnect()
                        return
                    end
                    if player.Character then
                        for _, part in ipairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                end)
            else
                if player.Character then
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end)

        makeButton("Teleport behind Player: " .. (tpBehindEnabled and "ON" or "OFF"), function(btn)
            playLocalSound(SOUND_ACTION_ID)
            tpBehindEnabled = not tpBehindEnabled
            btn.Text = "Teleport behind Player: " .. (tpBehindEnabled and "ON" or "OFF")
        end)
    end
end
table.insert(connections, ultiTab.MouseButton1Click:Connect(loadUltiMenu))

loadMovementMenu()

-- Versuche beim allerersten Ausführen, die Konfiguration automatisch zu laden (falls vorhanden)
pcall(function() loadSettingsFromFile() end)
