KickSystem = {}
KickSystem.votes = {}

function KickSystem:StartVoteKick( args )
	print("Start vote kick")
	local playerID = args["KickPlayerID"]
	local teamID = PlayerResource:GetPlayer(playerID):GetTeamNumber()

	local initiator = args["VoteInitiator"]

	if PlayerResource:GetTeam(initiator) == DOTA_TEAM_BADGUYS then
		if GameMode.assignedPlayerHeroes[initiator]:GetUnitName() ~= "npc_dota_hero_storm_spirit" then
			if GameMode.assignedPlayerHeroes[playerID]:GetUnitName() == "npc_dota_hero_storm_spirit" then
				GameMode.assignedPlayerHeroes[playerID]:AddAbility("petri_suicide")
				InitAbilities(GameMode.assignedPlayerHeroes[playerID])
				GameMode.assignedPlayerHeroes[playerID]:CastAbilityImmediately(GameMode.assignedPlayerHeroes[playerID]:FindAbilityByName("petri_suicide"), playerID)

				Timers:CreateTimer(1.0, function (  )
					UTIL_Remove(GameMode.assignedPlayerHeroes[playerID])

					Notifications:Top(playerID,{text="BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED BANNED", duration=99999, style={color="red"}, continue=false})
				end)

				--SendToServerConsole("kick " .. PlayerResource:GetPlayerName(playerID))
				return true
			end
		end
	end

	CustomGameEventManager:Send_ServerToTeam(teamID, "petri_vote_kick", {["KickPlayerID"] = playerID, ["VoteInitiator"] = args["VoteInitiator"]} )
	KickSystem.votes[ playerID ] = 1;

	-- Check vote after 11 seconds
	Timers:CreateTimer(11.0, 
		function() 
		  KickSystem:VoteResult( playerID )
		end);
end

-- Votes count
function KickSystem:VoteKickAgree( args )
  KickSystem.votes[ args["KickPlayerID"] ] = KickSystem.votes[ args["KickPlayerID"] ] + 1;
end

function KickSystem:VoteKickDisagree( args )
  KickSystem.votes[ args["KickPlayerID"] ] = KickSystem.votes[ args["KickPlayerID"] ] - 1;
end

-- Check vote
function KickSystem:VoteResult( playerID )
	if KickSystem.votes[ playerID ] > 1 then
		SendToServerConsole("kick " .. PlayerResource:GetPlayerName(playerID))
	end

	KickSystem.votes[ playerID ] = 0;
end