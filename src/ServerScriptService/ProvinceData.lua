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

function ProvinceData.update(province, attribute, update )
	ProvinceData.Data[province][attribute]=update
end

function ProvinceData.grab(TeamColor, province, attribute, data)
	local Data=ProvinceData.Data
	local LocalData={}
	if data==nil then
		for i,cur in pairs(Data) do
			if cur.Team==TeamColor then
				LocalData[i]=cur
				ProvinceData.update(i,"Owned",true)
				for j=1,#cur.Adjacment do
					local cur2=cur.Adjacment[j]
					LocalData["Province_"..cur2]=Data["Province_"..cur2]
				end
			end
		end
		print(LocalData)
		return LocalData
	end
	return Data[attribute][data]
end

return ProvinceData
