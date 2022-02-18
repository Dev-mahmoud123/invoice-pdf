import 'dart:io';

import 'package:features/api/pdf_api.dart';
import 'package:features/model/invoices.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

import '../model/customers.dart';
import '../model/suppliers.dart';
import '../utils.dart';

class PdfInvoiceApi {
  static Future<File> generate (Invoices invoices)async {
     final pdf = pw.Document(
       theme: pw.ThemeData.withFont(
         base: Font.ttf(await rootBundle.load("assets/OpenSans-Regular.ttf")),
         bold: Font.ttf(await rootBundle.load("assets/OpenSans-Bold.ttf")),
       )
     );
     pdf.addPage(
         pw.MultiPage(
           build: (context) => [
             buildHeader(invoices),
             SizedBox(height: 2 * PdfPageFormat.cm),
             buildTitle(invoices),
             buildInvoice(invoices),
             Divider(),
             buildTotal(invoices),
           ],
           footer: (context) => buildFooter(invoices),
         )
     );
     return PdfApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }


  static Widget buildHeader(Invoices invoice) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 1 * PdfPageFormat.cm),
      pw.Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildSupplierAddress(invoice.supplier),
          pw.Container(
            height: 50,
            width: 50,
            child: pw.BarcodeWidget(
              barcode: Barcode.qrCode(),
              data: invoice.info.number,
            ),
          ),
        ],
      ),
      SizedBox(height: 1 * PdfPageFormat.cm),
      pw.Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildCustomerAddress(invoice.customers),
          buildInvoiceInfo(invoice.info),
        ],
      ),
    ],
  );

  static Widget buildCustomerAddress(Customers customer) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pw.Text(customer.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, )),
      pw.Text(customer.address),
    ],
  );

  static Widget buildInvoiceInfo(InvoicesInfo info) {
    final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titles = <String>[
      'Invoice Number:',
      'Invoice Date:',
      'Payment Terms:',
      'Due Date:'
    ];
    final data = <String>[
      info.number,
      Utils.formatDate(info.date),
      paymentTerms,
      Utils.formatDate(info.dueDate),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static Widget buildSupplierAddress(Suppliers supplier) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pw.Text(supplier.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      SizedBox(height: 1 * PdfPageFormat.mm),
      pw.Text(supplier.address),
    ],
  );

  static Widget buildTitle(Invoices invoice) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pw.Text(
        'INVOICE',
        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
      ),
      SizedBox(height: 0.8 * PdfPageFormat.cm),
      pw.Text(invoice.info.description),
      SizedBox(height: 0.8 * PdfPageFormat.cm),
    ],
  );

  static Widget buildInvoice(Invoices invoice) {
    final headers = [
      'Description',
      'Date',
      'Quantity',
      'Unit Price',
      'VAT',
      'Total'
    ];
    final data = invoice.items.map((item) {
      final total = item.unitPrice * item.quantity * (1 + item.vat);

      return [
        item.description,
        Utils.formatDate(item.date),
        '${item.quantity}',
        '\$ ${item.unitPrice}',
        '${item.vat} %',
        '\$ ${total.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
        5: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Invoices invoice) {
    final netTotal = invoice.items
        .map((item) => item.unitPrice * item.quantity)
        .reduce((item1, item2) => item1 + item2);
    final vatPercent = invoice.items.first.vat;
    final vat = netTotal * vatPercent;
    final total = netTotal + vat;

    return pw.Container(
      alignment: Alignment.centerRight,
      child: pw.Row(
        children: [
          Spacer(flex: 6),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Net total',
                  value: Utils.formatPrice(netTotal),
                  unite: true,
                ),
                buildText(
                  title: 'Vat ${vatPercent * 100} %',
                  value: Utils.formatPrice(vat),
                  unite: true,
                ),
                Divider(),
                buildText(
                  title: 'Total amount due',
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  value: Utils.formatPrice(total),
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                pw.Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                pw.Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFooter(Invoices invoice) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Divider(),
      SizedBox(height: 2 * PdfPageFormat.mm),
      buildSimpleText(title: 'Address', value: invoice.supplier.address),
      SizedBox(height: 1 * PdfPageFormat.mm),
      buildSimpleText(title: 'Paypal', value: invoice.supplier.paymentInfo),
    ],
  );

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return pw.Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        pw.Text(value),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? pw.TextStyle(fontWeight: pw.FontWeight.bold);

    return pw.Container(
      width: width,
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(title, style: style)),
          pw.Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}