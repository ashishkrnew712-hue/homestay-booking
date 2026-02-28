# DECISIONS.md — Architecture Decision Records

## ADR-001: Cross-Platform Framework
**Date**: 2026-02-28
**Status**: Accepted
**Decision**: Use Flutter (Dart) for cross-platform mobile development
**Rationale**: User preference, single codebase for Android + iOS, modern UI capabilities
**Alternatives**: React Native, native development

## ADR-002: Backend & Database
**Date**: 2026-02-28
**Status**: Accepted
**Decision**: Use Firebase (Firestore, Auth, FCM)
**Rationale**: Real-time sync via Firestore listeners, built-in auth, FCM for push notifications, fast to set up for MVP
**Alternatives**: Supabase, custom backend

## ADR-003: Payment Strategy
**Date**: 2026-02-28
**Status**: Accepted
**Decision**: Offline UPI payments (no in-app payment processing)
**Rationale**: Simpler scope for MVP, avoids payment gateway integration complexity
**Alternatives**: Razorpay, Stripe integration

## ADR-005: App Flow — Direct to Login
**Date**: 2026-02-28
**Status**: Accepted
**Decision**: No splash screen or onboarding — app opens directly to login
**Rationale**: Only 2 known owners use the app, no need for onboarding

## ADR-006: Room Management via Firestore
**Date**: 2026-02-28
**Status**: Accepted
**Decision**: Rooms stored in Firestore (not hardcoded), editable without app update
**Rationale**: Flexibility to add/rename rooms later without redeploying

## ADR-007: Flat Firestore Collections
**Date**: 2026-02-28
**Status**: Accepted
**Decision**: Use flat top-level collections (`/rooms`, `/bookings`) not nested sub-collections
**Rationale**: Easier to query all bookings across rooms for dashboard/calendar views

## ADR-008: Riverpod State Management
**Date**: 2026-02-28
**Status**: Accepted
**Decision**: Use Riverpod for Flutter state management
**Rationale**: Modern, testable, excellent integration with Firebase streams
**Alternatives**: Bloc, Provider

## ADR-009: Email/Password Authentication
**Date**: 2026-02-28
**Status**: Accepted
**Decision**: Email/password login, no forgot password flow (reset via Firebase Console)
**Rationale**: Simplest auth for 2-owner MVP, phone OTP adds unnecessary complexity

## ADR-004: Single Property First
**Date**: 2026-02-28
**Status**: Accepted
**Decision**: Build for single property, design data model to support multi-property later
**Rationale**: MVP timeline constraint, single property is immediate need
