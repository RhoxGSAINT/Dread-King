local dk_ror_units = {
    "ovn_dk_inf_wights_ror",
    "ovn_dk_inf_mummies_ror",
    "ovn_dk_inf_catacomb_guardians_ror",
    "ovn_dk_cav_black_grail_knights_ror",        
    "ovn_dk_mon_skeleton_elephant_ror",
    "ovn_dk_inf_spartan_ror",
    "ovn_dk_inf_thessos_ror",
    "ovn_dk_cav_ephalian_ror",
    "ovn_dk_art_polybolos_ror"
}

local defaults = {
    replen_chance = 100,
    max = 1,
    max_per_turn = 0.1,
    xp_level = 0,
    faction_restriction = "",
    subculture_restriction = "",
    tech_restriction = "",
    partial_replenishment = true,
}

cm:add_first_tick_callback_new(
	function()
        local faction = cm:get_faction("wh3_dlc29_nag_host_of_nagash")
        for _, unit_key in ipairs(dk_ror_units) do
            cm:add_unit_to_faction_mercenary_pool(
                faction,
                unit_key,
                "wh3_main_regiments_of_renown_pool",
                1,
                defaults.replen_chance,
                defaults.max,
                defaults.max_per_turn,
                defaults.faction_restriction,
                defaults.subculture_restriction,
                defaults.tech_restriction,
                defaults.partial_replenishment,
                unit_key
            )
        end
	end
)

-----------------------------------------------------------------------RoR Table insert
nagash_rors.rituals["rhox_nag_mortarchs_dk_arkhan"]="ovn_tmb_dread_king"
nagash_rors.agents["Dread_King"] = "ovn_tmb_dread_king"
nagash_rors.unit_locks["ovn_tmb_dread_king"] = dk_ror_units


-------------------------------------------------------------------------Mortarch table insert

nag_mortarchs_config.dynamic_ritual_data["rhox_nag_mortarchs_dk_arkhan"] = {agent = "Dread_King", general = true}
nag_mortarchs_config.incidnet_keys["rhox_nag_mortarchs_dk_arkhan"]= "rhox_nag_incident_mortarch_subjugated_dk"
nag_mortarchs_config.initial_missions["rhox_nag_mortarchs_dk_arkhan"] = {
    target_faction = "ovn_tmb_dread_king",
    limit_power_objective = false,
    payload = "text_display dummy_wh3_dlc24_mission_schemes_reveal_shroud_payload",	-- Mandatory there is at least one payload, but it isn't shown in the UI.
    unique_objectives_config = {
        khemri_objective_key = "scripted_mis_ovn_nag_mortarchs_pyramid_of_settra",
        valid_building_keys = {
            "wh3_dlc29_special_khemri_nag",
        }
    },

    add_unique_objectives = function(faction_key, mm, mission_data, mission_key)
        local objectives = {
            -- Kill 5,000 enemies using Dread King units
            generate_KILL_X_ENTITIES_BY_objective(
                5000,
                "dk_all",
                "mission_text_text_ovn_kill_n_entities_with_dk_units",
                true
            ),

            -- Construct Settra's Pyramid in Khemri
            generate_CONSTRUCT_BUILDINGS_INCLUDING_objective(
                1,
                faction_key,
                mission_data.valid_building_keys,
                nil,
                "mission_text_text_" .. mission_data.khemri_objective_key,
                "wh3_main_combi_region_khemri"
            )
        }

        nag_mortarchs:add_non_scripted_objectives(faction_key, mm, objectives)
    end,

    ai_unlock_conditions = function(self)
        local khemri_region = cm:get_region("wh3_main_combi_region_khemri")

        if khemri_region:owning_faction():name() ~= nag_mortarchs_config.faction_key then
            return false
        end

        for _, building_key in ipairs(self.unique_objectives_config.valid_building_keys) do
            if khemri_region:building_exists(building_key) then
                return cm:model():turn_number() > 5 -- precaution against early subjugation
            end
        end

        return false
    end
}

table.insert(nag_mortarchs_config.ritual_keys, "rhox_nag_mortarchs_dk_arkhan")


-------------------------------Dieter missions

table.insert(nag_mortarchs_config.initial_missions["wh3_dlc29_nag_mortarchs_dieter"].unique_objectives_config.ritual_list, "wh3_dlc29_ritual_nag_unit_capacity_cav_royal_guard")
table.insert(nag_mortarchs_config.initial_missions["wh3_dlc29_nag_mortarchs_dieter"].unique_objectives_config.ritual_list, "wh3_dlc29_ritual_nag_unit_capacity_inf_hoplites_and_pikes")
table.insert(nag_mortarchs_config.initial_missions["wh3_dlc29_nag_mortarchs_dieter"].unique_objectives_config.ritual_list, "wh3_dlc29_ritual_nag_unit_capacity_inf_mummies")
table.insert(nag_mortarchs_config.initial_missions["wh3_dlc29_nag_mortarchs_dieter"].unique_objectives_config.ritual_list, "wh3_dlc29_ritual_nag_unit_capacity_inf_tomb_guardians")
table.insert(nag_mortarchs_config.initial_missions["wh3_dlc29_nag_mortarchs_dieter"].unique_objectives_config.ritual_list, "wh3_dlc29_ritual_nag_unit_capacity_inf_tomb_guardians_peltasts")
table.insert(nag_mortarchs_config.initial_missions["wh3_dlc29_nag_mortarchs_dieter"].unique_objectives_config.ritual_list, "wh3_dlc29_ritual_nag_unit_capacity_mon_bone_colossus")
table.insert(nag_mortarchs_config.initial_missions["wh3_dlc29_nag_mortarchs_dieter"].unique_objectives_config.ritual_list, "wh3_dlc29_ritual_nag_unit_capacity_mon_bone_hydra")
table.insert(nag_mortarchs_config.initial_missions["wh3_dlc29_nag_mortarchs_dieter"].unique_objectives_config.ritual_list, "wh3_dlc29_ritual_nag_unit_capacity_mon_skeletal_elephant")
table.insert(nag_mortarchs_config.initial_missions["wh3_dlc29_nag_mortarchs_dieter"].unique_objectives_config.ritual_list, "wh3_dlc29_ritual_nag_unit_capacity_mon_skeletal_minotaurs")

-------------------------------hand summon

core:add_listener(
    "rhox_nagash_dk_subjugated",
    "RitualCompletedEvent",
    function(context)
    return context:ritual():ritual_key() == "rhox_nag_mortarchs_dk_arkhan" and context:succeeded()
    end,
    function(context)
        if not nag_mortarchs:is_mortarch_spawned("elo_hand_of_nagash") then
            cm:spawn_character_to_pool("wh3_dlc29_nag_host_of_nagash", "names_name_311089132", "names_name_311089133", "", "", 18, true, "general", "elo_hand_of_nagash", true, "");
        end
    end,
    true
)

------------------------------------------------------------- Dread King Unit Conversion

local dk_unit_conversions = {
    -- Dread King unit record = Nagash unit record

    ["ovn_dk_inf_cairn_wraiths"] = "wh_main_vmp_inf_cairn_wraiths",
    ["ovn_dk_veh_mortis_engine_0"] = "wh_dlc04_vmp_veh_mortis_engine_0",
    ["ovn_dk_cav_hexwraiths"] = "wh_main_vmp_cav_hexwraiths",
    ["ovn_dk_inf_crypt_ghouls"] = "wh_main_vmp_inf_crypt_ghouls",
    ["ovn_dk_mon_dire_wolves"] = "wh_main_vmp_mon_dire_wolves",
    ["ovn_dk_mon_fell_bats"] = "wh_main_vmp_mon_fell_bats",
    ["dread_mon_ushabti_0"] = "wh2_dlc09_tmb_mon_ushabti_0",
    ["dread_mon_ushabti_1"] = "wh2_dlc09_tmb_mon_ushabti_1",
    ["dread_inf_tomb_guard_0"] = "wh2_dlc09_tmb_inf_tomb_guard_0",
    ["dread_inf_tomb_guard_1"] = "wh2_dlc09_tmb_inf_tomb_guard_1",
    ["ovn_dk_mon_morghast_archai"] = "wh3_dlc29_vmp_mon_morghast_archai",
    ["ovn_dk_mon_morghast_harbingers"] = "wh3_dlc29_vmp_mon_morghast_harbingers",
}

core:add_listener(
    "rhox_nagash_dk_convert_units_on_confederation",
    "FactionJoinsConfederation",
    function(context)
        return context:confederation():name() == "wh3_dlc29_nag_host_of_nagash"
            and (
                context:faction():name() == "ovn_tmb_dread_king"
            )
    end,
    function(context)
        local units_to_convert = {}
        local faction = context:confederation()
        local military_force_list = faction:military_force_list()

        -- Collect CQIs before replacing units
        for i = 0, military_force_list:num_items() - 1 do
            local unit_list = military_force_list:item_at(i):unit_list()

            for j = 0, unit_list:num_items() - 1 do
                local unit = unit_list:item_at(j)
                local target_unit_key = dk_unit_conversions[unit:unit_key()]

                if target_unit_key then
                    table.insert(units_to_convert, {
                        cqi = unit:command_queue_index(),
                        target_unit_key = target_unit_key
                    })
                end
            end
        end

        for _, entry in ipairs(units_to_convert) do
            cm:convert_unit(entry.cqi, entry.target_unit_key)
        end
    end,
    true
)
