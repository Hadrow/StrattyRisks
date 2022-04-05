local max, sqrt = math.max, math.sqrt
local insert,remove, unpack =table.insert,table.remove, unpack or table.unpack

local function quatCross(a, b, c)
	local p = (a + b + c) * (a + b - c) * (a - b + c) * (-a + b + c)
	return sqrt( p )
end


local function crossProduct(p1, p2, p3)
	local x1, x2 = p2.x - p1.x, p3.x - p2.x
	local y1, y2 = p2.y - p1.y, p3.y - p2.y
	return x1 * y2 - y1 * x2
end

local function isFlatAngle(p1, p2, p3)
	return (crossProduct(p1, p2, p3) == 0)
end

local Point = {}

Point.__index = Point

function Point.new( x, y )
	return setmetatable( {x = x, y = y, id = 0}, Point )
end

function Point:__eq( other )   
	return self.x == other.x and self.y == other.y 
end

function Point:__tostring()
	return ('Point (%s) x: %.2f y: %.2f'):format( self.id, self.x, self.y)
end

function Point:dist2(p)
	local dx, dy = (self.x - p.x), (self.y - p.y)
	return dx * dx + dy * dy
end

function Point:dist(p)
	return sqrt(self:dist2(p))
end

function Point:isInCircle(cx, cy, r)
	local dx = (cx - self.x)
	local dy = (cy - self.y)
	return ((dx * dx + dy * dy) <= (r * r))
end

setmetatable( Point, {__call = function( _, x, y )
	return Point.new( x, y )
end} )


local Edge = {}

Edge.__index = Edge

function Edge.new( p1, p2 )
	return setmetatable( { p1 = p1, p2 = p2, length2=0 }, Edge )
end

function Edge:__eq( other ) 
	return self.p1 == other.p1 and self.p2 == other.p2 
end

function Edge:__tostring()
	return (('Edge :\n  %s\n  %s\n  %s'):format(tostring(self.p1), tostring(self.p2),tostring(self.length2) ))
end

function Edge:same(otherEdge)
	return ((self.p1 == otherEdge.p1) and (self.p2 == otherEdge.p2))
		or ((self.p1 == otherEdge.p2) and (self.p2 == otherEdge.p1))
end

function Edge:length()
	return self.p1:dist(self.p2)
end

function Edge:getMidPoint()
	local x = self.p1.x + (self.p2.x - self.p1.x) / 2
	local y = self.p1.y + (self.p2.y - self.p1.y) / 2
	return x, y
end

setmetatable( Edge, {__call = function(_,p1,p2)
	return Edge.new( p1, p2 )
end} )


local Triangle = {}

Triangle.__index = Triangle

function Triangle.new( p1, p2, p3 )
	assert(not isFlatAngle(p1, p2, p3), ("angle (p1, p2, p3) is flat:\n  %s\n  %s\n  %s")
		:format(tostring(p1), tostring(p2), tostring(p3)))
	return setmetatable( {
		p1 = p1, p2 = p2, 
		p3 = p3, e1 = Edge(p1, p2), e2 = Edge(p2, p3), e3 = Edge(p3, p1)}, Triangle )

end

function Triangle:__tostring()
	return (('Triangle: \n  %s\n  %s\n  %s')
		:format(tostring(self.p1), tostring(self.p2), tostring(self.p3)))
end

function Triangle:isCW()
	return (crossProduct(self.p1, self.p2, self.p3) < 0)
end

function Triangle:isCCW()
	return (crossProduct(self.p1, self.p2, self.p3) > 0)
end

function Triangle:getSidesLength()
	return self.e1:length(), self.e2:length(), self.e3:length()
end

function Triangle:getCenter()
	local x = (self.p1.x + self.p2.x + self.p3.x) / 3
	local y = (self.p1.y + self.p2.y + self.p3.y) / 3
	return x, y
end

function Triangle:getCircumCircle()
	local x, y = self:getCircumCenter()
	local r = self:getCircumRadius()
	return x, y, r
end

function Triangle:getCircumCenter()
	local p1, p2, p3 = self.p1, self.p2, self.p3
	local D =  ( p1.x * (p2.y - p3.y) +
		p2.x * (p3.y - p1.y) +
		p3.x * (p1.y - p2.y)) * 2
	local x = (( p1.x * p1.x + p1.y * p1.y) * (p2.y - p3.y) +
		( p2.x * p2.x + p2.y * p2.y) * (p3.y - p1.y) +
		( p3.x * p3.x + p3.y * p3.y) * (p1.y - p2.y))
	local y = (( p1.x * p1.x + p1.y * p1.y) * (p3.x - p2.x) +
		( p2.x * p2.x + p2.y * p2.y) * (p1.x - p3.x) +
		( p3.x * p3.x + p3.y * p3.y) * (p2.x - p1.x))
	return (x / D), (y / D)
end

function Triangle:getCircumRadius()
	local a, b, c = self:getSidesLength()
	return ((a * b * c) / quatCross(a, b, c))
end

function Triangle:getArea()
	local a, b, c = self:getSidesLength()
	return (quatCross(a, b, c) / 4)
end

function Triangle:inCircumCircle(p)
	return p:isInCircle(self:getCircumCircle())
end

setmetatable( Triangle, {__call = function( _, p1, p2, p3 )
	return Triangle.new( p1, p2, p3 )
end} )



local delaunay = {
	Point            = Point,
	Edge             = Edge,
	Triangle         = Triangle
}

function delaunay.triangulate( vertices )
	local nvertices = #vertices
	assert( nvertices > 2, "Cannot triangulate, needs more than 3 vertices" )

	if nvertices == 3 then
		return {Triangle(vertices[1], vertices[2], vertices[3])}
	end

	local trmax = nvertices * 4
	local minX, minY = vertices[1].x, vertices[1].y
	local maxX, maxY = minX, minY

	for i = 1, #vertices do
		local vertex = vertices[i]
		vertex.id = i
		if vertex.x < minX then minX = vertex.x end
		if vertex.y < minY then minY = vertex.y end
		if vertex.x > maxX then maxX = vertex.x end
		if vertex.y > maxY then maxY = vertex.y end
	end

	local dx, dy = (maxX - minX), (maxY - minY)
	local deltaMax = max(dx, dy)
	local midx, midy = (minX + maxX) * 0.5, (minY + maxY) * 0.5
	local p1 = Point( midx - 2 * deltaMax, midy - deltaMax )
	local p2 = Point( midx, midy + 2 * deltaMax )
	local p3 = Point( midx + 2 * deltaMax, midy - deltaMax )

	p1.id, p2.id, p3.id = nvertices + 1, nvertices + 2, nvertices + 3
	vertices[p1.id], vertices[p2.id], vertices[p3.id] = p1, p2, p3

	local triangles = {Triangle( vertices[nvertices + 1], vertices[nvertices + 2], vertices[nvertices + 3] )}

	for i = 1, nvertices do
		local edges = {}
		local ntriangles = #triangles

		for j = #triangles, 1, -1 do
			local curTriangle = triangles[j]
			if curTriangle:inCircumCircle(vertices[i]) then
				edges[#edges + 1] = curTriangle.e1
				edges[#edges + 1] = curTriangle.e2
				edges[#edges + 1] = curTriangle.e3
				remove( triangles, j )
			end
		end

		for j = #edges - 1, 1, -1 do
			for k = #edges, j + 1, -1 do
				if edges[j] and edges[k] and edges[j]:same(edges[k]) then
					remove( edges, j )
					remove( edges, k-1 )
				end
			end
		end

		for j = 1, #edges do
			local n = #triangles
			assert(n <= trmax, "Generated more than needed triangles")
			triangles[n + 1] = Triangle(edges[j].p1, edges[j].p2, vertices[i])
		end
	end

	for i = #triangles, 1, -1 do
		local triangle = triangles[i]
		if triangle.p1.id > nvertices or triangle.p2.id > nvertices or triangle.p3.id > nvertices then
			remove( triangles, i )
		end
	end
	for _ = 1,3 do 
		remove( vertices ) 
	end
	return triangles
end

function delaunay.mapData(vertices)
	local triangles=delaunay.triangulate(vertices)
	local matrix={}
	local edges={}
	for i=1,#triangles do
		local cur=triangles[i]
		edges[#edges+1]=cur.e1
		edges[#edges+1]=cur.e2
		edges[#edges+1]=cur.e3
	end

	for i=1,#edges do
		for j=1,#edges do
			if edges[i] and edges[j] and edges[i].p1==edges[j].p2 and edges[i].p2==edges[j].p1 then
				remove(edges,j)
			end
		end
	end

	for i=#edges,1,-1 do
		local edge=edges[i]
		local length=edge:length()
		edge.length2=length
		if length>8 then
			remove(edges,i)
		end
	end
	
	for i=1,#vertices do
		matrix[#matrix+1]={}
		for j=1,#edges do
			local vertex=vertices[i]
			local edge=edges[j]
			if edge and vertex and edge.p1==vertex then
				matrix[i][#matrix[i]+1]=edge.p2.id
			end
			if edge and vertex and edge.p2==vertex then
				matrix[i][#matrix[i]+1]=edge.p1.id
			end
		end
	end
	
	local function concaveHull(matrix,vertices)
		
		local concaveHull={}
		
		local nvertices=#vertices
		
		--finds the point thats rightmost and topmost
		--this needs work!!!!!!
		local function cornerVertex(vertices)
			local maxX=0
			local minX=100
			local maxY=0
			local minY=100
			for i=1,#vertices do
				local cur=vertices[i]
				if cur.x>maxX then maxX=cur.x end
				if cur.x<minX then minX=cur.x end
				if cur.y>maxY then maxY=cur.y end
				if cur.y<minY then minY=cur.y end
			end
			local minmag={500,0}
			for i=1,#vertices do
				local cur=vertices[i]
				local mag=math.sqrt(math.pow(cur.x-maxX,2)+math.pow(cur.y-maxY,2))
				if mag<minmag[1] then minmag[1]=mag minmag[2]=cur.id end
			end
			return vertices[minmag[2]]
		end
		
		--finds a vector thats bottommost and rightmost compared to the firstVector
		local function nextVertex(matrix,cornerVertex)
			local nextVertex=nil
			local AdjacmentVertices=matrix[cornerVertex.id]
			local maxX=0
			local maxY=0
			local minX=100
			local minY=100
			for i=1,#AdjacmentVertices do
				local cur=vertices[AdjacmentVertices[i]]
				if cur.x>maxX then maxX=cur.x end
				if cur.x<minX then minX=cur.x end
				if cur.y>maxY then maxY=cur.y end
				if cur.y<minY then minY=cur.y end
			end
			for i=1,#AdjacmentVertices do
				local cur=vertices[AdjacmentVertices[i]]
				if cur.y==maxY then
					nextVertex=cur
				end
			end
			return nextVertex
		end
		
		local cornerVertex=cornerVertex(vertices)
		local nextVertex=nextVertex(matrix,cornerVertex)
		concaveHull[#concaveHull+1]=cornerVertex
		concaveHull[#concaveHull+1]=nextVertex
		
		--finds an angle from origin and next vertex
		local function angle(originVertex,alignmentVertex,Vertex)
			--aligning vertices to the origin
			local Ax,Ay=originVertex.x,originVertex.y
			local Bx,By=alignmentVertex.x,alignmentVertex.y
			local Cx,Cy=Vertex.x,Vertex.y
			Bx,By=Bx-Ax,By-Ay
			Cx,Cy=Cx-Ax,Cy-Ay
			local dot_product=Cx*Bx+Cy*By
			local cross_product=Cx*By-Cy*Bx
			local angle=math.atan2(math.abs(cross_product),dot_product)*180/math.pi
			if cross_product<0 then
				angle=360-angle
			end
			return angle
		end
		
		local function pickedVertex(matrix,prevVertex,originVertex)
			local biggestAngleVertex={}
			local originVertex=originVertex.id
			local prevVertex=prevVertex.id
			local selectedMatrix=matrix[originVertex]
			for i=1,#selectedMatrix do
				local cur=selectedMatrix[i]
				local angle=angle(vertices[originVertex],vertices[prevVertex],vertices[cur])
				biggestAngleVertex[#biggestAngleVertex+1]={angle=angle,vertex=cur}
			end
			table.sort(biggestAngleVertex, function(a,b)
				return a.angle>b.angle
			end)
			return vertices[biggestAngleVertex[1].vertex]
		end
		
		repeat
			
			local prevVertex=concaveHull[#concaveHull-1]
			local originVertex=concaveHull[#concaveHull]
			
			concaveHull[#concaveHull+1]=pickedVertex(matrix,prevVertex,originVertex)
			
		until concaveHull[#concaveHull]==concaveHull[1]
		
		return concaveHull
	end
	
	local concaveHull=concaveHull(matrix,vertices)
	
	local mapData={
		concaveHull=concaveHull,
		Provinces=vertices,
		Edges=edges,
		adjMatrix=matrix,
		Triangles=triangles
	}
	_G.mapData=mapData
	return mapData
end

return delaunay