$cd "F:\Users\Grig\Documents"
$modelname "heroes/rattletrap/rattletrap.mdl"
$model "default" "rattletrap.dmx.smd"

$lod 1
 {
  replacemodel "rattletrap.dmx" "lod1_rattletrap.dmx"
}
$cdmaterials ""
$hboxset "default"
$hbox 0 "knee_L" 2.269  -6.547  -7.318  18.130  6.814  6.732
$hbox 0 "ankle_L" -4.364  -5.584  -10.712  10.645  6.224  4.434
$hbox 0 "thigh_R" -20.565  -3.997  -7.033  -7.790  8.445  4.473
$hbox 0 "knee_R" -18.130  -9.335  -11.284  10.052  10.596  7.318
$hbox 0 "ankle_R" -15.124  -7.750  -3.560  5.082  4.782  10.788
$hbox 0 "Root_0" -7.460  -14.321  -9.903  4.560  0.004  5.794
$hbox 0 "Spine_0" -9.684  -20.862  -21.805  1.668  19.103  13.175
$hbox 0 "bicep_R" -18.607  -6.027  -4.785  -3.071  5.061  5.843
$hbox 0 "elbow_R" -27.073  -9.207  -8.090  -1.603  10.116  11.377
$hbox 0 "wrist_R" -17.006  -6.863  -11.465  0.306  5.880  7.487
$hbox 0 "weapon_1" -14.449  -34.899  -12.076  14.000  61.191  19.568
$hbox 0 "bicep_L" 3.071  -5.061  -5.843  18.607  6.027  6.248
$hbox 0 "elbow_L" 1.603  -10.116  -11.377  20.713  9.193  8.090
$hbox 0 "wrist_L" -0.306  -5.880  -6.481  17.006  6.863  11.465
$hbox 0 "back_thing" -20.888  -23.712  -11.804  7.154  26.318  25.492
$hbox 0 "Head_1" -8.764  -15.991  -10.394  17.507  15.991  22.289
$hbox 0 "thigh_L" 7.536  -8.614  -4.625  20.238  3.966  7.018
$hboxset "feet"
$hbox 0 "ankle_L" -4.364  -5.584  -10.712  10.645  6.224  4.434
$hbox 0 "ankle_R" -15.124  -7.750  -3.560  5.082  4.782  10.788
$hboxset "select_high"
$hbox 0 "Spine_0" -72.103  -38.170  -36.326  -6.994  38.475  32.828
$hbox 0 "Spine_0" -7.142  -38.189  -30.471  46.979  37.008  26.898
$hboxset "select_low"
$hbox 0 "Spine_0" -71.484  -76.490  -71.597  58.977  67.517  56.256
$hboxset "hands"
$hbox 0 "wrist_R" -16.250  -7.616  -11.133  1.062  5.127  7.819
$hbox 0 "wrist_L" -0.543  -4.769  -7.591  16.768  7.975  10.355
$hboxset "head"
$hbox 0 "Head_1" -8.764  -9.321  -5.440  17.507  9.321  17.334
$attachment "attach_rocket" "missle_gun2_1" 10.00 17.00 -0.00 rotate -0.00 0.00 0.00
$attachment "attach_glow" "back_thing" -12.00 -10.00 0.00 rotate 0.00 0.00 -0.00
$attachment "attach_batAss_1" "rocket_1_jnt" 0.00 0.00 -20.00 rotate 0.00 0.00 -0.00
$attachment "attach_batAss_2" "rocket_2_jnt" 0.00 -0.00 -20.00 rotate 0.00 0.00 -0.00
$attachment "attach_batAss_3" "rocket_3_jnt" 0.00 0.00 -20.00 rotate 0.00 0.00 -0.00
$attachment "attach_batAss_4" "rocket_4_jnt" 0.00 0.00 -20.00 rotate 0.00 0.00 -0.00
$attachment "attach_attack1" "weapon_1" -0.00 25.00 -0.00 rotate -0.00 -0.00 -0.00
$attachment "attach_weapon" "weapon_1" 0.00 0.00 0.00 rotate -0.00 -0.00 -0.00
$attachment "attach_hitloc" "Spine_3" 0.00 -0.00 0.00 rotate -0.00 0.00 -0.00
$surfaceprop "default"
$keyvalues  {  } 
$illumposition -3.504 -4.486 53.171
$sequence BindPose "BindPose" fps 30.00
$sequence run "run" loop ACT_DOTA_RUN 1 fps 30.00 {
  { event AE_CL_PLAYSOUND 2 "Rattletrap.Footsteps" }
  { event AE_CL_PLAYSOUND 13 "Rattletrap.Footsteps" }
  { event AE_CL_PLAYSOUND 6 "Rattletrap.Foley" }
  { event AE_CL_PLAYSOUND 18 "Rattletrap.Foley" }
}

$sequence idle "idle" loop ACT_DOTA_IDLE 4 fps 30.00
$sequence idle_portrait "idle_portrait" loop ACT_DOTA_CAPTURE 1 fps 30.00
$sequence idle_alt "idle_alt" loop ACT_DOTA_IDLE_RARE 1 fps 30.00
$sequence attack "attack" ACT_DOTA_ATTACK 1 fps 30.00
$sequence attack_alt "attack_alt" ACT_DOTA_ATTACK 1 fps 30.00
$sequence death "death" ACT_DOTA_DIE 1 fps 30.00 {
  { event AE_CL_PLAYSOUND 29 "Hero_Rattletrap.Death" }
}

$sequence death_alt "death_alt" ACT_DOTA_DIE 1 fps 30.00 {
  { event AE_CL_PLAYSOUND 28 "Hero_Rattletrap.Death" }
}

$sequence death_special "death_special" ACT_DOTA_DIE_SPECIAL 1 fps 30.00
$sequence flail "flail" loop ACT_DOTA_FLAIL 1 fps 30.00
$sequence stun "stun" loop ACT_DOTA_DISABLED 1 fps 30.00
$sequence battery_assault "battery_assault" ACT_DOTA_RATTLETRAP_BATTERYASSAULT 1 fps 30.00
$sequence battery_assault_statue "battery_assault_statue" ACT_DOTA_STATUE_SEQUENCE 1 fps 30.00
$sequence power_cogs "power_cogs" ACT_DOTA_RATTLETRAP_POWERCOGS 1 fps 30.00
$sequence power_cogs_statue "power_cogs_statue" ACT_DOTA_STATUE_SEQUENCE 1 fps 30.00
$sequence rocketFlare "rocketFlare" ACT_DOTA_CAST_ABILITY_3 1 fps 30.00
$sequence hookshot_start "hookshot_start" ACT_DOTA_RATTLETRAP_HOOKSHOT_START 1 fps 30.00
$sequence hookshot_loop "hookshot_loop" loop ACT_DOTA_RATTLETRAP_HOOKSHOT_LOOP 1 fps 30.00
$sequence hookshot_end "hookshot_end" ACT_DOTA_RATTLETRAP_HOOKSHOT_END 1 fps 30.00
$sequence spawn "spawn" ACT_DOTA_SPAWN 1 fps 30.00
$sequence spawn_loadout "spawn_loadout" ACT_DOTA_SPAWN 1 fps 30.00
$sequence teleport_end "teleport_end" ACT_DOTA_TELEPORT_END 1 fps 30.00
$sequence telebolt_power_cogs "telebolt_power_cogs" ACT_DOTA_RATTLETRAP_POWERCOGS 1 fps 30.00
$sequence telebolt_teleport "telebolt_teleport" loop ACT_DOTA_TELEPORT 1 fps 30.00
$sequence telebolt_victory "telebolt_victory" loop ACT_DOTA_VICTORY 1 fps 30.00
$sequence taunt_robot "taunt_robot" ACT_DOTA_TAUNT 1 fps 30.00 {
  { event AE_CL_PLAYSOUND 0 "Hero_Rattletrap.Taunt.Robot" }
}

$sequence para_idle "para_idle" loop ACT_DOTA_IDLE 4 fps 30.00
$sequence para_run "para_run" loop ACT_DOTA_RUN 1 fps 30.00 {
  { event AE_CL_PLAYSOUND 2 "Rattletrap.Footsteps" }
  { event AE_CL_PLAYSOUND 13 "Rattletrap.Footsteps" }
  { event AE_CL_PLAYSOUND 6 "Rattletrap.Foley" }
  { event AE_CL_PLAYSOUND 18 "Rattletrap.Foley" }
  { event AE_CL_PLAYSOUND 27 "Rattletrap.Footsteps" }
  { event AE_CL_PLAYSOUND 38 "Rattletrap.Footsteps" }
  { event AE_CL_PLAYSOUND 31 "Rattletrap.Foley" }
  { event AE_CL_PLAYSOUND 43 "Rattletrap.Foley" }
}

$sequence para_idle_alt "para_idle_alt" loop ACT_DOTA_IDLE_RARE 1 fps 30.00
$sequence para_attack "para_attack" ACT_DOTA_ATTACK 1 fps 30.00
$sequence para_attack_alt "para_attack_alt" ACT_DOTA_ATTACK 1 fps 30.00
$sequence para_flail "para_flail" loop ACT_DOTA_FLAIL 1 fps 30.00
$sequence para_stun "para_stun" loop ACT_DOTA_DISABLED 1 fps 30.00
$sequence para_battery_assault "para_battery_assault" ACT_DOTA_RATTLETRAP_BATTERYASSAULT 1 fps 30.00
$sequence para_power_cogs "para_power_cogs" ACT_DOTA_RATTLETRAP_POWERCOGS 1 fps 30.00
$sequence para_rocketFlare "para_rocketFlare" ACT_DOTA_CAST_ABILITY_3 1 fps 30.00
$sequence para_hookshot_start "para_hookshot_start" ACT_DOTA_RATTLETRAP_HOOKSHOT_START 1 fps 30.00
$sequence para_hookshot_loop "para_hookshot_loop" loop ACT_DOTA_RATTLETRAP_HOOKSHOT_LOOP 1 fps 30.00
$sequence para_hookshot_end "para_hookshot_end" ACT_DOTA_RATTLETRAP_HOOKSHOT_END 1 fps 30.00
$sequence para_spawn "para_spawn" ACT_DOTA_SPAWN 1 fps 30.00
$sequence para_spawn_loadout "para_spawn_loadout" ACT_DOTA_SPAWN 1 fps 30.00
$sequence para_teleport_end "para_teleport_end" ACT_DOTA_TELEPORT_END 1 fps 30.00
$sequence para_telebolt_power_cogs "para_telebolt_power_cogs" ACT_DOTA_RATTLETRAP_POWERCOGS 1 fps 30.00
$sequence para_telebolt_teleport "para_telebolt_teleport" loop ACT_DOTA_TELEPORT 1 fps 30.00
$sequence para_telebolt_victory "para_telebolt_victory" loop ACT_DOTA_VICTORY 1 fps 30.00
$sequence para_death "para_death" ACT_DOTA_DIE 1 fps 30.00 {
  { event AE_CL_PLAYSOUND 29 "Hero_Rattletrap.Death" }
}

$sequence para_taunt_robot "para_taunt_robot" ACT_DOTA_TAUNT 1 fps 30.00 {
  { event AE_CL_PLAYSOUND 0 "Hero_Rattletrap.Taunt.Robot" }
}

$sequence para_death_special "para_death_special" ACT_DOTA_DIE_SPECIAL 1 fps 30.00
$sequence para_death_alt "para_death_alt" ACT_DOTA_DIE 1 fps 30.00 {
  { event AE_CL_PLAYSOUND 28 "Hero_Rattletrap.Death" }
}

