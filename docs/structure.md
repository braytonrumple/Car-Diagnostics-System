# Base Architecture

This project follows a simple expert-system layout:

- `Knowledge Base`: Stores fault rules, recommendations, and required symptoms.
- `Working Memory`: Stores temporary yes/no answers given by the user during one session.
- `Inference Engine`: Matches observed symptoms to known faults.
- `CLI`: Asks the user questions and prints the final diagnosis.

## Inference Flow

1. Clear any previous session data.
2. Try a possible fault from the knowledge base.
3. Verify each required symptom.
4. If a symptom is unknown, ask the user and cache the answer.
5. If all symptoms match, return the diagnosis and recommendation.
6. If not, backtrack and try the next fault.

## Suggested Future Expansion

- Split electrical and mechanical faults into separate files.
- Add certainty scoring for partial matches.
- Support multiple recommended next actions.
- Log session results for later review.
