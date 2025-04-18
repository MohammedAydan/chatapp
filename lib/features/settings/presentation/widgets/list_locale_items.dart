import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/features/settings/presentation/widgets/card_setting_item.dart';
import 'package:chatapp/global/blocs/locale/locale_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListLocaleItems extends StatelessWidget {
  const ListLocaleItems({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        if (state is LocaleLoadedState) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardSettingItem(
                selected: state.locale.languageCode == 'en',
                child: Row(
                  children: [
                    Icon(Icons.language_rounded),
                    SizedBox(width: 10),
                    Text(context.tr.english),
                  ],
                ),
                onTap: () {
                  context.read<LocaleBloc>().add(
                    ChangeLocaleEvent(locale: Locale('en')),
                  );
                },
              ),
              CardSettingItem(
                selected: state.locale.languageCode == 'ar',
                child: Row(
                  children: [
                    Icon(Icons.language_rounded),
                    SizedBox(width: 10),
                    Text(context.tr.arabic),
                  ],
                ),
                onTap: () {
                  context.read<LocaleBloc>().add(
                    ChangeLocaleEvent(locale: Locale('ar')),
                  );
                },
              ),
            ],
          );
        }
        return SizedBox();
      },
    );
  }
}
