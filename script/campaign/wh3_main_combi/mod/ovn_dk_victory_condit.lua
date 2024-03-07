local function ovn_gru_victory_conditions()
	if cm:is_new_game() and cm:get_campaign_name() == "main_warhammer" then

		if cm:get_faction("ovn_tmb_dread_king"):is_human() then

			local mission = {[[
				 mission
				{
					victory_type ovn_victory_type_roleplay_dk_aon;
					key wh_main_short_victory;
					issuer CLAN_ELDERS;
					primary_objectives_and_payload
					{
						objective
                        {
                            override_text mission_text_text_dk_aon_intro;
                            type SCRIPTED;
                            script_key ovn_dummy;	
                        }
                        objective
                        {
								type OCCUPY_LOOT_RAZE_OR_SACK_X_SETTLEMENTS;
								total 30;
                        }
                        objective
                        {
                            type CONTROL_N_PROVINCES_INCLUDING;
                            total 6;
                            province wh3_main_combi_province_great_mortis_delta;
                            province wh3_main_combi_province_the_cracked_land;
                        }
						objective
						{
							type DESTROY_FACTION;
							faction wh2_dlc09_tmb_khemri;
                            faction wh3_main_emp_cult_of_sigmar;
                            faction wh2_dlc14_brt_chevaliers_de_lyonesse;
							confederation_valid;
						}
						payload
						{
							effect_bundle
							{
								bundle_key ovn_vc_dk_aon;
								turns 0;
							}
							game_victory;
						}
					}
				}
			]],
			[[
				mission
			   {
				   victory_type ovn_victory_type_roleplay_dk_do;
				   key wh_main_long_victory;
				   issuer CLAN_ELDERS;
				   primary_objectives_and_payload
				   {
                        objective
                        {
                            override_text mission_text_text_dk_do_intro;
                            type SCRIPTED;
                            script_key ovn_dummy;	
                        }
                        objective
                        {
								type OCCUPY_LOOT_RAZE_OR_SACK_X_SETTLEMENTS;
								total 70;
                        }
                        objective
                        {
                            type CONTROL_N_PROVINCES_INCLUDING;
                            total 15;
                            province wh3_main_combi_province_great_mortis_delta;
                            province wh3_main_combi_province_the_cracked_land;
                            province wh3_main_combi_province_western_border_princes;
                        }
					   objective
					   {
						   type DESTROY_FACTION;
						   faction wh2_dlc09_tmb_khemri;
                           faction wh3_main_emp_cult_of_sigmar;
                           faction wh2_dlc14_brt_chevaliers_de_lyonesse;
						   faction ovn_emp_grudgebringers;
						   confederation_valid;
					   }
					   payload
					   {
						   effect_bundle
						   {
							   bundle_key ovn_vc_dk_do;
							   turns 0;
						   }
						   game_victory;
					   }
				   }
			   }
		   ]]
		}

			cm:trigger_custom_mission_from_string("ovn_tmb_dread_king", mission[1]);
			cm:trigger_custom_mission_from_string("ovn_tmb_dread_king", mission[2]);
			
			cm:callback(
				function()
                    cm:complete_scripted_mission_objective("ovn_tmb_dread_king", "wh_main_short_victory", "ovn_dummy", true)
                    cm:complete_scripted_mission_objective("ovn_tmb_dread_king", "wh_main_long_victory", "ovn_dummy", true)
				end,
				5
			)

			
            
		end
	end
end

cm:add_first_tick_callback(function() ovn_gru_victory_conditions() end)