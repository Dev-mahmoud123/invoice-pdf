import 'package:features/model/customers.dart';
import 'package:features/model/suppliers.dart';

class Invoices {
  final InvoicesInfo info;
  final Suppliers supplier;
  final Customers customers;
  final List<InvoiceItems> items;

  Invoices({
    required this.info,
    required this.supplier,
    required this.customers,
    required this.items,
  });
}

class InvoiceItems {
  final String description;

  final DateTime date;
  final int quantity;
  final double vat;
  final double unitPrice;

  InvoiceItems({
    required this.description,
    required this.date,
    required this.quantity,
    required this.vat,
    required this.unitPrice,
  });
}

class InvoicesInfo {
  final String description;
  final String number;
  final DateTime date;
  final DateTime dueDate;

  InvoicesInfo({
    required this.description,
    required this.number,
    required this.date,
    required this.dueDate,
  });
}
