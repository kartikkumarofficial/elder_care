# 💙 ElderCare – Connect, Monitor, and Care

**ElderCare** is a modern, cross-platform application designed to bridge the gap between caregivers and care receivers. Built with a focus on real-time monitoring and ease of use, it provides peace of mind through seamless location tracking, health analytics, and task management.

---

## ✨ Core Features

* 🔐 **Secure Authentication & Profiles:** User sign-up, login, and profile management powered by Supabase.
* 📍 **Real-Time Location Tracking:** Caregivers can view the live location of their linked care receiver on a map.
* 📊 **Health Analytics:** A simple, card-based interface to monitor the latest health vitals like heart rate and blood pressure.
* 🚀 **Role-Based Onboarding:** A smart onboarding flow that assigns 'Caregiver' or 'Care Receiver' roles and links their accounts securely.
* 📱 **Modern & Responsive UI:** Built with a clean, dark-themed interface that looks great on any device.
* ⚡ **Fast & Reactive State Management:** Powered by GetX for a smooth and predictable user experience.

---

## 📲 Quick Start

1.  **Clone the repository**

    ```bash
    git clone [https://github.com/your-username/elder_care.git](https://github.com/your-username/elder_care.git)
    cd elder_care
    ```

2.  **Install dependencies**

    ```bash
    flutter pub get
    ```

3.  **Set up Supabase**
    Open the file `lib/main.dart` and replace the placeholder values with your actual Supabase URL and Anon Key.

    ```dart
    // In lib/main.dart
    Future<void> main() async {
      WidgetsFlutterBinding.ensureInitialized();

      await Supabase.initialize(
        url: 'YOUR_SUPABASE_URL',       // <-- PASTE YOUR URL HERE
        anonKey: 'YOUR_SUPABASE_ANON_KEY', // <-- PASTE YOUR KEY HERE
      );

      runApp(const MyApp());
    }
    ```

4.  **Run the app**

    ```bash
    flutter run
    ```

---

## 📂 Project Structure

The project follows a clean architecture to separate concerns and improve maintainability.

```
lib/
├── controllers/     # State management logic (AuthController, LocationController, etc.)
├── models/          # Data models (Task, User)
├── presentation/
│   ├── screens/     # UI screens for each feature
│   └── widgets/     # Reusable UI components (e.g., BottomNavBar)
├── services/        # Business logic for APIs (LocationService, HealthDataService)
└── main.dart        # Entry point of the application
```

---

## 🌍 Future Enhancements

* **Medication Reminders:** A robust system for scheduling and tracking medication intake.
* **Video & Voice Calls:** In-app communication features for easy check-ins.
* **Emergency SOS Alerts:** An enhanced SOS system with automated alerts and calls.
* **Detailed Health Reports:** Generate and export weekly or monthly health summaries.

---

## 🛠️ Built With

* **Flutter** 💙 - The core framework for building the cross-platform UI.
* **Supabase** 🔐 - Handles authentication, database, and file storage.
* **GetX** ⚡ - For powerful and lightweight state management and navigation.
* **flutter_map** 🗺️ - For displaying interactive maps with OpenStreetMap.
* **fl_chart** 📊 - Used for creating beautiful and dynamic charts.
* **Image Picker** 🖼️ - For selecting profile pictures from the device gallery.

---

## 👨‍💻 Made by Kartik

Connect with me for updates, forks, and collaborations!
