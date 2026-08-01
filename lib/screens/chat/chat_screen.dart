import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/app_state.dart';
import '../../models/rental_item.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.item});

  final RentalItem? item;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    final item = widget.item ?? store.firstItem;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.elevatedCard,
              child: Text(
                'AI',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.ownerName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Call',
            onPressed: _mockAction,
            icon: const Icon(Icons.call_rounded),
          ),
          IconButton(
            tooltip: 'Location',
            onPressed: _mockAction,
            icon: const Icon(Icons.location_on_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: store.messages.isEmpty
                  ? const EmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'No chat messages',
                      message:
                          'Messages about your borrow request will appear here.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      itemCount: store.messages.length,
                      itemBuilder: (context, index) {
                        final message = store.messages[index];
                        return Align(
                          alignment: message.isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.74,
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: message.isMine
                                  ? AppColors.purpleGradient
                                  : null,
                              color: message.isMine
                                  ? null
                                  : AppColors.cardSurface,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: Radius.circular(
                                  message.isMine ? 18 : 4,
                                ),
                                bottomRight: Radius.circular(
                                  message.isMine ? 4 : 18,
                                ),
                              ),
                              border: message.isMine
                                  ? null
                                  : Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  message.text,
                                  style: const TextStyle(height: 1.35),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  message.time,
                                  style: TextStyle(
                                    color: AppColors.primaryText.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Row(
                children: [
                  IconButton.filled(
                    tooltip: 'Attach',
                    onPressed: _mockAction,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.elevatedCard,
                    ),
                    icon: const Icon(Icons.add_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send',
                    onPressed: () {
                      store.sendMessage(_controller.text);
                      _controller.clear();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                    ),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mockAction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This action is mocked in the frontend demo.'),
      ),
    );
  }
}
