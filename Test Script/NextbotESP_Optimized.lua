-- NextbotESP_Optimized.lua
-- Optimized external Nextbot ESP for URL loadstring usage.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local SCAN_INTERVAL = 0.12
local DIST_UPDATE_INTERVAL = 0.24
local STALE_TIMEOUT = 8

local nextbotBillboards = {}
local nextbotLoop = nil
local scanAccumulator = 0
local distAccumulator = 0

_G.NextbotESPRunning = false

local knownNextbotNames = {}
do
    local npcs = ReplicatedStorage:FindFirstChild("NPCs")
    if npcs then
        for _, npc in ipairs(npcs:GetChildren()) do
            knownNextbotNames[npc.Name] = true
        end
    end
end

local function isNextbotModel(model)
    if not model or not model:IsA("Model") or not model.Name then
        return false
    end

    if knownNextbotNames[model.Name] then
        return true
    end

    local lowerName = model.Name:lower()
    if lowerName:find("nextbot")
        or lowerName:find("scp%-")
        or lowerName:find("^monster")
        or lowerName:find("^creep")
        or lowerName:find("^enemy")
    then
        return true
    end

    if Players:FindFirstChild(model.Name) then
        return false
    end

    if model:GetAttribute("IsNPC") or model:GetAttribute("Nextbot") then
        return true
    end

    return false
end

local function getDistance(targetPosition)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return 0
    end
    return math.floor((targetPosition - hrp.Position).Magnitude)
end

local function resolveAnchor(model)
    -- ВАЖНО: как в старом скрипте, всегда используем отдельный ESP_Anchor блок внутри модели.
    local anchor = model:FindFirstChild("ESP_Anchor")
    if not anchor then
        anchor = Instance.new("Part")
        anchor.Name = "ESP_Anchor"
        anchor.Size = Vector3.new(0.1, 0.1, 0.1)
        anchor.Transparency = 1
        anchor.CanCollide = false
        anchor.Anchored = true
        anchor.Parent = model
    end

    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.Transparency = 1

    if model.PrimaryPart then
        anchor.CFrame = model.PrimaryPart.CFrame
    else
        local base = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
        if base then
            anchor.CFrame = base.CFrame
        end
    end

    -- Помечаем как временный якорь для очистки при Stop/ClearAll.
    return anchor, true
end

local function createEsp(part)
    local gui = Instance.new("BillboardGui")
    gui.Name = "NextbotESP"
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(0, 200, 0, 50)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.MaxDistance = 1000
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.Name = "ESPText"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.RobotoMono
    label.TextStrokeTransparency = 0.5
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.Text = "Loading..."
    label.Parent = gui

    return gui, label
end

local function clearAll()
    for model, data in pairs(nextbotBillboards) do
        if data.gui and data.gui.Parent then
            data.gui:Destroy()
        end
        if data.fakeAnchor and data.anchor and data.anchor.Parent then
            data.anchor:Destroy()
        end
        nextbotBillboards[model] = nil
    end
end

local function collectCandidates()
    local result = {}

    local gameFolder = workspace:FindFirstChild("Game")
    local gamePlayers = gameFolder and gameFolder:FindFirstChild("Players")
    if gamePlayers then
        for _, model in ipairs(gamePlayers:GetChildren()) do
            if isNextbotModel(model) then
                result[model] = true
            end
        end
    end

    local npcs = workspace:FindFirstChild("NPCs")
    if npcs then
        for _, model in ipairs(npcs:GetChildren()) do
            if isNextbotModel(model) then
                result[model] = true
            end
        end
    end

    return result
end

local function updateLabelsDistanceOnly()
    for model, data in pairs(nextbotBillboards) do
        if model and model.Parent and data.anchor and data.anchor.Parent and data.label then
            data.label.Text = string.format("%s [%dm]", model.Name, getDistance(data.anchor.Position))
        end
    end
end

local function fullScanAndSync()
    local candidates = collectCandidates()

    for model in pairs(candidates) do
        local data = nextbotBillboards[model]
        if not data then
            local anchor, fakeAnchor = resolveAnchor(model)
            if anchor then
                local gui, label = createEsp(anchor)
                nextbotBillboards[model] = {
                    anchor = anchor,
                    fakeAnchor = fakeAnchor,
                    gui = gui,
                    label = label,
                    lastSeen = tick()
                }
            end
        else
            data.lastSeen = tick()
            if data.anchor and data.anchor.Parent then
                if model.PrimaryPart then
                    data.anchor.CFrame = model.PrimaryPart.CFrame
                else
                    local base = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
                    if base then
                        data.anchor.CFrame = base.CFrame
                    end
                end
            end
        end
    end

    for model, data in pairs(nextbotBillboards) do
        if not candidates[model] or not model.Parent or (tick() - (data.lastSeen or 0) > STALE_TIMEOUT) then
            if data.gui and data.gui.Parent then
                data.gui:Destroy()
            end
            if data.fakeAnchor and data.anchor and data.anchor.Parent then
                data.anchor:Destroy()
            end
            nextbotBillboards[model] = nil
        end
    end

    updateLabelsDistanceOnly()
end

local function start()
    if nextbotLoop then
        _G.NextbotESPRunning = true
        return true
    end

    _G.NextbotESPRunning = true
    scanAccumulator = 0
    distAccumulator = 0

    nextbotLoop = RunService.Heartbeat:Connect(function(dt)
        if not _G.NextbotESPRunning then
            return
        end

        local delta = dt or 0
        scanAccumulator = scanAccumulator + delta
        distAccumulator = distAccumulator + delta

        if scanAccumulator >= SCAN_INTERVAL then
            scanAccumulator = 0
            fullScanAndSync()
        elseif distAccumulator >= DIST_UPDATE_INTERVAL then
            distAccumulator = 0
            updateLabelsDistanceOnly()
        end
    end)

    task.spawn(function()
        for _ = 1, 2 do
            fullScanAndSync()
            task.wait(0.08)
        end
    end)

    return true
end

local function stop()
    _G.NextbotESPRunning = false
    if nextbotLoop then
        nextbotLoop:Disconnect()
        nextbotLoop = nil
    end
    clearAll()
    return true
end

_G.StopNextbotESP = stop

return {
    Start = start,
    Stop = stop,
    ClearAll = clearAll,
    IsRunning = function()
        return _G.NextbotESPRunning == true
    end
}
