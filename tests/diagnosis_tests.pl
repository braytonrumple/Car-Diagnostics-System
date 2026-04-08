:- use_module('../src/engine/diagnosis.pl').
:- use_module('../src/engine/session.pl').

% Detailed runner for class demos when you want visible test output.
run_detailed_tests :-
    nl,
    writeln('Running detailed diagnosis tests...'),
    nl,
    run_dead_battery_test,
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

run_missing_symptom_test :-
    clear_session,
    remember_yes(engine_wont_start),
    remember_yes(lights_dim),
    writeln('Test 2: dead battery should not match when one symptom is missing'),
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

:- end_tests(diagnosis).
