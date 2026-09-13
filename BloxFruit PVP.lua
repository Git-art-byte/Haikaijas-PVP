--[[ HJ & Hakai Bounty Hunt Script - Modified ]]--
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "COLLAB OF HARJAS AND HAKAI",
        Text = "ENJOY BOUNTY HUNT",
        Duration = 5
    })
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Auto VisionRadius Loop
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            LocalPlayer.VisionRadius.Value = 3000000
        end)
    end
end)

-- UI Creation (reduced sizes)
local gui = Instance.new("ScreenGui")
gui.Name = "HJ_MainUI"
gui.Parent = game:GetService("CoreGui")

-- Toggle Icon
local icon = Instance.new("TextButton")
icon.Parent = gui
icon.Size = UDim2.new(0, 28, 0, 28)
icon.Position = UDim2.new(0, 20, 0.5, -20)
icon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
icon.Text = "HJ"
icon.TextScaled = true
icon.Font = Enum.Font.GothamBold
icon.TextColor3 = Color3.new(1, 1, 1)
icon.Draggable = true
icon.Active = true
Instance.new("UICorner", icon)

-- Main Window
local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0, 180, 0, 280)
main.Position = UDim2.new(0, 70, 0.5, -140)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.Visible = false
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- Title Bar
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 24)
titleBar.BackgroundTransparency = 1

-- Close Button
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -24, 0, 2)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)

-- Scroll Frame
local scrollFrame = Instance.new("ScrollingFrame", main)
scrollFrame.Size = UDim2.new(1, -8, 1, -28)
scrollFrame.Position = UDim2.new(0, 4, 0, 26)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 4
scrollFrame.BackgroundTransparency = 1

-- Layout
local layout = Instance.new("UIListLayout", scrollFrame)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Toggle menu visibility
icon.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    icon.Text = main.Visible and " HJ" or "HJ"
end)
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    icon.Text = "HJ"
end)

-- Button creation function
local function createBtn(name, callback)
    local button = Instance.new("TextButton", scrollFrame)
    button.Size = UDim2.new(1, 0, 0, 28)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    button.Text = name
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", button)
    button.MouseButton1Click:Connect(function()
        callback(button)
    end)
    return button
end

-- Update scroll frame size
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)

-- ==================== HELPERS ====================
-- Robust level getter (handles Data.Level being a number OR a ValueObject)
local function getPlayerLevel(player)
    local level = nil
    pcall(function()
        local data = player:FindFirstChild("Data")
        if data then
            local lvl = data:FindFirstChild("Level")
            if lvl then
                if typeof(lvl) == "Instance" and (lvl:IsA("IntValue") or lvl:IsA("NumberValue") or lvl:IsA("StringValue")) then
                    level = lvl.Value
                else
                    level = lvl
                end
            end
        end
    end)
    return level
end

-- ==================== FEATURE DEFINITIONS ====================
local buttonDefinitions = {}

-- ESP Feature (loop-based, live level update)
buttonDefinitions.esp = {
    name = "ESP: OFF",
    enabled = false,
    objects = {},
    connection = nil,
    callback = function(button)
        if not buttonDefinitions.esp.enabled then
            buttonDefinitions.esp.enabled = true
            button.Text = "ESP: ON"
            buttonDefinitions.esp.objects = {}

            local function createESP(player)
                if buttonDefinitions.esp.objects[player] or player == LocalPlayer then return end
                if not player.Character then return end
                local head = player.Character:FindFirstChild("Head")
                if not head then return end

                local highlight = Instance.new("Highlight")
                highlight.FillTransparency = 1
                highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineTransparency = 0
                highlight.Parent = player.Character
                highlight.Adornee = player.Character

                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ZenoESP"
                billboard.Adornee = head
                billboard.Size = UDim2.new(0, 150, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                billboard.AlwaysOnTop = true
                billboard.MaxDistance = math.huge
                billboard.Parent = player.Character

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Name = "PlayerName"
                nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextStrokeTransparency = 0
                nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 12
                nameLabel.Parent = billboard

                local levelLabel = Instance.new("TextLabel")
                levelLabel.Name = "PlayerLevel"
                levelLabel.Size = UDim2.new(1, 0, 0.5, 0)
                levelLabel.Position = UDim2.new(0, 0, 0.5, 0)
                levelLabel.BackgroundTransparency = 1
                local lvl = getPlayerLevel(player)
                levelLabel.Text = lvl and ("Lv. " .. tostring(lvl)) or "Lv. ?"
                levelLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                levelLabel.TextStrokeTransparency = 0
                levelLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                levelLabel.Font = Enum.Font.GothamBold
                levelLabel.TextSize = 10
                levelLabel.Parent = billboard

                buttonDefinitions.esp.objects[player] = {
                    Highlight = highlight,
                    Billboard = billboard
                }
            end

            local function removeESP(player)
                local data = buttonDefinitions.esp.objects[player]
                if data then
                    if data.Highlight then data.Highlight:Destroy() end
                    if data.Billboard then data.Billboard:Destroy() end
                    buttonDefinitions.esp.objects[player] = nil
                end
            end

            buttonDefinitions.esp.connection = RunService.RenderStepped:Connect(function()
                if not buttonDefinitions.esp.enabled then return end
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        if player.Character and player.Character:FindFirstChild("Head") then
                            if not buttonDefinitions.esp.objects[player] then
                                createESP(player)
                            end

                            -- Live-update level label
                            local espData = buttonDefinitions.esp.objects[player]
                            if espData and espData.Billboard then
                                local lvlLabel = espData.Billboard:FindFirstChild("PlayerLevel")
                                if lvlLabel then
                                    local lvl = getPlayerLevel(player)
                                    lvlLabel.Text = lvl and ("Lv. " .. tostring(lvl)) or "Lv. ?"
                                end
                            end
                        else
                            removeESP(player)
                        end
                    end
                end
            end)

            -- Initial setup
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    createESP(player)
                end
            end
        else
            buttonDefinitions.esp.enabled = false
            button.Text = "ESP: OFF"
            if buttonDefinitions.esp.connection then
                buttonDefinitions.esp.connection:Disconnect()
                buttonDefinitions.esp.connection = nil
            end
            for player, espObjects in pairs(buttonDefinitions.esp.objects or {}) do
                if espObjects.Highlight then espObjects.Highlight:Destroy() end
                if espObjects.Billboard then espObjects.Billboard:Destroy() end
            end
            buttonDefinitions.esp.objects = {}
        end
    end
}

-- Speed Feature
buttonDefinitions.speed = {
    name = "SPEED: OFF",
    callback = function(button)
        if not buttonDefinitions.speed.enabled then
            buttonDefinitions.speed.enabled = true
            local speedInput = Instance.new("TextBox")
            speedInput.Parent = button
            speedInput.Size = UDim2.new(0.5, 0, 1, 0)
            speedInput.Position = UDim2.new(0.5, 0, 0, 0)
            speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            speedInput.TextColor3 = Color3.new(1, 1, 1)
            speedInput.PlaceholderText = "Enter speed"
            speedInput.Font = Enum.Font.Gotham
            speedInput.TextScaled = true
            Instance.new("UICorner", speedInput)
            speedInput.FocusLost:Connect(function()
                local customSpeed = tonumber(speedInput.Text)
                if customSpeed and customSpeed > 0 then
                    buttonDefinitions.speed.value = customSpeed
                    button.Text = "SPEED: ON (" .. customSpeed .. ")"
                    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = customSpeed
                        if buttonDefinitions.speed.connection then
                            buttonDefinitions.speed.connection:Disconnect()
                        end
                        buttonDefinitions.speed.connection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                            if humanoid.WalkSpeed ~= customSpeed then
                                humanoid.WalkSpeed = customSpeed
                            end
                        end)
                    end
                end
                speedInput:Destroy()
            end)
        else
            buttonDefinitions.speed.enabled = false
            button.Text = "SPEED: OFF"
            if buttonDefinitions.speed.connection then
                buttonDefinitions.speed.connection:Disconnect()
                buttonDefinitions.speed.connection = nil
            end
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end,
    enabled = false,
    value = 50,
    connection = nil
}

-- Wallwalk Feature
buttonDefinitions.wallwalk = {
    name = "NOCLIP: OFF",
    callback = function(button)
        buttonDefinitions.wallwalk.enabled = not buttonDefinitions.wallwalk.enabled
        button.Text = buttonDefinitions.wallwalk.enabled and "NOCLIP: ON" or "NOCLIP: OFF"
        if buttonDefinitions.wallwalk.enabled then
            if buttonDefinitions.wallwalk.connection then
                buttonDefinitions.wallwalk.connection:Disconnect()
            end
            buttonDefinitions.wallwalk.connection = RunService.Stepped:Connect(function()
                local character = LocalPlayer.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if buttonDefinitions.wallwalk.connection then
                buttonDefinitions.wallwalk.connection:Disconnect()
                buttonDefinitions.wallwalk.connection = nil
            end
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
    enabled = false,
    connection = nil
}

-- Jump Feature
buttonDefinitions.jump = {
    name = "JUMP: OFF",
    callback = function(button)
        if not buttonDefinitions.jump.enabled then
            buttonDefinitions.jump.enabled = true
            local jumpInput = Instance.new("TextBox")
            jumpInput.Parent = button
            jumpInput.Size = UDim2.new(0.5, 0, 1, 0)
            jumpInput.Position = UDim2.new(0.5, 0, 0, 0)
            jumpInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            jumpInput.TextColor3 = Color3.new(1, 1, 1)
            jumpInput.PlaceholderText = "Jump power"
            jumpInput.Font = Enum.Font.Gotham
            jumpInput.TextScaled = true
            Instance.new("UICorner", jumpInput)
            jumpInput.FocusLost:Connect(function()
                local jumpPower = tonumber(jumpInput.Text)
                if jumpPower and jumpPower > 0 then
                    buttonDefinitions.jump.value = jumpPower
                    button.Text = "JUMP: ON (" .. jumpPower .. ")"
                    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.JumpPower = jumpPower
                        if buttonDefinitions.jump.connection then
                            buttonDefinitions.jump.connection:Disconnect()
                        end
                        buttonDefinitions.jump.connection = humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
                            if humanoid.JumpPower ~= jumpPower then
                                humanoid.JumpPower = jumpPower
                            end
                        end)
                    end
                end
                jumpInput:Destroy()
            end)
        else
            buttonDefinitions.jump.enabled = false
            button.Text = "JUMP: OFF"
            if buttonDefinitions.jump.connection then
                buttonDefinitions.jump.connection:Disconnect()
                buttonDefinitions.jump.connection = nil
            end
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = 50
            end
        end
    end,
    enabled = false,
    value = 100,
    connection = nil
}

-- Fly Feature (with customizable speed)
buttonDefinitions.fly = {
    name = "FLY: OFF",
    callback = function(button)
        if not buttonDefinitions.fly.enabled then
            buttonDefinitions.fly.enabled = true
            local flyInput = Instance.new("TextBox")
            flyInput.Parent = button
            flyInput.Size = UDim2.new(0.5, 0, 1, 0)
            flyInput.Position = UDim2.new(0.5, 0, 0, 0)
            flyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            flyInput.TextColor3 = Color3.new(1, 1, 1)
            flyInput.PlaceholderText = "Fly speed"
            flyInput.Font = Enum.Font.Gotham
            flyInput.TextScaled = true
            Instance.new("UICorner", flyInput)
            flyInput.FocusLost:Connect(function()
                local flySpeed = tonumber(flyInput.Text)
                if flySpeed and flySpeed > 0 then
                    buttonDefinitions.fly.value = flySpeed
                    button.Text = "FLY: ON (" .. flySpeed .. ")"
                    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = flySpeed
                        if buttonDefinitions.fly.connection then
                            buttonDefinitions.fly.connection:Disconnect()
                        end
                        buttonDefinitions.fly.connection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                            if humanoid.WalkSpeed ~= flySpeed then
                                humanoid.WalkSpeed = flySpeed
                            end
                        end)
                    end
                end
                flyInput:Destroy()
            end)
        else
            buttonDefinitions.fly.enabled = false
            button.Text = "FLY: OFF"
            if buttonDefinitions.fly.connection then
                buttonDefinitions.fly.connection:Disconnect()
                buttonDefinitions.fly.connection = nil
            end
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end,
    enabled = false,
    value = 100,
    connection = nil
}

-- Camlock Feature (fixed to avoid duplicates)
local camlockGui = nil
local camlockButton = nil
local camlockEnabled = false
local target = nil

local function createCamlockUI()
    if camlockGui and camlockGui.Parent then return end
    camlockGui = Instance.new("ScreenGui")
    camlockGui.Name = "HakaijasCamlock"
    camlockGui.Parent = game.CoreGui

    camlockButton = Instance.new("TextButton", camlockGui)
    camlockButton.Size = UDim2.new(0, 140, 0, 40)
    camlockButton.Position = UDim2.new(0.5, -70, 0, 10)
    camlockButton.Text = "HAKAIJAS: OFF"
    camlockButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    camlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    camlockButton.TextScaled = true
    camlockButton.Font = Enum.Font.GothamBold
    camlockButton.Draggable = true
    camlockButton.Active = true
    Instance.new("UICorner", camlockButton).CornerRadius = UDim.new(0, 8)

    camlockButton.MouseButton1Click:Connect(function()
        camlockEnabled = not camlockEnabled
        camlockButton.Text = camlockEnabled and "HAKAIJAS: ON" or "HAKAIJAS: OFF"
        if camlockEnabled then
            local closestTarget = nil
            local shortestDistance = math.huge
            local viewportSize = workspace.CurrentCamera.ViewportSize
            local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local position, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local distance = (center - Vector2.new(position.X, position.Y)).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestTarget = player
                        end
                    end
                end
            end
            target = closestTarget
        else
            target = nil
        end
    end)
end

buttonDefinitions.camlock = {
    name = "CAMLOCK",
    callback = function(button)
        createCamlockUI()
        camlockEnabled = not camlockEnabled
        camlockButton.Text = camlockEnabled and "HAKAIJAS: ON" or "HAKAIJAS: OFF"
        if camlockEnabled then
            local closestTarget = nil
            local shortestDistance = math.huge
            local viewportSize = workspace.CurrentCamera.ViewportSize
            local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local position, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local distance = (center - Vector2.new(position.X, position.Y)).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestTarget = player
                        end
                    end
                end
            end
            target = closestTarget
        else
            target = nil
        end
    end
}

-- Camlock update loop
RunService.RenderStepped:Connect(function()
    if camlockEnabled and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        workspace.CurrentCamera.CFrame = CFrame.new(
            workspace.CurrentCamera.CFrame.Position,
            target.Character.HumanoidRootPart.Position
        )
    end
end)

-- TP Feature
local tpEnabled = false
local tpTarget = nil
local tpConnection = nil

local function getScreenTarget()
    local closestTarget = nil
    local shortestDistance = math.huge

    local camera = workspace.CurrentCamera
    local viewportSize = camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer
        and player.Character
        and player.Character:FindFirstChild("HumanoidRootPart") then

            local root = player.Character.HumanoidRootPart
            local position, onScreen =
                camera:WorldToViewportPoint(root.Position)

            if onScreen then
                local distance =
                    (center - Vector2.new(position.X, position.Y)).Magnitude

                if distance < shortestDistance then
                    shortestDistance = distance
                    closestTarget = player
                end
            end
        end
    end

    return closestTarget
end

buttonDefinitions.tp = {
    name = "TP: OFF",

    callback = function(button)
        tpEnabled = not tpEnabled

        if tpEnabled then
            button.Text = "TP: ON"

            tpTarget = getScreenTarget()

            if tpConnection then
                tpConnection:Disconnect()
            end

            tpConnection = RunService.Heartbeat:Connect(function()
                if not tpEnabled then
                    return
                end

                local character = LocalPlayer.Character
                local targetCharacter = tpTarget and tpTarget.Character

                if character
                and targetCharacter
                and targetCharacter:FindFirstChild("HumanoidRootPart")
                and character:FindFirstChild("HumanoidRootPart") then

                    character.HumanoidRootPart.CFrame =
                        targetCharacter.HumanoidRootPart.CFrame
                end
            end)

        else
            button.Text = "TP: OFF"
            tpTarget = nil

            if tpConnection then
                tpConnection:Disconnect()
                tpConnection = nil
            end
        end
    end
}

-- ==================== CREATE BUTTONS ====================
for _, definition in pairs(buttonDefinitions) do
    createBtn(definition.name, definition.callback)
end

-- Character added event to reapply features
LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    if buttonDefinitions.speed.enabled and buttonDefinitions.speed.connection then
        buttonDefinitions.speed.connection:Disconnect()
        humanoid.WalkSpeed = buttonDefinitions.speed.value
        buttonDefinitions.speed.connection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if humanoid.WalkSpeed ~= buttonDefinitions.speed.value then
                humanoid.WalkSpeed = buttonDefinitions.speed.value
            end
        end)
    end
    if buttonDefinitions.jump.enabled and buttonDefinitions.jump.connection then
        buttonDefinitions.jump.connection:Disconnect()
        humanoid.JumpPower = buttonDefinitions.jump.value
        buttonDefinitions.jump.connection = humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if humanoid.JumpPower ~= buttonDefinitions.jump.value then
                humanoid.JumpPower = buttonDefinitions.jump.value
            end
        end)
    end
    if buttonDefinitions.fly.enabled and buttonDefinitions.fly.connection then
        buttonDefinitions.fly.connection:Disconnect()
        humanoid.WalkSpeed = buttonDefinitions.fly.value
        buttonDefinitions.fly.connection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if humanoid.WalkSpeed ~= buttonDefinitions.fly.value then
                humanoid.WalkSpeed = buttonDefinitions.fly.value
            end
        end)
    end
    if buttonDefinitions.wallwalk.enabled and buttonDefinitions.wallwalk.connection then
        buttonDefinitions.wallwalk.connection:Disconnect()
        buttonDefinitions.wallwalk.connection = RunService.Stepped:Connect(function()
            if character:IsDescendantOf(workspace) then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)
