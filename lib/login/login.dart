import 'dart:ui';
import 'package:app/login/animation.dart';
import 'package:app/login/input_custom.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animacaoBlur;
  Animation<double>? _animacaoFade;
  Animation<double>? _animacaoSize;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animacaoBlur = _getAnimation(begin: 50, end: 0, curve: Curves.ease);
    _animacaoFade =
        _getAnimation(begin: 0, end: 1, curve: Curves.easeInOutQuint);
    _animacaoSize = _getAnimation(begin: 0, end: 500, curve: Curves.decelerate);

    _controller?.forward();
  }

  Animation<double> _getAnimation(
      {required double begin, required double end, required Curve curve}) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: curve,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildForm(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
      child: Column(
        children: [
          _buildAnimatedContainer(),
          const SizedBox(height: 20),
          BotaoAnimado(controller: _controller!),
          const SizedBox(height: 10),
          _buildForgotPasswordText(),
        ],
      ),
    );
  }

  Widget _buildAnimatedContainer() {
    return AnimatedBuilder(
      animation: _animacaoSize!,
      builder: (context, widget) {
        return Container(
          width: _animacaoSize?.value,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 80,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              const InputCustomizado(
                hint: 'e-mail',
                obscure: false,
                icon: Icon(Icons.person),
              ),
              Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 0.5,
                      blurRadius: 0.5,
                    ),
                  ],
                ),
              ),
              const InputCustomizado(
                hint: 'password',
                obscure: true,
                icon: Icon(Icons.lock),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForgotPasswordText() {
    return FadeTransition(
      opacity: _animacaoFade!,
      child: const Text(
        "Mot de passe oublié",
        style: TextStyle(
          color: Color.fromARGB(255, 69, 76, 177),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
