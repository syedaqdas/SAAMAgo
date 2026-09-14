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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item.toJson(),
      'durationDays': durationDays,
      'amount': amount,
      'personName': personName,
      'status': status.name,
      'dateLabel': dateLabel,
    };
  }

  factory RentalRequest.fromJson(Map<String, dynamic> json) {
    return RentalRequest(
      id: json['id'] as String,
      item: RentalItem.fromJson(json['item'] as Map<String, dynamic>),
      durationDays: json['durationDays'] as int,
      amount: json['amount'] as int,
      personName: json['personName'] as String,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      dateLabel: json['dateLabel'] as String,
    );
  }
}
