local Delaunay=require(script.Parent.DelaunayModule)

--a module used to handle provinceData(province values, buildings, colors, if owned...)

local ProvinceData= {
	Data  = nil
}

function ProvinceData.generate()
	local mapData=Delaunay.mapData
	local provinces=workspace.Provinces:GetChildren()
	local adjMatrix=mapData.adjMatrix
	local Data={}
	for i=1,#provinces do
		Data[provinces[i].Name]={}
		local cur=Data[provinces[i].Name]
		cur.Artillery=false
		cur.Factory=false
		cur.Fort=false
		cur.Powerplant=false
		cur.Team=BrickColor.new("Middile stone grey")
		cur.OwnerValue=100
		cur.AttackerValue=0
		cur.AdjacmentTo=adjMatrix[i]
	end
	ProvinceData.Data=Data
	print(Data)
	return Data
end

--gets updates from the clients
function ProvinceData.update(province, data, update )
	ProvinceData.Data[province][data]=update
end

--only gives specific data
function ProvinceData.SpecificRequest(province,data)
	return ProvinceData.Data[province][data]
end

--gives whole data, usually only at the game start
function ProvinceData.request(TeamColor)
	local list={}
	local ProvinceData=ProvinceData.Data
	for i,v in pairs(ProvinceData) do
		if v.Team==TeamColor then
			list[i]=v
			local Adjacment=v['AdjacmentTo']
			for j,w in pairs(Adjacment) do
				if list['Province_'..w]==nil then
					list['Province_'..w]=ProvinceData['Province_'..w]
				end
			end
		end
	end
	return list
end

return ProvinceData
