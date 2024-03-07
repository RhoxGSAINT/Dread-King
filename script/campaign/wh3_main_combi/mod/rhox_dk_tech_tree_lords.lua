local special_characters = {
	["dread_king_tech_14"] = {forename = "names_name_311089124", surname = "", subtype = "dread_possessed_hero_01"},
	["dread_king_tech_49"] = {forename = "names_name_311089125", surname = "", subtype = "dread_possessed_hero_02"},
    ["dread_king_tech_51"] = {forename = "names_name_311089126", surname = "", subtype = "dread_traitor_tomb_king_haptmose"},		
	["dread_king_tech_57"] = {forename = "names_name_311089127", surname = "", subtype = "dread_traitor_tomb_king_nebwaneph"},
	["dread_king_tech_64"] = {forename = "names_name_311089128", surname = "", subtype = "dread_traitor_tomb_king_omanhan_iii"},
	["dread_king_tech_hand"] = {forename = "names_name_247259237", surname = "names_name_247259238", subtype = "elo_hand_of_nagash"}
};


local function rhox_dk_techtree_listener()
    core:add_listener(
		"rhox_dk_ResearchCompleted",
		"ResearchCompleted",
		function(context)
			local tech_key = context:technology();
            return special_characters[tech_key]
		end,
		function(context)
            local faction = context:faction();
			local tech_key = context:technology();
            local character_info = special_characters[tech_key]
            cm:spawn_character_to_pool(faction:name(), character_info.forename, character_info.surname, "", "", 18, true, "general", character_info.subtype, true, "");
		end,
		true
	);
end


local function rhox_dk_ai_techtree_listener()
    core:add_listener(
        "rhox_dk_ai_tech_turn_start",
        "FactionTurnStart",
        function(context)
            return context:faction():name() == "ovn_tmb_dread_king"
        end,
        function(context)
            local faction = context:faction()
            for tech_key, contents in pairs(special_characters) do
                if faction:has_technology(tech_key) and cm:get_saved_value("ai"..tech_key) ~= true then
                    out("Rhox DK: Dreadking has researched: "..tech_key)
                    cm:set_saved_value("ai"..tech_key, true)
                    cm:spawn_character_to_pool(faction:name(), contents.forename, contents.surname, "", "", 18, true, "general", contents.subtype, true, "");
                end
            end
        end,
        true
    )
end



	
	
cm:add_first_tick_callback(
	function()
        if cm:get_faction("ovn_tmb_dread_king"):is_human() then
		    rhox_dk_techtree_listener()
        else
            rhox_dk_ai_techtree_listener()
        end
	end
);

local vanilla_tech_list={
    wh2_dlc09_tech_tmb_campaign_bonus_1_1 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_1_2 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_1_3 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_2_1 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_2_2 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_2_3 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_3_1 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_3_2 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_3_3 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_4_1 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_4_2 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_4_3 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_5_1 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_5_2 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_5_3 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_6_1 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_6_2 =true,
    wh2_dlc09_tech_tmb_campaign_bonus_6_3 =true,
    wh2_dlc09_tech_tmb_dynasty_1 =true,
    wh2_dlc09_tech_tmb_dynasty_2 =true,
    wh2_dlc09_tech_tmb_dynasty_3 =true,
    wh2_dlc09_tech_tmb_dynasty_4 =true,
    wh2_dlc09_tech_tmb_dynasty_5 =true,
    wh2_dlc09_tech_tmb_dynasty_6 =true,
    wh2_dlc09_tech_tmb_extra_army_1 =true,
    wh2_dlc09_tech_tmb_extra_army_2 =true,
    wh2_dlc09_tech_tmb_extra_army_3 =true,
    wh2_dlc09_tech_tmb_extra_army_4 =true,
    wh2_dlc09_tech_tmb_extra_army_5 =true,
    wh2_dlc09_tech_tmb_extra_army_6 =true,
    wh2_dlc09_tech_tmb_extra_army_7 =true,
    wh2_dlc09_tech_tmb_faction_target_1 =true,
    wh2_dlc09_tech_tmb_faction_target_2 =true,
    wh2_dlc09_tech_tmb_faction_target_3 =true,
    wh2_dlc09_tech_tmb_faction_target_4 =true,
    wh2_dlc09_tech_tmb_faction_target_5 =true,
    wh2_dlc09_tech_tmb_faction_target_6 =true,
    wh2_dlc09_tech_tmb_legions_of_legend =true,
    wh2_dlc09_tech_tmb_liche_priest_1 =true,
    wh2_dlc09_tech_tmb_liche_priest_2 =true,
    wh2_dlc09_tech_tmb_liche_priest_3 =true,
    wh2_dlc09_tech_tmb_liche_priest_4 =true,
    wh2_dlc09_tech_tmb_liche_priest_5 =true,
    wh2_dlc09_tech_tmb_liche_priest_6 =true,
    wh2_dlc09_tech_tmb_necrotect_1 =true,
    wh2_dlc09_tech_tmb_necrotect_2 =true,
    wh2_dlc09_tech_tmb_necrotect_3 =true,
    wh2_dlc09_tech_tmb_necrotect_4 =true,
    wh2_dlc09_tech_tmb_necrotect_5 =true,
    wh2_dlc09_tech_tmb_necrotect_6 =true,
    wh2_dlc09_tech_tmb_tomb_king_1 =true,
    wh2_dlc09_tech_tmb_tomb_king_2 =true,
    wh2_dlc09_tech_tmb_tomb_king_3 =true,
    wh2_dlc09_tech_tmb_tomb_king_4 =true,
    wh2_dlc09_tech_tmb_tomb_king_5 =true,
    wh2_dlc09_tech_tmb_tomb_king_6 =true,
    wh2_dlc09_tech_tmb_tomb_prince_1 =true,
    wh2_dlc09_tech_tmb_tomb_prince_2 =true,
    wh2_dlc09_tech_tmb_tomb_prince_3 =true,
    wh2_dlc09_tech_tmb_tomb_prince_4 =true,
    wh2_dlc09_tech_tmb_tomb_prince_5 =true,
    wh2_dlc09_tech_tmb_tomb_prince_6 =true,
}

cm:add_first_tick_callback_new(
	function()
        for tech_key, value in pairs(vanilla_tech_list) do
			cm:lock_technology("ovn_tmb_dread_king",tech_key)
		end
	end
);



