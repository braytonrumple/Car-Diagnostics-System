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
