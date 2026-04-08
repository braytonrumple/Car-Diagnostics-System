:- module(diagnosis, [
    diagnose/2,
    matches_fault/2
]).

% Use working memory plus the static knowledge base to infer a fault.
:- use_module('./session.pl').
:- use_module('../kb/faults.pl').

% Find the first fault whose full symptom list matches the user's answers.
diagnose(Fault, Recommendation) :-
    fault(Fault),
    matches_fault(Fault, _Symptoms),
    recommendation(Fault, Recommendation),
    !.

% Collect every symptom required for a fault and verify each one.
matches_fault(Fault, Symptoms) :-
    findall(Symptom, symptom(Fault, Symptom), Symptoms),
    all_symptoms_present(Symptoms).

% A fault only matches if every required symptom is known to be true.
all_symptoms_present([]).
all_symptoms_present([Symptom | Rest]) :-
    known_yes(Symptom),
    all_symptoms_present(Rest).
