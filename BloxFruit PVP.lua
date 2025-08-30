--[[
    HJ & Hakai Bounty Hunt Script
    Complete with all functionalities
--]]

-- Safe notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "COLLAB OF HARJAS AND HAKAI", 
        Text = "ENJOY BOUNTY HUNT", 
        Duration = 5
    })
end)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- UI Creation
local gui = Instance.new("ScreenGui")
gui.Name = "HJ_MainUI"
gui.Parent = game:GetService("CoreGui")

-- Toggle Icon
local icon = Instance.new("TextButton")
icon.Parent = gui
icon.Size = UDim2.new(0, 35, 0, 35)
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
main.Size = UDim2.new(0, 220, 0, 350)
main.Position = UDim2.new(0, 70, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.Visible = false
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- Title Bar
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundTransparency = 1

-- Close Button
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 2)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)

-- Scroll Frame for buttons
local scrollFrame = Instance.new("ScrollingFrame", main)
scrollFrame.Size = UDim2.new(1, -8, 1, -35)
scrollFrame.Position = UDim2.new(0, 4, 0, 32)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 4
scrollFrame.BackgroundTransparency = 1

-- Layout
local layout = Instance.new("UIListLayout", scrollFrame)
layout.Padding = UDim.new(0, 8)
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
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    button.Text = name
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", button)
    
    button.MouseButton1Click:Connect(function()
        callback(button)
    end)
    
    -- Update scroll frame size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    return button
end

-- ==================== FEATURE DEFINITIONS ==================== --

-- Table to store all button definitions
local buttonDefinitions = {}

-- ESP Feature
buttonDefinitions.esp = {
    name = "ESP 👁️: OFF",
    callback = function(button)
        -- ESP state and objects storage
        if not buttonDefinitions.esp.enabled then
            buttonDefinitions.esp.enabled = true
            button.Text = "ESP 👁️: ON"
            
            -- ESP implementation
            buttonDefinitions.esp.objects = {}
            
            local function createESP(player)
                if buttonDefinitions.esp.objects[player] or player == LocalPlayer then return end
                
                if player.Character then
                    -- Create highlight
                    local highlight = Instance.new("Highlight")
                    highlight.FillTransparency = 1
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineTransparency = 0
                    highlight.Parent = player.Character
                    highlight.Adornee = player.Character
                    
                    -- Create billboard GUI for username with infinite range
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ZenoESP"
                    billboard.Adornee = player.Character:WaitForChild("Head")
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                    billboard.AlwaysOnTop = true
                    billboard.MaxDistance = math.huge -- INFINITE RANGE
                    billboard.Parent = player.Character
                    
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Name = "PlayerName"
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = player.Name
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLabel.TextStrokeTransparency = 0
                    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.TextSize = 16
                    nameLabel.Parent = billboard
                    
                    -- Store both objects
                    buttonDefinitions.esp.objects[player] = {
                        Highlight = highlight,
                        Billboard = billboard
                    }
                end
            end
            
            local function removeESP(player)
                if buttonDefinitions.esp.objects[player] then
                    if buttonDefinitions.esp.objects[player].Highlight then
                        buttonDefinitions.esp.objects[player].Highlight:Destroy()
                    end
                    if buttonDefinitions.esp.objects[player].Billboard then
                        buttonDefinitions.esp.objects[player].Billboard:Destroy()
                    end
                    buttonDefinitions.esp.objects[player] = nil
                end
            end
            
            -- Set up event listeners
            local function onCharacterAdded(player, character)
                if buttonDefinitions.esp.enabled and player ~= LocalPlayer then
                    task.wait(1) -- Wait for character to fully load
                    createESP(player)
                end
            end
            
            local function onPlayerAdded(player)
                player.CharacterAdded:Connect(function(character)
                    onCharacterAdded(player, character)
                end)
                
                if player.Character and buttonDefinitions.esp.enabled and player ~= LocalPlayer then
                    onCharacterAdded(player, player.Character)
                end
            end
            
            local function onPlayerRemoving(player)
                removeESP(player)
            end
            
            Players.PlayerAdded:Connect(onPlayerAdded)
            Players.PlayerRemoving:Connect(onPlayerRemoving)
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    onCharacterAdded(player, player.Character)
                end
                player.CharacterAdded:Connect(function(character)
                    onCharacterAdded(player, character)
                end)
            end
        else
            buttonDefinitions.esp.enabled = false
            button.Text = "ESP 👁️: OFF"
            
            -- Remove ESP from all players
            for player, espObjects in pairs(buttonDefinitions.esp.objects or {}) do
                if espObjects.Highlight then espObjects.Highlight:Destroy() end
                if espObjects.Billboard then espObjects.Billboard:Destroy() end
            end
            buttonDefinitions.esp.objects = {}
        end
    end,
    enabled = false,
    objects = {}
}

-- Speed Feature
buttonDefinitions.speed = {
    name = "SPEED🏃: OFF",
    callback = function(button)
        if not buttonDefinitions.speed.enabled then
            buttonDefinitions.speed.enabled = true
            
            -- Create input for custom speed
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
                    button.Text = "SPEED🏃: ON (" .. customSpeed .. ")"
                    
                    -- Apply speed logic
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
            button.Text = "SPEED🏃: OFF"
            
            -- Reset speed logic
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
    name = "WALLWALKER🧱: OFF",
    callback = function(button)
        buttonDefinitions.wallwalk.enabled = not buttonDefinitions.wallwalk.enabled
        button.Text = buttonDefinitions.wallwalk.enabled and "WALLWALKER🧱: ON" or "WALLWALKER🧱: OFF"
        
        -- Wallwalk logic
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
    name = "JUMP⚡: OFF",
    callback = function(button)
        if not buttonDefinitions.jump.enabled then
            buttonDefinitions.jump.enabled = true
            
            -- Create input for custom jump power
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
                    button.Text = "JUMP⚡: ON (" .. jumpPower .. ")"
                    
                    -- Apply jump logic
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
            button.Text = "JUMP⚡: OFF"
            
            -- Reset jump logic
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

-- Fly Feature
buttonDefinitions.fly = {
    name = "FLY👼: OFF",
    callback = function(button)
        buttonDefinitions.fly.enabled = not buttonDefinitions.fly.enabled
        button.Text = buttonDefinitions.fly.enabled and "FLY👼: ON" or "FLY👼: OFF"
        
        -- Fly logic
        if buttonDefinitions.fly.enabled then
            if buttonDefinitions.fly.connection then
                buttonDefinitions.fly.connection:Disconnect()
            end
            
            buttonDefinitions.fly.connection = UserInputService.JumpRequest:Connect(function()
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        else
            if buttonDefinitions.fly.connection then
                buttonDefinitions.fly.connection:Disconnect()
                buttonDefinitions.fly.connection = nil
            end
        end
    end,
    enabled = false,
    connection = nil
}

-- Hitbox Feature
buttonDefinitions.hitbox = {
    name = "HITBOX🥊",
    callback = function(button)
        -- Hitbox expander implementation
        local hitboxEnabled = false
        local hitboxSize = 5
        local originalSizes = {}
        
        local hitboxGui = Instance.new("ScreenGui", game.CoreGui)
        hitboxGui.Name = "HitboxExpanderUI"
        
        local mainFrame = Instance.new("Frame", hitboxGui)
        mainFrame.Size = UDim2.new(0, 180, 0, 120)
        mainFrame.Position = UDim2.new(0.5, -90, 0, 10)
        mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        mainFrame.BackgroundTransparency = 0.2
        mainFrame.Active = true
        mainFrame.Draggable = true
        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
        
        local toggleButton = Instance.new("TextButton", mainFrame)
        toggleButton.Size = UDim2.new(1, -20, 0, 30)
        toggleButton.Position = UDim2.new(0, 10, 0, 10)
        toggleButton.Text = "Hitbox: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        toggleButton.TextColor3 = Color3.new(1, 1, 1)
        toggleButton.TextScaled = true
        toggleButton.Font = Enum.Font.GothamBold
        
        local sizeBox = Instance.new("TextBox", mainFrame)
        sizeBox.Size = UDim2.new(1, -20, 0, 30)
        sizeBox.Position = UDim2.new(0, 10, 0, 50)
        sizeBox.Text = tostring(hitboxSize)
        sizeBox.PlaceholderText = "Size (1-100)"
        sizeBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        sizeBox.TextColor3 = Color3.new(1, 1, 1)
        sizeBox.TextScaled = true
        sizeBox.ClearTextOnFocus = false
        sizeBox.Font = Enum.Font.Gotham
        
        local closeButton = Instance.new("TextButton", mainFrame)
        closeButton.Size = UDim2.new(0, 25, 0, 25)
        closeButton.Position = UDim2.new(1, -30, 0, 5)
        closeButton.Text = "X"
        closeButton.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
        closeButton.TextColor3 = Color3.new(1, 1, 1)
        closeButton.TextScaled = true
        closeButton.Font = Enum.Font.GothamBold
        Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 4)
        
        local miniToggle = Instance.new("TextButton", hitboxGui)
        miniToggle.Size = UDim2.new(0, 50, 0, 30)
        miniToggle.Position = UDim2.new(0, 10, 0.5, -90)
        miniToggle.Text = "HB"
        miniToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        miniToggle.TextColor3 = Color3.new(1, 1, 1)
        miniToggle.TextScaled = true
        miniToggle.Font = Enum.Font.GothamBold
        miniToggle.Visible = false
        miniToggle.Active = true
        miniToggle.Draggable = true
        Instance.new("UICorner", miniToggle).CornerRadius = UDim.new(0, 6)
        
        local function restoreHitboxes()
            for player, originalSize in pairs(originalSizes) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    hrp.Size = originalSize
                    hrp.Transparency = 1
                    hrp.Material = Enum.Material.Plastic
                    hrp.CanCollide = true
                end
            end
            originalSizes = {}
        end
        
        local function updateHitboxes()
            if hitboxEnabled then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = player.Character.HumanoidRootPart
                        if not originalSizes[player] then
                            originalSizes[player] = hrp.Size
                        end
                        hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                        hrp.Transparency = 0.7
                        hrp.Material = Enum.Material.ForceField
                        hrp.CanCollide = false
                    end
                end
            else
                restoreHitboxes()
            end
        end
        
        toggleButton.MouseButton1Click:Connect(function()
            hitboxEnabled = not hitboxEnabled
            toggleButton.Text = hitboxEnabled and "Hitbox: ON" or "Hitbox: OFF"
            if not hitboxEnabled then
                restoreHitboxes()
            end
        end)
        
        sizeBox.FocusLost:Connect(function()
            local newSize = tonumber(sizeBox.Text)
            if newSize and newSize >= 1 and newSize <= 100 then
                hitboxSize = newSize
            else
                sizeBox.Text = tostring(hitboxSize)
            end
        end)
        
        closeButton.MouseButton1Click:Connect(function()
            mainFrame.Visible = false
            miniToggle.Visible = true
        end)
        
        miniToggle.MouseButton1Click:Connect(function()
            mainFrame.Visible = true
            miniToggle.Visible = false
        end)
        
        RunService.RenderStepped:Connect(updateHitboxes)
    end
}

-- RedzHub Feature
buttonDefinitions.redzhub = {
    name = "REDZHUB☠️",
    callback = function(button)
        -- Load RedzHub script
        loadstring(game:HttpGet("https://raw.githubusercontent.com/tlredz/Scripts/refs/heads/main/main.luau"))()
    end
}

-- Camlock Feature
buttonDefinitions.camlock = {
    name = "CAMLOCK 🎯",
    callback = function(button)
        -- Camlock implementation
        local camlockEnabled = false
        local target = nil
        
        local camlockGui = Instance.new("ScreenGui", game.CoreGui)
        camlockGui.Name = "HakaijasCamlock"
        
        local camlockButton = Instance.new("TextButton", camlockGui)
        camlockButton.Size = UDim2.new(0, 180, 0, 50)
        camlockButton.Position = UDim2.new(0.5, -90, 0, 10)
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
        
        RunService.RenderStepped:Connect(function()
            if camlockEnabled and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end)
    end
}

-- ==================== CREATE BUTTONS FROM DEFINITIONS ==================== --

-- Create all buttons from the definitions table
for _, definition in pairs(buttonDefinitions) do
    createBtn(definition.name, definition.callback)
end

-- Character added event to reapply features
LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Reapply speed if enabled
    if buttonDefinitions.speed.enabled and buttonDefinitions.speed.connection then
        buttonDefinitions.speed.connection:Disconnect()
        humanoid.WalkSpeed = buttonDefinitions.speed.value
        buttonDefinitions.speed.connection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if humanoid.WalkSpeed ~= buttonDefinitions.speed.value then
                humanoid.WalkSpeed = buttonDefinitions.speed.value
            end
        end)
    end
    
    -- Reapply jump if enabled
    if buttonDefinitions.jump.enabled and buttonDefinitions.jump.connection then
        buttonDefinitions.jump.connection:Disconnect()
        humanoid.JumpPower = buttonDefinitions.jump.value
        buttonDefinitions.jump.connection = humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if humanoid.JumpPower ~= buttonDefinitions.jump.value then
                humanoid.JumpPower = buttonDefinitions.jump.value
            end
        end)
    end
    
    -- Reapply fly if enabled
    if buttonDefinitions.fly.enabled and buttonDefinitions.fly.connection then
        buttonDefinitions.fly.connection:Disconnect()
        buttonDefinitions.fly.connection = UserInputService.JumpRequest:Connect(function()
            if character:IsDescendantOf(workspace) then
                local hum = character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
    
    -- Reapply wallwalk if enabled
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
