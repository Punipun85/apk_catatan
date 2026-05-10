import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  final bool isDarkMode;
  final Future<void> Function(bool value) onThemeChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  Future<void> _toggleDarkMode(bool value) async {
    await widget.onThemeChanged(value);
    if (!mounted) {
      return;
    }

    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Card(
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              title: const Text(
                'Mode Gelap',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('Ubah tampilan aplikasi ke tema gelap'),
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
            ),
          ),
        ],
      ),
    );
  }
}
