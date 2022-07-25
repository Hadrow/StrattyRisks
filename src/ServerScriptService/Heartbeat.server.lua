local ProvinceDataModule=require(script.parent.ProvinceData)
local LanchestersModule=require(script.parent.LanchestersModule)
local DijkstraModule=require(script.parent.DijkstraModule)
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local ServerStorage=game:GetService('ServerStorage')

--clones a bob on request from a client
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

--updates combat to the request
local CombatFunction=ReplicatedStorage.CombatFunction
CombatFunction.OnServerInvoke = (function(player,p1,p2)
	return LanchestersModule(p1,p2)
end)

--client/server request for specific information
local SpecificDataGrabber=ReplicatedStorage.SpecificDataGrabber
SpecificDataGrabber.OnServerInvoke = (function(player,province,data)
	return ProvinceDataModule.SpecificRequest(province,data)
end)

--creates a table for everything a client owns, usually only at the start of the game
local TeamDataGrabber=ReplicatedStorage.TeamDataGrabber
TeamDataGrabber.OnServerInvoke=(function(player)
	return ProvinceDataModule.request(player.TeamColor)
end)

--updates data on the client when there is an observed change
local ClientDataUpdate=ReplicatedStorage.ClientDataUpdate
ClientDataUpdate.OnServerInvoke = (function(player,province,attribute,change)
	ProvinceDataModule.update(player.TeamColor,province,attribute,change)
end)

--communicates path to the client who uses the function
local DijkstraFunction=ReplicatedStorage.DijkstraFunction
DijkstraFunction.OnServerInvoke = (function(player,province1,province2)
	return DijkstraModule(province1,province2)
end)