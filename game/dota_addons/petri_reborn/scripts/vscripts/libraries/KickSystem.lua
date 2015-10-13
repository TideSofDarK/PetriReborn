KickSystem = {}
KickSystem.votes = {}

function KickSystem:StartVoteKick( args )
	print("Start vote kick")
	local playerID = args["KickPlayerID"]
	local teamID = PlayerResource:GetPlayer(playerID):GetTeamNumber()

	local allHeroes = HeroList:GetAllHeroes()
		for _, v in pairs( allHeroes ) do
			local curPlayerID = v:GetPlayerID()
			if curPlayerID then
				if curPlayerID ~= playerID and curPlayerID ~= args["PlayerID"] and PlayerResource:GetPlayer(curPlayerID):GetTeamNumber() == teamID then
					CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(curPlayerID), "petri_vote_kick", {["KickPlayerID"] = playerID } )
			end
		end
	end

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