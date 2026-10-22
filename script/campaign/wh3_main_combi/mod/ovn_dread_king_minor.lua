OVN_DREAD_KING_MINOR={
    spawn_italy=false
}


core:add_listener(
    "rhox_ovn_dread_king_mct_initialize",
    "MctInitialized",
    true,
    function(context)
        -- get the mct object
        local mct = context:mct()
        local my_mod = mct:get_mod_by_key("ovn_dread_king")

        local rhox_ovn_dread_king_minor_italy = my_mod:get_option_by_key("rhox_ovn_dread_king_minor_italy")
        local rhox_ovn_dread_king_minor_italy_setting = rhox_ovn_dread_king_minor_italy:get_finalized_setting()
        OVN_DREAD_KING_MINOR.spawn_italy=rhox_ovn_dread_king_minor_italy_setting

    end,
    true
)

cm:add_first_tick_callback_new(
	function()
        core:add_listener(
            "rhox_ovn_dread_king_mct_changed",
            "MctOptionSettingFinalized",
            true,
            function(context)
                -- get the mct object
                local mct = context:mct()
                local my_mod = mct:get_mod_by_key("ovn_dread_king")

                local rhox_ovn_dread_king_minor_italy = my_mod:get_option_by_key("rhox_ovn_dread_king_minor_italy")
                local rhox_ovn_dread_king_minor_italy_setting = rhox_ovn_dread_king_minor_italy:get_finalized_setting()
                OVN_DREAD_KING_MINOR.spawn_italy=rhox_ovn_dread_king_minor_italy_setting
            end,
            true
        )
        --out("Rhox Araby Checking: "..tostring(OVN_ARABY_MINOR.spawn_ind))
        if OVN_DREAD_KING_MINOR.spawn_italy then
            local faction_string = "ovn_tmb_dread_myrmidens"

            cm:apply_effect_bundle("ovn_myrmidens_diplo_hidden", "ovn_tmb_dread_myrmidens", 0)

            cm:create_force_with_general(
                faction_string,
                "ovn_dk_inf_skeleton_hoplites,ovn_dk_inf_skeleton_hoplites,ovn_dk_inf_skeleton_javelinmen,ovn_dk_inf_skeleton_javelinmen,ovn_dk_mon_skeletal_minotaurs,ovn_dk_veh_skeleton_chariot", -- unit_list,
                "wh3_main_combi_region_myrmidens", -- region_key,
                578, -- x,
                438, -- y,
                "general", -- type,
                "elo_liche_general_vampires", -- subtype,
                "", -- name1,
                "", -- name2,
                "", -- name3,
                "", -- name4,
                true,-- make_faction_leader,
                function(cqi) -- callback
                    local str = "character_cqi:" .. cqi
                    cm:set_character_immortality(str, true);
                    cm:set_character_unique(str, true);
                end
            )
            
            cm:callback(
                function()
                    cm:transfer_region_to_faction("wh3_main_combi_region_myrmidens", faction_string)
                    local region_myrmidens = cm:get_region("wh3_main_combi_region_myrmidens")
                    cm:heal_garrison(region_myrmidens:cqi());
                    
                    cm:transfer_region_to_faction("wh3_main_combi_region_argalis", faction_string)
                    local region_argalis = cm:get_region("wh3_main_combi_region_argalis")
                    cm:heal_garrison(region_argalis:cqi());  
                end,
                5.0--Cataph's TEB also hands them off to Ogre, so we need latency for it to actually work over it
            )
            
            local unit_count = 1 -- card32 count
            local rcp = 100 -- float32 replenishment_chance_percentage
            local max_units = 1 -- int32 max_units
            local murpt = 0.1 -- float32 max_units_replenished_per_turn
            local xp_level = 0 -- card32 xp_level
            local frr = "" -- (may be empty) String faction_restricted_record
            local srr = "" -- (may be empty) String subculture_restricted_record
            local trr = "" -- (may be empty) String tech_restricted_record
            local units = {
                "ovn_dk_inf_wights_ror",
                "ovn_dk_inf_mummies_ror",
                "ovn_dk_inf_catacomb_guardians_ror",
                "ovn_dk_cav_black_grail_knights_ror",        
                "ovn_dk_mon_skeleton_elephant_ror",
                "ovn_dk_inf_brigands_ror",
                "ovn_dk_inf_spartan_ror",
                "ovn_dk_inf_thessos_ror",
                "ovn_dk_cav_ephalian_ror",
                "ovn_dk_art_polybolos_ror"
            }
            
            cm:apply_effect_bundle("rhox_dk_army_ability_enabler_hidden", faction_string, 0)
            
            for _, unit in ipairs(units) do
                cm:add_unit_to_faction_mercenary_pool(
                    faction_string,
                    unit,
                    "wh3_main_regiments_of_renown_pool",
                    unit_count,
                    rcp,
                    max_units,
                    murpt,
                    frr,
                    srr,
                    trr,
                    true,
                    unit
                )
            end
            cm:add_event_restricted_unit_record_for_faction("ovn_dk_inf_spartan_ror", faction_string, "wh2_dlc09_lock_ror_crafting");
            cm:add_event_restricted_unit_record_for_faction("ovn_dk_inf_thessos_ror", faction_string, "wh2_dlc09_lock_ror_crafting");
            cm:add_event_restricted_unit_record_for_faction("ovn_dk_cav_ephalian_ror", faction_string, "wh2_dlc09_lock_ror_crafting");
            cm:add_event_restricted_unit_record_for_faction("ovn_dk_art_polybolos_ror", faction_string, "wh2_dlc09_lock_ror_crafting");
        end
    end
)
