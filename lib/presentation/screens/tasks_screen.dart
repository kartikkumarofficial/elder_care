import 'package:flutter/material.dart';

// 1. Home Screen - Dashboard style
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, Caregiver 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
            const SizedBox(height: 20),
            _dashboardCard(
              context,
              title: "Today's Tasks",
              subtitle: "5 pending | 3 completed",
              icon: Icons.task_alt,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _dashboardCard(
              context,
              title: "Elder Wellbeing",
              subtitle: "Feeling good today",
              icon: Icons.favorite,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            _dashboardCard(
              context,
              title: "Upcoming Check-in",
              subtitle: "4:00 PM with Mr. Sharma",
              icon: Icons.schedule,
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(BuildContext context,
      {required String title,
        required String subtitle,
        required IconData icon,
        required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
            ],
          )
        ],
      ),
    );
  }
}

// 2. Tasks Screen
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Care Tasks'),
      ),
      body: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
            title: Text('Task ${index + 1}', style: const TextStyle(color: Colors.white)),
            subtitle: const Text('Walk at 4 PM', style: TextStyle(color: Colors.white70)),
            trailing: IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }
}

// 3. Emergency Screen
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Emergency Help',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.sos, size: 28),
              label: const Text('Send SOS', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('My Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            const SizedBox(height: 16),
            const Text('Ravi Kumar', style: TextStyle(color: Colors.white, fontSize: 20)),
            const Text('Primary Caregiver', style: TextStyle(color: Colors.white70)),
            const Divider(height: 40, color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
