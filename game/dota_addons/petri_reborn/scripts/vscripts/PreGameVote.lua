--ListenToGameEvent("dota_player_gained_level", OnPlayerAbandon, nil)
print( "Starting VOTING.LUA" )
VoteNS = {}
CustomGameEventManager:RegisterListener( "event_pregame_vote",   Dynamic_Wrap(VoteNS, "OnPreGameVote_event"  ) )
PlayerCount = 24 --сколько игроков может быть максимум
VotedPlayers ={} --кто проголосовал
	PlayerVotes = {} --кто за что проголосовал
	--PlayerVotes["ExitDelay"] = {} 
	--PlayerVotes["GameDuration"] = {}
	--for i=0, PlayerCount do
	--	PlayerVotes["ExitDelay"][i] = -1
	--end
	--for j=0, PlayerCount do
	--	PlayerVotes["GameDuration"][j] = -1
	--end
	
function IsIn(item,array)
	for key,value in pairs(array) do
		if value == item then
			return true
		end
	end
	return false
end

function  VoteNS:OnPreGameVote_event( args ) --WAT , eventSourceIndex
	print( "Vote recieved" )
		print( print_r(args,6) )
	print( "Vote recieved2" )
	PlayerID=args['PlayerID']
	if( IsIn(PlayerID,VotedPlayers) == false ) then
		VotedPlayers[#VotedPlayers+1] = PlayerID
		print( "Players count=" .. PlayerResource:GetPlayerCount() )
		--print( "My event:" .. args['PlayerID'] .. " ( Exit delay:" .. args['ExitDelay'] .. ", Game duration:" .. args['GameDuration'] .. " )" )
		for key, value in pairs( args ) do
			if ( key ~= 'PlayerID' ) then
				if ( PlayerVotes[key] == nil ) then
					PlayerVotes[key] = {}
						print( "added PlayerVotes element '"..key.."'" )
				end
				if ( PlayerVotes[key][PlayerID] == nil ) then
					for i=0, PlayerCount do
						PlayerVotes[key][i] = -1
					end
				end
				PlayerVotes[key][PlayerID] = value
				print("Added vote "..key..' = '..PlayerVotes[key][PlayerID]..' by player '..PlayerID)
				--print("Added vote " .. key .. " = " .. value .. " by player " .. PlayerID)
			end
		end
		--PlayerVotes["ExitDelay"][PlayerID]=args['ExitDelay']
		--PlayerVotes["GameDuration"][PlayerID]=args['GameDuration']
		--если это был последний не проголосовавший игрок-заканчиваем голосование
		if #VotedPlayers == PlayerResource:GetPlayerCount() then
			print("All players have voted, closing poll")
			PreGameVote_end()
		end
	else
		print( "This player has already voted! Ignoring vote attempt" )
	end
end


function CalcVotes(VoteName)
	votes = {}
	maxItems=4 -- Заменить значение на максимальное кол-во вариантов голоса 
	for i=0, maxItems do
		votes[i]=0
	end
	--Суммируем, сколько за конкретный вариант проголосовало людей
	for i=0, PlayerCount do
		thisVote=PlayerVotes[VoteName][i]
		if thisVote ~= -1 then
			if votes[thisVote] ~= nil then
				votes[thisVote] = votes[thisVote] + 1
			else
				votes[thisVote] = 1
			end
		end
	end
	
	-- Выясняем за кого проголосовало больше всех
	maxValue=votes[0]
	maxId={0}
	maxCount=1
	for key,value in pairs(votes) do
		if value > maxValue then
				maxValue=value
				maxId={key}
				maxCount=1
		elseif value == maxValue then
			maxId[#maxId+1]=key
		end
	end
	
	--выбираем победителя из списка вариантов с максимальным кол-вом голосов
	return maxId[ math.random( #maxId ) ]
end

function PreGameVote_start()
	print("Starting Pregame Vote")
	local event_data =
	{
		visible = true,
	}
	CustomGameEventManager:Send_ServerToAllClients( "PreGameVote_start_event", event_data )
	
end

function PreGameVote_end()
	local event_data =
	{
		--ExitDelay = CalcVotes("ExitDelay"),
		--GameDuration = CalcVotes("GameDuration"),
	}
	for VoteID, value in pairs( PlayerVotes ) do
		print('Adding to event_data:'.. VoteID ..'('.. CalcVotes(VoteID) ..')')
		event_data[VoteID]=CalcVotes(VoteID)
	end
	CustomGameEventManager:Send_ServerToAllClients( "PreGameVote_end_event", event_data )
	--local votes_data =
	--{
	--	ExitDelay = CalcVotes("ExitDelay"),
	--	GameDuration = CalcVotes("GameDuration"),
	--}
	PreGameVote_results(event_data) -- !!!!!!!! Эту функцию надо принимать в основной луашке, которая делает что-либо с результатами
	ExitDelay_result = CalcVotes("ExitDelay")
	GameDuration_result = CalcVotes("GameDuration")
	--print("Exit delay winner is " .. ExitDelay_result )
	--print("Game Duration winner is " .. GameDuration_result )
end


function print_r(arr, indentLevel)
    local str = ""
    local indentStr = "#"

    if(indentLevel == nil) then
        print(print_r(arr, 0))
        return
    end

    for i = 0, indentLevel do
        indentStr = indentStr.."\t"
    end

    for index,value in pairs(arr) do
        if type(value) == "table" then
            str = str..indentStr..index..": \n"..print_r(value, (indentLevel + 1))
        else 
            str = str..indentStr..index..": "..value.."\n"
        end
    end
    return str
end