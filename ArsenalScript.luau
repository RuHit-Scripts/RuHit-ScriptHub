-- ArsenalScript.luau
-- Lightweight Roblox utility script for Arsenal-style gameplay helpers.
-- Adjust settings as needed for your personal setup.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

local ArsenalScript = {}

ArsenalScript.Config = {
    Enabled = true,
    MovementBoost = 1.0,
    FOV = 70,
    RecoilReduction = 0.25,
    SprintToggle = false,
    ShowDebug = false,
}

ArsenalScript.State = {
    CameraTween = nil,
    LastTick = tick(),
    Sprinting = false,
}

local function round(value)
    return math.floor(value + 0.5)
end

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    elseif value > maxValue then
        return maxValue
    end
    return value
end

local function getRootPart()
    local character = LocalPlayer.Character
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function applyFOV(targetFOV)
    if Camera then
        Camera.FieldOfView = targetFOV
    end
end

local function onCharacterAdded(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")

    if ArsenalScript.Config.ShowDebug then
        print("[ArsenalScript] Character loaded.")
    end
end

local function handleMovement()
    if not ArsenalScript.Config.Enabled then
        return
    end

    local rootPart = getRootPart()
    if rootPart and Humanoid then
        if ArsenalScript.Config.SprintToggle then
            if Humanoid.MoveDirection.Magnitude > 0 then
                Humanoid.WalkSpeed = 22 * ArsenalScript.Config.MovementBoost
                ArsenalScript.State.Sprinting = true
            else
                Humanoid.WalkSpeed = 16
                ArsenalScript.State.Sprinting = false
            end
        else
            Humanoid.WalkSpeed = 16 * ArsenalScript.Config.MovementBoost
            ArsenalScript.State.Sprinting = false
        end
    end
end

local function handleCamera()
    if not Camera or not ArsenalScript.Config.Enabled then
        return
    end

    local desiredFOV = ArsenalScript.Config.FOV
    local currentFOV = Camera.FieldOfView
    local delta = desiredFOV - currentFOV

    if math.abs(delta) > 0.05 then
        Camera.FieldOfView = currentFOV + (delta * 0.15)
    end
end

local function handleInput(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.LeftShift then
        ArsenalScript.Config.SprintToggle = not ArsenalScript.Config.SprintToggle
        if ArsenalScript.Config.ShowDebug then
            print("[ArsenalScript] Sprint toggle:", ArsenalScript.Config.SprintToggle)
        end
    end

    if input.KeyCode == Enum.KeyCode.F then
        ArsenalScript.Config.Enabled = not ArsenalScript.Config.Enabled
        if ArsenalScript.Config.Enabled then
            applyFOV(ArsenalScript.Config.FOV)
        else
            applyFOV(70)
        end

        if ArsenalScript.Config.ShowDebug then
            print("[ArsenalScript] Enabled:", ArsenalScript.Config.Enabled)
        end
    end
end

local function bindEvents()
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    UserInputService.InputBegan:Connect(handleInput)

    RunService.RenderStepped:Connect(function()
        handleMovement()
        handleCamera()
    end)
end

function ArsenalScript:Toggle()
    self.Config.Enabled = not self.Config.Enabled
    if self.Config.ShowDebug then
        print("[ArsenalScript] Script toggled:", self.Config.Enabled)
    end
end

function ArsenalScript:SetFOV(value)
    self.Config.FOV = clamp(value, 60, 120)
    applyFOV(self.Config.FOV)
end

function ArsenalScript:SetMovementBoost(value)
    self.Config.MovementBoost = clamp(value, 0.5, 2.5)
end

function ArsenalScript:SetRecoilReduction(value)
    self.Config.RecoilReduction = clamp(value, 0, 1)
end

bindEvents()
applyFOV(ArsenalScript.Config.FOV)

if ArsenalScript.Config.ShowDebug then
    print("[ArsenalScript] Initialized successfully.")
end

return ArsenalScript
