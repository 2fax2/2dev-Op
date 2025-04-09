--// Variáveis principais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Player = Players.LocalPlayer
local Connection, Parried, Cooldown
local SpamEnabled = false

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
MainUI.Size = UDim2.new(0, 260, 0, 200)
MainUI.Visible = true
Instance.new("UICorner", MainUI).CornerRadius = UDim.new(0, 12)

local NameLabel = Instance.new("TextLabel", MainUI)
NameLabel.Text = "2Devs Blade Ball"
NameLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
NameLabel.Font = Enum.Font.GothamSemibold
NameLabel.TextSize = 14
NameLabel.Position = UDim2.new(0, 10, 1, -20)
NameLabel.Size = UDim2.new(1, -20, 0, 20)
NameLabel.BackgroundTransparency = 1

--// Botões
local function CreateButton(name, position, color)
    local btn = Instance.new("TextButton", MainUI)
    btn.Text = name
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = position
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local Toggle = CreateButton("Auto Parry [ON]", UDim2.new(0, 10, 0, 10), Color3.fromRGB(50, 200, 50))
local SpamBtn = CreateButton("Auto Parry Spam [OFF]", UDim2.new(0, 10, 0, 60), Color3.fromRGB(100, 100, 100))
local DestroyBtn = CreateButton("Destroy Script", UDim2.new(0, 10, 0, 110), Color3.fromRGB(200, 50, 50))

--// Estados
local Enabled = true
Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    Toggle.Text = Enabled and "Auto Parry [ON]" or "Auto Parry [OFF]"
    Toggle.BackgroundColor3 = Enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
end)

SpamBtn.MouseButton1Click:Connect(function()
    SpamEnabled = not SpamEnabled
    SpamBtn.Text = SpamEnabled and "Auto Parry Spam [ON]" or "Auto Parry Spam [OFF]"
    SpamBtn.BackgroundColor3 = SpamEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.PageUp then
        MainUI.Visible = not MainUI.Visible
    end
end)

DestroyBtn.MouseButton1Click:Connect(function()
    if Connection then Connection:Disconnect() end
    if ScreenGui then ScreenGui:Destroy() end
    script:Destroy()
end)

--// Som
local function PlayParrySound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6026984224"
    sound.Volume = 2
    sound.Parent = workspace
    sound:Play()
    Debris:AddItem(sound, 2)
end

--// Auto Parry Melhorado (fix bolas rápidas e curvas)
RunService.Heartbeat:Connect(function()
    if not Enabled then return end
    local Ball = GetBall()
    local HRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not Ball or not HRP or Ball:GetAttribute("target") ~= Player.Name then return end
    if Parried then return end

    local Distance = (HRP.Position - Ball.Position).Magnitude
    local Velocity = Ball.AssemblyLinearVelocity.Magnitude

    -- Tempo estimado de impacto ajustado
    local PredictedTime = Distance / (Velocity + 1)
    if PredictedTime <= 0.53 then -- mais sensível e eficaz em bolas com curvas e alta velocidade
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        Parried = true
        Cooldown = tick()
        PlayParrySound()
    end

    if (tick() - (Cooldown or 0)) >= 1 then
        Parried = false
    end
end)

--// Auto Parry Spam (op 1v1)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and SpamEnabled and Enabled and input.KeyCode == Enum.KeyCode.E then
        for i = 1, 5 do
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            task.wait(0.012)
        end
    end
end)
