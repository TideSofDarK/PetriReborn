$cd "F:\Users\Grig\Documents"
$modelname "heroes/brewmaster/brewmaster.mdl"
$model "default" "brewmaster_model.dmx.smd"

$lod 1
 {
  replacemodel "brewmaster_model.dmx" "lod1_brewmaster_model.dmx"
}
$poseparameter TURN -1.00 1.00
$poseparameter idle_to_run 0.00 1.00
$poseparameter idle_aggr_to_run_aggr 0.00 1.00
$cdmaterials ""
$hboxset "default"
$hbox 0 "knee_R" -33.269  -18.669  -19.680  6.696  20.630  28.724
$hbox 0 "thigh_R" -38.233  -21.335  -26.839  8.274  24.413  33.892
$hbox 0 "frontCloth5_0" -2.828  -14.012  -44.205  2.242  9.232  -1.941
$hbox 0 "ear0_0_L" -9.055  -3.470  5.683  7.003  6.572  43.282
$hbox 0 "jaw0_0" 0.745  -13.891  -22.149  18.558  13.891  -9.334
$hbox 0 "keg1_0" -35.472  -35.104  -37.342  35.181  34.700  44.083
$hbox 0 "elbow_L" -13.010  -17.523  -17.434  41.813  17.710  21.324
$hbox 0 "bicep_L" 2.828  -18.851  -18.607  60.474  19.330  23.701
$hbox 0 "mug4_0" -11.339  -18.201  -5.392  19.123  15.585  37.555
$hbox 0 "flail_R3C0" -0.822  -8.692  -8.692  84.168  8.692  8.692
$hbox 0 "flail_R2C0" -3.381  -2.019  -5.585  16.141  2.019  5.585
$hbox 0 "flail_R1C0" -3.195  -5.585  -2.019  16.328  5.585  2.019
$hbox 0 "flail_R0C0" 2.723  -1.500  -5.927  14.578  1.500  5.927
$hbox 0 "flail2_0" -50.000  -8.692  -8.692  163.415  8.692  8.692
$hbox 0 "elbow_R" -41.813  -17.710  -21.324  13.010  17.523  17.434
$hbox 0 "bicep_R" -60.474  -19.330  -23.701  -2.828  18.851  18.607
$hbox 0 "spine2" -25.528  -40.079  -48.098  19.629  40.079  30.533
$hbox 0 "spine1" -16.686  -56.367  -37.804  70.584  42.765  55.895
$hbox 0 "knee_L" -6.696  -20.630  -28.724  33.269  18.669  19.680
$hbox 0 "thigh_L" -8.274  -24.413  -33.892  38.233  21.335  26.845
$hbox 0 "hipCloth2_1_A_L" -2.722  -20.559  -37.534  21.689  2.787  30.876
$hbox 0 "hipCloth2_0_A_L" -1.138  -50.428  -34.925  20.974  3.849  30.947
$hbox 0 "hipCloth3_1_A_R" -21.689  -2.674  -30.919  3.582  22.361  38.668
$hbox 0 "hipCloth3_0_A_R" -28.562  -3.849  -30.003  1.138  19.951  36.301
$hbox 0 "root" -36.814  -44.219  -31.910  45.017  44.285  41.518
$hboxset "feet"
$hbox 0 "ankle_R" -35.685  -12.629  -10.794  10.100  12.290  8.759
$hbox 0 "ankle_L" -10.100  -12.281  -8.759  35.686  12.788  10.794
$hboxset "head"
$hbox 0 "head" -10.747  -18.638  -21.871  39.849  36.972  45.927
$hboxset "hands"
$hbox 0 "wrist_L" -2.167  -7.676  -21.284  29.687  26.369  12.578
$hbox 0 "wrist_R" -29.687  -26.369  -12.578  2.167  7.676  21.284
$hboxset "select_high"
$hbox 0 "spine2" -47.252  -46.335  -50.056  41.354  46.335  39.874
$hbox 0 "root" -47.838  -58.000  -84.467  56.041  58.065  43.354
$hboxset "select_low"
$hbox 0 "root" -95.284  -97.931  -85.046  103.487  97.996  89.169
$attachment "attach_mouth" "jaw0_0" 17.00 0.00 -13.30 rotate 45.00 0.00 -0.00
$attachment "attach_keg" "keg1_0" 15.00 -0.00 40.00 rotate -90.00 0.00 0.00
$attachment "attach_attack1" "flail_R3C0" 0.00 0.00 0.00 rotate -0.00 -0.00 0.00
$attachment "attach_hitloc" "spine2" 0.00 0.00 0.00 rotate 0.00 -0.00 -0.00
$surfaceprop "default"
$keyvalues  {  } 
$illumposition 75.936 -0.000 26.877
$sequence BindPose "BindPose" fps 30.00
$sequence idle "idle" loop ACT_DOTA_IDLE 1 fps 30.00
$sequence idle_injured "idle_injured" loop ACT_DOTA_IDLE 1 fps 30.00
$sequence idle_aggressive "idle_aggressive" loop ACT_DOTA_IDLE 1 fps 30.00
$sequence run_aggressive "run_aggressive" loop ACT_DOTA_RUN 1 fps 30.00 {
  { event AE_CL_PLAYSOUND 1 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 13 "Hero_Brewmaster.Footsteps" }
}

$sequence Run "Run" loop ACT_DOTA_RUN 1 fps 30.00 {
  { event AE_CL_PLAYSOUND 1 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 13 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 25 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 37 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 49 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 61 "Hero_Brewmaster.Footsteps" }
}

$sequence run_injured "run_injured" loop ACT_DOTA_RUN 1 fps 30.00 {
  { event AE_CL_PLAYSOUND 1 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 13 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 25 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 37 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 49 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 61 "Hero_Brewmaster.Footsteps" }
}

$sequence run_haste "run_haste" loop ACT_DOTA_RUN 1 fps 30.00 {
  { event AE_CL_PLAYSOUND 1 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 9 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 18 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 27 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 36 "Hero_Brewmaster.Footsteps" }
  { event AE_CL_PLAYSOUND 45 "Hero_Brewmaster.Footsteps" }
}

$sequence Attack "Attack" ACT_DOTA_ATTACK 1 fps 30.00
$sequence Attack Alternate "Attack Alternate" ACT_DOTA_ATTACK 1 fps 30.00
$sequence Attack Critical "Attack Critical" ACT_DOTA_ATTACK_EVENT 1 fps 30.00 {
  { event AE_CL_CREATE_PARTICLE_EFFECT 8 "BREWMASTER_DRUNKEN_BRAWLER_CRIT start_at_origin" }
}

$sequence flail "flail" loop ACT_DOTA_FLAIL 1 fps 30.00
$sequence disabled "disabled" loop ACT_DOTA_DISABLED 1 fps 30.00
$sequence die "die" ACT_DOTA_DIE 1 fps 30.00 {
  { event AE_CL_PLAYSOUND 28 "BodyImpact_Common.Heavy" }
  { event AE_CL_PLAYSOUND 35 "Hero_Brewmaster.Death" }
}

$sequence capture "capture" loop ACT_DOTA_CAPTURE 1 fps 30.00
$sequence Thunderclap "Thunderclap" ACT_DOTA_CAST_ABILITY_1 1 fps 30.00
$sequence Drunken Haze "Drunken Haze" ACT_DOTA_CAST_ABILITY_2 1 fps 30.00
$sequence drunkenHaze_aggressive "drunkenHaze_aggressive" ACT_DOTA_CAST_ABILITY_2 1 fps 30.00
$sequence drunkenBrawler "drunkenBrawler" ACT_DOTA_OVERRIDE_ABILITY_3 1 fps 30.00 subtract mdldecompiler_delta.smd 0
$sequence Primal Split "Primal Split" ACT_DOTA_CAST_ABILITY_4 1 fps 30.00
$sequence Spawn "Spawn" ACT_DOTA_SPAWN 1 fps 30.00
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
$sequence heroPickerPortrait "heroPickerPortrait" loop ACT_DOTA_CAPTURE 2 fps 30.00
$sequence turns_lookFrame_0 "turns_lookFrame_0" fps 30.00
$sequence turns_lookFrame_1 "turns_lookFrame_1" fps 30.00
$sequence turns_lookFrame_2 "turns_lookFrame_2" fps 30.00
$sequence idle_to_run_pose_lookFrame_0 "idle_to_run_pose_lookFrame_0" fps 30.00
$sequence idle_to_run_pose_lookFrame_1 "idle_to_run_pose_lookFrame_1" fps 30.00
$sequence idle_aggr_to_run_aggr_pose_lookFrame_0 "idle_aggr_to_run_aggr_pose_lookFrame_0" fps 30.00
$sequence idle_aggr_to_run_aggr_pose_lookFrame_1 "idle_aggr_to_run_aggr_pose_lookFrame_1" fps 30.00
$sequence turns "turns_lookFrame_0" fps 30.00 {
  blendwidth 3
  blend TURN -1.000000 1.000000
  delta
 turns_lookFrame_0 turns_lookFrame_1 turns_lookFrame_2
}
$sequence idle_to_run_pose "idle_to_run_pose_lookFrame_0" fps 30.00 {
  blendwidth 2
  blend idle_to_run 0.000000 1.000000
  delta
 idle_to_run_pose_lookFrame_0 idle_to_run_pose_lookFrame_1
}
$sequence idle_aggr_to_run_aggr_pose "idle_aggr_to_run_aggr_pose_lookFrame_0" fps 30.00 {
  blendwidth 2
  blend idle_aggr_to_run_aggr 0.000000 1.000000
  delta
 idle_aggr_to_run_aggr_pose_lookFrame_0 idle_aggr_to_run_aggr_pose_lookFrame_1
}
