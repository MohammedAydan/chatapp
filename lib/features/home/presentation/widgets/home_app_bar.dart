import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/features/home/presentation/blocs/chats/chats_bloc.dart';
import 'package:chatapp/global/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_chat_bottom_sheet.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        "CHATS",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
      ),
      actions: [
        IconButton.filled(
          onPressed:
              () => showModalBottomSheet(
                context: context,
                showDragHandle: true,
                isScrollControlled: true,
                // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                builder:
                    (_) => BlocProvider.value(
                      value: BlocProvider.of<ChatsBloc>(context),
                      child: AddChatBottomSheet(contextWrap: context),
                    ),
              ),
          icon: const Icon(Icons.add_rounded),
          color: Theme.of(context).colorScheme.surface,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        // DropdownMenu(
        //   textStyle: TextStyle(
        //     color: Theme.of(context).colorScheme.surface,
        //   ),
        //   inputDecorationTheme: InputDecorationTheme(
        //     fillColor: Theme.of(context).colorScheme.primary,
        //     filled: true,
        //     border: OutlineInputBorder(
        //       borderSide: BorderSide.none,
        //       borderRadius: BorderRadius.circular(15),
        //     ),
        //   ),
        //   dropdownMenuEntries: [
        //     DropdownMenuEntry(value: ThemeMode.light, label: "Light"),
        //     DropdownMenuEntry(value: ThemeMode.dark, label: "Dark"),
        //     DropdownMenuEntry(value: ThemeMode.system, label: "System"),
        //   ],
        //   onSelected: (themeMode) {
        //     if (themeMode != null) {
        //       context.read<ThemeBloc>().add(
        //         SetThemeModeEvent(themeMode: themeMode),
        //       );
        //     }
        //   },
        // ),
      ],
      centerTitle: true,
      floating: true,
      pinned: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            height: 50,
            child: CustomTextFormField(labelText: context.tr.search),
          ),
        ),
      ),
    );
  }
}
