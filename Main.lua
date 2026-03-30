local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Plr = game.Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char.HumanoidRootPart

Plr.CharacterAdded:Connect(function(c)
    Char = c
    Root = c.HumanoidRootPart
end)

local f = workspace.Enemies
local orbFolder = workspace.BattleStuff

local autoCollectOrb = false
local espEnabled = false
local minXP = 0
local minLuck = 0

-- Suffix-Daten
local suffixesData = {
    {1e24,"ST"},
    {1e21,"SX"},
    {1e18,"QN"},
    {1e15,"QA"},
    {1e12,"T"},
    {1e9,"B"},
    {1e6,"M"},
    {1e3,"K"},
}

-- Format Funktionen
local function suffix(n)
    for _,pair in ipairs(suffixesData) do
        local limit,suf = pair[1],pair[2]

        if n >= limit then
            local scaled = n/limit
            local floored = math.floor(scaled*10)/10
            return tostring(floored)..suf
        end
    end

    return tostring(n)
end

local function round2(n)
    if not n then return 0 end
    return math.floor(n*100+0.5)/100
end

local function format(n)
    return suffix(round2(n))
end

-- Luck aus Enchants lesen
local function getLuck(t)

    local enchants = t:FindFirstChild("Enchants")
    if not enchants then return 0 end

    local data = tostring(enchants.Value)

    for enchant, value in string.gmatch(data, "(%w+)=(%d+)") do
        if enchant == "Lucky" then
            return tonumber(value)
        end
    end

    return 0
end

-- Notify
Rayfield:Notify({
    Title = "Yay!!",
    Content = "Loading Script...",
    Duration = 4
})

-- Window
local Window = Rayfield:CreateWindow({

    Name = "Omega Hub",
    LoadingTitle = "Please wait",
    LoadingSubtitle = "By nicklewkow maybe",
    ShowText = "Omega Hub",

    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Exploits",
        FileName = "SACSimOmega"
    },

    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },

    KeySystem = false
})

-- Tab
local ESPTab = Window:CreateTab("ESP",4483362458)
local AutoTab = Window:CreateTab("Auto", 4483362458)
local OPTab = Window:CreateTab("OP", 4483362458)

ESPTab:CreateSection("NPC ESP")
AutoTab:CreateSection("ORBS 🟠")

-- Speicher
local shown = {}

local function DisableESP(t)

    local v = shown[t]
    if not v then return end

    for _,obj in pairs(v) do
        if obj then obj:Destroy() end
    end

    shown[t] = nil
end

local function DisableESPAll()

    for i,v in pairs(shown) do
        DisableESP(i)
    end
end

local function ESPTarget(t)

    if not espEnabled then return end

    local xpObj = t:FindFirstChild("TotalXP")
    local hrp = t:FindFirstChild("HumanoidRootPart")

    if not xpObj or not hrp then return end

    local xp = xpObj.Value
    local luck = getLuck(t)

    -- Filter
    if xp < minXP then DisableESP(t) return end
    if luck < minLuck then DisableESP(t) return end
    if shown[t] then return end

    local hl = Instance.new("Highlight")
    hl.Parent = t

    local ua = Instance.new("Attachment")
    ua.Parent = hrp

    local bu = Instance.new("BillboardGui")
    bu.Parent = ua

    local rd = Instance.new("TextLabel")
    rd.Parent = bu

    local st = Instance.new("UIStroke")
    st.Parent = rd
    st.Thickness = 2

    ua.Position = Vector3.new(0,2,0)

    bu.Size = UDim2.new(15,0,2,0)
    bu.AlwaysOnTop = true

    rd.BackgroundTransparency = 1
    rd.Size = UDim2.new(1,0,1,0)
    rd.TextSize = 16
    rd.Text = "EXP: "..format(xp).." | Luck: "..luck
    rd.TextColor3 = Color3.new(1,1,1)

    shown[t] = {hl,ua}
end

local function ESPNPC()

    for _,v in pairs(f:GetChildren()) do
        ESPTarget(v)
    end
end

-- Toggle
ESPTab:CreateToggle({

    Name = "Enable Esp",
    CurrentValue = false,
    Flag = "Yes",

    Callback = function(value)

        Rayfield:Notify({
            Title = "Message",
            Content = value and "Marking all enemies" or "Disabling ESP",
            Duration = 4
        })

        espEnabled = value

        if value then
            ESPNPC()
        else
            DisableESPAll()
        end
    end
})

-- Slider XP
ESPTab:CreateSlider({

    Name = "Minimum XP",
    Range = {0,100000},
    Increment = 1000,
    CurrentValue = 0,
    Suffix = "XP",

    Callback = function(value)

        minXP = value
        ESPNPC()

    end
})

-- Slider Luck
ESPTab:CreateSlider({

    Name = "Minimum Luck",
    Range = {0,10},
    Increment = 1,
    CurrentValue = 0,
    Suffix = "Luck",

    Callback = function(value)

        minLuck = value
        ESPNPC()

    end
})

ESPTab:CreateSection("ORBS (WIP) ⚠️")

ESPTab:CreateToggle({
    Name = "Orb ESP",
    CurrentValue = false,
    Flag = "What?",

    Callback = function(value)

    end
})

ESPTab:CreateSlider({
    Name = "Minimum RNG",
    Range = {0, 10000},
    Increment = 100,
    CurrentValue = 0,
    Suffix = "RNG",

    Callback = function(value)
    end
})

local function CollectOrb(o)
    if not Plr.Character then return end
    if not autoCollectOrb then return end

    local part = o:IsA("BasePart")
    if not part then return end

    firetouchinterest(Root, o, 0)
    task.wait()
    firetouchinterest(Root, o, 1)
end

local function CollectAllOrbs()
    for i, o in pairs(orbFolder:GetChildren()) do
        CollectOrb(o)
    end
end

AutoTab:CreateToggle({
    Name = "Collect Orbs",
    CurrentValue = false,
    Flag = "Boi",

    Callback = function(value)
        autoCollectOrb = value
        if value then CollectAllOrbs() end
    end
})

f.ChildAdded:Connect(function(c)
    task.spawn(ESPTarget, c)
end)

orbFolder.ChildAdded:Connect(function(c)
    CollectOrb(c)
end)

while task.wait(0.1) do
    if not autoCollectOrb then return end
    CollectAllOrbs()
end