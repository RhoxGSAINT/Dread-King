local dk_faction = "ovn_tmb_dread_king"

local function rhox_dread_nagash_dilemma_listeners()
  core:add_listener(
      "rhox_ovn_dk_nagash_turn_check",
      "FactionTurnStart",
      function(context)
          local faction = context:faction()
          local turn = cm:model():turn_number();
          local nagash_faction = cm:get_faction("wh3_dlc29_nag_host_of_nagash")
          return faction:is_human() and faction:name() == dk_faction and nagash_faction and nagash_faction:is_dead() == false and turn == 50
      end,
      function(context)
        out("Rhox DK: Let's trigger Dilemma")
        local faction = context:faction()
        local nagash_faction = cm:get_faction("wh3_dlc29_nag_host_of_nagash")
        local dilemma_builder = cm:create_dilemma_builder("rhox_dk_nagash_dilemma");
        local payload_builder = cm:create_payload();
        
        
        

        payload_builder:text_display("dummy_rhox_dk_declare_war_on_nagash")
        payload_builder:text_display("dummy_rhox_dk_prize_on_the_destruction")
        dilemma_builder:add_choice_payload("FIRST", payload_builder);
        payload_builder:clear();


        payload_builder:treasury_adjustment(10000)
        payload_builder:diplomatic_attitude_adjustment(nagash_faction, 5)
        payload_builder:effect_bundle_to_faction("rhox_dk_nagash_follower_reward")
        dilemma_builder:add_choice_payload("SECOND", payload_builder);
        dilemma_builder:add_target("default", nagash_faction);
        dilemma_builder:add_target("target_faction_1", nagash_faction);
        
        
        cm:launch_custom_dilemma_from_builder(dilemma_builder, faction);
      end,
      true
  );
  core:add_listener(
        "rhox_ovn_dk_nagash_turn_check_DilemmaChoiceMadeEvent", 
        "DilemmaChoiceMadeEvent",
        function(context)
            return context:dilemma() == "rhox_dk_nagash_dilemma"
        end,
        function(context)
            local choice = context:choice();
            local faction = context:faction()
            
            if choice == 0 then    
                cm:force_declare_war(faction:name(), "wh3_dlc29_nag_host_of_nagash", true, true)

                local mm = mission_manager:new(faction:name(), "rhox_dk_defeat_nagash")
                mm:add_new_objective("DESTROY_FACTION");
                mm:add_condition("faction " .. "wh3_dlc29_nag_host_of_nagash");
                mm:add_payload("text_display dummy_rhox_dk_morghast_archai");
                mm:add_payload("effect_bundle{bundle_key rhox_dk_nagash_defeated_reward;turns 0;}");


                mm:trigger()
            end
        end,
        true
    )
    core:add_listener(
        "rhox_ovn_dk_nagash_turn_check_DilemmaChoiceMadeEvent",
        "MissionSucceeded",
        function(context)
            local mission = context:mission()
            return mission:mission_record_key() == "rhox_dk_defeat_nagash"
        end,
        function(context)
            local faction = context:faction()
            cm:add_unit_to_faction_mercenary_pool(faction, "ovn_dk_mon_morghast_harbingers", "wh3_main_regiments_of_renown_pool", 10, 10, 10, 0.1, "", "", "", true, "nag_morghast_harbingers")
            cm:add_unit_to_faction_mercenary_pool(faction, "ovn_dk_mon_morghast_archai", "wh3_main_regiments_of_renown_pool", 10, 10, 10, 0.1, "", "", "", true, "nag_morghast_archai")
            local incident_builder = cm:create_incident_builder("rhox_dk_defeated_nagash")
            cm:launch_custom_incident_from_builder(incident_builder, faction)
        end,
        true
    )
end; 

cm:add_first_tick_callback(
  function() 
    if cm:get_faction(dk_faction):is_human() then
      rhox_dread_nagash_dilemma_listeners()
    end
  end
);
