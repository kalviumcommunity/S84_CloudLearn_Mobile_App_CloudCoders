# Architecture Overview

This project contains two Flutter app roots:
- Root app in `lib/` for base screens and services
- Full-featured app in `flut/lib/` with feature modules

Key layers used in `flut/lib/`:
- `data/` for models and repositories
- `services/` for Firebase and backend integrations
- `features/` and `screens/` for UI and flows
- `providers/` for state and business logic wiring

This document is informational and does not change runtime behavior.
