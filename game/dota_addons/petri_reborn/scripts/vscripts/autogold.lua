function GameMode:RegisterAutoGold( )
	for i=1,5 do
		Timers:CreateTimer(GameRules.AUTO_GOLD_TIMINGS[i] * 60, function (  )
		    for playerID = 0, DOTA_MAX_PLAYERS do
		      	if PlayerResource:IsValidPlayerID(playerID) then
		        	if not PlayerResource:IsBroadcaster(playerID) then
	          			if GameMode.assignedPlayerHeroes[playerID] then
	          				local hero = GameMode.assignedPlayerHeroes[playerID]
	          				local offset = GameRules.PETRI_AUTO_GOLD[i]

			          		if PlayerResource:GetTeam(playerID) == DOTA_TEAM_BADGUYS then
			          			offset = GameRules.PETRI_AUTO_GOLD[i]
			          		end
			          		if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
			          			offset = GameRules.KVN_AUTO_GOLD[i]
		          			end

		          			if hero.allEarnedGold and hero.allEarnedGold < offset then
		          				AddCustomGold( playerID, offset - hero.allEarnedGold )
		          			end
	          			end
		        	end
		      	end
		    end
		end)
	end
end

function GiveSharedGoldToHeroes(gold, heroName)
  	for playerID = 0, DOTA_MAX_PLAYERS do
      	local hero = GameMode.assignedPlayerHeroes[playerID] 
      	if hero and hero:GetUnitName() == heroName then
        	AddCustomGold( playerID, gold )
        	PopupParticle(gold, Vector(244,201,23), 3.0, hero)
      	end
    end
end

function GiveSharedGoldToTeam(gold, team)
	for playerID = 0, DOTA_MAX_PLAYERS do
      	if PlayerResource:IsValidPlayerID(playerID) then
        	if not PlayerResource:IsBroadcaster(playerID) then
          		if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
            		if PlayerResource:GetTeam(playerID) == team then
				      	local hero = GameMode.assignedPlayerHeroes[playerID] 
				      	if IsValidEntity(hero) == true then
				        	AddCustomGold( playerID, gold )

				        	PopupParticle(gold, Vector(244,201,23), 3.0, hero)
				      	end
            		end
          		end
        	end
      	end
    end
end

function AddCustomGold( pID, gold )
	local hero = GameMode.assignedPlayerHeroes[pID]

	if hero then
		local gold = math.floor(gold)

		hero._customGold = hero._customGold or 0

		hero.allEarnedGold = hero.allEarnedGold or 0
		hero.allEarnedGold = hero.allEarnedGold + gold

		if hero.allEarnedGold >= 100000 and not GameMode.FIRST_MONEY then
		  GameMode.FIRST_MONEY = math.floor(GameMode.PETRI_TRUE_TIME)
		end

		hero._customGold = hero._customGold + gold
	end
end

function SpendCustomGold( pID, gold )
	local hero = GameMode.assignedPlayerHeroes[pID]

	if hero then
		hero._customGold = hero._customGold or 0

		if hero._customGold - gold < 0 then
			return false 
		end
		
		hero._customGold = math.max(0, hero._customGold - gold)

		return true
	end
end

function GetCustomGold( pID )
	local hero = GameMode.assignedPlayerHeroes[pID]

	if hero then
		hero._customGold = hero._customGold or 0
		return hero._customGold
	end

	return 0
end

function SetCustomGold( pID, gold )
	local hero = GameMode.assignedPlayerHeroes[pID]

	if hero then
		hero._customGold = gold
		return gold
	end
end