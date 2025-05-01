local UI = {}
local toggled = {
    SuperSpeed = false;
    SuperJump = false;
    AutoBlow = false;
    AutoSell = false;
    AutoTeleport = false;
    AutoFarm = false;
}

local ISLANDS = {
    "Floating Island";
    "Outer Space";
    "The Void";
    "Twilight";
    "Zen"
}

local cache = {}

local player = game.Players.LocalPlayer

local networkEvent = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event")
local pickUpEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Pickups"):WaitForChild("CollectPickup")
local spawnPickups = game:GetService("ReplicatedStorage").Remotes.Pickups.SpawnPickups

local CoinsFolder = workspace.Rendered:GetChildren()[12]

local islands = workspace.Worlds["The Overworld"].Islands

local voidPickups = islands["The Void"].Island.Pickups
local zenPickups = islands.Zen.Island.Pickups

local bubblesBlown = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.HUD.Left.Currency.Bubble.Frame.Label

local generalPickups = {}

do
    for _, part in voidPickups:GetDescendants() do
        if not part:IsA("Part") then continue end
        table.insert(generalPickups, part)
    end

    for _, part in zenPickups:GetDescendants() do
        if not part:IsA("Part") then continue end
        table.insert(generalPickups, part)
    end
end

local function lerpToPos(obj: Part, endCFrame: CFrame)
    for x = 0, 1, 0.05 do
        obj.CFrame = obj.CFrame:Lerp(endCFrame, x)
        task.wait(.01)
    end
end

local function unformatString(s: string)
	str = string.gsub(s,"<br%s*/>", "\n")
	return (string.gsub(str, "<[^<>]->", ""))
end

local function CreateItem(Id: string, buttonFrame: Frame, text: string, customClick: (current: boolean) -> nil | nil)
    local x, y = buttonFrame.Size.X, buttonFrame.Size.Y
    
    local label = Instance.new("TextLabel")
    label.Parent = buttonFrame
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 25
    label.TextColor3 = Color3.fromRGB(245,245,245)
    label.Size = UDim2.new(.7, 0, 1, 0)

    local button = Instance.new("TextButton")
    button.Parent = buttonFrame
    button.Position = UDim2.new(0.8, 0, 0.12, 0)
    button.Size = UDim2.new(0, 55, 0, 55)
    button.BackgroundColor3 = Color3.fromRGB(255,0,0)
    button.Text = ""

    local corner = Instance.new("UICorner")
    corner.Parent = button
    corner.CornerRadius = UDim.new(0, 5)

    UI[Id] = button

    button.MouseButton1Click:Connect(function()
        local current = not toggled[Id]
        toggled[Id] = current

        if current == true then
            button.BackgroundColor3 = Color3.fromRGB(5,5,243)
        else
            button.BackgroundColor3 = Color3.fromRGB(255,3,3)
        end

        if customClick then
            customClick(current)
        end

    end)

    return label, button
end

local function getBubblesBlown()
    local unformatted = unformatString(bubblesBlown.Text)
    local decrypt = string.split(unformatted, " / ")
    return decrypt[1], decrypt[2]
end

local function BlowBubble()
    local args = {
        [1] = "BlowBubble"
    }
    networkEvent:FireServer(unpack(args))
end

local function collectCoin(id: string)
    local args = {
        [1] = id
    }
    pickUpEvent:FireServer(unpack(args))
end

local function hatchEgg(egg: string)
    local args = {
        [1] = "HatchEgg",
        [2] = egg, --ex "Common Egg",
        [3] = 1
    }
    
    networkEvent:FireServer(unpack(args))
end

local function getIsland(island: string)
    return islands[island].Island
end

local function teleportToIsland(island: string)
    local args = {
        [1] = "Teleport",
        [2] = "Workspace.Worlds.The Overworld.Islands.".. island ..".Island.Portal.Spawn"
    }

    networkEvent:FireServer(unpack(args))
end

local function sellBubbles()
    local args = {
        [1] = "SellBubble"
    }
    teleportToIsland("Twilight")
    lerpToPos(player.Character.HumanoidRootPart, islands.Twilight.Island.Sell.Root.CFrame)
    networkEvent:FireServer(unpack(args))
end

local function collectCoins()
    for _, coin in CoinsFolder:GetChildren() do
        if not toggled.AutoFarm then continue end
        --local pos = coin.WorldPivot
        collectCoin(coin.Name)
        cache[coin.Name] = coin
    end
end

function createMenuItem(Id: string, list: Frame, labelText: string, customClick: (toggled: boolean) -> nil | nil)
    local menuFrame: Frame = Instance.new("Frame")
    menuFrame.Parent = list
    menuFrame.Size = UDim2.new(1,0,0,75)
    menuFrame.BackgroundTransparency = 1
    UI[Id .. "Frame"] = AutoFarm

    local optionButton, optionLabel = CreateItem(Id, menuFrame, labelText, customClick)

end

local function createBarItem(itemName: string, text: string, Clicked: () -> nil)
    local bar = UI.bar
    
    local item: TextButton = Instance.new("TextButton")
    item.Parent = bar
    item.Size = UDim2.new(0,10,0,10)
    item.Position = UDim2.new(0,bar.Size.X.Offset - 25,0,20)
    item.Text = text
    item.TextSize = 25
    item.BackgroundTransparency = 1
    item.TextColor3 = Color3.fromRGB(255,255,255)
    item.MouseButton1Click:Connect(Clicked)

    UI[itemName] = item
end

-- UI creation
do
    local Screen: ScreenGui = Instance.new("ScreenGui")
    Screen.Parent = player.PlayerGui
    
    local bar: Frame = Instance.new("Frame")
    bar.Parent = Screen
    bar.Size = UDim2.new(0,500,0,50)
    bar.BackgroundColor3 = Color3.fromRGB(10,10,10)
    UI.bar = bar 

    local mainFrame: Frame = Instance.new("Frame")
    mainFrame.Parent = bar
    mainFrame.Position = UDim2.new(0,0,.98,0)
    mainFrame.Size = UDim2.new(0, 500, 0, 350)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)

    local list: Frame = Instance.new("ScrollingFrame")
    list.BackgroundTransparency = 1
    list.Parent = mainFrame
    list.CanvasSize = UDim2.new(0,0,2,0)
    list.ScrollingEnabled = true
    list.Position = UDim2.new(0,10,0,0)      
    list.Size = UDim2.new(1,0,1,0)
    list.BackgroundColor3 = Color3.fromRGB(10,10,10)
    list.ClipsDescendants = true
    list.ScrollBarThickness = 0
    UI.list = list

    createBarItem("Exit", "x", function()
            Screen:Destroy()
    end)

    createMenuItem("SuperSpeed", list, "Super Speed", function(toggled: boolean)
        if not toggled then player.Character.Humanoid.WalkSpeed = 20 return end
        player.Character.Humanoid.WalkSpeed = 40
    end)

    createMenuItem("SuperJump", list, "Super Jump", function(toggled: Boolean)
        if not toggled then player.Character.Humanoid.JumpPower = 70.3 return end
        player.Character.Humanoid.JumpPower = 1000
    end)

    createMenuItem("AutoBlow", list, "Auto Blow")
    createMenuItem("AutoFarm", list, "Auto Farm")
    createMenuItem("AutoSell", list, "Auto Sell")
    createMenuItem("AutoTeleport", list, "Auto Teleport")

    UI.main = mainFrame
end
-- components (functions, corners, etc)
do
    local CornerUI1 = Instance.new("UICorner")
    CornerUI1.CornerRadius = UDim.new(0, 4)
    CornerUI1.Parent = UI.main

    local dragger = Instance.new("UIDragDetector")
    dragger.Parent = UI.bar

    local list = Instance.new("UIListLayout")
    list.Parent = UI.list
end

local running = true

UI.main.Destroying:Connect(function()
    running = false
end)

for i = 1, 50 do
    spawnPickups:FireServer("Coins", 1)
end

task.spawn(function()
    while true do
        task.wait(1)
        if not running then break end
        for _, island in ISLANDS do
            if not toggled.AutoTeleport then continue end
            teleportToIsland(island)
            task.wait(1)
        end

        for name, coin in cache do
            local pos = coin.WorldPivot
            collectCoins()
            collectCoin(name)
            lerpToPos(player.Character.HumanoidRootPart, pos)
            cache[name] = nil
        end

    end
    return
end)

while true do    
    if not running then break end

    collectCoins()

    if toggled.AutoBlow then
        BlowBubble()
    end

    if toggled.AutoSell then
        local min, max = getBubblesBlown()
        if min >= max then
            sellBubbles()
        end
    end

    task.wait(.1)
end
