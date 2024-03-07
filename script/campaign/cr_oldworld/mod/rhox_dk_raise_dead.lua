
-------------------------------------------------------------------------------initial setup
local raise_dead_list={  --this is for the initial add
    "ovn_dk_inf_skeleton_hoplites_no_caps",
    "ovn_dk_inf_skeleton_pikemen_no_caps",
    "ovn_dk_inf_skeleton_javelinmen_no_caps",
    "wh2_dlc09_tmb_inf_skeleton_archers_no_caps",
    "ovn_dk_cav_skeleton_horsemen_no_caps",
    "ovn_dk_cav_skeleton_horsemen_archers_no_caps",
    "ovn_dk_mon_skeleton_elephant_no_caps",
    "ovn_dk_mon_skeleton_giant_no_caps",
    "ovn_dk_mon_skeletal_minotaurs_no_caps",
    "ovn_dk_mon_bone_hydra_no_caps"
}



cm:add_first_tick_callback_new(
    function()
        local faction = cm:get_faction("ovn_tmb_dread_king")
        for k, unit in pairs(raise_dead_list) do
            --out("Rhox DK: Unit key: " .. unit .. " / Group key: ".. "rhox_dk_"..unit)
            cm:add_unit_to_faction_mercenary_pool(
                faction,
                unit,
                "rhox_dk_raise_dead",
                0,--temp
                100,
                20,
                0,
                "",
                "",
                "",
                false,
                "rhox_dk_"..unit
            )
        end
    end
);

-----------------------------------------------------------------------listeners
RHOX_DREADKING_NECROMANCY_UNIT_TABLE={
    wh2_dlc10_def_mon_war_hydra_boss = "ovn_dk_mon_bone_hydra_no_caps",
    wh2_dlc15_grn_mon_feral_hydra_waaagh_0 = "ovn_dk_mon_bone_hydra_no_caps",
    wh2_main_def_mon_war_hydra = "ovn_dk_mon_bone_hydra_no_caps",
    wh2_dlc10_def_mon_chill_of_sontar_ror_0 = "ovn_dk_mon_bone_hydra_no_caps",
    
    wh3_main_ogr_mon_giant_0 ="ovn_dk_mon_skeleton_giant_no_caps",
    wh_dlc03_bst_mon_giant_0 ="ovn_dk_mon_skeleton_giant_no_caps",
    wh_dlc08_grn_mon_giant_boss ="ovn_dk_mon_skeleton_giant_no_caps",
    wh_dlc08_nor_mon_norscan_giant_0 ="ovn_dk_mon_skeleton_giant_no_caps",
    wh_main_chs_mon_giant ="ovn_dk_mon_skeleton_giant_no_caps",
    wh_main_grn_mon_giant ="ovn_dk_mon_skeleton_giant_no_caps",
    wh_main_grn_mon_giant_qb_tall_roff ="ovn_dk_mon_skeleton_giant_no_caps",
    wh3_dlc20_chs_mon_giant_mnur_ror ="ovn_dk_mon_skeleton_giant_no_caps",
    albion_giant ="ovn_dk_mon_skeleton_giant_no_caps",
    ovn_alb_inf_stone_throw_giant ="ovn_dk_mon_skeleton_giant_no_caps",
    albion_bologs_giant_ror ="ovn_dk_mon_skeleton_giant_no_caps",
    albion_cachtorr_stonethrower ="ovn_dk_mon_skeleton_giant_no_caps",
    
    ovn_arb_mon_elephant ="ovn_dk_mon_skeleton_elephant_no_caps",
    ovn_arb_mon_war_elephant ="ovn_dk_mon_skeleton_elephant_no_caps",
    ovn_arb_mon_war_elephant_ror_1 ="ovn_dk_mon_skeleton_elephant_no_caps",
    ovn_arb_mon_war_elephant_ror_2 ="ovn_dk_mon_skeleton_elephant_no_caps",
    
    wh_dlc03_bst_inf_minotaurs_0 ="ovn_dk_mon_skeletal_minotaurs_no_caps",
    wh_dlc03_bst_inf_minotaurs_1 ="ovn_dk_mon_skeletal_minotaurs_no_caps",
    wh_dlc03_bst_inf_minotaurs_2 ="ovn_dk_mon_skeletal_minotaurs_no_caps",
    wh_pro04_bst_inf_minotaurs_ror_0 ="ovn_dk_mon_skeletal_minotaurs_no_caps",
    bst_mino_nurgle ="ovn_dk_mon_skeletal_minotaurs_no_caps",
    bst_mino_slaanesh ="ovn_dk_mon_skeletal_minotaurs_no_caps",
    bst_mino_tzeentch ="ovn_dk_mon_skeletal_minotaurs_no_caps",
    bst_mino_nurgle_2 ="ovn_dk_mon_skeletal_minotaurs_no_caps",
    bst_mino_slaanesh_2 ="ovn_dk_mon_skeletal_minotaurs_no_caps",
    bst_mino_tzeentch_2 ="ovn_dk_mon_skeletal_minotaurs_no_caps",
    bst_mino_khornataurs_2 ="ovn_dk_mon_skeletal_minotaurs_no_caps",
    wh3_main_kho_mon_khornataurs_0 ="ovn_dk_mon_skeletal_minotaurs_no_caps",
    wh3_main_kho_mon_khornataurs_1 ="ovn_dk_mon_skeletal_minotaurs_no_caps"
}

local culture_unit_category_table={
    wh2_main_def_dark_elves =true,
    wh2_main_hef_high_elves =true,
    wh3_main_cth_cathay =true,
    wh_dlc05_wef_wood_elves =true,
    wh_dlc08_nor_norsca =true,
    wh_main_brt_bretonnia =true,
    wh_main_emp_empire =true,
    mixer_teb_southern_realms =true,
    ovn_albion =true,
    ovn_amazon =true,
    ovn_araby =true,
    ovn_halflings =true,
    mixer_nip_nippon =true,
    mixer_nur_rotbloods =true,
    mixer_hng_hung =true
}



function get_enemy_units_in_last_battle(character)
	local pb = cm:model():pending_battle();
	local attackers_corpse = {};
	local defenders_corpse = {};
	local was_attacker = false;

	local num_attackers = cm:pending_battle_cache_num_attackers();
	local num_defenders = cm:pending_battle_cache_num_defenders();
    
    local culture_check = false

	if pb:night_battle() == true or pb:ambush_battle() == true then
		num_attackers = 1;
		num_defenders = 1;
	end
	
	for i = 1, num_attackers do
		local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_attacker(i);
		local faction_key = cm:pending_battle_cache_get_attacker_faction_name(i)
		local faction = cm:get_faction(faction_key)
		if culture_unit_category_table[faction:culture()] then
            out("Rhox DK: This faction's culture is Human or Elf")
            culture_check = true
        end
            
            
		if this_char_cqi == character:cqi() then
			was_attacker = true;
			break;
		end
		
        local num_attacker_unit = cm:pending_battle_cache_num_attacker_units(i);

        --out("Rhox_LH/ Number of attacking units:" .. tostring(num_attacker_unit));
        for j = 1, num_attacker_unit do
            local cqi, unit_key = cm:pending_battle_cache_get_attacker_unit(i,j);
            --out("Rhox DK: unit_key:" .. unit_key);
            if RHOX_DREADKING_NECROMANCY_UNIT_TABLE[unit_key] then
                out("Rhox DK: This unit is special: ".. unit_key)
                local target = RHOX_DREADKING_NECROMANCY_UNIT_TABLE[unit_key]
                local value =1
                if attackers_corpse[target] then
                    value = attackers_corpse[target]+1
                end
                attackers_corpse[target]=value
            end
        end
	end
	
	if was_attacker == false then
		return attackers_corpse, culture_check;
	end
	
	for i = 1, num_defenders do
		local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_defender(i);
        local faction_key = cm:pending_battle_cache_get_defender_faction_name(i)
		local faction = cm:get_faction(faction_key)
		if culture_unit_category_table[faction:culture()] then
            out("Rhox DK: This faction is Human or Elf")
            culture_check = true
        end
		
		
		
        local num_defender_unit = cm:pending_battle_cache_num_defender_units(i);
        for j = 1, num_defender_unit do
            local cqi, unit_key = cm:pending_battle_cache_get_defender_unit(i,j);
            --out("Rhox DK: unit_key:" .. unit_key);
            if RHOX_DREADKING_NECROMANCY_UNIT_TABLE[unit_key] then
                out("Rhox DK: This unit is special: ".. unit_key)
                local target = RHOX_DREADKING_NECROMANCY_UNIT_TABLE[unit_key]
                local value =1
                if defenders_corpse[target] then
                    value = defenders_corpse[target]+1
                end
                defenders_corpse[target]=value
            end
        end
	end
	return defenders_corpse, culture_check;
end


local common_raise_dead_list={
    "ovn_dk_inf_skeleton_hoplites_no_caps",
    "ovn_dk_inf_skeleton_pikemen_no_caps",
    "ovn_dk_inf_skeleton_javelinmen_no_caps",
    "wh2_dlc09_tmb_inf_skeleton_archers_no_caps",
    "ovn_dk_cav_skeleton_horsemen_no_caps",
    "ovn_dk_cav_skeleton_horsemen_archers_no_caps"
}

local function rhox_dk_raise_dead_listener()
	core:add_listener(
		"rhox_dk_battle_listner",
		"CharacterCompletedBattle",
		function(context)
			local character = context:character();
            return character:faction():name() == "ovn_tmb_dread_king" and cm:char_is_general_with_army(character) and character:won_battle()
		end,
		function(context)
			local character = context:character();
            local beaten_enemies, culture_check = get_enemy_units_in_last_battle(character);
			local count = 0
			for unit_key, number in pairs(beaten_enemies) do
				count = count+1
			end
            if count~=0 or (culture_check == true and cm:model():random_percent(40)) then
                out("Rhox DK: You're getting a raise dead unit!!")
                local incident_builder = cm:create_incident_builder("rhox_dk_after_battle")
                incident_builder:add_target(character)
                local payload_builder = cm:create_payload()
                payload_builder:text_display("dummy_rhox_dk_raise_dead1")
                payload_builder:text_display("dummy_rhox_dk_raise_dead2")
                payload_builder:text_display("dummy_rhox_dk_raise_dead3")
                
                if culture_check == true then
                    local target = cm:random_number(#common_raise_dead_list,1)
                    out("Rhox DK unit key: ".. common_raise_dead_list[target])
                    payload_builder:add_mercenary_to_faction_pool(common_raise_dead_list[target], 1)  
                end
                
                if count ~=0 then
                    for unit_key, number in pairs(beaten_enemies) do
                        payload_builder:add_mercenary_to_faction_pool(unit_key, number)  
						out("Rhox DK: Special unit: ".. unit_key .. " /and number ".. number)
                    end
                end
                
                
                --
                incident_builder:set_payload(payload_builder)
                cm:launch_custom_incident_from_builder(incident_builder, character:faction())
            end
		end,
		true
	);
end


cm:add_first_tick_callback(
	function()
		rhox_dk_raise_dead_listener()
	end
);