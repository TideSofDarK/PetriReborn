PETRI_FIRST_LOTTERY_TIME = 12
PETRI_LOTTERY_DURATION = 3
PETRI_LOTTERY_TIME = 10

LOTTERY_STATE = LOTTERY_STATE or 0

GameMode.CURRENT_BANK = GameMode.CURRENT_BANK or 0
DEFAULT_BANK_RATE = 100
PLAY_COUNT = 0

function InitLottery()
	LOTTERY_STATE = 1

	GameMode.CURRENT_BANK = DEFAULT_BANK_RATE * (PLAY_COUNT+1)

	Timers:CreateTimer((PETRI_LOTTERY_DURATION * 60) - 3,
      function()
        Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#pre_win_lottery", duration=7, continue=false, style={color="white", ["font-size"]="45px"}})
      	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text=" "..tostring(3), duration=7, continue=true, style={color="red", ["font-size"]="45px"}})
      end)

	Timers:CreateTimer((PETRI_LOTTERY_DURATION * 60) - 2,
      function()
        Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#pre_win_lottery", duration=7, continue=false, style={color="white", ["font-size"]="45px"}})
      	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text=" "..tostring(2), duration=7, continue=true, style={color="red", ["font-size"]="50px"}})
      end)

	Timers:CreateTimer((PETRI_LOTTERY_DURATION * 60) - 1,
      function()
        Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#pre_win_lottery", duration=7, continue=false, style={color="white", ["font-size"]="45px"}})
      	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text=" "..tostring(1), duration=7, continue=true, style={color="red", ["font-size"]="55px"}})
      end)

	Timers:CreateTimer((PETRI_LOTTERY_DURATION * 60),
      function()
        SelectWinner()
      end)

	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#init_lottery", duration=7, style={color="white", ["font-size"]="45px"}})
end

function SelectWinner()
	if PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) == 0 then return false end
	local winner = GetRandomAliveKvnFan()

	GameMode.assignedPlayerHeroes[winner]:ModifyGold(GameMode.CURRENT_BANK, false, 0)

	Notifications:ClearTopFromTeam(DOTA_TEAM_GOODGUYS)

	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#win_lottery_1", 								duration=7, continue=false, style={color="white", ["font-size"]="45px"}})
	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text=winner.." ", 	duration=7, continue=true, 	style={color="rgb("..PLAYER_COLORS[winner][1]..", "..PLAYER_COLORS[winner][2]..", "..PLAYER_COLORS[winner][3]..")", ["font-size"]="45px"}})
	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#win_lottery_2", 								duration=7, continue=true,  style={color="white", ["font-size"]="45px"}})
	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text=" "..tostring(GameMode.CURRENT_BANK).."$", 				duration=7, continue=true, 	style={color="yellow", ["font-size"]="45px"}})

	LOTTERY_STATE = 0
	GameMode.CURRENT_BANK = 0
	PLAY_COUNT = PLAY_COUNT + 1
end

function GetRandomAliveKvnFan()
	local kvnCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)

	local winner = math.random(1, kvnCount)

	if GameMode.assignedPlayerHeroes[PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner)]:IsAlive() then return PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, winner) end
	return GetRandomAliveKvnFan()
end