# expense_tracker

A production-ready personal finance app built with Flutter, BLoC, Clean
Architecture, and Supabase.

## Features

- Email/password authentication (Supabase Auth) with password reset
- Income & expense transactions — add, edit, delete, search, filter, sort
- Lending tracker — money lent/borrowed, partial payments, full payment
  history, overdue detection
- Categories — default set + fully custom, income/expense split, safe delete
  (blocked while transactions reference the category)
- Dashboard — balance, income/expense totals, lending summary, recent activity
- Light/Dark/System theme, persisted locally
- Classic, minimal financial-app UI — no gradients, no glassmorphism

## Architecture

Strict Clean Architecture, three layers per feature:

```
lib/
├── core/            constants, error types, theme, utils, extensions,
│                    network (connectivity check), DI, router
└── features/
    ├── authentication/
    ├── dashboard/
    ├── transactions/
    ├── lending/
    ├── categories/
    └── settings/
        ├── data/          datasources, models, repository impl
        ├── domain/        entities, repository interface, use cases
        └── presentation/  bloc, pages, widgets
```

Dependency direction is always `presentation -> domain -> data`. The domain
layer has zero Flutter or Supabase imports — it's pure Dart.

Financial calculations that need to be exactly right (lending totals, partial
payment math) live in standalone, unit-tested domain services:
`lib/features/lending/domain/lending_calculator.dart` and
`lib/features/dashboard/domain/dashboard_calculator.dart`. The same
"cannot pay more than what's left" rule is enforced a second time inside a
Postgres function (`record_lending_payment` in `supabase/schema.sql`) so a
buggy or malicious client can never bypass it.

## Getting started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Set up Supabase

1. Create a project at [supabase.com](https://supabase.com).
2. Open the SQL Editor and run `supabase/schema.sql` — it creates every
   table, index, RLS policy, trigger, the `record_lending_payment` function,
   and seeds the default categories.
3. Copy `.env.example` to `.env` and fill in your project's URL and
   **anon/public** key (Project Settings → API). Never put the
   `service_role` key here — it must never ship inside a client app.

```bash
cp .env.example .env
```

### 3. Run

```bash
flutter run
```

### 4. Run tests

```bash
flutter test
```

`test/unit/lending_calculator_test.dart` covers the partial-payment math in
isolation. `test/bloc/lending_bloc_test.dart` covers the BLoC layer,
including that an overpayment is rejected client-side before it ever reaches
the repository.

## Security notes

- Row Level Security is enabled on every user-owned table; policies scope
  every read/write to `auth.uid()`.
- `user_id` is never trusted from the client — `BEFORE INSERT` triggers stamp
  it from the authenticated session on every insert.
- Lending payments only ever go through `record_lending_payment`, a
  `SECURITY DEFINER` function that re-validates the remaining balance
  server-side, independent of whatever the Flutter client already checked.
- Deleting a category that's still referenced by a transaction is blocked by
  a foreign key (`ON DELETE RESTRICT`), surfaced to the user as a friendly
  error instead of a raw Postgres exception.

## What's scaffolded vs. fully wired

Authentication, Lending (including partial payments + history), Transactions,
Categories, Dashboard, and Settings are all wired end-to-end and runnable
once Supabase credentials are in place. `freezed`/`json_serializable` are in
`pubspec.yaml` for future use (e.g. if you want generated `copyWith`/JSON on
top of the hand-written models here) but aren't required — nothing in this
codebase depends on generated code, so `flutter run` works without running
`build_runner`.
