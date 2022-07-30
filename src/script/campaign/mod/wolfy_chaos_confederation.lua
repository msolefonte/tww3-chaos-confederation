local debug_mode = false; -- TODO Always set to false for production
local wcc = {
    confederable_legendary_lords = {
        wh_dlc01_chs_kholek_suneater = true,
        wh_dlc01_chs_prince_sigvald = true,
        placeholder_azazel = true, -- TODO
        placeholder_festus = true, -- TODO
        placeholder_vilitch = true, -- TODO
        placeholder_valkia = true, -- TODO
        wh3_main_nur_kugath = true,
        wh3_main_sla_nkari = true,
        wh3_main_tze_kairos = true,
        wh3_main_kho_skarbrand = true
    },
    config = {
        enable_ai_confederation = true,
        enable_minor_factions = true
    },
    dilemma_execution_option = 1,
    dilemma_key = "wolfy_roc_confederation_generic",
    dilemma_key_lls = "wolfy_roc_confederation_generic_no_execution",
    valid_factions = {
        placeholder_archaon_faction = {
            "placeholder_festus_faction",
            "placeholder_azazel_faction",
            "placeholder_sigvald_faction",
            "placeholder_kholek_faction",
            "placeholder_valkia_faction",
            "placeholder_vilitch_faction"
        },
        placeholder_festus_faction = {
            "wh3_main_nur_poxmakers_of_nurgle"
        },
        placeholder_azazel_faction = {
            "wh3_main_sla_seducers_of_slaanesh",
            "placeholder_sigvald_faction"
        },
        placeholder_sigvald_faction = {
            "wh3_main_sla_seducers_of_slaanesh",
            "placeholder_azazel_faction"
        },
        placeholder_valkia_faction = {
            "wh3_main_kho_exiles_of_khorne"
        },
        placeholder_vilitch_faction = {
            "wh3_main_tze_oracles_of_tzeentch"
        },
        wh3_main_nur_poxmakers_of_nurgle = {
            "placeholder_festus_faction"
        },
        wh3_main_sla_seducers_of_slaanesh = {
            "placeholder_azazel_faction",
            "placeholder_sigvald_faction"
        },
        wh3_main_kho_exiles_of_khorne = {
            "placeholder_valkia_faction"
        },
        wh3_main_tze_oracles_of_tzeentch = {
            "placeholder_vilitch_faction"
        },
        placeholder_belakor_faction = {
            "wh3_main_nur_poxmakers_of_nurgle",
            "wh3_main_sla_seducers_of_slaanesh",
            "placeholder_kholek_faction",
            "wh3_main_kho_exiles_of_khorne",
            "wh3_main_tze_oracles_of_tzeentch"
        },
        wh3_main_dae_daemon_prince = {
            "wh3_main_nur_poxmakers_of_nurgle",
            "wh3_main_sla_seducers_of_slaanesh",
            "placeholder_kholek_faction",
            "wh3_main_kho_exiles_of_khorne",
            "wh3_main_tze_oracles_of_tzeentch"
        }
    },
    valid_races = {
        "wh_main_chs_chaos",
        "wh3_main_dae_daemons",
        "wh3_main_kho_khorne",
        "wh3_main_nur_nurgle",
        "wh3_main_sla_slaanesh",
        "wh3_main_tze_tzeentch"
    }
}

function wcc.load_minor_factions()
    out("WCC Loading Minor Factions");
    local function table_concat(t1,t2)
        new = {};
        for i=1, #t1 do
            new[#new+1] = t1[i];
        end
        for i=1, #t2 do
            new[#new+1] = t2[i];
        end
        return new;
    end

    local minor_khorne = {
        "wh3_main_kho_brazen_throne",
        "wh3_main_kho_crimson_skull",
        "wh3_main_kho_karneths_sons"
    };
    local minor_nurgle = {
        "wh3_main_nur_bubonic_swarm",
        "wh3_main_nur_maggoth_kin",
        "wh3_main_nur_septic_claw"
    };
    local minor_slaanesh = {
        "wh3_main_sla_exquisite_pain",
        "wh3_main_sla_rapturous_excess",
        "wh3_main_sla_subtle_torture"
    };
    local minor_tzeentch = {
        "wh3_main_tze_all_seeing_eye",
        "wh3_main_tze_broken_wheel",
        "wh3_main_tze_flaming_scribes",
        "wh3_main_tze_sarthoraels_watchers"
    };

    wcc.valid_factions["wh3_main_kho_exiles_of_khorne"] = table_concat(
        wcc.valid_factions["wh3_main_nur_poxmakers_of_nurgle"],
        minor_khorne
    );

    wcc.valid_factions["placeholder_valkia_faction"] = table_concat(
        wcc.valid_factions["placeholder_valkia_faction"],
        minor_khorne
    );

    wcc.valid_factions["wh3_main_nur_poxmakers_of_nurgle"] = table_concat(
        wcc.valid_factions["wh3_main_nur_poxmakers_of_nurgle"],
        minor_nurgle
    );

    wcc.valid_factions["placeholder_festus_faction"] = table_concat(
        wcc.valid_factions["placeholder_festus_faction"],
        minor_nurgle
    );

    wcc.valid_factions["wh3_main_sla_seducers_of_slaanesh"] = table_concat(
        wcc.valid_factions["wh3_main_nur_poxmakers_of_nurgle"],
        minor_slaanesh
    );

    wcc.valid_factions["placeholder_azazel_faction"] = table_concat(
        wcc.valid_factions["placeholder_azazel_faction"],
        minor_slaanesh
    );

    wcc.valid_factions["placeholder_sigvald_faction"] = table_concat(
        wcc.valid_factions["placeholder_sigvald_faction"],
        minor_slaanesh
    );

    wcc.valid_factions["wh3_main_tze_oracles_of_tzeentch"] = table_concat(
        wcc.valid_factions["wh3_main_nur_poxmakers_of_nurgle"],
        minor_tzeentch
    );

    wcc.valid_factions["placeholder_vilitch_faction"] = table_concat(
        wcc.valid_factions["placeholder_vilitch_faction"],
        minor_tzeentch
    );

    wcc.valid_factions["placeholder_belakor_faction"] = table_concat(
        wcc.valid_factions["placeholder_belakor_faction"],
        table_concat(minor_khorne,
            table_concat(minor_nurgle,
                table_concat(minor_slaanesh, minor_tzeentch)
            )
        )
    );

    wcc.valid_factions["wh3_main_dae_daemon_prince"] = table_concat(
        wcc.valid_factions["wh3_main_dae_daemon_prince"],
        table_concat(minor_khorne,
            table_concat(minor_nurgle,
                table_concat(minor_slaanesh, minor_tzeentch)
            )
        )
    );
end

function wcc.get_config(config_key)
  if get_mct then
      local mct = get_mct();

      if mct ~= nil then
          out("WCC Loading config from MCT: " .. config_key);
          local mod_cfg = mct:get_mod_by_key("wolfy_chaos_confederation");
          wcc.config[config_key] = mod_cfg:get_option_by_key("wcc_" .. config_key):get_finalized_setting();
      end
  end

  return wcc.config[config_key];
end

function wcc.check_attacker_and_defender_races_are_valid()
    out("WCC Check attacker and defender races are valid IN");
    if debug_mode then
        return true;
    end

    local attacker_valid = false;
    local defender_valid = false;

    for _, race in ipairs(wcc.valid_races) do
        if cm:pending_battle_cache_culture_is_attacker(race) then
            out("WCC Valid attacker race: " .. race);
            attacker_valid = true;
        end
        if cm:pending_battle_cache_culture_is_defender(race) then
            out("WCC Valid defender race: " .. race);
            defender_valid = true;
        end
    end

    out("WCC Check attacker and defender races are valid OUT");
    return attacker_valid and defender_valid;
end

function wcc.check_if_confederation_is_possible(victorious_character_faction_name, defeated_character)
    out("WCC Check if a confederation is possible IN");
    if defeated_character:is_faction_leader() then
        if debug_mode then
            return true;
        end

        if wcc.get_config("enable_minor_factions") then
            wcc.load_minor_factions();
        end

        local valid_factions = wcc.valid_factions[victorious_character_faction_name]
        if valid_factions ~= nil then
            for _, valid_faction in ipairs(valid_factions) do
                if defeated_character:faction():name() == valid_faction then
                    out("WCC Confederation valid: " .. valid_faction .. " -> " .. victorious_character_faction_name);
                    out("WCC Check attacker and defender factions are valid OUT");
                    return true;
                end
            end
        end
    end
    out("WCC Check if a confederation is possible OUT");
    return false;
end

function wcc.force_kill_leader(enemy_leader_family_member_key)
	local character_interface = cm:get_family_member_by_cqi(enemy_leader_family_member_key):character();
	local character_cqi = character_interface:command_queue_index();

	if wcc.confederable_legendary_lords[character_interface:character_subtype_key()] then
		script_error(string.format("ERROR: WCC Attempt was made to force-kill one of the legendary lords ('%s'): this should not be possible through events, as legendary lords should trigger a confederation dilemma with no execution option. Aborting process.",
			character_interface:character_subtype_key()));
		return;
	end
	out("WCC KILLING CHARACTER: " .. character_interface:get_forename());
	cm:set_character_immortality("character_cqi:"..character_cqi, false);
	cm:kill_character(character_cqi, false);
end

function wcc.listen_for_execution_of_lord(enemy_leader_family_member_key)
	core:add_listener(
		"wcc_dilemma_choice_made_event",
		"DilemmaChoiceMadeEvent",
		true,
		function(context)
			if cm:model():difficulty_level() == -3 and not cm:is_multiplayer() then  -- Auto save on legendary
				cm:callback(function() cm:autosave_at_next_opportunity() end, 0.5);
			end;

			if context:dilemma() == wcc.dilemma_key and context:choice() == wcc.dilemma_execution_option then
				wcc.force_kill_leader(enemy_leader_family_member_key);
			end
		end,
		false
	);
end

function wcc.attempt_to_launch_confederate_dilemma(victorious_character_faction, defeated_character)
    if wcc.check_if_confederation_is_possible(victorious_character_faction:name(), defeated_character) then
        if victorious_character_faction:is_human() then
            local confederate_dilemma_key = wcc.confederate_dilemma_key;
            if wcc.confederable_legendary_lords[defeated_character:character_subtype_key()] ~= nil then
                confederate_dilemma_key = wcc.dilemma_key_lls;
            end

            cm:trigger_dilemma_with_targets(victorious_character_faction:command_queue_index(),
                confederate_dilemma_key,
                defeated_character:faction():command_queue_index(),
                0,
                defeated_character:command_queue_index(),
                0,
                0,
                0,
                function() wcc.listen_for_execution_of_lord(defeated_character:family_member():command_queue_index()) end);
        else
            if wcc.get_config("enable_ai_confederation") then
                cm:force_confederation(victorious_character_faction:name(), defeated_character:faction():name());
                out.design("###### WCC AI CONFEDERATION");
                out.design("WCC Faction: ".. victorious_character_faction:name().." is confederating ".. defeated_character:faction():name());
            end
        end
    end
end

function main()
    out("WCC LOADED");

    core:add_listener(
        "wcc_character_completed_battle_chaos_confederation_dilemma",
        "BattleCompleted",
        true,
        function(context)
            if not wcc.check_attacker_and_defender_races_are_valid() then
                return;
            end

            local victorious_character;
            if cm:pending_battle_cache_attacker_victory() then
                victorious_character = cm:get_character_by_cqi(cm:pending_battle_cache_get_attacker(1));
            elseif cm:pending_battle_cache_defender_victory() then
                victorious_character = cm:get_character_by_cqi(cm:pending_battle_cache_get_defender(1));
            elseif cm:model():pending_battle():has_been_fought() then
                script_error("ERROR: WCC Attempted to get victorious character in most recent battle when trying to fire Chaos Confederation event, but the battle was neither an attacker nor a defender victory. This is unhandled.");
                return;
            else
                -- Likely a retreat.
                return;
            end

            -- We have to get the enemies using family members, instead of character interfaces.
            -- This is because a lot of the enemies may have just died and respawned, in which case their character CQIs will have changed.
            local enemies = cm:pending_battle_cache_get_enemy_fms_of_char_fm(victorious_character:family_member());
            local enemy_count = #enemies;

            if cm:model():pending_battle():night_battle() == true or cm:model():pending_battle():ambush_battle() == true then
                enemy_count = 1;
            end

            for i = 1, enemy_count do
                local enemy_fm = enemies[i];
                local enemy_char = enemy_fm:character();

                local custom_character_context = custom_context:new();
                if not enemy_char:is_null_interface() then
                    custom_character_context:add_data(enemy_char);
                end

                if enemy_fm:character_details():is_immortal() then
                    cm:progress_on_event(
                        "wcc_chaos_leader_respawned",
                        "CharacterCreated",
                        function(context) return context.character and not context:character():is_null_interface() end,
                        function(context) wcc.attempt_to_launch_confederate_dilemma(victorious_character:faction(), context:character()) end,
                        custom_character_context
                    );
                end
            end
        end,
        true
    );
end

main();
