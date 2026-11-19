local dk_gc_column_id = "rhox_dk_gravecall_entry"

local dk_gc_units = {
	ovn_dk_inf_mummies = true,
	ovn_dk_inf_skeleton_hoplites = true,
	ovn_dk_inf_skeleton_pikemen = true,
	ovn_dk_inf_skeleton_javelinmen = true,
	ovn_dk_inf_tomb_guardian = true,
	ovn_dk_inf_tomb_guardian_great_weapons = true,
	ovn_dk_inf_tomb_guardian_peltasts = true,
	ovn_dk_cav_royal_guard_cavalry = true,
	ovn_dk_cav_royal_guard_lancers = true,
	ovn_dk_mon_skeletal_minotaurs = true,
	ovn_dk_mon_skeleton_giant = true,
	ovn_dk_mon_skeleton_elephant = true,
	ovn_dk_mon_bone_hydra = true,
	ovn_dk_art_screaming_skull_ballista = true,
	ovn_dk_art_bone_throwers = true,
	ovn_dk_inf_skeleton_archers_0 = true,
	ovn_dk_inf_skeleton_spearmen_0 = true,
	ovn_dk_inf_skeleton_warriors_0 = true,
	ovn_dk_cav_skeleton_horsemen_0 = true,
	ovn_dk_cav_skeleton_horsemen_archers_0 = true,
	ovn_dk_veh_skeleton_chariot = true,
	ovn_dk_veh_skeleton_archer_chariot = true,
}

local function dk_gc_entry_card_list(uic_entry)
	return find_uicomponent(uic_entry, "listview", "list_clip", "list_box")
end

local function dk_gc_card_unit_key(uic_card)
	local key = string.gsub(uic_card:Id(), "_mercenary$", "")
	if dk_gc_units[key] then
		return key
	end
	return nil
end

local function dk_gc_get_pool_list_box()
	local uic_display = find_uicomponent(core:get_ui_root(), "main_units_panel", "recruitment_options", "mercenary_display")
	if not uic_display or not uic_display:Visible(true) then
		return nil
	end
	return find_uicomponent(uic_display, "mercenary_recruitment_pool_list", "list_clip", "list_box")
end


-- Returns the engine-created entry (column) that currently holds Dread King cards, if any
local function dk_gc_find_source_entry(uic_pool_list_box)
	for i = 0, uic_pool_list_box:ChildCount() - 1 do
		local uic_entry = UIComponent(uic_pool_list_box:Find(i))
		if uic_entry:Id() ~= dk_gc_column_id then
			local uic_cards = dk_gc_entry_card_list(uic_entry)
			if uic_cards then
				for j = 0, uic_cards:ChildCount() - 1 do
					if dk_gc_card_unit_key(UIComponent(uic_cards:Find(j))) then
						return uic_entry, uic_cards
					end
				end
			end
		end
	end
	return nil
end

local function dk_gc_get_or_create_column(uic_pool_list_box, uic_source_entry)
	local uic_column = find_child_uicomponent(uic_pool_list_box, dk_gc_column_id)
	if uic_column then
		return uic_column
	end
	if not uic_source_entry then
		return nil
	end

	uic_column = core:get_or_create_component(dk_gc_column_id, "ui/campaign ui/rhox_dk_gravecall_entry.twui.xml", uic_pool_list_box)

	local uic_header = find_uicomponent(uic_column, "header_frame", "tx_header")
	if uic_header then
		local text = common.get_localised_string("unit_recruitment_queue_sets_screen_name_wh3_dlc29_nag_raise_dead_dk_faction_pool")
		uic_header:SetStateText(text, "")
	end

	return uic_column
end

local function dk_gc_update()
	local uic_pool_list_box = dk_gc_get_pool_list_box()
	if not uic_pool_list_box then
		return
	end

	local uic_source_entry, uic_source_cards = dk_gc_find_source_entry(uic_pool_list_box)
	local uic_column = dk_gc_get_or_create_column(uic_pool_list_box, uic_source_entry)
	if not uic_column then
		return
	end
	local uic_target_cards = dk_gc_entry_card_list(uic_column)
	if not uic_target_cards then
		return
	end

	if uic_source_cards then
		-- Collect first, since adopting changes the child indices
		local to_move = {}
		for j = 0, uic_source_cards:ChildCount() - 1 do
			local uic_card = UIComponent(uic_source_cards:Find(j))
			local key = dk_gc_card_unit_key(uic_card)
			if key then
				table.insert(to_move, {uic = uic_card, key = key})
			end
		end

		for _, entry in ipairs(to_move) do
			for k = uic_target_cards:ChildCount() - 1, 0, -1 do
				local uic_old = UIComponent(uic_target_cards:Find(k))
				if dk_gc_card_unit_key(uic_old) == entry.key then
					-- Detach
					uic_target_cards:Divorce(uic_old:Address())
				end
			end
			uic_source_cards:Divorce(entry.uic:Address())
			uic_target_cards:Adopt(entry.uic:Address())
		end

		if #to_move > 0 then
			uic_target_cards:Layout()
			uic_source_cards:Layout()
			uic_pool_list_box:Layout()
		end
	end

	uic_column:SetVisible(uic_target_cards:ChildCount() > 0)
end


cm:add_first_tick_callback(function()
	if cm:get_local_faction_name(true) == "wh3_dlc29_nag_host_of_nagash" then
		core:add_listener(
			"rhox_dk_gravecall_column_panel",
			"PanelOpenedCampaign",
			function(context)
				return context.string == "mercenary_recruitment"
			end,
			function()
				-- Wait a moment for the engine to build the columns
				cm:real_callback(dk_gc_update, 50)
			end,
			true
		)
	end
end)
