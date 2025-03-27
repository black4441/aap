local Library = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))();
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))();
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))();

local Window = Library:CreateWindow({
    Title = "Anime Power V1.0.0",
    SubTitle = "by borges",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Darker",
    AccentColor = Color3.fromRGB(255, 165, 0),
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Welcome!", Icon = "home" }),
    Autofarm = Window:AddTab({ Title = "Auto Farm", Icon = "swords" }),
    AutoSpin = Window:AddTab({ Title = "Auto Spin", Icon = "refresh-cw" }),
    Boss = Window:AddTab({ Title = "Boss", Icon = "angry" }),
    Notification = Window:AddTab({ Title = "Notification", Icon = "bell" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "share" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local playerName = game.Players.LocalPlayer.DisplayName



Tabs.Main:AddParagraph({
    Title = "Welcome, " .. playerName .. "!", 
    Content = "This is the main hub for [ARISE] Anime Power."
})
-- auto farm --

local inimigosPorMundo = {
    ["Shinobi World"] = {
        "Risane",
        "Nagaco",
        "Itaki",
        "Tony",
        "Zaruka",
    },
    ["Bar Tavern"] = {
        "Knight",
        "Thunder Knight",
        "Fraudim",
        "Toxinia",
        "Estaroza",
    },
    -- ["Another World"] = { "Outro", "Inimigo", "Teste" }
}

local mundoSelecionado = "Shinobi World"
local inimigosSelecionados = {} -- começa vazio
local farmando = false
local autofarmLoop

-- Dropdown 1: selecionar o mundo
Tabs.Autofarm:AddDropdown("mundoDropdown", {
    Title = "World",
    Values = { "Shinobi World", "Bar Tavern" },
    Multi = false,
    Default = 1,
Callback = function(value)
    mundoSelecionado = value

local novaLista = inimigosPorMundo[mundoSelecionado]
local novoDropdown = Fluent.Options.inimigosMultiDropdown
novoDropdown:SetValues(novaLista)

-- Cria tabela no formato esperado pela Fluent
local valoresIniciais = {}
for _, nome in ipairs(novaLista) do
    valoresIniciais[nome] = false -- começa tudo desmarcado
end

novoDropdown:SetValue(valoresIniciais)
inimigosSelecionados = {}

end


})


Tabs.Autofarm:AddDropdown("inimigosMultiDropdown", {
    Title = "Enemies",
    Values = inimigosPorMundo[mundoSelecionado],
    Multi = true,
    Default = {}, -- Começa sem nada
    Callback = function(value)
        local selecionados = {}

        -- 'value' é uma tabela no formato: { Risane = true, Tony = true }
        for nome, ativo in pairs(value) do
            if ativo then
                table.insert(selecionados, nome)
            end
        end

        inimigosSelecionados = selecionados
        print("Selecionados:", table.concat(inimigosSelecionados, ", "))
    end
})





-- Função para encontrar o NPC mais próximo por nome visível
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function encontrarNPCPorNomeVisivel(nomeProcurado)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    local npcMaisProximo = nil
    local menorDistancia = math.huge

    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
            local humanoid = npc.Humanoid
            local rootPart = npc.HumanoidRootPart

            if humanoid.Health > 0 then
                for _, gui in ipairs(npc:GetDescendants()) do
                    if gui:IsA("TextLabel") and gui.Text == nomeProcurado then
                        local distancia = (hrp.Position - rootPart.Position).Magnitude
                        if distancia < menorDistancia and distancia < 100 then 
                            menorDistancia = distancia
                            npcMaisProximo = npc
                        end
                    end
                end
            end
        end
    end

    return npcMaisProximo
end

-- Toggle para ativar o Auto Farm nos inimigos selecionados
Tabs.Autofarm:AddToggle("autoFarmToggle", {
    Title = "Auto Farm",
    Default = false,
    Callback = function(state)
        farmando = state

        if state then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

            autofarmLoop = task.spawn(function()
                while farmando do
                    for _, nomeDoInimigo in ipairs(inimigosSelecionados or {}) do
                        local npc = encontrarNPCPorNomeVisivel(nomeDoInimigo)

                        if npc and npc:FindFirstChild("HumanoidRootPart") and hrp then
                            -- Teleporta pro inimigo
                            hrp.CFrame = npc.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)

                            -- Espera até o inimigo morrer antes de ir pro próximo
                            while farmando and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 do
                                task.wait(0.5)
                            end
                        end
                    end

                    task.wait(0.5)
                end
            end)
        else
            if autofarmLoop then
                task.cancel(autofarmLoop)
                autofarmLoop = nil
            end
        end
    end
})

-- BOSS
local bossPositions = {
    ["Shinobi World"] = Vector3.new(-2466.604248046875, 17.5874080657959, 920.8086547851562),
    ["Bar Tavern"] = Vector3.new(-1552.380127, 19.359671, -1251.440918),

    -- ["Another World"] = Vector3.new(x, y, z),
}

local mundoSelecionadoBoss = "Shinobi World"

-- Dropdown to select boss world
Tabs.Boss:AddDropdown("bossWorldDropdown", {
    Title = "Select Boss World",
    Values = { "Shinobi World","Bar Tavern" },
    Multi = false,
    Default = 1,
    Callback = function(value)
        mundoSelecionadoBoss = value
    end
})

-- Button to teleport to the boss
Tabs.Boss:AddButton({
    Title = "Teleport to Boss",
    Description = "Teleport to the selected boss location",
    Callback = function()
        local pos = bossPositions[mundoSelecionadoBoss]
        if pos then
            local player = game:GetService("Players").LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            hrp.CFrame = CFrame.new(pos)
            print("Teleported to boss of:", mundoSelecionadoBoss)
        else
            warn("Boss position not defined for:", mundoSelecionadoBoss)
        end
    end
})



local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local spinAtivo = false
local selectedWorld = "Shinobi World"
local posicaoOriginal = nil
local spinLoop

Tabs.AutoSpin:AddSection("Champion Spin")

Tabs.AutoSpin:AddDropdown("worldDropdown", {
    Title = "World",
    Values = { "Shinobi World", "Bar Tavern" },
    Multi = false,
    Default = 1,
    Callback = function(value)
        selectedWorld = value
    end
})

local spinPositions = {
    ["Shinobi World"] = Vector3.new(-1904.765625, 21.17751121520996, 1102.5560302734375),
    ["Bar Tavern"] = Vector3.new(-1980.800415, 19.110008, -924.159546),
    -- ["Another World"] = Vector3.new(...) -- Se quiser adicionar
}

local remoteWorldKeys = {
    ["Shinobi World"] = "two",
    ["Bar Tavern"] = "one",
}

local remoteWorldNames = {
    ["Shinobi World"] = "shinobi world",
    ["Bar Tavern"] = "boar tavern",
}

Tabs.AutoSpin:AddToggle("autoSpinToggle", {
    Title = "Auto Spin",
    Default = false,
    Callback = function(state)
        spinAtivo = state

        if state then
            posicaoOriginal = humanoidRootPart.CFrame

            spinLoop = task.spawn(function()
                local remoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("events"):WaitForChild("RemoteEvent")

                while spinAtivo and remoteEvent do
                    local spinPos = spinPositions[selectedWorld]
                    local key = remoteWorldKeys[selectedWorld] or "one"
                    local worldName = remoteWorldNames[selectedWorld] or string.lower(selectedWorld)

                    -- 1. TP até o spin
                    if spinPos then
                        humanoidRootPart.CFrame = CFrame.new(spinPos)
                        task.wait(0.5)
                    end

                    -- 2. Executa o giro
                    remoteEvent:FireServer("rollChampion", key, worldName)

                    -- 3. Espera o giro
                    task.wait(1.5)

                    -- 4. Volta pra posição original
                    if posicaoOriginal then
                        humanoidRootPart.CFrame = posicaoOriginal
                    end

                    -- 5. Espera 7s no lugar original (pra dar tempo de animação etc)
                    task.wait(7)
                end
            end)
        else
            if spinLoop then
                task.cancel(spinLoop)
                spinLoop = nil
            end
            if posicaoOriginal then
                humanoidRootPart.CFrame = posicaoOriginal
            end
        end
    end
})


-- ✅ Dungeon Notification System with Live/Local Fallback

local DungeonTimers = {
    ["Easy"]   = { Active = false, Seconds = nil, Text = "", LastUpdate = nil },
    ["Medium"] = { Active = false, Seconds = nil, Text = "", LastUpdate = nil },
    ["Hard"]   = { Active = false, Seconds = nil, Text = "", LastUpdate = nil },
}

local NotifyEasy = Tabs.Notification:AddToggle("NotifyEasy", { Title = "Notify Dungeon - Easy", Default = false })
local NotifyMedium = Tabs.Notification:AddToggle("NotifyDungeonMedium", { Title = "Notify Dungeon - Medium", Default = false })
local NotifyHard = Tabs.Notification:AddToggle("NotifyDungeonHard", { Title = "Notify Dungeon - Hard", Default = false })

NotifyEasy:OnChanged(function(state) DungeonTimers["Easy"].Active = state end)
NotifyMedium:OnChanged(function(state) DungeonTimers["Medium"].Active = state end)
NotifyHard:OnChanged(function(state) DungeonTimers["Hard"].Active = state end)

Tabs.Notification:AddButton({
    Title = "📦 Capture Dungeon Timer",
    Description = "Teleport to the dungeon and capture the timer values.",
    Callback = function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local currentWorld = workspace:FindFirstChild("currentWorld")
        if not currentWorld or currentWorld.Name ~= "Shinobi World" then
            Window:Dialog({
                Title = "World Required",
                Content = "You must be in Shinobi World to capture the timer.",
                Buttons = {
                    {
                        Title = "OK",
                        Callback = function()
                            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                            local hrp = char:WaitForChild("HumanoidRootPart")

                            local dungeonCFrame = CFrame.new(
                                -2025.82971, 28.2168045, 1021.86169,
                                0.00279312232, -0.747816086, -0.663900137,
                                0.999988735, -0.000459586503, 0.00472477218,
                                -0.00383837963, -0.663905859, 0.747806311
                            )

                            hrp.CFrame = dungeonCFrame
                            task.wait(3)
                            getLiveTimers()
                        end
                    }
                }
            })
            return
        end

        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        local dungeonCFrame = CFrame.new(
            -2025.82971, 28.2168045, 1021.86169,
            0.00279312232, -0.747816086, -0.663900137,
            0.999988735, -0.000459586503, 0.00472477218,
            -0.00383837963, -0.663905859, 0.747806311
        )

        hrp.CFrame = dungeonCFrame
        task.wait(3)
        getLiveTimers()
    end
})

-- 🧱 UI Setup
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("DungeonPopup") then CoreGui.DungeonPopup:Destroy() end

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "DungeonPopup"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 100)
frame.Position = UDim2.new(1, -240, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0, 0)
frame.ClipsDescendants = true
frame.Parent = screenGui
frame.Visible = false
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local function createLabel(y, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = color
    lbl.Text = ""
    lbl.Parent = frame
    return lbl
end

local title = createLabel(5, Color3.fromRGB(255, 255, 255))
title.Text = "⏰ Dungeon Countdown"
title.Font = Enum.Font.GothamBold
title.TextSize = 16

easyLabel   = createLabel(30, Color3.fromRGB(200, 255, 200))
mediumLabel = createLabel(50, Color3.fromRGB(255, 210, 150))
hardLabel   = createLabel(70, Color3.fromRGB(255, 150, 150))

-- 🧭 Referências vivas no workspace (se disponíveis)
function getLiveTimers()
    local success, result = pcall(function()
        local hitboxes = workspace:FindFirstChild("currentWorld")
            and workspace.currentWorld:FindFirstChild("dungeon")
            and workspace.currentWorld.dungeon:FindFirstChild("elements")
            and workspace.currentWorld.dungeon.elements:FindFirstChild("hitboxes")

        if not hitboxes then return end

        local function parseText(obj)
            if not obj or not obj:IsA("TextLabel") or obj.Text == "" then return nil end
            local min, sec = string.match(obj.Text, "(%d+):(%d+)")
            return tonumber(min or 0) * 60 + tonumber(sec or 0)
        end

        local now = os.time()

        local easy = hitboxes:FindFirstChild("easy")
        if easy then
            local timer = easy:FindFirstChild("billboard") and easy.billboard:FindFirstChild("timer")
            local seconds = parseText(timer)
            if seconds then
                DungeonTimers["Easy"].Seconds = math.max(0, seconds)
                DungeonTimers["Easy"].LastUpdate = now
            end
        end

        local medium = hitboxes:FindFirstChild("medium")
        if medium then
            local timer = medium:FindFirstChild("billboard") and medium.billboard:FindFirstChild("timer")
            local seconds = parseText(timer)
            if seconds then
                DungeonTimers["Medium"].Seconds = math.max(0, seconds)
                DungeonTimers["Medium"].LastUpdate = now
            end
        end

        local hard = hitboxes:FindFirstChild("hard")
        if hard then
            local timer = hard:FindFirstChild("billboard") and hard.billboard:FindFirstChild("timer")
            local seconds = parseText(timer)
            if seconds then
                DungeonTimers["Hard"].Seconds = math.max(0, seconds)
                DungeonTimers["Hard"].LastUpdate = now
            end
        end
    end)
end

-- ⏱️ Formatting
local function formatTime(seconds)
    return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

-- 🔁 Atualização contínua
getLiveTimers() -- inicial

task.spawn(function()
    while screenGui and screenGui.Parent do
        getLiveTimers()

        local show = false
        local now = os.time()

        for name, data in pairs(DungeonTimers) do
            local label = (name == "Easy" and easyLabel) or (name == "Medium" and mediumLabel) or hardLabel

            if data.Active then
                if data.Seconds then
                    local delta = now - (data.LastUpdate or now)
                    local remaining = math.max(0, data.Seconds - delta)
                    data.Text = formatTime(remaining)
                end

                if data.Text ~= "" then
                    label.Text = ((name == "Easy" and "🌱 Easy: ") or (name == "Medium" and "⚔️ Medium: ") or "🔥 Hard: ") .. data.Text
                    label.Position = UDim2.new(0, 10, 0, label.Position.Y.Offset) -- 🔧 add X offset of 10
                    label.Visible = true
                    show = true
                else
                    label.Visible = false
                end
            else
                label.Visible = false
            end
        end

        frame.Visible = show
        task.wait(1)
    end
end)


-- Misc
local antiAFKEnabled = false

local function simulateMovement()
    while antiAFKEnabled do
        local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:Move(Vector3.new(0, 0, 0.1))
        end
        wait(5)
    end
end

Tabs.Misc:AddToggle("AntiAFKToggle", {
    Title = "Anti-AFK",
    Description = "Prevents being kicked for AFK",
    Default = false,
    Callback = function(value)
        antiAFKEnabled = value
        if antiAFKEnabled then
            simulateMovement()
        end
    end
})



SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
