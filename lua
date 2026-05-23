--====================================================
-- 🧠 ULTRA ANIMAL SPAWNER FINAL v3 (FIXED)
-- + DELETE STACK FIX
-- + SEARCH BAR
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
-- STACK SYSTEM (DELETE FIX)
--====================================================

local spawnStack = {}

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
title.Size = UDim2.new(1,-200,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "🧠 ULTRA ANIMAL SPAWNER v3 FIXED"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

--====================================================
-- SEARCH BAR (NEW)
--====================================================

local searchBox = Instance.new("TextBox")
searchBox.Parent = main
searchBox.Size = UDim2.new(1,-10,0,30)
searchBox.Position = UDim2.new(0,5,0,45)
searchBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
searchBox.TextColor3 = Color3.new(1,1,1)
searchBox.PlaceholderText = "🔍 Buscar animal..."
searchBox.Text = ""
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
Instance.new("UICorner", searchBox)

--====================================================
-- INFO
--====================================================

local info = Instance.new("TextLabel")
info.Parent = main
info.Size = UDim2.new(1,-10,0,40)
info.Position = UDim2.new(0,5,0,80)
info.BackgroundTransparency = 1
info.Font = Enum.Font.Code
info.TextSize = 13
info.TextColor3 = Color3.new(1,1,1)
info.TextXAlignment = Enum.TextXAlignment.Left
info.Text = "🔍 Cargando..."

--====================================================
-- SCROLL
--====================================================

local scroll = Instance.new("ScrollingFrame")
scroll.Parent = main
scroll.Size = UDim2.new(1,-10,1,-130)
scroll.Position = UDim2.new(0,5,0,125)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
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
-- DELETE SYSTEM (FIXED STACK)
--====================================================

local deleteBtn = Instance.new("TextButton")
deleteBtn.Parent = top
deleteBtn.Size = UDim2.new(0,80,0,28)
deleteBtn.Position = UDim2.new(1,-130,0,6)
deleteBtn.Text = "DELETE"
deleteBtn.Font = Enum.Font.GothamBold
deleteBtn.TextSize = 12
deleteBtn.BackgroundColor3 = Color3.fromRGB(180,60,60)
deleteBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", deleteBtn)

deleteBtn.MouseButton1Click:Connect(function()
    local last = spawnStack[#spawnStack]

    if last and last.Parent then
        last:Destroy()
        table.remove(spawnStack, #spawnStack)
        info.Text = "🗑️ Último animal eliminado"
    else
        info.Text = "⚠️ No hay animales para borrar"
    end
end)

--====================================================
-- ANIMATIONS (NO TOCADO)
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
-- PLOT SYSTEM (SIN CAMBIOS)
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

        if first and first:FindFirstChild("Base") and first.Base:FindFirstChild("Spawn") then

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
-- SPAWN SYSTEM
--====================================================

local function spawnAnimal(name)

    local plot = getPlayerPlot()
    if not plot then return end

    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return end

    local spawnPoint

    for _,p in pairs(podiums:GetChildren()) do
        local s = p:FindFirstChild("Base") and p.Base:FindFirstChild("Spawn")
        if s then
            spawnPoint = s
            break
        end
    end

    if not spawnPoint then return end

    local model = animalsFolder:FindFirstChild(name)
    if not model then return end

    local clone = model:Clone()
    clone.Parent = workspace

    table.insert(spawnStack, clone)

    task.wait()

    local root = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    clone.PrimaryPart = root
    clone:PivotTo(spawnPoint.CFrame * CFrame.new(0, -1.2, 0))

    for _,v in pairs(clone:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = true
            v.CanCollide = false
        end
    end

    task.wait(0.5)

    playAnimation(clone,name)

    info.Text = "✅ Spawned: "..name
end

--====================================================
-- LIST + SEARCH
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

    local search = string.lower(searchBox.Text or "")
    local animals = animalsFolder:GetChildren()

    table.sort(animals,function(a,b)
        return a.Name < b.Name
    end)

    local count = 0

    for _,animal in pairs(animals) do

        if search == "" or string.find(string.lower(animal.Name), search) then

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

            count += 1
        end
    end

    info.Text = "🔎 Resultados: "..count
end

searchBox:GetPropertyChangedSignal("Text"):Connect(rebuildList)

--====================================================
-- INIT
--====================================================

task.wait(1)
rebuildList()

animalsFolder.ChildAdded:Connect(function()
    task.wait(0.2)
    rebuildList()
end)

animalsFolder.ChildRemoved:Connect(function()
    task.wait(0.2)
    rebuildList()
end)

print("🔥 FIXED ULTRA ANIMAL SPAWNER READY")
