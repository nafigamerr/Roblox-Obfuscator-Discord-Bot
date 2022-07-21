-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
local ModuleScripts = ReplicatedStorage.ModuleScripts
local GameSettings = require(ModuleScripts:WaitForChild("GameSettings"))
local PlayerManagement = ServerScriptService.PlayerManagement
local PlayerManagementModules = PlayerManagement.ModuleScripts
local ParticleController = require(PlayerManagementModules.ParticleController)
local Data = ServerScriptService.Data
local DataStore = require(Data.Modules.DataStore)
local UpgradeManager = require(Data.Modules.UpgradeManager)

-- Events
local Events = ReplicatedStorage.Events
local BuyUpgradeEvent = Events.BuyUpgrade
local AddUpgradeEvent = Events.AddUpgrade
local UpdatePointsEvent = Events.UpdatePoints
local TouchCheckpointEvent = Events.TouchCheckpoint
local ChangeController = Events.ChangeController
local PlayerEnteredGame = Events.PlayerEnteredGame


-- Local Functions
-- Get their stats and update the value
local function updatePlayerPoints(player, valueToAdd)
	local stats = player:WaitForChild("stats")
	local points = stats:WaitForChild(GameSettings.pointsName)
	local totalPoints = stats:WaitForChild("Total"..GameSettings.pointsName)
	
	points.Value = points.Value + valueToAdd
	if valueToAdd > 0 then
		totalPoints.Value = totalPoints.Value + valueToAdd
	end
	DataStore:IncrementPoints(player, valueToAdd)
end

local function makeUpgradePurchase(player)
	local stats = player:WaitForChild("stats")
	local points = stats:WaitForChild(GameSettings.pointsName)
	local upgrades = stats:WaitForChild(GameSettings.upgradeName)
	
	UpgradeManager:BuyUpgrade(player)
end

local function touchCheckpoint(player)
	ParticleController.EmitCheckpointParticle(player)
end

local function addPlayerUpgrade(player)
	UpgradeManager:AddUpgrade(player)
end

local function changeController(player, defaultController)
	if defaultController then
		player.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice
		player.DevTouchMovementMode = Enum.DevTouchMovementMode.UserChoice
	else
		player.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable
		player.DevTouchMovementMode = Enum.DevTouchMovementMode.Scriptable
	end
end

local function onPlayerEnteredGame(player)
	UpgradeManager:SetWalkspeedToCurrentUpgrade(player)
end


-- Connections
AddUpgradeEvent.OnServerEvent:Connect(addPlayerUpgrade)
BuyUpgradeEvent.OnServerEvent:Connect(makeUpgradePurchase)
UpdatePointsEvent.OnServerEvent:Connect(updatePlayerPoints)
TouchCheckpointEvent.OnServerEvent:Connect(touchCheckpoint)
ChangeController.OnServerEvent:Connect(changeController)
ChangeController.OnServerEvent:Connect(changeController)
PlayerEnteredGame.OnServerEvent:Connect(onPlayerEnteredGame)