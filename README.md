# 📱 Sender SMS App

A professional mobile application built using **Flutter**, designed for schools, educational centers, and institutions to send student grades, exam results, and periodic updates to parents via SMS in bulk, automatically, and directly from their phone.

---

## 🚀 Key Features

### 📊 1. Smart Excel Data Import
* Import student lists, grades, and phone numbers directly from Excel files.
* Auto-detects columns whether they are named in Arabic (الاسم، الدرجة، الهاتف) or English (name, degree, phone).
* Automatically cleans and normalizes phone numbers to fit standard mobile operator formats.

### 📲 2. Dual SIM Support
* Choose which active SIM card (SIM 1 or SIM 2) to send messages from directly within the app settings to optimize SMS package costs or cellular coverage.

### 🛡️ 3. Default SMS App Mode
* Seamlessly request to set the app as the default SMS handler on Android, allowing it to bypass system-level rate limits and protect the SIM card from blocking during bulk campaigns.

### ⏳ 4. Custom Rate Limiting & Live Controls
* Define custom delay intervals (in seconds) between each message to prevent network spam filters from flags.
* Full real-time control during sending campaigns: (Pause / Resume / Cancel).
* Programmatic `Keep Screen On` utility to prevent the CPU from entering low-power sleep mode, ensuring the sending loop runs continuously.

### 📝 5. Dynamic Message Templates
* Create and save reusable message templates using dynamic placeholders:
  * `{name}`: Automatically replaces with the student's name.
  * `{degree}`: Automatically replaces with the student's grade/mark.
  * `{phone}`: Automatically replaces with the student's phone number.

### 🛠️ 6. Robust Error Handling & Recovery
* Real-time validation of network coverage, carrier credits, and flight mode.
* Informative Arabic error logs (e.g., low balance, no service, radio off, rate limit exceeded).
* **Auto-Skip** failed recipients with a 5-second cooldown delay to allow the network to stabilize.
* A dedicated dashboard to review and resend failed logs after fixing any network or number issues.

### 📋 7. History & Detailed Reporting
* Keep an active archive of all past sending sessions (campaigns).
* Log status reports for each recipient (sent time, message payload, success/failure status with exact error reasons).
* Export session logs directly as Excel files for administrative record-keeping.

### ☁️ 8. Tracking & Updates (Firebase & Shorebird)
* Report anonymous stats (totals, successes, failures, phone lists contacted) to Firebase Console for server-side quality monitoring (retaining zero message contents for user privacy).
* Embedded with **Shorebird Code Push** to receive hot-patches instantly, bypassing app stores for critical updates.

---

## 🛠️ Technology Stack

* **Core Framework:** Flutter (SDK ^3.0.0) & Dart.
* **State Management:** Flutter BLoC / Cubit for clean separation of business logic and UI.
* **Local Storage:** Hive (Ultra-fast, lightweight key-value database for local logs, sessions, templates, and configurations).
* **Native Integration:** Kotlin custom MethodChannel integration for (`SmsManager`, `SubscriptionManager`, `BroadcastReceivers`, `RoleManager`).
* **Cloud Services:** Firebase Core, Firebase Auth, Cloud Firestore, Firebase Messaging.
* **Code Push:** Shorebird.

---

## 📂 Project Structure

This project follows a clean, feature-first modular architecture:

```text
lib/
├── core/
│   ├── constants/       # App constants (colors, strings, assets keys)
│   ├── di/              # Dependency Injection container (GetIt)
│   ├── routing/         # Application navigation router (GoRouter)
│   ├── services/        # Shared services (Hive database, FCM service, Android native bridge)
│   └── theme/           # UI Theme configurations (light & dark theme)
└── features/
    ├── auth/            # Authentications and account validations
    ├── failed_messages/ # Dashboard to retry and review failed logs
    ├── history/         # Sessions history list, logs viewer, and Excel export
    ├── home/            # Shell container layouts and dashboard navigation
    ├── import_excel/    # File picking, parsing, and validation of Excel lists
    ├── manual_sms/      # Form to send custom one-off messages manually
    ├── message_template/# Dynamic templates builder and catalog
    ├── notifications/   # System-wide alert logs manager
    ├── onboarding/      # Welcome slide overlays for first launch setup
    ├── send_sms/        # Queue processor view showing real-time sending progress
    └── settings/        # Interval sliders and default SIM select tools
```

---

## 🛡️ License & Privacy
* The application is built Local-First to respect student data privacy.
* All SMS text content is kept local on your physical device. Firebase integrations are restricted to numerical counters and log statistics to keep operations secure and private.

---

## ✍️ Developer
Developed with ❤️ by **Sohib Emad** (صهيب عماد).
