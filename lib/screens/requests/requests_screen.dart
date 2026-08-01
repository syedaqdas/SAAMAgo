import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/app_state.dart';
import '../../models/rental_request.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  RequestStatus? _status;

  final _tabs = const <({String label, RequestStatus? status})>[
    (label: 'All', status: null),
    (label: 'Pending', status: RequestStatus.pending),
    (label: 'Accepted', status: RequestStatus.accepted),
    (label: 'Completed', status: RequestStatus.completed),
    (label: 'Cancelled', status: RequestStatus.cancelled),
  ];

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    final requests = store.requestsByStatus(_status);
    final body = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.showAppBar)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Text(
                'My Requests',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
            ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final selected = tab.status == _status;
                return ChoiceChip(
                  label: Text(tab.label),
                  selected: selected,
                  selectedColor: AppColors.primaryPurple,
                  backgroundColor: AppColors.chip,
                  side: const BorderSide(color: AppColors.border),
                  labelStyle: TextStyle(
                    color: selected
                        ? AppColors.primaryText
                        : AppColors.secondaryText,
                    fontWeight: FontWeight.w800,
                  ),
                  onSelected: (_) => setState(() => _status = tab.status),
                );
              },
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: requests.isEmpty
                  ? EmptyState(
                      key: ValueKey(_status?.name ?? 'all-empty'),
                      icon: Icons.receipt_long_rounded,
                      title: 'No requests',
                      message: 'Requests with this status will appear here.',
                      actionLabel: 'Explore Items',
                      onAction: () => Navigator.pushNamed(
                        context,
                        AppRoutes.shell,
                        arguments: 1,
                      ),
                    )
                  : ListView.separated(
                      key: ValueKey(_status?.name ?? 'all-list'),
                      padding: EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        widget.showAppBar ? 24 : 112,
                      ),
                      itemCount: requests.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _RequestCard(request: requests[index]),
                    ),
            ),
          ),
        ],
      ),
    );

    if (!widget.showAppBar) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      body: body,
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final RentalRequest request;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.itemDetails,
        arguments: request.item,
      ),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 84,
              height: 84,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ItemThumbnail(item: request.item, height: 84),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          request.item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip.forRequest(request.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${request.durationDays} days · ${request.dateLabel}',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'With ${request.personName}',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        AppFormatters.rupees(request.amount),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _handleAction(context),
                        child: Text(_actionLabel(request.status)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _actionLabel(RequestStatus status) {
    return switch (status) {
      RequestStatus.pending => 'Cancel',
      RequestStatus.accepted => 'Chat',
      RequestStatus.completed => 'Review',
      RequestStatus.cancelled => 'Rebook',
    };
  }

  void _handleAction(BuildContext context) {
    switch (request.status) {
      case RequestStatus.accepted:
        Navigator.pushNamed(context, AppRoutes.chat, arguments: request.item);
        return;
      case RequestStatus.completed:
        Navigator.pushNamed(context, AppRoutes.reviews);
        return;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_actionLabel(request.status)} action is mocked.'),
          ),
        );
    }
  }
}
