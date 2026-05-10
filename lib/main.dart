import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/splash_screen.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  final bool isDarkMode = await ThemeService.instance.getDarkMode();
  runApp(CatatanHarianApp(initialDarkMode: isDarkMode));
}

class CatatanHarianApp extends StatefulWidget {
  const CatatanHarianApp({super.key, required this.initialDarkMode});

  final bool initialDarkMode;

  @override
  State<CatatanHarianApp> createState() => _CatatanHarianAppState();
}

class _CatatanHarianAppState extends State<CatatanHarianApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  Future<void> _updateTheme(bool value) async {
    await ThemeService.instance.setDarkMode(value);
    if (!mounted) {
      return;
    }

    setState(() {
      _isDarkMode = value;
    });
  }

  ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    const Color primaryColor = Color(0xFF2196F3);

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF101418) : const Color(0xFFF5F8FE),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF17212B),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 2,
        color: isDark ? const Color(0xFF1A2129) : Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: primaryColor.withValues(alpha: 0.10),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1A2129) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2B3642) : const Color(0xFFD6E4F4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide.none,
        selectedColor: primaryColor,
        secondarySelectedColor: primaryColor,
        labelStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF243443),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Harian',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _updateTheme,
      ),
    );
  }
}
