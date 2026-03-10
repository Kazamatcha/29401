-- ==================== HIGHLIGHT BOTS MODULE ====================
-- External module for Draconic Hub X Evade
-- File: HighlightBots.lua

local module = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Internal variables
local botHighlights = {}
local highlightConnection = nil
local isEnabled = false
local Fluent = nil
local Options = nil

-- Store original transparency values
local originalTransparencies = {}

-- Get nextbot names from ReplicatedStorage
local nextBotNames = {}
if ReplicatedStorage:FindFirstChild("NPCs") then
    for _, npc in ipairs(ReplicatedStorage.NPCs:GetChildren()) do
        table.insert(nextBotNames, npc.Name)
    end
end

-- Function to check if model is a nextbot
local function isNextbotModel(model)
    if not model or not model.Name then return false end
    
    -- Check against known nextbot names
    for _, name in ipairs(nextBotNames) do
        if model.Name == name then return true end
    end
    
    -- Check by name patterns
    local nameLower = model.Name:lower()
    return nameLower:find("nextbot") or 
           nameLower:find("scp") or 
           nameLower:find("monster") or
           nameLower:find("creep") or
           nameLower:find("enemy") or
           nameLower:find("zombie") or
           nameLower:find("ghost") or
           nameLower:find("demon")
end

-- Function to check if a part is a hitbox (by name patterns)
local function isHitboxPart(part)
    if not part or not part.Name then return false end
    
    local nameLower = part.Name:lower()
    return nameLower:find("hitbox") or 
           nameLower:find("hit") or 
           nameLower:find("collision") or
           nameLower:find("collide") or
           nameLower:find("damage") or
           nameLower:find("hurt") or
           nameLower:find("attack") or
           nameLower:find("body") or
           nameLower:find("root") or
           nameLower:find("torso") or
           nameLower:find("head") or
           nameLower:find("limb") or
           nameLower:find("arm") or
           nameLower:find("leg")
end

-- Function to make hitboxes visible (transparency = 0)
local function makeHitboxesVisible(model)
    if not model then return end
    
    -- Store original transparency values and set to 0
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and isHitboxPart(part) then
            -- Store original transparency if not already stored
            if not originalTransparencies[part] then
                originalTransparencies[part] = part.Transparency
            end
            -- Set to 0 (fully visible)
            part.Transparency = 0
            -- Also make sure it's visible through walls if needed
            part.CanQuery = true
        end
    end
end

-- Function to restore original transparency
local function restoreHitboxesTransparency(model)
    if not model then return end
    
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and originalTransparencies[part] then
            part.Transparency = originalTransparencies[part]
            originalTransparencies[part] = nil
        end
    end
end

-- Initialize module with Fluent library
function module:Init(fluentLib, options)
    Fluent = fluentLib
    Options = options
    print("Highlight Bots module initialized")
end

-- Function to update/create highlight for a bot
local function updateBotHighlight(bot)
    if not bot or not isEnabled then return end
    
    local hrp = bot:FindFirstChild("HumanoidRootPart") or 
                bot:FindFirstChild("Torso") or 
                bot:FindFirstChild("Head") or
                bot:FindFirstChildWhichIsA("BasePart")
    
    if not hrp then return end
    
    -- Make hitboxes visible
    makeHitboxesVisible(bot)
    
    -- If highlight already exists, just return
    if botHighlights[bot] then
        local highlight = botHighlights[bot]
        if highlight and highlight.Parent then
            return
        else
            botHighlights[bot] = nil
        end
    end
    
    -- Create new highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "DraconicBotHighlight_" .. bot.Name
    highlight.Parent = bot
    
    -- Visibility settings (through walls)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Color: Red for all bots
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
    
    botHighlights[bot] = highlight
end

-- Function to remove highlight from a bot
local function removeBotHighlight(bot)
    -- Restore original transparency for hitboxes
    restoreHitboxesTransparency(bot)
    
    if botHighlights[bot] then
        local highlight = botHighlights[bot]
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
        botHighlights[bot] = nil
    end
end

-- Function to clear all bot highlights
local function clearAllHighlights()
    -- Restore transparency for all bots
    for bot in pairs(botHighlights) do
        restoreHitboxesTransparency(bot)
    end
    
    for bot, highlight in pairs(botHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    botHighlights = {}
end

-- Function to find all bots in the game
local function findAllBots()
    local bots = {}
    
    -- Check in NPCs folder
    local npcsFolder = workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, model in ipairs(npcsFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                table.insert(bots, model)
            end
        end
    end
    
    -- Check in Game.Players folder (some bots might be there)
    local playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if playersFolder then
        for _, model in ipairs(playersFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                table.insert(bots, model)
            end
        end
    end
    
    return bots
end

-- Main update function for all bots
local function updateAllHighlights()
    if not isEnabled then return end
    
    local currentBots = {}
    local bots = findAllBots()
    
    -- Update/create highlights for current bots
    for _, bot in ipairs(bots) do
        currentBots[bot] = true
        updateBotHighlight(bot)
    end
    
    -- Remove highlights for bots that no longer exist
    for bot in pairs(botHighlights) do
        if not currentBots[bot] or not bot.Parent then
            removeBotHighlight(bot)
        end
    end
end

-- Start the module
function module:Start()
    if isEnabled then return end
    isEnabled = true
    
    -- Clear any stored transparency data from previous runs
    originalTransparencies = {}
    
    -- Create highlights for existing bots
    updateAllHighlights()
    
    -- Start update loop
    if highlightConnection then
        highlightConnection:Disconnect()
    end
    
    highlightConnection = RunService.Heartbeat:Connect(function()
        if isEnabled then
            updateAllHighlights()
        end
    end)
    
    -- Subscribe to new bots being added
    local function watchForNewBots(folder)
        if not folder then return end
        
        folder.ChildAdded:Connect(function(child)
            if isEnabled and child:IsA("Model") and isNextbotModel(child) then
                task.wait(0.1) -- Wait for model to fully load
                updateBotHighlight(child)
            end
        end)
        
        folder.ChildRemoved:Connect(function(child)
            if isEnabled then
                removeBotHighlight(child)
            end
        end)
    end
    
    -- Watch both possible bot locations
    local npcsFolder = workspace:FindFirstChild("NPCs")
    if npcsFolder then
        watchForNewBots(npcsFolder)
    end
    
    local playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if playersFolder then
        watchForNewBots(playersFolder)
    end
    
    if Fluent then
        Fluent:Notify({
            Title = "Highlight Bots",
            Content = "Enabled (Bots highlighted in RED, hitboxes visible)",
            Duration = 3
        })
    end
    
    print("Highlight Bots module started")
end

-- Stop the module
function module:Stop()
    if not isEnabled then return end
    isEnabled = false
    
    if highlightConnection then
        highlightConnection:Disconnect()
        highlightConnection = nil
    end
    
    clearAllHighlights()
    
    if Fluent then
        Fluent:Notify({
            Title = "Highlight Bots",
            Content = "Disabled",
            Duration = 3
        })
    end
    
    print("Highlight Bots module stopped")
end

-- Toggle function (for keybinds)
function module:Toggle()
    if isEnabled then
        self:Stop()
    else
        self:Start()
    end
    return isEnabled
end

-- Check if module is running
function module:IsEnabled()
    return isEnabled
end

-- Force update all highlights
function module:Refresh()
    if isEnabled then
        updateAllHighlights()
    end
end

return module
