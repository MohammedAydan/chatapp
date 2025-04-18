// features/home/presentation/widgets/update_display_name_chat_bottom_sheet.dart
import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/core/params/update_display_name_params.dart';
import 'package:chatapp/core/utils/validation_utils.dart';
import 'package:chatapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/features/home/presentation/blocs/chats_actions/chats_actions_bloc.dart';
import 'package:chatapp/global/widgets/custom_button.dart';
import 'package:chatapp/global/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showUpdateDisplayNameBottomSheet({
  required BuildContext contextWrap,
  required ChatEntity chat,
  required String displayName,
}) {
  showModalBottomSheet(
    context: contextWrap,
    backgroundColor: Theme.of(contextWrap).scaffoldBackgroundColor,
    barrierColor: Colors.grey.withAlpha((0.1 * 255).toInt()),
    showDragHandle: true,
    isScrollControlled: true,
    builder:
        (bottomSheetContext) => SafeArea(
          child: _UpdateDisplayNameContent(
            contextWrap: contextWrap,
            chat: chat,
            initialDisplayName: displayName,
          ),
        ),
  );
}

class _UpdateDisplayNameContent extends StatefulWidget {
  final BuildContext contextWrap;
  final ChatEntity chat;
  final String initialDisplayName;

  const _UpdateDisplayNameContent({
    required this.contextWrap,
    required this.chat,
    required this.initialDisplayName,
  });

  @override
  State<_UpdateDisplayNameContent> createState() =>
      _UpdateDisplayNameContentState();
}

class _UpdateDisplayNameContentState extends State<_UpdateDisplayNameContent> {
  late final TextEditingController _displayNameController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  ChatsActionsBloc? _chatsBloc;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.initialDisplayName,
    );
    _chatsBloc = widget.contextWrap.read<ChatsActionsBloc>();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authState = widget.contextWrap.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      _showError('Authentication failed');
      return;
    }

    final newDisplayName = _displayNameController.text.trim();
    if (newDisplayName == widget.initialDisplayName) {
      Navigator.of(context).maybePop();
      return;
    }
    _chatsBloc?.add(
      UpdateDisplayNameEvent(
        params: UpdateDisplayNameParams(
          chatId: widget.chat.id,
          userId: authState.user.email,
          newDisplayName: newDisplayName,
          participant: widget.chat.participant,
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatsActionsBloc, ChatsActionsState>(
      bloc: _chatsBloc,
      listener: (context, state) {
        if (state is ChatsActionsError) {
          _showError(state.message);
        } else if (state is ChatsActionsLoading) {
          Navigator.of(context).maybePop();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr.editDisplayName,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                labelText: context.tr.displayName,
                controller: _displayNameController,
                keyboardType: TextInputType.name,
                validator:
                    (value) => ValidationUtils.validateRequired(
                      value,
                      'Display name is required',
                    ),
                prefixIcon: const Icon(Icons.person_rounded),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      textButton: true,
                      child: Text(context.tr.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(context.tr.update),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
