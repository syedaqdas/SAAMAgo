import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_panel.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/app_state.dart';
import '../../models/rental_item.dart';

class BorrowConfirmationScreen extends StatefulWidget {
  const BorrowConfirmationScreen({required this.item, super.key});

  final RentalItem item;

  @override
  State<BorrowConfirmationScreen> createState() =>
      _BorrowConfirmationScreenState();
}

class _BorrowConfirmationScreenState extends State<BorrowConfirmationScreen> {
  int _durationDays = 3;
  String _pickupOption = 'Self Pickup';
  String _paymentMethod = 'UPI';
  bool _isLoading = false;

  int get _rent => widget.item.pricePerDay * _durationDays;
  int get _platformFee => 49;
  int get _total => _rent + widget.item.deposit + _platformFee;

  Future<void> _confirm() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) {
      return;
    }
    try {
      await AppStateScope.of(
        context,
      ).addBorrowRequest(widget.item, _durationDays, _total);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Borrow request created as Pending.')),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.shell,
        (route) => false,
        arguments: 3,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borrow Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppPanel(
              child: Row(
                children: [
                  SizedBox(
                    width: 76,
                    height: 68,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ItemThumbnail(item: widget.item, height: 68),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppFormatters.rupees(widget.item.pricePerDay)} / day',
                          style: const TextStyle(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _DatePanel(durationDays: _durationDays),
            const SizedBox(height: 18),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rental Duration',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '$_durationDays Days',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      IconButton.filled(
                        tooltip: 'Reduce duration',
                        onPressed: _durationDays > 1
                            ? () => setState(() => _durationDays--)
                            : null,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.elevatedCard,
                        ),
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        tooltip: 'Increase duration',
                        onPressed: () => setState(() => _durationDays++),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.elevatedCard,
                        ),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _pickupOption,
              decoration: const InputDecoration(labelText: 'Pickup Option'),
              items: const [
                DropdownMenuItem(
                  value: 'Self Pickup',
                  child: Text('Self Pickup'),
                ),
                DropdownMenuItem(value: 'Delivery', child: Text('Delivery')),
              ],
              onChanged: (value) =>
                  setState(() => _pickupOption = value ?? _pickupOption),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Payment Method'),
              items: const [
                DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                DropdownMenuItem(
                  value: 'Wallet',
                  child: Text('SAAMAgo Wallet'),
                ),
                DropdownMenuItem(value: 'Card', child: Text('Card')),
              ],
              onChanged: (value) =>
                  setState(() => _paymentMethod = value ?? _paymentMethod),
            ),
            const SizedBox(height: 18),
            AppPanel(
              child: Column(
                children: [
                  _AmountRow(
                    label:
                        'Rent (${widget.item.pricePerDay} x $_durationDays days)',
                    amount: _rent,
                  ),
                  _AmountRow(
                    label: 'Security deposit',
                    amount: widget.item.deposit,
                  ),
                  _AmountRow(label: 'Platform fee', amount: _platformFee),
                  const Divider(height: 26),
                  _AmountRow(
                    label: 'Total Amount',
                    amount: _total,
                    strong: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Confirm and Pay ${AppFormatters.rupees(_total)}',
              icon: Icons.lock_rounded,
              isLoading: _isLoading,
              onPressed: _confirm,
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePanel extends StatelessWidget {
  const _DatePanel({required this.durationDays});

  final int durationDays;

  @override
  Widget build(BuildContext context) {
    final start = DateTime.now();
    final end = start.add(Duration(days: durationDays));
    return Row(
      children: [
        Expanded(
          child: _DateBox(label: 'Start Date', value: _formatDate(start)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DateBox(label: 'End Date', value: _formatDate(end)),
        ),
      ],
    );
  }

  String _formatDate(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${value.day} ${months[value.month - 1]}';
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.strong = false,
  });

  final String label;
  final int amount;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: strong ? AppColors.primaryText : AppColors.secondaryText,
                fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            AppFormatters.rupees(amount),
            style: TextStyle(
              fontSize: strong ? 18 : 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
