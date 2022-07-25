local ProvinceDataModule=require(script.parent.ProvinceData)
local LanchestersModule=require(script.parent.LanchestersModule)
local DijkstraModule=require(script.parent.DijkstraModule)
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local ServerStorage=game:GetService('ServerStorage')

local BlobCloner=ReplicatedStorage.BlobCloner
local function onEventFired(player,units,position,Path)
	local Blob = ReplicatedStorage.Blob:Clone()
	Blob.Parent = workspace.Blobs
	Blob.BrickColor = BrickColor.new(player.TeamColor.Color)
	Blob.Size=Vector3.new(0.6*(1+units/1000),(1+units/1000),(1+units/1000))
	Blob.Position=position
	Blob:SetAttribute('Path',Path)
end

BlobCloner.OnServerEvent:Connect(onEventFired)

--redundant
function strToTable(list) --turns a string into a table
	local out = {}
	for entry in string.gmatch(list, "[^,]+") do
		table.insert(out, tonumber(entry))
	end
	return out
end

local CombatFunction=ReplicatedStorage.CombatFunction
CombatFunction.OnServerInvoke = (function(player,p1,p2)
	return LanchestersModule(p1,p2)
end)


--creates a table for a client when invoked, this is not the final function

local ClientDataGrabber=ReplicatedStorage.ClientDataGrabber
ClientDataGrabber.OnServerInvoke = (function(player,provinceName,data)
	return ProvinceDataModule.grab(province,attribute,data)
end)

local ClientDataUpdate=ReplicatedStorage.ClientDataUpdate
ClientDataUpdate.OnServerInvoke = (function(player,province,attribute,change)
	ProvinceDataModule.update(player.TeamColor,province,attribute,change)
end)

local DijkstraFunction=ReplicatedStorage.DijkstraFunction
DijkstraFunction.OnServerInvoke = (function(player,province1,province2)
	return DijkstraModule(province1,province2)
end)