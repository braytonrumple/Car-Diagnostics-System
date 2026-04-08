# Base Architecture

This project follows a simple expert-system layout:

- `Knowledge Base`: Stores fault rules, recommendations, and required symptoms.
- `Working Memory`: Stores temporary yes/no answers given by the user during one session.
- `Inference Engine`: Matches observed symptoms to known faults.
- `CLI`: Asks the user questions and prints the final diagnosis.

## Inference Flow

1. Clear any previous session data.
2. Ask the user each symptom question once and store the answer.
3. Search the knowledge base for exact fault matches.
4. If all symptoms for a fault are confirmed, return that diagnosis.
5. If multiple faults match, list the additional exact matches.
6. If no exact match is found, rank close matches based on partial symptom overlap.

## Suggested Future Expansion

- Split electrical and mechanical faults into separate files.
- Add certainty scoring for partial matches.
- Support multiple recommended next actions.
- Log session results for later review.
