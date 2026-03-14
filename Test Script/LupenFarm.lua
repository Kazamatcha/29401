--[[
    Внешний модуль: Auto Farm Lupen для Draconic Hub
    Версия: 1.1 (Исправленная)
]]

-- Защита от повторной загрузки
if _G.LupenFarmLoaded then 
    return _G.LupenFarmModule 
end

-- Сервисы (с защитой от nil)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Создаем модуль
local LupenFarmModule = {}

-- Переменные
LupenFarmModule.Enabled = false
LupenFarmModule.Connection = nil
LupenFarmModule.RespawnConnection = nil
LupenFarmModule.CurrentTarget = nil
LupenFarmModule.Settings = {
    TeleportOffset = Vector3.new(0, 5, 0),
    PlatformOffset = Vector3.new(0, 3, 0),
    AutoRespawn = true
}

-- Безопасное создание платформы
function LupenFarmModule:FindOrCreatePlatform()
    local platform = workspace:FindFirstChild("SecurityPart")
    
    if not platform then
        local success, result = pcall(function()
            local newPlatform = Instance.new("Part")
            newPlatform.Name = "SecurityPart"
            newPlatform.Size = Vector3.new(10, 1, 10)
            newPlatform.Position = Vector3.new(5000, 5000, 5000)
            newPlatform.Anchored = true
            newPlatform.CanCollide = true
            newPlatform.Material = Enum.Material.Neon
            newPlatform.BrickColor = BrickColor.new("Bright red")
            newPlatform.Parent = workspace
            return newPlatform
        end)
        
        if success then
            platform = result
        end
    end
    
    return platform
end

-- Безопасная телепортация на платформу
function LupenFarmModule:TeleportToPlatform()
    local success, result = pcall(function()
        local character = LocalPlayer.Character
        if not character then return false end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return false end
        
        local platform = self:FindOrCreatePlatform()
        if platform then
            humanoidRootPart.CFrame = platform.CFrame + self.Settings.PlatformOffset
            return true
        end
        return false
    end)
    
    return success and result or false
end

-- Безопасный поиск Лупина
function LupenFarmModule:FindLupen()
    local success, result = pcall(function()
        -- Поиск в Game.Players
        local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
        if gamePlayers then
            for _, obj in ipairs(gamePlayers:GetChildren()) do
                if obj:IsA("Model") then
                    local name = obj.Name:lower()
                    if name:find("lupen") or name:find("lupin") or name:find("lupine") then
                        return obj
                    end
                end
            end
        end
        
        -- Поиск в NPCs
        local npcs = workspace:FindFirstChild("NPCs")
        if npcs then
            for _, obj in ipairs(npcs:GetChildren()) do
                if obj:IsA("Model") then
                    local name = obj.Name:lower()
                    if name:find("lupen") or name:find("lupin") or name:find("lupine") then
                        return obj
                    end
                end
            end
        end
        
        return nil
    end)
    
    return success and result or nil
end

-- Безопасное получение корневой части
local function safeGetRootPart(model)
    if not model then return nil end
    
    local success, result = pcall(function()
        return model:FindFirstChild("HumanoidRootPart") or
               model:FindFirstChild("Head") or
               model:FindFirstChild("Torso") or
               model:FindFirstChild("UpperTorso") or
               model.PrimaryPart or
               model:FindFirstChildWhichIsA("BasePart")
    end)
    
    return success and result or nil
end

-- Безопасная телепортация к Лупину
function LupenFarmModule:TeleportToLupen(lupen)
    local success, result = pcall(function()
        local character = LocalPlayer.Character
        if not character then return false end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return false end
        
        local lupenRoot = safeGetRootPart(lupen)
        if not lupenRoot then return false end
        
        humanoidRootPart.CFrame = lupenRoot.CFrame + self.Settings.TeleportOffset
        return true
    end)
    
    return success and result or false
end

-- Проверка состояния игрока
function LupenFarmModule:IsPlayerDowned()
    local success, result = pcall(function()
        local character = LocalPlayer.Character
        if not character then return true end
        
        if character:GetAttribute("Downed") then
            return true
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            return humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead
        end
        
        return false
    end)
    
    return success and result or false
.end

-- Безопасное возрождение
function LupenFarmModule:RespawnPlayer()
    if not self.Settings.AutoRespawn then return false end
    
    local success = pcall(function()
        if ReplicatedStorage and 
           ReplicatedStorage:FindFirstChild("Events") and
           ReplicatedStorage.Events:FindFirstChild("Player") and
           ReplicatedStorage.Events.Player:FindFirstChild("ChangePlayerMode") then
            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
        end
    end)
    
    return success
end

-- Основной цикл (с защитой)
function LupenFarmModule:Update()
    if not self.Enabled then return end
    
    local success = pcall(function()
        if self:IsPlayerDowned() then
            self:RespawnPlayer()
            return
        end
        
        local lupen = self:FindLupen()
        
        if lupen then
            if not self.CurrentTarget or self.CurrentTarget ~= lupen then
                self.CurrentTarget = lupen
            end
            self:TeleportToLupen(lupen)
        else
            if self.CurrentTarget then
                self.CurrentTarget = nil
                self:TeleportToPlatform()
            end
        end
    end)
    
    if not success then
        -- Если ошибка, просто игнорируем этот цикл
    end
end

-- Запуск
function LupenFarmModule:Start()
    if self.Enabled then return true end
    
    self.Enabled = true
    self.CurrentTarget = nil
    
    -- Телепорт на платформу
    self:TeleportToPlatform()
    
    -- Очищаем старые соединения
    if self.Connection then
        pcall(function() self.Connection:Disconnect() end)
        self.Connection = nil
    end
    
    if self.RespawnConnection then
        pcall(function() self.RespawnConnection:Disconnect() end)
        self.RespawnConnection = nil
    end
    
    -- Новые соединения
    self.Connection = RunService.Heartbeat:Connect(function()
        self:Update()
    end)
    
    self.RespawnConnection = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if self.Enabled then
            self:TeleportToPlatform()
        end
    end)
    
    -- Уведомление
    self:Notify("Auto Farm Lupen включен")
    
    return true
end

-- Остановка
function LupenFarmModule:Stop()
    if not self.Enabled then return true end
    
    self.Enabled = false
    self.CurrentTarget = nil
    
    -- Отключаем соединения
    if self.Connection then
        pcall(function() self.Connection:Disconnect() end)
        self.Connection = nil
    end
    
    if self.RespawnConnection then
        pcall(function() self.RespawnConnection:Disconnect() end)
        self.RespawnConnection = nil
    end
    
    -- Возврат на платформу
    self:TeleportToPlatform()
    
    -- Уведомление
    self:Notify("Auto Farm Lupen выключен")
    
    return true
end

-- Уведомление
function LupenFarmModule:Notify(message)
    local success = pcall(function()
        if Fluent and Fluent.Notify then
            Fluent:Notify({
                Title = "Auto Farm Lupen",
                Content = message,
                Duration = 3
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Auto Farm Lupen",
                Text = message,
                Duration = 3
            })
        end
    end)
end

-- Настройка параметров
function LupenFarmModule:SetSettings(settings)
    if not settings then return end
    
    for key, value in pairs(settings) do
        if self.Settings[key] ~= nil then
            self.Settings[key] = value
        end
    end
end

-- Проверка статуса
function LupenFarmModule:IsEnabled()
    return self.Enabled
end

-- Получение цели
function LupenFarmModule:GetCurrentTarget()
    return self.CurrentTarget
end

-- Обновление платформы
function LupenFarmModule:RefreshPlatform()
    return self:TeleportToPlatform()
.end

-- Экспортируем модуль
_G.LupenFarmLoaded = true
_G.LupenFarmModule = LupenFarmModule

print("✅ Auto Farm Lupen module loaded successfully!")

return LupenFarmModule
