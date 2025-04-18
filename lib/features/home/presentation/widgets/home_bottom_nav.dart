// features/home/presentation/widgets/home_bottom_nav.dart
import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatapp/routes/routes_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: context.tr.chats,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: context.tr.settings,
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.logout_rounded),
        //   label: 'Sign Out',
        // ),
      ],
      onTap: (index) {
        if (index == 0) {
          //
        } else if (index == 1) {
          Navigator.pushNamed(context, RoutesPaths.settings);
        } else if (index == 2) {
          context.read<AuthBloc>().add(SignOutEvent());
        }
      },
    );
  }
}
