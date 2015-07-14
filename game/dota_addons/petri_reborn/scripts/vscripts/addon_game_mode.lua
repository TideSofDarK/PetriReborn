require('internal/util')
require('gamemode')

function Precache( context )
  -- HEROES
  PrecacheUnitByNameSync("npc_dota_hero_rattletrap", context)
  PrecacheUnitByNameSync("npc_dota_hero_brewmaster", context)

  -- UNITS
  PrecacheResource("model", "models/heroes/death_prophet/death_prophet_ghost.vmdl", context)

  PrecacheResource("model", "models/items/dragon_knight/dragon_immortal_1/dragon_immortal_1.vmdl", context)
  PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_ogre_lrg/n_creep_ogre_lrg.vmdl", context)
  PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_melee_mega.vmdl", context)
  PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_melee_diretide/creep_bad_melee_diretide.vmdl", context)
  PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_kobold/kobold_a/n_creep_kobold_a.vmdl", context)
  PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee.vmdl", context)
  PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_melee.vmdl", context)

  PrecacheUnitByNameSync("npc_petri_svetlakov", context)
  PrecacheUnitByNameSync("npc_petri_maslyakov", context)
  PrecacheUnitByNameSync("npc_petri_gusman", context)

  PrecacheUnitByNameSync("npc_peasant", context)

  -- BUILDINGS
  PrecacheResource("model", "models/props_debris/merchant_debris_chest002.vmdl", context)
  PrecacheResource("model", "models/props_rock/riveredge_rock008a.vmdl", context)
  PrecacheResource("model", "models/heroes/oracle/crystal_ball.vmdl", context)
  PrecacheResource("model", "models/props_items/bloodstone.vmdl", context)
  PrecacheResource("model", "models/props_magic/bad_crystals002.vmdl", context)
  PrecacheResource("model", "models/heroes/undying/undying_flesh_golem.vmdl", context)
  PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_golem_a/neutral_creep_golem_a.vmdl", context)
  PrecacheResource("model", "models/items/terrorblade/dotapit_s3_fallen_light_metamorphosis/dotapit_s3_fallen_light_metamorphosis.vmdl", context)
  PrecacheResource("model", "models/items/warlock/golem/obsidian_golem/obsidian_golem.vmdl", context)
  PrecacheResource("model", "models/items/rattletrap/forge_warrior_rocket_cannon/forge_warrior_rocket_cannon.vmdl", context)

  PrecacheResource("model", "models/props_structures/radiant_tower001.vmdl", context)

  PrecacheResource("model", "models/props_structures/tent_dk_small.vmdl", context)
  PrecacheResource("model", "models/props_structures/tent_dk_med.vmdl", context)
  PrecacheResource("model", "models/props_structures/tent_dk_large.vmdl", context)

  PrecacheResource("model", "models/aow/aow.vmdl", context)

  PrecacheUnitByNameSync("npc_petri_sawmill", context)
  PrecacheUnitByNameSync("npc_petri_tower_basic", context)
  PrecacheUnitByNameSync("npc_petri_exploration_tower", context)
  PrecacheUnitByNameSync("npc_petri_gold_bag", context)
  
  -- PARTICLES
  PrecacheResource("particle_folder", "particles/buildinghelper", context)
  PrecacheResource("particle", "particles/econ/events/nexon_hero_compendium_2014/teleport_end_ground_flash_nexon_hero_cp_2014.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_mirana/mirana_base_attack.vpcf", context)

  PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_ready.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf", context)
end

function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:InitGameMode()
end