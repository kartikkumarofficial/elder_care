# 🧓 Eldercare App v2.0

A real-time caregiving Flutter app built with ❤️ using Supabase and GetX. Eldercare bridges the gap between caregivers and care receivers by offering seamless task management, location tracking, inactivity alerts, and emergency response – all in one platform.

---

## 📱 Features

### 👥 Role-Based Access
- **Care Receiver**: Shares real-time location and receives care reminders.
- **Caregiver**: Manages tasks, tracks health status, and monitors location/activity.

### 🔗 Care ID Linking
- Secure one-time **care ID** system to link caregivers with their respective care receivers.

### 📍 Live Location Tracking
- Real-time updates of the care receiver’s location via Supabase.

### ⏰ Reminders & Appointments
- Caregivers can set medication reminders or appointment alerts for receivers.

### ⚠️ Inactivity Alerts
- Automatically detect inactivity for a configured duration and notify caregivers.

### 💓 Health Status Monitoring
- View and update basic health parameters of the receiver (e.g., heart rate, symptoms, vitals).

### 🚨 SOS Emergency Button
- One-tap SOS alert from care receivers to caregivers for emergencies.

---

## 🛠️ Tech Stack

- **Flutter** – UI development
- **GetX** – State & route management
- **Supabase** – Authentication, real-time database
- **Cloudinary** – For profile image uploads
- **Hive** *(optional)* – Offline support (future)

---

## 📁 Folder Structure

lib/
├── controllers/ # GetX Controllers (Auth, Nav, User, Location)
├── models/ # User and location models
├── presentation/
│ ├── screens/ # UI screens (Login, Dashboard, Location, Profile, etc.)
│ └── widgets/ # Shared widgets
├── services/ # Supabase & location services
├── bindings/ # Dependency bindings for controllers
└── main.dart # App entry point

yaml
Copy
Edit

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- Supabase project
- Cloudinary account

### 1. Clone the Repo
```bash
git clone https://github.com/yourusername/eldercare-app.git
cd eldercare-app
2. Install Dependencies
bash
Copy
Edit
flutter pub get
3. Configure Supabase & Cloudinary
Add your supabaseUrl and supabaseKey in lib/services/supabase_service.dart

Set Cloudinary credentials in lib/services/cloudinary_service.dart

4. Run the App
bash
Copy
Edit
flutter run
🧪 Upcoming Features
✅ Inactivity detection alert

✅ Custom appointment & task scheduling

🔜 Voice assistant (for elderly)

🔜 Health device integration (optional)

🔜 Notifications and alerts

👨‍💻 Author
Kartik Kumar
Flutter Developer | GDG Core Member
LinkedIn • Twitter

📄 License
This project is open-source and available under the MIT License.

yaml
Copy
Edit

---

Let me know if you'd like:
- A lighter version for a hackathon.
- Setup of `.env` for credentials.
- Badge images for features (for GitHub readme polish).