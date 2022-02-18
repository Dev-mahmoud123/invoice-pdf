import 'package:flutter/material.dart';

import '../api/pdf_api.dart';
import '../api/pdf_invoice_api.dart';
import '../model/customers.dart';
import '../model/invoices.dart';
import '../model/suppliers.dart';

class PdfScreen extends StatefulWidget {
  const PdfScreen({Key? key}) : super(key: key);

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Invoice generate',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
                onPressed: () async {
                  final date = DateTime.now();
                  final dueDate = date.add(const Duration(days: 7));

                  final invoice = Invoices(
                    supplier: Suppliers(
                      name: 'Sarah Field',
                      address: 'Sarah Street 9, Beijing, China',
                      paymentInfo: 'https://paypal.me/sarahfieldzz',
                    ),
                    customers: const Customers(
                      name: 'Apple Inc.',
                      address: 'Apple Street, Cupertino, CA 95014',
                    ),
                    info: InvoicesInfo(
                      date: date,
                      dueDate: dueDate,
                      description: 'My description...',
                      number: '${DateTime.now().year}-9999',
                    ),
                    items: [
                      InvoiceItems(
                        description: 'Coffee',
                        date: DateTime.now(),
                        quantity: 3,
                        vat: 0.19,
                        unitPrice: 5.99,
                      ),
                      InvoiceItems(
                        description: 'Water',
                        date: DateTime.now(),
                        quantity: 8,
                        vat: 0.19,
                        unitPrice: 0.99,
                      ),
                      InvoiceItems(
                        description: 'Orange',
                        date: DateTime.now(),
                        quantity: 3,
                        vat: 0.19,
                        unitPrice: 2.99,
                      ),
                      InvoiceItems(
                        description: 'Apple',
                        date: DateTime.now(),
                        quantity: 8,
                        vat: 0.19,
                        unitPrice: 3.99,
                      ),
                      InvoiceItems(
                        description: 'Mango',
                        date: DateTime.now(),
                        quantity: 1,
                        vat: 0.19,
                        unitPrice: 1.59,
                      ),
                      InvoiceItems(
                        description: 'Blue Berries',
                        date: DateTime.now(),
                        quantity: 5,
                        vat: 0.19,
                        unitPrice: 0.99,
                      ),
                      InvoiceItems(
                        description: 'Lemon',
                        date: DateTime.now(),
                        quantity: 4,
                        vat: 0.19,
                        unitPrice: 1.29,
                      ),
                    ],
                  );
                  final pdfFile = await PdfInvoiceApi.generate(invoice);
                  PdfApi.openFile(pdfFile);
                },
                child: const Text('Invoice Pdf'))
          ],
        ),
      ),
    );
  }
}
