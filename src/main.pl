:- module(main, []).

% Load the command-line interface for the expert system.
:- use_module('./ui/cli.pl').

% Start the program when the file is launched with SWI-Prolog.
run :-
    cli:start,
    halt.

:- initialization(run, main).
