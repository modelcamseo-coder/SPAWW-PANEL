--====================================================
-- 🧠 ULTRA ANIMAL SPAWNER FINAL v3 (PRO SYSTEM)
-- FULL INTELLIGENT + FIXED LIST + PLOTS + ANIMS
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
-- GUI
--====================================================

local gui = Instance.new("ScreenGui")
gui.Name = "UltraAnimalSpawner"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0,380,0,520)
main.Position = UDim2.new(0.05,0,0.1,0)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

--====================================================
-- TOP BAR (MINIMIZE)
--====================================================

local top = Instance.new("Frame")
top.Parent = main
top.Size = UDim2.new(1,0,0,40)
top.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", top)

local title = Instance.new("TextLabel")
title.Parent = top
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "🧠 ULTRA ANIMAL SPAWNER v3"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

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
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Active = true
scroll.ClipsDescendants = true

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.Padding = UDim.new(0,5)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

--====================================================
-- MINIMIZE SYSTEM
--====================================================

local minimized = false

minimize.MouseButton1Click:Connect(function()

    minimized = not minimized

    if minimized then
        scroll.Visible = false
        info.Visible = false
        main.Size = UDim2.new(0,380,0,40)
        minimize.Text = "+"
    else
        scroll.Visible = true
        info.Visible = true
        main.Size = UDim2.new(0,380,0,520)
        minimize.Text = "-"
    end
end)

--====================================================
-- PLOT DETECTOR
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

--====================================================
-- SLOT FINDER
--====================================================

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

            local taken = false

            for _,m in pairs(workspace:GetChildren()) do
                if m:IsA("Model") then
                    local part = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                    if part and (part.Position - spawn.Position).Magnitude < 4 then
                        taken = true
                        break
                    end
                end
            end

            if not taken then
                return p
            end
        end
    end
end

--====================================================
-- ANIMATIONS FIX
--====================================================

local function playAnimation(model,name)

    local folder = animationsFolder:FindFirstChild(name)
    if not folder then return end

    local anim =
        folder:FindFirstChild("Idle")
        or folder:FindFirstChild("Spawn")
        or folder:FindFirstChildWhichIsA("Animation")

    if not anim then return end

    local controller =
        model:FindFirstChildWhichIsA("AnimationController",true)

    if not controller then
        controller = Instance.new("AnimationController")
        controller.Parent = model
    end

    local animator =
        controller:FindFirstChildOfClass("Animator")

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
-- SPAWN SYSTEM
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

    task.wait(0.6)

    playAnimation(clone,name)

    info.Text = "✅ Spawned: "..name.." | Plot: "..plot.Name
end

--====================================================
-- ULTRA LIST (FIX REAL - SOLO FUENTE REAL)
--====================================================

local function clearList()
    for _,v in pairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end
end

local function rebuildList()

    clearList()

    -- 🔥 FUENTE REAL Y ÚNICA
    local animals = {}

    for _,obj in ipairs(animalsFolder:GetChildren()) do
        if obj:IsA("Model") then
            table.insert(animals, obj)
        end
    end

    table.sort(animals,function(a,b)
        return a.Name < b.Name
    end)

    for _,animal in ipairs(animals) do

        local btn = Instance.new("TextButton")
        btn.Parent = scroll
        btn.Size = UDim2.new(1,-5,0,40)
        btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Text = "🐾 "..animal.Name

        Instance.new("UICorner", btn)

        btn.MouseButton1Click:Connect(function()
            spawnAnimal(animal.Name)
        end)
    end

    info.Text = "✅ Animals cargados: "..#animals
end

--====================================================
-- INIT
--====================================================

task.wait(1)

rebuildList()

--====================================================
-- LIVE UPDATE
--====================================================

animalsFolder.ChildAdded:Connect(function()
    task.wait(0.2)
    rebuildList()
end)

animalsFolder.ChildRemoved:Connect(function()
    task.wait(0.2)
    rebuildList()
end)

--====================================================
-- INFO LOOP
--====================================================

task.spawn(function()
    while task.wait(2) do
        local plot = getPlayerPlot()
        if plot then
            info.Text = "📍 Plot: "..plot.Name
        end
    end
end)

print("🔥 ULTRA ANIMAL SPAWNER v3 LOADED PERFECT")
