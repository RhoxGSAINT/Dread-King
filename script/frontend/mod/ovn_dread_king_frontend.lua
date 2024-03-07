core:add_ui_created_callback(
    function(context)
        mixer_enable_custom_faction("1157338935")
        mixer_add_starting_unit_list_for_faction("ovn_tmb_dread_king", {"ovn_dk_mon_skeleton_elephant", "ovn_dk_inf_tomb_guardian_peltasts", "ovn_dk_cav_royal_guard_cavalry"})
		mixer_change_lord_name("1157338935", "Dread_King")
        mixer_add_faction_to_major_faction_list("ovn_tmb_dread_king")
        
        
        mixer_enable_custom_faction("2142864497")
        mixer_add_starting_unit_list_for_faction("ovn_tmb_dread_king", {"ovn_dk_mon_skeleton_elephant", "ovn_dk_inf_tomb_guardian_peltasts", "ovn_dk_cav_royal_guard_cavalry"})
		mixer_change_lord_name("2142864497", "Dread_King")
        
    end
)