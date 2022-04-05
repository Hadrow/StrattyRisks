local RS=game:GetService("ReplicatedStorage")
local RF=RS.RemoteFunction
local Player = game.Players.LocalPlayer
local mouse = Player:GetMouse()

mouse.TargetFilter = game.Workspace.Baseplate
mouse.TargetFilter = game.Nodes.string.match("Node")

--this function will be used in the future to send info about values into the server side lanchasters module
function PressF(key)
	if (key == "f") then
		local Selected={}
		local Selections = game.Workspace.Selections:GetChildren()
		for i,v in pairs(Selections) do
			
		end
	end
end





mouse.KeyDown:connect(PressF)