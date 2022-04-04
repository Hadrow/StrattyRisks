local function copy(tabl)
	local copy = {}
	for k, v in pairs(tabl) do
		copy[k] = v
	end
	return copy
end

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

function Dijkstra(startPoint,endPoint)
	
	local vertices=copy(_G.mapData.Provinces)
	local matrix=copy(_G.mapData.adjMatrix)
	local edges=copy(_G.mapData.Edges)
	
	local distance={}
	local processed={}
	local parent={}
	
	for i=1,#vertices do
		distance[#distance+1]=math.huge
		parent[#parent+1]=math.huge
		processed[#processed+1]=false
	end
	parent[startPoint.id]=-1
	distance[startPoint.id]=0
	
	local function getNeighbours(vertex)
		return matrix[vertex.id]
	end
	
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
	local ShortestPath={}
	local lastPoint=endPoint.id
	ShortestPath[#ShortestPath+1]=lastPoint
	for i=1,#vertices do
		local lastPoint=ShortestPath[#ShortestPath]
		local nextis=parent[lastPoint]
		if nextis==-1 then break end
		ShortestPath[#ShortestPath+1]=nextis
	end
	print(ShortestPath)
end
return Dijkstra