local RS=game:GetService("ReplicatedStorage")
local RF=RS.RemoteFunction
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local mouse=player:GetMouse()
local location=game.Workspace.Selections
local isTrue=false

function strToTable(list)
	local out = {}
	for entry in string.gmatch(list, "[^,]+") do
		table.insert(out, tonumber(entry))
	end
	return out
end

--client updater
RS:GetAttributeChangedSignal('InRound'):Connect(function()
	if RS:GetAttribute('InRound')==true then
		local provinces=workspace.Provinces:GetChildren()
		for i=1,#provinces do 
			local cur=provinces[i]
			if cur.BrickColor~=player.TeamColor then
				cur.BrickColor=BrickColor.new("Medium Medium stone grey")
			end
		end
		local LocalData=RF:InvokeServer(player)
		print(LocalData)
		for i,cur in pairs(LocalData) do
			print(workspace.Provinces[i])
			workspace.Provinces[i].BillboardGui.Enabled=true
		end
	end
end)

function ClickOnSelection()
	if mouse.Target == nil then
		return
	end
	if mouse.Target.Parent ~= game.Workspace.Provinces then
		return
	end
	if mouse.Target.BrickColor ~= player.TeamColor then 
		return
	end
	if mouse.Target == nil then
		return 
	end
	if mouse.Target ~= nil then
		if not location:FindFirstChild(mouse.Target.Name) then
			local ClickBox = Instance.new("SelectionBox")
			ClickBox.Name = mouse.Target.Name
			ClickBox.Adornee = mouse.Target
			ClickBox.Color3 = Color3.new("Really red")
			ClickBox.SurfaceColor3 = Color3.new(178, 255, 105)
			ClickBox.Parent = game.workspace.Selections
		elseif location:FindFirstChild(mouse.Target.Name,math.huge) then
			location:FindFirstChild(mouse.Target.Name):Remove()
		end
	end
end

mouse.Button1Down:connect(ClickOnSelection)




