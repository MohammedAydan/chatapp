import 'package:chatapp/core/params/get_chats_params.dart';
import 'package:chatapp/di/injection_container.dart';
import 'package:chatapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatapp/features/home/presentation/blocs/chats/chats_bloc.dart';
import 'package:chatapp/features/home/presentation/blocs/chats_actions/chats_actions_bloc.dart';
import 'package:chatapp/features/home/presentation/widgets/home_app_bar.dart';
import 'package:chatapp/routes/routes_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/chat_list.dart';
import '../widgets/home_bottom_nav.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthUnauthenticated || authState is SignOut) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(RoutesPaths.signIn);
      });
      return const SizedBox();
    }

    if (authState is! AuthAuthenticated) {
      return const Center(child: CircularProgressIndicator());
    }

    final userId = authState.user.email;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ChatsBloc>()),
        BlocProvider(create: (context) => sl<ChatsActionsBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated || state is SignOut) {
            Navigator.of(context).pushReplacementNamed(RoutesPaths.signIn);
          }
        },
        child: BlocBuilder<ChatsBloc, ChatsState>(
          buildWhen: (previous, current) => current is! ChatsInitial,
          builder: (context, state) {
            if (state is ChatsInitial) {
              context.read<ChatsBloc>().add(
                LoadChatsEvent(params: GetChatsParams(userId: userId)),
              );
            }

            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  const HomeAppBar(),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ChatList(state: state),

                  // SliverToBoxAdapter(
                  //   child: Text(EncryptionHelper.encrypt(
                  //     "Welcome to the chat app",
                  //     'dotenv.get("ENCRYPTION_KEY")',
                  //   )),
                  // ),
                  // SliverToBoxAdapter(
                  //   child: Text(EncryptionHelper.decrypt(
                  //     EncryptionHelper.encrypt(
                  //     "Welcome to the chat app",
                  //     'dotenv.get("ENCRYPTION_KEY")',
                  //   ),
                  //     'dotenv.get("ENCRYPTION_KEY")',
                  //   )),
                  // ),
                ],
              ),
              bottomNavigationBar: const HomeBottomNavBar(),
            );
          },
        ),
      ),
    );
  }
}