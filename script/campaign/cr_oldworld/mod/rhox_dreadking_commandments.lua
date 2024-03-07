
local base_tmb_edicts={
    wh2_dlc09_edict_tmb_worship_of_asaph =true,
    wh2_dlc09_edict_tmb_worship_of_djaf =true,
    wh2_dlc09_edict_tmb_worship_of_khsar =true,
    wh2_dlc09_edict_tmb_worship_of_phakth =true,
    wh2_dlc09_edict_tmb_worship_of_ptra =true
}





cm:add_first_tick_callback(
    function()
        if cm:get_local_faction_name(true) == "ovn_tmb_dread_king" then
            core:remove_listener("rhox_dk_settlement_edict_real_time")
            core:add_listener(
                "rhox_dk_settlement_edict_real_time",
                "RealTimeTrigger",
                function(context)
                    return context.string == "rhox_dk_settlement_edict_real_time"
                end,
                function()
                    local edict_parent = find_uicomponent(core:get_ui_root(), "hud_campaign", "BL_parent", "stack_incentives")
        
					if not edict_parent then
						--out("Rhox DK: Couldn't find edict parent")
						return
					end
					
					for edict, _ in pairs(base_tmb_edicts) do
						local edict_button = find_uicomponent(edict_parent, "button_"..edict)
						if edict_button then
							edict_button:SetVisible(false)
							--out("Rhox DK: Setting edict button to invisible: button_"..edict)
						end
						
					end
                end,
                true
            )


			core:add_listener(
				"rhox_dk_settlement_panel_open",
				"PanelOpenedCampaign",
				function(context)	
					return context.string == "settlement_panel" and cm:get_local_faction_name(true) == "ovn_tmb_dread_king" --ui thing and should be local
				end,
				function()
					
					real_timer.unregister("rhox_dk_settlement_edict_real_time")
					real_timer.register_repeating("rhox_dk_settlement_edict_real_time", 100)
					
					core:remove_listener("rhox_dk_settlement_panel_closed")
					core:add_listener(
						"rhox_dk_settlement_panel_closed",
						"PanelClosedCampaign",
						function(context) return context.string == "events" end,
						function()
							real_timer.unregister("rhox_dk_settlement_edict_real_time")
						end,
						false
					);	
					
				end,
				true
			)
        end
    end
);


