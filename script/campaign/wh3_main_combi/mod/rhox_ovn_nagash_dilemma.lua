local dk_faction = "ovn_tmb_dread_king"

local function rhox_dread_nagash_dilemma_listeners()
  core:add_listener(
      "rhox_ovn_dk_nagash_turn_check",
      "FactionTurnStart",
      function(context)
          local faction = context:faction()
          local turn = cm:model():turn_number();
          local nagash_faction = cm:get_faction("mixer_nag_nagash")
          return faction:is_human() and faction:name() == dk_faction and nagash_faction and nagash_faction:is_dead() == false and turn == 50
      end,
      function(context)
        out("Rhox DK: Let's trigger Dilemma")
        local faction = context:faction()
        local nagash_faction = cm:get_faction("mixer_nag_nagash")
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
                cm:force_declare_war(faction:name(), "mixer_nag_nagash", true, true)

                local mm = mission_manager:new(faction:name(), "rhox_dk_defeat_nagash")
                mm:add_new_objective("DESTROY_FACTION");
                mm:add_condition("faction " .. "mixer_nag_nagash");
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
            cm:add_unit_to_faction_mercenary_pool(faction, "nag_morghasts", "renown", 10, 10, 10, 0.1, "", "", "", true, "nag_morghasts")
            local force = faction:faction_leader():military_force()
            if not force then
            return
            end
            cm:spawn_agent_at_military_force(faction, force, "spy", "nag_morghasts_archai")
            local new_character = cm:get_most_recently_created_character_of_type(faction, "spy", "nag_morghasts_archai")
            if new_character then 
                local forename = common:get_localised_string("rhox_ovn_dk_fixed_morghast_archai_name")
                --cm:add_agent_experience(cm:char_lookup_str(new_character), 1, true) -- in case of 2 it becomes level 2
                cm:change_character_custom_name(new_character, forename, "","","")
                cm:replenish_action_points(cm:char_lookup_str(new_character))
                --cm:force_add_trait(cm:char_lookup_str(new_character),"rhox_dreadking_morghast_archai")
            end
            local incident_builder = cm:create_incident_builder("rhox_dk_defeated_nagash")
            cm:launch_custom_incident_from_builder(incident_builder, faction)
        end,
        true
    )
end;

cm:add_first_tick_callback(
  function() 
    if cm:get_faction(dk_faction):is_human() and vfs.exists("script/frontend/mod/rhox_nagash_mixer.lua") then
      rhox_dread_nagash_dilemma_listeners()
    end
  end
);
