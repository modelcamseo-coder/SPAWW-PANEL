--====================================================
-- 🧠 ULTRA ANIMAL SPAWNER FINAL v3 (PRO SYSTEM)
-- FULL INTELLIGENT + FIXED LIST + PLOTS + ANIMS
-- + DELETE LAST SPAWNED
--====================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--====================================================
-- CLEAN OLD GUI
--====================================================

pcall(function()
    local old = playerGui:FindFirstChild("UltraAnimalSpawner")
    if old then old:Destroy() end
end)

--====================================================
-- FOLDERS
--====================================================

local animalsFolder =
    ReplicatedStorage:WaitForChild("Models"):WaitForChild("Animals")

local animationsFolder =
    ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Animals")

local plotsFolder =
    workspace:WaitForChild("Plots")

--====================================================
-- TRACK SPAWNED ANIMALS (STACK)
--====================================================

local spawnedAnimals = {}

--====================================================
-- GUI
--====================================================

local gui = Instance.new("ScreenGui")
gui.Name = "UltraAnimalSpawner"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0,380,0,560)
main.Position = UDim2.new(0.05,0,0.1,0)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

--====================================================
-- TOP BAR
--====================================================

local top = Instance.new("Frame")
top.Parent = main
top.Size = UDim2.new(1,0,0,40)
top.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", top)

local title = Instance.new("TextLabel")
title.Parent = top
title.Size = UDim2.new(1,-120,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "🧠 ULTRA ANIMAL SPAWNER v3"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

-- MINIMIZE
local minimize = Instance.new("TextButton")
minimize.Parent = top
minimize.Size = UDim2.new(0,40,0,28)
minimize.Position = UDim2.new(1,-45,0,6)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 20
minimize.BackgroundColor3 = Color3.fromRGB(70,70,70)
minimize.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", minimize)

--====================================================
-- DELETE BUTTON (NEW)
--====================================================

local deleteBtn = Instance.new("TextButton")
deleteBtn.Parent = top
deleteBtn.Size = UDim2.new(0,60,0,28)
deleteBtn.Position = UDim2.new(1,-110,0,6)
deleteBtn.Text = "DEL"
deleteBtn.Font = Enum.Font.GothamBold
deleteBtn.TextSize = 14
deleteBtn.BackgroundColor3 = Color3.fromRGB(150,60,60)
deleteBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", deleteBtn)

deleteBtn.MouseButton1Click:Connect(function()

    local last = spawnedAnimals[#spawnedAnimals]

    if last and last.Parent then
        last:Destroy()
        table.remove(spawnedAnimals, #spawnedAnimals)
        info.Text = "🗑️ Deleted last spawned animal"
    else
        info.Text = "⚠️ No animals to delete"
    end
end)

--====================================================
-- INFO
--====================================================

local info = Instance.new("TextLabel")
info.Parent = main
info.Size = UDim2.new(1,-10,0,50)
info.Position = UDim2.new(0,5,0,45)
info.BackgroundTransparency = 1
info.Font = Enum.Font.Code
info.TextSize = 13
info.TextColor3 = Color3.new(1,1,1)
info.TextXAlignment = Enum.TextXAlignment.Left
info.Text = "🔍 Cargando animales..."

--====================================================
-- SCROLL
--====================================================

local scroll = Instance.new("ScrollingFrame")
scroll.Parent = main
scroll.Size = UDim2.new(1,-10,1,-105)
scroll.Position = UDim2.new(0,5,0,105)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ClipsDescendants = true

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.Padding = UDim.new(0,5)

--====================================================
-- PLOT / SPAWN LOGIC (UNCHANGED CORE)
--====================================================

local function getPlayerPlot()
    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local nearest, dist = nil, math.huge

    for _,plot in pairs(plotsFolder:GetChildren()) do
        local podiums = plot:FindFirstChild("AnimalPodiums")
        local first = podiums and podiums:FindFirstChild("1")

        if first and first:FindFirstChild("Base")
        and first.Base:FindFirstChild("Spawn") then

            local d = (hrp.Position - first.Base.Spawn.Position).Magnitude

            if d < dist then
                dist = d
                nearest = plot
            end
        end
    end

    return nearest
end

local function getEmptyPodium(plot)
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return end

    local list = podiums:GetChildren()

    table.sort(list,function(a,b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)

    for _,p in pairs(list) do
        local spawn = p:FindFirstChild("Base") and p.Base:FindFirstChild("Spawn")
        if spawn then
            return p
        end
    end
end

--====================================================
-- ANIMATION
--====================================================

local function playAnimation(model,name)

    local folder = animationsFolder:FindFirstChild(name)
    if not folder then return end

    local anim = folder:FindFirstChild("Idle") or folder:FindFirstChildWhichIsA("Animation")
    if not anim then return end

    local controller = model:FindFirstChildWhichIsA("AnimationController",true)
    if not controller then
        controller = Instance.new("AnimationController")
        controller.Parent = model
    end

    local animator = controller:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = controller
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = anim.AnimationId

    local track = animator:LoadAnimation(animation)
    track.Looped = true
    track:Play()
end

--====================================================
-- SPAWN SYSTEM (UPDATED STACK TRACKING)
--====================================================

local function spawnAnimal(name)

    local plot = getPlayerPlot()
    if not plot then return end

    local podium = getEmptyPodium(plot)
    if not podium then return end

    local spawn = podium.Base:FindFirstChild("Spawn")
    if not spawn then return end

    local model = animalsFolder:FindFirstChild(name)
    if not model then return end

    local clone = model:Clone()
    clone.Parent = workspace

    task.wait()

    local root = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    clone.PrimaryPart = root
    clone:PivotTo(spawn.CFrame * CFrame.new(0, -1.2, 0))

    for _,v in pairs(clone:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = true
            v.CanCollide = false
        end
    end

    table.insert(spawnedAnimals, clone)

    task.wait(0.5)
    playAnimation(clone,name)

    info.Text = "✅ Spawned: "..name
end

--====================================================
-- LIST
--====================================================

local function rebuildList()
    for _,v in pairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _,animal in pairs(animalsFolder:GetChildren()) do

        local btn = Instance.new("TextButton")
        btn.Parent = scroll
        btn.Size = UDim2.new(1,-5,0,40)
        btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Text = "🐾 "..animal.Name

        Instance.new("UICorner", btn)

        btn.MouseButton1Click:Connect(function()
            spawnAnimal(animal.Name)
        end)
    end
end

--====================================================
-- INIT
--====================================================

task.wait(1)
rebuildList()

print("🔥 ULTRA ANIMAL SPAWNER v3 + DELETE LOADED")
