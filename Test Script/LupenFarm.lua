--[[
    Внешний модуль: Auto Farm Lupen для Draconic Hub
    Версия: 1.0
    Описание: Автоматическая ферма Лупина с телепортацией на платформу
]]

-- Проверяем, не загружен ли уже модуль
if _G.LupenFarmLoaded then
    return
end
_G.LupenFarmLoaded = true

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Переменные модуля
local LupenFarm = {
    Enabled = false,
    Connection = nil,
    RespawnConnection = nil,
    CurrentTarget = nil,
    Settings = {
        TeleportOffset = Vector3.new(0, 5, 0),  -- Высота телепортации над Лупином
        PlatformOffset = Vector3.new(0, 3, 0),  -- Высота над платформой
        CheckInterval = 0.1,                     -- Интервал проверки (секунды)
        AutoRespawn = true                        -- Автоматическое возрождение
    }
}

-- Поиск безопасной платформы
local function findSafePlatform()
    local platform = workspace:FindFirstChild("SecurityPart")
    
    -- Если платформы нет, создаем новую
    if not platform then
        platform = Instance.new("Part")
        platform.Name = "SecurityPart"
        platform.Size = Vector3.new(10, 1, 10)
        platform.Position = Vector3.new(5000, 5000, 5000)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Material = Enum.Material.Neon
        platform.BrickColor = BrickColor.new("Bright red")
        platform.Parent = workspace
        
        -- Добавляем подсветку для видимости
        local pointLight = Instance.new("PointLight")
        pointLight.Color = Color3.new(1, 0, 0)
        pointLight.Range = 20
        pointLight.Brightness = 1
        pointLight.Parent = platform
    end
    
    return platform
end

-- Телепортация на безопасную платформу
function LupenFarm:TeleportToPlatform()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local platform = findSafePlatform()
    if platform then
        humanoidRootPart.CFrame = platform.CFrame + self.Settings.PlatformOffset
        return true
    end
    return false
end

-- Поиск Лупина
function LupenFarm:FindLupen()
    -- Поиск в Game.Players
    local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if gamePlayers then
        for _, obj in ipairs(gamePlayers:GetChildren()) do
            if obj:IsA("Model") and (
                obj.Name:lower():find("lupen") or 
                obj.Name:lower():find("lupin") or
                obj.Name:lower():find("lupine")
            ) then
                return obj
            end
        end
    end
    
    -- Поиск в NPCs
    local npcs = workspace:FindFirstChild("NPCs")
    if npcs then
        for _, obj in ipairs(npcs:GetChildren()) do
            if obj:IsA("Model") and (
                obj.Name:lower():find("lupen") or 
                obj.Name:lower():find("lupin") or
                obj.Name:lower():find("lupine")
            ) then
                return obj
            end
        end
    end
    
    return nil
end

-- Получение корневой части модели
local function getRootPart(model)
    if not model then return nil end
    
    -- Проверяем стандартные части
    return model:FindFirstChild("HumanoidRootPart") or
           model:FindFirstChild("Head") or
           model:FindFirstChild("Torso") or
           model:FindFirstChild("UpperTorso") or
           model.PrimaryPart or
           model:FindFirstChildWhichIsA("BasePart")
end

-- Телепортация к Лупину
function LupenFarm:TeleportToLupen(lupen)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local lupenRoot = getRootPart(lupen)
    if not lupenRoot then return false end
    
    humanoidRootPart.CFrame = lupenRoot.CFrame + self.Settings.TeleportOffset
    return true
end

-- Проверка, жив ли игрок
function LupenFarm:IsPlayerDowned()
    local character = LocalPlayer.Character
    if not character then return true end
    
    -- Проверка через атрибут Downed
    if character:GetAttribute("Downed") then
        return true
    end
    
    -- Проверка через Humanoid
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and (humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead) then
        return true
    end
    
    return false
end

-- Возрождение игрока
function LupenFarm:RespawnPlayer()
    if not self.Settings.AutoRespawn then return false end
    
    local success = pcall(function()
        ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
    end)
    
    return success
end

-- Основной цикл обновления
function LupenFarm:Update()
    if not self.Enabled then return end
    
    -- Проверяем состояние игрока
    if self:IsPlayerDowned() then
        self:RespawnPlayer()
        return
    end
    
    -- Ищем Лупина
    local lupen = self:FindLupen()
    
    if lupen then
        -- Лупин найден
        if not self.CurrentTarget or self.CurrentTarget ~= lupen then
            self.CurrentTarget = lupen
            --print("Auto Farm: Лупин найден")
        end
        
        -- Телепортируемся к Лупину
        self:TeleportToLupen(lupen)
    else
        -- Лупин исчез
        if self.CurrentTarget then
            self.CurrentTarget = nil
            --print("Auto Farm: Лупин исчез, возвращаюсь на платформу")
            self:TeleportToPlatform()
        end
    end
end

-- Запуск авто-фермы
function LupenFarm:Start()
    if self.Enabled then return end
    
    self.Enabled = true
    self.CurrentTarget = nil
    
    -- Сначала телепортируемся на платформу
    self:TeleportToPlatform()
    
    -- Запускаем цикл обновления
    if self.Connection then
        self.Connection:Disconnect()
    end
    
    self.Connection = RunService.Heartbeat:Connect(function()
        self:Update()
    end)
    
    -- Обработка респавна
    if self.RespawnConnection then
        self.RespawnConnection:Disconnect()
    end
    
    self.RespawnConnection = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1) -- Ждем загрузки персонажа
        if self.Enabled then
            self:TeleportToPlatform()
        end
    end)
    
    -- Уведомление
    self:Notify("Auto Farm Lupen включен", 3)
    
    return true
end

-- Остановка авто-фермы
function LupenFarm:Stop()
    if not self.Enabled then return end
    
    self.Enabled = false
    self.CurrentTarget = nil
    
    -- Отключаем соединения
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    if self.RespawnConnection then
        self.RespawnConnection:Disconnect()
        self.RespawnConnection = nil
    end
    
    -- Возвращаемся на платформу
    self:TeleportToPlatform()
    
    -- Уведомление
    self:Notify("Auto Farm Lupen выключен", 3)
    
    return true
end

-- Отправка уведомления (если доступен Fluent)
function LupenFarm:Notify(message, duration)
    -- Пробуем использовать Fluent, если он доступен
    if Fluent and Fluent.Notify then
        Fluent:Notify({
            Title = "Auto Farm Lupen",
            Content = message,
            Duration = duration or 3
        })
    else
        -- Запасной вариант через Roblox уведомления
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Auto Farm Lupen",
            Text = message,
            Duration = duration or 3
        })
    end
end

-- Настройка параметров
function LupenFarm:SetSettings(settings)
    for key, value in pairs(settings) do
        if self.Settings[key] ~= nil then
            self.Settings[key] = value
        end
    end
end

-- Получение статуса
function LupenFarm:IsEnabled()
    return self.Enabled
end

-- Получение текущей цели
function LupenFarm:GetCurrentTarget()
    return self.CurrentTarget
end

-- Принудительное обновление позиции на платформе
function LupenFarm:RefreshPlatform()
    return self:TeleportToPlatform()
.end

-- Экспортируем модуль в глобальную переменную
_G.LupenFarm = LupenFarm

-- Автоматический запуск при загрузке (опционально)
-- _G.LupenFarm:Start()

print("✅ Auto Farm Lupen module loaded successfully!")
print("ℹ️ Use _G.LupenFarm:Start() to enable, _G.LupenFarm:Stop() to disable")

-- Возвращаем модуль для использования в основном скрипте
return LupenFarm
