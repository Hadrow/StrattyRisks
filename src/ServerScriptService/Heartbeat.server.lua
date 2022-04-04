local RS=game:GetService('ReplicatedStorage')
local SS=game:GetService('ServerStorage')
local RF=RS.RemoteFunction

function strToTable(list) --turns a string into a table
	local out = {}
	for entry in string.gmatch(list, "[^,]+") do
		table.insert(out, tonumber(entry))
	end
	return out
end

RF.OnServerInvoke = (function(player)
	local LocalData={}
	for i,cur in pairs(_G.ProvinceData) do
		if cur.Team==player.TeamColor then
			LocalData[i]=cur
			for j=1,#cur.Adjacment do
				local cur2=cur.Adjacment[j]
				LocalData["Province_"..cur2]=_G.ProvinceData["Province_"..cur2]
			end
		end
	end
	return LocalData
end)