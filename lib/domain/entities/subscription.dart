import 'package:equatable/equatable.dart';

class Subscription extends Equatable {
  final int id;
  final String name;
  final double price;
  final String category;
  final DateTime nextBillingDate;

  const Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.nextBillingDate,
  });

  @override
  List<Object?> get props => [id, name, price, category, nextBillingDate];
}
