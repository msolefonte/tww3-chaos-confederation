local wcc_dataset = require("wolfy_chaos_confederation_dataset");
local config = {
  enable_ai_confederation = true,
  enable_minor_factions = true,
  logging_enabled = false
}

-- GENERIC --

function wcc_log(str)
  if get_config("logging_enabled") then
    out("[wolfy][wcc] " .. str);
  end
end

function get_config(config_key)
  if get_mct then
    local mct = get_mct();
    if mct ~= nil then
      local mod_cfg = mct:get_mod_by_key("wolfy_chaos_confederation");
      return mod_cfg:get_option_by_key("wcc_" .. config_key):get_finalized_setting();
    end
  end

  return config[config_key];
end

-- CHAOS CONFEDERATION --

function is_confederation_possible(victorious_faction_name, defeated_character)
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

function force_kill_leader(enemy_leader_family_member_key)
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

function add_dilemma_choice_listeners(victorious_faction, defeated_character)
	core:add_listener(
		"wcc_dilemma_choice_made_event",
		"DilemmaChoiceMadeEvent",
		true,
		function(context)
      wcc_log("Dilemma " .. context:dilemma() .. " choice made. Choice selected: " .. context:choice());
			if cm:model():difficulty_level() == -3 and not cm:is_multiplayer() then  -- Auto save on legendary
        wcc_log("Autosaving on Legendary");
				cm:callback(function() cm:autosave_at_next_opportunity() end, 0.5);
			end;

			if context:dilemma() == wcc_dataset.dilemma_key and context:choice() == wcc_dataset.dilemma_choice_execution then
				force_kill_leader(defeated_character:family_member():command_queue_index());
			end

      if (context:dilemma() == wcc_dataset.dilemma_key or context:dilemma() == wcc_dataset.dilemma_key_lls) and
          context:choice() == wcc_dataset.dilemma_choice_vassalization then
        wcc_log("Force make vassal: " .. victorious_faction:name() .. " -> " ..  defeated_character:faction():name());
        cm:force_make_vassal(victorious_faction:name(), defeated_character:faction():name())
      end
		end,
		false
	);
end

function attempt_to_launch_confederate_dilemma(victorious_faction, defeated_character)
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

function are_battle_races_confederable()
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

function get_battle_victorious_character()
  if cm:pending_battle_cache_attacker_victory() then
    return cm:get_character_by_cqi(cm:pending_battle_cache_get_attacker(1));
  elseif cm:pending_battle_cache_defender_victory() then
    return cm:get_character_by_cqi(cm:pending_battle_cache_get_defender(1));
  else
    return nil; -- Likely a retreat, sometimes a bug.
  end
end

function get_defeated_enemy_family_members(victorious_character)
  -- We have to get the enemies using family members, instead of character interfaces
  -- When enemies die and respawn, their character CQIs change, but not their family member ones
  return cm:pending_battle_cache_get_enemy_fms_of_char_fm(victorious_character:family_member());
end

function create_character_respawn_listener(victorious_faction, defeated_character)
  local custom_character_context = custom_context:new();
  if not defeated_character:is_null_interface() then
      custom_character_context:add_data(defeated_character);
  end

  wcc_log("Wait for immortal character to respawn...");
  cm:progress_on_event(
    "wcc_character_respawned",
    "CharacterCreated",
    function(context)
      return context.character and not context:character():is_null_interface();
    end,
    function(context)
      wcc_log("Character respawned!");
      attempt_to_launch_confederate_dilemma(victorious_faction, context:character());
    end,
    custom_character_context
  );
end

function evaluate_completed_battle()
  wcc_log("A battle has been completed. Battle type: " .. cm:model():pending_battle():battle_type());

  if are_battle_races_confederable() then
    local victorious_character = get_battle_victorious_character();
    if victorious_character ~= nil then
      wcc_log("Victorious character from faction: " .. victorious_character:faction():name() .. ")");

      local enemy_family_members = get_defeated_enemy_family_members(victorious_character);
      for i = 1, #enemy_family_members do
        wcc_log("Checking defeated enemy " .. i .. " (faction: " ..
                enemy_family_members[i]:character_details():faction():name() .. ")");

        if enemy_family_members[i]:character_details():is_immortal() then
          create_character_respawn_listener(victorious_character:faction(), enemy_family_members[i]:character());
        end
      end
    end
  end
end

-- MAIN --

function main()
  core:add_listener(
    "wcc_battle_completed",
    "BattleCompleted",
    true,
    evaluate_completed_battle,
    true
  );
end

main();
