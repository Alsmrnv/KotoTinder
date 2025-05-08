import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'Data/services/cat_api.dart';
import 'Data/repositories/cat_repository_impl.dart';
import 'Domain/repositories/cat_repository.dart';

import 'Presentation/screens/home_screen.dart';

Future<void> main() async {
  try {
    await dotenv.load();
    debugPrint('main: .env file loaded successfully');
  } catch (e) {
    debugPrint('main: Error loading .env: $e');
  }
  setupDependencies();
  runApp(const MyApp());
}

void setupDependencies() {
  final getIt = GetIt.instance;

  getIt.registerLazySingleton<CatApiService>(() => CatApiService());
  getIt.registerLazySingleton<CatRepository>(
    () => CatRepositoryImpl(getIt<CatApiService>()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Кототиндер',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blueGrey.shade100,
      ),
      home: const HomeScreen(),
    );
  }
}
