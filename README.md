"# S84_CloudLearn_Mobile_App_CloudCoders" ☁️ CloudLearn

🎯 Problem Statement
Students lack a dedicated, mobile-first platform to learn abstract cloud computing concepts. Existing resources are often desktop-heavy, making it difficult to track learning progress or save architectural notes on the move.

💡 Solution:
A reactive mobile application built with Flutter and Firebase that provides:

    📱 Mobile-First Learning: Bite-sized cloud modules optimized for small screens.

    🔄 Real-Time Sync: Instant progress tracking across devices via Firestore.

    📝 Cloud Notes: A persistent digital notebook for cloud snippets and diagrams.

    🔐 Secure Access: Personalized learning paths protected by Firebase Auth.

🧩 Tech Stack

Frontend: Flutter • Dart • Provider/Riverpod (State Management)

Backend: Firebase Auth • Cloud Functions (Optional)

Database: Cloud Firestore (NoSQL) • Firebase Local Persistence

Storage: Firebase Cloud Storage (Media & Diagrams)

Infrastructure: GitHub Actions (CI/CD for APK) • Firebase Console
👥 Team Structure (Member Focused: Backend)
MEMBER 2 — Backend & Data Architect (Akanksha Kumari )

Responsibilities:

    Firebase ecosystem initialization & environment config

    Firestore NoSQL schema design & data modeling

    Security rules & Role-Based Access Control (RBAC)

    Async data streams & repository pattern implementation

Sprint Contribution:

Phase 1: Plan & Design (Days 1–5) - 🏗️ Initialize Firebase project & link Android/iOS apps

    📊 Design Firestore collections (Courses, UserProgress, Notes)

    📝 Draft JSON data models for cloud modules

    🔐 Define Firebase Auth requirements (Email/Pass)

Phase 2: Build & Integrate (Days 6–15) - 🔑 Implement Firebase Auth logic & User Profile creation

    🛠️ Setup Firestore CRUD services in Dart

    🛡️ Write Firestore Security Rules for user data privacy

    📡 Implement StreamBuilder logic for real-time progress updates

    🖼️ Configure Firebase Storage for architectural images

Phase 3: Refine & Deploy (Days 16–19) - 🚀 Optimize database queries & indexing

    🧪 Backend integration testing & error handling

    🔒 Final Security Audit on Firestore Rules

    📦 Assist in CI/CD pipeline setup for automated builds

Phase 4: Showcase (Day 20) - 🎬 Live demonstration of real-time data sync

    📚 Documentation of Backend Architecture & Data Flow


-------------------------------------------------------------

MEMBER 3 — Backend & DevOps Engineer (Arman Singh)
Responsibilities:
Authentication & User Lifecycle: Managing user sign-up, password resets, and session persistence.
Media & Asset Management: Handling image uploads (diagrams/notes) to Firebase Storage and generating download URLs.
Backend Automation: Setting up GitHub Actions for CI/CD and managing the Firebase CLI for deployments.
Offline Data Persistence: Ensuring the app works offline by configuring Firestore Local Persistence.
Sprint Contribution (Member 3)
Phase 1: Plan & Design (Days 1–5)
Auth Flow: Map out the user journey from "Sign Up" to "Onboarding."
Storage Structure: Define the folder structure in Firebase Storage (e.g., /users/{uid}/notes/diagrams/).
CI/CD Setup: Initialize the GitHub repository with a basic workflow to check for code errors.
Phase 2: Build & Integrate (Days 6–15)
Auth Implementation: Code the Firebase Auth logic (Email/Password & Google Sign-in).
Storage Services: Build a service in Dart to upload images and fetch their URLs for the Cloud Notes feature.
Offline Support: Write logic to ensure that if a student takes a note in a "no-network" zone (like a basement), it syncs when they are back online.
Phase 3: Refine & Deploy (Days 16–19)
Performance Tuning: Monitor Firebase usage to ensure queries are fast and efficient.
Automated Builds: Configure GitHub Actions to automatically build a new APK (Android app file) every time you push code to the firebases branch.
Logging: Set up basic error logging to track if the app crashes during data sync.
Phase 4: Showcase (Day 20)
Deployment: Ensure the final version is deployed to Firebase Hosting or App Distribution.
Documentation: Write the "Deployment Guide" and explain the CI/CD pipeline for the final report.