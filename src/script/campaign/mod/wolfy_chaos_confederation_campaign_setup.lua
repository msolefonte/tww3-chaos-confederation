local wcc_dataset = require("wolfy_chaos_confederation_dataset");

local function is_wcc_confederable(faction_culture)
	for _, race in ipairs(wcc_dataset.confederable_races) do
		if faction_culture == race then
			return true;
		end
	end

	return false;
end


-- Copy paste from wh_campaign_setup, only change in line 15
local function start_confederation_listeners()
	core:add_listener(
		"confederation_listener",
		"FactionJoinsConfederation",
		true,
		function(context)
			local faction = context:confederation();
			local faction_name = faction:name();
			local faction_culture = faction:culture();
			local faction_subculture = faction:subculture();
			local faction_human = faction:is_human();
			local confederation_timeout = 5;

			-- exclude Empire, Wood Elves, Beastmen, Norsca, Greenskins, Bretonnia (excluding Chevs de Leonesse), Kislev - they can confederate as often as they like but only if they aren't AI
			if faction_human == false or is_wcc_confederable(faction_culture) or (faction_subculture ~= "wh_main_sc_emp_empire" and faction_culture ~= "wh_dlc03_bst_beastmen" and faction_culture ~= "wh_dlc05_wef_wood_elves" and (faction_culture ~= "wh_main_brt_bretonnia" or faction_name == "wh2_dlc14_brt_chevaliers_de_lyonesse") and faction_subculture ~= "wh_dlc08_sc_nor_norsca" and faction_subculture ~= "wh_main_sc_grn_greenskins" and faction_subculture ~= "wh3_main_sc_ksl_kislev") then
				if faction_human == false then
					confederation_timeout = 10;
				end

				out("Restricting confederation between [faction:" .. faction_name .. "] and [subculture:" .. faction_subculture .. "]");
				cm:force_diplomacy("faction:" .. faction_name, "subculture:" .. faction_subculture, "form confederation", false, true, false);
				cm:add_turn_countdown_event(faction_name, confederation_timeout, "ScriptEventConfederationExpired", faction_name);
			end

			local source_faction = context:faction();
			local source_faction_name = source_faction:name();

			-- remove deathhag after confederating/being confedrated with cult of pleasure
			if source_faction:culture() == "wh2_main_def_dark_elves" and faction_name == "wh2_main_def_cult_of_pleasure" then
				local char_list = faction:character_list();

				for i = 0, char_list:num_items() - 1 do
					local current_char = char_list:item_at(i);

					if current_char:has_skill("wh2_main_skill_all_dummy_agent_actions_def_death_hag") then
						cm:kill_character(current_char:command_queue_index(), true);
					end
				end
			elseif faction_culture == "wh2_main_def_dark_elves" and source_faction_name == "wh2_main_def_cult_of_pleasure" then
				local char_list = faction:character_list();

				for i = 0, char_list:num_items() - 1 do
					local current_char = char_list:item_at(i);

					if current_char:has_skill("wh2_main_skill_all_dummy_agent_actions_def_death_hag_chs") then
						cm:kill_character(current_char:command_queue_index(), true);
					end
				end
			elseif faction_name == "wh2_dlc13_lzd_spirits_of_the_jungle" then
				local defender_faction = cm:get_faction("wh2_dlc13_lzd_defenders_of_the_great_plan");

				cm:disable_event_feed_events(true, "", "wh_event_subcategory_diplomacy_treaty_broken", "");
				cm:disable_event_feed_events(true, "", "", "diplomacy_treaty_negotiated_vassal");

				local function handover_nakai_region()
					local nakai_faction = cm:get_faction("wh2_dlc13_lzd_spirits_of_the_jungle");
					local faction_regions = nakai_faction:region_list();

					for i = 0, faction_regions:num_items() - 1 do
						local region = faction_regions:item_at(i);
						cm:transfer_region_to_faction(region:name(), "wh2_dlc13_lzd_defenders_of_the_great_plan");
						nakai_temples:create_region_temple(region);
					end
				end

				if defender_faction then
					if defender_faction:is_dead() and faction:has_home_region() then
						local home_region = faction:home_region():name();

						local x, y = cm:find_valid_spawn_location_for_character_from_settlement(
							"wh2_dlc13_lzd_defenders_of_the_great_plan",
							home_region,
							false,
							true
						);

						cm:create_force(
							"wh2_dlc13_lzd_defenders_of_the_great_plan",
							"wh2_main_lzd_inf_skink_cohort_0",
							home_region,
							x, y,
							true,
							function(char_cqi, force_cqi)
								handover_nakai_region();
								cm:kill_character(char_cqi, true);
							end
						);
					else
						handover_nakai_region();
					end

					if defender_faction:is_vassal() == false then
						cm:force_make_vassal("wh2_dlc13_lzd_spirits_of_the_jungle", "wh2_dlc13_lzd_defenders_of_the_great_plan");
						cm:force_diplomacy("faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "all", "all", false, false, false);
						cm:force_diplomacy("faction:wh2_dlc13_lzd_spirits_of_the_jungle", "faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "war", false, false, true);
						cm:force_diplomacy("faction:wh2_dlc13_lzd_spirits_of_the_jungle", "faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "break vassal", false, false, true);
						cm:force_diplomacy("faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "all", "war", false, true, false);
						cm:force_diplomacy("faction:wh2_dlc13_lzd_defenders_of_the_great_plan", "all", "peace", false, true, false);
					end
				end

				cm:callback(function() cm:disable_event_feed_events(false, "", "wh_event_subcategory_diplomacy_treaty_broken", "") end, 1);
				cm:callback(function() cm:disable_event_feed_events(false, "", "","diplomacy_treaty_negotiated_vassal") end, 1);
			elseif source_faction_name == "wh2_dlc13_lzd_spirits_of_the_jungle" then
				cm:disable_event_feed_events(true, "", "wh_event_subcategory_diplomacy_treaty_broken", "");
				cm:disable_event_feed_events(true, "", "", "diplomacy_treaty_negotiated_vassal");

				cm:force_confederation(faction_name, "wh2_dlc13_lzd_defenders_of_the_great_plan");

				cm:callback(function() cm:disable_event_feed_events(false, "", "wh_event_subcategory_diplomacy_treaty_broken", "") end, 1);
				cm:callback(function() cm:disable_event_feed_events(false, "", "", "diplomacy_treaty_negotiated_vassal") end, 1);
			end
		end,
		true
	);
end;

-- MAIN --

local function main()
	start_confederation_listeners();
end

main();