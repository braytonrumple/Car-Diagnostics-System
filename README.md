# Car Diagnostics Expert System

A rule-based car diagnostics expert system built with SWI-Prolog. The program asks the user about vehicle symptoms and uses Prolog inference rules to identify possible faults and recommend a next step.

## Overview

This project was created for a programming languages course as a classical rule-based artificial intelligence system. It uses Prolog facts, rules, backtracking, and dynamic predicates to simulate the reasoning process of a car diagnostics assistant.

## Requirements

- SWI-Prolog
- A terminal or command prompt

## Install SWI-Prolog

Use the official SWI-Prolog website for downloads:

- https://www.swi-prolog.org/

### macOS

Option 1: Homebrew

```bash
brew install swi-prolog
```

Option 2: Installer

Download the macOS package from the SWI-Prolog website and install it normally.

### Windows

Download the Windows installer from the SWI-Prolog website and run the setup wizard.

After installation, open Command Prompt or PowerShell and check:

```powershell
swipl --version
```

### Ubuntu or Debian Linux

```bash
sudo apt update
sudo apt install swi-prolog
```

### Verify Installation

Run:

```bash
swipl --version
```

If SWI-Prolog is installed correctly, it will print the installed version.

## Project Structure

```text
Car-Diagnostics-System/
├── .gitignore
├── README.md
├── docs/
│   └── structure.md
├── src/
│   ├── main.pl
│   ├── engine/
│   │   ├── diagnosis.pl
│   │   └── session.pl
│   ├── kb/
│   │   └── faults.pl
│   └── ui/
│       └── cli.pl
└── tests/
    └── diagnosis_tests.pl
```

## Modules

- `src/main.pl`: Entry point that starts the expert system.
- `src/engine/diagnosis.pl`: Core inference logic.
- `src/engine/session.pl`: Dynamic working memory for user answers.
- `src/kb/faults.pl`: Knowledge base of symptoms, diagnoses, and recommendations.
- `src/ui/cli.pl`: Command-line interaction loop.
- `tests/diagnosis_tests.pl`: Basic tests for diagnosis rules.

## Libraries and Built-In Modules Used

This project uses SWI-Prolog and its standard built-in features. No third-party libraries are required.

- `library(readutil)`: Used in the CLI to read full lines of user input.
- `plunit`: Used for the Prolog unit tests in `tests/diagnosis_tests.pl`.
- Dynamic predicates: Used in working memory with `assertz/1`, `retractall/1`, and `dynamic/1`.
- Backtracking and unification: Used by the diagnosis engine to match symptoms to faults.

## How To Run The Program

From the project root:

```bash
cd /Users/braytonrumple/Documents/GitHub/Car-Diagnostics-System
swipl -s src/main.pl
```

The program will ask symptom questions one at a time. Respond with:

```text
yes
no
```

You can also use:

```text
y
n
```

After the diagnosis is printed, the program closes automatically.

## Example Program Run

```text
========================================
      Car Diagnostics Expert System
========================================
Enter yes or no for each symptom question.

Does the engine fail to start? (yes/no): yes
Are the headlights or dashboard lights dim? (yes/no): yes
Do you hear repeated clicking when turning the key? (yes/no): yes
...

Diagnostic Summary
------------------
Most likely diagnosis: Dead Battery
Recommended action: Check battery charge, terminals, and consider a jump start or replacement.

Thank you for using the Car Diagnostics Expert System.
```

## How To Run The Tests

### Standard unit test output

```bash
swipl -q -s tests/diagnosis_tests.pl -t run_tests
```

### Detailed test output

This version prints the test scenario, inputs, and diagnosis result:

```bash
swipl -q -s tests/diagnosis_tests.pl -t run_detailed_tests
```

## Example Detailed Test Output

```text
Running detailed diagnosis tests...

Test 1: dead battery should be diagnosed
Inputs: engine_wont_start = yes, lights_dim = yes, clicking_sound = yes
Result: Fault = dead_battery
Recommendation: Check battery charge, terminals, and consider a jump start or replacement.
```

## How The System Works

1. The program clears any previous session data.
2. The CLI asks the user a series of symptom questions.
3. Each answer is stored in working memory as a dynamic predicate.
4. The diagnosis engine compares confirmed symptoms against the knowledge base.
5. If all required symptoms for a fault are present, the system returns an exact diagnosis.
6. If no exact match is found, the system ranks close matches based on partial symptom overlap.

## Prolog Features Demonstrated

- Facts: Used to define faults, symptoms, recommendations, and question prompts.
- Rules: Used to infer diagnoses from symptoms.
- Backtracking: Used to explore multiple possible diagnoses.
- Dynamic predicates: Used to store temporary user responses during a session.
- Pattern matching and unification: Used to match symptoms to possible faults.

## Current Limitations

- The system depends entirely on user-reported symptoms.
- The knowledge base is still limited compared to a real automotive diagnostic system.
- The program does not connect to real vehicle sensors or onboard diagnostics.
- Partial matches are ranked, but they are still based on simple rule scoring rather than probabilities.

## Future Improvements

- Expand the knowledge base with more detailed mechanical and electrical faults.
- Support probabilistic or confidence-based diagnosis ranking.
- Organize faults into multiple knowledge base files by subsystem.
- Add logging or saved diagnostic sessions.
