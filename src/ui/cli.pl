:- module(cli, [start/0]).

% Import the inference engine, session memory, and knowledge base.
:- use_module('../engine/diagnosis.pl').
:- use_module('../engine/session.pl').
:- use_module('../kb/faults.pl').
:- use_module(library(readutil)).

% Begin a fresh diagnostic session and then print the result.
start :-
    clear_session,
    writeln('Car Diagnostics Expert System'),
    writeln('Answer each question with yes or no.'),
    nl,
    collect_answers,
    run_diagnosis.

% Ask each unique symptom once so the user is not asked duplicate questions.
collect_answers :-
    findall(Symptom, question_text(Symptom, _), Symptoms),
    list_to_set(Symptoms, UniqueSymptoms),
    ask_symptom_list(UniqueSymptoms).

ask_symptom_list([]).
ask_symptom_list([Symptom | Rest]) :-
    ask_missing_symptom(Symptom),
    ask_symptom_list(Rest).

% Show exact matches first, otherwise show the most likely partial matches.
run_diagnosis :-
    matching_diagnoses([Fault | OtherFaults]),
    nl,
    writeln('Diagnosis result:'),
    print_diagnosis(Fault),
    print_other_matches(OtherFaults),
    nl.
run_diagnosis :-
    nl,
    writeln('No exact diagnosis could be determined from the current rules.'),
    print_ranked_suggestions,
    nl.

print_diagnosis(Fault) :-
    fault_name(Fault, FaultName),
    recommendation(Fault, Recommendation),
    format('Most likely diagnosis: ~w~n', [FaultName]),
    format('Recommended action: ~w~n', [Recommendation]).

print_other_matches([]).
print_other_matches([Fault | Rest]) :-
    fault_name(Fault, FaultName),
    format('Also matched: ~w~n', [FaultName]),
    print_other_matches(Rest).

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
    format('  Suggested action: ~w~n', [Recommendation]),
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
