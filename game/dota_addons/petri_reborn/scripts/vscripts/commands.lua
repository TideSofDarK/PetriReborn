function GameMode:SetTime(t)
  if t and tonumber(t) then
    GameMode.PETRI_TRUE_TIME = t * 60
  end
end

function GameMode:TestCommand()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      print(GameMode.assignedPlayerHeroes[playerID]:GetBaseAttackTime(), GameMode.assignedPlayerHeroes[playerID]:GetAttackAnimationPoint())
    end
  end
end

function GameMode:LumberCommand()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      GameMode.assignedPlayerHeroes[playerID].lumber = GameMode.assignedPlayerHeroes[playerID].lumber + 15000000
    end
  end
end

function GameMode:LumberAndGoldCommand(g)
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      GameMode.assignedPlayerHeroes[playerID].lumber = GameMode.assignedPlayerHeroes[playerID].lumber + 15000000
      if g and tonumber(g) then
        AddCustomGold( playerID, tonumber(g) )
      else
        AddCustomGold( playerID, 999999 )
      end
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

function GameMode:FinishGameSetup(g)
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      cmdPlayer:SetTeam(tonumber(g))
      GameRules:FinishCustomGameSetup()

      StartAnimation(cmdPlayer:GetAssignedHero(), {duration=0.5, activity=ACT_DOTA_ATTACK_EVENT_BASH, rate=2.0, translate="basher"})
    end
  end
end