import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/order_detail_model.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../service/auth_service.dart';
import 'home_page.dart';
import 'account_screen.dart';

class TicketDetailScreen extends StatefulWidget {
  final OrderDetailModel order;
  final OrderItemModel ticket;
  final int ticketIndex;
  final int totalTickets;

  const TicketDetailScreen({
    super.key,
    required this.order,
    required this.ticket,
    required this.ticketIndex,
    required this.totalTickets,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  String _buyerName = 'Hanah';

  @override
  void initState() {
    super.initState();
    _loadBuyerName();
  }

  Future<void> _loadBuyerName() async {
    try {
      final user = await AuthService.getUser();
      if (user != null && mounted) {
        setState(() {
          _buyerName = user['username'] ?? 'Hanah';
        });
      }
    } catch (_) {
      // fallback already set to 'Hanah'
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic venue resolution from ticket model
    final String venue = widget.ticket.venue.isNotEmpty
        ? widget.ticket.venue
        : 'Venue Lokasi Event';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(
        title: Text(
          'My Ticket',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Outer card wrapping the ticket layout
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.cardShadow,
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  // Blue Header Area
                  Container(
                    width: double.infinity,
                    color: AppColors.bluePrimary,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Column(
                      children: [
                        // Official App Logo
                        Image.asset(
                          'assets/images/logo_tick_square.png',
                          width: 90,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'E-TIKET RESMI',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order ID #${widget.order.trxId}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ticket Body Content
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Title
                        Text(
                          widget.ticket.eventName.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.borderDefault),
                        const SizedBox(height: 16),

                        // Info List with aligned colons
                        _buildInfoRow('PEMBELI', _buyerName),
                        const SizedBox(height: 12),
                        _buildInfoRow('TANGGAL', widget.ticket.eventDate),
                        const SizedBox(height: 12),
                        _buildInfoRow('WAKTU', widget.ticket.eventTime.isNotEmpty ? widget.ticket.eventTime : '19.00 - 21.00 WIB'),
                        const SizedBox(height: 12),
                        _buildInfoRow('LOKASI', venue),
                        const SizedBox(height: 12),
                        _buildInfoRow('KATEGORI', widget.ticket.ticketName, isHighlight: true),
                        const SizedBox(height: 12),
                        _buildInfoRow('NOMOR KURSI', widget.ticket.seatLabel, isHighlight: true),
                        const SizedBox(height: 20),

                        // Dotted Divider Line
                        Row(
                          children: List.generate(
                            30,
                            (index) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                height: 1.5,
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // QR Code Scanner Box - single grey container enclosing everything
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Scan di pintu masuk',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                                ),
                                child: QrImageView(
                                  data: widget.ticket.ticketCode,
                                  version: QrVersions.auto,
                                  size: 160.0,
                                  backgroundColor: Colors.white,
                                  gapless: true,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.ticket.ticketCode,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Grey Footer
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF2D2D2D),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Text(
                      '© 2025 Ticketly System. Tiket ${widget.ticketIndex}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: TicketlyBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomePage(),
                transitionDuration: Duration.zero,
              ),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.pop(context);
          } else if (index == 2) {
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const AccountScreen(),
                transitionDuration: Duration.zero,
              ),
              (route) => false,
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          ':  ',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.bluePrimary : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
