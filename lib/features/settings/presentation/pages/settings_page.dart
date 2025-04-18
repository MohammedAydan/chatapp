import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatapp/features/settings/presentation/widgets/list_locale_items.dart';
import 'package:chatapp/features/settings/presentation/widgets/list_theme_mode_items.dart';
import 'package:chatapp/global/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.settings.toUpperCase()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListThemeModeItems(),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "${context.tr.language}:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Divider(color: Colors.grey.withAlpha((0.3 * 255).toInt())),
                ListLocaleItems(),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        child: CustomButton(
          backgroundColor: Colors.red.shade700,
          child: Text(context.tr.signOut),
          onPressed: () {
            context.read<AuthBloc>().add(SignOutEvent());
          },
        ),
      ),
    );
  }
}
