local Delaunay=require(script.Parent.DelaunayModule)

--a module used to handle provinceData(province values, buildings, colors, if owned...) which is not mapData

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
		cur.Artillery=provinces[i]:GetAttribute('HasArtillery')
		cur.Factory=provinces[i]:GetAttribute('HasFactory')
		cur.Fort=provinces[i]:GetAttribute('HasFort')
		cur.Powerplant=provinces[i]:GetAttribute('HasPowerplant')
		cur.Team=provinces[i]:GetAttribute("Team")
		cur.Owned=provinces[i]:GetAttribute("IsOwned")
		cur.Value=provinces[i]:GetAttribute("Value")
		cur.Adjacment=adjMatrix[i]
	end
	ProvinceData.Data=Data
	print(Data)
	return Data
end

function ProvinceData.update( province, attribute, update )
	local mapData=Delaunay.mapData
	ProvinceData.Data[province][attribute]=update
	return print("changed",ProvinceData.Data[province][attribute],"should be", update)
end

return ProvinceData
