local modded_units = {
    
    --CORE
    {"ovn_dk_inf_skeleton_hoplites", "core"},
    {"ovn_dk_inf_skeleton_pikemen", "core"},
    {"ovn_dk_inf_skeleton_javelinmen", "core"},
    {"ovn_dk_inf_mummies", "core"},
    {"ovn_dk_veh_skeleton_archer_chariot", "core"},
    {"ovn_dk_veh_skeleton_chariot", "core"},
    {"ovn_dk_cav_skeleton_horsemen_0", "core"},
    {"ovn_dk_cav_skeleton_horsemen_archers_0", "core"},    

    {"ovn_dk_inf_skeleton_hoplites_no_caps", "core"},
    {"ovn_dk_inf_skeleton_pikemen_no_caps", "core"},
    {"ovn_dk_inf_skeleton_javelinmen_no_caps", "core"},
    {"wh2_dlc09_tmb_inf_skeleton_archers_no_caps", "core"},
    {"ovn_dk_cav_skeleton_horsemen_no_caps", "core"},
    {"ovn_dk_cav_skeleton_horsemen_archers_no_caps", "core"},
    
    --SPECIAL
    {"ovn_dk_inf_tomb_guardian", "special", 1},
    {"ovn_dk_inf_tomb_guardian_great_weapons", "special", 1},
    {"ovn_dk_inf_tomb_guardian_peltasts", "special", 1},
    {"ovn_dk_cav_royal_guard_cavalry", "special", 1},
    {"ovn_dk_cav_royal_guard_lancers", "special", 1},
    {"ovn_dk_art_bone_throwers", "special", 1},
    {"ovn_dk_mon_skeletal_minotaurs", "special", 2},
    {"dread_mon_ushabti_0", "special", 2},
    {"dread_mon_ushabti_1", "special", 2},
    {"dread_inf_tomb_guard_0", "special", 1},
    {"dread_inf_tomb_guard_1", "special", 1},

    {"ovn_dk_mon_skeletal_minotaurs_no_caps", "special", 2},
    
    --RARE    
    {"ovn_dk_inf_cairn_wraiths", "rare", 1},
    {"ovn_dk_mon_skeleton_elephant", "rare", 2},
    {"ovn_dk_mon_skeleton_giant", "rare", 2},
    {"ovn_dk_mon_bone_hydra", "rare", 2},
    {"ovn_dk_veh_mortis_engine_0", "rare", 3},
    {"ovn_dk_art_screaming_skull_ballista", "rare", 1},

    {"ovn_dk_mon_skeleton_elephant_no_caps", "rare", 2},
    {"ovn_dk_mon_skeleton_giant_no_caps", "rare", 2},
    {"ovn_dk_mon_bone_hydra_no_caps", "rare", 2},
    
    -------LEGIONS OF LEGEND-------
    --SPECIAL
    {"ovn_dk_inf_thessos_ror", "core"},
    {"ovn_dk_cav_ephalian_ror", "special", 1},
    {"ovn_dk_art_polybolos_ror", "special", 1},
    {"ovn_dk_inf_spartan_ror", "special", 1},
    
    -------ROR-------
    --CORE
    {"ovn_dk_inf_brigands_ror", "core"},       
    {"ovn_dk_inf_wights_ror", "core"},
    {"ovn_dk_inf_mummies_ror", "core"},
    
    --SPECIAL
    {"ovn_dk_inf_catacomb_guardians_ror", "special", 1},

    --RARE
    {"ovn_dk_mon_skeleton_elephant_ror", "rare", 2},
    {"ovn_dk_cav_black_grail_knights_ror", "rare", 2}    
    
}

local ttc = core:get_static_object("tabletopcaps")
if ttc then
    ttc.add_setup_callback(function()
        ttc.add_unit_list(modded_units)
    end)
end