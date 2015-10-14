KickSystem = {}
KickSystem.votes = {}

function KickSystem:StartVoteKick( args )
	print("Start vote kick")
	local playerID = args["KickPlayerID"]
	local teamID = PlayerResource:GetPlayer(playerID):GetTeamNumber()

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