import 'package:flutter_test/flutter_test.dart';
import 'package:ticketly/models/order_detail_model.dart';

void main() {
  group('Phase 1 - OrderDetailModel & OrderItemModel Tests', () {
    test('OrderDetailModel correctly parses Midtrans payment fields and items', () {
      final json = {
        'id': 42,
        'trx_id': 'TRX-20261018-0042',
        'order_total': 750000,
        'status': 'pending',
        'payment_method': 'bca',
        'payment_va_number': '123456789012',
        'payment_bill_key': null,
        'payment_biller_code': null,
        'payment_qr_url': 'https://api.midtrans.com/qr/sample.png',
        'payment_deeplink_url': 'https://simulator.midtrans.com/gopay/pay',
        'payment_expired_at': '2026-10-18 20:00:00',
        'created_at': '2026-10-18T19:00:00Z',
        'items': [
          {
            'id': 101,
            'ticket_code': 'TKT-E01-42-ABCD12',
            'ticket_name': 'VIP Festival',
            'ticket_category': 'Standing',
            'event_name': 'Coldplay Music of the Spheres',
            'venue': 'Gelora Bung Karno Main Stadium',
            'event_date': '2026-11-15T19:30:00Z',
            'seat_label': 'VIP Front Row',
            'price_per_ticket': 750000,
            'attendee_name': 'Budi Pratama',
            'attendee_email': 'budi@example.com',
            'attendee_identity_number': '3301234567890001',
          }
        ]
      };

      final order = OrderDetailModel.fromJson(json);

      expect(order.id, 42);
      expect(order.trxId, 'TRX-20261018-0042');
      expect(order.orderTotal, 750000);
      expect(order.status, 'pending');
      expect(order.paymentMethod, 'bca');
      expect(order.paymentVaNumber, '123456789012');
      expect(order.paymentQrUrl, 'https://api.midtrans.com/qr/sample.png');
      expect(order.paymentDeeplinkUrl, 'https://simulator.midtrans.com/gopay/pay');
      expect(order.paymentExpiredAt, '2026-10-18 20:00:00');
      expect(order.items.length, 1);

      final item = order.items.first;
      expect(item.id, 101);
      expect(item.ticketCode, 'TKT-E01-42-ABCD12');
      expect(item.eventName, 'Coldplay Music of the Spheres');
      expect(item.venue, 'Gelora Bung Karno Main Stadium');
      expect(item.attendeeName, 'Budi Pratama');
      expect(item.attendeeEmail, 'budi@example.com');
      expect(item.attendeeIdentityNumber, '3301234567890001');
    });

    test('OrderItemModel safely falls back when venue is omitted', () {
      final json = {
        'id': 202,
        'ticket_code': 'TKT-E02-50-XYZ999',
        'ticket_name': 'General Admission',
        'ticket_category': 'General',
        'event_name': 'Jazz Heritage Night',
        'price_per_ticket': 250000,
      };

      final item = OrderItemModel.fromJson(json);
      expect(item.venue, '');
      expect(item.attendeeName, isNull);
    });
  });
}
