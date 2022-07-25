local Delaunay=require(script.Parent.DelaunayModule)
local Dijkstra=require(script.Parent.DijkstraModule)
local ProvinceData=require(script.Parent.ProvinceData)
local Lanchasters=require(script.Parent.LanchestersModule)
local mapData=Delaunay.mapData
local point=Delaunay.Point
local remove=table.remove
local testMap={point(4.83,2.06),point(3.19,7.77),point(0.99,7.06),point(0.29,2.14),point(2.15,9.41),point(8.07,4.58),point(5.73,5.51),point(9.00,6.05),point(8.23,0.92)}
local seed=math.random()

local Teams=game.Teams:GetChildren()

--converts directory to Vector3
function toV3(p)
	return Vector3.new(p.x,0,p.y)
end

--builds a Province
function createProvince(x,y,name)
	local Province=game.ReplicatedStorage.Province_:Clone()
	Province.Name='Province_'..name
	Province.Position=Vector3.new(x,0,y)
	Province.Parent=workspace.Provinces
end

--builds a node
function createNode(a,b)
	local p1=toV3(a)
	local p2=toV3(b)
	local dist = (p1-p2).Magnitude
	local line=game.ReplicatedStorage.Node:Clone()
	line.Parent=workspace.Nodes
	line.Name=a.id..' to '..b.id
	line.Main.Size = Vector3.new(0.15, 0.1, dist)
	line.Main.CFrame = CFrame.new(p1, p2) * CFrame.new(0, 0, -dist/2)
	line.Black.Size = Vector3.new(0.5, 0, dist)
	line.Black.CFrame = CFrame.new(p1, p2) * CFrame.new(0, 0, -dist/2)
end

function createBorder(a,b)
	local p1=toV3(a)
	local p2=toV3(b)
	local dist = (p1-p2).Magnitude
	local line=game.ReplicatedStorage.Node:Clone()
	line.Parent=workspace.Nodes
	line.Name=a.id..' to '..b.id
	line.Main.Size = Vector3.new(0.15, 0.1, dist)
	line.Main.CFrame = CFrame.new(p1, p2) * CFrame.new(0, 0, -dist/2)
	line.Black.Size = Vector3.new(0.5, 0, dist)
	line.Black.CFrame = CFrame.new(p1, p2) * CFrame.new(0, 0, -dist/2)
	line.Black.BrickColor=BrickColor.new("Bright red")
end

function constructMap(plrCount)
	local mapData=Delaunay.mapData
	local edges=mapData.Edges
	local vertices=mapData.Provinces
	local matrix=mapData.adjMatrix
	local concaveHull=mapData.concaveHull
	for i=1,#vertices do
		local cur=vertices[i]
		createProvince(cur.x,cur.y,cur.id)
	end
	for i=1,#edges do
		local cur=edges[i]
		local vertex1=cur.p1
		local vertex2=cur.p2
		createNode(vertex1,vertex2)
	end
	local Players=game:GetService("Players")

	local provinces = workspace.Provinces
	
	ProvinceData.generate()

	local p=1
	for i=1,#concaveHull do
		local cur=concaveHull[i]
		local ratio=math.floor(#concaveHull/plrCount-0.5)
		if ratio*p==i then
			local province="Province_"..cur.id
			ProvinceData.update(province,"Team",Teams[p].TeamColor)
			ProvinceData.update(province,"OwnerValue",1000)
			p=p+1
		end
		if concaveHull[i+1]~=nil then
			createBorder(cur,concaveHull[i+1])
		end
	end
	
	game.ReplicatedStorage:SetAttribute('InRound',true)
end


--#########################################################################################
--#########################################################################################
--########### Intermission part of the script #############################################
--#########################################################################################
--#########################################################################################

local roundLength  =0
local IntermissionLength = 1
local RS=game.ReplicatedStorage
local Players=game:GetService("Players")
local Players=game.Players

--checks if the player count is adequate and starts the intermission screen
Players.PlayerAdded:Connect(function(player)
	local plrCount=#Players:GetChildren()
	if plrCount >= 1 and RS:GetAttribute('InRound')==false then
		RS:SetAttribute('Intermission',true)
	end
end)

--checks if the game is in intermission and a player has left(not sure if this works) and will stop the intermission
Players.PlayerRemoving:Connect(function(player)
	local plrCount=#Players:GetChildren()
	if (plrCount-1) < 2 and RS:GetAttribute('InRound')==false then
		RS:SetAttribute('Intermission',false)
	end
end)

--starts generating the map at the end of intermission and start of the game
RS:GetAttributeChangedSignal('Intermission'):Connect(function()
	if RS:GetAttribute('Intermission')==false and RS:GetAttribute('InRound')==false and RS:GetAttribute('GameStarted')==true then
		local plrCount=#Players:GetChildren()
		mapData(plrCount)
		constructMap(plrCount)
	end
end)

--Checks if the Game ending conditions have been met and restarts the game if there are adequate amount of players.
RS:GetAttributeChangedSignal('GameEnded'):Connect(function()
	if RS:GetAttribute('GameEnded')==false then
		local plrCount=#Players:GetChildren()
		if plrCount >= 2 and RS:GetAttribute('InRound')==false then
			RS:SetAttribute('Intermission',true)
		end
	end
end)

--after a game has ended it clears the entire map, provinces, nodes, children and selections. Also sets the game to not in round.
RS:GetAttributeChangedSignal('GameEnded'):Connect(function()
	if RS:GetAttribute('GameEnded')==true then
		RS:SetAttribute('InRound',false)
		workspace.Nodes:ClearAllChildren()
		workspace.Provinces:ClearAllChildren()
		workspace.Selections:ClearAllChildren()
		workspace.Blobs:ClearAllChildren()
	end
	wait(8)
	RS:SetAttribute('GameEnded',false)	
end)

--round timer display.
local function roundTimer()
	while wait() do
		while RS:GetAttribute('InRound')==false and RS:GetAttribute('Intermission')==false and RS:GetAttribute('GameEnded')==false do
			RS:SetAttribute('Status',"Waiting for players")
			wait(1)
			RS:SetAttribute('Status',"Waiting for players.")
			wait(1)
			RS:SetAttribute('Status',"Waiting for players..")
			wait(1)
			RS:SetAttribute('Status',"Waiting for players...")
			wait(1)
		end
		
		local Length=IntermissionLength
		while RS:GetAttribute('Intermission')==true and Length>=0 do
			wait(1)
			RS:SetAttribute('Status',"Intermission: "..Length.." seconds left")
			Length-=1
		end
		
		RS:SetAttribute('GameStarted',true)
		RS:SetAttribute('Intermission',false)
		
		local len=0
		while RS:GetAttribute('Intermission')==false and RS:GetAttribute('InRound')==true do
			wait(1)
			RS:SetAttribute('Status',"Game has been ongoing for "..len.." seconds")
			len+=1
		end
		
		RS:SetAttribute('GameStarted',false)
		
		while RS:GetAttribute('GameEnded')==true do
			print('fired')
			RS:SetAttribute('Status','Game has ended awaiting restart')
			wait(1)
			RS:SetAttribute('Status','Game has ended awaiting restart.')
			wait(1)
			RS:SetAttribute('Status','Game has ended awaiting restart..')
			wait(1)
			RS:SetAttribute('Status','Game has ended awaiting restart...')
			wait(1)
		end
		
		RS:SetAttribute('GameEnded',false)
		
	end
end

spawn(roundTimer())