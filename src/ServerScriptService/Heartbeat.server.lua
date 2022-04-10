local ProvinceDataModule=require(script.parent.ProvinceData)
local RS=game:GetService('ReplicatedStorage')
local SS=game:GetService('ServerStorage')
local RF=RS.ClientDataGrabber
local RF2=RS.ClientDataUpdate

--redundant
function strToTable(list) --turns a string into a table
	local out = {}
	for entry in string.gmatch(list, "[^,]+") do
		table.insert(out, tonumber(entry))
	end
	return out
end

--creates a table for a client when invoked, this is not the final function
RF.OnServerInvoke = (function(player)
	local Data=ProvinceDataModule.Data
	local LocalData={}
	for i,cur in pairs(Data) do
		if cur.Team==player.TeamColor then
			LocalData[i]=cur
			ProvinceDataModule.update(i,"Owned",true)
			for j=1,#cur.Adjacment do
				local cur2=cur.Adjacment[j]
				LocalData["Province_"..cur2]=Data["Province_"..cur2]
			end
		end
	end
	return LocalData
end)


RF2.OnServerInvoke = (function(player,province,attribute,change)
	ProvinceDataModule.update(province,attribute,change)
end)