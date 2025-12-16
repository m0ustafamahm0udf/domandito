import 'package:flutter/material.dart';

class SafetyStandardsScreen extends StatelessWidget {
  const SafetyStandardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Safety Standards'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Child Safety and Abuse Prevention Standards',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'At Domandito, the safety of our users—especially minors—is our highest priority. '
              'We are committed to preventing child sexual abuse and exploitation and have implemented comprehensive standards and procedures to protect our community.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              '1. Our Commitment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• We strictly prohibit any content, behavior, or activity that exploits or harms children.\n'
              '• All user-generated content is monitored to ensure compliance with child protection laws.\n'
              '• We provide tools and education to help parents and guardians keep children safe online.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              '2. Policies Against Child Sexual Abuse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• No user may upload, share, or request sexual content involving minors.\n'
              '• Accounts found violating these rules are immediately suspended or banned.\n'
              '• We comply with all applicable laws, including reporting requirements to authorities.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              '3. Reporting Mechanisms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Users can report any content, behavior, or account that may involve child abuse:\n'
              '• In-app reporting tools: Use the “Report” button on any content or profile.\n'
              '• Email: m0ustafamahm0ud@yahoo.com\n'
              '• We respond promptly to all reports and take necessary actions to protect the community.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              '4. Education and Awareness',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Resources for parents and guardians on safe online practices.\n'
              '• Educational content for users to recognize and avoid unsafe situations.\n'
              '• Regular updates and guidance on preventing abuse in online communities.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              '5. Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'For questions or concerns about child safety:\n'
              '• Email: m0ustafamahm0ud@yahoo.com\n'
              '• Phone: +201062429287\n'
              '• Website: https://domandito.com/#/child_safety',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
