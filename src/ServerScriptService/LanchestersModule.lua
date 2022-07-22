--work in progress

function Lanchesters(Province1,Province2)
	local AttackerTroops, DefenderTroops=Province1.Value,Province2.Value
	local AttackerArtillery=1
	local DefenderFort=1	
	print("works!")
	if Province1.HasArtillery==true then AttackerArtillery=2 end
	if Province2.HasFort==true then DefenderFort=2 end
	
	while DefenderTroops>0 do
		local Alpha=math.random(100,115)/100*AttackerArtillery --attacking forces for Alpha
		local Beta=math.random(100,115)/100*DefenderFort --attacking forces for Beta
		
		local ForceAttacker=math.round(AttackerTroops/(100 * Alpha))
		local ForceDefender=math.round(DefenderTroops/(100 * Beta))
		
		AttackerTroops=AttackerTroops-ForceDefender
		DefenderTroops=DefenderTroops-ForceAttacker
		
		if DefenderTroops<0 then DefenderTroops=0 elseif AttackerTroops<0 then AttackerTroops=0 end
		print(AttackerTroops,DefenderTroops)
		wait(0.1)
    end
    return AttackerTroops,DefenderTroops
end


return Lanchesters
