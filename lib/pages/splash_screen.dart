import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/authentication_bloc.dart';
import 'login_page.dart';
import 'main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool _animationFinished = false;
  AuthenticationState? _authState;

  @override
  void initState() {
    super.initState();

    context.read<AuthenticationBloc>().add(AppStarted());

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward().whenComplete(() {
      _animationFinished = true;
      _tryNavigate();
    });
  }

  void _tryNavigate() {
    if (!mounted) return;

    if (_animationFinished && _authState != null) {
      if (_authState is AuthenticationAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      } else if (_authState is AuthenticationUnauthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        _authState = state;
        _tryNavigate();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              "assets/logo/astronacci_logo.png",
              width: 150,
              height: 150
            ),
          ),
        ),
      ),
    );
  }
}
