local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents")
local QuestAccept = RemoteEvent:WaitForChild("QuestAccept")
local CombatSystem = ReplicatedStorage:WaitForChild("CombatSystem")
local Remotes = CombatSystem:WaitForChild("Remotes")
local Hit = Remotes:WaitForChild("RequestHit")

local NPCs = workspace:WaitForChild("NPCs")

local function getQuestAndMon()
    local level = player.Data.Level.Value

    local monList, questId
    if level >= 10000 and level <= 100000 then
        monList = {"Thief1","Thief2", "Thief3", "Thief4", "Thief5"}
        questId = "QuestNPC1"
	
	end	

    if not questId or not monList then
        return nil, nil
    end

    local QuestFrame = player.PlayerGui:FindFirstChild("QuestUI", true) and player.PlayerGui.QuestUI:FindFirstChild("Quest")
   
    if QuestFrame and QuestFrame.Visible then
    else
        QuestAccept:FireServer(questId)
    end 

    return monList[math.random(1, #monList)], questId
end
while true do 
    task.wait(0.2)

     if not character or not character.Parent or humanoid.Health <= 0 then
        character = player.CharacterAdded:Wait()
        humanoid = character:WaitForChild("Humanoid")
        root = character:WaitForChild("HumanoidRootPart")
        continue
    end

    local monName = getQuestAndMon()

    if not monName then continue end

    local target 
    for _, npc in ipairs(NPCs:GetChildren()) do
        if npc.Name == monName and npc:FindFirstAncestorWhichIsA("Humanoid") then
		local hum = npc:FindFirstAncestorWhichIsA("Humanoid")
            if hum.Health > 0 then
                target = npc
                break
            end
        end
    end

    if not target then
        task.wait(1)
        continue
    end

    local targetRoot = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if not targetRoot then continue end

    while task.wait(0.12) do
        local hum = target:FindFirstChildWhichIsA("Huamnoid")
        if not hum or hum.Health <= 0 or not target.Parent then
            break
        end

        root.CFrame = targetRoot.CFrame * CFrame.new(0,0,3)

        Hit:FireServer()
    end
end


getQuestAndMon()
