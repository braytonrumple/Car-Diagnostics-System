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
    writeln('Answer each question with yes. or no.'),
    nl,
    collect_answers,
    run_diagnosis.

% Visit each known fault and ask about any symptoms we do not know yet.
collect_answers :-
    fault(Fault),
    ask_missing_symptoms(Fault),
    fail.
collect_answers.

% Show the first diagnosis that fully matches the stored symptoms.
run_diagnosis :-
    diagnose(Fault, Recommendation),
    nl,
    format('Possible diagnosis: ~w~n', [Fault]),
    format('Recommended action: ~w~n', [Recommendation]),
    nl.
run_diagnosis :-
    nl,
    writeln('No diagnosis could be determined from the current rules.').

% Ask only about symptoms that have not already been answered.
ask_missing_symptoms(Fault) :-
    symptom(Fault, Symptom),
    \+ known_yes(Symptom),
    \+ known_no(Symptom),
    ask_user(Symptom),
    fail.
ask_missing_symptoms(_).

% Read a yes/no response from the user for one symptom.
ask_user(Symptom) :-
    question_text(Symptom, Question),
    format('~w (yes/no): ', [Question]),
    current_input(Stream),
    read_line_to_string(Stream, Input),
    normalize_answer(Input, Response),
    handle_response(Symptom, Response).

% Normalize user input so answers like "Yes" and "no" are both accepted.
normalize_answer(Input, Response) :-
    string(Input),
    string_lower(Input, LowerInput),
    normalize_space(string(Normalized), LowerInput),
    answer_value(Normalized, Response).

answer_value("yes", yes).
answer_value("y", yes).
answer_value("no", no).
answer_value("n", no).

% Store valid answers in working memory and retry invalid input.
handle_response(Symptom, yes) :-
    remember_yes(Symptom).
handle_response(Symptom, no) :-
    remember_no(Symptom).
handle_response(Symptom, _) :-
    writeln('Please answer with yes. or no.'),
    ask_user(Symptom).
