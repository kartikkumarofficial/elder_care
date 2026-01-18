# 💙 ElderCare
### A Connected Care Platform for Monitoring, Safety, and Peace of Mind

**ElderCare** is a modern, cross-platform caregiving application designed to seamlessly connect **caregivers** and **care receivers**. It enables real-time monitoring, scheduled reminders, and location awareness — helping families and caregivers ensure safety, consistency, and well-being without friction.

Built with **Flutter**, **Supabase**, and **GetX**, ElderCare focuses on reliability, clarity, and real-world usability.

---

## 🚀 Why ElderCare?

Caring for elders often means juggling:
- Medication schedules
- Daily tasks and appointments
- Location safety and wandering concerns
- General health and mood awareness
- Emergency preparedness

**ElderCare centralizes all of this into a single, intuitive platform**, reducing cognitive load for caregivers while empowering care receivers to maintain their independence.

---

## ✨ Key Features

- **👥 Role-Based Care System**:
    - Smart onboarding for **Caregiver** and **Care Receiver** roles.
    - Secure account linking between caregiver and receiver.
    - Personalized dashboards tailored to each user's role.

- **📋 Task & Medication Management**:
    - Create, edit, and manage daily tasks and medication reminders.
    - Scheduled reminders with repeat options (daily, custom days).
    - Smooth swipe-to-complete gestures with undo support.

- **⏰ Intelligent Reminders**:
    - Reliable, alarm-based task reminders that work even if the app is closed.
    - Automatic alarm cleanup when tasks are removed or completed.
    - Utilizes a foreground service for high-priority alert delivery.

- **📍 Real-Time Location & Device Monitoring**:
    - Live location tracking for care receivers (with permission).
    - Periodic background location updates for peace of mind.
    - Monitor device battery level and connectivity status.
    - Track step counts and online/offline presence.

- **🚨 Emergency SOS**:
    - A prominent, one-tap SOS button for emergencies.
    - Instantly sends a high-priority alert and real-time location to linked caregivers.

- **⚡ Smooth & Reactive UX**:
    - Built with GetX for predictable and efficient state management.
    - Optimistic UI updates provide a fast, responsive feel.
    - Haptic feedback and clean animations for an intuitive user experience.

---

## 🧱 Tech Stack

| Layer | Technology |
|---|---|
| Framework | **Flutter 3.x** |
| Backend & DB | **Supabase** (Auth, PostgreSQL, Realtime) |
| State Management | **GetX** |
| Location Services | `geolocator`, `permission_handler` |
| Background Services | `flutter_background_service` |
| Local Notifications | `flutter_local_notifications` |
| UI | **Material 3** + Custom Widgets |
| Image Handling | `image_picker`, `cloudinary` |

---

## 📲 Getting Started

#### 1. Prerequisites
- Flutter SDK (version 3.x or higher)
- An IDE (like VS Code or Android Studio)
- A Supabase account

#### 2. Clone the Repository
```bash
git clone https://github.com/your-username/elder_care.git
cd elder_care
```

#### 3. Install Dependencies
```bash
flutter pub get
```

#### 4. Configure Supabase
1.  Create a new project on [Supabase](https://supabase.com).
2.  Use the SQL schemas from the `/supabase` directory in this project to set up your tables.
3.  Open `lib/main.dart` and initialize Supabase with your project credentials:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

#### 5. Run the App
```bash
flutter run
```

---

## 📁 Project Structure

The project follows a feature-first architecture, organized into modules.

```
lib/
├── app/                # App-level config, constants, and utilities
├── core/               # Core business logic, models, and shared controllers
├── modules/            # Feature-based modules
│   ├── auth/           # Authentication, onboarding, role selection
│   ├── care_receiver/  # Features for the care receiver role
│   ├── caregiver/      # Features for the caregiver role
│   ├── dashboard/      # Main dashboard screen
│   ├── events/         # Event/task creation and management
│   ├── profile/        # User profile and settings
│   └── splash/         # Initial splash/loading screen
├── services/           # Background services (location, alarms)
└── main.dart           # App entry point
```

---

## 🔐 Security & Privacy

- Authentication is managed by **Supabase Auth**.
- **Row-Level Security (RLS)** is enabled in Supabase to ensure a user can only access their own data or the data of their linked care receiver.
- User data is only visible to the user and their securely linked caregivers.
- The app only requests permissions that are essential for its features (e.g., Location, Notifications).

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/your-username/elder_care/issues).

1.  **Fork** the project.
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a **Pull Request**.

---

## 📝 License

This project is licensed under the MIT License - see the `LICENSE.md` file for details.

---

## 👨‍💻 Author

**Kartik Kumar**
- Flutter Developer
- Backend & Systems Enthusiast

⭐ If you find this project useful, please consider starring the repository!
```