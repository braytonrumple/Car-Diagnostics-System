:- module(diagnosis, [
    diagnose/2,
    matches_fault/2,
    matching_diagnoses/1,
    ranked_diagnoses/1
]).

% Use working memory plus the static knowledge base to infer a fault.
:- use_module('./session.pl').
:- use_module('../kb/faults.pl').

% Find the best fully matching fault whose symptoms all match the user's answers.
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

% Collect every symptom required for a fault and verify each one.
matches_fault(Fault, Symptoms) :-
    fault(Fault),
    findall(Symptom, symptom(Fault, Symptom), Symptoms),
    all_symptoms_present(Symptoms).

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
