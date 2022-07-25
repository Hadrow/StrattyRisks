local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TeamDataGrabber=ReplicatedStorage.TeamDataGrabber
local SpecificDataGrabber=ReplicatedStorage.SpecificDataGrabber
local ClientDataUpdate=ReplicatedStorage.ClientDataUpdate

local CombatFunction=ReplicatedStorage.CombatFunction
local DijkstraFunction=ReplicatedStorage.DijkstraFunction

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local mouse=player:GetMouse()

local location=game.Workspace.Selections
local GUI=100
local BlobCloner=ReplicatedStorage.BlobCloner

local inRound=false
local LocalData=nil
local provinces=nil
mouse.TargetFilter = workspace.Nodes

function strToTable(list)
	local out = {}
	for entry in string.gmatch(list, "[^,]+") do
		table.insert(out, tonumber(entry))
	end
	return out
end

function tableToStr(table)
	local string=''
	for i,v in pairs(table) do
		local name,value=next(v)
		string=string..name..','
	end
	string=string:sub(0,-2)
	return string
end

--sends client the relevant information
ReplicatedStorage:GetAttributeChangedSignal('InRound'):Connect(function()
	if ReplicatedStorage:GetAttribute('InRound')==true then
		inRound=true
		provinces=workspace.Provinces:GetChildren()
		while inRound==true do
			LocalData=TeamDataGrabber:InvokeServer()
			for i,v in pairs(workspace.Provinces:GetChildren()) do
				if LocalData[v.Name]==nil then
					v.BrickColor=BrickColor.new('Middile stone grey')
					v.BillboardGui.Enabled=false
				end
			end
			for i,v in pairs(LocalData) do
				workspace.Provinces[i].BrickColor=v.Team
				workspace.Provinces[i].BillboardGui.Enabled=true
				workspace.Provinces[i].BillboardGui.OwnerValue.Text=SpecificDataGrabber:InvokeServer(i,'OwnerValue')
			end
			wait()
		end
	else
		inRound=false
	end
end)


--this function will be used in the future to send info about values into the server side lanchasters module
function PressF(key)
	local target=mouse.Target
	if (key == "f") then
		local Selections = game.Workspace.Selections:GetChildren()
		if #Selections>0 and target~=nil and LocalData[target.Name]~=nil then
			local Province1={[Selections[1].Name] = LocalData[Selections[1].Name]}
			local Province2={[target.Name] = LocalData[target.Name]}
			local path = DijkstraFunction:InvokeServer(Province1,Province2)
			for i=1,#Selections do
				local units=countUnits(Selections[i].Name)
				local cur ={[Selections[i].Name] = LocalData[Selections[i].Name]}
				local path = tableToStr(DijkstraFunction:InvokeServer(cur,Province2))
				BlobCloner:FireServer(units,workspace.Provinces[Selections[i].Name].position,path)
			end
		end
	end
end

function countUnits(province)
	local num=SpecificDataGrabber:InvokeServer(province,'OwnerValue')
	if num>GUI then num=GUI end
	return num
end


--combat(gonna be used in the future)
--[[
function CombatStarts()
	if (Troop.position==Province2.position) then
		local Selections = game.Workspace.Selections:GetChildren()
		if #Selections>0 and mouse.Target~=nil and LocalData[mouse.Target.Name]~=nil then
			local Province1=LocalData[Selections[1].Name]
			local Province2=LocalData[mouse.Target.Name]
			print(Province1,Province2)
			print(CombatFunction:InvokeServer(Province1,Province2))
		end
	end
end
]]





mouse.KeyDown:connect(PressF)
--Just a visual part of the client like the clickboxes hoverboxes etc.
function ClickOnSelection()
	if mouse.Target == nil then
		workspace.Selections:ClearAllChildren()
		return
	end
	if mouse.Target.Parent ~= game.Workspace.Provinces then
		return
	end
	if mouse.Target.BrickColor ~= player.TeamColor then 
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




