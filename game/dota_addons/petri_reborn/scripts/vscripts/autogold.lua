function GameMode:RegisterAutoGold( )
	for i=1,5 do
		Timers:CreateTimer(GameMode.AUTO_GOLD_TIMINGS[i], function (  )
		    for playerID = 0, DOTA_MAX_PLAYERS do
		      	if PlayerResource:IsValidPlayerID(playerID) then
		        	if not PlayerResource:IsBroadcaster(playerID) then
	          			local hero = GameMode.assignedPlayerHeroes[playerID]

	          			if hero then
	          				local offset = PETRI_AUTO_GOLD[i]

			          		if PlayerResource:GetTeam(playerID) == DOTA_TEAM_BADGUYS then
			          			offset = PETRI_AUTO_GOLD[i]
			          		end
			          		if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
			          			offset = KVN_AUTO_GOLD[i]
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

function GiveSharedGoldToHeroes(gold, hero)
  	for playerID = 0, DOTA_MAX_PLAYERS do
      	if PlayerResource:IsValidPlayerID(playerID) then
        	if not PlayerResource:IsBroadcaster(playerID) then
          		if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
			      	local hero = GameMode.assignedPlayerHeroes[playerID] 
			      	if IsValidEntity(hero) == true and hero:GetUnitName() == hero then
			        	AddCustomGold( playerID, gold )

			        	PopupParticle(gold, Vector(244,201,23), 3.0, hero)
			      	end
          		end
        	end
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
    hero.allEarnedGold = hero.allEarnedGold or 0
    hero.allEarnedGold = hero.allEarnedGold + gold

    if hero.allEarnedGold >= 100000 and not GameMode.FIRST_MONEY then
      GameMode.FIRST_MONEY = math.floor(GameMode.PETRI_TRUE_TIME)
    end

    PlayerResource:ModifyGold(hero:GetPlayerOwnerID(), gold, false, DOTA_ModifyGold_SharedGold)
  end
end