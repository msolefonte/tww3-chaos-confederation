if not get_mct then return end
local mct = get_mct();

if not mct then return end
local mct_mod = mct:register_mod("wolfy_chaos_confederation");

mct_mod:set_title("Allegiance of the Damned");
mct_mod:set_author("Wolfy");
mct_mod:set_description("Allow Chaos factions to confederate via imposition following loreful rules.");

mct_mod:add_new_section("1-wcc-base", "Base Options");

local wcc_enable_minor_factions = mct_mod:add_new_option("wcc_enable_minor_factions", "checkbox");
wcc_enable_minor_factions:set_default_value(true);
wcc_enable_minor_factions:set_text("Enable Minor Factions");
wcc_enable_minor_factions:set_tooltip_text("Enable if you want minor factions to be confederable");

mct_mod:add_new_section("2-wcc-ao", "Advanced Options", false);

local wcc_logging_enabled = mct_mod:add_new_option("wcc_logging_enabled", "checkbox");
wcc_logging_enabled:set_default_value(false);
wcc_logging_enabled:set_text("Enable logging");
wcc_logging_enabled:set_tooltip_text("If enabled, a log will be populated as you play. Use it to report bugs!");
