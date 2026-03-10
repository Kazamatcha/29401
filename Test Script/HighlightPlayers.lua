-- ==================== HIGHLIGHT DOWNED PLAYERS MODULE ====================
-- External module for Draconic Hub X Evade
-- File: HighlightDownedPlayers.lua

local module = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Internal variables
local playerHighlights = {}
local highlightConnection = nil
local isEnabled = false
local Fluent = nil
local Options = nil

-- Initialize module with Fluent library
function module:Init(fluentLib, options)
    Fluent = fluentLib
    Options = options
    print("Highlight Downed Players module initialized")
end

-- Function to check if player is downed
local function isPlayerDowned(player)
    if not player or not player.Character then return false end
    
    local character = player.Character
    
    -- Method 1: Downed attribute
    if character:GetAttribute("Downed") then
        return true
    end
    
    -- Method 2: Check Ragdolls folder
    local ragdollsFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Ragdolls")
    if ragdollsFolder and ragdollsFolder:FindFirstChild(player.Name) then
        return true
    end
    
    -- Method 3: Check Humanoid health
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health <= 0 then
        return true
    end
    
    return false
end

-- Function to update/create highlight for a player
local function updatePlayerHighlight(player)
    if not player or player == LocalPlayer then return end
    if not isEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    local isDowned = isPlayerDowned(player)
    
    -- If highlight already exists, update its color
    if playerHighlights[player] then
        local highlight = playerHighlights[player]
        if highlight and highlight.Parent then
            highlight.FillColor = isDowned and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 255, 255)
            highlight.OutlineColor = isDowned and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(200, 200, 200)
            return
        else
            playerHighlights[player] = nil
        end
    end
    
    -- Create new highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "DraconicHighlight_" .. player.Name
    highlight.Parent = character
    
    -- Visibility settings (through walls)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Colors: White (alive) or Yellow (downed)
    highlight.FillColor = isDowned and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = isDowned and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(200, 200, 200)
    
    playerHighlights[player] = highlight
end

-- Function to remove highlight from a player
local function removePlayerHighlight(player)
    if playerHighlights[player] then
        local highlight = playerHighlights[player]
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
        playerHighlights[player] = nil
    end
end

-- Function to clear all highlights
local function clearAllHighlights()
    for player, highlight in pairs(playerHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    playerHighlights = {}
end

-- Main update function for all players
local function updateAllHighlights()
    if not isEnabled then return end
    
    local currentPlayers = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            currentPlayers[player] = true
            updatePlayerHighlight(player)
        end
    end
    
    -- Remove highlights for players who left
    for player in pairs(playerHighlights) do
        if not currentPlayers[player] then
            removePlayerHighlight(player)
        end
    end
end

-- Start the module
function module:Start()
    if isEnabled then return end
    isEnabled = true
    
    -- Create highlights for existing players
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
    
    -- Subscribe to new players
    Players.PlayerAdded:Connect(function(newPlayer)
        if isEnabled then
            task.wait(0.5)
            updatePlayerHighlight(newPlayer)
        end
    end)
    
    -- Subscribe to player removal
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        if isEnabled then
            removePlayerHighlight(leavingPlayer)
        end
    end)
    
    -- Subscribe to character changes for all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function()
                if isEnabled then
                    task.wait(0.5)
                    updatePlayerHighlight(player)
                end
            end)
        end
    end
    
    -- Subscribe to future players' character changes
    Players.PlayerAdded:Connect(function(newPlayer)
        if newPlayer ~= LocalPlayer then
            newPlayer.CharacterAdded:Connect(function()
                if isEnabled then
                    task.wait(0.5)
                    updatePlayerHighlight(newPlayer)
                end
            end)
        end
    end)
    
    if Fluent then
        Fluent:Notify({
            Title = "Highlight Players",
            Content = "Enabled",
            Duration = 3
        })
    end
    
    print("Highlight Players module started")
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
            Title = "Highlight Players",
            Content = "Disabled",
            Duration = 3
        })
    end
    
    print("Highlight Players module stopped")
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
