--// Variáveis principais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer
local Connection, Parried, Cooldown
local Optimized = false

--// Função para obter a bola real
local function GetBall()
    for _, Ball in ipairs(workspace.Balls:GetChildren()) do
        if Ball:GetAttribute("realBall") then
            return Ball
        end
    end
end

--// Reset da conexão anterior
local function ResetConnection()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
end

--// Conecta a nova bola quando criada
workspace.Balls.ChildAdded:Connect(function()
    local Ball = GetBall()
    if not Ball then return end
    ResetConnection()
    Connection = Ball:GetAttributeChangedSignal("target"):Connect(function()
        Parried = false
    end)
end)

--// Interface (UI)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "BladeBallAutoParry"
ScreenGui.ResetOnSpawn = false

local MainUI = Instance.new("Frame", ScreenGui)
MainUI.Name = "MainUI"
MainUI.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainUI.BackgroundTransparency = 0.3
MainUI.BorderSizePixel = 0
MainUI.Position = UDim2.new(0.7, 0, 0.3, 0)
MainUI.Size = UDim2.new(0, 260, 0, 230)
MainUI.Visible = true
Instance.new("UICorner", MainUI).CornerRadius = UDim.new(0, 12)

-- Nome
local NameLabel = Instance.new("TextLabel", MainUI)
NameLabel.Text = "2Devs Blade Ball [Bypass until 05/05/25]"
NameLabel.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1) -- RGB automático
NameLabel.Font = Enum.Font.GothamSemibold
NameLabel.TextSize = 14
NameLabel.Position = UDim2.new(0, 10, 1, -20)
NameLabel.Size = UDim2.new(1, -20, 0, 20)
NameLabel.BackgroundTransparency = 1

-- NomeLabel efeito RGB
task.spawn(function()
    while task.wait() do
        NameLabel.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
end)

-- Auto Parry Toggle
local Enabled = true
local Toggle = Instance.new("TextButton", MainUI)
Toggle.Text = "Auto Parry [ON]"
Toggle.Size = UDim2.new(1, -20, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0, 10)
Toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 16
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)
Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    Toggle.Text = Enabled and "Auto Parry [ON]" or "Auto Parry [OFF]"
    Toggle.BackgroundColor3 = Enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
end)

-- Auto Spam Toggle
local SpamEnabled = false
local SpamToggle = Instance.new("TextButton", MainUI)
SpamToggle.Text = "Auto Spam [OFF]"
SpamToggle.Size = UDim2.new(1, -20, 0, 40)
SpamToggle.Position = UDim2.new(0, 10, 0, 60)
SpamToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
SpamToggle.TextColor3 = Color3.new(1, 1, 1)
SpamToggle.Font = Enum.Font.GothamBold
SpamToggle.TextSize = 16
Instance.new("UICorner", SpamToggle).CornerRadius = UDim.new(0, 8)
SpamToggle.MouseButton1Click:Connect(function()
    SpamEnabled = not SpamEnabled
    SpamToggle.Text = SpamEnabled and "Auto Spam [ON]" or "Auto Spam [OFF]"
    SpamToggle.BackgroundColor3 = SpamEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
end)

-- Optimize Game Toggle
local OptimizeToggle = Instance.new("TextButton", MainUI)
OptimizeToggle.Text = "Optimize Game [OFF]"
OptimizeToggle.Size = UDim2.new(1, -20, 0, 40)
OptimizeToggle.Position = UDim2.new(0, 10, 0, 110)
OptimizeToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
OptimizeToggle.TextColor3 = Color3.new(1, 1, 1)
OptimizeToggle.Font = Enum.Font.GothamBold
OptimizeToggle.TextSize = 16
Instance.new("UICorner", OptimizeToggle).CornerRadius = UDim.new(0, 8)
OptimizeToggle.MouseButton1Click:Connect(function()
    Optimized = not Optimized
    OptimizeToggle.Text = Optimized and "Optimize Game [ON]" or "Optimize Game [OFF]"
    OptimizeToggle.BackgroundColor3 = Optimized and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
    if Optimized then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("tree") or v.Name:lower():find("rock") or v.Name:lower():find("grass")) then
                v:Destroy()
            end
        end
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then
                v.Enabled = false
            end
        end
    end
end)

-- Destroy script button
local DestroyBtn = Instance.new("TextButton", MainUI)
DestroyBtn.Text = "Destroy Script"
DestroyBtn.Size = UDim2.new(1, -20, 0, 40)
DestroyBtn.Position = UDim2.new(0, 10, 0, 160)
DestroyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
DestroyBtn.TextColor3 = Color3.new(1, 1, 1)
DestroyBtn.Font = Enum.Font.GothamBold
DestroyBtn.TextSize = 16
Instance.new("UICorner", DestroyBtn).CornerRadius = UDim.new(0, 8)
DestroyBtn.MouseButton1Click:Connect(function()
    Enabled = false
    SpamEnabled = false
    MainUI.Visible = false
    if Connection then Connection:Disconnect() end
    if ScreenGui then ScreenGui:Destroy() end
    script:Destroy()
end)

-- Atalho PageUp para esconder/mostrar UI
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.PageUp then
        MainUI.Visible = not MainUI.Visible
    end
end)

-- Som de Parry
local function PlayParrySound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6026984224"
    sound.Volume = 2
    sound.Parent = workspace
    sound:Play()
    Debris:AddItem(sound, 2)
end

-- Auto Spam
RunService.Heartbeat:Connect(function()
    if not SpamEnabled or not Enabled then return end
    for _ = 1, 123 do -- 1.23 clicks (ajustado como pedido)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end)

-- Auto Parry (0.50 segundos de reação)
RunService.PreSimulation:Connect(function()
    if not Enabled then return end
    local Ball, HRP = GetBall(), Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not Ball or not HRP then return end

    local Speed = Ball.zoomies.VectorVelocity.Magnitude
    local Distance = (HRP.Position - Ball.Position).Magnitude
    local ReactionTime = 0.50

    if Ball:GetAttribute("target") == Player.Name and not Parried and Distance / Speed <= ReactionTime then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        Parried = true
        Cooldown = tick()
        PlayParrySound()
        if (tick() - Cooldown) >= 1 then
            Parried = false
        end
    end
end)

-- Tecla T para ativar/desativar Auto Spam
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T then
        SpamEnabled = not SpamEnabled
        SpamToggle.Text = SpamEnabled and "Auto Spam [ON]" or "Auto Spam [OFF]"
        SpamToggle.BackgroundColor3 = SpamEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
    end
end)

-- ✅ REMOVE COOLDOWN BLOCK
task.spawn(function()
    while task.wait(0.1) do
        local char = Player.Character
        if char and char:FindFirstChild("BlockingCooldown") then
            char.BlockingCooldown:Destroy()
        end
    end
end)

-- ✅ MENSAGEM DE CONSOLE (F9)
warn("Injected Successfully: 2Dev Blade Ball 👻")
