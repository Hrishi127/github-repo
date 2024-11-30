import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_repo/core/colors.dart';
import 'package:github_repo/core/navigator_key.dart';
import 'package:github_repo/features/repo/bloc/repo_bloc.dart';
import 'package:github_repo/features/repo/screens/repo_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/github_token/bloc/github_token_bloc.dart';
import 'features/github_token/screens/github_token_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if a token exists in SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final savedToken = prefs.getString('github_token');
  runApp(MyApp(initialScreen: savedToken != null ? const RepoScreen() : const GithubTokenScreen()));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'GitHub Token Checker',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: appbarColor,
          elevation: 0,
          scrolledUnderElevation: 0
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor
          )
        )
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => GitHubTokenBloc()),
          BlocProvider(create: (context) => RepoBloc()),
        ],
        child: initialScreen
      ),
    );
  }
}