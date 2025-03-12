import 'package:flutter/material.dart';
import 'profile_page.dart';
class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PreferenceScreenState createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  bool notificationsEnabled = true;
  bool darkMode = false;
  String selectedLanguage = 'English';
  List<String> languages = ['English', 'Spanish', 'French', 'German', 'Japanese'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
     
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Notifications Toggle
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          const Divider(),

          ListTile(
            title: const Text('Language'),
            subtitle: Text(selectedLanguage),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              items: languages.map((String lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedLanguage = newValue;
                  });
                }
              },
            ),
          ),
          const Divider(),

          // Account Settings
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Manage Account'),
            subtitle: const Text('Update account details'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
            },
          ),
          const Divider(),

         

          // Logout Button
          ListTile(
            title: Center(
              child: TextButton(
                onPressed: () {
                  // Handle logout
                },
                child: const Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
