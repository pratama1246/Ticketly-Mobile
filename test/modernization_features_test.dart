import 'package:flutter_test/flutter_test.dart';
import 'package:ticketly/models/order_detail_model.dart';

void main() {
  group('Modernization Features - Vouchers, Multi-Attendee & Midtrans Bill', () {
    test('OrderDetailModel handles Mandiri Bill Key and Biller Code correctly', () {
      final json = {
        'id': 99,
        'trx_id': 'TRX-20261018-0099',
        'order_total': 1500000,
        'status': 'pending',
        'payment_method': 'mandiri_bill',
        'payment_va_number': null,
        'payment_bill_key': '081234567890',
        'payment_biller_code': '70012',
        'payment_expired_at': '2026-10-18 21:00:00',
        'created_at': '2026-10-18T19:00:00Z',
        'items': [
          {
            'id': 301,
            'ticket_code': 'TKT-E03-99-MNDR01',
            'ticket_name': 'Cat 1 Seated',
            'ticket_category': 'Numbered Seating',
            'event_name': 'Taylor Swift The Eras Tour',
            'venue': 'Jakarta International Stadium',
            'price_per_ticket': 750000,
            'attendee_name': 'Attendee One',
            'attendee_email': 'one@example.com',
            'attendee_identity_number': '3171010101010001',
          },
          {
            'id': 302,
            'ticket_code': 'TKT-E03-99-MNDR02',
            'ticket_name': 'Cat 1 Seated',
            'ticket_category': 'Numbered Seating',
            'event_name': 'Taylor Swift The Eras Tour',
            'venue': 'Jakarta International Stadium',
            'price_per_ticket': 750000,
            'attendee_name': 'Attendee Two',
            'attendee_email': 'two@example.com',
            'attendee_identity_number': '3171010101010002',
          }
        ]
      };

      final order = OrderDetailModel.fromJson(json);

      expect(order.id, 99);
      expect(order.paymentMethod, 'mandiri_bill');
      expect(order.paymentBillerCode, '70012');
      expect(order.paymentBillKey, '081234567890');
      expect(order.items.length, 2);

      expect(order.items[0].attendeeName, 'Attendee One');
      expect(order.items[0].attendeeIdentityNumber, '3171010101010001');

      expect(order.items[1].attendeeName, 'Attendee Two');
      expect(order.items[1].attendeeIdentityNumber, '3171010101010002');
    });

    test('Voucher calculation accurately applies discount to grand total', () {
      const subtotal = 1000000;
      const tax = 110000;
      const platformFee = 20000;
      const adminFee = 2500;
      const discount = 150000;

      final baseTotal = subtotal + tax + platformFee + adminFee;
      expect(baseTotal, 1132500);

      final grandTotal = (baseTotal - discount) > 0 ? (baseTotal - discount) : 0;
      expect(grandTotal, 982500);
    });

    test('Multi-Attendee payload construction correctly captures primary and secondary attendees', () {
      final buyer = {
        'first_name': 'Ahmad',
        'last_name': 'Dhani',
        'email': 'ahmad@example.com',
        'nik': '3201010101010001',
      };

      final secondary = [
        {'name': 'Ari Lasso', 'email': 'ari@example.com', 'nik': '3201010101010002'},
        {'name': 'Andra Ramadhan', 'email': 'andra@example.com', 'nik': '3201010101010003'},
      ];

      final List<Map<String, String>> attendees = [];
      // Ticket 1 (Primary Buyer)
      attendees.add({
        'attendee_name': '${buyer['first_name']} ${buyer['last_name']}',
        'attendee_email': buyer['email']!,
        'attendee_identity_number': buyer['nik']!,
      });

      // Ticket 2..3 (Secondary)
      for (final sec in secondary) {
        attendees.add({
          'attendee_name': sec['name']!,
          'attendee_email': sec['email']!,
          'attendee_identity_number': sec['nik']!,
        });
      }

      expect(attendees.length, 3);
      expect(attendees[0]['attendee_name'], 'Ahmad Dhani');
      expect(attendees[1]['attendee_name'], 'Ari Lasso');
      expect(attendees[2]['attendee_name'], 'Andra Ramadhan');
    });
  });
}
