
local base_tmb_rituals={
    wh2_dlc09_ritual_crafting_tmb_nehekhara_horsemen = true,
    wh2_dlc09_ritual_crafting_tmb_carrion  = true,
    wh2_dlc09_ritual_crafting_tmb_necropolis_knights  = true,
    wh2_dlc09_ritual_crafting_tmb_nehekhara_warriors  = true,
    wh3_main_ritual_crafting_tmb_liche_priest_capacity  = true,
    wh3_main_ritual_crafting_tmb_necrotect_capacity  = true,
    wh3_main_ritual_crafting_tmb_prince_capacity  = true,
    wh2_dlc09_ritual_crafting_tmb_army_capacity  = true
}


local function rhox_dk_mortuary_scroll_bar()
	------let's do something here
	local rituals_list = find_uicomponent(core:get_ui_root(), "mortuary_cult", "header_list")
	if not rituals_list then
        return
	end
	--create horizontal view
	local result = core:get_or_create_component("rhox_horizontal_view", "ui/campaign ui/rhox_dk_horizontal_view.twui.xml", rituals_list)
	if not result then
		script_error("Rhox Market: ".. "ERROR: could not create horizontal view ui component? How can this be?");
		return false;
	end;
	
	if not rituals_list then
		return
	end
	
	local addresses = {}
	for i = 0, rituals_list:ChildCount() -2 do -- -2 because the lost one is rhox_horizontal_view
		local child_uic = find_child_uicomponent_by_index(rituals_list, i)
		if child_uic then
			--out("Rhox: Currently looking at: "..child_uic:Id())
			table.insert(addresses, child_uic:Address())
		end
	end
	out("Rhox market got the addresses, number of addresses are: "..#addresses)
	
	local new_parent = find_uicomponent(result, "list_clip", "list_box")
	if not new_parent then
		return
	end
	--move them to horizontal view
	for i = 1, #addresses do
		rituals_list:Divorce(addresses[i])
		new_parent:Adopt(addresses[i])
	end
end

local function play_rite()
	local orig_rite_performed = find_uicomponent(core:get_ui_root(), "rite_performed")
	if not orig_rite_performed then 
        --return --not summoned so let's do this
    end

	local rite = core:get_or_create_component("rhox_nagash_rite", "ui/campaign ui/rite_performed", core:get_ui_root())
	if not rite then
        out("Rhox dreadking: Could not create it? Why?")
        return
	end
	for i = 0, rite:ChildCount() - 1 do
		local uic_child = UIComponent(rite:Find(i));
		uic_child:SetVisible(false)
	end;
	
	local tokmbking_animation = find_uicomponent(rite, "wh2_dlc09_tmb_tomb_kings")
	tokmbking_animation:SetVisible(true)

end

cm:add_first_tick_callback(
    function()
        if cm:get_faction("ovn_tmb_dread_king"):is_human() then
            --this will remove the rituals from the visual
            if cm:is_new_game() == true then
                local faction = cm:get_faction("ovn_tmb_dread_king")
                for ritual_key, content in pairs(base_tmb_rituals) do
                    cm:lock_ritual(faction, ritual_key)
                end
                
            end
            --adding scrollbar to the mortuary cult
            core:add_listener(
                "rhox_dk_mortuary_panel_open",
                "PanelOpenedCampaign",
                function(context)	
                    return context.string == "mortuary_cult"
                end,
                function()
                    if cm:get_local_faction(true):name() == "ovn_tmb_dread_king" then
                        rhox_dk_mortuary_scroll_bar()
                        cm:callback(
                            function()
                                rhox_dk_mortuary_scroll_bar()--this is needed for the case when the player pushes the craft button
                            end,
                            0.5
                        )
                    end
                end,
                true
            )
            
            core:add_listener(
                "rhox_ovn_dk_RitualCompletedEvent",
                "RitualCompletedEvent",
                function(context)
                    return context:succeeded() and context:ritual():ritual_key() == "dread_ritual_crafting_tmb_army_capacity";
                end,
                function(context)
                    tomb_king_dynasty_crafted(context:performing_faction():name());
                end,
                true
            );
            
            core:add_listener(
                "rhox_ovn_dk_mortuaty_RitualCompletedEvent",
                "RitualCompletedEvent",
                function(context)
					local ritual = context:ritual()
					local faction = context:performing_faction()
                    return faction:is_human() and faction:name() == "ovn_tmb_dread_king" and context:succeeded() and ritual:ritual_category() == "CRAFTING_RITUAL";
                end,
                function(context)
                    if cm:get_local_faction(true):name() == "ovn_tmb_dread_king" then
                        cm:callback(
                            function()
                                rhox_dk_mortuary_scroll_bar()--this is needed for the case when the player pushes the craft button
                            end,
                            4
                        )
                    end
                end,
                true
            );
            core:add_listener(
                "rhox_dreadking_rite_animation",
                "RitualStartedEvent",
                function(context)
                    local ritual = context:ritual()
                    return context:performing_faction() == cm:get_local_faction(true) and cm:get_local_faction_name(true) == "ovn_tmb_dread_king" and ritual:ritual_category() == "STANDARD_RITUAL";
                end,
                function()
                    cm:callback(function()
                        play_rite()
                    end, 0)
                end,
                true
            )

        end
    end
);



local vanilla_tomb_king_rite={
    wh2_dlc09_ritual_tmb_geheb =true,
    wh2_dlc09_ritual_tmb_khsar =true,
    wh2_dlc09_ritual_tmb_ptra =true,
    wh2_dlc09_ritual_tmb_tahoth =true
}

cm:add_faction_turn_start_listener_by_name(
    "rhox_dk_vanilla_rite_lock",
    "ovn_tmb_dread_king",
    function(context)
        for rite, bool in pairs(vanilla_tomb_king_rite) do
			cm:lock_ritual(context:faction(), rite)--it will lock the ritual at the start of the turn, AI is less likely to use it
		end
	end,
	true
)


core:add_listener(
	"rhox_dk_rite_panel_open",
	"PanelOpenedCampaign",
	function(context)	
        return context.string == "rituals_panel" and cm:get_local_faction_name(true) == "ovn_tmb_dread_king" --ui thing and should be local
	end,
	function()
        local rituals_list = find_uicomponent(core:get_ui_root(), "rituals_panel", "panel_frame", "context_rituals_list")
        
        local faction_cqi = cm:get_faction("ovn_tmb_dread_king"):command_queue_index()
        --out("Rhox DK: faction cqi ".. faction_cqi)
        local addresses = {}
        for i = 0, rituals_list:ChildCount() -1 do 
            local child_uic = find_child_uicomponent_by_index(rituals_list, i)
            local child_id = string.gsub(child_uic:Id(), "CcoCampaignRitual"..faction_cqi,"");
            --out("Rhox DK: ".. child_id)
            
            if vanilla_tomb_king_rite[child_id] then
                child_uic:SetVisible(false)
            end
        end
        local faction = cm:get_faction("ovn_tmb_dread_king")
        for rite, bool in pairs(vanilla_tomb_king_rite) do
			cm:lock_ritual(faction, rite)--it will lock the ritual at the start of the turn, AI is less likely to use it
		end
	end,
	true
)









core:add_listener(
	"rhox_dread_ritual_tmb_legions",
	"GarrisonOccupiedEvent",
	function(context)	
        local faction = context:character():faction();
        return faction:name() == "ovn_tmb_dread_king" and faction:region_list():num_items() >= 3;
	end,
	function(context)
        local faction = context:character():faction();
        cm:unlock_ritual(faction, "dread_ritual_tmb_legions", 0)
        
        cm:callback(
			function()
                for rite, bool in pairs(vanilla_tomb_king_rite) do
                    cm:lock_ritual(faction, rite)--it will lock the ritual at the start of the turn, AI is less likely to use it
                end
            end,
            0.1
		)
		
		if faction:is_human() and cm:get_saved_value("dread_ritual_tmb_legions_unlock") ~= true then
            cm:set_saved_value("dread_ritual_tmb_legions_unlock",true)
            local incident_builder = cm:create_incident_builder("rhox_dk_unlocked_dread_legions")
			cm:launch_custom_incident_from_builder(incident_builder, faction)
		end
	end,
	true
)

core:add_listener(
	"rhox_dread_ritual_tmb_awakening_1",
	"BuildingCompleted",
	function(context)	
        local building = context:building();
        return building:faction():name() == "ovn_tmb_dread_king" and building:name() == "dread_citadel_1";
	end,
	function(context)
        local faction = context:building():faction();
        cm:unlock_ritual(faction, "dread_ritual_tmb_awakening", 0)
        
        cm:callback(
			function()
                for rite, bool in pairs(vanilla_tomb_king_rite) do
                    cm:lock_ritual(faction, rite)--it will lock the ritual at the start of the turn, AI is less likely to use it
                end
            end,
            0.1
		)
		if faction:is_human() and cm:get_saved_value("dread_ritual_tmb_awakening_unlock") ~= true then
            cm:set_saved_value("dread_ritual_tmb_awakening_unlock",true)
            local incident_builder = cm:create_incident_builder("rhox_dk_unlocked_dread_awakening")
			cm:launch_custom_incident_from_builder(incident_builder, faction)
		end
	end,
	true
)


core:add_listener(
	"rhox_dread_ritual_tmb_awakening_2",
	"GarrisonOccupiedEvent",
	function(context)	
        local region = context:garrison_residence():region();
        return context:character():faction():name() == "ovn_tmb_dread_king" and region:building_exists("dread_citadel_1");
	end,
	function(context)
        local faction = context:character():faction();
        cm:unlock_ritual(faction, "dread_ritual_tmb_awakening", 0)
        
        cm:callback(
			function()
                for rite, bool in pairs(vanilla_tomb_king_rite) do
                    cm:lock_ritual(faction, rite)--it will lock the ritual at the start of the turn, AI is less likely to use it
                end
            end,
            0.1
		)
		if faction:is_human() and cm:get_saved_value("dread_ritual_tmb_awakening_unlock") ~= true then
            cm:set_saved_value("dread_ritual_tmb_awakening_unlock",true)
            local incident_builder = cm:create_incident_builder("rhox_dk_unlocked_dread_awakening")
			cm:launch_custom_incident_from_builder(incident_builder, faction)
		end
	end,
	true
)

core:add_listener(
	"rhox_dread_ritual_tmb_conquest",
	"FactionTurnStart",
	function(context)	
        local faction = context:faction();
					
        if faction:name() == "ovn_tmb_dread_king" then
            local mf_list = faction:military_force_list();
            local units = 0;
            
            for i = 0, mf_list:num_items() - 1 do
                local current_mf = mf_list:item_at(i);
                
                if current_mf:has_general() and not current_mf:is_armed_citizenry() then
                    units = units + current_mf:unit_list():num_items();
                end;
            end;
            
            return units > 19;
        end;
	end,
	function(context)
        local faction = context:faction();
        cm:unlock_ritual(faction, "dread_ritual_tmb_conquest", 0)
        cm:callback(
			function()
                for rite, bool in pairs(vanilla_tomb_king_rite) do
                    cm:lock_ritual(faction, rite)--it will lock the ritual at the start of the turn, AI is less likely to use it
                end
            end,
            0.1
		)
		if faction:is_human() and cm:get_saved_value("dread_ritual_tmb_conquest_unlock") ~= true then
            cm:set_saved_value("dread_ritual_tmb_conquest_unlock",true)
            local incident_builder = cm:create_incident_builder("rhox_dk_unlocked_dread_conquest")
			cm:launch_custom_incident_from_builder(incident_builder, faction)
		end
	end,
	true
)

core:add_listener(
	"rhox_dread_ritual_tmb_necromancy_1",
	"CharacterCharacterTargetAction",
	function(context)	
        local character = context:character();
        return character:faction():name() == "ovn_tmb_dread_king" and character:character_type("engineer");
	end,
	function(context)
        local faction = context:character():faction();
        cm:unlock_ritual(faction, "dread_ritual_tmb_necromancy", 0)
        cm:callback(
			function()
                for rite, bool in pairs(vanilla_tomb_king_rite) do
                    cm:lock_ritual(faction, rite)--it will lock the ritual at the start of the turn, AI is less likely to use it
                end
            end,
            0.1
		)
		if faction:is_human() and cm:get_saved_value("dread_ritual_tmb_necromancy_unlock") ~= true then
            cm:set_saved_value("dread_ritual_tmb_necromancy_unlock",true)
            local incident_builder = cm:create_incident_builder("rhox_dk_unlocked_dread_necromancy")
			cm:launch_custom_incident_from_builder(incident_builder, faction)
		end
	end,
	true
)


core:add_listener(
	"rhox_dread_ritual_tmb_necromancy_2",
	"CharacterGarrisonTargetAction",
	function(context)	
        local character = context:character();
        return character:faction():name() == "ovn_tmb_dread_king" and character:character_type("engineer");
	end,
	function(context)
        local faction = context:character():faction();
        cm:unlock_ritual(faction, "dread_ritual_tmb_necromancy", 0)
        cm:callback(
			function()
                for rite, bool in pairs(vanilla_tomb_king_rite) do
                    cm:lock_ritual(faction, rite)--it will lock the ritual at the start of the turn, AI is less likely to use it
                end
            end,
            0.1
		)
		if faction:is_human() and cm:get_saved_value("dread_ritual_tmb_necromancy_unlock") ~= true then
            cm:set_saved_value("dread_ritual_tmb_necromancy_unlock",true)
            local incident_builder = cm:create_incident_builder("rhox_dk_unlocked_dread_necromancy")
			cm:launch_custom_incident_from_builder(incident_builder, faction)
		end
	end,
	true
)














