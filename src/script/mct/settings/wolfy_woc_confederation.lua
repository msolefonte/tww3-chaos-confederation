local mct_mod = mct:register_mod("wolfy_woc_confederation");

mct_mod:set_title("Confederable Chaos");
mct_mod:set_author("Wolfy");

local wwc_enable_minor_factions = mct_mod:add_new_option("wwc_enable_minor_factions", "checkbox");
wwc_enable_minor_factions:set_default_value(true);
wwc_enable_minor_factions:set_text("Enable Minor Factions");
wwc_enable_minor_factions:set_tooltip_text("Enable if you want minor factions to be confederable");