import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String profileName = 'StudySphere User';
  String profileEmail = 'user@example.com';
  bool notificationsEnabled = true;

  void _openEditProfile() async {
    final result = await Navigator.push<ProfileUpdateResult>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          name: profileName,
          email: profileEmail,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        profileName = result.name;
        profileEmail = result.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1ECB9B),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.person, color: Color(0xFF1ECB9B)),
              title: Text(profileName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(profileEmail),
              trailing: TextButton(
                onPressed: _openEditProfile,
                child: const Text('Edit'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings, color: Color(0xFF1ECB9B)),
                  title: const Text('App Preferences'),
                  subtitle: const Text('Manage notifications and app behavior'),
                ),
                SwitchListTile(
                  title: const Text('Notifications'),
                  value: notificationsEnabled,
                  onChanged: (value) => setState(() => notificationsEnabled = value),
                  secondary: const Icon(Icons.notifications_active, color: Color(0xFF1ECB9B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Color(0xFF1ECB9B)),
                  title: const Text('About StudySphere'),
                  subtitle: const Text('Version 1.0.0 • A study companion app'),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: Color(0xFF1ECB9B)),
                  title: const Text('Support'),
                  subtitle: const Text('Contact us for help and feedback'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AlertDialog(
                        title: Text('Support'),
                        content: Text('Email: support@studysphere.app'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;

  const EditProfileScreen({super.key, required this.name, required this.email});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final updatedName = nameController.text.trim();
    final updatedEmail = emailController.text.trim();

    if (updatedName.isEmpty || updatedEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email cannot be empty.')),
      );
      return;
    }

    Navigator.pop(context, ProfileUpdateResult(name: updatedName, email: updatedEmail));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF1ECB9B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1ECB9B),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileUpdateResult {
  final String name;
  final String email;

  ProfileUpdateResult({required this.name, required this.email});
}
