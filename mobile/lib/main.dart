import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/config.dart';
import 'app/design_tokens.dart';
import 'app/shell.dart';
import 'app/theme.dart';
import 'core/navigation_state.dart';
import 'core/settings.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final settings = AppSettings();
  await settings.restore();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => NavigationState()),
      ],
      child: const CzyPrzejadeApp(),
    ),
  );
}

class CzyPrzejadeApp extends StatefulWidget {
  const CzyPrzejadeApp({super.key});

  @override
  State<CzyPrzejadeApp> createState() => _CzyPrzejadeAppState();
}

class _CzyPrzejadeAppState extends State<CzyPrzejadeApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return MaterialApp(
      title: AppConfig.title,
      debugShowCheckedModeBanner: false,
      theme: AppThemeFactory.build(settings.theme, highContrast: settings.highContrast),
      // Globalna skala tekstu z ustawień dostępności.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(settings.textSize.scale)),
        child: child!,
      ),
      home: Stack(
        children: [
          const AppShell(),
          // Splash nakłada się na aplikację i znika płynnie po zakończeniu.
          IgnorePointer(
            ignoring: !_showSplash,
            child: AnimatedSwitcher(
              duration: AppDurations.fade,
              child: _showSplash
                  ? SplashScreen(
                      key: const ValueKey('splash'),
                      onFinish: () => setState(() => _showSplash = false),
                    )
                  : const SizedBox.shrink(key: ValueKey('none')),
            ),
          ),
        ],
      ),
    );
  }
}
