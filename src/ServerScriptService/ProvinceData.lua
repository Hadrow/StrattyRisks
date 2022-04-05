--a module used to handle provinceData(province values, buildings, colors, if owned...) which is not mapData
function ProvinceData()
	local mapData=_G.mapData
	local provinces=workspace.Provinces:GetChildren()
	local adjMatrix=mapData.adjMatrix
	local Province_Data={}
	for i=1,#provinces do
		Province_Data[provinces[i].Name]={}
		local cur=Province_Data[provinces[i].Name]
		cur.Artillery=provinces[i]:GetAttribute('HasArtillery')
		cur.Factory=provinces[i]:GetAttribute('HasFactory')
		cur.Fort=provinces[i]:GetAttribute('HasFort')
		cur.Powerplant=provinces[i]:GetAttribute('HasPowerplant')
		cur.Team=provinces[i]:GetAttribute("Team")
		cur.Owned=provinces[i]:GetAttribute("IsOwned")
		cur.Value=provinces[i]:GetAttribute("Value")
		cur.Adjacment=adjMatrix[i]
	end
	_G.ProvinceData=Province_Data
end

return ProvinceData
