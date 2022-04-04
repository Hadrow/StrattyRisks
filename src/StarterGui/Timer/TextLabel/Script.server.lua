local replicatedStorage=game.ReplicatedStorage

replicatedStorage:GetAttributeChangedSignal("Status"):Connect(function()
	script.Parent.Text = game.ReplicatedStorage:GetAttribute("Status")
end)
