local UI = {}
local toggled = {
    SuperSpeed = false;
    SuperJump = false;
    AutoBlow = false;
    AutoHatch = false;
    AutoSell = false;
    AutoTeleport = false;
    AutoFarm = false;
}

local VERSION = "v1.0.0"

local hatching = "Common Egg"

local ISLANDS = {
    "Floating Island";
    "Outer Space";
    "The Void";
    "Twilight";
    "Zen"
}

local eggs = {
    ["Common Egg"] = {
        Id = "Common Egg";
        Position = Vector3.new(-7.629898548126221, 9.598024368286133, -81.24771881103516)
    };

    ["Spotted Egg"] = {
        Id = "Spotted Egg";
        Position = Vector3.new(-7.231836318969727, 9.598024368286133, -70.34373474121094)
    };

    ["Iceshard Egg"] = {
        Id = "Iceshard Egg";
        Position = Vector3.new(-7.427544116973877, 9.598024368286133, -60.65147399902344)
    };

    ["Spikey Egg"] = {
        Id = "Spikey Egg";
        Position = Vector3.new(-125.24658203125, 10.114696502685547, 5.430325984954834)
    };

    ["Magma Egg"] = {
        Id = "Magma Egg";
        Position = Vector3.new(-132.60409545898438, 10.114592552185059, -0.514018177986145)
    };

    ["Crystal Egg"] = {
        Id = "Crystal Egg";
        Position = Vector3.new(-140.09437561035156, 10.114696502685547, -6.903750896453857)
    };

    ["Lunar Egg"] = {
        Id = "Lunar Egg";
        Position = Vector3.new(-145.25392150878906, 10.17003345489502, -15.187322616577148)
    };

    ["Void Egg"] = {
        Id = "Void Egg";
        Position = Vector3.new(-144.72616577148438, 10.114665031433105, -26.24932098388672)
    };

    ["Hell Egg"] = {
        Id = "Hell Egg";
        Position = Vector3.new(-144.60983276367188, 10.114696502685547, -35.832881927490234)
    };

    ["Nightmare Egg"] = {
        Id = "Nightmare Egg";
        Position = Vector3.new(-141.10316467285156, 10.114696502685547, -45.03639602661133)
    };

    ["Rainbow Egg"] = {
        Id = "Rainbow Egg";
        Position = Vector3.new(-136.88348388671875, 10.114521026611328, -51.80839538574219)
    }
}

local arrayEggs = {}

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

    for name, _ in eggs do
        table.insert(arrayEggs, name)
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
    hatching = egg
    local pos = CFrame.new(eggs[egg].Position)
    lerpToPos(player.Character.HumanoidRootPart, pos)
    
    local args = {
        [1] = "HatchEgg",
        [2] = "Common Egg", --ex "Common Egg",
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

-- UI creation
local function makedropdown(Id: string, txt: string, Default: string, append: Frame, Options: {string}, OptionPicked: (option: string) -> nil)
	local dropdown = Instance.new("Frame")
	local title = Instance.new("TextLabel")
	local button = Instance.new("TextButton")
	local UICorner_3 = Instance.new("UICorner")
	local dropdownMenu = Instance.new("ScrollingFrame")
	local UICorner_4 = Instance.new("UICorner")
	local UIListLayout = Instance.new("UIListLayout")
	local UIStroke = Instance.new("UIStroke")

	dropdown.Name = Id
	dropdown.Parent = append
	dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	dropdown.BackgroundTransparency = 1.000
	dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
	dropdown.BorderSizePixel = 0
	dropdown.Size = UDim2.new(1, 0, 0, 40)

	title.Parent = dropdown
	title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1.000
	title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	title.BorderSizePixel = 0
	title.Size = UDim2.new(0.629213512, 0, 0.925000012, 0)
	title.Font = Enum.Font.Montserrat
	title.Text = txt
	title.TextColor3 = Color3.fromRGB(249, 249, 249)
	title.TextSize = 20.000
	title.TextWrapped = true
	title.TextXAlignment = Enum.TextXAlignment.Left

	button.Parent = dropdown
	button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	button.BorderColor3 = Color3.fromRGB(0, 0, 0)
	button.BorderSizePixel = 0
	button.Position = UDim2.new(0.775280893, 0, 0.150000006, 0)
	button.Size = UDim2.new(0.191011235, 0, 0.625, 0)
	button.Font = Enum.Font.GothamMedium
	button.Text = Default
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 14.000

	UICorner_3.CornerRadius = UDim.new(0, 4)
	UICorner_3.Parent = button

	dropdownMenu.Name = "dropdown"
	dropdownMenu.Parent = dropdown
	dropdownMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	dropdownMenu.BorderColor3 = Color3.fromRGB(0, 0, 0)
	dropdownMenu.BorderSizePixel = 0
	dropdownMenu.Position = UDim2.new(0.775280893, 0, 0.625, 0)
	dropdownMenu.Selectable = false
	dropdownMenu.Size = UDim2.new(0.191011235, 0, 2.0250001, 0)
	dropdownMenu.Visible = false
	dropdownMenu.ScrollBarThickness = 1
    dropdownMenu.AutomaticCanvasSize = Enum.AutomaticSize.Y

	UICorner_4.CornerRadius = UDim.new(0, 4)
	UICorner_4.Parent = dropdownMenu

	UIListLayout.Parent = dropdownMenu
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	UIStroke.Transparency = 0.85
	UIStroke.Color = Color3.fromRGB(255,255,255)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Parent = button

	UIStroke:Clone().Parent = dropdownMenu

	for _, opt in Options do
		local template = Instance.new("Frame")
		local optionButton = Instance.new("TextButton")
		local border = Instance.new("Frame")

		template.Name = opt
		template.Parent = dropdownMenu
		template.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		template.BackgroundTransparency = 1.000
		template.BorderColor3 = Color3.fromRGB(0, 0, 0)
		template.BorderSizePixel = 0
		template.Size = UDim2.new(1, 0, 0, 20)

		optionButton.Parent = template
		optionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		optionButton.BackgroundTransparency = 1.000
		optionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		optionButton.BorderSizePixel = 0
		optionButton.Text = opt
		optionButton.Size = UDim2.new(1, 0, 1, 0)
		optionButton.Font = Enum.Font.Montserrat
		optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		optionButton.TextSize = 14.000

		border.Parent = template
		border.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		border.BackgroundTransparency = 0.850
		border.BorderColor3 = Color3.fromRGB(0, 0, 0)
		border.BorderSizePixel = 0
		border.Position = UDim2.new(0, 0, 1, 0)
		border.Size = UDim2.new(1, 0, 0, 1)

		optionButton.MouseButton1Click:Connect(function()
			button.Text = opt
			OptionPicked(opt)
			dropdownMenu.Visible = false
		end)
	end

	button.MouseButton1Click:Connect(function()
		dropdownMenu.Visible = not dropdownMenu.Visible
	end)

	return dropdown
end

local function makeFielded(Id: string, txt: string, append: Frame, edited: (txt: string | number) -> nil)
	local range = Instance.new("Frame")
	local title = Instance.new("TextLabel")
	local field = Instance.new("TextBox")
	local UICorner_2 = Instance.new("UICorner")
	local UIStroke = Instance.new("UIStroke")

	range.Name = Id
	range.Parent = append
	range.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	range.BackgroundTransparency = 1.000
	range.BorderColor3 = Color3.fromRGB(0, 0, 0)
	range.BorderSizePixel = 0
	range.Size = UDim2.new(1, 0, 0, 40)

	title.Parent = range
	title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1.000
	title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	title.BorderSizePixel = 0
	title.Size = UDim2.new(0.629213512, 0, 0.925000012, 0)
	title.Font = Enum.Font.Montserrat
	title.Text = txt
	title.TextColor3 = Color3.fromRGB(249, 249, 249)
	title.TextSize = 20.000
	title.TextWrapped = true
	title.TextXAlignment = Enum.TextXAlignment.Left

	field.Parent = range
	field.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	field.BorderColor3 = Color3.fromRGB(0, 0, 0)
	field.BorderSizePixel = 0
	field.Position = UDim2.new(0.775280893, 0, 0.150000006, 0)
	field.Size = UDim2.new(0.191011235, 0, 0.625, 0)
	field.Font = Enum.Font.GothamMedium
	field.Text = txt
	field.TextColor3 = Color3.fromRGB(255, 255, 255)
	field.TextSize = 14.000

	UICorner_2.CornerRadius = UDim.new(0, 4)
	UICorner_2.Parent = field

	UIStroke.Transparency = 0.85
	UIStroke.Color = Color3.fromRGB(255,255,255)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Parent = field

	field.FocusLost:Connect(function(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
		if field.Text == "" then return end
		edited(field.Text)
	end)

	return range
end

local function makeToggle(Id: string, txt: string, append: Frame, clicked: (toggle: boolean) -> nil)
	local toggleable = Instance.new("Frame")
	local TextLabel = Instance.new("TextLabel")
	local Button = Instance.new("TextButton")
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	local UICorner = Instance.new("UICorner")
	local UIStroke = Instance.new("UIStroke")

	toggleable.Name = Id
	toggleable.Parent = append
	toggleable.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	toggleable.BackgroundTransparency = 1.000
	toggleable.BorderColor3 = Color3.fromRGB(0, 0, 0)
	toggleable.BorderSizePixel = 0
	toggleable.Size = UDim2.new(1, 0, 0, 40)

	TextLabel.Parent = toggleable
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 1.000
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.BorderSizePixel = 1
	TextLabel.BorderMode = Enum.BorderMode.Inset
	TextLabel.Size = UDim2.new(0.629213512, 0, 0.925000012, 0)
	TextLabel.Font = Enum.Font.Montserrat
	TextLabel.Text = txt
	TextLabel.TextColor3 = Color3.fromRGB(249, 249, 249)
	TextLabel.TextSize = 20.000
	TextLabel.TextWrapped = true
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left

	Button.Parent = toggleable
	Button.BackgroundColor3 = Color3.fromRGB(255, 0, 89)
	Button.BorderColor3 = Color3.fromRGB(40, 40, 40)
    Button.BorderMode = Enum.BorderMode.Middle
	Button.BorderSizePixel = 2
	Button.Position = UDim2.new(0.887640476, 0, 0.0500000007, 0)
	Button.Size = UDim2.new(0.078651689, 0, 0.875, 0)
	Button.Text = ""

	UIAspectRatioConstraint.Parent = Button

	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = Button

	UIStroke.Transparency = 0.4
	UIStroke.Thickness = 1
	UIStroke.Color = Color3.fromRGB(255,255,255)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Parent = Button

    Button.MouseButton1Click:Connect(function()
        local current = not toggled[Id]
        toggled[Id] = current

        if current == true then
           Button.BackgroundColor3 = Color3.fromRGB(0, 255, 115)
        else
            Button.BackgroundColor3 = Color3.fromRGB(255, 0, 89)
        end

        if clicked then
            clicked(current)
        end
	end)

	return toggleable
end

-- Instances:
do
	local screen = Instance.new("ScreenGui")
	local TopBar = Instance.new("Frame")
	local Menu = Instance.new("Frame")
	local ScrollingFrame = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local title = Instance.new("TextLabel")
	local version = Instance.new("TextLabel")
	local border = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local close = Instance.new("ImageButton")
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	local dragger = Instance.new("UIDragDetector")
	--Properties:

	screen.Name = "screen"
	screen.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	TopBar.Name = "TopBar"
	TopBar.Parent = screen
	TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	TopBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TopBar.BorderSizePixel = 0
	TopBar.Position = UDim2.new(0.472921908, 0, 0.116699986, 0)
	TopBar.Size = UDim2.new(0.292821169, 0, 0, 45)

	Menu.Name = "Menu"
	Menu.Parent = TopBar
	Menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Menu.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Menu.BorderSizePixel = 0
	Menu.Position = UDim2.new(-0.000196362555, 0, 0.970542312, 0)
	Menu.Size = UDim2.new(0.99999994, 0, 5.06442165, 0)

	ScrollingFrame.Parent = Menu
	ScrollingFrame.Active = true
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollingFrame.BackgroundTransparency = 1.000
	ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.Position = UDim2.new(0.011, 0, 0.0444115512, 0)
	ScrollingFrame.Size = UDim2.new(0.989, 0, 0.95558846, 0)
    ScrollingFrame.CanvasSize = UDim2.new(1,0,2.5,0)
	ScrollingFrame.ScrollBarThickness = 5

	UIListLayout.Parent = ScrollingFrame
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	title.Name = "title"
	title.Parent = TopBar
	title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1.000
	title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	title.BorderSizePixel = 0
	title.Position = UDim2.new(0.0215053745, 0, 0.0840004086, 0)
	title.Size = UDim2.new(0.387096763, 0, 0.916000545, 0)
	title.Font = Enum.Font.GothamMedium
	title.Text = "Bubblegum simulator"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 14.000
	title.TextXAlignment = Enum.TextXAlignment.Left

	version.Name = "version"
	version.Parent = TopBar
	version.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	version.BackgroundTransparency = 1.000
	version.BorderColor3 = Color3.fromRGB(0, 0, 0)
	version.BorderSizePixel = 0
	version.Position = UDim2.new(0.911827922, 0, 0.615960538, 0)
	version.Size = UDim2.new(0.0860214978, 0, 0.333333343, 0)
	version.Font = Enum.Font.GothamMedium
	version.Text = VERSION
	version.TextColor3 = Color3.fromRGB(255, 255, 255)
	version.TextSize = 12.000

	border.Name = "border"
	border.Parent = TopBar
	border.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	border.BackgroundTransparency = 0.850
	border.BorderColor3 = Color3.fromRGB(0, 0, 0)
	border.BorderSizePixel = 0
	border.Position = UDim2.new(0, 0, 1, 0)
	border.Size = UDim2.new(1, 0, 0.0333333351, 0)

	UICorner.CornerRadius = UDim.new(0, 4)
	UICorner.Parent = TopBar
	
	dragger.Parent = TopBar
	
	close.Name = "close"
	close.Parent = TopBar
	close.BackgroundColor3 = Color3.fromRGB(15,15,15)
	close.BorderColor3 = Color3.fromRGB(0, 0, 0)
	close.BorderSizePixel = 0
	close.Position = UDim2.new(0.954999983, 0, 0.0839999989, 0)
	close.Size = UDim2.new(0, 18, 0, 21)
	close.Image = "rbxassetid://11293981586"
	
    close.MouseButton1Click:Connect(function() screen:Destroy() end)

    makeToggle("AutoBlow", "Auto Blow", ScrollingFrame)
    makeToggle("AutoFarm", "Auto Farm", ScrollingFrame)
    makeToggle("AutoHatch", "Auto Hatch", ScrollingFrame)
    makeToggle("AutoSell", "Auto Sell", ScrollingFrame)
    makeToggle("AutoTeleport", "Auto Teleport", ScrollingFrame)

    makeToggle("SuperSpeed", "Super Speed", ScrollingFrame, function(toggled: boolean)
        if not toggled then player.Character.Humanoid.WalkSpeed = 20 return end
        player.Character.Humanoid.WalkSpeed = 40
    end)

    makeToggle("SuperJump", "Super Jump", ScrollingFrame, function(toggled: Boolean)
        if not toggled then player.Character.Humanoid.JumpPower = 70.3 return end
        player.Character.Humanoid.JumpPower = 1000
    end)

	makeFielded("SetSpeed", "Set Speed", ScrollingFrame, function(speed: number)
        player.Character.Humanoid.WalkSpeed = speed
    end)

    makeFielded("SetJump", "Set Jump Power", ScrollingFrame, function(power: number )
        player.Character.Humanoid.JumpPower = power
    end)

	makedropdown("TeleportTo", "Teleport To", "Zen", ScrollingFrame, ISLANDS, function(option: string)
        teleportToIsland(option)
    end).ZIndex = 3

    makedropdown("HatchEgg", "Hatch Egg", "Common Egg", ScrollingFrame, arrayEggs, function(option: string)
        hatchEgg(option)
    end).ZIndex = 2

	UI.main = screen
	UIAspectRatioConstraint.Parent = close
end
-- components (functions, corners, etc)

local running = true

UI.main.Destroying:Connect(function()
    running = false
end)

for i = 1, 50 do
    collectCoin(i)
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

    if toggled.AutoHatch then
        hatchEgg(hatching)
    end

    if toggled.AutoSell then
        local min, max = getBubblesBlown()

        if min >= max then
            sellBubbles()
        end
    end

    task.wait(.1)
end
