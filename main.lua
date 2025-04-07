local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Parried = false
local Connection, Cooldown = nil, 0
local AutoMode = "Legit" -- Legit ou Hack
local AntiCurves = false
local Optimized = false

local function GetBall()
    for _, Ball in ipairs(workspace.Balls:GetChildren()) do
        if Ball:GetAttribute("realBall") then
            return Ball
        end
    end
end

local function ResetConnection()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
end

local function OptimizeGame()
    if Optimized then return end
    Optimized = true
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
            v.Transparency = 1
            v.Material = Enum.Material.SmoothPlastic
            v:ClearAllChildren()
        end
    end
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end

workspace.Balls.ChildAdded:Connect(function()
    local Ball = GetBall()
    if not Ball then return end
    ResetConnection()
    Connection = Ball:GetAttributeChangedSignal("target"):Connect(function()
        Parried = false
    end)
end)

RunService.PreSimulation:Connect(function()
    local Ball = GetBall()
    local HRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not Ball or not HRP then return end

    if Ball:GetAttribute("target") ~= Player.Name or Parried then return end

    local Speed = Ball:FindFirstChild("zoomies") and Ball.zoomies.VectorVelocity.Magnitude or 100
    local Distance = (HRP.Position - Ball.Position).Magnitude
    local ReactionTime = AutoMode == "Hack" and 0.2 or 0.55

    if Distance / Speed <= ReactionTime then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        Parried = true
        Cooldown = tick()
    end
end)

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TwoDevOpUI"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 350)
Main.Position = UDim2.new(0.02, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.new(1, 0, 0)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Thickness = 2

local RGBTween = TweenService:Create(Main, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
    BackgroundColor3 = Color3.fromRGB(0, 255, 255)
})
RGBTween:Play()

local Title = Instance.new("TextLabel", Main)
Title.Text = "2dev Op - Blade Ball"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

local function CreateButton(text, yPos, callback)
    local Button = Instance.new("TextButton", Main)
    Button.Size = UDim2.new(0.9, 0, 0, 30)
    Button.Position = UDim2.new(0.05, 0, 0, yPos)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.Gotham
    Button.Text = text
    Button.TextSize = 14
    Button.MouseButton1Click:Connect(callback)
end

CreateButton("Auto Parry - Hack", 60, function()
    AutoMode = "Hack"
end)

CreateButton("Auto Parry - Legit", 100, function()
    AutoMode = "Legit"
end)

CreateButton("Ativar Anti-Curves", 140, function()
    AntiCurves = not AntiCurves
end)

CreateButton("Otimizar Jogo", 180, function()
    OptimizeGame()
end)

local Footer = Instance.new("TextLabel", Main)
Footer.Text = "Versão 1.0 | Atualizado: 07/04/2025"
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -20)
Footer.BackgroundTransparency = 1
Footer.TextColor3 = Color3.new(1, 1, 1)
Footer.Font = Enum.Font.GothamSemibold
Footer.TextSize = 12

local Minimized = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.CapsLock then
        Minimized = not Minimized
        Main.Visible = not Minimized
    end
end)
