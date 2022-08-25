if not get_mct then return end
local mct = get_mct();

if not mct then return end
local mct_mod = mct:register_mod("wolfy_chaos_confederation");

mct_mod:set_title("Allegiance of the Damned");
mct_mod:set_author("Wolfy");
mct_mod:set_description("Allow Chaos factions to confederate via imposition following loreful rules");

mct_mod:add_new_section("1-wcc-base", "Base Options");

local enable_minor_factions = mct_mod:add_new_option("enable_minor_factions", "checkbox");
enable_minor_factions:set_default_value(true);
enable_minor_factions:set_text("Enable Minor Factions");
enable_minor_factions:set_tooltip_text("Do you want minor factions to be confederable?");

local enable_ai_confederation = mct_mod:add_new_option("enable_ai_confederation", "checkbox");
enable_ai_confederation:set_default_value(true);
enable_ai_confederation:set_text("Enable AI confederation");
enable_ai_confederation:set_tooltip_text("Do you want AI to also confederate?");

mct_mod:add_new_section("2-wcc-custom", "Custom Confederations");

local enable_wh_main_chs_chaos_everyone = mct_mod:add_new_option("enable_wh_main_chs_chaos_everyone", "checkbox");
enable_wh_main_chs_chaos_everyone:set_default_value(false);
enable_wh_main_chs_chaos_everyone:set_text("Archaon can Confederate Everyone");
enable_wh_main_chs_chaos_everyone:set_tooltip_text("Do you want Archaon to be able to confederate al Chaos factions?");

local enable_shadow_legion_everyone = mct_mod:add_new_option("enable_wh3_main_chs_shadow_legion_everyone", "checkbox");
enable_shadow_legion_everyone:set_default_value(false);
enable_shadow_legion_everyone:set_text("Be'lakor can Confederate Everyone");
enable_shadow_legion_everyone:set_tooltip_text("Do you want Be'lakor to be able to confederate al Chaos factions?");

local enable_daniel_everyone = mct_mod:add_new_option("enable_wh3_main_dae_daemon_prince_everyone", "checkbox");
enable_daniel_everyone:set_default_value(false);
enable_daniel_everyone:set_text("Daniel can Confederate Everyone");
enable_daniel_everyone:set_tooltip_text("Do you want Daniel to be able to confederate al Chaos factions?");

mct_mod:add_new_section("3-wcc-ao", "Advanced Options", false);

local logging_enabled = mct_mod:add_new_option("logging_enabled", "checkbox");
logging_enabled:set_default_value(false);
logging_enabled:set_text("Enable logging");
logging_enabled:set_tooltip_text("If enabled, a log will be populated as you play. Use it to report bugs!");
