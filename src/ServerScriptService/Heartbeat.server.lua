local ProvinceDataModule=require(script.parent.ProvinceData)
local LanchestersModule=require(script.parent.LanchestersModule)
local DijkstraModule=require(script.parent.DijkstraModule)
local RS=game:GetService('ReplicatedStorage')
local SS=game:GetService('ServerStorage')
local RF=RS.ClientDataGrabber
local RF2=RS.ClientDataUpdate
local RF3=RS.CombatFunction
local RF4=RS.DijkstraFunction

--redundant
function strToTable(list) --turns a string into a table
	local out = {}
	for entry in string.gmatch(list, "[^,]+") do
		table.insert(out, tonumber(entry))
	end
	return out
end


RF3.OnServerInvoke = (function(player,p1,p2)
	return LanchestersModule(p1,p2)
end)


--creates a table for a client when invoked, this is not the final function
RF.OnServerInvoke = (function(player,provinceName,index)
	local Data=ProvinceDataModule.Data
	local LocalData={}
	if index==nil then
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
	end
	print(provinceName,index)
	return Data[provinceName][index]
end)


RF2.OnServerInvoke = (function(player,province,attribute,change)
	ProvinceDataModule.update(province,attribute,change)
end)

RF4.OnServerInvoke = (function(player,province1,province2)
	return DijkstraModule(province1,province2)
end)