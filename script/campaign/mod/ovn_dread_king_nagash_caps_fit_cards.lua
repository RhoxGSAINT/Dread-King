-- fits the unit cards in Nagash's Necromancy panel to the screen by shrinking or wrapping them, with optional card order and sort
-- made by Druwski from the "Da Modding Den" Discord, re-use in mods as needed

local panel_id = 'dlc29_nag_necromancy'
local categories = { 'inf', 'guns', 'cav', 'beasts', 'war_machines', 'monsters' }
local min_scale = 0.75 -- smallest card scale, below this the groups wrap onto more lines instead
local align_bars = false -- true = push shorter groups down so their bottoms line up in each row

-- optional card order inside each group
-- listed units come first and the rest keep the game order
local card_order = {
	-- 'wh2_dlc11_cst_inf_zombie_deckhands_mob_1',
}

-- optional sort for the unit cards inside each group, the groups themselves keep their order
-- runs after card_order, smallest first: 'name', 'key', 'tier', 'cost', 'class'
-- or function(unit) returning a value, unit is the card's CcoMainUnitRecord
local card_sort = function(unit) return string.format('%02d %s', unit:Call('Tier'), unit:Call('Name')) end
-- local card_sort = nil
-- local card_sort = 'tier'
-- local card_sort = function(unit) return -unit:Call('BaseCost') end

local max_cards_per_line = nil -- most cards on one line in a group, nil = as many as fit
-- local max_cards_per_line = 4

local max_groups_per_row = nil -- most groups side by side, nil = as many as the layout wants
-- local max_groups_per_row = 3

local shrink_cards = true -- false = never shrink cards, go straight to wrapping
local edge_gap = 10 -- free space kept at each side of the list, in pixels

-- when to fit again after the panel opens or a tab is clicked, in ms
-- the second pass catches lists that fill late
local delay_ms = 50
local settle_ms = 300

local log_prefix = '[nagash_caps_fit_cards] ' -- prefix for errors in the script log

-- original card sizes by card id, so re-running on tab clicks doesn't shrink twice
local card_sizes = {}
local moved_groups = {}

local function visible_children(parent)
	local children = {}
	for i = 0, parent:ChildCount() - 1 do
		local child = UIComponent(parent:Find(i))
		if child:Visible() then children[#children + 1] = { index = i, component = child } end
	end
	return children
end

-- find_uicomponent is recursive and can match nested ids
local function direct_child(parent, id)
	for i = 0, parent:ChildCount() - 1 do
		local child = UIComponent(parent:Find(i))
		if child:Id() == id then return child end
	end
end

local function width_limit(panel)
	local listview = find_uicomponent(panel, 'unit_categories_listview') or panel
	local x = listview:Position()
	local width = listview:Dimensions()
	local right = x + width
	local slider = direct_child(listview, 'vslider')
	if slider then
		local slider_x = slider:Position()
		right = math.min(right, slider_x)
	end
	return 2 * (right - (x + width / 2)) - 2 * edge_gap
end

local sort_values = {
	name = function(unit) return unit:Call('Name') end,
	key = function(unit) return unit:Call('Key') end,
	tier = function(unit) return unit:Call('Tier') end,
	cost = function(unit) return unit:Call('BaseCost') end,
	class = function(unit) return unit:Call('ClassName') end,
}

local pinned = {}
for i, key in ipairs(card_order) do
	pinned['CcoMainUnitRecord' .. key] = i
end

local function card_values(list, value)
	local kind
	for _, card in ipairs(list) do
		local unit = cco('CcoMainUnitRecord', (card.component:Id():gsub('^CcoMainUnitRecord', '')))
		card.value = unit and value(unit)
		if card.value == nil or (kind and type(card.value) ~= kind) then return false end
		kind = type(card.value)
	end
	return true
end

-- the list draws children in child order, Adopt at an index moves the card and its unit binding
local function order_cards(cards)
	local list = visible_children(cards)
	if #list == 0 then return end
	local first = list[1].index
	local value = type(card_sort) == 'function' and card_sort or sort_values[card_sort]
	local by_value = value and card_values(list, value)
	for _, card in ipairs(list) do
		card.pin = pinned[card.component:Id()]
	end
	table.sort(list, function(a, b)
		if a.pin or b.pin then
			if a.pin and b.pin then return a.pin < b.pin end
			return a.pin ~= nil
		end
		if by_value and a.value ~= b.value then return a.value < b.value end
		return a.index < b.index
	end)
	for i, card in ipairs(list) do
		cards:Adopt(card.component:Address(), first + i - 1)
	end
	cards:Layout()
end

local function read_group(group, engine_path)
	local cards = direct_child(group.component, 'unit_image_list')
	local bar = direct_child(group.component, 'group_info_holder')
	if not cards or not bar then return end
	if #card_order > 0 or card_sort then order_cards(cards) end
	group.cards = visible_children(cards)
	group.cards_component = cards
	group.bar = bar
	group.engine = engine_path .. '.ChildList.At(' .. group.index .. ').ChildContext("unit_image_list").ListLayoutContext'
	for i = 1, #group.cards do
		local card = group.cards[i].component
		local key = card:Id()
		if not card_sizes[key] then
			local width, height = card:Dimensions()
			if width <= 0 or height <= 0 then return false end
			card_sizes[key] = { width, height }
		end
		group.cards[i].size = card_sizes[key]
	end
	return #group.cards > 0
end

local function cards_bottom(group)
	local bottom = 0
	for i = 1, #group.cards do
		local _, y = group.cards[i].component:Position()
		local _, h = group.cards[i].component:Dimensions()
		bottom = math.max(bottom, y + h)
	end
	return bottom
end

local function close_gap(panel_context, group)
	local _, bar_y = group.bar:Position()
	local gap = bar_y - cards_bottom(group)
	if gap <= 0 then return false end
	local vertical = panel_context:Call(group.engine .. '.IsVertical')
	local margins = vertical and 'Margins' or 'SecondaryMargins'
	local start = panel_context:Call(group.engine .. '.' .. margins .. '.x') or 0
	local finish = panel_context:Call(group.engine .. '.' .. margins .. '.y') or 0
	if finish <= 0 then return false end
	panel_context:Call(group.engine .. '.Set' .. margins .. '(ToVector(' .. start .. ', ' .. math.max(0, finish - gap) .. '))')
	group.component:Layout()
	return true
end

local function scale_cards(group, scale)
	for i = 1, #group.cards do
		local card = group.cards[i].component
		local size = group.cards[i].size
		local width, height = math.floor(size[1] * scale + 0.5), math.floor(size[2] * scale + 0.5)
		-- with allow_resize=false in the layout the art gets cropped without ResizeCurrentStateImage
		card:SetCanResizeWidth(true)
		card:SetCanResizeHeight(true)
		card:Resize(width, height)
		if card:NumImages() > 0 then card:ResizeCurrentStateImage(0, width, height) end
	end
	group.cards_component:Layout()
	group.component:Layout()
end

local function one_line(panel_context, group)
	local _, first_y = group.cards[1].component:Position()
	local _, last_y = group.cards[#group.cards].component:Position()
	return first_y == last_y and panel_context:Call(group.engine .. '.IsVertical') == false
end

local function scale_for(groups, per_row, spacing, limit)
	local scale = 1
	for first = 1, #groups, per_row do
		local card_width, fixed_width = 0, spacing * (math.min(per_row, #groups - first + 1) - 1)
		for i = first, math.min(first + per_row - 1, #groups) do
			local group_width = groups[i].component:Dimensions()
			local card_now = groups[i].cards[1].component:Dimensions()
			card_width = card_width + #groups[i].cards * groups[i].cards[1].size[1]
			fixed_width = fixed_width + group_width - #groups[i].cards * card_now
		end
		scale = math.min(scale, (limit - fixed_width) / card_width)
	end
	return scale
end

local function wrap_group(panel_context, group, limit)
	local width = group.component:Dimensions()
	if width <= limit or not one_line(panel_context, group) then return end
	local card_width = group.cards[1].component:Dimensions()
	local fixed_width = width - #group.cards * card_width
	local per_line = math.max(1, math.floor((limit - fixed_width) / card_width))
	-- on a HorizontalList this is cards per column
	panel_context:Call(group.engine .. '.SetItemsPerRow(' .. math.ceil(#group.cards / per_line) .. ')')
end

local function rows_fit(groups, per_row, spacing, limit)
	local row = 0
	for i = 1, #groups do
		local width = groups[i].component:Dimensions()
		row = (i - 1) % per_row == 0 and width or row + spacing + width
		if row > limit then return false end
	end
	return true
end

local function reset_offsets(panel_context, list, list_path, groups)
	local reset = false
	for i = 1, #groups do
		local key = groups[i].component:Id()
		if moved_groups[key] then
			panel_context:Call(list_path .. '.ChildList.At(' .. groups[i].index .. ').SetListOffset(0, 0)')
			moved_groups[key] = nil
			reset = true
		end
	end
	if reset then list:Layout() end
end

local function bottom_align(panel_context, list, list_path, groups)
	reset_offsets(panel_context, list, list_path, groups)
	local rows = {}
	local moved = false
	for i = 1, #groups do
		local _, y = groups[i].component:Position()
		local _, height = groups[i].component:Dimensions()
		y = math.floor(y + 0.5)
		rows[y] = math.max(rows[y] or 0, height)
	end
	for i = 1, #groups do
		local _, y = groups[i].component:Position()
		local _, height = groups[i].component:Dimensions()
		y = math.floor(y + 0.5)
		if rows[y] > height then
			-- sizetocontent ignores list offsets, so never push past the tallest group in the row
			panel_context:Call(list_path .. '.ChildList.At(' .. groups[i].index .. ').SetListOffset(0, ' .. (rows[y] - height) .. ')')
			moved_groups[groups[i].component:Id()] = true
			moved = true
		end
	end
	if moved then list:Layout() end
end

local function fit_category(panel, panel_context, category, limit)
	local holder = find_uicomponent(panel, 'unit_category_' .. category)
	if not holder or not holder:Visible() then return false end
	local list = direct_child(holder, 'unit_sets_list')
	if not list then return false end
	local list_path = 'ChildContext("unit_category_' .. category .. '").ChildContext("unit_sets_list")'
	local engine = list_path .. '.ListLayoutContext'
	local groups = {}
	for _, group in ipairs(visible_children(list)) do
		if read_group(group, list_path) then groups[#groups + 1] = group end
	end
	if #groups == 0 then return false end
	local changed = false
	if max_cards_per_line then
		for i = 1, #groups do
			if #groups[i].cards > max_cards_per_line and one_line(panel_context, groups[i]) then
				panel_context:Call(groups[i].engine .. '.SetItemsPerRow(' .. math.ceil(#groups[i].cards / max_cards_per_line) .. ')')
				changed = true
			end
		end
	end
	for i = 1, #groups do
		changed = close_gap(panel_context, groups[i]) or changed
	end
	if max_groups_per_row and (panel_context:Call(engine .. '.ItemsPerRow') or 0) > max_groups_per_row then
		panel_context:Call(engine .. '.SetItemsPerRow(' .. max_groups_per_row .. ')')
		changed = true
	end
	if changed then list:Layout() end
	if list:Dimensions() > limit then
		local most = panel_context:Call(engine .. '.ItemsPerRow') or 1
		local spacing = panel_context:Call(engine .. '.Spacing.x') or 0
		local scalable = shrink_cards
		for i = 1, #groups do
			scalable = scalable and one_line(panel_context, groups[i])
		end
		local per_row = math.max(1, most)
		local scale = scalable and scale_for(groups, per_row, spacing, limit) or 0
		while scalable and per_row > 1 and scale < min_scale do
			per_row = per_row - 1
			scale = scale_for(groups, per_row, spacing, limit)
		end
		if scalable then
			for i = 1, #groups do
				scale_cards(groups[i], math.min(1, math.max(scale, min_scale)))
			end
		end
		if scale < min_scale then
			for i = 1, #groups do
				wrap_group(panel_context, groups[i], limit)
			end
			per_row = math.max(1, most)
			while per_row > 1 and not rows_fit(groups, per_row, spacing, limit) do
				per_row = per_row - 1
			end
		end
		panel_context:Call(engine .. '.SetItemsPerRow(' .. per_row .. ')')
		changed = true
	end
	if align_bars then
		bottom_align(panel_context, list, list_path, groups)
	else
		reset_offsets(panel_context, list, list_path, groups)
	end
	return changed
end

-- the bottom spacer is only needed when the last group ends under the category tabs at the end of the scroll
local function update_spacer(panel)
	local spacer = find_uicomponent(panel, 'empty_spacer_bottom')
	local list_box = find_uicomponent(panel, 'list_box')
	local listview = find_uicomponent(panel, 'unit_categories_listview')
	local tabs = find_uicomponent(panel, 'button_list')
	if not (spacer and list_box and listview and tabs) then return end
	local list
	for i = 1, #categories do
		local holder = find_uicomponent(panel, 'unit_category_' .. categories[i])
		if holder and holder:Visible() then list = direct_child(holder, 'unit_sets_list') end
	end
	if not list then return end
	local _, box_y = list_box:Position()
	local _, list_y = list:Position()
	local _, list_height = list:Dimensions()
	local _, view_y = listview:Position()
	local _, view_height = listview:Dimensions()
	local _, tabs_y = tabs:Position()
	local bottom_at_end = view_y + math.min(list_y - box_y + list_height, view_height)
	local needed = bottom_at_end > tabs_y
	if spacer:Visible() ~= needed then
		spacer:SetVisible(needed)
		list_box:Layout()
	end
end

-- a spacer left on from the old tab adds a scroll bar for a frame, the later passes turn it back on if needed
local function hide_spacer(panel)
	local spacer = find_uicomponent(panel, 'empty_spacer_bottom')
	local list_box = find_uicomponent(panel, 'list_box')
	if spacer and list_box and spacer:Visible() then
		spacer:SetVisible(false)
		list_box:Layout()
	end
end

local function fit_panel(tab_clicked)
	local panel = find_uicomponent(core:get_ui_root(), panel_id)
	local panel_context = panel and cco('CcoComponent', panel_id)
	if not panel_context then return end
	local limit = width_limit(panel)
	for i = 1, #categories do
		fit_category(panel, panel_context, categories[i], limit)
	end
	if tab_clicked then hide_spacer(panel) else update_spacer(panel) end
end

local function fit_panel_safely(tab_clicked)
	local ok, err = xpcall(function() fit_panel(tab_clicked) end, debug.traceback)
	if not ok then out(log_prefix .. tostring(err)) end
end

-- lists are empty when the panel opens and fill ~50 ms later, tab switches can take longer
local function fit_panel_later()
	cm:remove_real_callback('nagash_caps_fit_cards')
	cm:real_callback(fit_panel_safely, delay_ms, 'nagash_caps_fit_cards')
	cm:real_callback(fit_panel_safely, settle_ms, 'nagash_caps_fit_cards')
end

local function forget_cards()
	card_sizes = {}
	moved_groups = {}
	fit_panel_later()
end

core:remove_listener('nagash_caps_fit_cards_open')
core:remove_listener('nagash_caps_fit_cards_tab')

core:add_listener('nagash_caps_fit_cards_open', 'PanelOpenedCampaign', function(context)
	return context.string == panel_id
end, forget_cards, true)

core:add_listener('nagash_caps_fit_cards_tab', 'ComponentLClickUp', function(context)
	return context.string == 'category_tab_button'
end, function()
	fit_panel_safely(true)
	fit_panel_later()
end, true)
