local wcc_dataset = require("wolfy_chaos_confederation_dataset");
local config = {
	enable_ai_confederation = true,
	enable_minor_factions = true,
	enable_wh_main_chs_chaos_everyone = false,
	enable_wh3_main_chs_shadow_legion_everyone = false,
	enable_wh3_main_dae_daemon_prince_everyone = false,
	logging_enabled = false
}

-- GENERIC --

local function forced_log(str, disabled)
	if not disabled then
		out("[wolfy][wcc] " .. str);
	end
end

local function get_config(config_key, disable_log)
	forced_log("Getting config for key \"" .. config_key .. "\"", disable_log);
	local config_value = config[config_key];

	if get_mct then
		local mct = get_mct();
		if mct ~= nil then
			local mod_cfg = mct:get_mod_by_key("wolfy_chaos_confederation");
			local opt_key = mod_cfg:get_option_by_key(config_key);

			if not opt_key then
				forced_log("ERROR Reading value from MCT: Config key not valid", disable_log);
			else
				config_value = opt_key:get_finalized_setting();
			end
		end
	end

	forced_log("Config value read: " .. config_key .. " -> " .. tostring(config_value), disable_log);
	return config_value;
end

local function wcc_log(str)
	if get_config("logging_enabled", true) then
		out("[wolfy][wcc] " .. str);
	end
end

-- CHAOS CONFEDERATION --

local function are_battle_races_confederable()
	local attacker_valid = false;
	local defender_valid = false;
	for _, race in ipairs(wcc_dataset.confederable_races) do
		if cm:pending_battle_cache_culture_is_attacker(race) then
			wcc_log("Confederable attacker race " .. race);
			attacker_valid = true;
		end
		if cm:pending_battle_cache_culture_is_defender(race) then
			wcc_log("Confederable defender race " .. race);
			defender_valid = true;
		end
	end

	return attacker_valid and defender_valid;
end

local function faction_can_confederate_everyone(faction_name)
	local faction_confederation_everyone_enabled = get_config("enable_" .. faction_name .. "_everyone");
	if faction_confederation_everyone_enabled ~= nil and faction_confederation_everyone_enabled then
		wcc_log("Faction " .. faction_name .. " gets a free confederation pass");
		return true;
	end

	return false;
end

local function is_confederation_possible(victorious_faction_name, defeated_character)
	wcc_log("Is confederation possible? " .. defeated_character:faction():name() .. " -> " .. victorious_faction_name);
	if defeated_character:faction():is_human() then
		wcc_log("Confederation not valid: Defeated faction is human");
		return false;
	end

	if faction_can_confederate_everyone(victorious_faction_name) then
		if not get_config("enable_minor_factions") then
			local is_minor_faction = true;
			for major_faction_name, _ in pairs(wcc_dataset.confederable_factions) do
				if victorious_faction_name == major_faction_name then
					is_minor_faction = false;
					break;
				end
			end

			if is_minor_faction then
				wcc_log("Confederation not valid: Minor factions confederation is disabled");
				return false;
			end
		end
		wcc_log("Confederation valid: " .. victorious_faction_name .. " can confederate everyone");
		return true;
	end

	if defeated_character:is_faction_leader() then
		wcc_log("Defeated character is faction leader!");

		local confederable_factions;
		if get_config("enable_minor_factions") then
			wcc_log("Minor factions enabled");
			confederable_factions = wcc_dataset.confederable_factions[victorious_faction_name];
		else
			confederable_factions = wcc_dataset.confederable_factions_no_minor[victorious_faction_name];
		end

		if confederable_factions ~= nil then
			for _, confederable_faction in ipairs(confederable_factions) do
				if defeated_character:faction():name() == confederable_faction then
					wcc_log("Confederation valid: " .. confederable_faction .. " -> " .. victorious_faction_name);
					return true;
				end
			end
		end
	end

	return false;
end

local function force_kill_leader(enemy_leader_family_member_key)
	local character_interface = cm:get_family_member_by_cqi(enemy_leader_family_member_key):character();

	if wcc_dataset.confederable_legendary_lords[character_interface:character_subtype_key()] then
		wcc_log("ERROR: Attempt was made to force-kill one legendary lord");
		return;
	end

	wcc_log("KILLING CHARACTER: " .. character_interface:get_forename());
	local character_cqi = character_interface:command_queue_index();
	cm:set_character_immortality("character_cqi:"..character_cqi, false);
	cm:kill_character(character_cqi, false);
end

local function add_dilemma_choice_listeners(victorious_faction, defeated_character)
	core:add_listener(
		"wcc_dilemma_choice_made_event",
		"DilemmaChoiceMadeEvent",
		true,
		function(context)
			wcc_log("Dilemma " .. context:dilemma() .. " choice made. Choice selected: " .. context:choice());
			if cm:model():difficulty_level() == -3 and not cm:is_multiplayer() then	-- Auto save on legendary
				wcc_log("Autosaving on Legendary");
				cm:callback(function() cm:autosave_at_next_opportunity() end, 0.5);
			end;

			if context:dilemma() == wcc_dataset.dilemma_key and context:choice() == wcc_dataset.dilemma_choice_execution then
				force_kill_leader(defeated_character:family_member():command_queue_index());
			end

			if (context:dilemma() == wcc_dataset.dilemma_key or context:dilemma() == wcc_dataset.dilemma_key_lls) and
					context:choice() == wcc_dataset.dilemma_choice_vassalization then
				wcc_log("Force make vassal: " .. victorious_faction:name() .. " -> " ..	defeated_character:faction():name());
				cm:force_make_vassal(victorious_faction:name(), defeated_character:faction():name())
			end
		end,
		false
	);
end

local function trigger_confederate_dilemma(victorious_fm, defeated_fm)
	local victorious_character = victorious_fm:character();
	local defeated_character = defeated_fm:character();

	if not victorious_character or victorious_character:is_null_interface() or
		 not defeated_character or defeated_character:is_null_interface() then
		return;
	end

	local victorious_faction = victorious_character:faction();
	if is_confederation_possible(victorious_faction:name(), defeated_character) then
		if victorious_faction:is_human() then
			local confederate_dilemma_key = wcc_dataset.dilemma_key;
			if wcc_dataset.confederable_legendary_lords[defeated_character:character_subtype_key()] ~= nil then
				confederate_dilemma_key = wcc_dataset.dilemma_key_lls;
			end

			cm:trigger_dilemma_with_targets(
				victorious_faction:command_queue_index(), confederate_dilemma_key,
				defeated_character:faction():command_queue_index(), 0, defeated_character:command_queue_index(), 0, 0, 0,
				function()
					add_dilemma_choice_listeners(victorious_faction, defeated_character);
				end);
		elseif get_config("enable_ai_confederation") then
			wcc_log("Faction ".. victorious_faction:name().." is confederating ".. defeated_character:faction():name());
			cm:force_confederation(victorious_faction:name(), defeated_character:faction():name());
		end
	end
end

-- MAIN --

local function main()
	cm:add_immortal_character_defeated_listener(
		"wcc_immortal_defeated",
		function(context)
			return are_battle_races_confederable();
		end,
		trigger_confederate_dilemma,
		true
	);
end

main();
