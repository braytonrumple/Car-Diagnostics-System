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
