local function ovn_dread_king_disable_vanilla_lords()
    if vfs.exists("script/frontend/mod/mixer_frontend.lua")then
        mixer_disable_lord_recruitment("ovn_tmb_dread_king", "wh2_dlc09_tmb_tomb_king", "tmb_tomb_king", "elo_liche_general_vampires")
    end

end;

cm:add_first_tick_callback(function() ovn_dread_king_disable_vanilla_lords() end);
