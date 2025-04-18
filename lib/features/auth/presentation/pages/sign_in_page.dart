import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatapp/global/widgets/custom_button.dart';
import 'package:chatapp/routes/routes_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInPage extends StatelessWidget {
  final bool googleSignInOnly;

  const SignInPage({super.key, this.googleSignInOnly = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, RoutesPaths.settings);
            },
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, RoutesPaths.home);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Spacer(flex: 2),
                // Image.asset("assets/icons/google-icon.png", height: 100),
                Text(
                      "C",
                      style: TextStyle(
                        fontSize: 200,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                        shadows: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: const Duration(milliseconds: 1200)),
                Spacer(),
                Text(
                  context.tr.signIn,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(height: 5),
                Text(
                  context.tr.welcomeMessage,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                Spacer(flex: 2),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed:
                        isLoading
                            ? null
                            : () => context.read<AuthBloc>().add(
                              SignInWithGoogleEvent(),
                            ),

                    child:
                        isLoading
                            ? SizedBox(
                              width: 25,
                              height: 25,
                              child: const CircularProgressIndicator(),
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/google-icon.png',
                                  height: 24,
                                ),
                                SizedBox(width: 10),
                                Text(context.tr.signInWithGoogle),
                              ],
                            ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
