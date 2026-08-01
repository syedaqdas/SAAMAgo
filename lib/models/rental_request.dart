import 'rental_item.dart';

enum RequestStatus { pending, accepted, completed, cancelled }

class RentalRequest {
  const RentalRequest({
    required this.id,
    required this.item,
    required this.durationDays,
    required this.amount,
    required this.personName,
    required this.status,
    required this.dateLabel,
  });

  final String id;
  final RentalItem item;
  final int durationDays;
  final int amount;
  final String personName;
  final RequestStatus status;
  final String dateLabel;

  RentalRequest copyWith({RequestStatus? status}) {
    return RentalRequest(
      id: id,
      item: item,
      durationDays: durationDays,
      amount: amount,
      personName: personName,
      status: status ?? this.status,
      dateLabel: dateLabel,
    );
  }
}
