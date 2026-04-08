# CS311 Project Implementation Submission

## Project Information

- Course: CS311 - Programming Languages
- Project Title: An Intelligent Rule-Based Car Diagnostics Expert System Using Prolog
- Student: Brayton
- Primary Language: Prolog using SWI-Prolog
- GitHub Repository: https://github.com/braytonrumple/Car-Diagnostics-System

## Implementation Status

This project is in working and testable condition. The implementation includes:

- A knowledge base of car faults, symptoms, and recommendations
- A working-memory module that stores user responses during a session
- A diagnosis engine that supports exact matches and ranked partial matches
- A command-line interface for interactive diagnosis
- Automated unit tests and a detailed demo-style test runner

## How To Run

From the project root:

```bash
swipl -s src/main.pl
```

## How To Run Tests

Standard unit tests:

```bash
swipl -q -s tests/diagnosis_tests.pl -t run_tests
```

Detailed demo output:

```bash
swipl -q -s tests/diagnosis_tests.pl -t run_detailed_tests
```

## File: src/main.pl

```prolog
:- module(main, []).

% Load the command-line interface for the expert system.
:- use_module('./ui/cli.pl').

% Start the program when the file is launched with SWI-Prolog.
run :-
    cli:start,
    halt.

:- initialization(run, main).
```

## File: src/engine/session.pl

```prolog
:- module(session, [
    clear_session/0,
    remember_yes/1,
    remember_no/1,
    known_yes/1,
    known_no/1
]).

% Dynamic predicates act as the expert system's working memory.
:- dynamic yes/1.
:- dynamic no/1.

% Remove all stored answers before starting a new session.
clear_session :-
    retractall(yes(_)),
    retractall(no(_)).

% Cache a positive symptom answer.
remember_yes(Symptom) :-
    (yes(Symptom) -> true ; assertz(yes(Symptom))).

% Cache a negative symptom answer.
remember_no(Symptom) :-
    (no(Symptom) -> true ; assertz(no(Symptom))).

% Check whether a symptom was confirmed by the user.
known_yes(Symptom) :-
    yes(Symptom).

% Check whether a symptom was rejected by the user.
known_no(Symptom) :-
    no(Symptom).
```

## File: src/engine/diagnosis.pl

```prolog
:- module(diagnosis, [
    diagnose/2,
    matches_fault/2,
    matching_diagnoses/1,
    ranked_diagnoses/1,
    next_question_symptom/1,
    diagnosis_complete/0,
    matched_symptoms/2
]).

% Use working memory plus the static knowledge base to infer a fault.
:- use_module('./session.pl').
:- use_module('../kb/faults.pl').

% Find the first exact match for CLI-style use. This predicate is intended to
% return a single best diagnosis rather than be backtracked over for all matches.
diagnose(Fault, Recommendation) :-
    matching_diagnoses([Fault | _]),
    recommendation(Fault, Recommendation),
    !.

% Return every fault that fully matches the confirmed symptom set.
matching_diagnoses(Faults) :-
    findall(Fault, matches_fault(Fault, _), Faults).

% Rank faults by how many confirmed symptoms they match.
ranked_diagnoses(RankedFaults) :-
    findall(
        Score-Fault,
        scored_fault(Fault, Score),
        ScoredFaults
    ),
    keysort(ScoredFaults, Ascending),
    reverse(Ascending, RankedFaults).

% Choose the most informative unanswered symptom among still-possible faults.
next_question_symptom(Symptom) :-
    candidate_faults(CandidateFaults),
    CandidateFaults \= [],
    focus_faults(CandidateFaults, FocusFaults),
    findall(
        CandidateSymptom,
        (
            member(Fault, FocusFaults),
            symptom(Fault, CandidateSymptom),
            unanswered_symptom(CandidateSymptom)
        ),
        CandidateSymptoms
    ),
    CandidateSymptoms \= [],
    best_symptom(CandidateSymptoms, Symptom).

% Stop asking questions when an exact diagnosis is isolated or no faults remain possible.
diagnosis_complete :-
    candidate_faults([]).
diagnosis_complete :-
    matching_diagnoses(Matches),
    Matches \= [],
    candidate_faults(Candidates),
    same_fault_set(Matches, Candidates).

% Collect every symptom required for a fault and verify each one.
matches_fault(Fault, Symptoms) :-
    fault(Fault),
    findall(Symptom, symptom(Fault, Symptom), Symptoms),
    all_symptoms_present(Symptoms).

% Return the list of confirmed symptoms that support a diagnosis.
matched_symptoms(Fault, Symptoms) :-
    findall(
        Symptom,
        (
            symptom(Fault, Symptom),
            known_yes(Symptom)
        ),
        Symptoms
    ).

% Calculate how strongly each fault matches the confirmed symptoms.
scored_fault(Fault, Score) :-
    fault(Fault),
    findall(Symptom, symptom(Fault, Symptom), Symptoms),
    count_known_yes(Symptoms, KnownYesCount),
    KnownYesCount > 0,
    \+ has_known_no_symptom(Symptoms),
    length(Symptoms, TotalSymptoms),
    Score is KnownYesCount / TotalSymptoms.

% A fault only matches if every required symptom is known to be true.
all_symptoms_present([]).
all_symptoms_present([Symptom | Rest]) :-
    known_yes(Symptom),
    all_symptoms_present(Rest).

count_known_yes([], 0).
count_known_yes([Symptom | Rest], Count) :-
    count_known_yes(Rest, RestCount),
    (known_yes(Symptom) -> Count is RestCount + 1 ; Count is RestCount).

has_known_no_symptom([Symptom | _]) :-
    known_no(Symptom).
has_known_no_symptom([_ | Rest]) :-
    has_known_no_symptom(Rest).

candidate_faults(Faults) :-
    findall(Fault, candidate_fault(Fault), Faults).

candidate_fault(Fault) :-
    fault(Fault),
    findall(Symptom, symptom(Fault, Symptom), Symptoms),
    \+ has_known_no_symptom(Symptoms),
    candidate_has_positive_support(Symptoms).

candidate_has_positive_support(Symptoms) :-
    known_yes(_),
    !,
    count_known_yes(Symptoms, KnownYesCount),
    KnownYesCount > 0.
candidate_has_positive_support(_).

focus_faults(CandidateFaults, FocusFaults) :-
    matching_diagnoses(Matches),
    Matches \= [],
    subtract_exact_matches(CandidateFaults, Matches, RemainingFaults),
    RemainingFaults \= [],
    !,
    highest_ranked_faults(RemainingFaults, FocusFaults).
focus_faults(_CandidateFaults, FocusFaults) :-
    ranked_diagnoses(RankedFaults),
    RankedFaults \= [],
    !,
    highest_ranked_faults(RankedFaults, FocusFaults).
focus_faults(CandidateFaults, CandidateFaults).

subtract_exact_matches([], _, []).
subtract_exact_matches([Fault | Rest], Matches, Remaining) :-
    member(Fault, Matches),
    !,
    subtract_exact_matches(Rest, Matches, Remaining).
subtract_exact_matches([Fault | Rest], Matches, [Fault | Remaining]) :-
    subtract_exact_matches(Rest, Matches, Remaining).

unanswered_symptom(Symptom) :-
    \+ known_yes(Symptom),
    \+ known_no(Symptom).

best_symptom([Symptom | Rest], BestSymptom) :-
    AllSymptoms = [Symptom | Rest],
    symptom_score(Symptom, AllSymptoms, BestScore),
    best_symptom(Rest, AllSymptoms, Symptom, BestScore, BestSymptom).

best_symptom([], _, BestSymptom, _, BestSymptom).
best_symptom([Symptom | Rest], AllSymptoms, CurrentBest, CurrentBestScore, BestSymptom) :-
    symptom_score(Symptom, AllSymptoms, Score),
    (   Score > CurrentBestScore
    ->  NextBest = Symptom,
        NextScore = Score
    ;   NextBest = CurrentBest,
        NextScore = CurrentBestScore
    ),
    best_symptom(Rest, AllSymptoms, NextBest, NextScore, BestSymptom).

symptom_score(Symptom, Symptoms, Score) :-
    count_occurrences(Symptom, Symptoms, Score).

count_occurrences(_, [], 0).
count_occurrences(Symptom, [Symptom | Rest], Count) :-
    !,
    count_occurrences(Symptom, Rest, RestCount),
    Count is RestCount + 1.
count_occurrences(Symptom, [_ | Rest], Count) :-
    count_occurrences(Symptom, Rest, Count).

same_fault_set(Left, Right) :-
    msort(Left, SortedLeft),
    msort(Right, SortedRight),
    SortedLeft = SortedRight.

highest_ranked_faults(Entries, Faults) :-
    normalize_ranked_entries(Entries, RankedEntries),
    RankedEntries = [BestScore-BestFault | Rest],
    highest_ranked_faults(Rest, BestScore, [BestFault], Faults).

normalize_ranked_entries([], []).
normalize_ranked_entries([Entry | Rest], [Score-Fault | RankedRest]) :-
    ranked_entry(Entry, Score-Fault),
    normalize_ranked_entries(Rest, RankedRest).

ranked_entry(Score-Fault, Score-Fault).
ranked_entry(Fault, Score-Fault) :-
    scored_fault(Fault, Score).

highest_ranked_faults([], _BestScore, Faults, Faults).
highest_ranked_faults([Score-Fault | Rest], BestScore, CurrentFaults, Faults) :-
    compare_fault_score(Score, Fault, Rest, BestScore, CurrentFaults, Faults).

compare_fault_score(Score, Fault, Rest, BestScore, CurrentFaults, Faults) :-
    (   Score > BestScore
    ->  highest_ranked_faults(Rest, Score, [Fault], Faults)
    ;   Score =:= BestScore
    ->  append(CurrentFaults, [Fault], UpdatedFaults),
        highest_ranked_faults(Rest, BestScore, UpdatedFaults, Faults)
    ;   highest_ranked_faults(Rest, BestScore, CurrentFaults, Faults)
    ).
```

## File: src/kb/faults.pl

```prolog
:- module(faults, [
    fault/1,
    fault_name/2,
    symptom/2,
    recommendation/2,
    question_text/2
]).

% Each fact below names a possible diagnosis the system can test.
fault(dead_battery).
fault(bad_alternator).
fault(starter_failure).
fault(spark_plug_issue).
fault(overheating_engine).
fault(fuel_pump_failure).
fault(clogged_air_filter).
fault(low_oil_pressure).
fault(radiator_fan_failure).
fault(blown_ignition_fuse).

% fault_name(Fault, Name) stores a user-friendly name for each diagnosis.
fault_name(dead_battery, 'Dead Battery').
fault_name(bad_alternator, 'Bad Alternator').
fault_name(starter_failure, 'Starter Failure').
fault_name(spark_plug_issue, 'Spark Plug Issue').
fault_name(overheating_engine, 'Overheating Engine').
fault_name(fuel_pump_failure, 'Fuel Pump Failure').
fault_name(clogged_air_filter, 'Clogged Air Filter').
fault_name(low_oil_pressure, 'Low Oil Pressure').
fault_name(radiator_fan_failure, 'Radiator Fan Failure').
fault_name(blown_ignition_fuse, 'Blown Ignition Fuse').

% symptom(Fault, Symptom) defines which symptoms support each diagnosis.
symptom(dead_battery, engine_wont_start).
symptom(dead_battery, lights_dim).
symptom(dead_battery, clicking_sound).

symptom(bad_alternator, battery_warning_light).
symptom(bad_alternator, lights_dim).
symptom(bad_alternator, engine_stalls).

symptom(starter_failure, engine_wont_start).
symptom(starter_failure, dashboard_lights_on).
symptom(starter_failure, single_click).

symptom(spark_plug_issue, engine_misfire).
symptom(spark_plug_issue, rough_idle).
symptom(spark_plug_issue, poor_fuel_economy).

symptom(overheating_engine, temperature_gauge_high).
symptom(overheating_engine, steam_from_hood).
symptom(overheating_engine, coolant_leak).

symptom(fuel_pump_failure, engine_cranks_but_wont_start).
symptom(fuel_pump_failure, fuel_whine_absent).
symptom(fuel_pump_failure, loss_of_power).

symptom(clogged_air_filter, poor_acceleration).
symptom(clogged_air_filter, poor_fuel_economy).
symptom(clogged_air_filter, dirty_air_filter).

symptom(low_oil_pressure, oil_warning_light).
symptom(low_oil_pressure, engine_knocking).
symptom(low_oil_pressure, low_oil_level).

symptom(radiator_fan_failure, temperature_gauge_high).
symptom(radiator_fan_failure, engine_hot_at_idle).
symptom(radiator_fan_failure, cooling_fan_not_running).

symptom(blown_ignition_fuse, engine_wont_start).
symptom(blown_ignition_fuse, no_dashboard_power).
symptom(blown_ignition_fuse, electrical_accessories_off).

% recommendation(Fault, Advice) stores the repair guidance for each diagnosis.
recommendation(dead_battery, 'Check battery charge, terminals, and consider a jump start or replacement.').
recommendation(bad_alternator, 'Inspect the alternator and charging system output.').
recommendation(starter_failure, 'Test the starter motor, solenoid, and related wiring.').
recommendation(spark_plug_issue, 'Inspect and replace worn spark plugs if needed.').
recommendation(overheating_engine, 'Check coolant level, radiator, thermostat, and water pump.').
recommendation(fuel_pump_failure, 'Inspect the fuel pump, fuel pressure, and fuel filter.').
recommendation(clogged_air_filter, 'Inspect the air filter and replace it if it is dirty or blocked.').
recommendation(low_oil_pressure, 'Check the oil level immediately and inspect for leaks or oil pump issues.').
recommendation(radiator_fan_failure, 'Inspect the radiator fan motor, relay, and temperature sensor.').
recommendation(blown_ignition_fuse, 'Inspect the ignition fuse and related electrical circuits for shorts.').

% question_text(Symptom, Prompt) maps each symptom to a user-friendly question.
question_text(engine_wont_start, 'Does the engine fail to start?').
question_text(lights_dim, 'Are the headlights or dashboard lights dim?').
question_text(clicking_sound, 'Do you hear repeated clicking when turning the key?').
question_text(battery_warning_light, 'Is the battery warning light on?').
question_text(engine_stalls, 'Does the engine stall while running?').
question_text(dashboard_lights_on, 'Do the dashboard lights turn on normally?').
question_text(single_click, 'Do you hear a single click when trying to start the car?').
question_text(engine_misfire, 'Is the engine misfiring?').
question_text(rough_idle, 'Does the car idle roughly?').
question_text(poor_fuel_economy, 'Have you noticed poor fuel economy?').
question_text(temperature_gauge_high, 'Is the temperature gauge reading high?').
question_text(steam_from_hood, 'Is steam coming from under the hood?').
question_text(coolant_leak, 'Do you see signs of a coolant leak?').
question_text(engine_cranks_but_wont_start, 'Does the engine crank but still fail to start?').
question_text(fuel_whine_absent, 'Do you no longer hear the fuel pump priming sound from the fuel tank area?').
question_text(loss_of_power, 'Does the vehicle lose power while driving?').
question_text(poor_acceleration, 'Does the vehicle have poor acceleration?').
question_text(dirty_air_filter, 'Is the air filter visibly dirty or clogged?').
question_text(oil_warning_light, 'Is the oil pressure warning light on?').
question_text(engine_knocking, 'Do you hear a knocking sound from the engine?').
question_text(low_oil_level, 'Is the engine oil level low?').
question_text(engine_hot_at_idle, 'Does the engine run especially hot while idling?').
question_text(cooling_fan_not_running, 'Is the cooling fan not turning on when the engine gets hot?').
question_text(no_dashboard_power, 'Is there no power on the dashboard when you turn the key?').
question_text(electrical_accessories_off, 'Are electrical accessories staying off when the ignition is on?').
```

## File: src/ui/cli.pl

```prolog
:- module(cli, [start/0]).

% Import the inference engine, session memory, and knowledge base.
:- use_module('../engine/diagnosis.pl').
:- use_module('../engine/session.pl').
:- use_module('../kb/faults.pl').
:- use_module(library(readutil)).

% Begin a fresh diagnostic session and then print the result.
start :-
    clear_session,
    print_welcome,
    nl,
    run_question_flow,
    run_diagnosis,
    print_goodbye.

print_welcome :-
    writeln('========================================'),
    writeln('      Car Diagnostics Expert System     '),
    writeln('========================================'),
    writeln('Enter yes or no for each symptom question.').

print_goodbye :-
    writeln('Thank you for using the Car Diagnostics Expert System.').

% Ask the next best symptom question until the diagnosis is clear.
run_question_flow :-
    diagnosis_complete,
    !.
run_question_flow :-
    next_question_symptom(Symptom),
    ask_missing_symptom(Symptom),
    run_question_flow.
run_question_flow.

% Show exact matches first, otherwise show the most likely partial matches.
run_diagnosis :-
    matching_diagnoses([Fault | OtherFaults]),
    nl,
    writeln('Diagnostic Summary'),
    writeln('------------------'),
    print_diagnosis(Fault),
    print_other_matches(OtherFaults),
    nl.
run_diagnosis :-
    nl,
    writeln('Diagnostic Summary'),
    writeln('------------------'),
    writeln('No exact diagnosis could be determined from the current rules.'),
    print_ranked_suggestions,
    nl.

print_diagnosis(Fault) :-
    fault_name(Fault, FaultName),
    recommendation(Fault, Recommendation),
    matched_symptoms(Fault, Symptoms),
    format('Most likely diagnosis: ~w~n', [FaultName]),
    format('Recommended action: ~w~n', [Recommendation]),
    print_matched_symptoms(Symptoms).

print_other_matches([]).
print_other_matches([Fault | Rest]) :-
    fault_name(Fault, FaultName),
    format('Additional exact match: ~w~n', [FaultName]),
    print_other_matches(Rest).

print_matched_symptoms([]).
print_matched_symptoms(Symptoms) :-
    writeln('Matched symptoms:'),
    print_symptom_reasons(Symptoms).

print_symptom_reasons([]).
print_symptom_reasons([Symptom | Rest]) :-
    question_text(Symptom, Question),
    format('- ~w~n', [Question]),
    print_symptom_reasons(Rest).

print_ranked_suggestions :-
    ranked_diagnoses([]),
    writeln('No close matches were found based on the current answers.').
print_ranked_suggestions :-
    ranked_diagnoses(RankedFaults),
    writeln('Closest matches based on your answers:'),
    print_ranked_faults(RankedFaults, 3).

print_ranked_faults(_, 0).
print_ranked_faults([], _).
print_ranked_faults([_Score-Fault | Rest], Remaining) :-
    Remaining > 0,
    fault_name(Fault, FaultName),
    recommendation(Fault, Recommendation),
    format('- ~w~n', [FaultName]),
    format('  Recommended action: ~w~n', [Recommendation]),
    NextRemaining is Remaining - 1,
    print_ranked_faults(Rest, NextRemaining).

% Ask only about symptoms that have not already been answered.
ask_missing_symptom(Symptom) :-
    known_yes(Symptom),
    !.
ask_missing_symptom(Symptom) :-
    known_no(Symptom),
    !.
ask_missing_symptom(Symptom) :-
    ask_user(Symptom).

% Read a yes/no response from the user for one symptom.
ask_user(Symptom) :-
    question_text(Symptom, Question),
    format('~w (yes/no): ', [Question]),
    flush_output,
    read_line_to_string(user_input, Input),
    normalize_answer(Input, Response),
    handle_response(Symptom, Response).

% Normalize user input so answers like "Yes" and "no" are both accepted.
normalize_answer(Input, Response) :-
    string(Input),
    string_lower(Input, LowerInput),
    normalize_space(string(TrimmedInput), LowerInput),
    strip_trailing_period(TrimmedInput, Normalized),
    answer_value(Normalized, Response).

normalize_answer(end_of_file, invalid).

strip_trailing_period(Input, Output) :-
    sub_string(Input, _, 1, 0, '.'),
    !,
    sub_string(Input, 0, _, 1, WithoutPeriod),
    normalize_space(string(Output), WithoutPeriod).
strip_trailing_period(Input, Input).

answer_value("yes", yes).
answer_value("y", yes).
answer_value("no", no).
answer_value("n", no).
answer_value("", invalid).
answer_value(_, invalid).

% Store valid answers in working memory and retry invalid input.
handle_response(Symptom, yes) :-
    remember_yes(Symptom).
handle_response(Symptom, no) :-
    remember_no(Symptom).
handle_response(Symptom, _) :-
    writeln('Please answer with yes or no.'),
    ask_user(Symptom).
```

## File: tests/diagnosis_tests.pl

```prolog
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
```
