import 'event_model.dart';
import '../service/api_service.dart';

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final parsedDouble = double.tryParse(value);
    if (parsedDouble != null) {
      return parsedDouble.toInt();
    }
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

class OrderDetailModel {
  final int id;
  final String trxId;
  final int orderTotal;
  final String status;
  final String paymentMethod;
  final String? paymentVaNumber;
  final String? paymentBillKey;
  final String? paymentBillerCode;
  final String? paymentQrUrl;
  final String? paymentDeeplinkUrl;
  final String? paymentExpiredAt;
  final String createdAt;
  final List<OrderItemModel> items;

  const OrderDetailModel({
    required this.id,
    required this.trxId,
    required this.orderTotal,
    required this.status,
    required this.paymentMethod,
    this.paymentVaNumber,
    this.paymentBillKey,
    this.paymentBillerCode,
    this.paymentQrUrl,
    this.paymentDeeplinkUrl,
    this.paymentExpiredAt,
    required this.createdAt,
    required this.items,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final id = _parseInt(json['id']);
    final trxId = json['trx_id'] ?? '';
    final orderTotal = _parseInt(json['order_total']);
    final status = json['status'] ?? '';
    final paymentMethod = json['payment_method'] ?? '';
    final paymentVaNumber = json['payment_va_number']?.toString();
    final paymentBillKey = json['payment_bill_key']?.toString();
    final paymentBillerCode = json['payment_biller_code']?.toString();
    final paymentQrUrl = json['payment_qr_url']?.toString();
    final paymentDeeplinkUrl = json['payment_deeplink_url']?.toString();
    final paymentExpiredAt = json['payment_expired_at']?.toString() ?? json['expires_at']?.toString();
    
    // Parse created_at to clean Indonesian date format
    String dateStr = '';
    try {
      final rawDate = json['created_at'];
      if (rawDate != null) {
        final parsedDate = DateTime.parse(rawDate);
        dateStr = formatIndonesianDate(parsedDate);
      }
    } catch (_) {
      dateStr = json['created_at']?.toString() ?? '';
    }

    final List<OrderItemModel> itemsList = [];
    if (json['items'] != null) {
      final List rawItems = json['items'];
      for (final item in rawItems) {
        itemsList.add(OrderItemModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return OrderDetailModel(
      id: id,
      trxId: trxId,
      orderTotal: orderTotal,
      status: status,
      paymentMethod: paymentMethod,
      paymentVaNumber: paymentVaNumber,
      paymentBillKey: paymentBillKey,
      paymentBillerCode: paymentBillerCode,
      paymentQrUrl: paymentQrUrl,
      paymentDeeplinkUrl: paymentDeeplinkUrl,
      paymentExpiredAt: paymentExpiredAt,
      createdAt: dateStr.isNotEmpty ? dateStr : (json['created_at'] ?? ''),
      items: itemsList,
    );
  }
}

class OrderItemModel {
  final int id;
  final String ticketCode;
  final String ticketName;
  final String ticketCategory;
  final String eventName;
  final String venue;
  final String eventDate;
  final String eventTime;
  final String seatLabel;
  final int pricePerTicket;
  final String? eventPoster;
  final String? attendeeName;
  final String? attendeeEmail;
  final String? attendeeIdentityNumber;

  const OrderItemModel({
    required this.id,
    required this.ticketCode,
    required this.ticketName,
    required this.ticketCategory,
    required this.eventName,
    required this.venue,
    required this.eventDate,
    required this.eventTime,
    required this.seatLabel,
    required this.pricePerTicket,
    this.eventPoster,
    this.attendeeName,
    this.attendeeEmail,
    this.attendeeIdentityNumber,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final id = _parseInt(json['id']);
    final ticketCode = json['ticket_code'] ?? '';
    final ticketName = json['ticket_name'] ?? '';
    final ticketCategory = json['ticket_category'] ?? '';
    final eventName = json['event_name'] ?? '';
    final venue = json['venue']?.toString() ?? json['event_venue']?.toString() ?? '';
    final pricePerTicket = _parseInt(json['price_per_ticket']);
    final seatLabel = json['seat_label'] ?? 'Free Seating';
    final eventPoster = ApiService.normalizeImageUrl(json['event_poster']);
    final attendeeName = json['attendee_name']?.toString();
    final attendeeEmail = json['attendee_email']?.toString();
    final attendeeIdentityNumber = json['attendee_identity_number']?.toString();

    // Parse event date and time
    String dateStr = '';
    String timeStr = '';
    try {
      final rawDate = json['event_date'];
      if (rawDate != null) {
        final parsedDate = DateTime.parse(rawDate);
        dateStr = formatIndonesianDate(parsedDate);
        timeStr = formatIndonesianTime(parsedDate);
      }
    } catch (_) {
      dateStr = json['event_date']?.toString() ?? '';
    }

    return OrderItemModel(
      id: id,
      ticketCode: ticketCode,
      ticketName: ticketName,
      ticketCategory: ticketCategory,
      eventName: eventName,
      venue: venue,
      eventDate: dateStr,
      eventTime: timeStr,
      seatLabel: seatLabel,
      pricePerTicket: pricePerTicket,
      eventPoster: eventPoster,
      attendeeName: attendeeName,
      attendeeEmail: attendeeEmail,
      attendeeIdentityNumber: attendeeIdentityNumber,
    );
  }
}
