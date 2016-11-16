function GameMode:LumberCommand()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      GameMode.assignedPlayerHeroes[playerID].lumber = GameMode.assignedPlayerHeroes[playerID].lumber + 15000000
    end
  end
end

function GameMode:LumberAndGoldCommand()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      GameMode.assignedPlayerHeroes[playerID].lumber = GameMode.assignedPlayerHeroes[playerID].lumber + 15000000
      AddCustomGold( playerID, 999999 )
    end
  end
end

function GameMode:TestAdditionalExitGold()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      Timers:CreateTimer(GameMode.PETRI_ADDITIONAL_EXIT_GOLD_TIME, 
        function() 
          GameMode.PETRI_ADDITIONAL_EXIT_GOLD_GIVEN = true
          GiveSharedGoldToHeroes(GameMode.PETRI_ADDITIONAL_EXIT_GOLD, "npc_dota_hero_brewmaster")
          GiveSharedGoldToHeroes(GameMode.PETRI_ADDITIONAL_EXIT_GOLD, "npc_dota_hero_death_prophet")
          Notifications:TopToAll({text="#additional_exit_gold", duration=5, style={color="white"}, continue=false})
        end)
    end
  end
end

function GameMode:TestStaticPopup()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      PopupStaticParticle(6, Vector(255,255,255), GameMode.assignedPlayerHeroes[playerID])
    end
  end
end

function GameMode:GetGold()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      print(GameMode.assignedPlayerHeroes[playerID].allEarnedGold)
    end
  end
end

function GameMode:DontEndGame(  )
  GameMode.PETRI_NO_END = true
end