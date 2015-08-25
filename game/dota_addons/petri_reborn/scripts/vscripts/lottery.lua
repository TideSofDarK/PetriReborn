PETRI_FIRST_LOTTERY_TIME = 12
PETRI_LOTTERY_DURATION = 3
PETRI_LOTTERY_TIME = 10

GameMode.LOTTERY_STATE = GameMode.LOTTERY_STATE or 0

GameMode.CURRENT_BANK =  0

GameMode.CURRENT_LOTTERY_PLAYERS = GameMode.CURRENT_LOTTERY_PLAYERS or {}

GameMode.PlAYER_0_BET = 0;
GameMode.PlAYER_1_BET = 0;
GameMode.PlAYER_2_BET = 0;
GameMode.PlAYER_3_BET = 0;
GameMode.PlAYER_4_BET = 0;
GameMode.PlAYER_5_BET = 0;
GameMode.PlAYER_6_BET = 0;
GameMode.PlAYER_7_BET = 0;
GameMode.PlAYER_8_BET = 0;
GameMode.PlAYER_9_BET = 0;
GameMode.PlAYER_10_BET = 0;
GameMode.PlAYER_11_BET = 0;
GameMode.PlAYER_12_BET = 0;
GameMode.PlAYER_13_BET = 0;

DEFAULT_BANK_RATE = 100
PLAY_COUNT = 0

function InitLottery()
	GameMode.LOTTERY_STATE = 1
     
    
	GameMode.CURRENT_BANK = 0

	Timers:CreateTimer((PETRI_LOTTERY_DURATION * 60) - 3,
      function()
        Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#pre_win_lottery", duration=1, continue=false, style={color="white", ["font-size"]="45px"}})
      	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text=" "..tostring(3), duration=1, continue=true, style={color="red", ["font-size"]="45px"}})
      end)

	Timers:CreateTimer((PETRI_LOTTERY_DURATION * 60) - 2,
      function()
        Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#pre_win_lottery", duration=1, continue=false, style={color="white", ["font-size"]="45px"}})
      	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text=" "..tostring(2), duration=1, continue=true, style={color="red", ["font-size"]="50px"}})
      end)

	Timers:CreateTimer((PETRI_LOTTERY_DURATION * 60) - 1,
      function()
        Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#pre_win_lottery", duration=1, continue=false, style={color="white", ["font-size"]="45px"}})
      	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text=" "..tostring(1), duration=1, continue=true, style={color="red", ["font-size"]="55px"}})
      end)

	Timers:CreateTimer((PETRI_LOTTERY_DURATION * 60),
      function()
        SelectWinner()
      end)

	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#init_lottery", duration=7, style={color="white", ["font-size"]="45px"}})
end

function SelectWinner()
    
GameMode.CURRENT_BANK = GameMode.PlAYER_0_BET + GameMode.PlAYER_1_BET + GameMode.PlAYER_2_BET + GameMode.PlAYER_3_BET + GameMode.PlAYER_4_BET + GameMode.PlAYER_5_BET + GameMode.PlAYER_6_BET + GameMode.PlAYER_7_BET + GameMode.PlAYER_8_BET + GameMode.PlAYER_9_BET + GameMode.PlAYER_10_BET + GameMode.PlAYER_11_BET + GameMode.PlAYER_12_BET + GameMode.PlAYER_13_BET
    
    Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#lottery_bank "..tostring(GameMode.CURRENT_BANK), duration=1, continue=false, style={color="red", ["font-size"]="45px"}})  
    
	if PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) == 0 then return false end
    if GameMode.CURRENT_BANK == 0 then Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#no_money_lottery",duration=9, continue=false, style={color="white", ["font-size"]="45px"}}) return false end
	local winner = GetRandomAliveKvnFan()
       
    
    Notifications:ClearTopFromTeam(DOTA_TEAM_GOODGUYS)

	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#win_lottery_1", 								duration=9, continue=false, style={color="white", ["font-size"]="45px"}})
	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text=GameMode.PETRI_NAME_LIST[winner].." ", 	duration=9, continue=true, 	style={color="rgb("..PLAYER_COLORS[winner][1]..", "..PLAYER_COLORS[winner][2]..", "..PLAYER_COLORS[winner][3]..")", ["font-size"]="50px"}})
	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#win_lottery_2", 								duration=9, continue=true,  style={color="white", ["font-size"]="45px"}})
	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text=" "..tostring(math.floor((GameMode.CURRENT_BANK/3)*2)).."$", 				duration=9, continue=true, 	style={color="yellow", ["font-size"]="45px"}})
	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#win_lottery_3", 				duration=9, continue=false, 	style={color="white", ["font-size"]="40px"}})
	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text=tostring(math.floor(GameMode.CURRENT_BANK/5)).."$", 				duration=9, continue=true, 	style={color="yellow", ["font-size"]="40px"}})

	GameMode.assignedPlayerHeroes[winner]:ModifyGold(math.floor((GameMode.CURRENT_BANK/3)*2), false, 0)

	for k,v in pairs(GameMode.CURRENT_LOTTERY_PLAYERS) do
		if v and v ~= winner and PlayerResource:GetTeam(v) == DOTA_TEAM_GOODGUYS then
			GameMode.assignedPlayerHeroes[v]:ModifyGold(GameMode.CURRENT_BANK/5, false, 0)
		end
	end

	GameMode.CURRENT_LOTTERY_PLAYERS = {}
	GameMode.LOTTERY_STATE = 0
	GameMode.CURRENT_BANK = 0
    GameMode.PlAYER_0_BET = 0
    GameMode.PlAYER_1_BET = 0
    GameMode.PlAYER_2_BET = 0
    GameMode.PlAYER_3_BET = 0
    GameMode.PlAYER_4_BET = 0
    GameMode.PlAYER_5_BET = 0
    GameMode.PlAYER_6_BET = 0
    GameMode.PlAYER_7_BET = 0
    GameMode.PlAYER_8_BET = 0
    GameMode.PlAYER_9_BET = 0
    GameMode.PlAYER_10_BET = 0
    GameMode.PlAYER_11_BET = 0
    GameMode.PlAYER_12_BET = 0
    GameMode.PlAYER_13_BET = 0
	PLAY_COUNT = PLAY_COUNT + 1
end

function GetRandomAliveKvnFan()
	local kvnCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)

	local winner = math.random(1, kvnCount)

    if winner == 1 
        and GameMode.PlAYER_0_BET ~= 0 
        and GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)]:IsAlive() 
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 4
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 3 then return PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner) end
	
     if winner == 2 
        and GameMode.PlAYER_1_BET ~= 0 
        and GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)]:IsAlive() 
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 4
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 3 then return PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner) end
    
     if winner == 3 
        and GameMode.PlAYER_2_BET ~= 0 
        and GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)]:IsAlive() 
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 4
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 3 then return PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner) end
    
    
     if winner == 4 
        and GameMode.PlAYER_3_BET ~= 0 
        and GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)]:IsAlive() 
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 4
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 3 then return PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner) end
    
     if winner == 5 
        and GameMode.PlAYER_4_BET ~= 0 
        and GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)]:IsAlive() 
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 4
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 3 then return PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner) end
    
     if winner == 6 
        and GameMode.PlAYER_5_BET ~= 0 
        and GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)]:IsAlive() 
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 4
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 3 then return PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner) end
    
     if winner == 7 
        and GameMode.PlAYER_6_BET ~= 0 
        and GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)]:IsAlive() 
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 4
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 3 then return PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner) end
    
     if winner == 8 
        and GameMode.PlAYER_7_BET ~= 0 
        and GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)]:IsAlive() 
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 4
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 3 then return PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner) end
    
     if winner == 9 
        and GameMode.PlAYER_8_BET ~= 0 
        and GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)]:IsAlive() 
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 4
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 3 then return PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner) end
    
     if winner == 10 
        and GameMode.PlAYER_9_BET ~= 0 
        and GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)]:IsAlive() 
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 4
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 3 then return PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner) end
    
     if winner == 11
        and GameMode.PlAYER_10_BET ~= 0 
        and GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)]:IsAlive() 
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 4
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 3 then return PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner) end
    
     if winner == 12
        and GameMode.PlAYER_11_BET ~= 0 
        and GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)]:IsAlive() 
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 4
		and PlayerResource:GetConnectionState(PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)) ~= 3 then return PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner) end
    
    return GetRandomAliveKvnFan()
end