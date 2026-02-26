import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Welcome Header
            Text(
              'Welcome Back,',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.displayName ?? "Learner",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F1F64),
              ),
            ),
            const SizedBox(height: 40),
            
            // Quick Actions Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    icon: Icons.school,
                    label: 'My Courses',
                    color: Colors.blueAccent,
                    onTap: () {},
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.emoji_events,
                    label: 'Achievements',
                    color: Colors.amber,
                    onTap: () {},
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.people,
                    label: 'Community',
                    color: Colors.green,
                    onTap: () {},
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.settings,
                    label: 'Settings',
                    color: Colors.grey,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {
    required IconData icon, 
    required String label, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
