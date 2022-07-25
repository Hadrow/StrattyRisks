local delaunay=require(script.Parent.DelaunayModule)

--copies a table
local function copy(tabl)
	local copy = {}
	for k, v in pairs(tabl) do
		copy[k] = v
	end
	return copy
end

--selects a vertex with the minimum path lenght
local function selectMinVertex(set,set2)
	local minimum=math.huge
	local vertex=0
	for i=1,#set do
		if (set2[i]==false and set[i]<minimum) then
			vertex=i
			minimum=set[i]
		end
	end
	return vertex
end

--a function that calculates a shortest path from the start to the end point
function Dijkstra(startPoint,endPoint)
	
	local vertices=copy(delaunay.mapData.Provinces)
	local matrix=copy(delaunay.mapData.adjMatrix)
	local edges=copy(delaunay.mapData.Edges)
	
	local distance={}
	local processed={}
	local parent={}
	
	--sets the path of all vertices to a maximum possible value
	for i=1,#vertices do
		distance[#distance+1]=math.huge
		parent[#parent+1]=math.huge
		processed[#processed+1]=false
	end
	
	--makes a start point a first one in the list and also sets its distance to 0
	parent[startPoint]=-1
	distance[startPoint]=0

	--grabs adjacment vertices of a vertex
	local function getNeighbours(vertex)
		return matrix[vertex.id]
	end
	
	--uses basic algebra to find a distance in between two vertices
	local function findDistance(v1,v2)
		local v1=vertices[v1]
		local v2=vertices[v2]
		for i=1,#edges do
			local edge=edges[i]
			if edge.p1==v1 and edge.p2==v2 or edge.p2==v1 and edge.p1==v2 then
				return edge.length2
			end 
		end
		return 0
	end

	--selects the next vertex which has the minimal distance and adds it to processed table
	for i=1,#vertices-1 do
		
		local U=selectMinVertex(distance,processed)
		processed[U]=true
		
		for j=1,#vertices do
			if (findDistance(U,j)~=0 and processed[j]==false and distance[U]~=math.huge and ((distance[U]+findDistance(U,j))<distance[j])) then
				distance[j]=distance[U]+findDistance(U,j)
				parent[j]=U
			end 
		end
	end

	--reverses the table and finds the shortest path
	local ShortestPath={}
	local lastPoint=endPoint
	ShortestPath[#ShortestPath+1]=lastPoint
	for i=1,#vertices do
		local lastPoint=ShortestPath[#ShortestPath]
		local nextis=parent[lastPoint]
		if nextis==-1 then break end
		ShortestPath[#ShortestPath+1]=nextis
	end
	for i=1, math.floor(#ShortestPath/2) do
		local j=#ShortestPath-i+1
		ShortestPath[i],ShortestPath[j]=ShortestPath[j],ShortestPath[i]
	end
	return ShortestPath
end
return Dijkstra