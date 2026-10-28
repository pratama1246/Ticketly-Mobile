import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/order_detail_model.dart';
import '../service/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import 'account_screen.dart';
import 'home_page.dart';
import 'login_screen.dart';
import 'ticket_detail_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<OrderDetailModel> _completedOrders = [];

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadTickets();
  }

  Future<void> _checkAuthAndLoadTickets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
      return;
    }

    final token = await AuthService.getToken();
    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sesi habis. Silakan login kembali.';
      });
      return;
    }

    try {
      // 1. Fetch completed orders with items pre-fetched in a single optimized request
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/orders?status=completed&include=items'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final List ordersRaw = decoded['data'];
          
          final List<OrderDetailModel> detailedOrders = [];
          final List<dynamic> ordersNeedingDetail = [];

          for (final order in ordersRaw) {
            if (order['status'] == 'completed') {
              if (order['items'] != null && (order['items'] as List).isNotEmpty) {
                detailedOrders.add(OrderDetailModel.fromJson(Map<String, dynamic>.from(order)));
              } else {
                ordersNeedingDetail.add(order);
              }
            }
          }

          // Fallback in parallel if server didn't include items
          if (ordersNeedingDetail.isNotEmpty) {
            final detailFutures = ordersNeedingDetail.map((order) async {
              try {
                final orderId = order['id'];
                final detailResponse = await http.get(
                  Uri.parse('${ApiConstants.baseUrl}/api/orders/$orderId'),
                  headers: {'Authorization': 'Bearer $token'},
                ).timeout(const Duration(seconds: 5));

                if (detailResponse.statusCode == 200) {
                  final detailDecoded = json.decode(detailResponse.body);
                  if (detailDecoded['status'] == 'success' && detailDecoded['data'] != null) {
                    return OrderDetailModel.fromJson(Map<String, dynamic>.from(detailDecoded['data']));
                  }
                }
              } catch (_) {}
              return null;
            });

            final fetched = await Future.wait(detailFutures);
            for (final item in fetched) {
              if (item != null) detailedOrders.add(item);
            }
          }

          if (mounted) {
            setState(() {
              _completedOrders = detailedOrders;
              _isLoading = false;
            });
          }
          return;
        }
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat tiket Anda.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Terjadi kesalahan jaringan: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Flatten list of orders to tickets list for direct card display
    final List<_TicketListItem> ticketsToRender = [];
    for (final order in _completedOrders) {
      for (int i = 0; i < order.items.length; i++) {
        final item = order.items[i];
        ticketsToRender.add(_TicketListItem(
          order: order,
          ticket: item,
          index: i + 1,
          total: order.items.length,
        ));
      }
    }

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
      ),
      body: RefreshIndicator(
        onRefresh: _checkAuthAndLoadTickets,
        color: AppColors.bluePrimary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.bluePrimary))
            : (_errorMessage != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _checkAuthAndLoadTickets,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : (ticketsToRender.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.confirmation_number_outlined,
                                    size: 64,
                                    color: AppColors.textHint,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada tiket',
                                    style: AppTextStyles.pageTitleStyle,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tiket yang kamu beli akan muncul di sini',
                                    style: AppTextStyles.bodyStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: ticketsToRender.length,
                        itemBuilder: (context, index) {
                          final item = ticketsToRender[index];
                          return _buildTicketCard(context, item);
                        },
                      ))),
      ),
      bottomNavigationBar: TicketlyBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomePage(),
                transitionDuration: Duration.zero,
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const AccountScreen(),
                transitionDuration: Duration.zero,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, _TicketListItem item) {
    // Normalize address mapping
    final String venue = item.ticket.eventName.contains('RIIZE')
        ? 'ICE BSD Hall 5-6'
        : 'Jakarta International Stadium';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Poster thumbnail (Loads webp from API if present, otherwise shows a clean placeholder)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.ticket.eventPoster != null && item.ticket.eventPoster!.isNotEmpty
                          ? Image.network(
                              item.ticket.eventPoster!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 100,
                                height: 100,
                                color: const Color(0xFFF3F4F6),
                                child: const Icon(
                                  Icons.music_note_outlined,
                                  size: 32,
                                  color: AppColors.textHint,
                                ),
                              ),
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: const Color(0xFFF3F4F6),
                              child: const Icon(
                                Icons.music_note_outlined,
                                size: 32,
                                color: AppColors.textHint,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.ticket.eventName.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textPrimary),
                              const SizedBox(width: 8),
                              Text(
                                item.ticket.eventDate,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: AppColors.textPrimary),
                              const SizedBox(width: 8),
                              Text(
                                item.ticket.eventTime.isNotEmpty ? item.ticket.eventTime : '19.00 - 21.00 WIB',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textPrimary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  venue,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Full Width Action Button matching mockup
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketDetailScreen(
                            order: item.order,
                            ticket: item.ticket,
                            ticketIndex: item.index,
                            totalTickets: item.total,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bluePrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lihat Tiket',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.confirmation_number_outlined, size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Private helper to wrap Ticket item alongside its Order container details
class _TicketListItem {
  final OrderDetailModel order;
  final OrderItemModel ticket;
  final int index;
  final int total;

  const _TicketListItem({
    required this.order,
    required this.ticket,
    required this.index,
    required this.total,
  });
}
