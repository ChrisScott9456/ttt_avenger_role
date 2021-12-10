if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_avenge.vmt")
end

function ROLE:PreInitialize()
	self.color = Color(40, 30, 30, 255)

	self.abbr = "avenge"
	self.survivebonus = 1                   	-- points for surviving longer
	self.preventFindCredits = true	        	-- can't take credits from bodies
	self.preventKillCredits = true          	-- does not get awarded credits for kills
	self.preventWin = true                  	-- cannot win unless he switches roles
	self.score.killsMultiplier = 2          	-- gets points for killing enemies of their team
	self.score.teamKillsMultiplier = -8     	-- loses points for killing teammates

	self.defaultTeam = TEAM_NONE 				-- starts as Neutral Team
	self.defaultEquipment = SPECIAL_EQUIPMENT

	self.conVarData = {
		pct = 0.17, 							-- necessary: percentage of getting this role selected (per player)
		maximum = 1, 							-- maximum amount of roles in a round
		minPlayers = 6, 						-- minimum amount of players until this role is able to get selected
		credits = 2, 							-- the starting credits of a specific role
		togglable = true, 						-- option to toggle a role for a client if possible (F1 menu)
		random = 20,							-- what percentage chance the role will show up each round
		shopFallback = SHOP_FALLBACK_TRAITOR	-- the fallback shop for the role to use
	}
end

function ROLE:Initialize()

end

if SERVER then
	-- Set the killer's entity on the victim for the Avenger to target
	hook.Add('TTT2PostPlayerDeath', 'TTT2AvengerSetCorpseKiller', function(victim, _, attacker)
		victim:SetNWEntity('ttt2_avenger_killer', attacker)
	end)

	-- Give the Avenger their target
	hook.Add('TTTCanSearchCorpse', 'TTT2AvengerCorpseTarget', function(idPlayer, rag, isCovert, isLongRange)
		local victim = player.GetBySteamID64(rag.sid64)
		local killer = victim:GetNWEntity('ttt2_avenger_killer')

		-- If the identifying player is an Avenger, give them a target
		if idPlayer:GetSubRole() == ROLE_AVENGER then
			if victim != killer 
			and killer:Alive() 
			and idPlayer !== killer then
				idPlayer:PrintMessage(HUD_PRINTTALK, 'Avenger target acquired: ' .. killer:GetName())
				
				-- Set the Avenger's team to convert to and target
				idPlayer:SetNWEntity('ttt2_avenger_convert_team', victim:GetTeam())
				idPlayer:SetNWEntity('ttt2_avenger_target', killer)
			end
			return true
		end
	end)

	-- Set the Avenger to the team of the person they successfully avenge
	hook.Add('TTT2PostPlayerDeath', 'TTT2AvengerConvertTeam', function(victim, _, attacker)
		if victim == attacker:GetNWEntity('ttt2_avenger_target') then
			attacker:SetNWEntity('ttt2_avenger_target', nil) -- Remove the target from the Avenger

			attacker:UpdateTeam(attacker:GetNWEntity('ttt2_avenger_convert_team'))
		end
	end)
end
