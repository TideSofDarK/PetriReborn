$cd "F:\Users\Grig\Documents"
$modelname "heroes/death_prophet/death_prophet.mdl"
$model "default" "death_prophet_model.dmx.smd"

$lod 1
 {
  replacemodel "death_prophet_model.dmx" "lod1_death_prophet_model.dmx"
}
$poseparameter turn -1.00 1.00
$cdmaterials ""
$hboxset "default"
$hbox 0 "elbow_R" -29.868  -5.269  -4.628  -0.361  3.825  4.919
$hbox 0 "bicep_R" -28.795  -5.565  -8.670  4.695  3.758  4.301
$hbox 0 "elbow_L" 0.361  -3.825  -4.919  28.778  5.269  4.628
$hbox 0 "bicep_L" 1.049  -4.478  -4.301  26.361  5.565  6.482
$hbox 0 "spine2" -9.009  -12.223  -18.209  8.062  12.665  10.771
$hbox 0 "spine1" -23.820  -12.085  -15.808  12.031  12.702  20.091
$hbox 0 "root" -16.201  -15.547  -29.310  18.945  10.825  12.605
$hboxset "hands"
$hbox 0 "wrist_R" -42.055  -18.082  -10.903  -4.255  5.262  8.381
$hbox 0 "wrist_L" 3.891  -5.262  -8.381  42.055  18.082  10.903
$hboxset "head"
$hbox 0 "head" -30.389  -13.692  -5.538  10.477  15.564  30.042
$hboxset "select_high"
$hbox 0 "spine1" -8.314  -18.614  -21.192  48.468  19.232  14.208
$hbox 0 "root" -23.514  -28.252  -85.504  20.170  23.530  7.735
$hboxset "select_low"
$hbox 0 "root" -67.196  -78.081  -108.938  54.378  73.359  77.769
$attachment "attach_attack1" "wrist_R" -40.00 -20.00 -0.00 rotate -0.00 0.00 -0.00
$attachment "Thumb1_plc2_L" "scarf_top_R4C0" 0.60 6.59 13.23 rotate 0.00 -0.00 0.00
$attachment "attach_attack2" "wrist_L" 40.00 20.00 0.00 rotate -0.00 -0.00 -0.00
$attachment "Thumb_plc1_R" "hair_R2C0" 0.00 0.00 -16.02 rotate -0.00 0.00 -0.00
$attachment "attach_head" "head" 0.00 0.00 0.00 rotate 0.00 -0.00 -0.00
$attachment "attach_hitloc" "spine2" 0.00 0.00 0.00 rotate -0.00 -0.00 0.00
$attachment "Thumb1_plc3_R" "scarf_bot_R6C0" -17.24 0.86 1.67 rotate -0.00 0.00 -0.00
$attachment "Thumb_plc0_L" "skirt_R3C0" 0.00 0.00 -16.02 rotate -0.00 0.00 -0.00
$attachment "attach_root" "root" 0.00 0.00 0.00 rotate -0.00 0.00 0.00
$surfaceprop "default"
$keyvalues  {  } 
$illumposition -18.884 -2.361 107.377
$sequence BindPose "BindPose" fps 30.00
$sequence loadout_spawn "loadout_spawn" ACT_DOTA_SPAWN 1 fps 27.00
$sequence loadout_idle "loadout_idle" loop ACT_DOTA_LOADOUT 6 fps 30.00
$sequence loadout_idle_rare "loadout_idle_rare" ACT_DOTA_LOADOUT_RARE 1 fps 30.00
$sequence idle "idle" loop ACT_DOTA_IDLE 6 fps 30.00
$sequence idle_frostivus "idle_frostivus" loop ACT_DOTA_IDLE 6 fps 30.00
$sequence idle_injured_frostivus "idle_injured_frostivus" loop ACT_DOTA_IDLE 6 fps 30.00
$sequence run_frostivus "run_frostivus" loop ACT_DOTA_RUN 1 fps 30.00
$sequence run_injured_frostivus "run_injured_frostivus" loop ACT_DOTA_RUN 1 fps 30.00
$sequence idle_alt1 "idle_alt1" loop ACT_DOTA_IDLE 1 fps 30.00
$sequence idle_alt2 "idle_alt2" loop ACT_DOTA_IDLE 1 fps 30.00
$sequence attack_01 "attack_01" ACT_DOTA_ATTACK 1 fps 30.00 {
  { event AE_DOTA_PLAY_SOUND_ATTACK 17 }
}

$sequence attack_01_injured "attack_01_injured" ACT_DOTA_ATTACK 1 fps 30.00 {
  { event AE_DOTA_PLAY_SOUND_ATTACK 17 }
}

$sequence attack_02 "attack_02" ACT_DOTA_ATTACK2 1 fps 30.00 {
  { event AE_DOTA_PLAY_SOUND_ATTACK 17 }
}

$sequence attack_02_injured "attack_02_injured" ACT_DOTA_ATTACK2 1 fps 30.00 {
  { event AE_DOTA_PLAY_SOUND_ATTACK 17 }
}

$sequence corpseSet_attack_alt01 "corpseSet_attack_alt01" ACT_DOTA_ATTACK 1 fps 30.00 {
  { event AE_DOTA_PLAY_SOUND_ATTACK 17 }
}

$sequence corpseSet_attack_alt01_injured "corpseSet_attack_alt01_injured" ACT_DOTA_ATTACK 1 fps 30.00 {
  { event AE_DOTA_PLAY_SOUND_ATTACK 17 }
}

$sequence corpseSet_attack_alt02 "corpseSet_attack_alt02" ACT_DOTA_ATTACK2 1 fps 30.00 {
  { event AE_DOTA_PLAY_SOUND_ATTACK 17 }
}

$sequence corpseSet_attack_alt02_injured "corpseSet_attack_alt02_injured" ACT_DOTA_ATTACK2 1 fps 30.00 {
  { event AE_DOTA_PLAY_SOUND_ATTACK 17 }
}

$sequence corpseSet_cast1_carrionSwarm "corpseSet_cast1_carrionSwarm" ACT_DOTA_CAST_ABILITY_1 1 fps 30.00
$sequence corpseSet_cast2_silence "corpseSet_cast2_silence" ACT_DOTA_CAST_ABILITY_2 1 fps 30.00
$sequence corpseSet_cast4_exorcism "corpseSet_cast4_exorcism" ACT_DOTA_CAST_ABILITY_4 1 fps 25.00
$sequence run "run" loop ACT_DOTA_RUN 1 fps 30.00
$sequence disabled "disabled" loop ACT_DOTA_DISABLED 1 fps 30.00
$sequence flail "flail" loop ACT_DOTA_FLAIL 1 fps 30.00
$sequence cast1_carrionSwarm "cast1_carrionSwarm" ACT_DOTA_CAST_ABILITY_1 1 fps 30.00
$sequence cast1_carrionSwarm_moth "cast1_carrionSwarm_moth" ACT_DOTA_CAST_ABILITY_1 1 fps 30.00
$sequence cast2_silence "cast2_silence" ACT_DOTA_CAST_ABILITY_2 1 fps 30.00
$sequence cast4_exorcism "cast4_exorcism" ACT_DOTA_CAST_ABILITY_4 1 fps 30.00
$sequence die "die" ACT_DOTA_DIE 1 fps 30.00
$sequence portrait "portrait" loop ACT_DOTA_CAPTURE 8 fps 30.00
$sequence portrait_alt1 "portrait_alt1" loop ACT_DOTA_CAPTURE 1 fps 30.00
$sequence portrait_alt2 "portrait_alt2" loop ACT_DOTA_CAPTURE 1 fps 30.00
$sequence run_chase "run_chase" loop ACT_DOTA_RUN 1 fps 30.00
$sequence run_injured "run_injured" loop ACT_DOTA_RUN 1 fps 30.00
$sequence spawn "spawn" ACT_DOTA_SPAWN 1 fps 30.00
$sequence idle_injured "idle_injured" loop ACT_DOTA_IDLE 1 fps 30.00
$sequence teleport "teleport" loop ACT_DOTA_TELEPORT 1 fps 30.00
$sequence teleport_end "teleport_end" ACT_DOTA_TELEPORT_END 1 fps 30.00
$sequence workshop_anim_00 "workshop_anim_00" fps 30.00
$sequence workshop_anim_01 "workshop_anim_01" fps 30.00
$sequence workshop_anim_02 "workshop_anim_02" fps 30.00
$sequence workshop_anim_03 "workshop_anim_03" fps 30.00
$sequence workshop_anim_04 "workshop_anim_04" fps 30.00
$sequence workshop_anim_05 "workshop_anim_05" fps 30.00
$sequence workshop_anim_06 "workshop_anim_06" fps 30.00
$sequence workshop_anim_07 "workshop_anim_07" fps 30.00
$sequence workshop_anim_08 "workshop_anim_08" fps 30.00
$sequence workshop_anim_09 "workshop_anim_09" fps 30.00
$sequence turns_lookFrame_0 "turns_lookFrame_0" fps 30.00
$sequence turns_lookFrame_1 "turns_lookFrame_1" fps 30.00
$sequence turns_lookFrame_2 "turns_lookFrame_2" fps 30.00
$sequence turns "turns_lookFrame_0" fps 30.00 {
  blendwidth 3
  blend turn -1.000000 1.000000
  delta
 turns_lookFrame_0 turns_lookFrame_1 turns_lookFrame_2
}
