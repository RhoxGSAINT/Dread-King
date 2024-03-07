local function rhox_dk_add_realm()
    local parent_ui = find_uicomponent(core:get_ui_root(), "hud_battle", "BOP_frame", "docked_holder")
	if not parent_ui then
        out("Rhox DK: No parent UI returning")
		return
	end
    local result = core:get_or_create_component("rhox_dk_realm_holder", "ui/battle ui/rhox_dreadking_realm.twui.xml", parent_ui)
    if not result then
        script_error("Rhox DK: ".. "ERROR: could not create realm ui component? How can this be?");
        return false;
    end;
end




bm:register_phase_change_callback(
	"Deployment", 
	function()
		if bm:player_army_is_faction("ovn_tmb_dread_king") or bm:player_army_is_faction("ovn_tmb_dread_king_battle_only") then
			rhox_dk_add_realm()
		end
	end
);