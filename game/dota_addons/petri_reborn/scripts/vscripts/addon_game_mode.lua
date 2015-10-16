require('internal/util')
require('gamemode')

function Precache( context )
  PrecacheUnitByNameSync("npc_dota_hero_storm_spirit", context)
  
  -- ITEMS
  PrecacheItemByNameSync("item_petri_pile_of_wood", context)
  PrecacheItemByNameSync("item_petri_gold_coin", context)
  PrecacheItemByNameSync("item_petri_boots", context)
  PrecacheItemByNameSync("item_petri_hook", context)
  PrecacheItemByNameSync("item_petri_alcohol", context)
  
  PrecacheResource("model", "models/props_gameplay/red_box.vmdl", context)
  PrecacheResource("model", "models/heroes/techies/fx_techiesfx_stasis.vmdl", context)

  -- HEROES
  PrecacheResource("model_folder", "models/heroes/death_prophet", context)
  PrecacheResource("model_folder", "models/heroes/rattletrap", context)
  PrecacheResource("model_folder", "models/heroes/brewmaster", context)
  PrecacheResource("model_folder", "models/heroes/storm_spirit", context)

  -- UNITS
  PrecacheResource("model", "models/items/rattletrap/cog_tesla/cog_tesla.vmdl", context)

  PrecacheResource("model", "models/items/courier/dokkaebi_nexon_courier/dokkaebi_nexon_courier.vmdl", context)

  PrecacheResource("model", "models/heroes/terrorblade/terrorblade_arcana.vmdl", context)
  PrecacheResource("model", "models/heroes/doom/doom.vmdl", context)

  PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_ghost_a/n_creep_ghost_a.vmdl", context)

  PrecacheResource("model", "models/props_structures/tower_dragon_white.vmdl", context)
  PrecacheResource("model", "models/items/dragon_knight/fireborn_dragon/fireborn_dragon.vmdl", context)
  PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_ogre_lrg/n_creep_ogre_lrg.vmdl", context)
  PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_melee_mega.vmdl", context)
  PrecacheResource("model", "models/items/undying/idol_of_ruination/ruin_wight_minion_gold.vmdl", context)
  PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_kobold/kobold_a/n_creep_kobold_a.vmdl", context)
  PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee.vmdl", context)
  PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_melee.vmdl", context)

  PrecacheUnitByNameSync("npc_petri_svetlakov", context)
  PrecacheUnitByNameSync("npc_petri_maslyakov", context)
  PrecacheUnitByNameSync("npc_petri_gusman", context)

  PrecacheUnitByNameSync("npc_petri_peasant", context)
  PrecacheUnitByNameSync("npc_petri_super_peasant", context)

  -- BUILDINGS
  -- idol
  PrecacheUnitByNameSync("npc_petri_idol", context)

  -- exit
  PrecacheUnitByNameSync("npc_petri_exit", context)

  -- towers
  PrecacheResource("model", "models/props_structures/tower_good3_dest_lvl1.vmdl", context)
  PrecacheResource("model", "models/items/invoker/forge_spirit/infernus/infernus.vmdl", context)
  PrecacheResource("model", "models/heroes/ancient_apparition/ancient_apparition.vmdl", context)
  PrecacheResource("model", "models/heroes/undying/undying_tower.vmdl", context)

  PrecacheResource("model", "models/items/undying/idol_of_ruination/idol_tower.vmdl", context)
  PrecacheResource("model", "models/items/undying/idol_of_ruination/idol_tower_gold.vmdl", context)

  PrecacheUnitByNameSync("npc_petri_tower_of_evil", context)
  
  -- wall
  PrecacheResource("model", "models/items/rattletrap/warmachine_cog_dc/warmachine_cog_dc.vmdl", context)
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
  PrecacheResource("model", "models/creeps/roshan/aegis.vmdl", context)
  PrecacheResource("model", "models/creeps/roshan/roshan.vmdl", context)
  
  -- sawmill
  PrecacheResource("model", "models/props_structures/bad_barracks001_ranged.vmdl", context)
  PrecacheResource("model", "models/props_structures/good_barracks_ranged002_lvl2.vmdl", context)
  PrecacheResource("model", "models/props_structures/good_ancient001.vmdl", context)

  PrecacheResource("model", "models/props_structures/radiant_tower001.vmdl", context)

  PrecacheResource("model", "models/props_structures/tent_dk_small.vmdl", context)
  PrecacheResource("model", "models/props_structures/tent_dk_med.vmdl", context)
  PrecacheResource("model", "models/props_structures/tent_dk_large.vmdl", context)

  PrecacheResource("model", "models/items/wards/eyeofforesight/eyeofforesight.vmdl", context)

  PrecacheUnitByNameSync("npc_petri_sawmill", context)
  PrecacheUnitByNameSync("npc_petri_tower_basic", context)
  PrecacheUnitByNameSync("npc_petri_exploration_tower", context)
  PrecacheUnitByNameSync("npc_petri_gold_bag", context)
  
  -- PARTICLES
  PrecacheResource("particle", "particles/units/heroes/hero_tinker/tinker_laser.vpcf", context)
  
  PrecacheResource("particle", "particles/buildinghelper/ghost_model.vpcf", context)
  PrecacheResource("particle", "particles/buildinghelper/square_sprite.vpcf", context)
  
  PrecacheResource("particle", "particles/econ/events/nexon_hero_compendium_2014/teleport_end_ground_flash_nexon_hero_cp_2014.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_mirana/mirana_base_attack.vpcf", context)

  PrecacheResource("particle", "particles/items_fx/dust_of_appearance.vpcf", context)

  PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_ready.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf", context)

  PrecacheResource("particle", "particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare_explosion_flash_c.vpcf", context)

  PrecacheResource("particle", "particles/generic_gameplay/dropped_item.vpcf", context)

  PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_tornado.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_tornado_child.vpcf", context)
  PrecacheResource("particle", "particles/items_fx/cyclone.vpcf", context)

  PrecacheResource("particle", "particles/items_fx/blademail.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_viper/viper_viper_strike_debuff.vpcf", context)

  PrecacheResource("particle", "particles/units/heroes/hero_meepo/meepo_earthbind.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf", context)

  PrecacheResource("particle", "particles/items_fx/immunity_sphere_buff.vpcf", context)

  -- SOUNDS
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_invoker.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_naga_siren.vsndevts", context)
end

function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:InitGameMode()
end