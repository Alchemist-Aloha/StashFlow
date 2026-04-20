# Team Assembly

## Task Shape
- **Domain**: Engineering / Ops
- **Output Target**: Code (Final Polish) / Plan (Release v1.11.0)
- **Risk**: Low (Localizations verified, preparing release)

## Role Lanes
- **Orchestration**: `omg-director` (Pipeline management)
- **Decision**: `omg-consultant` (Release gating)
- **Execution**: `omg-executor` (Final UI checks, version bumps)
- **Quality**: `omg-reviewer` / `omg-verifier` (Smoke tests, compilation checks)

## Model Profiles
- **omg-director**: `gemini-3.1-pro-preview`
- **omg-consultant**: `gemini-3.1-pro-preview`
- **omg-executor**: `gemini-3-flash-preview`
- **omg-verifier**: `gemini-3.1-pro-preview`
