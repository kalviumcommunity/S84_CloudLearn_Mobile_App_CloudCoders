# Deployment Notes

Pre-deploy sequence:
1. Validate Firestore and Storage rules
2. Confirm app versioning for target platforms
3. Run smoke tests on target environments
4. Publish only after regression checks pass

Post-deploy sequence:
1. Monitor logs for critical errors
2. Verify onboarding, auth, and course flows

Deployment notes are informational only.
