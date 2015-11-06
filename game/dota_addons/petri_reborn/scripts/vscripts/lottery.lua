PETRI_FIRST_LOTTERY_TIME = 12
PETRI_LOTTERY_DURATION = 2
PETRI_LOTTERY_TIME = 10

GameMode.LOTTERY_STATE = GameMode.LOTTERY_STATE or 0

GameMode.CURRENT_BANK = GameMode.CURRENT_BANK or 0

GameMode.CURRENT_LOTTERY_PLAYERS = GameMode.CURRENT_LOTTERY_PLAYERS or {}

LOTTERY_START_TIME = 0
DEFAULT_BANK_RATE = 500
PLAY_COUNT = 0

function InitLottery()
	GameMode.LOTTERY_STATE = 1

	GameMode.CURRENT_BANK = DEFAULT_BANK_RATE * (PLAY_COUNT+1)

	LOTTERY_START_TIME = GameRules:GetDOTATime(false, false) 

	CustomGameEventManager:Send_ServerToAllClients("petri_start_exchange", {["exchange_time"] = PETRI_LOTTERY_DURATION * 60} )

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
	if PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) == 0 then return false end

	local options = {}
	for i=1,4 do
		options[i] = 0
	end

	for k,v in pairs(GameMode.CURRENT_LOTTERY_PLAYERS) do
		local pID = tonumber(k)
		local bet = v["bet"]
		local option = v["option"]

		options[option] = options[option] or 0
		options[option] = options[option] + 1
	end

	local key, min = 9999, options[1]
	for k, v in ipairs(options) do
	    if options[k] < min then
	        key, min = k, v
	    end
	end

	local winner = key
	
	CustomGameEventManager:Send_ServerToAllClients("petri_finish_exchange", {["winner"] = winner + 1} )

	for k,v in pairs(GameMode.CURRENT_LOTTERY_PLAYERS) do
		local pID = tonumber(k)
		local prize
		if v["option"] == winner then
			prize = math.min(math.floor(v["bet"] * 1.7) + math.floor(GameMode.CURRENT_BANK * 0.2), math.floor(v["bet"] * 5))
			GameMode.assignedPlayerHeroes[pID]:ModifyGold(prize, false, 0)
			Notifications:Top(pID, {text="#win_lottery_1", duration=9, continue=false, style={color="white", ["font-size"]="45px"}})
			Notifications:Top(pID, {text=tostring(prize).."$", duration=9, continue=true, style={color="white", ["font-size"]="45px"}})
		else
			prize = math.min(math.floor(v["bet"] * 0.7) + math.floor(GameMode.CURRENT_BANK * 0.1), math.floor(v["bet"] * 3))
			GameMode.assignedPlayerHeroes[pID]:ModifyGold(prize, false, 0)
			Notifications:Top(pID, {text="#lose_lottery_1", duration=4, continue=false, style={color="white", ["font-size"]="45px"}})
			Notifications:Top(pID, {text=tostring(prize).."$", duration=9, continue=true, style={color="white", ["font-size"]="45px"}})
		end
	end

	GameMode.CURRENT_LOTTERY_PLAYERS = {}
	GameMode.LOTTERY_STATE = 0
	GameMode.CURRENT_BANK = 0
	PLAY_COUNT = PLAY_COUNT + 1
end