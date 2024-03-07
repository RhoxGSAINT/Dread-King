local function spawn_new_force()
	cm:create_force_with_general(
		"ovn_tmb_dread_king", -- faction_key,
		"ovn_dk_inf_skeleton_hoplites,ovn_dk_inf_skeleton_hoplites,ovn_dk_inf_tomb_guardian_peltasts,ovn_dk_inf_mummies,ovn_dk_mon_skeleton_elephant,ovn_dk_cav_royal_guard_cavalry", -- unit_list,
		"cr_oldworld_region_fort_straghov", -- region_key,
		1082, -- x,
		1177, -- y,
		"general", -- type,
		"Dread_King", -- subtype,
		"names_name_247259235", -- name1,
		"", -- name2,
		"names_name_247259236", -- name3,
		"", -- name4,
		true,-- make_faction_leader,
        function(cqi) -- callback
            local str = "character_cqi:" .. cqi
            cm:set_character_immortality(str, true);
            cm:set_character_unique(str, true);
        end
	)
end

local dk_rites={
    dread_ritual_tmb_awakening = true,
    dread_ritual_tmb_legions = true,
    dread_ritual_tmb_conquest = true,
    dread_ritual_tmb_necromancy = true
}

local function new_game_startup()
    local dread_king_string = "ovn_tmb_dread_king"
	local dread_king = cm:get_faction(dread_king_string)

    if not dread_king then return end

    for rite, bool in pairs(dk_rites) do
        cm:lock_ritual(dread_king, rite)
    end
    
    
    local to_kill_cqi = nil
    local mixer_dread_king_leader = dread_king:faction_leader()

	if mixer_dread_king_leader and not mixer_dread_king_leader:is_null_interface() then
		to_kill_cqi = mixer_dread_king_leader:command_queue_index()
	end

    spawn_new_force()
    
    --change the campaign settlement model used
	cm:override_building_chain_display("wh3_main_ksl_settlement_major", "ovn_dkl_special_settlement_pools_of_despair", "cr_oldworld_region_fort_straghov")

    local fort_straghov = cm:get_region("cr_oldworld_region_fort_straghov")
    cm:transfer_region_to_faction("cr_oldworld_region_fort_straghov", "ovn_tmb_dread_king")
	cm:instantly_set_settlement_primary_slot_level(fort_straghov:settlement(), 3)
	cm:heal_garrison(fort_straghov:cqi());
    
        local wizard_agent =  cm:create_agent(
        "ovn_tmb_dread_king",
        "wizard",
        "elo_dread_larenscheld",
        1084, -- x,
		1178
    )
        
    if wizard_agent then
        cm:force_add_trait(cm:char_lookup_str(wizard_agent), "ovn_trait_name_dummy_gunther", false)
    end
    
             if common.vfs_exists("script/campaign/cr_oldworld/mod/ovn_grudgebringers.lua") then
                cm:force_declare_war("ovn_emp_grudgebringers", "ovn_tmb_dread_king", false, false)
            end

    
    
    local unit_count = 1 -- card32 count
    local rcp = 20 -- float32 replenishment_chance_percentage
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
    }
     
     
    for _, unit in ipairs(units) do
        cm:add_unit_to_faction_mercenary_pool(
            dread_king,
            unit,
            "renown",
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
    
    
    cm:callback(function()
        if to_kill_cqi then
            cm:disable_event_feed_events(true, "wh_event_category_character", "", "")
            local str = "character_cqi:" .. to_kill_cqi
            --cm:set_character_immortality(str, false)
            local fm_cqi = cm:get_character_by_cqi(to_kill_cqi):family_member():command_queue_index()
            cm:suppress_immortality(fm_cqi,true)
            cm:kill_character_and_commanded_unit(str, true)
        end
    end, 0)
    cm:callback(function() cm:disable_event_feed_events(false, "wh_event_category_character", "", "") end, 0.5)
    
    cm:callback(
        function()
            if dread_king:is_human() == true then
                out("Rhox DK: Let's show how they play")
                local faction_name = dread_king:name()
                local title = "event_feed_strings_text_wh2_scripted_event_how_they_play_title";
                local primary_detail = "factions_screen_name_" .. faction_name;
                local secondary_detail = "event_feed_strings_text_wh2_scripted_event_how_they_play_dread_king_secondary_detail";
                local pic = 606;
                out(title)
                out(primary_detail)
                out(secondary_detail)
                cm:show_message_event(
                    faction_name,
                    title,
                    primary_detail,
                    secondary_detail,
                    true,
                    pic
                );
                out("Rhox DK: I'd show them the how to play")
            end
        end,
        5.0
    )
    
end



cm:add_first_tick_callback(
	function()
        pcall(function()
            mixer_set_faction_trait("ovn_tmb_dread_king", "ovn_lord_trait_dread_king", true)
        end)
		if cm:is_new_game() then
			if cm:get_campaign_name() == "cr_oldworld" then
				local ok, err =
					pcall(
					function()
						new_game_startup()
					end
				)
				if not ok then
					script_error(err)
				end
			end
		end
	end
)
