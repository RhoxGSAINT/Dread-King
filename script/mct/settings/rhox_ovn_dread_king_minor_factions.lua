if not get_mct then return end
local mct = get_mct()
local mct_mod = mct:register_mod("ovn_dread_king")
mct_mod:set_title("OvN Lost Factions: Dread King Legions", true)
mct_mod:set_author("OvN")
mct_mod:set_description("If you want more minor factions", true)


local minor_italy = mct_mod:add_new_option("rhox_ovn_dread_king_minor_italy", "checkbox")
minor_italy:set_default_value(false)
minor_italy:set_text("rhox_ovn_dread_king_minor_italy_title", true)
minor_italy:set_tooltip_text("rhox_ovn_dread_king_minor_italy_desc", true)