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

highest_ranked_faults([Score-Fault | Rest], Faults) :-
    !,
    highest_ranked_faults(Rest, Score, [Fault], Faults).
highest_ranked_faults([Fault | Rest], Faults) :-
    scored_fault(Fault, Score),
    highest_ranked_faults(Rest, Score, [Fault], Faults).

highest_ranked_faults([], _BestScore, Faults, Faults).
highest_ranked_faults([Score-Fault | Rest], BestScore, CurrentFaults, Faults) :-
    !,
    compare_fault_score(Score, Fault, Rest, BestScore, CurrentFaults, Faults).
highest_ranked_faults([Fault | Rest], BestScore, CurrentFaults, Faults) :-
    scored_fault(Fault, Score),
    compare_fault_score(Score, Fault, Rest, BestScore, CurrentFaults, Faults).

compare_fault_score(Score, Fault, Rest, BestScore, CurrentFaults, Faults) :-
    (   Score > BestScore
    ->  highest_ranked_faults(Rest, Score, [Fault], Faults)
    ;   Score =:= BestScore
    ->  append(CurrentFaults, [Fault], UpdatedFaults),
        highest_ranked_faults(Rest, BestScore, UpdatedFaults, Faults)
    ;   highest_ranked_faults(Rest, BestScore, CurrentFaults, Faults)
    ).
