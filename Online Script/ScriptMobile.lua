game:GetService("Players").LocalPlayer.PlayerGui.DraconicHubGui:Destroy()
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Draconic Hub X Evade",
    Text = "Welcome Draconic Hub Remake",
    Duration = 7
})
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Script Loading...",
    Text = "Evade Overhaul",
    Duration = 7
})
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Window = Fluent:CreateWindow({
    Title = "🌟 | Draconic-X-Remake",
    SubTitle = "Overhaul (2.9 Version) Made by Unknownproooolucky",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local FloatingButton = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ksjsowos/29401/refs/heads/main/Online%20Script/FlyBytton.lua",true))()
FloatingButton.init(Window)

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" })
}

local Options = Fluent.Options

Fluent:Notify({
    Title = "Draconic X Evade",
    Content = "System Loaded...",
    Duration = 3
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Billboard ESP Variables
local NextbotBillboards = {}
local nextbotLoop = nil
-- local PlayerBillboards = {} <-- УДАЛЕНО
local TicketBillboards = {}



-- ДОБАВИТЬ ЭТИ СТРОКИ ГДЕ-ТО ПОСЛЕ ТАКИХ ПЕРЕМЕННЫХ:
local ExternalESP = nil
local ExternalESPLoaded = false
local ExternalNextbotESP = nil
local ExternalNextbotESPLoaded = false

-- Функция для принудительной очистки всех ESP объектов
local function forceCleanAllESP()
    print("Запущена принудительная очистка ESP...")
    
    -- 1. Очистка всех GUI объектов в workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            if obj.Name:find("ESP") or obj.Name:find("Nextbot") or obj.Name:find("Billboard") then
                obj:Destroy()
            end
        end
    end
    
    -- 2. Очистка PlayerGui
    local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") or gui:IsA("TextLabel") then
                if gui.Name:find("ESP") or gui.Name:find("Nextbot") then
                    gui:Destroy()
                end
            end
        end
    end
    
    -- 3. Очистка CoreGui
    local coreGui = game:GetService("CoreGui")
    for _, gui in ipairs(coreGui:GetDescendants()) do
        if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
            if gui.Name:find("ESP") or gui.Name:find("Nextbot") then
                gui:Destroy()
            end
        end
    end
    
    -- 4. Очистка всех Drawing объектов
    pcall(function()
        local drawings = {}
        
        -- Ищем все Drawing объекты в окружении
        for _, v in pairs(getgenv() or {}) do
            if type(v) == "table" then
                -- Проверяем, является ли это Drawing объектом
                if v.Visible ~= nil and v.Color ~= nil and v.Thickness ~= nil then
                    table.insert(drawings, v)
                end
            end
        end
        
        -- Удаляем все найденные Drawing объекты
        for _, drawing in ipairs(drawings) do
            if drawing.Remove then
                pcall(function() drawing:Remove() end)
            end
        end
    end)
    
    print("Принудительная очистка ESP завершена")
end

-- Tracer ESP Variables
local playerTracerElements = {}
local botTracerElements = {}
local playerTracerConnection = nil
local botTracerConnection = nil

-- Auto Respawn Variables
local lastSavedPosition = nil
local respawnConnection = nil
local AutoSelfReviveConnection = nil
local hasRevived = false
local SelfReviveMethod = "Spawnpoint"

-- New Feature Variables
local AntiAFKConnection = nil
local autoWhistleHandle = nil
local stableCameraInstance = nil

-- Функция для удаления ТОЛЬКО Player ESP объектов
function cleanUpOnlyPlayerESPObjects()
    local cleaned = 0
    
    print("Cleaning only Player ESP objects...")
    
    -- Очищаем ESP у игроков
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                -- Ищем ВСЕ BillboardGui у персонажа
                for _, obj in pairs(player.Character:GetDescendants()) do
                    if obj:IsA("BillboardGui") then
                        local objName = obj.Name:lower()
                        -- Удаляем ТОЛЬКО Player ESP (не Nextbot ESP)
                        if objName:find("esp") and 
                           not objName:find("nextbot") and 
                           not objName:find("npc") and
                           not objName:find("bot") and
                           not objName:find("enemy") then
                            obj:Destroy()
                            cleaned = cleaned + 1
                            print("Removed Player ESP from " .. player.Name)
                        end
                    end
                end
            end
        end
    end
    
    -- Очищаем GUI объекты только Player ESP
    local guiContainers = {
        game:GetService("CoreGui"),
        LocalPlayer.PlayerGui
    }
    
    for _, container in pairs(guiContainers) do
        for _, gui in pairs(container:GetDescendants()) do
            if gui:IsA("BillboardGui") or gui:IsA("ScreenGui") then
                local guiName = gui.Name:lower()
                -- Удаляем ТОЛЬКО Player ESP GUI
                if (guiName:find("player") or guiName:find("esp")) and 
                   not guiName:find("nextbot") and 
                   not guiName:find("bot") then
                    gui:Destroy()
                    cleaned = cleaned + 1
                end
            end
        end
    end
    
    print("Cleaned " .. cleaned .. " Player ESP objects")
    return cleaned
end

-- Get nextbot names from ReplicatedStorage
local nextBotNames = {}
if ReplicatedStorage:FindFirstChild("NPCs") then
    for _, npc in ipairs(ReplicatedStorage.NPCs:GetChildren()) do
        table.insert(nextBotNames, npc.Name)
    end
end

function isNextbotModel(model)
    if not model or not model.Name then return false end
    for _, name in ipairs(nextBotNames) do
        if model.Name == name then return true end
    end
    return model.Name:lower():find("nextbot") or 
           model.Name:lower():find("scp") or 
           model.Name:lower():find("monster") or
           model.Name:lower():find("creep") or
           model.Name:lower():find("enemy") or
           model.Name:lower():find("zombie") or
           model.Name:lower():find("ghost") or
           model.Name:lower():find("demon")
end

function getDistanceFromPlayer(targetPosition)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return 0 
    end
    local distance = (targetPosition - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    return math.floor(distance)
end



local function scanForTickets()
    -- Если включен внешний Ticket ESP, используем его
    if ExternalTicketESPLoaded and _G.UpdateTicketESP then
        pcall(_G.UpdateTicketESP)
    else
        -- Стандартная логика (резервная)
        local ticketsFound = {}
        
        local gameFolder = workspace:FindFirstChild("Game")
        if gameFolder then
            local effects = gameFolder:FindFirstChild("Effects")
            if effects then
                local tickets = effects:FindFirstChild("Tickets")
                if tickets then
                    for _, ticket in pairs(tickets:GetChildren()) do
                        if ticket:IsA("BasePart") or ticket:IsA("Model") then
                            local part = ticket:IsA("Model") and 
                                       (ticket:FindFirstChild("HumanoidRootPart") or 
                                        ticket:FindFirstChild("Head") or 
                                        ticket.PrimaryPart or 
                                        ticket:FindFirstChildWhichIsA("BasePart")) or 
                                       ticket:IsA("BasePart") and ticket
                            if part then
                                ticketsFound[ticket] = part
                            end
                        end
                    end
                end
            end
        end
        
        -- Очистка старых ESP
        for ticket, data in pairs(TicketBillboards) do
            if not ticketsFound[ticket] or not ticket.Parent then
                if data.esp then
                    data.esp:Destroy()
                end
                TicketBillboards[ticket] = nil
            end
        end
    end
end

-- ==================== TRACER ESP FUNCTIONS ====================

function createTracerObject()
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1
    tracer.ZIndex = 1
    return tracer
end

function updatePlayerTracers()
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local screenBottomCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local currentTargets = {}

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                currentTargets[player] = true
                
                if not playerTracerElements[player] then
                    playerTracerElements[player] = createTracerObject()
                end

                local tracer = playerTracerElements[player]
                local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    tracer.Visible = true
                    tracer.From = screenBottomCenter
                    tracer.To = Vector2.new(vector.X, vector.Y)
                    tracer.Color = Color3.fromRGB(255, 255, 255)
                else
                    tracer.Visible = false
                end
            end
        end
    end

    for player, tracer in pairs(playerTracerElements) do
        if not currentTargets[player] then
            if tracer and tracer.Remove then
                tracer:Remove()
            end
            playerTracerElements[player] = nil
        end
    end
end

function updateBotTracers()
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local screenBottomCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local currentTargets = {}

    local playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if playersFolder then
        for _, model in pairs(playersFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    currentTargets[model] = true
                    
                    if not botTracerElements[model] then
                        botTracerElements[model] = createTracerObject()
                    end

                    local tracer = botTracerElements[model]
                    local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

                    if onScreen then
                        tracer.Visible = true
                        tracer.From = screenBottomCenter
                        tracer.To = Vector2.new(vector.X, vector.Y)
                        tracer.Color = Color3.fromRGB(255, 0, 0)
                    else
                        tracer.Visible = false
                    end
                end
            end
        end
    end

    local npcsFolder = workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, model in pairs(npcsFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    currentTargets[model] = true
                    
                    if not botTracerElements[model] then
                        botTracerElements[model] = createTracerObject()
                    end

                    local tracer = botTracerElements[model]
                    local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

                    if onScreen then
                        tracer.Visible = true
                        tracer.From = screenBottomCenter
                        tracer.To = Vector2.new(vector.X, vector.Y)
                        tracer.Color = Color3.fromRGB(255, 0, 0)
                    else
                        tracer.Visible = false
                    end
                end
            end
        end
    end

    for model, tracer in pairs(botTracerElements) do
        if not currentTargets[model] then
            if tracer and tracer.Remove then
                tracer:Remove()
            end
            botTracerElements[model] = nil
        end
    end
end

function startPlayerTracers()
    if playerTracerConnection then return end
    playerTracerConnection = RunService.RenderStepped:Connect(updatePlayerTracers)
end

function stopPlayerTracers()
    if playerTracerConnection then
        playerTracerConnection:Disconnect()
        playerTracerConnection = nil
    end
    for player, tracer in pairs(playerTracerElements) do
        if tracer and tracer.Remove then
            tracer:Remove()
        end
    end
    playerTracerElements = {}
end

function startBotTracers()
    if botTracerConnection then return end
    botTracerConnection = RunService.RenderStepped:Connect(updateBotTracers)
end

function stopBotTracers()
    if botTracerConnection then
        botTracerConnection:Disconnect()
        botTracerConnection = nil
    end
    for model, tracer in pairs(botTracerElements) do
        if tracer and tracer.Remove then
            tracer:Remove()
        end
    end
    botTracerElements = {}
end

-- ==================== AUTO RESPAWN FUNCTIONS ====================

local function startAutoRespawn()
    if AutoSelfReviveConnection then
        AutoSelfReviveConnection:Disconnect()
    end
    if respawnConnection then
        respawnConnection:Disconnect()
    end
    
    local character = LocalPlayer.Character
    if character then
        AutoSelfReviveConnection = character:GetAttributeChangedSignal("Downed"):Connect(function()
            local isDowned = character:GetAttribute("Downed")
            if isDowned then
                if SelfReviveMethod == "Spawnpoint" then
                    if not hasRevived then
                        hasRevived = true
                        -- УБРАЛ task.wait(3) - теперь мгновенно
                        pcall(function()
                            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                        end)
                        task.delay(0.5, function()
                            hasRevived = false
                        end)
                    end
                elseif SelfReviveMethod == "Fake Revive" then
                    if not hasRevived then
                        hasRevived = true
                        -- Сохраняем позицию
                        local lastPos = nil
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            lastPos = character.HumanoidRootPart.Position
                        end
                        -- УБРАЛ task.wait(3) - теперь мгновенно
                        pcall(function()
                            ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ChangePlayerMode"):FireServer(true)
                        end)
                        -- Мгновенная телепортация
                        task.spawn(function()
                            for i = 1, 10 do
                                local newChar = LocalPlayer.Character
                                if newChar and newChar ~= character then
                                    local newHRP = newChar:FindFirstChild("HumanoidRootPart")
                                    if newHRP and lastPos then
                                        newHRP.CFrame = CFrame.new(lastPos)
                                        break
                                    end
                                end
                                task.wait(0.05)
                            end
                        end)
                        task.delay(0.5, function()
                            hasRevived = false
                        end)
                    end
                end
            end
        end)
    end
    
    respawnConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.5)
        local newHumanoid = newChar:WaitForChild("Humanoid")
        local newHRP = newChar:WaitForChild("HumanoidRootPart")
        
        AutoSelfReviveConnection = newChar:GetAttributeChangedSignal("Downed"):Connect(function()
            local isDowned = newChar:GetAttribute("Downed")
            if isDowned then
                if SelfReviveMethod == "Spawnpoint" then
                    if not hasRevived then
                        hasRevived = true
                        pcall(function()
                            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                        end)
                        task.delay(0.5, function()
                            hasRevived = false
                        end)
                    end
                elseif SelfReviveMethod == "Fake Revive" then
                    if not hasRevived then
                        hasRevived = true
                        local lastPos = nil
                        if newHRP then
                            lastPos = newHRP.Position
                        end
                        pcall(function()
                            ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ChangePlayerMode"):FireServer(true)
                        end)
                        task.spawn(function()
                            for i = 1, 10 do
                                local freshChar = LocalPlayer.Character
                                if freshChar and freshChar ~= newChar then
                                    local freshHRP = freshChar:FindFirstChild("HumanoidRootPart")
                                    if freshHRP and lastPos then
                                        freshHRP.CFrame = CFrame.new(lastPos)
                                        break
                                    end
                                end
                                task.wait(0.05)
                            end
                        end)
                        task.delay(0.5, function()
                            hasRevived = false
                        end)
                    end
                end
            end
        end)
    end)
end

local function stopAutoRespawn()
    if AutoSelfReviveConnection then
        AutoSelfReviveConnection:Disconnect()
        AutoSelfReviveConnection = nil
    end
    if respawnConnection then
        respawnConnection:Disconnect()
        respawnConnection = nil
    end
    hasRevived = false
    lastSavedPosition = nil
end

-- ==================== NEW FEATURES ====================

-- Anti AFK Functions
local function startAntiAFK()
    if AntiAFKConnection then return end
    AntiAFKConnection = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

local function stopAntiAFK()
    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end
end

-- Auto Whistle Functions
local function startAutoWhistle()
    if autoWhistleHandle then 
        stopAutoWhistle() 
    end
    
    autoWhistleHandle = task.spawn(function()
        while true do
            if not AutoWhistleToggle.Value then break end
            
            pcall(function() 
                local success, result = pcall(function()
                    return ReplicatedStorage.Events.Character.Whistle:FireServer()
                end)
                if not success then
                    warn("Auto Whistle Error:", result)
                end
            end)
            
            task.wait(1)
        end
        autoWhistleHandle = nil
    end)
end

local function stopAutoWhistle()
    if autoWhistleHandle then
        local handle = autoWhistleHandle
        autoWhistleHandle = nil
        
        -- Альтернативный способ остановки
        pcall(function()
            -- Попробуем отменить задачу
            if type(handle) == "table" and handle.cancel then
                handle:cancel()
            end
        end)
    end
end

-- No Camera Shake Functions
local StableCamera = {}
StableCamera.__index = StableCamera

function StableCamera.new(maxDistance)
    local self = setmetatable({}, StableCamera)
    self.Player = Players.LocalPlayer
    self.MaxDistance = maxDistance or 50
    self._conn = RunService.RenderStepped:Connect(function(dt) self:Update(dt) end)
    return self
end

local function tryResetShake(player)
    if not player then return end
    local ok, playerScripts = pcall(function() return player:FindFirstChild("PlayerScripts") end)
    if not ok or not playerScripts then return end
    local cameraSet = playerScripts:FindFirstChild("Camera") and playerScripts.Camera:FindFirstChild("Set")
    if cameraSet and type(cameraSet.Invoke) == "function" then
        pcall(function()
            cameraSet:Invoke("CFrameOffset", "Shake", CFrame.new())
        end)
    end
end

function StableCamera:Update(dt)
    if Players and Players.LocalPlayer then
        tryResetShake(Players.LocalPlayer)
    end
end

function StableCamera:Destroy()
    if self._conn then
        self._conn:Disconnect()
        self._conn = nil
    end
end

local function startNoCameraShake()
    if stableCameraInstance then return end
    stableCameraInstance = StableCamera.new()
end

local function stopNoCameraShake()
    if stableCameraInstance then
        stableCameraInstance:Destroy()
        stableCameraInstance = nil
    end
end

-- ==================== FLUENT UI SECTIONS ====================

-- Billboard ESP Section
 billboardSection = Tabs.Main:AddSection("Billboard ESP")

 NextbotToggle = Tabs.Main:AddToggle("NextbotToggle", {
    Title = "ESP Nextbots",
    Default = false
})

 PlayerToggle = Tabs.Main:AddToggle("PlayerToggle", {
    Title = "ESP Players",
    Default = false
})

 TicketToggle = Tabs.Main:AddToggle("TicketToggle", {
    Title = "ESP Tickets",
    Default = false
})

-- ==================== LOAD HIGHLIGHT DOWNED PLAYERS MODULE ====================
-- Добавляем тумблер в секцию Main (после TicketToggle)
local highlightSection = Tabs.Main:AddSection("Highlight")

local HighlightDownedPlayers = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ksjsowos/29401/refs/heads/main/Online%20Script/HighlightPlayers.lua"))()
HighlightDownedPlayers:Init(Fluent, Options)

HighlightDownedToggle = Tabs.Main:AddToggle("HighlightDownedToggle", {
    Title = "Highlight Players",
    Default = false,
    Callback = function(value)
        if value then
            HighlightDownedPlayers:Start()
        else
            HighlightDownedPlayers:Stop()
        end
    end
})

-- ==================== LOAD HIGHLIGHT BOTS MODULE ====================
local HighlightBots = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ksjsowos/29401/refs/heads/main/Online%20Script/HighlightBots.lua"))()
HighlightBots:Init(Fluent, Options)

-- Добавляем тумблер в секцию Main (после HighlightDownedToggle)
HighlightBotsToggle = Tabs.Main:AddToggle("HighlightBotsToggle", {
    Title = "Highlight Bots",
    Default = false,
    Callback = function(value)
        if value then
            HighlightBots:Start()
        else
            HighlightBots:Stop()
        end
    end
})

-- Автоматическое восстановление при респавне или загрузке новой карты
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    if HighlightBotsToggle and HighlightBotsToggle.Value then
        HighlightBots:Refresh()
    end
end)

-- Также обновляем при изменении карты (если нужно)
workspace.ChildAdded:Connect(function(child)
    task.wait(1)
    if child.Name == "Game" and HighlightBotsToggle and HighlightBotsToggle.Value then
        HighlightBots:Refresh()
    end
end)

-- Автоматическое восстановление при респавне
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if HighlightDownedToggle and HighlightDownedToggle.Value then
        HighlightDownedPlayers:Refresh()
    end
end)

-- Tracer ESP Section
 tracerSection = Tabs.Main:AddSection("Tracer ESP")

 TracerPlayerToggle = Tabs.Main:AddToggle("TracerPlayerToggle", {
    Title = "Tracer Players",
    Default = false
})

 TracerBotToggle = Tabs.Main:AddToggle("TracerBotToggle", {
    Title = "Tracer Bots",
    Default = false
})

-- Main Modification Section
 modificationSection = Tabs.Main:AddSection("Respawn")

 AutoRespawnTypeDropdown = Tabs.Main:AddDropdown("AutoRespawnTypeDropdown", {
    Title = "Auto Respawn Type",
    Values = {"Spawnpoint", "Fake Revive"},
    Multi = false,
    Default = "Spawnpoint",
})

RespawnButton = Tabs.Main:AddButton({
    Title = "Respawn Button",
    Callback = function()
        local CoreGui = game:GetService("CoreGui")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        local existingScreenGui = CoreGui:FindFirstChild("DraconicRespawnButtonGUI")
        
        if existingScreenGui then
            existingScreenGui:Destroy()
        else
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "DraconicRespawnButtonGUI"
            screenGui.ResetOnSpawn = false
            screenGui.Parent = CoreGui

local function createGradientButton(parent, position, size, text, onClickCallback)
    local button = Instance.new("Frame")
    button.Name = "GradientBtn"
    button.BackgroundTransparency = 0.7
    button.Size = size
    button.Position = position
    button.Draggable = true
    button.Active = true
    button.Selectable = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    gradient.Rotation = 0
    gradient.Parent = button

    local gradientAnimation
    gradientAnimation = RunService.RenderStepped:Connect(function(delta)
        gradient.Rotation = (gradient.Rotation + 90 * delta) % 360
    end)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(139, 0, 0)  -- Темно-красный (обычное состояние)
    stroke.Thickness = 2
    stroke.Parent = button

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.Parent = button

    local clicker = Instance.new("TextButton")
    clicker.Size = UDim2.new(1, 0, 1, 0)
    clicker.BackgroundTransparency = 1
    clicker.Text = ""
    clicker.ZIndex = 5
    clicker.Parent = button

    button.Destroying:Connect(function()
        if gradientAnimation then
            gradientAnimation:Disconnect()
        end
    end)

    -- ==================== ПЕРЕТАСКИВАНИЕ С ЗАЩИТОЙ ОТ МУЛЬТИТАЧ ====================
    local UserInputService = game:GetService("UserInputService")
    local activeTouchId = nil  -- ID активного пальца
    local startPos = nil
    local startButtonPos = nil
    
    -- Функция для обновления позиции кнопки
    local function updateButtonPosition(touchPos)
        if not startPos or not startButtonPos then return end
        local delta = touchPos - startPos
        button.Position = UDim2.new(startButtonPos.X.Scale, startButtonPos.X.Offset + delta.X,
                                    startButtonPos.Y.Scale, startButtonPos.Y.Offset + delta.Y)
    end
    
    -- Сброс состояния
    local function resetDrag()
        activeTouchId = nil
        startPos = nil
        startButtonPos = nil
        stroke.Color = Color3.fromRGB(139, 0, 0)  -- Возвращаем темно-красный
    end
    
    -- Начало касания (мобильные устройства)
    clicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local touchId = input.UserInputState
            
            -- Если уже есть активный палец - игнорируем остальные
            if activeTouchId ~= nil then
                return
            end
            
            activeTouchId = touchId
            startPos = input.Position
            startButtonPos = button.Position
            
            -- Меняем цвет на ярко-красный при нажатии
            stroke.Color = Color3.fromRGB(255, 0, 0)
            
            -- Обработка окончания касания
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resetDrag()
                    connection:Disconnect()
                end
            end)
            
        -- Для мыши
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            if activeTouchId ~= nil then return end
            
            activeTouchId = "mouse"
            startPos = input.Position
            startButtonPos = button.Position
            
            stroke.Color = Color3.fromRGB(255, 0, 0)
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resetDrag()
                    connection:Disconnect()
                end
            end)
        end
    end)

    -- Обработка движения пальца/мыши
    clicker.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            if activeTouchId ~= nil then
                updateButtonPosition(input.Position)
            end
        elseif input.UserInputType == Enum.UserInputType.MouseMovement then
            if activeTouchId ~= nil then
                updateButtonPosition(input.Position)
            end
        end
    end)

    return button, clicker, stroke
end
            
            local buttonSize = 190
            if Options.RespawnButtonSizeInput and Options.RespawnButtonSizeInput.Value and tonumber(Options.RespawnButtonSizeInput.Value) then
                buttonSize = tonumber(Options.RespawnButtonSizeInput.Value)
            end
            
            local btnWidth = math.max(150, math.min(buttonSize, 400))
            local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
            
            local btn, clicker, stroke = createGradientButton(
                screenGui,
                UDim2.new(0.5, -btnWidth/2, 0.5, -btnHeight/2),
                UDim2.new(0, btnWidth, 0, btnHeight),
                "RESPAWN"
            )
            clicker.MouseButton1Click:Connect(function()
                  manualRevive()
            end)
        end
    end
})

 RespawnButtonSizeInput = Tabs.Main:AddInput("RespawnButtonSizeInput", {
    Title = "Button Size",
    Default = "190",
    Placeholder = "Enter size (150-400)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local size = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("DraconicRespawnButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local newWidth = math.max(150, math.min(size, 400))
                    local newHeight = math.max(60, math.min(size * 0.4, 160))
                    button.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end
        end
    end
})

modificationSection = Tabs.Main:AddSection("Things")

-- New Features Section

 AntiAFKToggle = Tabs.Main:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK",
    Default = false
})

 AutoWhistleToggle = Tabs.Main:AddToggle("AutoWhistleToggle", {
    Title = "Auto Whistle",
    Default = false
})

 NoCameraShakeToggle = Tabs.Main:AddToggle("NoCameraShakeToggle", {
    Title = "No Camera Shake",
    Default = false
})

-- ==================== TOGGLE HANDLERS ====================

NextbotToggle:OnChanged(function(value)
    if value then
        -- Загружаем внешний Nextbot ESP
        if not ExternalNextbotESPLoaded then
            local success, errorMsg = pcall(function()
                ExternalNextbotESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ksjsowos/29401/refs/heads/main/Test%20Script/NextbotESP.lua"))()
                ExternalNextbotESPLoaded = true
                
                _G.NextbotESPRunning = true
                
                if ExternalNextbotESP and ExternalNextbotESP.Start then
                    ExternalNextbotESP.Start()
                end
                
                Fluent:Notify({
                    Title = "ESP Nextbots",
                    Content = "External Nextbot ESP loaded and running!",
                    Duration = 3
                })
            end)
            
            if not success then
                Fluent:Notify({
                    Title = "ESP Nextbots Error",
                    Content = "Failed to load external Nextbot ESP: " .. tostring(errorMsg),
                    Duration = 5
                })
                Options.NextbotToggle:Set(false)
                return
            end
        else
            if ExternalNextbotESP and ExternalNextbotESP.Start then
                ExternalNextbotESP.Start()
            end
            _G.NextbotESPRunning = true
        end
        
        -- Запускаем loop проверки
        if not nextbotLoop then
            nextbotLoop = RunService.Heartbeat:Connect(function()
                if Options.NextbotToggle.Value then
                    if _G.NextbotESPRunning == false then
                        _G.NextbotESPRunning = true
                        if ExternalNextbotESP and ExternalNextbotESP.Start then
                            pcall(ExternalNextbotESP.Start)
                        end
                    end
                end
            end)
        end
        
    else
        -- ВАЖНО: СНАЧАЛА останавливаем проверку, ПОТОМ отключаем ESP
        if nextbotLoop then
            nextbotLoop:Disconnect()
            nextbotLoop = nil
        end
        
        -- Отключаем ESP (только Nextbot ESP)
        if ExternalNextbotESP and ExternalNextbotESPLoaded then
            if ExternalNextbotESP.Stop then
                pcall(function()
                    ExternalNextbotESP.Stop()
                end)
            end
        end
        
        -- Очищаем только Nextbot ESP объекты
        task.spawn(function()
            task.wait(0.2)
            
            -- Очищаем только Nextbot Billboard ESP
            for model, data in pairs(NextbotBillboards) do
                if data.esp and data.esp:IsDescendantOf(game) then
                    local espName = data.esp.Name:lower()
                    if espName:find("nextbot") or espName:find("bot") or espName:find("npc") then
                        data.esp:Destroy()
                    end
                end
            end
            NextbotBillboards = {}
            
            -- Очищаем только Nextbot Tracer ESP
            for model, tracer in pairs(botTracerElements) do
                if tracer and tracer.Remove then
                    pcall(function()
                        tracer:Remove()
                    end)
                end
            end
            botTracerElements = {}
            
            -- Очищаем только Nextbot Drawing объекты
            pcall(function()
                for _, drawing in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
                    if drawing:IsA("BillboardGui") and drawing.Name:find("Nextbot") then
                        drawing:Destroy()
                    end
                end
                
                -- Очищаем red tracers (боты)
                for _, obj in pairs(getgc(true)) do
                    if type(obj) == "table" then
                        if obj.__type and obj.__type == "Drawing" and obj.Color then
                            -- Красный цвет = Bot Tracer
                            if obj.Color.r == 1 and obj.Color.g == 0 and obj.Color.b == 0 then
                                if obj.Remove then
                                    pcall(obj.Remove, obj)
                                end
                            end
                        end
                    end
                end
            end)
        end)
        
        -- Очищаем только Nextbot ESP переменные
        ExternalNextbotESPLoaded = false
        _G.NextbotESPRunning = false
        
        Fluent:Notify({
            Title = "ESP Nextbots",
            Content = "Nextbot ESP disabled!",
            Duration = 3
        })
    end
end)

PlayerToggle:OnChanged(function(value)
    if value then
        -- Очищаем только Player ESP перед загрузкой
        cleanUpOnlyPlayerESPObjects()
        
        -- Проверяем, включен ли Nextbot ESP
        local nextbotESPActive = Options.NextbotToggle and Options.NextbotToggle.Value
        
        -- Загружаем внешний ESP
        if not ExternalESPLoaded then
            local success, errorMsg = pcall(function()
                -- Загружаем внешний ESP
                local espScript = game:HttpGet("https://raw.githubusercontent.com/Ksjsowos/29401/refs/heads/main/Test%20Script/Esp.lua", true)
                
                -- Добавляем защиту от дублирования в загружаемый скрипт
                espScript = [[
                    -- Защита от дублирования
                    if _G.PlayerESP_Loaded == true then
                        return
                    end
                    _G.PlayerESP_Loaded = true
                    
                    -- Очистка старых Player ESP
                    local function cleanOldPlayerESP()
                        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                            if player ~= game:GetService("Players").LocalPlayer then
                                if player.Character then
                                    local esp = player.Character:FindFirstChild("PlayerESP")
                                    if esp then
                                        esp:Destroy()
                                    end
                                end
                            end
                        end
                    end
                    cleanOldPlayerESP()
                    
                ]] .. espScript
                
                ExternalESP = loadstring(espScript)()
                ExternalESPLoaded = true
                
                -- Гарантируем, что ESP работает
                _G.ExternalESPRunning = true
                _G.PlayerESP_Loaded = true
                
                Fluent:Notify({
                    Title = "ESP Players",
                    Content = "Player ESP loaded!",
                    Duration = 3
                })
            end)
            
            if not success then
                Fluent:Notify({
                    Title = "ESP Players Error",
                    Content = "Failed to load ESP: " .. tostring(errorMsg),
                    Duration = 5
                })
                Options.PlayerToggle:Set(false)
                return
            end
        else
            -- Если уже загружен, просто включаем
            _G.ExternalESPRunning = true
            _G.PlayerESP_Loaded = true
        end
        
        -- Восстанавливаем Nextbot ESP если он был включен
        if nextbotESPActive then
            task.wait(0.5)
            if ExternalNextbotESP and ExternalNextbotESPLoaded and ExternalNextbotESP.Start then
                pcall(ExternalNextbotESP.Start)
            end
        end
        
        -- Запускаем мониторинг
        if not playerLoop then
            playerLoop = RunService.Heartbeat:Connect(function()
                if Options.PlayerToggle.Value then
                    -- Проверяем, не дублируется ли текст ESP
                    local playerEspCount = 0
                    
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            -- Ищем все BillboardGui у игрока
                            for _, obj in pairs(player.Character:GetDescendants()) do
                                if obj:IsA("BillboardGui") then
                                    local textLabels = obj:GetDescendants()
                                    local labelCount = 0
                                    for _, label in pairs(textLabels) do
                                        if label:IsA("TextLabel") then
                                            labelCount = labelCount + 1
                                        end
                                    end
                                    
                                    -- Если у одного BillboardGui несколько TextLabel, это дублирование
                                    if labelCount > 3 then
                                        obj:Destroy()
                                        playerEspCount = playerEspCount + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        
    else
        -- Останавливаем loop
        if playerLoop then
            playerLoop:Disconnect()
            playerLoop = nil
        end
        
        -- Очищаем только Player ESP
        cleanUpOnlyPlayerESPObjects()
        
        -- Останавливаем внешний ESP
        if ExternalESP and ExternalESPLoaded then
            if type(ExternalESP) == "table" and ExternalESP.Stop then
                pcall(ExternalESP.Stop)
            end
        end
        
        -- Сбрасываем переменные Player ESP
        _G.ExternalESPRunning = false
        _G.PlayerESP_Loaded = false
        ExternalESPLoaded = false
        
        Fluent:Notify({
            Title = "ESP Players",
            Content = "Player ESP disabled!",
            Duration = 3
        })
    end
end)

TicketToggle:OnChanged(function(value)
    if value then
        -- Загружаем внешний Ticket ESP
        if not ExternalTicketESPLoaded then
            local success, errorMsg = pcall(function()
                -- Загружаем внешний Ticket ESP
                ExternalTicketESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ksjsowos/29401/refs/heads/main/Online%20Script/TicketESP.lua"))()
                ExternalTicketESPLoaded = true
                
                -- Гарантируем, что ESP работает
                _G.TicketESPRunning = true
                
                Fluent:Notify({
                    Title = "ESP Tickets",
                    Content = "External Ticket ESP loaded!",
                    Duration = 3
                })
            end)
            
            if not success then
                Fluent:Notify({
                    Title = "ESP Tickets Error",
                    Content = "Failed to load external Ticket ESP: " .. tostring(errorMsg),
                    Duration = 5
                })
            end
        else
            -- Если уже загружен, включаем
            _G.TicketESPRunning = true
        end
        
        -- Запускаем loop
        if not ticketLoop then
            ticketLoop = RunService.RenderStepped:Connect(function()
                if Options.TicketToggle.Value then
                    scanForTickets()
                end
            end)
        end
    else
        -- Отключаем внешний Ticket ESP
        if ExternalTicketESPLoaded then
            if _G.StopTicketESP then
                pcall(_G.StopTicketESP)
            end
        end
        
        -- Останавливаем loop
        if ticketLoop then
            ticketLoop:Disconnect()
            ticketLoop = nil
        end
        
        -- Очищаем стандартные ESP
        for ticket, data in pairs(TicketBillboards) do
            if data.esp then
                data.esp:Destroy()
            end
        end
        TicketBillboards = {}
        
        ExternalTicketESPLoaded = false
        _G.TicketESPRunning = false
        
        Fluent:Notify({
            Title = "ESP Tickets",
            Content = "Ticket ESP disabled!",
            Duration = 3
        })
    end
end)

-- Tracer ESP Toggle Handlers
TracerPlayerToggle:OnChanged(function(value)
    if value then
        startPlayerTracers()
    else
        stopPlayerTracers()
    end
end)

TracerBotToggle:OnChanged(function(value)
    if value then
        startBotTracers()
    else
        stopBotTracers()
    end
end)


AutoRespawnTypeDropdown:OnChanged(function(value)
    SelfReviveMethod = value
end)

-- New Features Toggle Handlers
AntiAFKToggle:OnChanged(function(value)
    if value then
        startAntiAFK()
    else
        stopAntiAFK()
    end
end)

AutoWhistleToggle:OnChanged(function(value)
    if value then
        startAutoWhistle()
    else
        stopAutoWhistle()
    end
end)

NoCameraShakeToggle:OnChanged(function(value)
    if value then
        startNoCameraShake()
    else
        stopNoCameraShake()
    end
end)

-- ==================== SAVE MANAGER ====================

local TimerDisplayToggle = Tabs.Main:AddToggle("TimerDisplayToggle", {
    Title = "Show Timer",
    Default = false
})

local timerDisplayLoop = nil

TimerDisplayToggle:OnChanged(function(state)
    if state then
        if timerDisplayLoop then return end
        
        timerDisplayLoop = RunService.RenderStepped:Connect(function()
            local player = game:GetService("Players").LocalPlayer
            local pg = player.PlayerGui
            
            -- Find the timer display in the game's UI
            local shared = pg:FindFirstChild("Shared")
            local hud = shared and shared:FindFirstChild("HUD")
            local overlay = hud and hud:FindFirstChild("Overlay")
            local default = overlay and overlay:FindFirstChild("Default")
            local ro = default and default:FindFirstChild("RoundOverlay")
            local round = ro and ro:FindFirstChild("Round")
            local timer = round and round:FindFirstChild("RoundTimer")
            
            if timer then
                timer.Visible = true
            end
            
            local main = pg:FindFirstChild("MainInterface")
            if main then
                local container = main:FindFirstChild("TimerContainer")
                if container then
                    container.Visible = true
                end
            end
        end)
    else
        if timerDisplayLoop then
            timerDisplayLoop:Disconnect()
            timerDisplayLoop = nil
        end
        
        local player = game:GetService("Players").LocalPlayer
        local pg = player.PlayerGui
        
        local shared = pg:FindFirstChild("Shared")
        local hud = shared and shared:FindFirstChild("HUD")
        local overlay = hud and hud:FindFirstChild("Overlay")
        local default = overlay and overlay:FindFirstChild("Default")
        local ro = default and default:FindFirstChild("RoundOverlay")
        local round = ro and ro:FindFirstChild("Round")
        local timer = round and round:FindFirstChild("RoundTimer")
        
        if timer then
            timer.Visible = false
        end
        
        local main = pg:FindFirstChild("MainInterface")
        if main then
            local container = main:FindFirstChild("TimerContainer")
            if container then
                container.Visible = false
            end
        end
    end
end)
local billboardSection = Tabs.Main:AddSection("Player Modification")
-- who needs noclip on evade lol it's not even work 
 FlyToggle = Tabs.Main:AddToggle("FlyToggle", {
    Title = "Fly",
    Default = false
})

 FlySpeedInput = Tabs.Main:AddInput("FlySpeedInput", {
    Title = "Fly Speed",
    Default = "50",
    Placeholder = "Enter speed value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            featureStates.FlySpeed = tonumber(Value)
        end
    end
})

-- Fly variables
local flying = false
local bodyVelocity = nil
local bodyGyro = nil
local character = LocalPlayer.Character
local humanoid = character and character:FindFirstChild("Humanoid")
local rootPart = character and character:FindFirstChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")

-- Initialize fly speed
featureStates = featureStates or {}
featureStates.FlySpeed = 50

local function startFlying()
    if not character or not humanoid or not rootPart then 
        -- Try to get fresh references
        character = LocalPlayer.Character
        if not character then return end
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end
    end
    
    flying = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    humanoid.PlatformStand = true
end

local function stopFlying()
    flying = false
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    if humanoid then
        humanoid.PlatformStand = false
    end
end

local function updateFly()
    if not flying or not bodyVelocity or not bodyGyro then return end
    local camera = workspace.CurrentCamera
    local cameraCFrame = camera.CFrame
    local direction = Vector3.new(0, 0, 0)
    local moveDirection = humanoid.MoveDirection
    
    if moveDirection.Magnitude > 0 then
        local forwardVector = cameraCFrame.LookVector
        local rightVector = cameraCFrame.RightVector
        local forwardComponent = moveDirection:Dot(forwardVector) * forwardVector
        local rightComponent = moveDirection:Dot(rightVector) * rightVector
        direction = direction + (forwardComponent + rightComponent).Unit * moveDirection.Magnitude
    end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump then
        direction = direction + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        direction = direction - Vector3.new(0, 1, 0)
    end
    
    local speed = featureStates.FlySpeed or 50
    bodyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * (speed * 2) or Vector3.new(0, 0, 0)
    bodyGyro.CFrame = cameraCFrame
end

-- Fly loop connection
local flyLoop = nil

-- Character changed event to update references
local characterAddedConnection = nil

FlyToggle:OnChanged(function(state)
    if state then
        -- Set up character tracking
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
        end
        
        characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
            character = newChar
            task.wait(0.5)
            humanoid = character:WaitForChild("Humanoid")
            rootPart = character:WaitForChild("HumanoidRootPart")
            
            -- Restart flying if it was enabled
            if Options.FlyToggle.Value and flying == false then
                startFlying()
            end
        end)
        
        -- Get current character
        character = LocalPlayer.Character
        if character then
            humanoid = character:FindFirstChild("Humanoid")
            rootPart = character:FindFirstChild("HumanoidRootPart")
        end
        
        startFlying()
        
        -- Start update loop
        if not flyLoop then
            flyLoop = RunService.RenderStepped:Connect(function()
                if Options.FlyToggle.Value then
                    updateFly()
                end
            end)
        end
    else
        stopFlying()
        
        if flyLoop then
            flyLoop:Disconnect()
            flyLoop = nil
        end
        
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
            characterAddedConnection = nil
        end
    end
end)

-- Make sure to disconnect everything when script ends
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if Options.FlyToggle.Value then
        stopFlying()
        if flyLoop then
            flyLoop:Disconnect()
            flyLoop = nil
        end
    end
end)

modificationSection = Tabs.Main:AddSection("Manual")

 function manualRevive()
    local player = game:GetService("Players").LocalPlayer
    
    -- ПРАВИЛЬНЫЙ путь к персонажу в Evade
    local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if not gamePlayers then return end
    
    local character = gamePlayers:FindFirstChild(player.Name)
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local isDowned = character:GetAttribute("Downed")
    
    if not isDowned then 
        return 
    end
    
    local SelfReviveMethod = Options.AutoRespawnTypeDropdown and Options.AutoRespawnTypeDropdown.Value or "Spawnpoint"
    
    if SelfReviveMethod == "Spawnpoint" then
        pcall(function()
            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
        end)
        
    elseif SelfReviveMethod == "Fake Revive" then
        -- Сохраняем позицию ИЗ ПРАВИЛЬНОГО МЕСТА
        local lastSavedPosition = nil
        if hrp then
            lastSavedPosition = hrp.Position
        end
        
        -- Респавн
        pcall(function()
            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
        end)
        
        -- Ждем появления нового персонажа и телепортируем
        task.spawn(function()
            for i = 1, 30 do
                task.wait(0.05)
                local newGamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
                if newGamePlayers then
                    local newCharacter = newGamePlayers:FindFirstChild(player.Name)
                    if newCharacter and newCharacter ~= character then
                        local newHRP = newCharacter:FindFirstChild("HumanoidRootPart")
                        if newHRP and lastSavedPosition then
                            newHRP.CFrame = CFrame.new(lastSavedPosition)
                            newHRP.Velocity = Vector3.new(0, 0, 0)
                            break
                        end
                    end
                end
            end
        end)
    end
end

-- ==================== NO CLIP FUNCTIONALITY ====================

-- Add Noclip toggle to the Manual section
NoclipToggle = Tabs.Main:AddToggle("NoclipToggle", {
    Title = "Noclip",
    Default = false
})

-- Noclip variables
local noclipEnabled = false
local noclipConnection = nil

-- Function to toggle noclip
local function toggleNoclip(state)
    noclipEnabled = state
    
    if noclipEnabled then
        -- Start noclip
        if noclipConnection then
            noclipConnection:Disconnect()
        end
        
        noclipConnection = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        Fluent:Notify({
            Title = "Noclip",
            Content = "Noclip enabled",
            Duration = 2
        })
    else
        -- Stop noclip
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        -- Restore collision
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        
        Fluent:Notify({
            Title = "Noclip",
            Content = "Noclip disabled",
            Duration = 2
        })
    end
end

-- Connect toggle handler
NoclipToggle:OnChanged(function(value)
    toggleNoclip(value)
end)

-- Ensure noclip is disabled when character respawns and re-enabled if needed
LocalPlayer.CharacterAdded:Connect(function(character)
    if noclipEnabled then
        task.wait(0.5) -- Wait for character to fully load
        toggleNoclip(false) -- Temporarily disable
        task.wait(0.1)
        toggleNoclip(true) -- Re-enable
    end
end)

-- Cleanup on script end
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end)

-- Make sure noclip is off when script starts
toggleNoclip(false)

-- Sit Toggle
SitToggle = Tabs.Main:AddToggle("SitToggle", {
    Title = "Bug Emote",
    Default = false
})

-- Sit variables
local sitLoopConnection = nil
local player = game:GetService("Players").LocalPlayer

local function updateSit()
    if not SitToggle.Value then return end
    
    local character = player.Character
    if not character then return end
    
    -- Ищем Humanoid в персонаже игрока (workspace.Game.Players.LocalPlayer.Humanoid)
    -- Примечание: Humanoid может находиться либо в самом character, либо в workspace.Game.Players.[Name]
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- Если не нашли в character, ищем в workspace.Game.Players
    if not humanoid then
        local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
        if gamePlayers then
            local playerModel = gamePlayers:FindFirstChild(player.Name)
            if playerModel then
                humanoid = playerModel:FindFirstChild("Humanoid")
            end
        end
    end
    
    if humanoid then
        humanoid.Sit = true
    end
end

SitToggle:OnChanged(function(state)
    if state then
        -- Включаем
        if sitLoopConnection then
            sitLoopConnection:Disconnect()
        end
        
        -- Запускаем постоянное обновление (на случай если Humanoid пересоздается или сбрасывается)
        sitLoopConnection = game:GetService("RunService").Heartbeat:Connect(updateSit)
        
        -- Применяем сразу
        updateSit()
        
        Fluent:Notify({
            Title = "Force Sit",
            Content = "Character will now sit continuously",
            Duration = 2
        })
    else
        -- Отключаем
        if sitLoopConnection then
            sitLoopConnection:Disconnect()
            sitLoopConnection = nil
        end
        
        -- Возвращаем в обычное состояние
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then
                local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
                if gamePlayers then
                    local playerModel = gamePlayers:FindFirstChild(player.Name)
                    if playerModel then
                        humanoid = playerModel:FindFirstChild("Humanoid")
                    end
                end
            end
            if humanoid then
                humanoid.Sit = false
            end
        end
        
        Fluent:Notify({
            Title = "Force Sit",
            Content = "Sit mode disabled",
            Duration = 2
        })
    end
end)

-- Обработка смены персонажа
player.CharacterAdded:Connect(function()
    task.wait(1) -- Ждем загрузки персонажа
    if SitToggle and SitToggle.Value then
        updateSit()
    end
end)

-- Обработка удаления персонажа
player.CharacterRemoving:Connect(function()
    if sitLoopConnection then
        sitLoopConnection:Disconnect()
        sitLoopConnection = nil
    end
end)

-- ==================== NO COLLISION TOGGLE ====================
-- Добавляем после существующих элементов в Manual секцию
NoCollisionToggle = Tabs.Main:AddToggle("NoCollisionToggle", {
    Title = "Remove Barriers",
    Default = false
})

-- Функция для отключения/включения Collision и Query
local function toggleInvisPartsCollision(state)
    local invisParts = workspace:FindFirstChild("Game") and 
                      workspace.Game:FindFirstChild("Map") and 
                      workspace.Game.Map:FindFirstChild("InvisParts")
    
    if not invisParts then
        Fluent:Notify({
            Title = "Remove Barriers",
            Content = "InvisParts folder not found!",
            Duration = 3
        })
        return
    end
    
    local objectsChanged = 0
    
    -- Обрабатываем все дочерние объекты
    for _, obj in ipairs(invisParts:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = not state -- Если state = true, отключаем коллизию
            obj.CanQuery = not state   -- Также отключаем CanQuery
            objectsChanged = objectsChanged + 1
        end
    end
    
    Fluent:Notify({
        Title = "Remove Barriers",
        Content = string.format("%s collision and query for %d objects", 
            state and "Disabled" or "Enabled", 
            objectsChanged),
        Duration = 3
    })
    
    print(string.format("[No Collision] %s CanCollide и CanQuery для %d объектов в InvisParts", 
        state and "Отключил" or "Включил", 
        objectsChanged))
end

-- Обработчик изменения состояния тумблера
NoCollisionToggle:OnChanged(function(state)
    toggleInvisPartsCollision(state)
    
    -- Мониторинг новых объектов, добавленных в InvisParts
    if state then
        -- Если нужно отслеживать новые объекты, добавьте здесь код
        -- Например, connection = invisParts.DescendantAdded:Connect(function(obj)...)
    else
        -- Отключить соединения для мониторинга, если они были добавлены
    end
end)

-- Также обрабатываем респавн персонажа (на случай если нужно сбросить состояние)
LocalPlayer.CharacterAdded:Connect(function()
    if Options.NoCollisionToggle and Options.NoCollisionToggle.Value then
        -- Небольшая задержка чтобы все успело загрузиться
        task.wait(1)
        toggleInvisPartsCollision(true)
    end
end)

-- ==================== INVISIBLE PARTS TRANSPARENCY TOGGLE ====================
-- Тумблер для прозрачности InvisParts
InvisPartsTransparencyToggle = Tabs.Main:AddToggle("InvisPartsTransparencyToggle", {
    Title = "Barriers Visible",
    Default = false
})

-- Функция для изменения прозрачности
local function setInvisPartsTransparency(transparent)
    local invisParts = workspace:FindFirstChild("Game") and 
                      workspace.Game:FindFirstChild("Map") and 
                      workspace.Game.Map:FindFirstChild("InvisParts")
    
    if not invisParts then
        Fluent:Notify({
            Title = "Barriers Visible",
            Content = "InvisParts folder not found!",
            Duration = 3
        })
        return
    end
    
    local changed = 0
    
    if transparent then
        -- Устанавливаем Transparency = 0
        for _, obj in ipairs(invisParts:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Decal") then
                obj.Transparency = 0
                changed = changed + 1
            end
        end
        
        Fluent:Notify({
            Title = "Barriers Visible",
            Content = string.format("Set Transparency = 0 for %d objects", changed),
            Duration = 3
        })
        
    else
        -- Устанавливаем Transparency = 1
        for _, obj in ipairs(invisParts:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Decal") then
                obj.Transparency = 1
                changed = changed + 1
            end
        end
        
        Fluent:Notify({
            Title = "Barriers Disable",
            Content = string.format("Set Transparency = 1 for %d objects", changed),
            Duration = 3
        })
    end
    
    print(string.format("[InvisParts Transparency] Transparency = %d для %d объектов", 
        transparent and 0 or 1,
        changed))
end

-- Обработчик тумблера
InvisPartsTransparencyToggle:OnChanged(function(state)
    setInvisPartsTransparency(state)
    
    -- Автоматическое применение к новым объектам
    if state then
        local invisParts = workspace:FindFirstChild("Game") and 
                          workspace.Game:FindFirstChild("Map") and 
                          workspace.Game.Map:FindFirstChild("InvisParts")
        
        if invisParts then
            -- Применяем к новым объектам
            invisParts.DescendantAdded:Connect(function(obj)
                if state then
                    if obj:IsA("BasePart") or obj:IsA("Decal") then
                        task.wait(0.05)
                        obj.Transparency = 0
                    end
                end
            end)
        end
    end
end)

-- Автоматическое применение при респавне
LocalPlayer.CharacterAdded:Connect(function()
    if Options.InvisPartsTransparencyToggle and Options.InvisPartsTransparencyToggle.Value then
        task.wait(1)
        setInvisPartsTransparency(true)
    end
end)

-- Автоматическое восстановление при выходе из игры
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer and Options.InvisPartsTransparencyToggle and Options.InvisPartsTransparencyToggle.Value then
        setInvisPartsTransparency(false)
    end
end)


-- ... предыдущий код без изменений до LeaderboardToggle ...

LeaderboardToggle = Tabs.Main:AddButton({
    Title = "Unlock Leaderboard; Zoom; Front View",
    Callback = function()
        local player = game.Players.LocalPlayer
        local guiService = game:GetService("GuiService")
        local starterGui = game:GetService("StarterGui")
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")

        local playerGui = player:WaitForChild("PlayerGui")
        if playerGui:FindFirstChild("CustomTopGui") then
            playerGui.CustomTopGui:Destroy()
        end

        starterGui:SetCore("TopbarEnabled", false)

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "CustomTopGui"
        screenGui.IgnoreGuiInset = false
        screenGui.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets
        screenGui.DisplayOrder = 100
        screenGui.ResetOnSpawn = false
        screenGui.Parent = playerGui

        local frame = Instance.new("Frame")
        frame.Parent = screenGui
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.Position = UDim2.new(0, 0, 0, 0)
        frame.Size = UDim2.new(1, 0, 1, -2)

        local scrollingFrame = Instance.new("ScrollingFrame")
        scrollingFrame.Name = "Right"
        scrollingFrame.Parent = frame
        scrollingFrame.BackgroundTransparency = 1
        scrollingFrame.BorderSizePixel = 0
        scrollingFrame.Position = UDim2.new(0, 12, 0, 0)
        scrollingFrame.Size = UDim2.new(1, -24, 1, 0)
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
        scrollingFrame.ScrollBarThickness = 0
        scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
        scrollingFrame.ScrollingEnabled = false

        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.Parent = scrollingFrame
        uiListLayout.Padding = UDim.new(0, 12)
        uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        uiListLayout.FillDirection = Enum.FillDirection.Horizontal
        uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

        local buttonsConfig = {
            {
                name = "SecondaryButton",
                layoutOrder = 999,
                icon = "rbxassetid://126943351764139",
                label = "Zoom",
                width = 100,
                labelWidth = 45,
                key = "Secondary"
            },
            {
                name = "ReloadButton",
                layoutOrder = 997,
                icon = "rbxassetid://78648212535999",
                label = "Front View / View",
                width = 173,
                labelWidth = 118,
                key = "Reload"
            },
            {
                name = "LeaderboardButton",
                layoutOrder = 998,
                icon = "rbxassetid://5107166345",
                label = "Leaderboard",
                width = 143,
                labelWidth = 88,
                key = "Leaderboard"
            }
        }

        for _, config in ipairs(buttonsConfig) do
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            local Button = Instance.new("Frame")
            Button.Name = config.name
            Button.Parent = scrollingFrame
            Button.BackgroundTransparency = 1
            Button.ClipsDescendants = true
            Button.LayoutOrder = config.layoutOrder
            Button.Size = UDim2.new(0, 44, 0, 44)
            Button.ZIndex = 20

            local IconButton = Instance.new("Frame")
            IconButton.Name = "IconButton"
            IconButton.Parent = Button
            IconButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            IconButton.BackgroundTransparency = 0.3
            IconButton.BorderSizePixel = 0
            IconButton.ClipsDescendants = true
            IconButton.Size = UDim2.new(1, 0, 1, 0)
            IconButton.ZIndex = 2

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(1, 0)
            UICorner.Parent = IconButton

            local Menu = Instance.new("ScrollingFrame")
            Menu.Name = "Menu"
            Menu.Parent = IconButton
            Menu.BackgroundTransparency = 1
            Menu.BorderSizePixel = 0
            Menu.Position = UDim2.new(0, 4, 0, 0)
            Menu.Selectable = false
            Menu.Size = UDim2.new(1, 0, 1, 0)
            Menu.ZIndex = 20
            Menu.BottomImage = ""
            Menu.CanvasSize = UDim2.new(0, 0, 1, -1)
            Menu.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
            Menu.ScrollBarThickness = 3
            Menu.TopImage = ""

            local MenuUIListLayout = Instance.new("UIListLayout")
            MenuUIListLayout.Name = "MenuUIListLayout"
            MenuUIListLayout.Parent = Menu
            MenuUIListLayout.FillDirection = Enum.FillDirection.Horizontal
            MenuUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            MenuUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            local MenuGap = Instance.new("Frame")
            MenuGap.Name = "MenuGap"
            MenuGap.Parent = Menu
            MenuGap.AnchorPoint = Vector2.new(0, 0.5)
            MenuGap.BackgroundTransparency = 1
            MenuGap.Size = UDim2.new(0, 4, 0, 0)
            MenuGap.Visible = false
            MenuGap.ZIndex = 5

            local IconSpot = Instance.new("Frame")
            IconSpot.Name = "IconSpot"
            IconSpot.Parent = Menu
            IconSpot.AnchorPoint = Vector2.new(0, 0.5)
            IconSpot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            IconSpot.BackgroundTransparency = 1
            IconSpot.Position = UDim2.new(0, 4, 0.5, 0)
            IconSpot.Size = UDim2.new(0, 36, 1, -8)
            IconSpot.ZIndex = 5

            local UICorner_2 = Instance.new("UICorner")
            UICorner_2.CornerRadius = UDim.new(1, 0)
            UICorner_2.Parent = IconSpot

            local IconOverlay = Instance.new("Frame")
            IconOverlay.Name = "IconOverlay"
            IconOverlay.Parent = IconSpot
            IconOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            IconOverlay.BackgroundTransparency = 0.925
            IconOverlay.Size = UDim2.new(1, 0, 1, 0)
            IconOverlay.Visible = false
            IconOverlay.ZIndex = 6

            local UICorner_3 = Instance.new("UICorner")
            UICorner_3.CornerRadius = UDim.new(1, 0)
            UICorner_3.Parent = IconOverlay

            local ClickRegion = Instance.new("TextButton")
            ClickRegion.Name = "ClickRegion"
            ClickRegion.Parent = IconSpot
            ClickRegion.BackgroundTransparency = 1
            ClickRegion.Size = UDim2.new(1, 0, 1, 0)
            ClickRegion.ZIndex = 20
            ClickRegion.Text = ""

            local UICorner_4 = Instance.new("UICorner")
            UICorner_4.CornerRadius = UDim.new(1, 0)
            UICorner_4.Parent = ClickRegion

            local Contents = Instance.new("Frame")
            Contents.Name = "Contents"
            Contents.Parent = IconSpot
            Contents.BackgroundTransparency = 1
            Contents.Size = UDim2.new(1, 0, 1, 0)

            local ContentsList = Instance.new("UIListLayout")
            ContentsList.Name = "ContentsList"
            ContentsList.Parent = Contents
            ContentsList.FillDirection = Enum.FillDirection.Horizontal
            ContentsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            ContentsList.SortOrder = Enum.SortOrder.LayoutOrder
            ContentsList.VerticalAlignment = Enum.VerticalAlignment.Center
            ContentsList.Padding = UDim.new(0, 3)

            local PaddingLeft = Instance.new("Frame")
            PaddingLeft.Name = "PaddingLeft"
            PaddingLeft.Parent = Contents
            PaddingLeft.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            PaddingLeft.BackgroundTransparency = 1
            PaddingLeft.BorderColor3 = Color3.fromRGB(0, 0, 0)
            PaddingLeft.BorderSizePixel = 0
            PaddingLeft.LayoutOrder = 1
            PaddingLeft.Size = UDim2.new(0, 9, 1, 0)
            PaddingLeft.ZIndex = 5

            local PaddingCenter = Instance.new("Frame")
            PaddingCenter.Name = "PaddingCenter"
            PaddingCenter.Parent = Contents
            PaddingCenter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            PaddingCenter.BackgroundTransparency = 1
            PaddingCenter.BorderColor3 = Color3.fromRGB(0, 0, 0)
            PaddingCenter.BorderSizePixel = 0
            PaddingCenter.LayoutOrder = 3
            PaddingCenter.Size = UDim2.new(0, 0, 1, 0)
            PaddingCenter.ZIndex = 5

            local PaddingRight = Instance.new("Frame")
            PaddingRight.Name = "PaddingRight"
            PaddingRight.Parent = Contents
            PaddingRight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            PaddingRight.BackgroundTransparency = 1
            PaddingRight.BorderColor3 = Color3.fromRGB(0, 0, 0)
            PaddingRight.BorderSizePixel = 0
            PaddingRight.LayoutOrder = 5
            PaddingRight.Size = UDim2.new(0, 11, 1, 0)
            PaddingRight.ZIndex = 5

            local IconLabelContainer = Instance.new("Frame")
            IconLabelContainer.Name = "IconLabelContainer"
            IconLabelContainer.Parent = Contents
            IconLabelContainer.AnchorPoint = Vector2.new(0, 0.5)
            IconLabelContainer.BackgroundTransparency = 1
            IconLabelContainer.LayoutOrder = 4
            IconLabelContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            IconLabelContainer.Size = UDim2.new(0, 0, 1, 0)
            IconLabelContainer.Visible = false
            IconLabelContainer.ZIndex = 3

            local IconLabel = Instance.new("TextLabel")
            IconLabel.Name = "IconLabel"
            IconLabel.Parent = IconLabelContainer
            IconLabel.BackgroundTransparency = 1
            IconLabel.LayoutOrder = 4
            IconLabel.Size = UDim2.new(0, 1306, 1, 0)
            IconLabel.ZIndex = 15
            IconLabel.Font = Enum.Font.GothamMedium
            IconLabel.Text = config.label
            IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            IconLabel.TextSize = 16
            IconLabel.TextWrapped = true
            IconLabel.TextXAlignment = Enum.TextXAlignment.Left
            IconLabel.Visible = false

            local IconImage = Instance.new("ImageLabel")
            IconImage.Name = "IconImage"
            IconImage.Parent = Contents
            IconImage.AnchorPoint = Vector2.new(0, 0.5)
            IconImage.BackgroundTransparency = 1
            IconImage.LayoutOrder = 2
            IconImage.Position = UDim2.new(0, 11, 0.5, 0)
            IconImage.Size = UDim2.new(0.7, 0, 0.7, 0)
            IconImage.ZIndex = 15
            IconImage.Image = config.icon

            local IconImageCorner = Instance.new("UICorner")
            IconImageCorner.CornerRadius = UDim.new(0, 0)
            IconImageCorner.Name = "IconImageCorner"
            IconImageCorner.Parent = IconImage

            local IconImageRatio = Instance.new("UIAspectRatioConstraint")
            IconImageRatio.Name = "IconImageRatio"
            IconImageRatio.Parent = IconImage
            IconImageRatio.DominantAxis = Enum.DominantAxis.Height

            local IconSpotGradient = Instance.new("UIGradient")
            IconSpotGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(96, 98, 100)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(77, 78, 80))
            }
            IconSpotGradient.Rotation = 45
            IconSpotGradient.Name = "IconSpotGradient"
            IconSpotGradient.Parent = IconSpot

            local IconGradient = Instance.new("UIGradient")
            IconGradient.Name = "IconGradient"
            IconGradient.Parent = IconButton

            local isHovering = false
            local currentTween = nil
            local hideDelay = 0.3
            local isMouseDown = false
            
            local smallButtonSize = UDim2.new(0, 44, 0, 44)
            local largeButtonSize = UDim2.new(0, config.width, 0, 44)
            local smallIconSpotSize = UDim2.new(0, 36, 1, -8)
            local largeIconSpotSize = UDim2.new(0, config.width - 8, 1, -8)
            local smallLabelSize = UDim2.new(0, 0, 1, 0)
            local largeLabelSize = UDim2.new(0, config.labelWidth, 1, 0)

            local function hideTextWithDelay()
                task.wait(hideDelay)
                if not isHovering then
                    IconLabel.Visible = false
                    IconLabelContainer.Visible = false
                    IconOverlay.Visible = false
                end
            end

            local function expand()
                isHovering = true
                
                if currentTween then
                    currentTween:Cancel()
                end
                
                IconLabel.Visible = true
                IconLabelContainer.Visible = true
                IconOverlay.Visible = true
                
                currentTween = TweenService:Create(Button, tweenInfo, {Size = largeButtonSize})
                currentTween:Play()
                
                TweenService:Create(IconSpot, tweenInfo, {Size = largeIconSpotSize}):Play()
                TweenService:Create(IconLabelContainer, tweenInfo, {Size = largeLabelSize}):Play()
            end

            local function contract()
                isHovering = false
                
                if currentTween then
                    currentTween:Cancel()
                end
                
                currentTween = TweenService:Create(Button, tweenInfo, {Size = smallButtonSize})
                currentTween:Play()
                
                TweenService:Create(IconSpot, tweenInfo, {Size = smallIconSpotSize}):Play()
                TweenService:Create(IconLabelContainer, tweenInfo, {Size = smallLabelSize}):Play()
                
                hideTextWithDelay()
            end

            ClickRegion.MouseEnter:Connect(function()
                expand()
            end)

            ClickRegion.MouseLeave:Connect(function()
                contract()
                if isMouseDown then
                    isMouseDown = false
                    game:GetService("Players").LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({
                        Key = config.key,
                        Down = false
                    })
                end
            end)

            ClickRegion.MouseButton1Down:Connect(function()
                isMouseDown = true
                game:GetService("Players").LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({
                    Key = config.key,
                    Down = true
                })
            end)

            ClickRegion.MouseButton1Up:Connect(function()
                isMouseDown = false
                game:GetService("Players").LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({
                    Key = config.key,
                    Down = false
                })
            end)

            player.CharacterAdded:Connect(function()
                task.wait(0.1)
                isHovering = false
                isMouseDown = false
                if currentTween then
                    currentTween:Cancel()
                    currentTween = nil
                end
                
                Button.Size = smallButtonSize
                IconSpot.Size = smallIconSpotSize
                IconLabelContainer.Size = smallLabelSize
                IconLabel.Visible = false
                IconLabelContainer.Visible = false
                IconOverlay.Visible = false
            end)
        end
        
        Fluent:Notify({
            Title = "Custom Leaderboard",
            Content = "Custom leaderboard UI has been created!",
            Duration = 3
        })
    end
})

-- ... остальной код без изменений ...

if not workspace:FindFirstChild("SecurityPart") then
    local SecurityPart = Instance.new("Part")
    SecurityPart.Name = "SecurityPart"
    SecurityPart.Size = Vector3.new(10, 1, 10)
    SecurityPart.Position = Vector3.new(5000, 5000, 5000)
    SecurityPart.Anchored = true
    SecurityPart.CanCollide = true
    SecurityPart.Parent = workspace
end

local AutoTab = Window:AddTab({ Title = "Auto Farm", Icon = "clock" })

AutoTab:AddSection("Farmings")

AutoMoneyFarmToggle = AutoTab:AddToggle("AutoMoneyFarmToggle", {
    Title = "Auto Farm Money",
    Default = false
})

AutoTicketFarmToggle = AutoTab:AddToggle("AutoTicketFarmToggle", {
    Title = "Auto Farm Tickets",
    Default = false
})

AFKFarmToggle = AutoTab:AddToggle("AFKFarmToggle", {
    Title = "AFK Farm",
    Default = false
})

AutoTab:AddSection("Teleports")

AutoTab:AddButton({
    Title = "Custom Server",
    Description = "Create Custom Server",
    Callback = function()
        -- Показываем уведомление перед телепортацией
        Fluent:Notify({
            Title = "Create",
            Content = "Create Custom Server",
            Duration = 3
        })
        
        -- Небольшая задержка перед телепортацией
        task.wait(1)
        
        -- Телепортация в указанную игру
        local success, errorMsg = pcall(function()
            game:GetService("TeleportService"):Teleport(99214917572799)
        end)
        
        -- Если телепортация не удалась, показываем ошибку
        if not success then
            Fluent:Notify({
                Title = "Failed Custom Server",
                Content = "Failed Custom Server: " .. tostring(errorMsg),
                Duration = 5
            })
        end
    end
})

TeleportObjectiveButton = AutoTab:AddButton({
    Title = "Teleport to Objective",
    Callback = function()
        local objectives = {}
        
        local gameFolder = workspace:FindFirstChild("Game")
        if not gameFolder then return end
        
        local mapFolder = gameFolder:FindFirstChild("Map")
        if not mapFolder then return end
        
        -- Ищем Objectives в разных местах
        local objectivesFolder = nil
        
        -- Путь 1: Game.Map.Parts.Objectives
        local partsFolder = mapFolder:FindFirstChild("Parts")
        if partsFolder then
            objectivesFolder = partsFolder:FindFirstChild("Objectives")
        end
        
        -- Путь 2: Game.Map.Objectives (прямо в Map)
        if not objectivesFolder then
            objectivesFolder = mapFolder:FindFirstChild("Objectives")
        end
        
        -- Путь 3: Ищем по всему Map
        if not objectivesFolder then
            for _, obj in ipairs(mapFolder:GetDescendants()) do
                if obj.Name == "Objectives" and (obj:IsA("Folder") or obj:IsA("Model")) then
                    objectivesFolder = obj
                    break
                end
            end
        end
        
        if not objectivesFolder then return end
        
        -- Собираем все Objectives
        for _, obj in pairs(objectivesFolder:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
                local teleportPart = nil
                
                if obj:IsA("BasePart") then
                    teleportPart = obj
                elseif obj:IsA("Model") then
                    teleportPart = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or 
                                  obj:FindFirstChild("Head") or obj:FindFirstChild("Torso") or 
                                  obj:FindFirstChildWhichIsA("BasePart")
                end
                
                if teleportPart then
                    table.insert(objectives, {
                        Name = obj.Name,
                        Part = teleportPart,
                        Position = teleportPart.Position
                    })
                end
            end
        end
        
        if #objectives == 0 then return end
        
        -- Выбираем случайный Objective
        local selectedObjective = objectives[math.random(1, #objectives)]
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Телепортируемся
        local teleportPosition = selectedObjective.Position + Vector3.new(0, 5, 0)
        humanoidRootPart.CFrame = CFrame.new(teleportPosition)
    end
})

-- Teleport to Spawn
TeleportSpawnButton = AutoTab:AddButton({
    Title = "Teleport to Spawn",
    Callback = function()
        local gameFolder = workspace:FindFirstChild("Game")
        if not gameFolder then return end
        
        local mapFolder = gameFolder:FindFirstChild("Map")
        if not mapFolder then return end
        
        local partsFolder = mapFolder:FindFirstChild("Parts")
        if not partsFolder then return end
        
        local spawnsFolder = partsFolder:FindFirstChild("Spawns")
        if not spawnsFolder then return end
        
        -- Собираем все спавны
        local spawns = {}
        for _, obj in pairs(spawnsFolder:GetChildren()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                table.insert(spawns, obj)
            elseif obj:IsA("Model") then
                local part = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or 
                            obj:FindFirstChild("Head") or obj:FindFirstChild("Torso") or 
                            obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    table.insert(spawns, part)
                end
            end
        end
        
        if #spawns == 0 then return end
        
        -- Выбираем случайный спавн
        local selectedSpawn = spawns[math.random(1, #spawns)]
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Телепортируемся
        local teleportPosition = selectedSpawn.Position + Vector3.new(0, 3, 0)
        humanoidRootPart.CFrame = CFrame.new(teleportPosition)
    end
})

AutoMoneyFarmConnection = nil
AutoWinConnection = nil
AutoTicketFarmConnection = nil
AutoReviveModule = nil

character = LocalPlayer.Character
humanoid = character and character:FindFirstChild("Humanoid")
rootPart = character and character:FindFirstChild("HumanoidRootPart")

function startAutoWin()
    if AutoWinConnection then return end
    
    AutoWinConnection = RunService.Heartbeat:Connect(function()
        local securityPart = workspace:FindFirstChild("SecurityPart")
        if not securityPart then return end
        
        local currentCharacter = LocalPlayer.Character
        if not currentCharacter then return end
        
        local currentRootPart = currentCharacter:FindFirstChild("HumanoidRootPart")
        if not currentRootPart then return end
        
        if not currentCharacter:GetAttribute("Downed") then
            currentRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
        end
    end)
end

function stopAutoWin()
    if AutoWinConnection then
        AutoWinConnection:Disconnect()
        AutoWinConnection = nil
    end
end

function initAutoReviveModule()
    local reviveRange = 15
    local loopDelay = 0.25
    local autoReviveEnabled = false
    local reviveLoopHandle = nil
    local interactEvent = ReplicatedStorage:FindFirstChild("Events") and 
                         ReplicatedStorage.Events:FindFirstChild("Character") and 
                         ReplicatedStorage.Events.Character:FindFirstChild("Interact")
    
    if not interactEvent then
        warn("Auto Revive Module: Interact event not found!")
        return nil
    end

    local function isPlayerDowned(pl)
        if not pl or not pl.Character then return false end
        local char = pl.Character
        
        if char:GetAttribute("Downed") == true then
            return true
        end
        
        local ragdollsFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Ragdolls")
        if ragdollsFolder and ragdollsFolder:FindFirstChild(pl.Name) then
            return true
        end
        
        return false
    end

    local function getDownedRootPart(pl)
        if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            return pl.Character.HumanoidRootPart
        end
        
        local ragdollsFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Ragdolls")
        if ragdollsFolder then
            local ragdoll = ragdollsFolder:FindFirstChild(pl.Name)
            if ragdoll then
                return ragdoll:FindFirstChild("HumanoidRootPart") or 
                       ragdoll:FindFirstChild("Torso") or 
                       ragdoll:FindFirstChild("Head") or 
                       ragdoll:FindFirstChildWhichIsA("BasePart")
            end
        end
        return nil
    end

    function startAutoRevive()
        if reviveLoopHandle then return end
        reviveLoopHandle = task.spawn(function()
            while autoReviveEnabled do
                local currentPlayer = Players.LocalPlayer
                if currentPlayer then
                    local character = currentPlayer.Character
                    local securityPart = workspace:FindFirstChild("SecurityPart")
                    
                    -- АВТОМАТИЧЕСКОЕ ВОЗРОЖДЕНИЕ
                    if character and character:GetAttribute("Downed") then
                        pcall(function()
                            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                        end)
                        
                        if securityPart then
                            task.wait(1)
                            local newChar = currentPlayer.Character
                            if newChar and newChar:FindFirstChild("HumanoidRootPart") then
                                newChar.HumanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                            end
                        end
                        task.wait(1)
                    
                    -- НОРМАЛЬНАЯ РАБОТА
                    elseif character and character:FindFirstChild("HumanoidRootPart") then
                        local myHRP = character.HumanoidRootPart
                        local downedFound = false
                        
                        for _, pl in ipairs(Players:GetPlayers()) do
                            if pl ~= currentPlayer and isPlayerDowned(pl) then
                                local targetRoot = getDownedRootPart(pl)
                                if targetRoot then
                                    downedFound = true
                                    local dist = (myHRP.Position - targetRoot.Position).Magnitude
                                    
                                    -- Телепорт ПРЯМО ПОД игрока
                                    if dist > reviveRange then
                                        local targetPos = targetRoot.Position
                                        myHRP.CFrame = CFrame.new(targetPos.X, targetPos.Y - 5, targetPos.Z)
                                        task.wait(0.1)
                                    end
                                    
                                    -- Сразу лечим
                                    pcall(function()
                                        interactEvent:FireServer("Revive", true, pl.Name)
                                    end)
                                    task.wait(0.2)
                                end
                            end
                        end
                        
                        -- Если нет сбитых, стоим на SecurityPart
                        if not downedFound and not character:GetAttribute("Downed") and securityPart then
                            myHRP.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                end
                task.wait(loopDelay)
            end
            reviveLoopHandle = nil
        end)
    end

    function stopAutoRevive()
        autoReviveEnabled = false
        if reviveLoopHandle then
            task.cancel(reviveLoopHandle)
            reviveLoopHandle = nil
        end
    end

    function ToggleAutoRevive(state)
        autoReviveEnabled = state
        if autoReviveEnabled then
            startAutoRevive()
        else
            stopAutoRevive()
        end
    end

    return {
        Toggle = ToggleAutoRevive,
        Start = function() ToggleAutoRevive(true) end,
        Stop = function() ToggleAutoRevive(false) end,
        IsEnabled = function() return autoReviveEnabled end,
    }
end

function startAutoMoneyFarm()
    if AutoMoneyFarmConnection then 
        stopAutoMoneyFarm()
    end
    
    if not AutoReviveModule then
        AutoReviveModule = initAutoReviveModule()
        if not AutoReviveModule then
            Fluent:Notify({
                Title = "Auto Farm Money",
                Content = "Failed to initialize revive module!",
                Duration = 5
            })
            return
        end
    end
    
    AutoReviveModule.Start()
    
    AutoMoneyFarmConnection = RunService.Heartbeat:Connect(function()
        if not AutoReviveModule or not AutoReviveModule.IsEnabled() then
            if Options.AutoMoneyFarmToggle and Options.AutoMoneyFarmToggle.Value then
                AutoReviveModule.Start()
            end
        end
    end)
end

function stopAutoMoneyFarm()
    if AutoMoneyFarmConnection then
        AutoMoneyFarmConnection:Disconnect()
        AutoMoneyFarmConnection = nil
    end
    
    if AutoReviveModule then
        AutoReviveModule.Stop()
    end
end

AutoMoneyFarmToggle:OnChanged(function(state)
    if state then
        startAutoMoneyFarm()
    else
        stopAutoMoneyFarm()
    end
end)

AFKFarmToggle:OnChanged(function(state)
    if state then
        startAutoWin()
    else
        stopAutoWin()
    end
end)

AutoTicketFarmToggle:OnChanged(function(state)
    local yOffset = 15
    local currentTicket = nil
    local ticketProcessedTime = 0

    if state then
        local securityPart = workspace:FindFirstChild("SecurityPart")
        if not securityPart then
            return
        end

        if AutoTicketFarmConnection then
            AutoTicketFarmConnection:Disconnect()
        end
        
        AutoTicketFarmConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            local tickets = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Effects") and workspace.Game.Effects:FindFirstChild("Tickets")

            if character:GetAttribute("Downed") then
                pcall(function()
                    ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                end)
                humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                return
            end

            if tickets then
                local activeTickets = tickets:GetChildren()
                if #activeTickets > 0 then
                    if not currentTicket or not currentTicket.Parent then
                        currentTicket = activeTickets[1]
                        ticketProcessedTime = tick()
                    end

                    if currentTicket and currentTicket.Parent then
                        local ticketPart = currentTicket:FindFirstChild("HumanoidRootPart") or currentTicket:IsA("BasePart") and currentTicket
                        if ticketPart then
                            local targetPosition = ticketPart.Position + Vector3.new(0, yOffset, 0)
                            humanoidRootPart.CFrame = CFrame.new(targetPosition)
                            
                            if tick() - ticketProcessedTime > 0.1 then
                                humanoidRootPart.CFrame = ticketPart.CFrame
                            end
                        else
                            currentTicket = nil
                        end
                    else
                        humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                        currentTicket = nil
                    end
                else
                    humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                    currentTicket = nil
                end
            else
                humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                currentTicket = nil
            end
        end)
    else
        if AutoTicketFarmConnection then
            AutoTicketFarmConnection:Disconnect()
            AutoTicketFarmConnection = nil
        end
        currentTicket = nil
        local character = LocalPlayer.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local securityPart = workspace:FindFirstChild("SecurityPart")
            if humanoidRootPart and securityPart then
                humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end)

CombatTab = Window:AddTab({ Title = "Combat", Icon = "swords" })

CombatTab:AddSection("Anti-Nextbot")

featureStates.AntiNextbot = false
featureStates.AntiNextbotTeleportType = "Distance"
featureStates.AntiNextbotDistance = 50
featureStates.DistanceTeleport = 20

PathfindingService = game:GetService("PathfindingService")

antiNextbotConnection = nil
farmsSuppressedByAntiNextbot = false
previousMoneyFarm = false
previousTicketFarm = false
previousAutoWin = false

function handleAntiNextbot()
    if not featureStates.AntiNextbot then return end

    character = Players.LocalPlayer.Character
    humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    nextbots = {}
    npcsFolder = workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, model in ipairs(npcsFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    table.insert(nextbots, model)
                end
            end
        end
    end

    playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if playersFolder then
        for _, model in ipairs(playersFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    table.insert(nextbots, model)
                end
            end
        end
    end

    for _, nextbot in ipairs(nextbots) do
        nextbotHrp = nextbot:FindFirstChild("HumanoidRootPart")
        if nextbotHrp then
            distance = (humanoidRootPart.Position - nextbotHrp.Position).Magnitude
            if distance <= featureStates.AntiNextbotDistance then
                if featureStates.AntiNextbotTeleportType == "Players" then
                    validPlayers = {}
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            table.insert(validPlayers, plr)
                        end
                    end
                    if #validPlayers > 0 then
                        randomPlayer = validPlayers[math.random(1, #validPlayers)]
                        humanoidRootPart.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    end
                elseif featureStates.AntiNextbotTeleportType == "Spawn" then
                    spawnsFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Map") and workspace.Game.Map:FindFirstChild("Parts") and workspace.Game.Map.Parts:FindFirstChild("Spawns")
                    if spawnsFolder then
                        spawnLocations = spawnsFolder:GetChildren()
                        if #spawnLocations > 0 then
                            randomSpawn = spawnLocations[math.random(1, #spawnLocations)]
                            humanoidRootPart.CFrame = randomSpawn.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                elseif featureStates.AntiNextbotTeleportType == "Distance" then
                    direction = (humanoidRootPart.Position - nextbotHrp.Position).Unit
                    targetPos = humanoidRootPart.Position + direction * featureStates.DistanceTeleport

                    path = PathfindingService:CreatePath({
                        AgentRadius = 2,
                        AgentHeight = 5,
                        AgentCanJump = true
                    })

                    success, errorMessage = pcall(function()
                        path:ComputeAsync(humanoidRootPart.Position, targetPos)
                    end)

                    if success and path.Status == Enum.PathStatus.Success then
                        waypoints = path:GetWaypoints()
                        if #waypoints > 1 then
                            lastValidPos = waypoints[#waypoints].Position
                            distanceToTarget = (lastValidPos - humanoidRootPart.Position).Magnitude
                            if distanceToTarget <= featureStates.DistanceTeleport then
                                humanoidRootPart.CFrame = CFrame.new(lastValidPos + Vector3.new(0, 3, 0))
                            else
                                for i = #waypoints, 1, -1 do
                                    waypointPos = waypoints[i].Position
                                    if (waypointPos - humanoidRootPart.Position).Magnitude <= featureStates.DistanceTeleport then
                                        humanoidRootPart.CFrame = CFrame.new(waypointPos + Vector3.new(0, 3, 0))
                                        break
                                    end
                                end
                            end
                        end
                    else
                        fallbackPos = humanoidRootPart.Position + direction * featureStates.DistanceTeleport
                        ray = Ray.new(humanoidRootPart.Position, direction * featureStates.DistanceTeleport)
                        hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {character, nextbot})
                        if not hit then
                            humanoidRootPart.CFrame = CFrame.new(fallbackPos + Vector3.new(0, 3, 0))
                        else
                            humanoidRootPart.CFrame = CFrame.new(hitPos + Vector3.new(0, 3, 0))
                        end
                    end
                end
                break
            end
        end
    end
end

task.spawn(function()
    while true do
        if featureStates.AntiNextbot then
            pcall(handleAntiNextbot)
        end
        task.wait(0.1)
    end
end)

AntiNextbotToggle = CombatTab:AddToggle("AntiNextbotToggle", {
    Title = "Anti-Nextbot",
    Default = false
})

AntiNextbotTeleportTypeDropdown = CombatTab:AddDropdown("AntiNextbotTeleportTypeDropdown", {
    Title = "Teleport Type",
    Values = {"Players", "Spawn", "Distance"},
    Multi = false,
    Default = "Distance"
})

AntiNextbotDistanceInput = CombatTab:AddInput("AntiNextbotDistanceInput", {
    Title = "Detection Distance",
    Default = "50",
    Placeholder = "Enter distance",
    Numeric = true,
    Finished = false
})

DistanceTeleportInput = CombatTab:AddInput("DistanceTeleportInput", {
    Title = "Teleport Distance",
    Default = "20",
    Placeholder = "Enter distance",
    Numeric = true,
    Finished = false
})

AntiNextbotToggle:OnChanged(function(state)
    featureStates.AntiNextbot = state
    
    if state then
        antiNextbotConnection = RunService.Heartbeat:Connect(function()
            if not featureStates.AntiNextbot then return end
            
            character = player.Character
            humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            nearestDistance = math.huge
            nearestNextbot = nil
            playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
            npcsFolder = workspace:FindFirstChild("NPCs")
            
            if playersFolder then
                for _, model in pairs(playersFolder:GetChildren()) do
                    if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and isNextbotModel(model) then
                        dist = (model.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                        if dist < nearestDistance then
                            nearestDistance = dist
                            nearestNextbot = model
                        end
                    end
                end
            end
            
            if npcsFolder then
                for _, model in pairs(npcsFolder:GetChildren()) do
                    if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and isNextbotModel(model) then
                        dist = (model.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                        if dist < nearestDistance then
                            nearestDistance = dist
                            nearestNextbot = model
                        end
                    end
                end
            end
            
            threshold = featureStates.AntiNextbotDistance
            isTooClose = (nearestDistance < threshold)
            
            if isTooClose and not farmsSuppressedByAntiNextbot then
                previousMoneyFarm = Options.AutoMoneyFarmToggle.Value
                previousTicketFarm = Options.AutoTicketFarmToggle.Value
                previousAutoWin = Options.AFKFarmToggle.Value
                
                if Options.AutoMoneyFarmToggle.Value then
                    Options.AutoMoneyFarmToggle:Set(false)
                end
                if Options.AutoTicketFarmToggle.Value then
                    Options.AutoTicketFarmToggle:Set(false)
                end
                if Options.AFKFarmToggle.Value then
                    Options.AFKFarmToggle:Set(false)
                end
                
                farmsSuppressedByAntiNextbot = true
            elseif not isTooClose and farmsSuppressedByAntiNextbot then
                if previousMoneyFarm then
                    Options.AutoMoneyFarmToggle:Set(true)
                end
                if previousTicketFarm then
                    Options.AutoTicketFarmToggle:Set(true)
                end
                if previousAutoWin then
                    Options.AFKFarmToggle:Set(true)
                end
                
                farmsSuppressedByAntiNextbot = false
            end
            
            if isTooClose then
                safePart = workspace:FindFirstChild("SecurityPart")
                if safePart then
                    humanoidRootPart.CFrame = safePart.CFrame + Vector3.new(math.random(-5, 5), 3, math.random(-5, 5))
                end
            end
        end)
    else
        if antiNextbotConnection then
            antiNextbotConnection:Disconnect()
            antiNextbotConnection = nil
        end
        if farmsSuppressedByAntiNextbot then
            if previousMoneyFarm then
                Options.AutoMoneyFarmToggle:Set(true)
            end
            if previousTicketFarm then
                Options.AutoTicketFarmToggle:Set(true)
            end
            if previousAutoWin then
                Options.AFKFarmToggle:Set(true)
            end
            
            farmsSuppressedByAntiNextbot = false
        end
    end
end)

AntiNextbotTeleportTypeDropdown:OnChanged(function(value)
    featureStates.AntiNextbotTeleportType = value
end)

AntiNextbotDistanceInput:OnChanged(function(value)
    num = tonumber(value)
    if num and num > 0 then
        featureStates.AntiNextbotDistance = num
    end
end)

DistanceTeleportInput:OnChanged(function(value)
    num = tonumber(value)
    if num and num > 0 then
        featureStates.DistanceTeleport = num
    end
end)

 MiscTab = Window:AddTab({ Title = "Misc", Icon = "star" })
MiscTab:AddSection("Player Adjustments")
local currentSettings = {
    Speed = "1500",
    JumpCap = "1",
    AirStrafeAcceleration = "187"
}
local appliedOnce = false
local playerModelPresent = false
local gameStatsPath = workspace:WaitForChild("Game"):WaitForChild("Stats")
getgenv().ApplyMode = "Not Optimized"
local requiredFields = {
    Friction = true,
    AirStrafeAcceleration = true,
    JumpHeight = true,
    RunDeaccel = true,
    JumpSpeedMultiplier = true,
    JumpCap = true,
    SprintCap = true,
    WalkSpeedMultiplier = true,
    BhopEnabled = true,
    Speed = true,
    AirAcceleration = true,
    RunAccel = true,
    SprintAcceleration = true
}

local function hasAllFields(tbl)
    if type(tbl) ~= "table" then return false end
    for field, _ in pairs(requiredFields) do
        if rawget(tbl, field) == nil then return false end
    end
    return true
end

local function getConfigTables()
    local tables = {}
    for _, obj in ipairs(getgc(true)) do
        local success, result = pcall(function()
            if hasAllFields(obj) then return obj end
        end)
        if success and result then
            table.insert(tables, result)
        end
    end
    return tables
end

local function applyToTables(callback)
    local targets = getConfigTables()
    if #targets == 0 then return end
    
    if getgenv().ApplyMode == "Optimized" then
        task.spawn(function()
            for i, tableObj in ipairs(targets) do
                if tableObj and typeof(tableObj) == "table" then
                    pcall(callback, tableObj)
                end
                
                if i % 3 == 0 then
                    task.wait()
                end
            end
        end)
    else
        for i, tableObj in ipairs(targets) do
            if tableObj and typeof(tableObj) == "table" then
                pcall(callback, tableObj)
            end
        end
    end
end

local function applyStoredSettings()
    local settings = {
        {field = "Speed", value = tonumber(currentSettings.Speed)},
        {field = "JumpCap", value = tonumber(currentSettings.JumpCap)},
        {field = "AirStrafeAcceleration", value = tonumber(currentSettings.AirStrafeAcceleration)}
    }
    
    for _, setting in ipairs(settings) do
        if setting.value and tostring(setting.value) ~= "1500" and tostring(setting.value) ~= "1" and tostring(setting.value) ~= "187" then
            applyToTables(function(obj)
                obj[setting.field] = setting.value
            end)
        end
    end
end

local function applySettingsWithDelay()
    if not playerModelPresent or appliedOnce then
        return
    end
    
    appliedOnce = true
    
    local settings = {
        {field = "Speed", value = tonumber(currentSettings.Speed), delay = math.random(1, 14)},
        {field = "JumpCap", value = tonumber(currentSettings.JumpCap), delay = math.random(1, 14)},
        {field = "AirStrafeAcceleration", value = tonumber(currentSettings.AirStrafeAcceleration), delay = math.random(1, 14)}
    }
    
    for _, setting in ipairs(settings) do
        if setting.value and tostring(setting.value) ~= "1500" and tostring(setting.value) ~= "1" and tostring(setting.value) ~= "187" then
            task.spawn(function()
                task.wait(setting.delay)
                applyToTables(function(obj)
                    obj[setting.field] = setting.value
                end)
            end)
        end
    end
end

local function isPlayerModelPresent()
    local GameFolder = workspace:FindFirstChild("Game")
    local PlayersFolder = GameFolder and GameFolder:FindFirstChild("Players")
    return PlayersFolder and PlayersFolder:FindFirstChild(player.Name) ~= nil
end

SpeedInput = MiscTab:AddInput("SpeedInput", {
    Title = "Player Speed",
    Default = currentSettings.Speed,
    Placeholder = "Default 1500",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local val = tonumber(Value)
        if val and val >= 1450 and val <= 100008888 then
            currentSettings.Speed = tostring(val)
            applyToTables(function(obj)
                obj.Speed = val
            end)
        end
    end
})

JumpPowerInput = MiscTab:AddInput("JumpPowerInput", {
    Title = "Player Jump",
    Default = "3.5",
    Placeholder = "",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        if Value and tonumber(Value) then
            JumpPowerValue = tonumber(Value)
        end
    end
})

JumpCapInput = MiscTab:AddInput("JumpCapInput", {
    Title = "Player Jump Cap",
    Default = currentSettings.JumpCap,
    Placeholder = "Default 1",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local val = tonumber(Value)
        if val and val >= 0.1 and val <= 5088888 then
            currentSettings.JumpCap = tostring(val)
            applyToTables(function(obj)
                obj.JumpCap = val
            end)
        end
    end
})

StrafeInput = MiscTab:AddInput("StrafeInput", {
    Title = "Player Strafe Acceleration",
    Default = currentSettings.AirStrafeAcceleration,
    Placeholder = "Default 187",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local val = tonumber(Value)
        if val and val >= 1 and val <= 1000888888 then
            currentSettings.AirStrafeAcceleration = tostring(val)
            applyToTables(function(obj)
                obj.AirStrafeAcceleration = val
            end)
        end
    end
})

ApplyMethodDropdown = MiscTab:AddDropdown("ApplyMethodDropdown", {
    Title = "Select Apply Method",
    Values = {"Not Optimized", "Optimized"},
    Multi = false,
    Default = getgenv().ApplyMode,
    Callback = function(Value)
        getgenv().ApplyMode = Value
    end
})
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeSettingRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Data"):WaitForChild("ChangeSetting")
local UpdatedEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("Settings"):WaitForChild("Updated")

FovInput = MiscTab:AddInput("FovInput", {
    Title = "Player FOV",
    Default = "",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            ChangeSettingRemote:InvokeServer(2, num)
            UpdatedEvent:Fire(2, num)
        end
    end
})

JumpPowerValue = 3.5
MaxJumpsValue = math.huge

CurrentJumpCount = 0
JumpHumanoid = nil
JumpRootPart = nil

Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    JumpHumanoid = newChar:FindFirstChild("Humanoid")
    JumpRootPart = newChar:FindFirstChild("HumanoidRootPart")
    if JumpHumanoid and JumpRootPart then
        CurrentJumpCount = 0
        JumpHumanoid.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Landed then
                CurrentJumpCount = 0
            end
        end)
        JumpHumanoid.Jumping:Connect(function(isJumping)
            if isJumping and CurrentJumpCount < MaxJumpsValue then
                CurrentJumpCount = CurrentJumpCount + 1
                JumpHumanoid.JumpHeight = JumpPowerValue
                if CurrentJumpCount > 1 and JumpRootPart then
                    JumpRootPart:ApplyImpulse(Vector3.new(0, JumpPowerValue * JumpRootPart.Mass, 0))
                end
            end
        end)
    end
end)

-- Handle initial character
if Players.LocalPlayer.Character then
    task.spawn(function()
        task.wait(0.5)
        JumpHumanoid = Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        JumpRootPart = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if JumpHumanoid and JumpRootPart then
            CurrentJumpCount = 0
            JumpHumanoid.StateChanged:Connect(function(oldState, newState)
                if newState == Enum.HumanoidStateType.Landed then
                    CurrentJumpCount = 0
                end
            end)
            JumpHumanoid.Jumping:Connect(function(isJumping)
                if isJumping and CurrentJumpCount < MaxJumpsValue then
                    CurrentJumpCount = CurrentJumpCount + 1
                    JumpHumanoid.JumpHeight = JumpPowerValue
                    if CurrentJumpCount > 1 and JumpRootPart then
                        JumpRootPart:ApplyImpulse(Vector3.new(0, JumpPowerValue * JumpRootPart.Mass, 0))
                    end
                end
            end)
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    task.wait(0.5)
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
end)

MiscTab:AddSection("Player Modification")
--====FAILED TO DECOMPILED CODE====--
JumpPowerToggle = MiscTab:AddToggle("JumpPowerToggle", {
    Title = "Jump Power Toggle",
    Default = false
})

JumpPowerToggle:OnChanged(function()
    --====FAILED TO EXECUTE FUNCTION====--
end)

--====FAILED TO DECOMPILED CODE====--
PlayerJumpPowerInput = MiscTab:AddInput("PlayerJumpPowerInput", {
    Title = "Player Jump Power",
    Default = "Failed To Decode",
    Placeholder = "Failed To Decode",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        --====FAILED TO EXECUTE CALLBACK====--
    end
})

--====FAILED TO DECOMPILED CODE====--
WalkspeedToggle = MiscTab:AddToggle("WalkspeedToggle", {
    Title = "Walkspeed Toggle",
    Default = false
})

WalkspeedToggle:OnChanged(function()
    --====FAILED TO EXECUTE FUNCTION====--
end)

--====FAILED TO DECOMPILED CODE====--
PlayerWalkspeedInput = MiscTab:AddInput("PlayerWalkspeedInput", {
    Title = "Player Walkspeed",
    Default = "Failed To Decode",
    Placeholder = "Failed To Decode",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        --====FAILED TO EXECUTE CALLBACK====--
    end
})
--====FAILED TO DECOMPILED CODE====--
BounceToggle = MiscTab:AddToggle("WalkspeedToggle", {
    Title = "Walkspeed Toggle",
    Default = false
})

BounceToggle:OnChanged(function()
    --====FAILED TO EXECUTE FUNCTION====--
end)

--====FAILED TO DECOMPILED CODE====--
BounceInput = MiscTab:AddInput("BounceInput", {
    Title = "Player Walkspeed",
    Default = "Failed To Decode",
    Placeholder = "Failed To Decode",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        --====FAILED TO EXECUTE CALLBACK====--
    end
})

MiscTab:AddSection("Bounce")

BounceToggle = MiscTab:AddToggle("BounceToggle", {
    Title = "Modify Bounce",
    Default = false
})

BounceInput = MiscTab:AddInput("BounceInput", {
    Title = "Player Bounce",
    Default = "110",
    Placeholder = "Enter bounce speed",
    Numeric = true,
    Finished = false
})

-- Логика для Bounce
local bounceConnection = nil
local player = game:GetService("Players").LocalPlayer

local function updateBounce()
    if not BounceToggle.Value then return end
    
    local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if not gamePlayers then return end
    
    local playerModel = gamePlayers:FindFirstChild(player.Name)
    if not playerModel then return end
    
    local humanoid = playerModel:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local speedValue = tonumber(BounceInput.Value) or 110
    humanoid.WalkSpeed = speedValue
end

BounceToggle:OnChanged(function(state)
    if state then
        -- Запускаем постоянное обновление (на случай если Humanoid пересоздается)
        if bounceConnection then
            bounceConnection:Disconnect()
        end
        
        bounceConnection = game:GetService("RunService").Heartbeat:Connect(updateBounce)
    else
        if bounceConnection then
            bounceConnection:Disconnect()
            bounceConnection = nil
        end
        
        -- Возвращаем стандартную скорость
        local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
        if gamePlayers then
            local playerModel = gamePlayers:FindFirstChild(player.Name)
            if playerModel then
                local humanoid = playerModel:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 0  -- Стандартная скорость в Evade
                end
            end
        end
    end
end)

-- Обновляем при изменении значения в инпуте
BounceInput:OnChanged(function(Value)
    if BounceToggle.Value then
        local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
        if gamePlayers then
            local playerModel = gamePlayers:FindFirstChild(player.Name)
            if playerModel then
                local humanoid = playerModel:FindFirstChild("Humanoid")
                if humanoid then
                    local speedValue = tonumber(Value) or 110
                    humanoid.WalkSpeed = speedValue
                end
            end
        end
    end
end)

-- Обработка респавна
player.CharacterAdded:Connect(function()
    task.wait(1)
    if BounceToggle.Value then
        -- Небольшая задержка чтобы модель успела появиться в workspace.Game.Players
        task.wait(1)
        updateBounce()
    end
end)

MiscTab:AddSection("Revive Players")

local function createGradientButton(parent, position, size, text, onClickCallback)
    local button = Instance.new("Frame")
    button.Name = "GradientBtn"
    button.BackgroundTransparency = 0.7
    button.Size = size
    button.Position = position
    button.Draggable = true
    button.Active = true
    button.Selectable = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    gradient.Rotation = 0
    gradient.Parent = button

    local gradientAnimation
    gradientAnimation = RunService.RenderStepped:Connect(function(delta)
        gradient.Rotation = (gradient.Rotation + 90 * delta) % 360
    end)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(139, 0, 0)  -- Темно-красный (обычное состояние)
    stroke.Thickness = 2
    stroke.Parent = button

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.Parent = button

    local clicker = Instance.new("TextButton")
    clicker.Size = UDim2.new(1, 0, 1, 0)
    clicker.BackgroundTransparency = 1
    clicker.Text = ""
    clicker.ZIndex = 5
    clicker.Parent = button

    button.Destroying:Connect(function()
        if gradientAnimation then
            gradientAnimation:Disconnect()
        end
    end)

    -- ==================== ПЕРЕТАСКИВАНИЕ С ЗАЩИТОЙ ОТ МУЛЬТИТАЧ ====================
    local UserInputService = game:GetService("UserInputService")
    local activeTouchId = nil  -- ID активного пальца
    local startPos = nil
    local startButtonPos = nil
    
    -- Функция для обновления позиции кнопки
    local function updateButtonPosition(touchPos)
        if not startPos or not startButtonPos then return end
        local delta = touchPos - startPos
        button.Position = UDim2.new(startButtonPos.X.Scale, startButtonPos.X.Offset + delta.X,
                                    startButtonPos.Y.Scale, startButtonPos.Y.Offset + delta.Y)
    end
    
    -- Сброс состояния
    local function resetDrag()
        activeTouchId = nil
        startPos = nil
        startButtonPos = nil
        stroke.Color = Color3.fromRGB(139, 0, 0)  -- Возвращаем темно-красный
    end
    
    -- Начало касания (мобильные устройства)
    clicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local touchId = input.UserInputState
            
            -- Если уже есть активный палец - игнорируем остальные
            if activeTouchId ~= nil then
                return
            end
            
            activeTouchId = touchId
            startPos = input.Position
            startButtonPos = button.Position
            
            -- Меняем цвет на ярко-красный при нажатии
            stroke.Color = Color3.fromRGB(255, 0, 0)
            
            -- Обработка окончания касания
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resetDrag()
                    connection:Disconnect()
                end
            end)
            
        -- Для мыши
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            if activeTouchId ~= nil then return end
            
            activeTouchId = "mouse"
            startPos = input.Position
            startButtonPos = button.Position
            
            stroke.Color = Color3.fromRGB(255, 0, 0)
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resetDrag()
                    connection:Disconnect()
                end
            end)
        end
    end)

    -- Обработка движения пальца/мыши
    clicker.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            if activeTouchId ~= nil then
                updateButtonPosition(input.Position)
            end
        elseif input.UserInputType == Enum.UserInputType.MouseMovement then
            if activeTouchId ~= nil then
                updateButtonPosition(input.Position)
            end
        end
    end)

    return button, clicker, stroke
end

local InstantReviveToggle = MiscTab:AddToggle("InstantReviveToggle", {
    Title = "Instant Revive",
    Default = false
})

local ReviveWhileEmoteToggle = MiscTab:AddToggle("ReviveWhileEmoteToggle", {
    Title = "Instant Revive While Emoting",
    Default = false
})

local ReviveDelaySlider = MiscTab:AddSlider("ReviveDelaySlider", {
    Title = "Revive Delay",
    Min = 0,
    Max = 1,
    Default = 0.15,
    Rounding = 2,
    Callback = function(value)
        getgenv().InstantReviveDelay = value
    end
})
getgenv().InstantReviveDelay = 0.15

local InstantReviveModule = (function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    local reviveRange = 10
    local loopDelay = getgenv().InstantReviveDelay or 0.15

    local enabled = false
    local handle = nil
    local stateConnection = nil
    local isCurrentlyEmoting = false

    local interactEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact")

    local function updateEmoteStatus()
        if not LocalPlayer.Character then
            isCurrentlyEmoting = false
            return
        end
        local state = LocalPlayer.Character:GetAttribute("State")
        isCurrentlyEmoting = state and string.find(state, "Emoting")
    end

    local function isPlayerDowned(pl)
        if not pl or not pl.Character then return false end
        local char = pl.Character
        if char:GetAttribute("Downed") then return true end
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.Health <= 0 then return true end
        return false
    end

    local function reviveLoop()
        while enabled do
            if isCurrentlyEmoting and not Options.ReviveWhileEmoteToggle.Value then
                task.wait(0.3)
                continue
            end

            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local myHRP = myChar.HumanoidRootPart

                for _, pl in Players:GetPlayers() do
                    if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        if isPlayerDowned(pl) then
                            local dist = (myHRP.Position - pl.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= reviveRange then
                                pcall(function()
                                    interactEvent:FireServer("Revive", true, pl.Name)
                                end)
                            end
                        end
                    end
                end
            end

            task.wait(loopDelay)
        end
    end

    local function start()
        if handle then return end
        enabled = true
        updateEmoteStatus()

        if LocalPlayer.Character then
            stateConnection = LocalPlayer.Character:GetAttributeChangedSignal("State"):Connect(updateEmoteStatus)
        end
        LocalPlayer.CharacterAdded:Connect(function(char)
            if stateConnection then stateConnection:Disconnect() end
            stateConnection = char:GetAttributeChangedSignal("State"):Connect(updateEmoteStatus)
            updateEmoteStatus()
        end)

        handle = task.spawn(reviveLoop)
    end

    local function stop()
        enabled = false
        if handle then task.cancel(handle) handle = nil end
        if stateConnection then stateConnection:Disconnect() stateConnection = nil end
        isCurrentlyEmoting = false
    end

    return {
        Start = start,
        Stop = stop,
        SetDelay = function(d) loopDelay = d end,
    }
end)()

InstantReviveToggle:OnChanged(function(state)
    if state then
        InstantReviveModule.SetDelay(getgenv().InstantReviveDelay)
        InstantReviveModule.Start()
    else
        InstantReviveModule.Stop()
    end
end)

ReviveDelaySlider:OnChanged(function(value)
    getgenv().InstantReviveDelay = value
    InstantReviveModule.SetDelay(value)
end)

-- ==================== INSTANT REVIVE MODULE GUI BUTTON ====================

local instantReviveButtonScreenGui = nil
local instantReviveButton = nil
local instantReviveKeybindValue = "R"
local instantReviveButtonState = false

local function createInstantReviveButton()
    local CoreGui = game:GetService("CoreGui")
    
    if instantReviveButtonScreenGui then
        instantReviveButtonScreenGui:Destroy()
        instantReviveButtonScreenGui = nil
    end
    
    instantReviveButtonScreenGui = Instance.new("ScreenGui")
    instantReviveButtonScreenGui.Name = "InstantReviveButtonGUI"
    instantReviveButtonScreenGui.ResetOnSpawn = false
    instantReviveButtonScreenGui.Parent = CoreGui
    
    local buttonSize = 190
    local btnWidth = math.max(150, math.min(buttonSize, 400))
    local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
    
    -- Позиционируем кнопку ниже других кнопок
    local btn, clicker, stroke = createGradientButton(
        instantReviveButtonScreenGui,
        UDim2.new(0.5, -btnWidth/2, 0.5, 0),
        UDim2.new(0, btnWidth, 0, btnHeight),
        instantReviveButtonState and "Instant Revive:On" or "Instant Revive:Off"
    )
    
    clicker.MouseButton1Click:Connect(function()
        -- Переключаем состояние
        instantReviveButtonState = not instantReviveButtonState
        
        -- Обновляем текст кнопки
        if btn:FindFirstChild("TextLabel") then
            btn.TextLabel.Text = instantReviveButtonState and "Instant Revive:On" or "Instant Revive:Off"
        end
        
        -- Управляем модулем Instant Revive напрямую
        if instantReviveButtonState then
            InstantReviveModule.SetDelay(getgenv().InstantReviveDelay)
            InstantReviveModule.Start()
        else
            InstantReviveModule.Stop()
        end
        
        -- Синхронизируем с тумблером если он существует
        if Options.InstantReviveToggle then
            Options.InstantReviveToggle:SetValue(instantReviveButtonState)
        end
    end)
    
    instantReviveButton = btn
    return instantReviveButtonScreenGui
end

-- Добавляем тумблер для кнопки GUI в MiscTab
InstantReviveButtonToggle = MiscTab:AddToggle("InstantReviveButtonToggle", {
    Title = "Instant Revive Button GUI",
    Default = false,
    Callback = function(Value)
        if Value then
            createInstantReviveButton()
        else
            if instantReviveButtonScreenGui then
                instantReviveButtonScreenGui:Destroy()
                instantReviveButtonScreenGui = nil
            end
        end
    end
})

-- Добавляем ключ для Instant Revive
InstantReviveKeybind = MiscTab:AddKeybind("InstantReviveKeybind", {
    Title = "Instant Revive Keybind",
    Mode = "Toggle",
    Default = "R",
    ChangedCallback = function(New)
        instantReviveKeybindValue = New
    end,
    Callback = function()
        -- Переключаем состояние кнопки
        instantReviveButtonState = not instantReviveButtonState
        
        -- Управляем модулем Instant Revive напрямую
        if instantReviveButtonState then
            InstantReviveModule.SetDelay(getgenv().InstantReviveDelay)
            InstantReviveModule.Start()
        else
            InstantReviveModule.Stop()
        end
        
        -- Обновляем GUI кнопку если она существует
        if instantReviveButtonScreenGui and instantReviveButtonScreenGui:FindFirstChild("GradientBtn") then
            local button = instantReviveButtonScreenGui:FindFirstChild("GradientBtn")
            if button and button:FindFirstChild("TextLabel") then
                button.TextLabel.Text = instantReviveButtonState and "Instant Revive:On" or "Instant Revive:Off"
            end
        end
        
        -- Синхронизируем с тумблером
        if Options.InstantReviveToggle then
            Options.InstantReviveToggle:SetValue(instantReviveButtonState)
        end
    end
})

InstantReviveButtonSizeInput = MiscTab:AddInput("InstantReviveButtonSizeInput", {
    Title = "Instant Revive Button Scale",
    Default = "1.0",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local scale = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("InstantReviveButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local uiScale = button:FindFirstChild("UIScale") or Instance.new("UIScale")
                    uiScale.Scale = math.max(0.5, math.min(scale, 3.0))
                    uiScale.Parent = button
                end
            end
        end
    end
})

-- Обновляем текст GUI кнопки при изменении состояния Instant Revive через тумблер
InstantReviveToggle:OnChanged(function(Value)
    instantReviveButtonState = Value
    
    -- Обновляем GUI кнопку если она существует
    if instantReviveButtonScreenGui and instantReviveButtonScreenGui:FindFirstChild("GradientBtn") then
        local button = instantReviveButtonScreenGui:FindFirstChild("GradientBtn")
        if button and button:FindFirstChild("TextLabel") then
            button.TextLabel.Text = instantReviveButtonState and "Instant Revive: On" or "Instant Revive: Off"
        end
    end
end)

-- Обновляем GUI кнопку при включении/выключении InstantReviveButtonToggle
InstantReviveButtonToggle:OnChanged(function(Value)
    if Value then
        createInstantReviveButton()
    else
        if instantReviveButtonScreenGui then
            instantReviveButtonScreenGui:Destroy()
            instantReviveButtonScreenGui = nil
        end
    end
end)

MiscTab:AddSection("Carry Players")

AutoCarryToggle = MiscTab:AddToggle("AutoCarryToggle", {
    Title = "Auto Carry",
    Default = false
})

CarryGUIToggle = MiscTab:AddToggle("CarryGUIToggle", {
    Title = "Carry GUI Button",
    Default = false
})

CarryButtonSizeInput = MiscTab:AddInput("CarryButtonSizeInput", {
    Title = "Carry Button Size",
    Default = "190",
    Placeholder = "Enter size (150-400)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local size = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("AutoCarryButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local newWidth = math.max(150, math.min(size, 400))
                    local newHeight = math.max(60, math.min(size * 0.4, 160))
                    button.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end
        end
    end
})

CarryKeybind = MiscTab:AddKeybind("CarryKeybind", {
    Title = "Auto Carry Keybind",
    Mode = "Toggle",
    Default = "F3",
    ChangedCallback = function(New)
        Options.AutoCarryToggle:SetValue(not Options.AutoCarryToggle.Value)
    end
})

local AutoCarryConnection = nil
local featureStates = featureStates or {}
local player = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function startAutoCarry()
    if AutoCarryConnection then return end
    
    AutoCarryConnection = RunService.Heartbeat:Connect(function()
        if not featureStates.AutoCarry then 
            return 
        end
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (hrp.Position - other.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= 20 then
                        local args = { "Carry", [3] = other.Name }
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact"):FireServer(unpack(args))
                        end)
                        task.wait(0.01)
                    end
                end
            end
        end
    end)
end

local function stopAutoCarry()
    if AutoCarryConnection then
        AutoCarryConnection:Disconnect()
        AutoCarryConnection = nil
    end
end

local function toggleAutoCarryGUI()
    local CoreGui = game:GetService("CoreGui")
    local existingScreenGui = CoreGui:FindFirstChild("AutoCarryButtonGUI")
    
    if existingScreenGui then
        existingScreenGui:Destroy()
    else
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AutoCarryButtonGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui
        
        local buttonSize = 190
        if Options.CarryButtonSizeInput and Options.CarryButtonSizeInput.Value and tonumber(Options.CarryButtonSizeInput.Value) then
            buttonSize = tonumber(Options.CarryButtonSizeInput.Value)
        end
        
        local btnWidth = math.max(150, math.min(buttonSize, 400))
        local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
        
        local btn, clicker, stroke = createGradientButton(
            screenGui,
            UDim2.new(0.5, -btnWidth/2, 0.5, -btnHeight/2),
            UDim2.new(0, btnWidth, 0, btnHeight),
            "Auto Carry: Off"
        )
        
        local function updateButtonText()
            if btn and btn:FindFirstChild("TextLabel") then
                btn.TextLabel.Text = featureStates.AutoCarry and "Auto Carry: On" or "Auto Carry: Off"
            end
        end
        
        updateButtonText()
        
        clicker.MouseButton1Click:Connect(function()
            featureStates.AutoCarry = not featureStates.AutoCarry
            updateButtonText()
            
            if featureStates.AutoCarry then
                startAutoCarry()
            else
                stopAutoCarry()
            end
        end)
        
        AutoCarryToggle:OnChanged(function(state)
            featureStates.AutoCarry = state
            updateButtonText()
            
            if state then
                startAutoCarry()
            else
                stopAutoCarry()
            end
        end)
    end
end

AutoCarryToggle:OnChanged(function(state)
    featureStates.AutoCarry = state
    
    if state then
        startAutoCarry()
    else
        stopAutoCarry()
    end
end)

CarryGUIToggle:OnChanged(function(state)
    if state then
        toggleAutoCarryGUI()
    else
        local CoreGui = game:GetService("CoreGui")
        local existingScreenGui = CoreGui:FindFirstChild("AutoCarryButtonGUI")
        if existingScreenGui then
            existingScreenGui:Destroy()
        end
    end
end)


MiscTab:AddSection("Emote Speed")

local originalEmoteSpeeds = {}
local itemsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
if itemsFolder then
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if emotesFolder then
        for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
            if emoteModule:IsA("ModuleScript") then
                local success, emoteData = pcall(require, emoteModule)
                if success and emoteData and emoteData.EmoteInfo then
                    originalEmoteSpeeds[emoteModule.Name] = emoteData.EmoteInfo.SpeedMult
                end
            end
        end
    end
end

local function applyEmoteSpeed(speedValue)
    if not itemsFolder then return end
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if not emotesFolder then return end
    
    for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
        if emoteModule:IsA("ModuleScript") then
            local success, emoteData = pcall(require, emoteModule)
            if success and emoteData and emoteData.EmoteInfo and emoteData.EmoteInfo.SpeedMult ~= 0 then
                emoteData.EmoteInfo.SpeedMult = speedValue
            end
        end
    end
end

local function restoreOriginalEmoteSpeeds()
    if not itemsFolder then return end
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if not emotesFolder then return end
    
    for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
        if emoteModule:IsA("ModuleScript") then
            local originalSpeed = originalEmoteSpeeds[emoteModule.Name]
            if originalSpeed then
                local success, emoteData = pcall(require, emoteModule)
                if success and emoteData and emoteData.EmoteInfo then
                    emoteData.EmoteInfo.SpeedMult = originalSpeed
                end
            end
        end
    end
end

local requiredFields = {
    Friction = true,
    AirStrafeAcceleration = true,
    JumpHeight = true,
    RunDeaccel = true,
    JumpSpeedMultiplier = true,
    JumpCap = true,
    SprintCap = true,
    WalkSpeedMultiplier = true,
    BhopEnabled = true,
    Speed = true,
    AirAcceleration = true,
    RunAccel = true,
    SprintAcceleration = true
}

local function getMatchingTables()
    local matched = {}
    for _, obj in pairs(getgc(true)) do
        if typeof(obj) == "table" then
            local ok = true
            for field in pairs(requiredFields) do
                if rawget(obj, field) == nil then
                    ok = false
                    break
                end
            end
            if ok then
                table.insert(matched, obj)
            end
        end
    end
    return matched
end

local function applySpeedMultiplier(speedMultiplier)
    local targets = getMatchingTables()
    for _, tableObj in ipairs(targets) do
        if tableObj and typeof(tableObj) == "table" then
            pcall(function()
                tableObj.WalkSpeedMultiplier = speedMultiplier
            end)
        end
    end
end

local player = game:GetService("Players").LocalPlayer

local function getPlayerObj()
    local gamePlayers = workspace.Game and workspace.Game.Players
    if not gamePlayers then return nil end
    return gamePlayers:FindFirstChild(player.Name)
end

local playerObj = nil
local connection = nil
local emotingSpeed = 1.5

local function setupConnection(obj)
    if connection then 
        connection:Disconnect() 
        connection = nil
    end
    playerObj = obj
    if not obj then return end
    
    local function onStateChanged()
        local state = obj:GetAttribute("State")
        local targetSpeed = (state == "Emoting") and emotingSpeed or 1.5
        applySpeedMultiplier(targetSpeed)
    end
    
    onStateChanged()
    connection = obj:GetAttributeChangedSignal("State"):Connect(onStateChanged)
end

local function resetMultiplierSpeed()
    emotingSpeed = 1.5
    applySpeedMultiplier(1.5)
end

EmoteSpeedModeDropdown = MiscTab:AddDropdown("EmoteSpeedModeDropdown", {
    Title = "Emote speed mode",
    Values = {"Nah", "Legit", "Multiplier speed"},
    Multi = false,
    Default = "Nah",
    Callback = function(Value)
        if Value == "Nah" then
            resetMultiplierSpeed()
            restoreOriginalEmoteSpeeds()
            if connection then 
                connection:Disconnect() 
                connection = nil
            end
        elseif Value == "Multiplier speed" then
            restoreOriginalEmoteSpeeds()
            setupConnection(getPlayerObj())
            task.spawn(function()
                while Options.EmoteSpeedModeDropdown and Options.EmoteSpeedModeDropdown.Value == "Multiplier speed" do
                    task.wait(2)
                    local current = getPlayerObj()
                    if current ~= playerObj then
                        setupConnection(current)
                    elseif playerObj then
                        local state = playerObj:GetAttribute("State")
                        local targetSpeed = (state == "Emoting") and emotingSpeed or 1.5
                        applySpeedMultiplier(targetSpeed)
                    end
                end
            end)
        elseif Value == "Legit" then
            resetMultiplierSpeed()
            if connection then 
                connection:Disconnect() 
                connection = nil
            end
            local speedValue = featureStates.EmoteSpeedValue or 2
            applyEmoteSpeed(speedValue)
        end
    end
})

EmoteSpeedInput = MiscTab:AddInput("EmoteSpeedInput", {
    Title = "Emote Speed Value",
    Default = "1500",
    Placeholder = "Enter speed value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            featureStates.EmoteSpeedValue = num
            local appliedValue = num / 1000
            
            if Options.EmoteSpeedModeDropdown and Options.EmoteSpeedModeDropdown.Value == "Legit" then
                applyEmoteSpeed(appliedValue)
            elseif Options.EmoteSpeedModeDropdown and Options.EmoteSpeedModeDropdown.Value == "Multiplier speed" then
                emotingSpeed = appliedValue
            end
        end
    end
})

ApplyUnwalkableButton = MiscTab:AddButton({
    Title = "Apply Speed to Unwalkable Emotes",
    Callback = function()
        if not itemsFolder then return end
        
        local emotesFolder = itemsFolder:FindFirstChild("Emotes")
        if not emotesFolder then return end
        
        local speedValue = featureStates.EmoteSpeedValue or 2
        
        for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
            if emoteModule:IsA("ModuleScript") then
                local success, emoteData = pcall(require, emoteModule)
                if success and emoteData and emoteData.EmoteInfo and emoteData.EmoteInfo.SpeedMult == 0 then
                    emoteData.EmoteInfo.SpeedMult = speedValue
                end
            end
        end
    end
})

ResetEmoteSpeedButton = MiscTab:AddButton({
    Title = "Reset Emote Speed",
    Callback = function()
        Fluent:Notify({
            Title = "Emote Speed",
            Content = "Resetting emote speeds...",
            Duration = 3
        })
        restoreOriginalEmoteSpeeds()
        resetMultiplierSpeed()
    end
})

-- ... предыдущий код остается без изменений ...

MiscTab:AddSection("Gun Functions")

GrappleHookToggle = MiscTab:AddButton({
    Title = "Grapplehook",
    Callback = function()
        local success, result = pcall(function()
            local GrappleHook = require(game:GetService("ReplicatedStorage").Tools["GrappleHook"])

            local grappleTask = GrappleHook.Tasks[2]

            -- Супер-улучшенные параметры (лучше чем в обоих файлах)
            local shootMethod = grappleTask.Functions[1].Activations[1].Methods[1]

            -- Максимальные характеристики
            shootMethod.Info.Speed = 10000          -- Ещё быстрее!
            shootMethod.Info.Lifetime = 10.0        -- 10 секунд полёта!
            shootMethod.Info.Gravity = Vector3.new(0, 0, 0)  -- Нет гравитации
            shootMethod.Info.SpreadIncrease = 0     -- Нет разброса
            shootMethod.Info.Cooldown = 0.1         -- Мгновенная перезарядка

            -- Идеальная точность
            grappleTask.MethodReferences.Projectile.Info.SpreadInfo.MaxSpread = 0
            grappleTask.MethodReferences.Projectile.Info.SpreadInfo.MinSpread = 0
            grappleTask.MethodReferences.Projectile.Info.SpreadInfo.ReductionRate = 100

            -- Мгновенная проверка
            local checkMethod = grappleTask.AutomaticFunctions[1].Methods[1]
            checkMethod.Info.Cooldown = 0.1
            checkMethod.CooldownInfo.TestCooldown = 0.1

            -- Бесконечные заряды
            grappleTask.ResourceInfo.Cap = 999999

            -- Общие улучшения
            GrappleHook.Adjustments.ToolViewbob = false
            GrappleHook.Actions.LookBack.Enabled = true
            GrappleHook.Actions.ADS.Enabled = true
            GrappleHook.Actions.ADS.Zoom = 0.5  -- Ближе обзор

            -- Смена приоритетов для мгновенной реакции
            shootMethod.GlobalPriority = 500    -- Высокий приоритет стрельбы
            
            return true
        end)
        
        if success then
            Fluent:Notify({
                Title = "GrappleHook",
                Content = "GrappleHook успешно улучшен!",
                Duration = 5
            })
        else
            Fluent:Notify({
                Title = "GrappleHook Error",
                Content = "Ошибка: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

BreacherToggle = MiscTab:AddButton({
    Title = "Breacher (Portal Gun)",
    Callback = function()
        local success, result = pcall(function()
            local Breacher = require(game:GetService("ReplicatedStorage").Tools.Breacher)

            -- Находим задание с порталами
            local portalTask
            for i, task in ipairs(Breacher.Tasks) do
                if task.ResourceInfo and task.ResourceInfo.Type == "Clip" then
                    portalTask = task
                    break
                end
            end

            if not portalTask then
                portalTask = Breacher.Tasks[2]
            end

            -- ===== 1. БЕСКОНЕЧНЫЕ ЗАРЯДЫ =====
            portalTask.ResourceInfo.Cap = 999999

            -- ===== 2. МАКСИМАЛЬНАЯ ДАЛЬНОСТЬ =====
            local blueShoot = portalTask.Functions[1].Activations[1].Methods[1]  -- Синий портал
            local yellowShoot = portalTask.Functions[2].Activations[1].Methods[1] -- Желтый портал

            blueShoot.Info.Range = 999999
            yellowShoot.Info.Range = 999999

            -- ===== 3. ИДЕАЛЬНАЯ ТОЧНОСТЬ =====
            blueShoot.Info.SpreadIncrease = 0
            yellowShoot.Info.SpreadIncrease = 0

            portalTask.MethodReferences.Portal.Info.SpreadInfo.MaxSpread = 0
            portalTask.MethodReferences.Portal.Info.SpreadInfo.MinSpread = 0
            portalTask.MethodReferences.Portal.Info.SpreadInfo.ReductionRate = 100

            -- ===== 4. МГНОВЕННАЯ ПЕРЕЗАРЯДКА =====
            blueShoot.Info.Cooldown = 0.1
            yellowShoot.Info.Cooldown = 0.1

            -- ===== 5. УБИРАЕМ ВСЕ ОГРАНИЧЕНИЯ =====
            blueShoot.CooldownInfo = {}
            yellowShoot.CooldownInfo = {}
            blueShoot.Requirements = {}
            yellowShoot.Requirements = {}

            -- ===== 6. ОТКЛЮЧАЕМ ВСЁ СВЯЗАННОЕ С ПРИЦЕЛИВАНИЕМ (ADS) =====
            -- Полностью отключаем систему прицеливания
            Breacher.Actions.ADS.Enabled = false  -- ВЫКЛЮЧАЕМ ADS

            -- Убираем DisabledActions связанные с ADS из всех мест
            local unequipMethod = Breacher.Tasks[1].AutomaticFunctions[2].Methods[1]
            unequipMethod.CooldownInfo = {}  -- Убираем DisabledActions = {"ADS"}

            -- Также убираем из других мест, если есть
            if blueShoot.CooldownInfo and blueShoot.CooldownInfo.DisabledActions then
                -- Удаляем "ADS" из списка отключаемых действий
                local newDisabled = {}
                for _, action in ipairs(blueShoot.CooldownInfo.DisabledActions) do
                    if action ~= "ADS" then
                        table.insert(newDisabled, action)
                    end
                end
                blueShoot.CooldownInfo.DisabledActions = newDisabled
            end

            if yellowShoot.CooldownInfo and yellowShoot.CooldownInfo.DisabledActions then
                -- Удаляем "ADS" из списка отключаемых действий
                local newDisabled = {}
                for _, action in ipairs(yellowShoot.CooldownInfo.DisabledActions) do
                    if action ~= "ADS" then
                        table.insert(newDisabled, action)
                    end
                end
                yellowShoot.CooldownInfo.DisabledActions = newDisabled
            end

            -- ===== 7. ПОВЫШАЕМ ПРИОРИТЕТ СТРЕЛЬБЫ =====
            blueShoot.GlobalPriority = 500
            yellowShoot.GlobalPriority = 500
            blueShoot.Priority = 1
            yellowShoot.Priority = 1

            -- ===== 8. СУПЕР-РЕЖИМ: ДОПОЛНИТЕЛЬНЫЕ УЛУЧШЕНИЯ =====
            -- Убираем проверку на заряды
            blueShoot.ResourceAboveZero = false
            yellowShoot.ResourceAboveZero = false

            -- Включаем автоматическую стрельбу
            portalTask.Functions[1].Activations[1].CanHoldDown = true
            portalTask.Functions[2].Activations[1].CanHoldDown = true

            -- Добавляем скорость портала
            if not blueShoot.Info.Speed then
                blueShoot.Info.Speed = 5000
                yellowShoot.Info.Speed = 5000
            end

            -- ===== 9. УЛУЧШАЕМ АНИМАЦИИ =====
            local baseTask = Breacher.Tasks[1]
            baseTask.AutomaticFunctions[1].Methods[1].Info.Cooldown = 0.1
            baseTask.AutomaticFunctions[2].Methods[1].Info.Cooldown = 0.1

            -- ===== 10. УЛУЧШАЕМ ОБЩИЕ НАСТРОЙКИ (БЕЗ ADS) =====
            -- Включаем оглядывание назад
            Breacher.Actions.LookBack.Enabled = true

            -- Настройки анимаций
            Breacher.Adjustments.ToolViewbob = true
            Breacher.Adjustments.AnimationRootStraight = true
            Breacher.Adjustments.TurnWaist = true

            -- Настройки HUD
            Breacher.HUD.CrosshairType = "Accurate"  -- Точечный прицел (просто на экране)
            Breacher.HUD.Colored = true

            -- Убираем Zoom на всякий случай
            if Breacher.Actions.ADS.Zoom then
                Breacher.Actions.ADS.Zoom = nil  -- Удаляем параметр зума
            end
            
            return true
        end)
        
        if success then
            Fluent:Notify({
                Title = "Breacher (Portal Gun)",
                Content = "Portal Gun Successfully upgraded! \n✓ Infinite charges \n✓ Maximum range \n✓ Instant reload",
                Duration = 6
            })
        else
            Fluent:Notify({
                Title = "Breacher Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

SmokeGrenadeToggle = MiscTab:AddButton({
    Title = "Smoke Grenade",
    Callback = function()
        local success, result = pcall(function()
            local SmokeGrenade = require(game:GetService("ReplicatedStorage").Tools["SmokeGrenade"])

            -- ===== 1. БЕСКОНЕЧНЫЕ ГРАНАТЫ =====
            SmokeGrenade.RequiresOwnedItem = false  -- Не требует наличия гранат в инвентаре

            -- Находим метод броска
            local throwMethod = SmokeGrenade.Tasks[1].Functions[1].Activations[1].Methods[1]

            -- Меняем ItemUseIncrement на 0 (не тратит гранаты)
            throwMethod.ItemUseIncrement = {"SmokeGrenade", 0}

            -- ===== 2. БЫСТРЫЕ БРОСКИ =====
            throwMethod.Info.Cooldown = 0.1  -- Быстрая перезарядка (было 1.2)

            -- ===== 3. ДАЛЬНИЙ БРОСОК =====
            throwMethod.Info.ThrowVelocity = 200  -- Сильный бросок (было 40)

            -- ===== 4. АВТОМАТИЧЕСКИЙ БРОСОК =====
            SmokeGrenade.Tasks[1].Functions[1].Activations[1].CanHoldDown = true  -- Можно зажимать кнопку

            -- ===== 5. БОЛЬШАЯ ДЛИТЕЛЬНОСТЬ ДЫМА =====
            -- Добавляем параметры длительности и радиуса дыма
            throwMethod.Info.SmokeDuration = 999  -- Дым держится 999 секунд (16.5 минут!)
            throwMethod.Info.SmokeRadius = 100    -- Радиус дыма 100 studs (огромное облако)
            throwMethod.Info.FadeTime = 60        -- Время рассеивания дыма (60 секунд)

            -- ===== 6. БЫСТРОЕ ВЗЯТИЕ/УБИРАНИЕ =====
            local equipMethod = SmokeGrenade.Tasks[1].AutomaticFunctions[1].Methods[1]
            local unequipMethod = SmokeGrenade.Tasks[1].AutomaticFunctions[2].Methods[1]
            equipMethod.Info.Cooldown = 0.1  -- Быстрое взятие
            unequipMethod.Info.Cooldown = 0.1  -- Быстрое убирание

            -- ===== 7. ПОВЫШАЕМ ПРИОРИТЕТ БРОСКА =====
            throwMethod.GlobalPriority = 500  -- Высокий приоритет

            -- ===== 8. ОТКЛЮЧАЕМ ЛИШНИЕ ПРОВЕРКИ =====
            throwMethod.CooldownInfo = {}  -- Убираем все ограничения кулдауна

            -- ===== 9. УЛУЧШАЕМ HUD =====
            SmokeGrenade.HUD.ShowAmount = false  -- Не показывать количество (бесконечные)

            -- ===== 10. ДОПОЛНИТЕЛЬНЫЕ УЛУЧШЕНИЯ ГРАНАТЫ =====
            -- Если в игре поддерживаются дополнительные параметры:
            throwMethod.Info.Density = 0.9        -- Густота дыма (0-1)
            throwMethod.Info.Color = Color3.new(0.7, 0.7, 0.7)  -- Цвет дыма (серый)
            throwMethod.Info.ExplosionRadius = 20  -- Радиус разлёта дыма при ударе

            -- ===== 11. УБИРАЕМ "Weaponless" ОГРАНИЧЕНИЕ =====
            throwMethod.CooldownInfo.ActivatePhrase = nil  -- Убираем требование

            -- ===== 12. СУПЕР-БЫСТРЫЙ РЕЖИМ =====
            throwMethod.Info.Cooldown = 0.05  -- Мгновенная перезарядка

            -- ===== 13. УЛУЧШАЕМ УПРАВЛЕНИЕ =====
            SmokeGrenade.KeybindInfo.UnequipKeybind = "Backspace"  -- Удобная клавиша

            -- Активируем гранату
            local args = {
                [1] = 0,
                [2] = 20
            }
            
            game:GetService("ReplicatedStorage").Events.Character.ToolAction:FireServer(unpack(args))
            
            return true
        end)
        
        if success then
            Fluent:Notify({
                Title = "Smoke Grenade",
                Content = "Smoke Grenade Improved! \n✓ Infinite Grenades \n✓ Instant Reload",
                Duration = 6
            })
        else
            Fluent:Notify({
                Title = "Smoke Grenade Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

StunBatonToggle = MiscTab:AddButton({
    Title = "Stun Baton",
    Callback = function()
        local success, result = pcall(function()
            local StunBaton = require(game:GetService("ReplicatedStorage").Tools.StunBaton)

            -- Находим все методы
            local task = StunBaton.Tasks[1]

            -- MeleeStart (удачная атака)
            local meleeStart = task.Functions[1].Activations[2].Methods[1]
            meleeStart.Info.Cooldown = 0.05           -- Мгновенно
            meleeStart.Info.LungeRange = 0             -- Огромный выпад
            meleeStart.Info.ImmortalLength = 5         -- Долгая неуязвимость
            meleeStart.Info.SuccessStunLength = 5      -- Долгое оглушение
            meleeStart.CooldownInfo = {}               -- Убираем ограничения
            meleeStart.Requirements = {}                -- Убираем требования

            -- MeleeStartFail (неудачная атака)
            local meleeStartFail = task.Functions[1].Activations[1].Methods[1]
            meleeStartFail.Info.Cooldown = 0.05
            meleeStartFail.Info.LungeRange = 0
            meleeStartFail.Info.ImmortalLength = 5
            meleeStartFail.CooldownInfo = {}

            -- MeleeEnd (успешное завершение)
            local meleeEnd = task.AutomaticFunctions[2].Methods[1]
            meleeEnd.Info.Cooldown = 0.1               -- Мгновенное завершение
            meleeEnd.Info.Damage = 999                  -- Максимальный урон
            meleeEnd.Info.Range = 0                     -- Огромная дальность
            meleeEnd.CooldownInfo = {}

            -- MeleeEndFail (неудачное завершение)
            local meleeEndFail = task.AutomaticFunctions[1].Methods[1]
            meleeEndFail.Info.Cooldown = 0.1            -- Мгновенное
            meleeEndFail.Info.SelfDamage = 0            -- Нет урона по себе
            meleeEndFail.Info.Range = 0
            meleeEndFail.CooldownInfo = {}

            -- Анимации
            local equip = task.AutomaticFunctions[3].Methods[1]
            local unequip = task.AutomaticFunctions[4].Methods[1]
            equip.Info.Cooldown = 0.1                   -- Быстрое взятие
            unequip.Info.Cooldown = 0.1                  -- Быстрое убирание
            unequip.CooldownInfo = {}                     -- Убираем DisabledActions

            -- Общие настройки
            StunBaton.Actions.ADS.Enabled = false        -- Отключаем прицеливание
            StunBaton.Actions.LookBack.Enabled = true    -- Включаем оглядывание
            
            return true
        end)
        
        if success then
            Fluent:Notify({
                Title = "Stun Baton",
                Content = "Stun Baton Successfully upgraded!\n✓ Instant attacks\n✓ 999 damage\n✓ No self damage\n✓ Long stun",
                Duration = 6
            })
        else
            Fluent:Notify({
                Title = "Stun Baton Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

MiscTab:AddSection("Infinity Slide")

local infiniteSlideEnabled = false
local slideFrictionValue = -8
local movementTables = {}
local infiniteSlideHeartbeat = nil
local infiniteSlideCharacterConn = nil
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local requiredKeys = {
    "Friction","AirStrafeAcceleration","JumpHeight","RunDeaccel",
    "JumpSpeedMultiplier","JumpCap","SprintCap","WalkSpeedMultiplier",
    "BhopEnabled","Speed","AirAcceleration","RunAccel","SprintAcceleration"
}

local function hasRequiredFields(tbl)
    if typeof(tbl) ~= "table" then return false end
    for _, key in ipairs(requiredKeys) do
        if rawget(tbl, key) == nil then return false end
    end
    return true
end

local function findMovementTables()
    movementTables = {}
    for _, obj in ipairs(getgc(true)) do
        if hasRequiredFields(obj) then
            table.insert(movementTables, obj)
        end
    end
    return #movementTables > 0
end

local function setSlideFriction(value)
    local appliedCount = 0
    for _, tbl in ipairs(movementTables) do
        pcall(function()
            tbl.Friction = value
            appliedCount = appliedCount + 1
        end)
    end
    if appliedCount == 0 then
        for _, obj in ipairs(getgc(true)) do
            if hasRequiredFields(obj) then
                pcall(function()
                    obj.Friction = value
                end)
            end
        end
    end
end

local function updatePlayerModel()
    local gameFolder = workspace:FindFirstChild("Game")
    if not gameFolder then return false end
    
    local playersFolder = gameFolder:FindFirstChild("Players")
    if not playersFolder then return false end
    
    local playerModel = playersFolder:FindFirstChild(player.Name)
    return playerModel
end

local function infiniteSlideHeartbeatFunc()
    if not infiniteSlideEnabled then return end
    
    local playerModel = updatePlayerModel()
    if not playerModel then return end
    
    local state = playerModel:GetAttribute("State")
    
    if state == "Slide" then
        pcall(function()
            playerModel:SetAttribute("State", "EmotingSlide")
        end)
    elseif state == "EmotingSlide" then
        setSlideFriction(slideFrictionValue)
    else
        setSlideFriction(5)
    end
end

local function onCharacterAddedSlide(character)
    if not infiniteSlideEnabled then return end
    
    for i = 1, 5 do
        task.wait(0.5)
        if updatePlayerModel() then
            break
        end
    end
    
    task.wait(0.5)
    findMovementTables()
end

local function setInfiniteSlide(enabled)
    infiniteSlideEnabled = enabled

    if enabled then
        findMovementTables()
        updatePlayerModel()
        
        if not infiniteSlideCharacterConn then
            infiniteSlideCharacterConn = player.CharacterAdded:Connect(onCharacterAddedSlide)
        end
        
        if player.Character then
            task.spawn(function()
                onCharacterAddedSlide(player.Character)
            end)
        end
        
        if infiniteSlideHeartbeat then infiniteSlideHeartbeat:Disconnect() end
        infiniteSlideHeartbeat = RunService.Heartbeat:Connect(infiniteSlideHeartbeatFunc)
        
    else
        if infiniteSlideHeartbeat then
            infiniteSlideHeartbeat:Disconnect()
            infiniteSlideHeartbeat = nil
        end
        
        if infiniteSlideCharacterConn then
            infiniteSlideCharacterConn:Disconnect()
            infiniteSlideCharacterConn = nil
        end
        
        setSlideFriction(5)
        movementTables = {}
    end
end

InfiniteSlideToggle = MiscTab:AddToggle("InfiniteSlideToggle", {
    Title = "Sprint Slide",
    Default = false,
    Callback = function(Value)
        setInfiniteSlide(Value)
    end
})

SlideFrictionInput = MiscTab:AddInput("SlideFrictionInput", {
    Title = "Slide Speed (Negative only)",
    Default = "-8",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            slideFrictionValue = num
            if infiniteSlideEnabled then
                setSlideFriction(slideFrictionValue)
            end
        end
    end
})

local function createSlideGradientButton()
    local CoreGui = game:GetService("CoreGui")
    
    if slideButtonScreenGui then
        slideButtonScreenGui:Destroy()
        slideButtonScreenGui = nil
    end
    
    slideButtonScreenGui = Instance.new("ScreenGui")
    slideButtonScreenGui.Name = "SlideButtonGUI"
    slideButtonScreenGui.ResetOnSpawn = false
    slideButtonScreenGui.Parent = CoreGui
    
    local buttonSize = 190
    local btnWidth = math.max(150, math.min(buttonSize, 400))
    local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
    
    -- Позиционируем кнопку ниже Auto Jump кнопки
    local btn, clicker, stroke = createGradientButton(
        slideButtonScreenGui,
        UDim2.new(0.5, -btnWidth/2, 0.5, 0),
        UDim2.new(0, btnWidth, 0, btnHeight),
        infiniteSlideEnabled and "Sprint Slide: On" or "Sprint Slide: Off"
    )
    
    -- Применяем масштаб если он был установлен
    if Options.SlideButtonScaleInput and Options.SlideButtonScaleInput.Value then
        local scaleValue = tonumber(Options.SlideButtonScaleInput.Value) or 1.0
        local uiScale = Instance.new("UIScale")
        uiScale.Scale = math.max(0.5, math.min(scaleValue, 3.0))
        uiScale.Parent = btn
    end
    
    clicker.MouseButton1Click:Connect(function()
        infiniteSlideEnabled = not infiniteSlideEnabled
        setInfiniteSlide(infiniteSlideEnabled)
        
        if btn:FindFirstChild("TextLabel") then
            btn.TextLabel.Text = infiniteSlideEnabled and "Sprint Slide: On" or "Sprint Slide: Off"
        end
        
        if Options.InfiniteSlideToggle then
            Options.InfiniteSlideToggle:SetValue(infiniteSlideEnabled)
        end
    end)
    
    return slideButtonScreenGui
end

-- Обнови функцию updateSlideButtonText
local function updateSlideButtonText()
    if slideButtonScreenGui and slideButtonScreenGui:FindFirstChild("GradientBtn") then
        local button = slideButtonScreenGui:FindFirstChild("GradientBtn")
        if button and button:FindFirstChild("TextLabel") then
            button.TextLabel.Text = infiniteSlideEnabled and "Sprint Slide: On" or "Sprint Slide: Off"
        end
    end
end

SlideButtonToggle = MiscTab:AddToggle("SlideButtonToggle", {
    Title = "Sprint Slide Button GUI",
    Default = false,
    Callback = function(Value)
        if Value then
            createSlideGradientButton()
        else
            if slideButtonScreenGui then
                slideButtonScreenGui:Destroy()
                slideButtonScreenGui = nil
            end
        end
    end
})

SlideButtonScaleInput = MiscTab:AddInput("SlideButtonScaleInput", {
    Title = "Sprint Slide Button Scale",
    Default = "1.0",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local scale = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("SlideButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local uiScale = button:FindFirstChild("UIScale") or Instance.new("UIScale")
                    uiScale.Scale = math.max(0.5, math.min(scale, 3.0))
                    uiScale.Parent = button
                    
                    Fluent:Notify({
                        Title = "Sprint Slide Button",
                        Content = string.format("Button scale set to %.1f", scale),
                        Duration = 3
                    })
                end
            end
        end
    end
})

-- Добавляем ключ для Sprint Slide
SlideKeybind = MiscTab:AddKeybind("SlideKeybind", {
    Title = "Sprint Slide Keybind",
    Mode = "Toggle",
    Default = "X", -- Или любая другая клавиша по умолчанию
    ChangedCallback = function(New)
        -- Опционально: можно сохранить значение для отображения
    end,
    Callback = function()
        infiniteSlideEnabled = not infiniteSlideEnabled
        setInfiniteSlide(infiniteSlideEnabled)
        
        if Options.InfiniteSlideToggle then
            Options.InfiniteSlideToggle:SetValue(infiniteSlideEnabled)
        end
        
        updateSlideButtonText()
    end
})

MiscTab:AddSection("Gravity")

local gravityEnabled = false
local originalGravity = workspace.Gravity
local gravityValue = 10
local gravityHeartbeat = nil
local gravityKeybindValue = "G"

local function createGravityButton()
    local CoreGui = game:GetService("CoreGui")
    local existingScreenGui = CoreGui:FindFirstChild("GravityButtonGUI")
    
    if existingScreenGui then
        existingScreenGui:Destroy()
    else
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "GravityButtonGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui
        
        local buttonSize = 190
        local btnWidth = math.max(150, math.min(buttonSize, 400))
        local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
        
        local btn, clicker, stroke = createGradientButton(
            screenGui,
            UDim2.new(0.5, -btnWidth/2, 0.5, 60),
            UDim2.new(0, btnWidth, 0, btnHeight),
            gravityEnabled and "Gravity: On" or "Gravity: Off"
        )
        
        clicker.MouseButton1Click:Connect(function()
            gravityEnabled = not gravityEnabled
            if btn:FindFirstChild("TextLabel") then
                btn.TextLabel.Text = gravityEnabled and "Gravity: On" or "Gravity: Off"
            end
            
            if gravityEnabled then
                workspace.Gravity = gravityValue
            else
                workspace.Gravity = originalGravity
            end
        end)
    end
end

GravityToggle = MiscTab:AddToggle("GravityToggle", {
    Title = "Gravity",
    Default = false,
    Callback = function(Value)
        gravityEnabled = Value
        
        if Value then
            workspace.Gravity = gravityValue
        else
            workspace.Gravity = originalGravity
        end
    end
})

GravityButtonToggle = MiscTab:AddToggle("GravityButtonToggle", {
    Title = "Gravity Button GUI",
    Default = false,
    Callback = function(Value)
        if Value then
            createGravityButton()
        else
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("GravityButtonGUI")
            if existingScreenGui then
                existingScreenGui:Destroy()
            end
        end
    end
})

GravityKeybind = MiscTab:AddKeybind("GravityKeybind", {
    Title = "Gravity Keybind",
    Mode = "Toggle",
    Default = "G",
    ChangedCallback = function(New)
        gravityKeybindValue = New
    end,
    Callback = function()
        toggleGravity()
    end
})

GravityAdjustmentInput = MiscTab:AddInput("GravityAdjustmentInput", {
    Title = "Gravity Adjustment",
    Default = "10",
    Placeholder = "Enter gravity value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            gravityValue = num
            if gravityEnabled then
                workspace.Gravity = gravityValue
            end
        end
    end
})

originalGravity = workspace.Gravity

GravityToggle:OnChanged(function(state)
    if Options.GravityButtonToggle and Options.GravityButtonToggle.Value then
        local CoreGui = game:GetService("CoreGui")
        local screenGui = CoreGui:FindFirstChild("GravityButtonGUI")
        if screenGui then
            local button = screenGui:FindFirstChild("GradientBtn")
            if button and button:FindFirstChild("TextLabel") then
                button.TextLabel.Text = state and "Gravity: On" or "Gravity: Off"
            end
        end
    end
end)
GravityButtonSizeInput = MiscTab:AddInput("GravityButtonSizeInput", {
    Title = "Gravity Button Size",
    Default = "1",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local scale = tonumber(Value)
            scale = math.max(0.5, math.min(scale, 3.0))
            
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("GravityButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local uiScale = button:FindFirstChild("UIScale") or Instance.new("UIScale")
                    uiScale.Scale = scale
                    uiScale.Parent = button
                end
            end
        end
    end
})

MiscTab:AddSection("Auto Jump")

-- ==================== IMPROVED AUTO JUMP/BHOP SYSTEM ====================

local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Основные переменные
getgenv().autoJumpType = "Bounce"
getgenv().bhopMode = "Acceleration"
getgenv().bhopAccelValue = -0.5
getgenv().bhopHoldActive = false
getgenv().autoJumpEnabled = false
getgenv().jumpCooldown = 0.7
getgenv().rotationEnabled = false -- ★ ДОБАВЛЕНО: переменная для вращения

featureStates = featureStates or {}
featureStates.Bhop = false
featureStates.BhopHold = false

local bhopConnection = nil
local bhopLoaded = false
local characterConnection = nil
local frictionTables = {}
local Character = nil
local Humanoid = nil
local HumanoidRootPart = nil
local LastJump = 0
local GROUND_CHECK_OFFSET = 3.5
local GROUND_CHECK_RAY_LENGTH = 4
local MAX_SLOPE_ANGLE = 45
local bhopButtonScreenGui = nil
local rotationConnection = nil -- ★ ДОБАВЛЕНО: соединение для вращения
local rotationSpeed = 100000 -- ★ ДОБАВЛЕНО: скорость вращения (градусов в секунду)

-- ★ ДОБАВЛЕНО: Функция для вращения персонажа
local function startRotation()
    if rotationConnection then
        rotationConnection:Disconnect()
        rotationConnection = nil
    end
    
    if not getgenv().rotationEnabled or not HumanoidRootPart then return end
    
    rotationConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if HumanoidRootPart and HumanoidRootPart.Parent then
            -- Получаем текущее вращение
            local currentRotation = HumanoidRootPart.Orientation
            -- Изменяем только ось Y
            local newRotation = Vector3.new(
                currentRotation.X,
                currentRotation.Y + (rotationSpeed * deltaTime),
                currentRotation.Z
            )
            -- Применяем новое вращение
            HumanoidRootPart.Orientation = newRotation
        else
            -- Останавливаем вращение если части больше нет
            if rotationConnection then
                rotationConnection:Disconnect()
                rotationConnection = nil
            end
        end
    end)
end

-- ★ ДОБАВЛЕНО: Функция для остановки вращения
local function stopRotation()
    if rotationConnection then
        rotationConnection:Disconnect()
        rotationConnection = nil
    end
end

-- ★ ДОБАВЛЕНО: Обновляем состояние вращения
local function updateRotationState()
    if getgenv().rotationEnabled and getgenv().autoJumpEnabled then
        startRotation()
    else
        stopRotation()
    end
end

-- Функция для создания градиентной кнопки (должна быть уже объявлена выше)
-- Если её нет, вот базовая версия:
local function createGradientButton(parent, position, size, text, onClickCallback)
    local button = Instance.new("Frame")
    button.Name = "GradientBtn"
    button.BackgroundTransparency = 0.7
    button.Size = size
    button.Position = position
    button.Draggable = true
    button.Active = true
    button.Selectable = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    gradient.Rotation = 0
    gradient.Parent = button

    local gradientAnimation
    gradientAnimation = RunService.RenderStepped:Connect(function(delta)
        gradient.Rotation = (gradient.Rotation + 90 * delta) % 360
    end)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(139, 0, 0)  -- Темно-красный (обычное состояние)
    stroke.Thickness = 2
    stroke.Parent = button

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.Parent = button

    local clicker = Instance.new("TextButton")
    clicker.Size = UDim2.new(1, 0, 1, 0)
    clicker.BackgroundTransparency = 1
    clicker.Text = ""
    clicker.ZIndex = 5
    clicker.Parent = button

    button.Destroying:Connect(function()
        if gradientAnimation then
            gradientAnimation:Disconnect()
        end
    end)

    -- ==================== ПЕРЕТАСКИВАНИЕ С ЗАЩИТОЙ ОТ МУЛЬТИТАЧ ====================
    local UserInputService = game:GetService("UserInputService")
    local activeTouchId = nil  -- ID активного пальца
    local startPos = nil
    local startButtonPos = nil
    
    -- Функция для обновления позиции кнопки
    local function updateButtonPosition(touchPos)
        if not startPos or not startButtonPos then return end
        local delta = touchPos - startPos
        button.Position = UDim2.new(startButtonPos.X.Scale, startButtonPos.X.Offset + delta.X,
                                    startButtonPos.Y.Scale, startButtonPos.Y.Offset + delta.Y)
    end
    
    -- Сброс состояния
    local function resetDrag()
        activeTouchId = nil
        startPos = nil
        startButtonPos = nil
        stroke.Color = Color3.fromRGB(139, 0, 0)  -- Возвращаем темно-красный
    end
    
    -- Начало касания (мобильные устройства)
    clicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local touchId = input.UserInputState
            
            -- Если уже есть активный палец - игнорируем остальные
            if activeTouchId ~= nil then
                return
            end
            
            activeTouchId = touchId
            startPos = input.Position
            startButtonPos = button.Position
            
            -- Меняем цвет на ярко-красный при нажатии
            stroke.Color = Color3.fromRGB(255, 0, 0)
            
            -- Обработка окончания касания
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resetDrag()
                    connection:Disconnect()
                end
            end)
            
        -- Для мыши
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            if activeTouchId ~= nil then return end
            
            activeTouchId = "mouse"
            startPos = input.Position
            startButtonPos = button.Position
            
            stroke.Color = Color3.fromRGB(255, 0, 0)
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resetDrag()
                    connection:Disconnect()
                end
            end)
        end
    end)

    -- Обработка движения пальца/мыши
    clicker.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            if activeTouchId ~= nil then
                updateButtonPosition(input.Position)
            end
        elseif input.UserInputType == Enum.UserInputType.MouseMovement then
            if activeTouchId ~= nil then
                updateButtonPosition(input.Position)
            end
        end
    end)

    return button, clicker, stroke
end

-- ==================== КНОПКА GUI ДЛЯ AUTO JUMP ====================

local function createBhopGradientButton()
    local CoreGui = game:GetService("CoreGui")
    
    if bhopButtonScreenGui then
        bhopButtonScreenGui:Destroy()
        bhopButtonScreenGui = nil
    end
    
    bhopButtonScreenGui = Instance.new("ScreenGui")
    bhopButtonScreenGui.Name = "BhopButtonGUI"
    bhopButtonScreenGui.ResetOnSpawn = false
    bhopButtonScreenGui.Parent = CoreGui
    
    local buttonSize = 190
    local btnWidth = math.max(150, math.min(buttonSize, 400))
    local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
    
    local btn, clicker, stroke = createGradientButton(
        bhopButtonScreenGui,
        UDim2.new(0.5, -btnWidth/2, 0.5, 120),
        UDim2.new(0, btnWidth, 0, btnHeight),
        getgenv().autoJumpEnabled and "Auto Jump: On" or "Auto Jump: Off"
    )
    
    clicker.MouseButton1Click:Connect(function()
        getgenv().autoJumpEnabled = not getgenv().autoJumpEnabled
        featureStates.Bhop = getgenv().autoJumpEnabled
        
        if btn:FindFirstChild("TextLabel") then
            btn.TextLabel.Text = getgenv().autoJumpEnabled and "Auto Jump: On" or "Auto Jump: Off"
        end
        
        if Options.BhopToggle then
            Options.BhopToggle:SetValue(getgenv().autoJumpEnabled)
        end
        
        checkBhopState() 
    end)
    
    return bhopButtonScreenGui
end

local function updateBhopButtonText()
    if bhopButtonScreenGui and bhopButtonScreenGui:FindFirstChild("GradientBtn") then
        local button = bhopButtonScreenGui:FindFirstChild("GradientBtn")
        if button and button:FindFirstChild("TextLabel") then
            button.TextLabel.Text = getgenv().autoJumpEnabled and "Auto Jump: On" or "Auto Jump: Off"
        end
    end
end

-- ==================== ЛОГИКА AUTO JUMP ====================

-- Улучшенная функция для определения, находится ли персонаж на земле
local function IsOnGround()
    if not Character or not HumanoidRootPart or not Humanoid then 
        return false 
    end
    
    local state = Humanoid:GetState()
    if state == Enum.HumanoidStateType.Jumping or 
       state == Enum.HumanoidStateType.Freefall or
       state == Enum.HumanoidStateType.Swimming then
        return false
    end
    
    if Humanoid:GetState() == Enum.HumanoidStateType.Running then
        return true
    end
    
    -- Улучшенная проверка через Raycast
    local rayOrigin = HumanoidRootPart.Position
    local rayDirection = Vector3.new(0, -GROUND_CHECK_RAY_LENGTH, 0)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {Character}
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if raycastResult then
        local surfaceNormal = raycastResult.Normal
        local angle = math.deg(math.acos(surfaceNormal:Dot(Vector3.new(0, 1, 0))))
        
        -- Проверка угла поверхности
        if angle <= MAX_SLOPE_ANGLE then
            -- Дополнительная проверка высоты
            local heightDiff = math.abs(rayOrigin.Y - raycastResult.Position.Y)
            return heightDiff <= GROUND_CHECK_OFFSET
        end
    end
    
    -- Альтернативная проверка через скорость по оси Y
    if HumanoidRootPart.Velocity.Y > -1 and HumanoidRootPart.Velocity.Y < 1 then
        return true
    end
    
    return false
end

-- Функция для нахождения таблиц с трением
local function findFrictionTables()
    frictionTables = {}
    
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "Friction") then
            table.insert(frictionTables, {
                obj = obj,
                original = obj.Friction
            })
        end
    end
end

-- Функция для применения/сброса трения
local function applyBhopFriction()
    local isActive = getgenv().autoJumpEnabled or getgenv().bhopHoldActive
    
    if isActive and getgenv().bhopMode == "Acceleration" then
        if #frictionTables == 0 then
            findFrictionTables()
        end
        
        for _, tableData in ipairs(frictionTables) do
            if tableData.obj and type(tableData.obj) == "table" then
                pcall(function()
                    tableData.obj.Friction = getgenv().bhopAccelValue or -0.5
                end)
            end
        end
    else
        -- Сбрасываем трение
        for _, tableData in ipairs(frictionTables) do
            if tableData.obj and type(tableData.obj) == "table" and tableData.original then
                pcall(function()
                    tableData.obj.Friction = tableData.original
                end)
            end
        end
    end
end

-- Основная функция автопрыжка (Bounce ИСПРАВЛЕН)
local function updateBhop()
    if not bhopLoaded then return end

    local isActive = getgenv().autoJumpEnabled or getgenv().bhopHoldActive

    if isActive then
        -- Проверяем состояние персонажа
        if not Character or not Humanoid or not HumanoidRootPart then
            Character = player.Character
            if Character then
                Humanoid = Character:FindFirstChildOfClass("Humanoid")
                HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            end
            if not Humanoid or not HumanoidRootPart then return end
        end

        -- Проверяем, жив ли персонаж
        if Humanoid:GetState() == Enum.HumanoidStateType.Dead then
            return
        end
        
        -- Проверяем кулдаун
        local now = tick()
        
        if getgenv().autoJumpType == "Realistic" then
            -- REALISTIC: Спамим событиями всегда
            pcall(function()
                player.PlayerScripts.Events.temporary_events.JumpReact:Fire()
                player.PlayerScripts.Events.temporary_events.EndJump:Fire()
            end)
            
        else  -- BOUNCE: Только на земле и с кулдауном!
            if IsOnGround() and (now - LastJump) > 0.25 then  -- Кулдаун 0.25 секунды
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                LastJump = now
            end
        end
    end
end

-- Загрузка системы автопрыжка
local function loadBhop()
    if bhopLoaded then return end
    
    print("Bhop System: Loading...")
    
    bhopLoaded = true
    
    -- Находим таблицы с трением
    findFrictionTables()
    
    -- Применяем трение если нужно
    applyBhopFriction()
    
    -- Запускаем основной цикл
    if bhopConnection then
        bhopConnection:Disconnect()
    end
    
    bhopConnection = RunService.Heartbeat:Connect(function(deltaTime)
        updateBhop()
    end)
    
    print("Bhop System: Loaded successfully")
end

-- Выгрузка системы
local function unloadBhop()
    if not bhopLoaded then return end
    
    print("Bhop System: Unloading...")
    
    bhopLoaded = false
    
    if bhopConnection then
        bhopConnection:Disconnect()
        bhopConnection = nil
    end
    
    getgenv().bhopHoldActive = false
    applyBhopFriction() -- Сбрасываем трение
    
    print("Bhop System: Unloaded")
end

-- Проверка состояния системы
local function checkBhopState()
    local shouldLoad = getgenv().autoJumpEnabled or getgenv().bhopHoldActive
    
    if shouldLoad then
        loadBhop()
        updateRotationState() -- ★ ДОБАВЛЕНО: Обновляем вращение при загрузке Bhop
    else
        unloadBhop()
        stopRotation() -- ★ ДОБАВЛЕНО: Останавливаем вращение при выгрузке Bhop
    end
end

-- Восстановление после респавна
local function reapplyBhopOnRespawn()
    if getgenv().autoJumpEnabled or getgenv().bhopHoldActive then
        task.wait(1) -- Даем время персонажу заспавниться
        Character = player.Character
        if Character then
            Humanoid = Character:FindFirstChildOfClass("Humanoid")
            HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        end
        checkBhopState()
    end
end

-- Настройка обработки прыжка для мобильных устройств
local function setupJumpButton()
    local isMobile = UserInputService.TouchEnabled
    
    if isMobile then
        task.spawn(function()
            task.wait(2) -- Даем время GUI загрузиться
            
            local success, err = pcall(function()
                local touchGui = player:WaitForChild("PlayerGui"):WaitForChild("TouchGui")
                if not touchGui then return end
                
                local touchControlFrame = touchGui:WaitForChild("TouchControlFrame")
                if not touchControlFrame then return end
                
                local jumpButton = touchControlFrame:WaitForChild("JumpButton")
                if not jumpButton then return end
                
                jumpButton.MouseButton1Down:Connect(function()
                    if featureStates.BhopHold then
                        getgenv().bhopHoldActive = true
                        checkBhopState()
                    end
                end)
                
                jumpButton.MouseButton1Up:Connect(function()
                    getgenv().bhopHoldActive = false
                    checkBhopState()
                end)
            end)
            
            if not success then
                print("Mobile jump button setup failed:", err)
            end
        end)
    end
end

-- ==================== UI ЭЛЕМЕНТЫ ====================

-- ... (существующий код)

-- ==================== UI ЭЛЕМЕНТЫ ====================

AutoJumpTypeDropdown = MiscTab:AddDropdown("AutoJumpTypeDropdown", {
    Title = "Auto Jump Type",
    Values = {"Bounce", "Realistic"},
    Multi = false,
    Default = "Bounce",
    Callback = function(Value)
        getgenv().autoJumpType = Value
    end
})

-- ★ ДОБАВЛЕНО: НОВЫЙ ТУМБЛЕР ДЛЯ ВРАЩЕНИЯ
RotationToggle = MiscTab:AddToggle("RotationToggle", {
    Title = "Rotation 360",
    Description = "Do not use with emotions!",
    Default = false,
    Callback = function(Value)
        getgenv().rotationEnabled = Value
        updateRotationState() -- ★ Вызываем функцию обновления состояния вращения
    end
})

BhopToggle = MiscTab:AddToggle("BhopToggle", {
    Title = "Bunny Hop",
    Default = false,
    Callback = function(Value)
        featureStates.Bhop = Value
        getgenv().autoJumpEnabled = Value
        
        updateBhopButtonText()
        updateRotationState() -- ★ ДОБАВЛЕНО: обновляем состояние вращения
        checkBhopState() 
    end
})

BhopHoldToggle = MiscTab:AddToggle("BhopHoldToggle", {
    Title = "Bhop Hold (Hold Space/Jump)",
    Default = false,
    Callback = function(Value)
        featureStates.BhopHold = Value
        if not Value then
            getgenv().bhopHoldActive = false
            checkBhopState() 
        end
    end
})

BhopButtonToggle = MiscTab:AddToggle("BhopButtonToggle", {
    Title = "Bhop Button GUI",
    Default = false,
    Callback = function(Value)
        if Value then
            createBhopGradientButton()
        else
            if bhopButtonScreenGui then
                bhopButtonScreenGui:Destroy()
                bhopButtonScreenGui = nil
            end
        end
    end
})

BhopKeybind = MiscTab:AddKeybind("BhopKeybind", {
    Title = "Bhop Keybind",
    Mode = "Toggle",
    Default = "B",
    ChangedCallback = function(New)
    end,
    Callback = function()
        getgenv().autoJumpEnabled = not getgenv().autoJumpEnabled
        featureStates.Bhop = getgenv().autoJumpEnabled
        
        if Options.BhopToggle then
            Options.BhopToggle:SetValue(getgenv().autoJumpEnabled)
        end
        
        updateBhopButtonText()
        checkBhopState()
    end
})

BhopModeDropdown = MiscTab:AddDropdown("BhopModeDropdown", {
    Title = "Bhop Mode",
    Values = {"Acceleration", "No Acceleration"},
    Multi = false,
    Default = "Acceleration",
    Callback = function(Value)
        getgenv().bhopMode = Value
        checkBhopState()
    end
})

BhopAccelInput = MiscTab:AddInput("BhopAccelInput", {
    Title = "Bhop Acceleration",
    Default = "-0.5",
    Placeholder = "Enter negative value (e.g., -0.5)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and string.sub(Value, 1, 1) == "-" then
            getgenv().bhopAccelValue = num
            if getgenv().autoJumpEnabled or getgenv().bhopHoldActive then
                applyBhopFriction()
            end
        end
    end
})

JumpCooldownInput = MiscTab:AddInput("JumpCooldownInput", {
    Title = "Jump Cooldown (Seconds)",
    Default = "0.7",
    Placeholder = "Enter cooldown in seconds",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            getgenv().jumpCooldown = num
        end
    end
})

-- ==================== ИНИЦИАЛИЗАЦИЯ ====================

-- Обновление ссылок на персонажа
RunService.Heartbeat:Connect(function()
    if not Character or not Character:IsDescendantOf(workspace) then
        Character = player.Character
        if Character then
            Humanoid = Character:FindFirstChildOfClass("Humanoid")
            HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            
            -- ★ ДОБАВЛЕНО: Обновляем состояние вращения при изменении персонажа
            updateRotationState()
        else
            Humanoid = nil
            HumanoidRootPart = nil
            stopRotation() -- ★ ДОБАВЛЕНО: останавливаем вращение
        end
    end
end)

-- Подписка на события персонажа
if characterConnection then
    characterConnection:Disconnect()
end

characterConnection = player.CharacterAdded:Connect(function(character)
    Character = character
    task.wait(0.5)
    Humanoid = character:WaitForChild("Humanoid")
    HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    setupJumpButton()
    reapplyBhopOnRespawn()
    updateRotationState() -- ★ ДОБАВЛЕНО: Обновляем состояние вращения при респавне
    
    print("Character added, Bhop system ready")
end)

-- Обработка нажатий клавиш (для ПК)
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    
    if input.KeyCode == Enum.KeyCode.Space and featureStates.BhopHold then
        getgenv().bhopHoldActive = true
        checkBhopState()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        getgenv().bhopHoldActive = false
        checkBhopState()
    end
end)

-- Инициализация при старте скрипта
task.spawn(function()
    task.wait(2)
    
    if player.Character then
        Character = player.Character
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    end
    
    setupJumpButton()
    
    if featureStates.Bhop then
        checkBhopState()
    end
    
    -- Создаем кнопку если она включена
    task.wait(1)
    if Options.BhopButtonToggle and Options.BhopButtonToggle.Value then
        createBhopGradientButton()
    end
end)

-- Очистка при выходе из игры
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        unloadBhop()
        stopRotation() -- ★ ДОБАВЛЕНО: Останавливаем вращение
        
        if characterConnection then
            characterConnection:Disconnect()
            characterConnection = nil
        end
    end
end)

MiscTab:AddSection("Lag Switch")

local lagSwitchEnabled = false
local lagSwitchKeybindValue = "F12"
local lagDelayValue = 0.1
local lagIntensity = 1000000
local lagSwitchMode = "Normal" -- "Normal" или "Demon"
local isLagActive = false

-- Обычный режим лаг свича (математические операции)
local function performMathLag()
    local startTime = tick()
    local duration = lagDelayValue
    
    while tick() - startTime < duration do
        for i = 1, lagIntensity do
            local a = math.random(1, 1000000) * math.random(1, 1000000)
            a = a / math.random(1, 10000)
            local b = math.sqrt(math.random(1, 1000000))
            b = b * math.pi * math.exp(1)
            local c = math.sin(math.rad(math.random(1, 360))) * math.cos(math.rad(math.random(1, 360)))
        end
    end
end

-- Демон режим: лаг + подъем игрока
local function performDemonLag()
    local startTime = tick()
    local duration = lagDelayValue
    
    -- Получаем текущее значение из поля ввода или глобальной переменной
    local currentHeightInput = Options.DemonRiseHeightInput and Options.DemonRiseHeightInput.Value or "100"
    local currentSpeedInput = Options.DemonRiseSpeedInput and Options.DemonRiseSpeedInput.Value or "80"
    
    local RISE_HEIGHT = tonumber(currentHeightInput) or 10
    local BOOST_SPEED = tonumber(currentSpeedInput) or 80
    
    print(string.format("Демон режим: высота = %dм, скорость = %d", RISE_HEIGHT, BOOST_SPEED))
    
    -- Часть 1: Выполняем математический лаг
    task.spawn(function()
        local startLagTime = tick()
        while tick() - startLagTime < duration do
            for i = 1, math.floor(lagIntensity / 2) do
                local a = math.random(1, 1000000) * math.random(1, 1000000)
                a = a / math.random(1, 10000)
                local b = math.sqrt(math.random(1, 1000000))
                b = b * math.pi * math.exp(1)
            end
        end
    end)
    
    -- Часть 2: Подъем игрока
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if humanoidRootPart and humanoid then
            -- Сохраняем начальную высоту
            local startHeight = humanoidRootPart.Position.Y
            
            -- Используем BodyThrust для подъема
            local bodyThrust = Instance.new("BodyThrust")
            bodyThrust.Name = "DemonRiseThrust"
            bodyThrust.Force = Vector3.new(0, BOOST_SPEED * 500, 0)  -- Нормальная сила
            bodyThrust.Location = Vector3.new(0, 0, 0)
            bodyThrust.Parent = humanoidRootPart
            
            -- Добавляем BodyVelocity для контроля
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Name = "DemonRiseVelocity"
            bodyVelocity.MaxForce = Vector3.new(0, 500000, 0)  -- Нормальная сила
            bodyVelocity.Velocity = Vector3.new(0, BOOST_SPEED, 0)
            bodyVelocity.Parent = humanoidRootPart
            
            -- Ждем пока поднимется на нужную высоту
            local waitTime = 0
            local maxWaitTime = 5  -- Максимальное время ожидания в секундах
            
            while waitTime < maxWaitTime do
                local currentHeight = humanoidRootPart.Position.Y
                local heightGained = currentHeight - startHeight
                
                if heightGained >= RISE_HEIGHT then
                    break
                end
                
                task.wait(0.1)
                waitTime = waitTime + 0.1
            end
            
            -- Убираем силы
            if bodyThrust then
                bodyThrust:Destroy()
            end
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
            
            -- Проверяем результат
            local finalHeight = humanoidRootPart.Position.Y
            local heightGained = finalHeight - startHeight
            print(string.format("Демон режим: поднято на %.1f метров (цель: %.1f м)", heightGained, RISE_HEIGHT))
            
            Fluent:Notify({
                Title = "Demon Mode",
                Content = string.format("Lifted %.1f meters", heightGained),
                Duration = 3
            })
        end
    end
    
    isLagActive = false
end

local function toggleLagSwitch()
    if not isLagActive then
        isLagActive = true
        
        if lagSwitchMode == "Normal" then
            task.spawn(function()
                performMathLag()
                isLagActive = false
            end)
        elseif lagSwitchMode == "Demon" then
            task.spawn(function()
                performDemonLag()
                isLagActive = false
            end)
        end
    end
end

-- Инициализируем значения по умолчанию для демон режима
getgenv().DemonRiseHeight = 10  -- 100 метров по умолчанию
getgenv().DemonRiseSpeed = 80
getgenv().DemonSoftLanding = true

-- ==================== UI ELEMENTS FOR LAG SWITCH ====================

-- Функция для создания кнопки GUI
local function createLagSwitchButton()
    local CoreGui = game:GetService("CoreGui")
    local existingScreenGui = CoreGui:FindFirstChild("LagSwitchButtonGUI")
    
    if existingScreenGui then
        existingScreenGui:Destroy()
    else
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "LagSwitchButtonGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui
        
        local buttonSize = 190
        local btnWidth = math.max(150, math.min(buttonSize, 400))
        local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
        
        local btn, clicker, stroke = createGradientButton(
            screenGui,
            UDim2.new(0.5, -btnWidth/2, 0.5, 1),
            UDim2.new(0, btnWidth, 0, btnHeight),
            "Lag Switch"
        )
        
        clicker.MouseButton1Click:Connect(function()
            if lagSwitchEnabled then
                toggleLagSwitch()
            end
        end)
    end
end

-- Добавь эту функцию сразу после объявления переменных и перед созданием UI элементов

-- Основной тумблер для включения Lag Switch
LagSwitchToggle = MiscTab:AddToggle("LagSwitchToggle", {
    Title = "Lag Switch",
    Default = false,
    Callback = function(Value)
        lagSwitchEnabled = Value
    end
})

-- Выбор режима
LagSwitchModeDropdown = MiscTab:AddDropdown("LagSwitchModeDropdown", {
    Title = "Lag Switch Mode",
    Values = {"Normal", "Demon"},
    Multi = false,
    Default = "Normal",
    Callback = function(Value)
        lagSwitchMode = Value
    end
})

-- Настройки задержки
LagDelayInput = MiscTab:AddInput("LagDelayInput", {
    Title = "Lag Delay (Seconds)",
    Default = "0.1",
    Placeholder = "Enter delay in seconds (0.1-5)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 and num <= 5 then
            lagDelayValue = num
        end
    end
})

-- Настройки интенсивности
LagIntensityInput = MiscTab:AddInput("LagIntensityInput", {
    Title = "Lag Intensity",
    Default = "1000000",
    Placeholder = "Enter intensity (1000-10000000)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 1000 and num <= 10000000 then
            lagIntensity = num
        end
    end
})

-- Настройки для демон режима
DemonRiseHeightInput = MiscTab:AddInput("DemonRiseHeightInput", {
    Title = "Demon Rise Height (meters)",
    Default = "10",
    Placeholder = "Enter rise height in meters (10-500)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 10 and num <= 500 then
            getgenv().DemonRiseHeight = num
            Fluent:Notify({
                Title = "Demon Mode",
                Content = string.format("Rise height set to %d meters", num),
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Demon Mode",
                Content = "Height must be between 10 and 500 meters",
                Duration = 3
            })
        end
    end
})

DemonRiseSpeedInput = MiscTab:AddInput("DemonRiseSpeedInput", {
    Title = "Demon Rise Speed",
    Default = "80",
    Placeholder = "Enter rise speed (20-200)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 20 and num <= 200 then
            getgenv().DemonRiseSpeed = num
            Fluent:Notify({
                Title = "Demon Mode",
                Content = string.format("Rise speed set to %d", num),
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Demon Mode",
                Content = "Speed must be between 20 and 200",
                Duration = 3
            })
        end
    end
})


LagSwitchButtonToggle = MiscTab:AddToggle("LagSwitchButtonToggle", {
    Title = "Lag Switch Button",
    Default = false,
    Callback = function(Value)
        if Value then
            createLagSwitchButton()
        else
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("LagSwitchButtonGUI")
            if existingScreenGui then
                existingScreenGui:Destroy()
            end
        end
    end
})

LagSwitchKeybind = MiscTab:AddKeybind("LagSwitchKeybind", {
    Title = "Lag Switch Keybind",
    Mode = "Toggle",
    Default = "F12",
    ChangedCallback = function(New)
        lagSwitchKeybindValue = New
        
        local CoreGui = game:GetService("CoreGui")
        local screenGui = CoreGui:FindFirstChild("LagSwitchButtonGUI")
        if screenGui then
            local button = screenGui:FindFirstChild("GradientBtn")
            if button and button:FindFirstChild("TextLabel") then
                button.TextLabel.Text = "Lag Switch"
            end
        end
    end,
    Callback = function()
        if lagSwitchEnabled then
            toggleLagSwitch()
        end
    end
})

LagSwitchKeybind:OnChanged(function()
    if Options.LagSwitchButtonToggle and Options.LagSwitchButtonToggle.Value then
        local CoreGui = game:GetService("CoreGui")
        local screenGui = CoreGui:FindFirstChild("LagSwitchButtonGUI")
        if screenGui then
            local button = screenGui:FindFirstChild("GradientBtn")
            if button and button:FindFirstChild("TextLabel") then
                button.TextLabel.Text = "Lag Switch"
            end
        end
    end
end)

LagSwitchScaleInput = MiscTab:AddInput("LagSwitchScaleInput", {
    Title = "Lag Switch Button Scale",
    Default = "1.0",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local scale = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("LagSwitchButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local uiScale = button:FindFirstChild("UIScale") or Instance.new("UIScale")
                    uiScale.Scale = math.max(0.5, math.min(scale, 3.0))
                    uiScale.Parent = button
                end
            end
        end
    end
})

-- Автоматически устанавливаем значение в поле ввода при загрузке
task.spawn(function()
    task.wait(1)
    if DemonRiseHeightInput then
        DemonRiseHeightInput:SetValue("100")
    end
    if DemonRiseSpeedInput then
        DemonRiseSpeedInput:SetValue("80")
    end
    if DemonSoftLandingToggle then
        DemonSoftLandingToggle:SetValue(true)
    end
end)

-- Обновляем описание для демон режима
MiscTab:AddParagraph({
    Title = "Demon Mode Features",
    Content = "Demon mode combines lag switch with character elevation. Default height: 100 meters. You can adjust height and speed settings."
})

MiscTab:AddSection("Camera Adjustments")

local cameraStretchConnection = nil
local stretchHorizontal = 0.80
local stretchVertical = 0.80

local function setupCameraStretch()
    if cameraStretchConnection then 
        cameraStretchConnection:Disconnect() 
        cameraStretchConnection = nil
    end
    
    cameraStretchConnection = game:GetService("RunService").RenderStepped:Connect(function()
        local Camera = workspace.CurrentCamera
        if Camera then
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, stretchHorizontal, 0, 0, 0, stretchVertical, 0, 0, 0, 1)
        end
    end)
end

CameraStretchToggle = MiscTab:AddToggle("CameraStretchToggle", {
    Title = "Camera Stretch",
    Default = false,
    Callback = function(Value)
        if Value then
            setupCameraStretch()
        else
            if cameraStretchConnection then
                cameraStretchConnection:Disconnect()
                cameraStretchConnection = nil
            end
        end
    end
})

CameraStretchHorizontalInput = MiscTab:AddInput("CameraStretchHorizontalInput", {
    Title = "Camera Stretch Horizontal",
    Default = "0.80",
    Placeholder = "Enter horizontal stretch value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            stretchHorizontal = num
            if Options.CameraStretchToggle and Options.CameraStretchToggle.Value then
                setupCameraStretch()
            end
        end
    end
})

CameraStretchVerticalInput = MiscTab:AddInput("CameraStretchVerticalInput", {
    Title = "Camera Stretch Vertical",
    Default = "0.80",
    Placeholder = "Enter vertical stretch value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            stretchVertical = num
            if Options.CameraStretchToggle and Options.CameraStretchToggle.Value then
                setupCameraStretch()
            end
        end
    end
})
MiscTab:AddSection("Client Modification")

FullBrightToggle = MiscTab:AddToggle("FullBrightToggle", {
    Title = "Full Bright",
    Default = false,
    Callback = function(state)
        featureStates.FullBright = state
        if state then
            local Lighting = game:GetService("Lighting")
            
            featureStates.originalBrightness = Lighting.Brightness
            featureStates.originalAmbient = Lighting.Ambient
            featureStates.originalOutdoorAmbient = Lighting.OutdoorAmbient
            featureStates.originalColorShiftBottom = Lighting.ColorShift_Bottom
            featureStates.originalColorShiftTop = Lighting.ColorShift_Top
            
            local function applyFullBright()
                if Lighting.Brightness ~= 1 then
                    Lighting.Brightness = 1
                end
                if Lighting.Ambient ~= Color3.new(1, 1, 1) then
                    Lighting.Ambient = Color3.new(1, 1, 1)
                end
                if Lighting.OutdoorAmbient ~= Color3.new(1, 1, 1) then
                    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                end
                if Lighting.ColorShift_Bottom ~= Color3.new(1, 1, 1) then
                    Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
                end
                if Lighting.ColorShift_Top ~= Color3.new(1, 1, 1) then
                    Lighting.ColorShift_Top = Color3.new(1, 1, 1)
                end
            end
            
            applyFullBright()
            
            if featureStates.fullBrightConnection then
                featureStates.fullBrightConnection:Disconnect()
            end
            
            featureStates.fullBrightConnection = RunService.Heartbeat:Connect(function()
                if featureStates.FullBright then
                    applyFullBright()
                end
            end)
            
            featureStates.fullBrightCharConnection = game.Players.LocalPlayer.CharacterAdded:Connect(function()
                task.wait(1)
                if featureStates.FullBright then
                    applyFullBright()
                end
            end)
            
        else
            if featureStates.fullBrightConnection then
                featureStates.fullBrightConnection:Disconnect()
                featureStates.fullBrightConnection = nil
            end
            
            if featureStates.fullBrightCharConnection then
                featureStates.fullBrightCharConnection:Disconnect()
                featureStates.fullBrightCharConnection = nil
            end
            
            if featureStates.originalBrightness then
                local Lighting = game:GetService("Lighting")
                Lighting.Brightness = featureStates.originalBrightness
                Lighting.Ambient = featureStates.originalAmbient
                Lighting.OutdoorAmbient = featureStates.originalOutdoorAmbient
                Lighting.ColorShift_Bottom = featureStates.originalColorShiftBottom
                Lighting.ColorShift_Top = featureStates.originalColorShiftTop
            end
        end
    end
})

AntiLag1 = MiscTab:AddButton({
    Title = "Anti lag 1",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e10
        Lighting.Brightness = 1

        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj:Destroy()
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj:Destroy()
            end
        end

        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("Accessory") or part:IsA("Clothing") then
                        part:Destroy()
                    end
                end
            end
        end
    end
})

AntiLag2 = MiscTab:AddButton({
    Title = "Anti lag 2",
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
                if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("BasePart") then
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
    end 
})

AntiLag3 = MiscTab:AddButton({
    Title = "Remove Texture",
    Callback = function()
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("Part") or part:IsA("MeshPart") or part:IsA("UnionOperation") or part:IsA("WedgePart") or part:IsA("CornerWedgePart") then
                if part:IsA("Part") then
                    part.Material = Enum.Material.SmoothPlastic
                end
                if part:FindFirstChildWhichIsA("Texture") then
                    local texture = part:FindFirstChildWhichIsA("Texture")
                    texture.Texture = "rbxassetid://0"
                end
                if part:FindFirstChildWhichIsA("Decal") then
                    local decal = part:FindFirstChildWhichIsA("Decal")
                    decal.Texture = "rbxassetid://0"
                end
            end
        end
    end
})

NoFogToggle = MiscTab:AddToggle("NoFogToggle", {
    Title = "Remove fog",
    Default = false,
    Callback = function(state)
        local Lighting = game:GetService("Lighting")
        if state then
            featureStates.originalFogEnd = Lighting.FogEnd
            featureStates.originalAtmospheres = {}
            
            for _, atmosphere in ipairs(Lighting:GetChildren()) do
                if atmosphere:IsA("Atmosphere") then
                    table.insert(featureStates.originalAtmospheres, atmosphere:Clone())
                end
            end
            
            Lighting.FogEnd = 1000000
            for _, v in pairs(Lighting:GetDescendants()) do
                if v:IsA("Atmosphere") then
                    v:Destroy()
                end
            end
        else
            if featureStates.originalFogEnd then
                Lighting.FogEnd = featureStates.originalFogEnd
            end
            
            if featureStates.originalAtmospheres then
                for _, atmosphere in ipairs(featureStates.originalAtmospheres) do
                    if not atmosphere.Parent then
                        local newAtmosphere = Instance.new("Atmosphere")
                        for _, prop in pairs({"Density", "Offset", "Color", "Decay", "Glare", "Haze"}) do
                            if atmosphere[prop] then
                                newAtmosphere[prop] = atmosphere[prop]
                            end
                        end
                        newAtmosphere.Parent = Lighting
                    end
                end
            end
        end
    end
})
VisualsTab = Window:AddTab({ Title = "Visuals", Icon = "folder" })
VisualsTab:AddSection("Cosmetics Changer")

cosmetic1 = ""
cosmetic2 = ""
originalCosmetic1 = ""
originalCosmetic2 = ""
isSwapped = false

CurrentCosmeticsInput = VisualsTab:AddInput("CurrentCosmeticsInput", {
    Title = "Current Cosmetics",
    Default = "",
    Placeholder = "Enter current cosmetic name",
    Finished = false,
    Callback = function(Value)
        cosmetic1 = Value
        if not isSwapped then
            originalCosmetic1 = Value
        end
    end
})

SelectCosmeticsInput = VisualsTab:AddInput("SelectCosmeticsInput", {
    Title = "Select Cosmetics",
    Default = "",
    Placeholder = "Enter cosmetic to swap with",
    Finished = false,
    Callback = function(Value)
        cosmetic2 = Value
        if not isSwapped then
            originalCosmetic2 = Value
        end
    end
})

ApplyCosmeticsButton = VisualsTab:AddButton({
    Title = "Apply Cosmetics",
    Callback = function()
        pcall(function()
            if cosmetic1 == "" or cosmetic2 == "" or cosmetic1 == cosmetic2 then return end
            
            ReplicatedStorage = game:GetService("ReplicatedStorage")    
            Cosmetics = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Cosmetics")    
            
            function normalize(str)    
                return str:gsub("%s+", ""):lower()    
            end    
            
            function levenshtein(s, t)    
                m = #s
                n = #t
                d = {}    
                for i = 0, m do d[i] = {[0] = i} end    
                for j = 0, n do d[0][j] = j end    
                
                for i = 1, m do    
                    for j = 1, n do    
                        cost = (s:sub(i,i) == t:sub(j,j)) and 0 or 1    
                        d[i][j] = math.min(    
                            d[i-1][j] + 1,    
                            d[i][j-1] + 1,    
                            d[i-1][j-1] + cost    
                        )    
                    end    
                end    
                return d[m][n]    
            end    
            
            function similarity(s, t)    
                nS = normalize(s)
                nT = normalize(t)    
                dist = levenshtein(nS, nT)    
                return 1 - dist / math.max(#nS, #nT)    
            end    
            
            function findSimilar(name)    
                bestMatch = name    
                bestScore = 0.5    
                for _, c in ipairs(Cosmetics:GetChildren()) do    
                    score = similarity(name, c.Name)    
                    if score > bestScore then    
                        bestScore = score    
                        bestMatch = c.Name    
                    end    
                end    
                return bestMatch    
            end    
            
            cosmetic1 = findSimilar(cosmetic1)    
            cosmetic2 = findSimilar(cosmetic2)    
            
            a = Cosmetics:FindFirstChild(cosmetic1)    
            b = Cosmetics:FindFirstChild(cosmetic2)    
            if not a or not b then return end    
            
            if not isSwapped then
                originalCosmetic1 = cosmetic1
                originalCosmetic2 = cosmetic2
            end
            
            tempRoot = Instance.new("Folder", Cosmetics)    
            tempRoot.Name = "__temp_swap_" .. tostring(tick()):gsub("%.", "_")    
            
            tempA = Instance.new("Folder", tempRoot)    
            tempB = Instance.new("Folder", tempRoot)    
            
            for _, c in ipairs(a:GetChildren()) do c.Parent = tempA end    
            for _, c in ipairs(b:GetChildren()) do c.Parent = tempB end    
            
            for _, c in ipairs(tempA:GetChildren()) do c.Parent = b end    
            for _, c in ipairs(tempB:GetChildren()) do c.Parent = a end    
            
            tempRoot:Destroy()
            
            isSwapped = true
            
            Fluent:Notify({
                Title = "Cosmetics Changer",
                Content = "Successfully swapped " .. cosmetic1 .. " with " .. cosmetic2,
                Duration = 3
            })
        end)    
    end
})

ResetCosmeticsButton = VisualsTab:AddButton({
    Title = "Reset Cosmetics",
    Callback = function()
        pcall(function()
            if not isSwapped then
                Fluent:Notify({
                    Title = "Cosmetics Changer",
                    Content = "No cosmetics have been swapped yet",
                    Duration = 3
                })
                return
            end
            
            if originalCosmetic1 == "" or originalCosmetic2 == "" then
                Fluent:Notify({
                    Title = "Cosmetics Changer",
                    Content = "Original cosmetic names not found",
                    Duration = 3
                })
                return
            end
            
            ReplicatedStorage = game:GetService("ReplicatedStorage")    
            Cosmetics = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Cosmetics")    
            
            function normalize(str)    
                return str:gsub("%s+", ""):lower()    
            end    
            
            function findSimilar(name)    
                bestMatch = name    
                bestScore = 0.5    
                for _, c in ipairs(Cosmetics:GetChildren()) do    
                    normalizedInput = normalize(name)
                    normalizedCosmetic = normalize(c.Name)
                    if normalizedInput == normalizedCosmetic then
                        return c.Name
                    end
                end    
                return name
            end    
            
            resetCosmetic1 = findSimilar(originalCosmetic1)
            resetCosmetic2 = findSimilar(originalCosmetic2)
            
            a = Cosmetics:FindFirstChild(cosmetic1)    
            b = Cosmetics:FindFirstChild(cosmetic2)    
            
            if a and b then
                tempRoot = Instance.new("Folder", Cosmetics)    
                tempRoot.Name = "__temp_reset_" .. tostring(tick()):gsub("%.", "_")    
                
                tempA = Instance.new("Folder", tempRoot)    
                tempB = Instance.new("Folder", tempRoot)    
                
                for _, c in ipairs(a:GetChildren()) do c.Parent = tempA end    
                for _, c in ipairs(b:GetChildren()) do c.Parent = tempB end    
                
                for _, c in ipairs(tempA:GetChildren()) do c.Parent = b end    
                for _, c in ipairs(tempB:GetChildren()) do c.Parent = a end    
                
                tempRoot:Destroy()
                
                isSwapped = false
                
                Fluent:Notify({
                    Title = "Cosmetics Changer",
                    Content = "Successfully reset cosmetics to original state",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Cosmetics Changer",
                    Content = "Could not find swapped cosmetics to reset",
                    Duration = 3
                })
            end
        end)
    end
})

VisualsTab:AddSection("CarryAnimation Replacer")

currentCarryAnim = ""
selectedCarryAnim = ""
lastCurrentCarryAnim = ""
lastSelectedCarryAnim = ""
isSwapped = false

function normalizeString(str)
    return str:gsub("%s+", ""):lower()
end

function isValidCarryAnimation(name)
    carryAnimations = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
    if not carryAnimations then return false end
    carryAnimations = carryAnimations:FindFirstChild("CarryAnimations")
    if not carryAnimations then return false end
    
    normalizedInput = normalizeString(name)
    for _, anim in ipairs(carryAnimations:GetChildren()) do
        if normalizeString(anim.Name) == normalizedInput then
            return true, anim.Name
        end
    end
    return false
end

function revertPreviousSwap()
    if lastCurrentCarryAnim ~= "" and lastSelectedCarryAnim ~= "" and isSwapped then
        carryAnimations = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
        if carryAnimations then
            carryAnimations = carryAnimations:FindFirstChild("CarryAnimations")
            if carryAnimations then
                lastCurrentValid, lastCurrentActual = isValidCarryAnimation(lastCurrentCarryAnim)
                lastSelectedValid, lastSelectedActual = isValidCarryAnimation(lastSelectedCarryAnim)
                
                if lastCurrentValid and lastSelectedValid then
                    pcall(function()
                        currentFolder = carryAnimations:FindFirstChild(lastCurrentActual)
                        selectedFolder = carryAnimations:FindFirstChild(lastSelectedActual)
                        
                        if currentFolder and selectedFolder then
                            tempRoot = Instance.new("Folder")
                            tempRoot.Name = "__temp_revert_swap_" .. tostring(tick()):gsub("%.", "_")
                            tempRoot.Parent = carryAnimations
                            
                            tempCurrent = Instance.new("Folder")
                            tempCurrent.Name = "tempCurrent"
                            tempCurrent.Parent = tempRoot
                            
                            tempSelected = Instance.new("Folder")
                            tempSelected.Name = "tempSelected"
                            tempSelected.Parent = tempRoot
                            
                            for _, child in ipairs(currentFolder:GetChildren()) do
                                child.Parent = tempCurrent
                            end
                            
                            for _, child in ipairs(selectedFolder:GetChildren()) do
                                child.Parent = tempSelected
                            end
                            
                            for _, child in ipairs(tempCurrent:GetChildren()) do
                                child.Parent = selectedFolder
                            end
                            
                            for _, child in ipairs(tempSelected:GetChildren()) do
                                child.Parent = currentFolder
                            end
                            
                            tempRoot:Destroy()
                        end
                    end)
                end
            end
        end
        isSwapped = false
    end
end

CurrentCarryAnimInput = VisualsTab:AddInput("CurrentCarryAnimInput", {
    Title = "Current CarryAnimation",
    Default = "",
    Placeholder = "Enter current carry animation name",
    Finished = false,
    Callback = function(Value)
        if Value ~= currentCarryAnim and currentCarryAnim ~= "" then
            revertPreviousSwap()
        end
        currentCarryAnim = Value
    end
})

SelectedCarryAnimInput = VisualsTab:AddInput("SelectedCarryAnimInput", {
    Title = "Selected CarryAnimation",
    Default = "",
    Placeholder = "Enter selected carry animation name",
    Finished = false,
    Callback = function(Value)
        if Value ~= selectedCarryAnim and selectedCarryAnim ~= "" then
            revertPreviousSwap()
        end
        selectedCarryAnim = Value
    end
})

ApplyCarryAnimButton = VisualsTab:AddButton({
    Title = "Apply CarryAnimation Swap",
    Callback = function()
        currentNorm = normalizeString(currentCarryAnim)
        selectedNorm = normalizeString(selectedCarryAnim)
        
        if currentNorm == "" or selectedNorm == "" then
            Fluent:Notify({
                Title = "CarryAnimation Replacer",
                Content = "Both animation names must be filled",
                Duration = 3
            })
            return
        end
        
        if currentNorm == selectedNorm then
            Fluent:Notify({
                Title = "CarryAnimation Replacer",
                Content = "Animation names cannot be the same",
                Duration = 3
            })
            return
        end
        
        carryAnimations = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
        if not carryAnimations then
            Fluent:Notify({
                Title = "CarryAnimation Replacer",
                Content = "CarryAnimations folder not found",
                Duration = 3
            })
            return
        end
        
        carryAnimations = carryAnimations:FindFirstChild("CarryAnimations")
        if not carryAnimations then
            Fluent:Notify({
                Title = "CarryAnimation Replacer",
                Content = "CarryAnimations folder not found",
                Duration = 3
            })
            return
        end
        
        currentAnim, currentActualName = isValidCarryAnimation(currentCarryAnim)
        selectedAnim, selectedActualName = isValidCarryAnimation(selectedCarryAnim)
        
        if not currentAnim then
            Fluent:Notify({
                Title = "CarryAnimation Replacer",
                Content = "Current animation not found: " .. currentCarryAnim,
                Duration = 3
            })
            return
        end
        
        if not selectedAnim then
            Fluent:Notify({
                Title = "CarryAnimation Replacer",
                Content = "Selected animation not found: " .. selectedCarryAnim,
                Duration = 3
            })
            return
        end
        
        pcall(function()
            revertPreviousSwap()
            
            currentFolder = carryAnimations:FindFirstChild(currentActualName)
            selectedFolder = carryAnimations:FindFirstChild(selectedActualName)
            
            if not currentFolder or not selectedFolder then
                Fluent:Notify({
                    Title = "CarryAnimation Replacer",
                    Content = "One or both animations not found in folder",
                    Duration = 3
                })
                return
            end
            
            tempRoot = Instance.new("Folder")
            tempRoot.Name = "__temp_carry_swap_" .. tostring(tick()):gsub("%.", "_")
            tempRoot.Parent = carryAnimations
            
            tempCurrent = Instance.new("Folder")
            tempCurrent.Name = "tempCurrent"
            tempCurrent.Parent = tempRoot
            
            tempSelected = Instance.new("Folder")
            tempSelected.Name = "tempSelected"
            tempSelected.Parent = tempRoot
            
            for _, child in ipairs(currentFolder:GetChildren()) do
                child.Parent = tempCurrent
            end
            
            for _, child in ipairs(selectedFolder:GetChildren()) do
                child.Parent = tempSelected
            end
            
            for _, child in ipairs(tempCurrent:GetChildren()) do
                child.Parent = selectedFolder
            end
            
            for _, child in ipairs(tempSelected:GetChildren()) do
                child.Parent = currentFolder
            end
            
            tempRoot:Destroy()
            
            lastCurrentCarryAnim = currentCarryAnim
            lastSelectedCarryAnim = selectedCarryAnim
            isSwapped = true
            
            Fluent:Notify({
                Title = "CarryAnimation Replacer",
                Content = "Successfully swapped " .. currentActualName .. " with " .. selectedActualName,
                Duration = 3
            })
        end)
    end
})

ResetCarryAnimButton = VisualsTab:AddButton({
    Title = "Reset All CarryAnimations",
    Callback = function()
        revertPreviousSwap()
        currentCarryAnim = ""
        selectedCarryAnim = ""
        lastCurrentCarryAnim = ""
        lastSelectedCarryAnim = ""
        isSwapped = false
        CurrentCarryAnimInput:SetValue("")
        SelectedCarryAnimInput:SetValue("")
        Fluent:Notify({
            Title = "CarryAnimation Replacer",
            Content = "All animations reset to original",
            Duration = 3
        })
    end
})

VisualsTab:AddSection("NameTag Changers")

function updateNametagList()
    nametagValues = {"Ignore", "None"}
    nametagsFolder = game:GetService("ReplicatedStorage").Items.Nametags
    
    if nametagsFolder then
        for _, nametagModule in ipairs(nametagsFolder:GetChildren()) do
            if nametagModule:IsA("ModuleScript") then
                success, nametagData = pcall(require, nametagModule)
                if success and nametagData and nametagData.AppearanceInfo then
                    table.insert(nametagValues, nametagData.AppearanceInfo.Name)
                end
            end
        end
    end
    
    return nametagValues
end

VisualNametagDropdown = VisualsTab:AddDropdown("VisualNametagDropdown", {
    Title = "Visual Nametag",
    Description = "Select nametag appearance",
    Values = updateNametagList(),
    Multi = false,
    Default = "Ignore",
    Callback = function(Value)
        playerFolder = workspace.Game.Players:FindFirstChild(game.Players.LocalPlayer.Name)
        if playerFolder then
            if Value == "None" then
                playerFolder:SetAttribute("Nametag", nil)
            elseif Value ~= "Ignore" then
                cleanValue = Value:gsub("%s+", "")
                playerFolder:SetAttribute("Nametag", cleanValue)
            end
        end
    end
})

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    playerFolder = workspace.Game.Players:FindFirstChild(game.Players.LocalPlayer.Name)
    if playerFolder and Options.VisualNametagDropdown and Options.VisualNametagDropdown.Value ~= "Ignore" then
        if Options.VisualNametagDropdown.Value == "None" then
            playerFolder:SetAttribute("Nametag", nil)
        else
            cleanValue = Options.VisualNametagDropdown.Value:gsub("%s+", "")
            playerFolder:SetAttribute("Nametag", cleanValue)
        end
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    playerFolder = workspace.Game.Players:FindFirstChild(game.Players.LocalPlayer.Name)
    if playerFolder and Options.VisualNametagDropdown and Options.VisualNametagDropdown.Value ~= "Ignore" then
        if Options.VisualNametagDropdown.Value == "None" then
            playerFolder:SetAttribute("Nametag", nil)
        else
            cleanValue = Options.VisualNametagDropdown.Value:gsub("%s+", "")
            currentTag = playerFolder:GetAttribute("Nametag")
            if currentTag ~= cleanValue then
                playerFolder:SetAttribute("Nametag", cleanValue)
            end
        end
    end
end)

VisualsTab:AddSection("Fake Streaks")

FakeStreaksInput = VisualsTab:AddInput("FakeStreaksInput", {
    Title = "Fake Streaks",
    Default = "",
    Placeholder = "Enter streak value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        num = tonumber(Value)
        if num then
            game:GetService("Players").LocalPlayer:SetAttribute("Streak", num)
        end
    end
})

task.spawn(function()
    task.wait(1)
    currentStreak = game:GetService("Players").LocalPlayer:GetAttribute("Streak")
    if currentStreak then
        FakeStreaksInput:SetValue(tostring(currentStreak))
    end
end)
VisualsTab:AddSection("Emote Changer")

player = game:GetService("Players").LocalPlayer
ReplicatedStorage = game:GetService("ReplicatedStorage")
Events = ReplicatedStorage:WaitForChild("Events", 10)
CharacterFolder = Events and Events:WaitForChild("Character", 10)
EmoteRemote = CharacterFolder and CharacterFolder:WaitForChild("Emote", 10)
PassCharacterInfo = CharacterFolder and CharacterFolder:WaitForChild("PassCharacterInfo", 10)

remoteSignal = PassCharacterInfo and PassCharacterInfo.OnClientEvent
currentTag = nil
currentEmotes = {}
selectEmotes = {}
emoteEnabled = {}
currentEmoteInputs = {}
selectEmoteInputs = {}

for i = 1, 12 do
    currentEmotes[i] = ""
    selectEmotes[i] = ""
    emoteEnabled[i] = false
end

function readTagFromFolder(f)
    if not f then return nil end
    tagAttribute = f:GetAttribute("Tag")
    if tagAttribute ~= nil then 
        return tagAttribute 
    end
    tagChild = f:FindFirstChild("Tag")
    if tagChild and tagChild:IsA("ValueBase") then 
        return tagChild.Value 
    end
    return nil
end

function onRespawn()
    currentTag = nil
    pendingSlot = nil
    
    task.spawn(function()
        startTime = tick()
        
        while tick() - startTime < 10 do
            if workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players") then
                playerFolder = workspace.Game.Players:FindFirstChild(player.Name)
                if playerFolder then
                    currentTag = readTagFromFolder(playerFolder)
                    if currentTag then
                        tagNumber = tonumber(currentTag)
                        if tagNumber and tagNumber >= 0 and tagNumber <= 255 then
                            print("Emote Changer: Found tag", tagNumber)
                            break
                        else
                            currentTag = nil
                        end
                    end
                end
            end
            task.wait(0.5)
        end
        
        if not currentTag then
            print("Emote Changer: Could not find tag after 10 seconds")
        end
    end)
end

pendingSlot = nil
blockOriginalEmote = false

function fireSelect(slot)
    if not currentTag then 
        print("Emote Changer: No current tag")
        return 
    end
    
    tagNumber = tonumber(currentTag)
    if not tagNumber or tagNumber < 0 or tagNumber > 255 then 
        print("Emote Changer: Invalid tag number", tagNumber)
        return 
    end
    
    if not selectEmotes[slot] or selectEmotes[slot] == "" then 
        print("Emote Changer: No select emote for slot", slot)
        return 
    end
    
    print("Emote Changer: Firing emote", selectEmotes[slot], "for slot", slot, "tag", tagNumber)
    
    if remoteSignal then
        pcall(function()
            buf = buffer.create(2)
            buffer.writeu8(buf, 0, tagNumber)
            buffer.writeu8(buf, 1, 17)
            firesignal(remoteSignal, buf, {selectEmotes[slot]})
        end)
    else
        print("Emote Changer: remoteSignal is nil")
    end
end

if PassCharacterInfo and EmoteRemote then
    print("Emote Changer: Setting up emote changer...")
    
    PassCharacterInfo.OnClientEvent:Connect(function(...)
        if not pendingSlot then return end
        slot = pendingSlot
        pendingSlot = nil
        task.wait(0.1)
        fireSelect(slot)
    end)

    success, oldNamecall = pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            methodName = getnamecallmethod()
            args = {...}
            
            if methodName == "FireServer" and self == EmoteRemote and type(args[1]) == "string" then
                print("Emote Changer: Detected emote fire:", args[1])
                for i = 1, 12 do
                    if emoteEnabled[i] and currentEmotes[i] ~= "" and args[1] == currentEmotes[i] then
                        print("Emote Changer: Matched emote slot", i, args[1], "->", selectEmotes[i])
                        pendingSlot = i
                        blockOriginalEmote = true
                        task.spawn(function()
                            task.wait(0.1)
                            blockOriginalEmote = false
                            if pendingSlot == i then
                                pendingSlot = nil
                                fireSelect(i)
                            end
                        end)
                        if blockOriginalEmote then
                            print("Emote Changer: Blocking original emote")
                            return nil
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
        return oldNamecall
    end)

    if success then
        print("Emote Changer: Hook installed successfully")
    else
        warn("Emote Changer: Error hooking __namecall:", oldNamecall)
    end
    
    if player.Character then
        task.spawn(onRespawn)
    end
    
    player.CharacterAdded:Connect(function()
        task.wait(1)
        onRespawn()
    end)
    
    if workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players") then
        workspace.Game.Players.ChildAdded:Connect(function(child)
            if child.Name == player.Name then
                task.wait(0.5)
                onRespawn()
            end
        end)
        
        workspace.Game.Players.ChildRemoved:Connect(function(child)
            if child.Name == player.Name then
                currentTag = nil
                pendingSlot = nil
            end
        end)
    end
else
    print("Emote Changer: Required remotes not found")
end

for i = 1, 12 do
    currentEmoteInputs[i] = VisualsTab:AddInput("CurrentEmoteInput" .. i, {
        Title = "Current Emote " .. i,
        Default = "",
        Placeholder = "Enter current emote name",
        Finished = false,
        Callback = function(Value)
            currentEmotes[i] = Value:gsub("%s+", "")
            print("Emote Changer: Set current emote " .. i .. " to: " .. currentEmotes[i])
        end
    })
end

VisualsTab:AddParagraph({ Title = "", Content = "" })

for i = 1, 12 do
    selectEmoteInputs[i] = VisualsTab:AddInput("SelectEmoteInput" .. i, {
        Title = "Select Emote " .. i,
        Default = "",
        Placeholder = "Enter select emote name",
        Finished = false,
        Callback = function(Value)
            selectEmotes[i] = Value:gsub("%s+", "")
            print("Emote Changer: Set select emote " .. i .. " to: " .. selectEmotes[i])
        end
    })
end

VisualsEmoteApply = VisualsTab:AddButton({
    Title = "Apply Emote Mappings",
    Callback = function()
        hasAnyEmote = false
        
        for i = 1, 12 do
            if currentEmotes[i] ~= "" or selectEmotes[i] ~= "" then
                hasAnyEmote = true
                break
            end
        end
        
        if not hasAnyEmote then
            Fluent:Notify({
                Title = "Emote Changer",
                Content = "Please enter your emote",
                Duration = 3
            })
            return
        end
        
        function normalizeEmoteName(name)
            return name:gsub("%s+", ""):lower()
        end
        
        function isValidEmote(emoteName)
            if emoteName == "" then return false, "" end
            
            normalizedInput = normalizeEmoteName(emoteName)
            ItemsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
            if ItemsFolder then
                emotesFolder = ItemsFolder:FindFirstChild("Emotes")
                if emotesFolder then
                    for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
                        if emoteModule:IsA("ModuleScript") then
                            normalizedEmote = normalizeEmoteName(emoteModule.Name)
                            if normalizedEmote == normalizedInput then
                                return true, emoteModule.Name
                            end
                        end
                    end
                end
            end
            return false, ""
        end
        
        sameEmoteSlots = {}
        missingEmoteSlots = {}
        invalidEmoteSlots = {}
        successfulSlots = {}
        
        for i = 1, 12 do
            if currentEmotes[i] ~= "" and selectEmotes[i] ~= "" then
                currentValid, currentActual = isValidEmote(currentEmotes[i])
                selectValid, selectActual = isValidEmote(selectEmotes[i])
                
                if not currentValid and not selectValid then
                    table.insert(invalidEmoteSlots, {slot = i, currentInvalid = true, currentName = currentEmotes[i], selectInvalid = true, selectName = selectEmotes[i]})
                elseif not currentValid then
                    table.insert(invalidEmoteSlots, {slot = i, currentInvalid = true, currentName = currentEmotes[i], selectInvalid = false, selectName = selectEmotes[i]})
                elseif not selectValid then
                    table.insert(invalidEmoteSlots, {slot = i, currentInvalid = false, currentName = currentEmotes[i], selectInvalid = true, selectName = selectEmotes[i]})
                elseif currentActual:lower() == selectActual:lower() then
                    table.insert(sameEmoteSlots, i)
                else
                    table.insert(successfulSlots, {slot = i, current = currentActual, select = selectActual})
                end
            elseif currentEmotes[i] ~= "" or selectEmotes[i] ~= "" then
                table.insert(missingEmoteSlots, i)
            end
        end
        
        message = ""
        
        if #successfulSlots > 0 then
            message = message .. "✓ Successfully applied emote on:\n"
            for _, data in ipairs(successfulSlots) do
                message = message .. "Slot " .. data.slot .. " Emote: " .. data.current .. " → " .. data.select .. "\n"
                emoteEnabled[data.slot] = true
                print("Emote Changer: Enabled slot", data.slot, data.current, "->", data.select)
            end
            message = message .. "\n"
        end
        
        if #sameEmoteSlots > 0 then
            message = message .. "✗ Failed to apply emote on:\n"
            for _, slot in ipairs(sameEmoteSlots) do
                message = message .. "Slot " .. slot .. " - Cannot change emote with the same name\n"
                emoteEnabled[slot] = false
            end
            message = message .. "\n"
        end
        
        if #invalidEmoteSlots > 0 then
            message = message .. "✗ Failed to apply emote on:\n"
            for _, data in ipairs(invalidEmoteSlots) do
                message = message .. "Slot " .. data.slot .. " - "
                if data.currentInvalid and data.selectInvalid then
                    message = message .. "Invalid current emote: \"" .. data.currentName .. "\", Invalid select emote: \"" .. data.selectName .. "\"\n"
                elseif data.currentInvalid then
                    message = message .. "Invalid current emote: \"" .. data.currentName .. "\", Select emote: \"" .. data.selectName .. "\"\n"
                else
                    message = message .. "Current emote: \"" .. data.currentName .. "\", Invalid select emote: \"" .. data.selectName .. "\"\n"
                end
                emoteEnabled[data.slot] = false
            end
            message = message .. "\n"
        end
        
        if #missingEmoteSlots > 0 then
            message = message .. "✗ Failed to apply emote on:\n"
            for _, slot in ipairs(missingEmoteSlots) do
                if currentEmotes[slot] == "" then
                    message = message .. "Slot " .. slot .. " - Current emote slot is missing text\n"
                else
                    message = message .. "Slot " .. slot .. " - Select emote slot is missing text\n"
                end
                emoteEnabled[slot] = false
            end
        end
        
        Fluent:Notify({
            Title = "Emote Changer",
            Content = message,
            Duration = 8
        })
        
        print("Emote Changer: Applied mappings")
        print("Enabled slots:")
        for i = 1, 12 do
            if emoteEnabled[i] then
                print("Slot " .. i .. ": " .. currentEmotes[i] .. " -> " .. selectEmotes[i])
            end
        end
    end
})

VisualsEmoteReset = VisualsTab:AddButton({
    Title = "Reset All Emotes",
    Callback = function()
        for i = 1, 12 do
            currentEmotes[i] = ""
            selectEmotes[i] = ""
            emoteEnabled[i] = false
            
            if currentEmoteInputs[i] then
                currentEmoteInputs[i]:SetValue("")
            end
            if selectEmoteInputs[i] then
                selectEmoteInputs[i]:SetValue("")
            end
        end
        
        Fluent:Notify({
            Title = "Emote Changer", 
            Content = "All emotes have been reset!",
            Duration = 3
        })
    end
})
VisualsTab:AddSection("Emote Replacer (very buggy)")

EmoteReplacer = {
    CurrentEmotes = {},
    SelectedEmotes = {},
    SwappedPairs = {},
    InputFields = {}
}

for i = 1, 12 do
    EmoteReplacer.CurrentEmotes[i] = ""
    EmoteReplacer.SelectedEmotes[i] = ""
end

VisualsTab:AddParagraph({ Title = "This Script is for bad executor", Content = "" })
VisualsTab:AddParagraph({ Title = "Current Emotes", Content = "" })

for i = 1, 12 do
    EmoteReplacer.InputFields["CurrentEmote" .. i] = VisualsTab:AddInput("CurrentEmote" .. i, {
        Title = "Current Emote " .. i,
        Default = "",
        Placeholder = "Enter current emote name",
        Finished = false,
        Callback = function(Value)
            EmoteReplacer.CurrentEmotes[i] = Value
        end
    })
end

VisualsTab:AddParagraph({ Title = "Selected Emotes", Content = "" })

for i = 1, 12 do
    EmoteReplacer.InputFields["SelectedEmote" .. i] = VisualsTab:AddInput("SelectedEmote" .. i, {
        Title = "Select Emote " .. i,
        Default = "",
        Placeholder = "Enter replacement emote name",
        Finished = false,
        Callback = function(Value)
            EmoteReplacer.SelectedEmotes[i] = Value
        end
    })
end

function SwapEmoteNames(currentName, selectedName)
    Items = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
    if not Items then 
        print("Emote Replacer: Items folder not found")
        return false 
    end
    
    EmotesFolder = Items:FindFirstChild("Emotes")
    if not EmotesFolder then 
        print("Emote Replacer: Emotes folder not found")
        return false 
    end
    
    currentEmoteObj = EmotesFolder:FindFirstChild(currentName)
    selectedEmoteObj = EmotesFolder:FindFirstChild(selectedName)
    
    if currentEmoteObj and selectedEmoteObj then
        tempName = selectedName .. "_EmoteSwapTemp"
        
        while EmotesFolder:FindFirstChild(tempName) do
            tempName = tempName .. "_"
        end
        
        currentEmoteObj.Name = tempName
        selectedEmoteObj.Name = currentName
        currentEmoteObj.Name = selectedName
        
        print("Emote Replacer: Swapped", currentName, "with", selectedName)
        return true
    else
        print("Emote Replacer: Could not find emotes:", currentName, "or", selectedName)
        return false
    end
end

function ResetEmoteNames()
    Items = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
    if not Items then return false end
    
    EmotesFolder = Items:FindFirstChild("Emotes")
    if not EmotesFolder then return false end
    
    for currentEmote, selectedEmote in pairs(EmoteReplacer.SwappedPairs) do
        currentEmoteObj = EmotesFolder:FindFirstChild(selectedEmote)
        selectedEmoteObj = EmotesFolder:FindFirstChild(currentEmote)
        
        if currentEmoteObj and selectedEmoteObj then
            tempName = currentEmote .. "_EmoteSwapTemp"
            
            while EmotesFolder:FindFirstChild(tempName) do
                tempName = tempName .. "_"
            end
            
            currentEmoteObj.Name = tempName
            selectedEmoteObj.Name = selectedEmote
            currentEmoteObj.Name = currentEmote
            
            print("Emote Replacer: Reset", selectedEmote, "back to", currentEmote)
        end
    end
    
    return true
end

EmoteSwapApplyButton = VisualsTab:AddButton({
    Title = "Apply Emote Swap",
    Callback = function()
        swappedCount = 0
        failedCount = 0
        
        for i = 1, 12 do
            currentEmote = EmoteReplacer.CurrentEmotes[i]
            selectedEmote = EmoteReplacer.SelectedEmotes[i]
            
            if currentEmote ~= "" and selectedEmote ~= "" then
                if SwapEmoteNames(currentEmote, selectedEmote) then
                    EmoteReplacer.SwappedPairs[currentEmote] = selectedEmote
                    swappedCount = swappedCount + 1
                else
                    failedCount = failedCount + 1
                end
            end
        end
        
        message = ""
        if swappedCount > 0 then
            message = "Successfully swapped " .. tostring(swappedCount) .. " emote(s)"
        end
        if failedCount > 0 then
            if message ~= "" then message = message .. " | " end
            message = message .. "Failed to swap " .. tostring(failedCount) .. " emote(s)"
        end
        if message == "" then
            message = "No emotes specified to swap"
        end
        
        Fluent:Notify({
            Title = "Emote Replacer",
            Content = message,
            Duration = 3
        })
    end
})

EmoteSwapResetButton = VisualsTab:AddButton({
    Title = "Reset Emote Module",
    Callback = function()
        if ResetEmoteNames() then
            EmoteReplacer.SwappedPairs = {}
            
            for i = 1, 12 do
                EmoteReplacer.CurrentEmotes[i] = ""
                EmoteReplacer.SelectedEmotes[i] = ""
                
                if EmoteReplacer.InputFields["CurrentEmote" .. i] then
                    EmoteReplacer.InputFields["CurrentEmote" .. i]:SetValue("")
                end
                if EmoteReplacer.InputFields["SelectedEmote" .. i] then
                    EmoteReplacer.InputFields["SelectedEmote" .. i]:SetValue("")
                end
            end
            
            Fluent:Notify({
                Title = "Emote Replacer",
                Content = "All emotes have been restored to original names!",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Emote Replacer",
                Content = "Failed to reset emotes!",
                Duration = 3
            })
        end
    end
})

player.CharacterRemoving:Connect(function()
    if next(EmoteReplacer.SwappedPairs) then
        ResetEmoteNames()
    end
end)

player.CharacterAdded:Connect(function(character)
    task.wait(1)
    
    if character:GetAttribute("Downed") then
        return
    end
    
    if next(EmoteReplacer.SwappedPairs) then
        for currentEmote, selectedEmote in pairs(EmoteReplacer.SwappedPairs) do
            SwapEmoteNames(currentEmote, selectedEmote)
        end
    end
end)

local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

SettingsTab:AddSection("Configuration")

-- ==================== FPS TIMER SETTINGS ====================

SettingsTab:AddSection("FPS Timer Settings")

local FPSTimerToggle = SettingsTab:AddToggle("FPSTimerToggle", {
    Title = "Show FPS Timer",
    Description = "Display FPS and session timer",
    Default = true,
    Callback = function(state)
        local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local timerGUI = PlayerGui:FindFirstChild("DraconicFPS")
        
        if state then
            -- Включаем
            if not timerGUI then
                createSimpleTimer()
            else
                timerGUI.Enabled = true
            end
        else
            -- Выключаем
            if timerGUI then
                timerGUI.Enabled = false
            end
        end
    end
})

SettingsTab:AddButton({
    Title = "Save Configuration",
    Description = "Save current settings to config file",
    Callback = function()
        SaveManager:Save()
        Fluent:Notify({
            Title = "Settings",
            Content = "Configuration saved successfully!",
            Duration = 3
        })
    end
})

SettingsTab:AddButton({
    Title = "Load Configuration",
    Description = "Load settings from config file",
    Callback = function()
        SaveManager:Load()
        Fluent:Notify({
            Title = "Settings",
            Content = "Configuration loaded successfully!",
            Duration = 3
        })
    end
})

SettingsTab:AddButton({
    Title = "Reset Configuration",
    Description = "Reset all settings to default",
    Callback = function()
        Window:Dialog({
            Title = "Reset Configuration",
            Content = "Are you sure you want to reset all settings to default?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        SaveManager:Reset()
                        Fluent:Notify({
                            Title = "Settings",
                            Content = "Configuration reset to default!",
                            Duration = 3
                        })
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Reset cancelled.")
                    end
                }
            }
        })
    end
})

SettingsTab:AddParagraph({
    Title = "Auto Load",
    Content = "The configuration will automatically load when the script starts."
})

SettingsTab:AddSection("Interface Manager")
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("DraconicXEvade")
InterfaceManager:BuildInterfaceSection(SettingsTab)

SettingsTab:AddSection("Save Manager")
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
SaveManager:SetFolder("DraconicXEvade/Config")
SaveManager:BuildConfigSection(SettingsTab)

task.spawn(function()
    task.wait(1)
    SaveManager:LoadAutoloadConfig()
end)

-- Добавьте этот код в раздел Settings (после существующего кода конфигурации)

SettingsTab:AddSection("Button Positions")

-- Переменные для хранения позиций кнопок
local buttonPositions = {}

-- Функция для сбора текущих позиций всех кнопок
local function collectButtonPositions()
    local positions = {}
    local CoreGui = game:GetService("CoreGui")
    
    -- Список всех GUI кнопок
    local buttonGUIs = {
        "DraconicRespawnButtonGUI",
        "InstantReviveButtonGUI", 
        "AutoCarryButtonGUI",
        "SlideButtonGUI",
        "GravityButtonGUI",
        "BhopButtonGUI",
        "LagSwitchButtonGUI"
    }
    
    for _, guiName in ipairs(buttonGUIs) do
        local gui = CoreGui:FindFirstChild(guiName)
        if gui then
            local button = gui:FindFirstChild("GradientBtn")
            if button then
                positions[guiName] = {
                    Position = {
                        X = { Scale = button.Position.X.Scale, Offset = button.Position.X.Offset },
                        Y = { Scale = button.Position.Y.Scale, Offset = button.Position.Y.Offset }
                    }
                }
            end
        end
    end
    
    -- Также сохраняем позицию FPS таймера
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local fpsGui = playerGui:FindFirstChild("DraconicFPS")
    if fpsGui then
        local container = fpsGui:FindFirstChild("Frame")
        if container then
            positions["DraconicFPS"] = {
                Position = {
                    X = { Scale = container.Position.X.Scale, Offset = container.Position.X.Offset },
                    Y = { Scale = container.Position.Y.Scale, Offset = container.Position.Y.Offset }
                }
            }
        end
    end
    
    return positions
end

-- Функция для применения позиций кнопок
local function applyButtonPositions(positions)
    local CoreGui = game:GetService("CoreGui")
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    for guiName, data in pairs(positions) do
        if guiName == "DraconicFPS" then
            local fpsGui = playerGui:FindFirstChild("DraconicFPS")
            if fpsGui then
                local container = fpsGui:FindFirstChild("Frame")
                if container and data.Position then
                    container.Position = UDim2.new(
                        data.Position.X.Scale, data.Position.X.Offset,
                        data.Position.Y.Scale, data.Position.Y.Offset
                    )
                end
            end
        else
            local gui = CoreGui:FindFirstChild(guiName)
            if gui then
                local button = gui:FindFirstChild("GradientBtn")
                if button and data.Position then
                    button.Position = UDim2.new(
                        data.Position.X.Scale, data.Position.X.Offset,
                        data.Position.Y.Scale, data.Position.Y.Offset
                    )
                end
            end
        end
    end
end

-- Кнопка сохранения позиций кнопок
SettingsTab:AddButton({
    Title = "Save Button Positions",
    Description = "Save current positions of all GUI buttons",
    Callback = function()
        local positions = collectButtonPositions()
        
        -- Сохраняем в файл через SaveManager
        local success, err = pcall(function()
            local configData = {
                ButtonPositions = positions,
                SavedAt = os.date("%Y-%m-%d %H:%M:%S")
            }
            
            -- Используем writefile для сохранения в файл
            local fileName = "DraconicX_ButtonPositions.json"
            local jsonData = game:GetService("HttpService"):JSONEncode(configData)
            
            if writefile then
                writefile(fileName, jsonData)
                Fluent:Notify({
                    Title = "Button Positions",
                    Content = "Positions saved to " .. fileName,
                    Duration = 4
                })
            else
                -- Если writefile недоступен, сохраняем через SaveManager
                SaveManager:Set("ButtonPositions", positions)
                Fluent:Notify({
                    Title = "Button Positions",
                    Content = "Positions saved to configuration!",
                    Duration = 3
                })
            end
        end)
        
        if not success then
            Fluent:Notify({
                Title = "Save Failed",
                Content = "Could not save positions: " .. tostring(err),
                Duration = 4
            })
        end
    end
})

-- Кнопка загрузки позиций кнопок
SettingsTab:AddButton({
    Title = "Load Button Positions",
    Description = "Load saved button positions from file",
    Callback = function()
        local success, err = pcall(function()
            local loadedPositions = nil
            
            -- Пытаемся загрузить из файла
            local fileName = "DraconicX_ButtonPositions.json"
            if readfile and isfile and isfile(fileName) then
                local jsonData = readfile(fileName)
                local configData = game:GetService("HttpService"):JSONDecode(jsonData)
                loadedPositions = configData.ButtonPositions
                
                if loadedPositions then
                    applyButtonPositions(loadedPositions)
                    Fluent:Notify({
                        Title = "Button Positions",
                        Content = "Positions loaded from file!",
                        Duration = 3
                    })
                    return
                end
            end
            
            -- Если файла нет, пробуем загрузить из SaveManager
            local savedPositions = SaveManager:Get("ButtonPositions")
            if savedPositions and type(savedPositions) == "table" then
                applyButtonPositions(savedPositions)
                Fluent:Notify({
                    Title = "Button Positions",
                    Content = "Positions loaded from configuration!",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "No Saved Positions",
                    Content = "No saved button positions found!",
                    Duration = 3
                })
            end
        end)
        
        if not success then
            Fluent:Notify({
                Title = "Load Failed",
                Content = "Could not load positions: " .. tostring(err),
                Duration = 4
            })
        end
    end
})

-- Кнопка сброса позиций кнопок (по умолчанию - центр экрана)
SettingsTab:AddButton({
    Title = "Reset Button Positions",
    Description = "Reset all buttons to default positions",
    Callback = function()
        Window:Dialog({
            Title = "Reset Button Positions",
            Content = "Are you sure you want to reset all button positions to default?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        local CoreGui = game:GetService("CoreGui")
                        local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                        
                        -- Стандартные позиции для каждой кнопки
                        local defaultPositions = {
                            DraconicRespawnButtonGUI = { X = 0.5, Y = 0.5 },
                            InstantReviveButtonGUI = { X = 0.5, Y = 0.6 },
                            AutoCarryButtonGUI = { X = 0.5, Y = 0.7 },
                            SlideButtonGUI = { X = 0.5, Y = 0.5 },
                            GravityButtonGUI = { X = 0.5, Y = 0.55 },
                            BhopButtonGUI = { X = 0.5, Y = 0.5 },
                            LagSwitchButtonGUI = { X = 0.5, Y = 0.5 },
                            DraconicFPS = { X = 0, Y = 0 }
                        }
                        
                        -- Сброс позиций кнопок
                        for guiName, defaultPos in pairs(defaultPositions) do
                            if guiName == "DraconicFPS" then
                                local fpsGui = playerGui:FindFirstChild("DraconicFPS")
                                if fpsGui then
                                    local container = fpsGui:FindFirstChild("Frame")
                                    if container then
                                        container.Position = UDim2.new(defaultPos.X, 10, defaultPos.Y, 10)
                                    end
                                end
                            else
                                local gui = CoreGui:FindFirstChild(guiName)
                                if gui then
                                    local button = gui:FindFirstChild("GradientBtn")
                                    if button then
                                        local btnWidth = button.Size.X.Offset
                                        local btnHeight = button.Size.Y.Offset
                                        button.Position = UDim2.new(defaultPos.X, -btnWidth/2, defaultPos.Y, -btnHeight/2)
                                    end
                                end
                            end
                        end
                        
                        Fluent:Notify({
                            Title = "Button Positions",
                            Content = "All buttons reset to default positions!",
                            Duration = 3
                        })
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Reset cancelled.")
                    end
                }
            }
        })
    end
})

-- Автоматическая загрузка позиций при запуске скрипта
task.spawn(function()
    task.wait(3) -- Ждем загрузки всех кнопок
    
    local fileName = "DraconicX_ButtonPositions.json"
    if readfile and isfile and isfile(fileName) then
        local success, err = pcall(function()
            local jsonData = readfile(fileName)
            local configData = game:GetService("HttpService"):JSONDecode(jsonData)
            if configData and configData.ButtonPositions then
                applyButtonPositions(configData.ButtonPositions)
                print("Button positions auto-loaded from file")
            end
        end)
        if not success then
            print("Failed to auto-load button positions:", err)
        end
    end
end)

-- Добавляем новую вкладку Event, если её ещё нет
local InfoTab = Window:AddTab({ Title = "Info", Icon = "help-circle" })

InfoTab:AddSection("Information")

InfoTab:AddParagraph({
    Title = "Telegram Support",
    Content = "Join our Telegram channel for updates and support"
})

InfoTab:AddButton({
    Title = "Copy Telegram Link",
    Description = "Click to copy Telegram link to clipboard",
    Callback = function()
        local telegramLink = "https://t.me/DraconicHub"
        
        -- Копирование в буфер обмена
        setclipboard(telegramLink)
        
        Fluent:Notify({
            Title = "Telegram",
            Content = "Link copied to clipboard!",
            Duration = 3
        })
    end
})

InfoTab:AddParagraph({
    Title = "Discord Server Support",
    Content = "Join our Discord Server for updates and support"
})

InfoTab:AddButton({
    Title = "Copy Discord Link",
    Description = "Click to copy Discord link to clipboard",
    Callback = function()
        local telegramLink = "https://discord.gg/F74VB7u"
        
        -- Копирование в буфер обмена
        setclipboard(telegramLink)
        
        Fluent:Notify({
            Title = "Discord",
            Content = "Link copied to clipboard!",
            Duration = 3
        })
    end
})

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
loadstring(game:HttpGet('https://raw.githubusercontent.com/Ksjsowos/29401/refs/heads/main/Online%20Script/TimerGUI.lua'))()

local function createSimpleTimer()
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    local StatsService = game:GetService("Stats")
    
    -- Создаём GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DraconicFPS"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Основной контейнер
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 165, 0, 48)
    container.Position = UDim2.new(0, 10, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = screenGui
    
    -- Основной фон с градиентом
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 0.7  -- Полупрозрачный
    mainFrame.Parent = container
    
    -- Градиент для фона
    local backgroundGradient = Instance.new("UIGradient")
    backgroundGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),      -- Красный
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),     -- Черный
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))      -- Красный
    }
    backgroundGradient.Rotation = 0
    backgroundGradient.Parent = mainFrame
    
    -- Анимация вращения для градиента фона
    local gradientAnimation
    gradientAnimation = RunService.RenderStepped:Connect(function(delta)
        backgroundGradient.Rotation = (backgroundGradient.Rotation + 90 * delta) % 360
    end)
    
    -- Обычный контур (не градиентный)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(139, 0, 0)  -- Темно-красный
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    -- Закругленные углы
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Контейнер для текста
    local textFrame = Instance.new("Frame")
    textFrame.Size = UDim2.new(1, -8, 1, -8)
    textFrame.Position = UDim2.new(0, 4, 0, 4)
    textFrame.BackgroundTransparency = 1
    textFrame.Parent = mainFrame
    
    -- Добавляем возможность перетаскивания
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    -- Функция для начала перетаскивания
    local function update(input)
        local delta = input.Position - dragStart
        container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    -- Обработчики событий для перетаскивания
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = container.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    -- Обработка перемещения мыши/тача
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    -- Тексты FPS, Ping и таймера
    local statsText = Instance.new("TextLabel")
    statsText.Size = UDim2.new(1, -10, 0.5, 0)
    statsText.Position = UDim2.new(0, 5, 0, 0)
    statsText.BackgroundTransparency = 1
    statsText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsText.Font = Enum.Font.GothamBold
    statsText.TextSize = 13
    statsText.TextXAlignment = Enum.TextXAlignment.Center
    statsText.Text = "FPS: 60 | Ping: 0ms"
    statsText.Parent = textFrame
    
    local timerText = Instance.new("TextLabel")
    timerText.Size = UDim2.new(1, -10, 0.5, 0)
    timerText.Position = UDim2.new(0, 5, 0.5, 0)
    timerText.BackgroundTransparency = 1
    timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
    timerText.Font = Enum.Font.GothamBold
    timerText.TextSize = 13
    timerText.TextXAlignment = Enum.TextXAlignment.Center
    timerText.Text = "Time: 0h 0m 0s"
    timerText.Parent = textFrame
    
    -- Эффекты при наведении
    mainFrame.MouseEnter:Connect(function()
        stroke.Color = Color3.fromRGB(255, 50, 50)  -- Ярко-красный при наведении
        backgroundGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),      -- Ярче
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 20)),     -- Светлее
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 50))       -- Ярче
        }
    end)
    
    mainFrame.MouseLeave:Connect(function()
        stroke.Color = Color3.fromRGB(139, 0, 0)  -- Темно-красный обычный
        backgroundGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }
    end)
    
    -- Таймер для обновления
    local startTime = tick()
    local frameCount = 0
    local lastUpdate = tick()
    local currentFPS = 0
    
    -- Функция для получения пинга
    local function getPing()
        local ping = 0
        
        -- Метод 1: Через Stats (стандартный метод Roblox)
        pcall(function()
            local stats = StatsService
            local networkStats = stats:FindFirstChild("Network")
            if networkStats then
                local serverStats = networkStats:FindFirstChild("ServerStatsItem")
                if serverStats then
                    ping = math.floor(serverStats:GetValue())
                end
            end
        end)
        
        -- Метод 2: Если первый не сработал, используем альтернативный
        if ping == 0 then
            pcall(function()
                local performanceStats = StatsService:FindFirstChild("PerformanceStats")
                if performanceStats then
                    local pingStat = performanceStats:FindFirstChild("Ping")
                    if pingStat then
                        ping = math.floor(pingStat:GetValue())
                    end
                end
            end)
        end
        
        -- Метод 3: Запасной вариант
        if ping == 0 then
            ping = 50
        end
        
        return ping
    end
    
    -- Обновление
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        
        local currentTime = tick()
        
        -- Обновляем FPS и Ping каждые 0.5 секунды
        if currentTime - lastUpdate >= 0.5 then
            currentFPS = math.floor(frameCount / (currentTime - lastUpdate))
            frameCount = 0
            lastUpdate = currentTime
            
            local ping = getPing()
            statsText.Text = string.format("FPS: %d | Ping: %dms", currentFPS, ping)
        end
        
        -- Обновляем таймер
        local elapsed = currentTime - startTime
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        
        timerText.Text = string.format("Time: %dh %dm %ds", hours, minutes, seconds)
    end)
    
    -- Очистка анимации при удалении
    container.Destroying:Connect(function()
        if gradientAnimation then
            gradientAnimation:Disconnect()
        end
    end)
    
    -- Функция для изменения позиции
    function screenGui:SetPosition(x, y)
        container.Position = UDim2.new(0, x, 0, y)
    end
    
    -- Функция для скрытия/показа
    function screenGui:SetVisible(visible)
        screenGui.Enabled = visible
    end
    
    -- Сохраняем позицию при перезапуске персонажа
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not screenGui or not screenGui.Parent then
            screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    
    print("Draconic Timer: Created with gradient background and normal border!")
    return screenGui
end

-- Автоматически создаём таймер (в конце файла добавьте эту строку)
createSimpleTimer()

-- Автоматическое восстановление ESP при респавне
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2) -- Даем время на загрузку
    
    -- Восстановление Player ESP
    if Options.PlayerToggle and Options.PlayerToggle.Value then
        if not ExternalESPLoaded or not _G.ExternalESPRunning then
            Fluent:Notify({
                Title = "ESP Players",
                Content = "Restoring Player ESP after respawn...",
                Duration = 3
            })
            
            -- Очищаем старые объекты
            cleanupPlayerESPObjects()
            
            -- Сбрасываем переменные
            ExternalESPLoaded = false
            ExternalESP = nil
            _G.ExternalESPRunning = false
            
            -- Загружаем заново
            local success = pcall(function()
                ExternalESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ksjsowos/29401/refs/heads/main/Test%20Script/Esp.lua"))()
                ExternalESPLoaded = true
                _G.ExternalESPRunning = true
            end)
            
            if success then
                Fluent:Notify({
                    Title = "ESP Players",
                    Content = "Player ESP restored successfully!",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "ESP Players Error",
                    Content = "Failed to restore Player ESP",
                    Duration = 3
                })
                Options.PlayerToggle:Set(false)
            end
        end
    end
end)

-- ==================== УЛУЧШЕННАЯ ОЧИСТКА И ВОССТАНОВЛЕНИЕ NEXTBOT ESP ====================

-- Очистка при респавне персонажа
LocalPlayer.CharacterRemoving:Connect(function()
    if Options.NextbotToggle and Options.NextbotToggle.Value then
        -- Временное отключение ESP при респавне
        if ExternalNextbotESPLoaded and ExternalNextbotESP then
            if ExternalNextbotESP.Stop then
                pcall(ExternalNextbotESP.Stop)
            end
        end
        
        -- Очистка временных данных
        for model, data in pairs(NextbotBillboards) do
            if data.esp then
                data.esp:Destroy()
            end
        end
        NextbotBillboards = {}
        
        -- Очищаем Tracer ESP для ботов
        for model, tracer in pairs(botTracerElements) do
            if tracer and tracer.Remove then
                tracer:Remove()
            end
        end
        botTracerElements = {}
    end
end)

-- Восстановление после респавна
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    
    if Options.NextbotToggle and Options.NextbotToggle.Value then
        if ExternalNextbotESPLoaded and ExternalNextbotESP then
            if ExternalNextbotESP.Start then
                pcall(function()
                    ExternalNextbotESP.Start()
                    _G.NextbotESPRunning = true
                    Fluent:Notify({
                        Title = "ESP Nextbots",
                        Content = "Nextbot ESP restored after respawn!",
                        Duration = 3
                    })
                end)
            end
        end
    end

end)
