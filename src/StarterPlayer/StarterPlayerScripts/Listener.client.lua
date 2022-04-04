local RS=game:GetService("ReplicatedStorage")
local RF=RS.RemoteFunction
local Player = game.Players.LocalPlayer
local mouse = Player:GetMouse()

mouse.TargetFilter = game.Workspace.Baseplate
mouse.TargetFilter = game.Nodes.string.match("Node")

function PressF(key)
	if (key == "f") then
		local Selected={}
		local Selections = game.Workspace.Selections:GetChildren()
		for i,v in pairs(Selections) do
			
		end
	end
end





mouse.KeyDown:connect(PressF)