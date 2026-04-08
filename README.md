# Car Diagnostics Expert System

A rule-based car diagnostics expert system built with SWI-Prolog. The program asks the user about vehicle symptoms and uses Prolog inference rules to identify possible faults and recommend a next step.

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

## Next Steps

- Expand the knowledge base with more vehicle faults.
- Add more detailed repair guidance.
- Improve the question flow and support multiple possible diagnoses.
