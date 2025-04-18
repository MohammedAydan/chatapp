import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/features/settings/presentation/widgets/card_setting_item.dart';
import 'package:chatapp/global/blocs/theme/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListThemeModeItems extends StatelessWidget {
  const ListThemeModeItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "${context.tr.themeMode}:",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Divider(color: Colors.grey.withAlpha((0.3 * 255).toInt())),
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            if (state is LoadedThemeModeState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CardSettingItem(
                    selected: state.themeMode == ThemeMode.light,
                    child: const Icon(Icons.light_mode_rounded),
                    onTap: () {
                      context.read<ThemeBloc>().add(
                        SetThemeModeEvent(themeMode: ThemeMode.light),
                      );
                    },
                  ),
                  CardSettingItem(
                    selected: state.themeMode == ThemeMode.dark,
                    child: const Icon(Icons.dark_mode_rounded),
                    onTap: () {
                      context.read<ThemeBloc>().add(
                        SetThemeModeEvent(themeMode: ThemeMode.dark),
                      );
                    },
                  ),
                  CardSettingItem(
                    selected: state.themeMode == ThemeMode.system,
                    child: const Icon(Icons.auto_mode_rounded),
                    onTap: () {
                      context.read<ThemeBloc>().add(
                        SetThemeModeEvent(themeMode: ThemeMode.system),
                      );
                    },
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ],
    );
  }
}
