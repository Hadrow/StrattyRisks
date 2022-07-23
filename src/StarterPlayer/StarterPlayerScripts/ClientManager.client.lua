local RS=game:GetService("ReplicatedStorage")
local RF=RS.ClientDataGrabber
local RF2=RS.ClientDataUpdate
local CombatFunction=RS.CombatFunction
local DijkstraFunction=RS.DijkstraFunction
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local mouse=player:GetMouse()
local location=game.Workspace.Selections
local GUI=100

local inRound=false
local LocalData=nil
local provinces=nil
mouse.TargetFilter = workspace.Nodes

--currently redundant but may come in use later, used to swap tables through attributes
function strToTable(list)
	local out = {}
	for entry in string.gmatch(list, "[^,]+") do
		table.insert(out, tonumber(entry))
	end
	return out
end

function tableToStr(table)
	print(table)
	local string='['
	for i=1,#table do
		local cur=table[i]
		print(cur)
		string[i+1]=tostring(cur)
		string[i+1]=','
	end
	string[i+1]=']'
	return string
end

--sends client the relevant information
RS:GetAttributeChangedSignal('InRound'):Connect(function()
	if RS:GetAttribute('InRound')==true then
		inRound=true
		provinces=workspace.Provinces:GetChildren()
		while inRound==true do
			LocalData=RF:InvokeServer(player)
			for i,cur in pairs(LocalData) do
				workspace.Provinces[i].BillboardGui.Enabled=true
				workspace.Provinces[i]:SetAttribute("HasArtilley",cur.Artillery)
				workspace.Provinces[i]:SetAttribute("HasFactory",cur.Factory)
				workspace.Provinces[i]:SetAttribute("HasFort",cur.Fort)
				workspace.Provinces[i]:SetAttribute("HasPowerplant",cur.Powerplant)
				workspace.Provinces[i]:SetAttribute("Team",cur.Team)
				workspace.Provinces[i].BrickColor=workspace.Provinces[i]:GetAttribute("Team")
				workspace.Provinces[i]:SetAttribute("Value",cur.Value)
				workspace.Provinces[i].BillboardGui.TextLabel.Text=workspace.Provinces[i]:GetAttribute("Value")
			end
			for i=1,#provinces do
				local cur=provinces[i]
				if LocalData[cur.Name]==nil then
					workspace.Provinces[cur.Name].BillboardGui.Enabled=false
					workspace.Provinces[cur.Name]:SetAttribute("Team",BrickColor.new("Medium stone grey"))
					workspace.Provinces[cur.Name].BrickColor=workspace.Provinces[cur.Name]:GetAttribute("Team")
				end
			end
			local selections=workspace.Selections:GetChildren()
			for i=1,#selections do 
				local cur=selections[i]
				if workspace.Provinces[cur.Name]:GetAttribute("Team")~=player.TeamColor then
					cur:Remove()
				end
			end
			wait()
		end
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
				print(path)
				generateBlob(units,workspace.Provinces[Selections[i].Name].position,target.Name,Path)
			end
		end
	end
end

function generateBlob(units,position,HeadingFor,Path)
	local Blob = RS.Blob:Clone()
	Blob.Parent = workspace.Blobs
	Blob.BrickColor = BrickColor.new(player.TeamColor.Color)
	Blob.Size=Vector3.new(0.6*(1+units/1000),(1+units/1000),(1+units/1000))
	Blob.Position=position
	Blob:SetAttribute("HeadingFor",HeadingFor)
	Blob:SetAttribute("Path",Path)
end

function countUnits(province)
	local num=RF:InvokeServer(province,'Value')
	print(num)
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




