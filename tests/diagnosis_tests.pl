:- use_module('../src/engine/diagnosis.pl').
:- use_module('../src/engine/session.pl').

% Detailed runner for class demos when you want visible test output.
run_detailed_tests :-
    nl,
    writeln('Running detailed diagnosis tests...'),
    nl,
    run_dead_battery_test,
    nl,
    run_alternator_test,
    nl,
    run_starter_test,
    nl,
    run_overheating_test,
    nl,
    run_low_oil_pressure_test,
    nl,
    run_multiple_match_test,
    nl,
    run_missing_symptom_test,
    nl,
    writeln('Detailed test run complete.'),
    halt.

run_dead_battery_test :-
    clear_session,
    remember_yes(engine_wont_start),
    remember_yes(lights_dim),
    remember_yes(clicking_sound),
    writeln('Test 1: dead battery should be diagnosed'),
    writeln('Inputs: engine_wont_start = yes, lights_dim = yes, clicking_sound = yes'),
    (   diagnose(Fault, Recommendation)
    ->  format('Result: Fault = ~w~n', [Fault]),
        format('Recommendation: ~w~n', [Recommendation])
    ;   writeln('Result: No diagnosis returned')
    ).

run_alternator_test :-
    clear_session,
    remember_yes(battery_warning_light),
    remember_yes(lights_dim),
    remember_yes(engine_stalls),
    writeln('Test 2: alternator issue should be diagnosed'),
    writeln('Inputs: battery_warning_light = yes, lights_dim = yes, engine_stalls = yes'),
    (   diagnose(Fault, Recommendation)
    ->  format('Result: Fault = ~w~n', [Fault]),
        format('Recommendation: ~w~n', [Recommendation])
    ;   writeln('Result: No diagnosis returned')
    ).

run_starter_test :-
    clear_session,
    remember_yes(engine_wont_start),
    remember_yes(dashboard_lights_on),
    remember_yes(single_click),
    writeln('Test 3: starter failure should be diagnosed'),
    writeln('Inputs: engine_wont_start = yes, dashboard_lights_on = yes, single_click = yes'),
    (   diagnose(Fault, Recommendation)
    ->  format('Result: Fault = ~w~n', [Fault]),
        format('Recommendation: ~w~n', [Recommendation])
    ;   writeln('Result: No diagnosis returned')
    ).

run_overheating_test :-
    clear_session,
    remember_yes(temperature_gauge_high),
    remember_yes(steam_from_hood),
    remember_yes(coolant_leak),
    writeln('Test 4: overheating engine should be diagnosed'),
    writeln('Inputs: temperature_gauge_high = yes, steam_from_hood = yes, coolant_leak = yes'),
    (   diagnose(Fault, Recommendation)
    ->  format('Result: Fault = ~w~n', [Fault]),
        format('Recommendation: ~w~n', [Recommendation])
    ;   writeln('Result: No diagnosis returned')
    ).

run_low_oil_pressure_test :-
    clear_session,
    remember_yes(oil_warning_light),
    remember_yes(engine_knocking),
    remember_yes(low_oil_level),
    writeln('Test 5: low oil pressure should be diagnosed'),
    writeln('Inputs: oil_warning_light = yes, engine_knocking = yes, low_oil_level = yes'),
    (   diagnose(Fault, Recommendation)
    ->  format('Result: Fault = ~w~n', [Fault]),
        format('Recommendation: ~w~n', [Recommendation])
    ;   writeln('Result: No diagnosis returned')
    ).

run_multiple_match_test :-
    clear_session,
    remember_yes(engine_wont_start),
    remember_yes(lights_dim),
    remember_yes(clicking_sound),
    remember_yes(battery_warning_light),
    remember_yes(engine_stalls),
    writeln('Test 6: multiple diagnoses should be available when symptoms overlap'),
    writeln('Inputs: dead battery and alternator symptoms mixed together'),
    (   matching_diagnoses(Faults)
    ->  format('Result: Matching faults = ~w~n', [Faults])
    ;   writeln('Result: No diagnoses returned')
    ).

run_missing_symptom_test :-
    clear_session,
    remember_yes(engine_wont_start),
    remember_yes(lights_dim),
    writeln('Test 7: dead battery should not match when one symptom is missing'),
    writeln('Inputs: engine_wont_start = yes, lights_dim = yes, clicking_sound = missing'),
    (   diagnose(dead_battery, Recommendation)
    ->  format('Unexpected result: ~w~n', [Recommendation])
    ;   writeln('Result: No diagnosis returned, which is correct')
    ).

:- begin_tests(diagnosis).

test(detect_dead_battery) :-
    clear_session,
    remember_yes(engine_wont_start),
    remember_yes(lights_dim),
    remember_yes(clicking_sound),
    diagnose(dead_battery, _).

test(no_match_without_all_symptoms, [fail]) :-
    clear_session,
    remember_yes(engine_wont_start),
    remember_yes(lights_dim),
    diagnose(dead_battery, _).

test(detect_bad_alternator) :-
    clear_session,
    remember_yes(battery_warning_light),
    remember_yes(lights_dim),
    remember_yes(engine_stalls),
    diagnose(bad_alternator, _).

test(detect_starter_failure) :-
    clear_session,
    remember_yes(engine_wont_start),
    remember_yes(dashboard_lights_on),
    remember_yes(single_click),
    diagnose(starter_failure, _).

test(detect_overheating_engine) :-
    clear_session,
    remember_yes(temperature_gauge_high),
    remember_yes(steam_from_hood),
    remember_yes(coolant_leak),
    diagnose(overheating_engine, _).

test(detect_low_oil_pressure) :-
    clear_session,
    remember_yes(oil_warning_light),
    remember_yes(engine_knocking),
    remember_yes(low_oil_level),
    diagnose(low_oil_pressure, _).

test(detect_fuel_pump_failure) :-
    clear_session,
    remember_yes(engine_cranks_but_wont_start),
    remember_yes(fuel_whine_absent),
    remember_yes(loss_of_power),
    diagnose(fuel_pump_failure, _).

test(return_multiple_matching_diagnoses) :-
    clear_session,
    remember_yes(engine_wont_start),
    remember_yes(lights_dim),
    remember_yes(clicking_sound),
    remember_yes(battery_warning_light),
    remember_yes(engine_stalls),
    once(matching_diagnoses(Faults)),
    msort(Faults, SortedFaults),
    SortedFaults == [bad_alternator, dead_battery].

test(rank_partial_matches_when_no_exact_result) :-
    clear_session,
    remember_yes(engine_wont_start),
    remember_yes(lights_dim),
    ranked_diagnoses([_Score-dead_battery | _]).

test(select_next_question_from_active_faults) :-
    clear_session,
    remember_yes(engine_wont_start),
    once(next_question_symptom(Symptom)),
    memberchk(Symptom, [lights_dim, clicking_sound, dashboard_lights_on, single_click, no_dashboard_power, electrical_accessories_off]).

test(mark_diagnosis_complete_when_exact_match_isolated) :-
    clear_session,
    remember_yes(engine_wont_start),
    remember_yes(lights_dim),
    remember_yes(clicking_sound),
    remember_no(battery_warning_light),
    remember_no(engine_stalls),
    remember_no(dashboard_lights_on),
    remember_no(single_click),
    remember_no(no_dashboard_power),
    remember_no(electrical_accessories_off),
    diagnosis_complete.

test(return_matched_symptoms_for_exact_diagnosis) :-
    clear_session,
    remember_yes(engine_wont_start),
    remember_yes(lights_dim),
    remember_yes(clicking_sound),
    matched_symptoms(dead_battery, Symptoms),
    Symptoms == [engine_wont_start, lights_dim, clicking_sound].

:- end_tests(diagnosis).
