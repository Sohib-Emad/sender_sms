# Claude Development Rules — Flutter / Dart
> These rules apply to every file, every response, every suggestion.
> No exceptions. No excuses.

---

## 1. Code Length — Hard Limit

- **Maximum 100 lines per file.**
- If a file approaches 100 lines → extract widgets, helpers, or extensions immediately.
- UI pages are **composition shells only** — they assemble widgets, they do not define them.
- Cubits emit state — they do not contain UI logic or string formatting.

---

## 2. Flutter Best Practices

### Widgets
- Prefer `const` constructors everywhere possible.
- Never use `setState` inside a `BlocBuilder` or `BlocListener`.
- Extract every repeated widget into its own file under `widgets/`.
- Use `Key` parameters on list items and dynamic widgets.
- Avoid deep nesting — max 4 levels of widget tree per file.

### State Management (BLoC / Cubit)
- One Cubit per feature — no cross-feature Cubit calls.
- States use `Equatable` or `freezed` — never plain classes.
- Cubits never hold `BuildContext`.
- Emit `loading` before every async operation, `error` on failure.
- Close all `StreamSubscription`s and `Timer`s in `close()`.

### Navigation
- Use named routes only — no inline `MaterialPageRoute` inside widgets.
- Pass arguments via `settings.arguments` — never via constructors directly in route files.
- Always handle the `default` case in `onGenerateRoute`.

### Async
- Every `async` function has a `try/catch`.
- Never swallow errors silently with empty `catch (_) {}` unless explicitly non-fatal with a comment explaining why.
- Network errors and auth errors must be distinguished — never treat them the same.

### Performance
- Use `ListView.builder` not `ListView` with children for lists.
- Avoid rebuilding the entire tree — use `BlocSelector` for partial rebuilds.
- Images use `cached_network_image` — never raw `Image.network`.

---

## 3. Dart Best Practices

### Naming
- Classes: `PascalCase` — `UserData`, `AuthCubit`.
- Files: `snake_case` — `user_data.dart`, `auth_cubit.dart`.
- Private members: prefix with `_` — `_refreshToken`, `_saveToken()`.
- Constants: `lowerCamelCase` — `const maxRetries = 5`.

### Code Style
- Prefer `final` over `var` everywhere.
- Use `??` and `?.` — avoid explicit null checks when unnecessary.
- Use `if (condition)` in collection literals instead of ternary spread.
- Prefer expression bodies `=>` for single-line functions.
- No magic numbers — extract to named constants.

### Models
- All models use `json_serializable` — no manual `fromJson`/`toJson`.
- All models implement `Equatable` or use `freezed`.
- Models are immutable — use `copyWith` for modifications.
- Never put business logic inside a model.

### Imports
- Order: dart → flutter → packages → local (separated by blank lines).
- Use relative imports for files within the same feature.
- Use absolute imports (`package:ecos/...`) across features.

---

## 4. Project Structure Rules

```
lib/
├── core/
│   ├── di/                  # Dependency injection only
│   ├── routing/             # AppRouter + AppRoutes
│   ├── services/            # Shared services (API, DB, Sync)
│   └── widgets/             # Shared/global widgets
└── features/
    └── {feature}/
        ├── data/
        │   ├── models/      # Data classes (@JsonSerializable)
        │   ├── repos/       # Repository classes
        │   └── api/         # API service classes
        ├── logic/
        │   └── cubit/       # Cubit + State (freezed)
        └── ui/
            ├── {feature}_page.dart   # Shell only — under 100 lines
            └── widgets/              # All extracted sub-widgets
```

- Feature folders are **self-contained** — no feature imports another feature's UI.
- Shared logic goes in `core/` — not copy-pasted across features.

---

## 5. Security Review Checklist

Claude must flag any of the following issues when reviewing or writing code:

### Authentication & Sessions
- [ ] Refresh tokens stored in plain `SharedPreferences` → must use `flutter_secure_storage` or encrypted SQLite.
- [ ] Access tokens logged to console in production → must be stripped.
- [ ] Empty `catch` blocks around auth calls that silently ignore session expiry.
- [ ] `init()` running before the local database is initialized → causes false logout.
- [ ] App lifecycle resume triggering `logout()` on any network error (not just 401).

### Data Storage
- [ ] Sensitive data (tokens, passwords, user IDs) stored in unencrypted tables.
- [ ] Passwords compared in plaintext without BCrypt when BCrypt is available.
- [ ] User data cached to disk without expiry or invalidation logic.

### API & Network
- [ ] API keys or secrets hardcoded in Dart source files.
- [ ] HTTP used instead of HTTPS for any endpoint.
- [ ] API responses trusted without validation (no null checks, no type casting guards).
- [ ] No timeout set on network requests — can hang indefinitely.

### Input & Injection
- [ ] Raw SQL string concatenation instead of parameterized queries (`whereArgs`).
- [ ] User input rendered directly in HTML or WebView without sanitization.
- [ ] `jsonDecode` called without `try/catch` on untrusted input.

### Permissions & Access Control
- [ ] UI routes accessible without checking user role or permission.
- [ ] Permission checks done only on the frontend — no backend enforcement assumed.
- [ ] Suspended / banned users able to reach any authenticated route.

### Code & Dependencies
- [ ] `kDebugMode` guards missing on debug-only logs that expose sensitive data.
- [ ] Dependencies not pinned to versions (using `any` in pubspec.yaml).
- [ ] Dead code or unused imports left in production files.

---

## 6. Before Every Response

Claude must internally verify:

1. Does any file I'm writing exceed 100 lines? → Split it.
2. Does any `catch` block silently ignore a meaningful error? → Add a comment or handle it.
3. Is any sensitive value (token, password, userId) exposed in a log or UI? → Remove it.
4. Is there a raw SQL string without `whereArgs`? → Parameterize it.
5. Is any widget defined inline that could be its own file? → Extract it.
6. Is `const` missing anywhere it could be added? → Add it.
7. Is there a `Timer` or `StreamSubscription` without a `cancel()` in `dispose`/`close`? → Fix it.

---

## 7. What Claude Must Never Do

- Never write a file over 100 lines without splitting it first.
- Never store tokens or passwords in plain `SharedPreferences`.
- Never use `print()` in production code — use a proper logger with `kDebugMode` guard.
- Never call `context.read()` inside `initState` directly — use `addPostFrameCallback`.
- Never import a feature's UI layer from another feature.
- Never write manual `fromJson`/`toJson` when `json_serializable` is available.
- Never use `dynamic` as a return type unless absolutely unavoidable with a comment.
- Never leave a `TODO` without a linked issue or explanation.
