local function ovn_dk_mortuary_cult_ror_addons()
	if cm:is_new_game() then
		local ovn_dread_king = "ovn_tmb_dread_king";
		local units = {
            "ovn_dk_inf_spartan_ror",
            "ovn_dk_inf_thessos_ror",
            "ovn_dk_cav_ephalian_ror",
            "ovn_dk_art_polybolos_ror"
        }
        local ovn_dread_king_interface=  cm:get_faction(ovn_dread_king)
        
        for _, unit in ipairs(units) do
            cm:add_unit_to_faction_mercenary_pool(
                ovn_dread_king_interface,
                unit,
                "renown",
                1,
                20,
                1,
                0.1,
                "",
                "",
                "",
                true,
                unit
            )
        end
        -- Unlocked via Crafting Additional
        cm:add_event_restricted_unit_record_for_faction("ovn_dk_inf_spartan_ror", ovn_dread_king, "wh2_dlc09_lock_ror_crafting");
        cm:add_event_restricted_unit_record_for_faction("ovn_dk_inf_thessos_ror", ovn_dread_king, "wh2_dlc09_lock_ror_crafting");
        cm:add_event_restricted_unit_record_for_faction("ovn_dk_cav_ephalian_ror", ovn_dread_king, "wh2_dlc09_lock_ror_crafting");
        cm:add_event_restricted_unit_record_for_faction("ovn_dk_art_polybolos_ror", ovn_dread_king, "wh2_dlc09_lock_ror_crafting");
	end
	
	core:add_listener(
		"tomb_king_ror_unlock",
		"RitualCompletedEvent",
		function(context)
			return context:performing_faction():is_human();
		end,
		function(context)
			local faction_key = context:performing_faction():name();
			local ritual_key = context:ritual():ritual_key();
			
		if ritual_key == "ovn_dk_inf_spartan" then
			cm:remove_event_restricted_unit_record_for_faction("ovn_dk_inf_spartan_ror", faction_key);
		elseif ritual_key == "ovn_dk_inf_thessos" then
			cm:remove_event_restricted_unit_record_for_faction("ovn_dk_inf_thessos_ror", faction_key);
		elseif ritual_key == "ovn_dk_cav_ephalian" then
			cm:remove_event_restricted_unit_record_for_faction("ovn_dk_cav_ephalian_ror", faction_key);
		elseif ritual_key == "ovn_dk_art_polybolos" then
			cm:remove_event_restricted_unit_record_for_faction("ovn_dk_art_polybolos_ror", faction_key);
			end
		end,
		true
	);
end

cm:add_first_tick_callback(function()
	cm:callback(ovn_dk_mortuary_cult_ror_addons, 4)
end);