-- Adds extra units to Nagash's Grave Call (Necromancy recruitment) and locks them behind a Black Pyramid sigil.
-- Made by Druwski at Da Modding Den, re-use in mods as needed

-- Units to add. One row per unit:
--   unit    main_units key
--   group   the mercenary_unit_groups key you made for it (same key as in mercenary_pool_to_groups_junctions)
--   section which Grave Call column: 'tmb', 'cst' or 'vmp'
--   sigil   Black Pyramid sigil that unlocks it, or nil to have it unlocked from the start
local units = {
	{ unit = 'ovn_dk_inf_mummies', group = 'ovn_dk_inf_mummies_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_skeleton_10' },
	{ unit = 'ovn_dk_inf_skeleton_hoplites', group = 'ovn_dk_inf_skeleton_hoplites_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_guards_4' },
    { unit = 'ovn_dk_inf_skeleton_pikemen', group = 'ovn_dk_inf_skeleton_pikemen_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_guards_4' },
    { unit = 'ovn_dk_inf_skeleton_javelinmen', group = 'ovn_dk_inf_skeleton_javelinmen_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_skeleton_2' },
    { unit = 'ovn_dk_inf_tomb_guardian', group = 'ovn_dk_inf_tomb_guardian_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_guards_6' },
    { unit = 'ovn_dk_inf_tomb_guardian_great_weapons', group = 'ovn_dk_inf_tomb_guardian_great_weapons_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_guards_6' },
    { unit = 'ovn_dk_inf_tomb_guardian_peltasts', group = 'ovn_dk_inf_tomb_guardian_peltasts_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_guards_6' },
    { unit = 'ovn_dk_cav_royal_guard_cavalry', group = 'ovn_dk_cav_royal_guard_cavalry_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_horsemen_7' },
    { unit = 'ovn_dk_cav_royal_guard_lancers', group = 'ovn_dk_cav_royal_guard_lancers_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_horsemen_7' },
    { unit = 'ovn_dk_mon_skeletal_minotaurs', group = 'ovn_dk_mon_skeletal_minotaurs_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_undead_monstrous_4' },
    { unit = 'ovn_dk_mon_skeleton_giant', group = 'ovn_dk_mon_skeleton_giant_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_undead_monsters_1' },
    { unit = 'ovn_dk_mon_skeleton_elephant', group = 'ovn_dk_mon_skeleton_elephant_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_undead_monstrous_1' },
    { unit = 'ovn_dk_mon_bone_hydra', group = 'ovn_dk_mon_bone_hydra_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_undead_monsters_1' },
    { unit = 'ovn_dk_art_screaming_skull_ballista', group = 'ovn_dk_art_screaming_skull_ballista_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_magic_artillery_1' },
    { unit = 'ovn_dk_art_bone_throwers', group = 'ovn_dk_art_bone_throwers_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_magic_artillery_1' },
    { unit = 'ovn_dk_inf_skeleton_archers_0', group = 'ovn_dk_inf_skeleton_archers_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_skeleton_2' },
    { unit = 'ovn_dk_inf_skeleton_spearmen_0', group = 'ovn_dk_inf_skeleton_spearmen_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_skeleton_2' },
    { unit = 'ovn_dk_inf_skeleton_warriors_0', group = 'ovn_dk_inf_skeleton_warriors_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_skeleton_2' },
    { unit = 'ovn_dk_cav_skeleton_horsemen_0', group = 'ovn_dk_cav_skeleton_horsemen_0_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_horsemen_1' },
    { unit = 'ovn_dk_cav_skeleton_horsemen_archers_0', group = 'ovn_dk_cav_skeleton_horsemen_archers_0_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_archers_1' },
    { unit = 'ovn_dk_veh_skeleton_chariot', group = 'ovn_dk_veh_skeleton_chariot_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_chariots_1' },
    { unit = 'ovn_dk_veh_skeleton_archer_chariot', group = 'ovn_dk_veh_skeleton_archer_chariot_nag', section = 'tmb', sigil = 'wh3_dlc29_black_pyramid_chariots_1' },   
}

-- Change the prefix if you copy this file into another mod, so the saved flags don't clash.
local save_prefix = 'dk_gravecall_units_'

local faction_key = 'wh3_dlc29_nag_host_of_nagash'
local subculture_key = 'wh3_dlc29_sc_nag_undead_legions'
local sigil_set_key = 'wh3_dlc29_pyramid_initiative_set'
local pools = {
	tmb = 'wh3_dlc29_nag_raise_dead_tmb_faction_pool',
	cst = 'wh3_dlc29_nag_raise_dead_cst_faction_pool',
	vmp = 'wh3_dlc29_nag_raise_dead_vmp_faction_pool',
    dk = "wh3_dlc29_nag_raise_dead_dk_faction_pool",
}

-- CA's Grave Call script locks units by reading this table, so it has to be filled before the campaign starts
if black_pyramid and black_pyramid.gravecall then
	for _, u in ipairs(units) do
		local section = black_pyramid.gravecall.initiatives[u.section]
		if u.sigil and section then
			-- CA's lock/unlock loops read every key in the section, so a sigil missing from this section can just be added
			section[u.sigil] = section[u.sigil] or {}
			table.insert(section[u.sigil], u.unit)
		elseif u.sigil then
			out('gravecall units: no section ' .. tostring(u.section) .. ', ' .. u.unit .. ' stays unlocked')
		end
	end
end

cm:add_first_tick_callback_new(function()
	local faction = cm:get_faction(faction_key)
	if not faction then return end
	local sigils = faction:lookup_faction_initiative_set_by_key(sigil_set_key)
	for _, u in ipairs(units) do
        local pool = pools[u.section]
        cm:add_unit_to_faction_mercenary_pool(faction, u.unit, pool, 999999, 100, 999999, 100, '', subculture_key, '', false, u.group)
	end
	   
end)