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

function RandomChange (percent)
  assert(percent >= 0 and percent <= 100) 
  return percent >= math.random(1, 100)
end

function SelectWinner()
	if PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) == 0 then return false end

	local winner = math.random(1,4)

	-- Check for same option
	local sameOption = true
	local option
	for k,v in pairs(GameMode.CURRENT_LOTTERY_PLAYERS) do
		local pID = tonumber(k)
		option = option or v["option"]
		if option ~= v["option"] then 
			sameOption = false
			break
		end
	end

	-- First variant
	if sameOption == true or RandomChange(10) == true then
		for k,v in pairs(GameMode.CURRENT_LOTTERY_PLAYERS) do
			winner = v["option"]
			if RandomChange(13) == true then
				v["prize"] = math.floor(v["bet"] * 0.7)
			elseif RandomChange(17) == true then
				v["prize"] = math.floor(v["bet"] * 1.5)
			elseif RandomChange(30) == true then
				v["prize"] = math.floor(v["bet"] * 0.92)
			else
				v["prize"] = math.floor(v["bet"] * 1.15)
			end
		end
	else -- Second variant
		local allBets = {}
		local allOptions = {}
		local allMoney = 0
		for i=1,4 do
			for k,v in pairs(GameMode.CURRENT_LOTTERY_PLAYERS) do
				if i == v["option"] then 
					allBets[i] = allBets[i] or 0
					allOptions[i] = allOptions[i] or 0

					allBets[i] = allBets[i] + math.floor(v["bet"])
					allOptions[i] = allOptions[i] + 1
					allMoney = allMoney + math.floor(v["bet"])
				end
			end
		end

		local allChances = {}
		local order = {}
		local step = 1
		for i=1,4 do
			if allBets[i] then
				table.insert(allChances, math.floor((allBets[i] / allMoney) * 100))
				order[math.floor((allBets[i] / allMoney) * 100)] = i
			else 
				table.insert(allChances, step + 1)
				order[step + 1] = i
				step = step + 1
			end
		end

		table.sort (allChances)

		for i,v in ipairs(allChances) do
			if RandomChange(v) == true or i == #allChances then
				winner = winner or order[v]

				for k1,v1 in pairs(GameMode.CURRENT_LOTTERY_PLAYERS) do
					if winner == v1["option"] then 
						v1["prize"] = math.min( math.floor((v1["bet"] * allMoney) / allBets[winner]), math.floor(v1["bet"] * (#GameMode.CURRENT_LOTTERY_PLAYERS / allOptions[v1["option"]])))
					else
						v1["prize"] = math.max( math.floor((v1["bet"] / allMoney) * allBets[winner]), math.floor(v1["bet"] * (allOptions[v1["option"]] / #GameMode.CURRENT_LOTTERY_PLAYERS)))
					end
				end

				break
			end
		end
	end
	
	CustomGameEventManager:Send_ServerToAllClients("petri_finish_exchange", {["winner"] = winner - 1} )

	for k,v in pairs(GameMode.CURRENT_LOTTERY_PLAYERS) do
		local pID = tonumber(k)
		local prize = v["prize"]
		local bet = v["bet"]
		if prize > bet then
			GameMode.assignedPlayerHeroes[pID]:ModifyGold(prize, false, 0)
			Notifications:Top(pID, {text="#win_lottery_1", duration=9, continue=false, style={color="white", ["font-size"]="45px"}})
			Notifications:Top(pID, {text=tostring(prize).."$", duration=9, continue=true, style={color="white", ["font-size"]="45px"}})
		else
			GameMode.assignedPlayerHeroes[pID]:ModifyGold(prize, false, 0)
			Notifications:Top(pID, {text="#lose_lottery_1", duration=4, continue=false, style={color="white", ["font-size"]="45px"}})
			Notifications:Top(pID, {text=tostring(prize).."$", duration=9, continue=true, style={color="white", ["font-size"]="45px"}})
		end
		GameMode.assignedPlayerHeroes[pID]:EmitSound("DOTA_Item.Hand_Of_Midas")
	end

	GameMode.CURRENT_LOTTERY_PLAYERS = {}
	GameMode.LOTTERY_STATE = 0
	GameMode.CURRENT_BANK = 0
	PLAY_COUNT = PLAY_COUNT + 1
end