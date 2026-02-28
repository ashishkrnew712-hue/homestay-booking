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

## ADR-004: Single Property First
**Date**: 2026-02-28
**Status**: Accepted
**Decision**: Build for single property, design data model to support multi-property later
**Rationale**: MVP timeline constraint, single property is immediate need
