import 'package:domandito/modules/admin/views/all_questions_screen.dart';
import 'package:domandito/modules/admin/views/all_users_screen.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(color: AppColors.primary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.people, color: AppColors.primary),
            title: const Text('All Users'),
            subtitle: const Text('View and manage users'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              pushScreen(context, screen: const AllUsersScreen());
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.question_answer,
              color: AppColors.primary,
            ),
            title: const Text('All Questions'),
            subtitle: const Text('View and interact with questions'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              pushScreen(context, screen: const AllQuestionsScreen());
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
