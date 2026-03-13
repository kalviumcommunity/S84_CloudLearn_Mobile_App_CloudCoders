import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return StreamBuilder<QuerySnapshot>(
            stream: taskProvider.tasksStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: Text('No data available'));
              }

              final tasks = snapshot.data!.docs;
              final totalTasks = tasks.length;
              final completedTasks = tasks.where((task) {
                final data = task.data() as Map<String, dynamic>;
                return data['completed'] ?? false;
              }).length;
              final completionPercentage = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Learning Progress',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Total Tasks: $totalTasks',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Completed Tasks: $completedTasks',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            LinearProgressIndicator(
                              value: completionPercentage / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${completionPercentage.toStringAsFixed(1)}% Complete',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (totalTasks == 0)
                      const Center(
                        child: Text(
                          'Start adding learning goals to track your progress!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    else if (completedTasks == totalTasks)
                      const Center(
                        child: Text(
                          'Congratulations! You\'ve completed all your learning goals.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),
                      )
                    else
                      Center(
                        child: Text(
                          'Keep going! You have ${totalTasks - completedTasks} tasks left.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}