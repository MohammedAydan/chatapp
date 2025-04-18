// features/home/presentation/widgets/add_chat_bottom_sheet.dart
import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/core/params/create_chat_params.dart';
import 'package:chatapp/core/utils/validation_utils.dart';
import 'package:chatapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatapp/features/home/data/models/chat_message_model.dart';
import 'package:chatapp/features/home/data/models/participant_model.dart';
import 'package:chatapp/features/home/presentation/blocs/chats/chats_bloc.dart';
import 'package:chatapp/features/home/presentation/blocs/chats_actions/chats_actions_bloc.dart';
import 'package:chatapp/global/widgets/custom_button.dart';
import 'package:chatapp/global/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddChatBottomSheet extends StatefulWidget {
  final BuildContext contextWrap;
  const AddChatBottomSheet({super.key, required this.contextWrap});

  @override
  State<AddChatBottomSheet> createState() => _AddChatBottomSheetState();
}

class _AddChatBottomSheetState extends State<AddChatBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _textMessageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _textMessageController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      _showError('Authentication failed.');
      return;
    }

    final user = authState.user;
    final email = _emailController.text.trim();
    final message = _textMessageController.text.trim();

    final participants = [
      ParticipantModel(
        id: user.email,
        displayName: user.email,
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoUrl,
        createdAt: DateTime.now().toIso8601String(),
        fcmToken: user.fcmToken,
      ),
      ParticipantModel(
        id: email,
        displayName: email,
        photoUrl: '',
        createdAt: DateTime.now().toIso8601String(),
      ),
    ];

    final chatParams = CreateChatParams(
      senderId: user.email,
      lastMessage: ChatMessageModel(
        senderId: user.email,
        message: message,
        createdAt: DateTime.now().toIso8601String(),
        isRead: false,
      ),
      participantIds: [user.email, email],
      participant: participants,
      createdAt: DateTime.now().toIso8601String(),
      chatType: 'one-to-one',
    );

    widget.contextWrap.read<ChatsActionsBloc>().add(CreateChatEvent(chatParams));
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatsBloc, ChatsState>(
      listener: (context, state) {
        if (state is ChatsError) _showError(state.message);
        if (state is ChatsLoaded) Navigator.pop(context);
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
                context.tr.startNewChat,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                labelText: context.tr.emailAddress,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: ValidationUtils.validateEmail,
                prefixIcon: const Icon(Icons.email_rounded),
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                labelText: context.tr.initialMessage,
                controller: _textMessageController,
                keyboardType: TextInputType.text,
                validator: ValidationUtils.validateMessage,
                maxLines: 3,
                prefixIcon: const Icon(Icons.message_rounded),
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: _isLoading ? null : _onSubmit,
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
                        : Text(context.tr.createChat),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
