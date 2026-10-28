import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../models/event_detail_model.dart';
import '../service/api_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../service/auth_service.dart';
import 'my_tickets_screen.dart';
import 'account_screen.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

// Helper to format currency manually to avoid adding package dependencies
String _formatCurrency(int number) {
  final str = number.toString();
  final chars = str.split('');
  String formatted = '';
  int count = 0;
  for (int i = chars.length - 1; i >= 0; i--) {
    formatted = chars[i] + formatted;
    count++;
    if (count % 3 == 0 && i > 0) {
      formatted = '.$formatted';
    }
  }
  return 'Rp $formatted';
}

class EventDetailScreen extends StatefulWidget {
  final String slug;

  const EventDetailScreen({super.key, required this.slug});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  EventDetailModel? _event;
  bool _isLoading = true;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  // Local navigation state to switch between info and ticket selection
  bool _isTicketSelectionMode = false;

  // Map to track ticket type ID -> selected quantity
  final Map<int, int> _selectedQuantities = {};

  @override
  void initState() {
    super.initState();
    _loadEventDetail();
  }

  Future<void> _loadEventDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await ApiService.fetchEventDetail(widget.slug);
      if (mounted) {
        setState(() {
          _event = result;
          _isLoading = false;
          if (_event == null) {
            _errorMessage = 'Event tidak ditemukan atau gagal memuat data.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Terjadi kesalahan saat memuat data: $e';
        });
      }
    }
  }

  // Back action helper
  void _handleBack() {
    if (_isTicketSelectionMode) {
      setState(() {
        _isTicketSelectionMode = false;
      });
      _scrollToTop();
    } else {
      Navigator.pop(context);
    }
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Calculate total amount
  int _calculateSubtotal() {
    if (_event == null) return 0;
    int total = 0;
    for (final ticket in _event!.tickets) {
      final qty = _selectedQuantities[ticket.id] ?? 0;
      total += ticket.price * qty;
    }
    return total;
  }

  // Get total quantity selected
  int _calculateTotalQuantity() {
    int total = 0;
    _selectedQuantities.forEach((_, qty) => total += qty);
    return total;
  }

  // Get selected tickets summary text (e.g. "1x CAT 1")
  String _getSelectedTicketsSummary() {
    if (_event == null) return '';
    final items = <String>[];
    for (final ticket in _event!.tickets) {
      final qty = _selectedQuantities[ticket.id] ?? 0;
      if (qty > 0) {
        items.add('${qty}x ${ticket.name}');
      }
    }
    return items.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    // Intercept hardware back button
    return PopScope(
      canPop: !_isTicketSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isTicketSelectionMode) {
          setState(() {
            _isTicketSelectionMode = false;
          });
          _scrollToTop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.screenBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: _handleBack,
          ),
          title: Text(
            'Detail Konser',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.bluePrimary),
        ),
      );
    }

    if (_errorMessage != null || _event == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Gagal memuat event.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyStyle,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadEventDetail,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final event = _event!;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Poster Image
          _buildPoster(event.posterImage),

          // 2. Event Title & Metadata
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Meta Rows
                _buildMetaRow(Icons.calendar_month_outlined, event.date),
                const SizedBox(height: 8),
                _buildMetaRow(Icons.access_time_outlined, event.time),
                const SizedBox(height: 8),
                _buildMetaRow(Icons.location_on_outlined, event.venue),
                const SizedBox(height: 12),

                // Status Badge (only in info mode)
                if (!_isTicketSelectionMode) _buildStatusBadge(event.eventStatus),
              ],
            ),
          ),

          // 3. Dynamic Section Content (Info vs Ticket list)
          _isTicketSelectionMode ? _buildTicketSelectionView(event) : _buildEventDetailView(event),
        ],
      ),
    );
  }

  Widget _buildPoster(String? url) {
    return GestureDetector(
      onTap: () => _showZoomableImage(context, url),
      child: Container(
        height: 220,
        width: double.infinity,
        color: Colors.grey[300],
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image_outlined, size: 64, color: AppColors.textHint),
                ),
              )
            : const Center(
                child: Icon(Icons.image_outlined, size: 64, color: AppColors.textHint),
              ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'ended':
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[600]!;
        label = 'Berakhir';
        break;
      case 'sold_out':
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        label = 'Habis Terjual';
        break;
      case 'almost_sold':
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        label = 'Hampir Habis';
        break;
      case 'available':
      default:
        bgColor = const Color(0xFFDCFCE7); // Light green matching mockup
        textColor = const Color(0xFF16A34A);
        label = 'Sedang Berlangsung';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Event Detail View Content
  // ─────────────────────────────────────────────
  Widget _buildEventDetailView(EventDetailModel event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description (Parsed HTML)
          ..._parseHtmlToWidgets(event.description, GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            height: 1.5,
          )),
          const SizedBox(height: 20),

          // Seatmap (Dark container for visibility)
          if (event.seatmapImage != null && event.seatmapImage!.isNotEmpty) ...[
            Text(
              'Denah Tempat Duduk',
              style: AppTextStyles.sectionHeadingStyle,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showZoomableImage(context, event.seatmapImage),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212), // Dark background for contrast
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.borderDefault, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.card - 4),
                  child: Image.network(
                    event.seatmapImage!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  // HTML Parser to translate TinyMCE HTML into structured Flutter widgets
  List<Widget> _parseHtmlToWidgets(String html, TextStyle baseStyle) {
    String cleanHtml = html
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&copy;', '©')
        .replaceAll('&rsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—');

    final List<Widget> widgets = [];
    final regExp = RegExp(r'<(h2|h3|p|li|div)[^>]*>(.*?)<\/\1>|<br\s*\/?>', dotAll: true, caseSensitive: false);
    final matches = regExp.allMatches(cleanHtml);

    if (matches.isEmpty) {
      String textOnly = cleanHtml.replaceAll(RegExp(r'<[^>]*>'), '');
      widgets.add(Text(textOnly, style: baseStyle));
      return widgets;
    }

    int lastEnd = 0;
    for (final match in matches) {
      if (match.start > lastEnd) {
        final plainText = cleanHtml.substring(lastEnd, match.start).replaceAll(RegExp(r'<[^>]*>'), '').trim();
        if (plainText.isNotEmpty) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(plainText, style: baseStyle),
          ));
        }
      }

      final tag = match.group(1)?.toLowerCase();
      final content = match.group(2) ?? '';

      if (tag == 'h2' || tag == 'h3') {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: RichText(
            text: _parseInlineTags(content, baseStyle.copyWith(
              fontSize: tag == 'h2' ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            )),
          ),
        ));
      } else if (tag == 'p' || tag == 'div') {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RichText(
            text: _parseInlineTags(content, baseStyle),
          ),
        ));
      } else if (tag == 'li') {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6.0, left: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: baseStyle.copyWith(fontWeight: FontWeight.bold)),
              Expanded(
                child: RichText(
                  text: _parseInlineTags(content, baseStyle),
                ),
              ),
            ],
          ),
        ));
      }
      lastEnd = match.end;
    }

    if (lastEnd < cleanHtml.length) {
      final plainText = cleanHtml.substring(lastEnd).replaceAll(RegExp(r'<[^>]*>'), '').trim();
      if (plainText.isNotEmpty) {
        widgets.add(Text(plainText, style: baseStyle));
      }
    }

    return widgets;
  }

  // ─────────────────────────────────────────────
  // Ticket Selection View Content
  // ─────────────────────────────────────────────
  Widget _buildTicketSelectionView(EventDetailModel event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic List of Ticket Cards
          ...event.tickets.map((ticket) {
            final qty = _selectedQuantities[ticket.id] ?? 0;
            return _TicketCard(
              ticket: ticket,
              selectedQuantity: qty,
              onQuantityChanged: (newQty) {
                setState(() {
                  _selectedQuantities[ticket.id] = newQty;
                });
              },
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Persistent Bottom Bar Builder
  // ─────────────────────────────────────────────
  Widget? _buildBottomNavigationBar() {
    if (_isLoading || _errorMessage != null || _event == null) return null;

    final subtotal = _calculateSubtotal();
    final totalQty = _calculateTotalQuantity();

    final bool canOrder = _event!.eventStatus != 'ended' && _event!.eventStatus != 'sold_out';
    String buttonText = 'Beli Tiket Sekarang';
    if (_event!.eventStatus == 'ended') {
      buttonText = 'Acara Telah Berakhir';
    } else if (_event!.eventStatus == 'sold_out') {
      buttonText = 'Tiket Habis Terjual';
    }

    if (!_isTicketSelectionMode) {
      // Info View Bottom: "Beli Tiket Sekarang" + TicketlyBottomNavBar
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canOrder
                    ? () {
                        setState(() {
                          _isTicketSelectionMode = true;
                        });
                        _scrollToTop();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canOrder ? AppColors.bluePrimary : const Color(0xFFD1D5DB),
                  foregroundColor: Colors.white,
                ),
                child: Text(buttonText),
              ),
            ),
          ),
          TicketlyBottomNavBar(
            currentIndex: 0,
            onTap: (index) {
              if (index == 0) {
                Navigator.pop(context);
              } else if (index == 1) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyTicketsScreen()),
                );
              } else if (index == 2) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountScreen()),
                );
              }
            },
          ),
        ],
      );
    } else {
      // Ticket Selection View Bottom: Total Estimasi + Pesan Sekarang
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary text (e.g. "1x CAT 1")
                    if (totalQty > 0)
                      Text(
                        _getSelectedTicketsSummary(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    Text(
                      'Total Estimasi',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _formatCurrency(subtotal),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: totalQty > 0 ? AppColors.bluePrimary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 48,
                width: 180, // Increased width
                child: ElevatedButton(
                  onPressed: totalQty > 0
                      ? () {
                          _navigateToCheckout();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: totalQty > 0 ? AppColors.bluePrimary : const Color(0xFFD1D5DB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16), // Custom padding to fit text
                    textStyle: GoogleFonts.poppins(
                      fontSize: 14, // Slightly smaller font size
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text(
                    'Pesan Sekarang',
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // Navigate to Checkout Screen
  // ─────────────────────────────────────────────
  void _navigateToCheckout() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan login terlebih dahulu untuk memesan tiket.'),
            backgroundColor: AppColors.textPrimary,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            event: _event!,
            selectedQuantities: _selectedQuantities,
            subtotal: _calculateSubtotal(),
            totalQty: _calculateTotalQuantity(),
          ),
        ),
      );
    }
  }

  void _showZoomableImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => _ZoomableImageDialog(imageUrl: imageUrl),
    );
  }
}

// ─────────────────────────────────────────────
// Ticket Tier Card Widget
// ─────────────────────────────────────────────
class _TicketCard extends StatelessWidget {
  final TicketTypeModel ticket;
  final int selectedQuantity;
  final ValueChanged<int> onQuantityChanged;

  const _TicketCard({
    required this.ticket,
    required this.selectedQuantity,
    required this.onQuantityChanged,
  });

  Color _parseColor(String hex) {
    try {
      final hexStr = hex.replaceAll('#', '');
      if (hexStr.length == 6) {
        return Color(int.parse('FF$hexStr', radix: 16));
      }
      return Color(int.parse(hexStr, radix: 16));
    } catch (_) {
      return AppColors.bluePrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = _parseColor(ticket.uiColor);
    final isSoldOut = ticket.quantityLeft <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault, width: 1.5),
        boxShadow: AppShadows.cardShadow,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ticket Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: headerColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Text(
                    ticket.ticketCategory,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Ticket Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ticket bullet points
                if (ticket.bulletDescriptions.isNotEmpty) ...[
                  ...ticket.bulletDescriptions.map((desc) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Expanded(
                              child: RichText(
                                text: _parseInlineTags(
                                  desc,
                                  GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                ],

                // Deadline
                if (ticket.ticketDate != null)
                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Batas Waktu Pemesanan: ${ticket.ticketDate} WIB',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.borderDefault),
                const SizedBox(height: 12),

                // Price and Stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatCurrency(ticket.price),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isSoldOut)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Habis',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Jumlah',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderDefault, width: 1.2),
                            ),
                            child: Row(
                              children: [
                                // Minus Button
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  icon: const Icon(Icons.remove, size: 14, color: AppColors.textPrimary),
                                  onPressed: selectedQuantity > 0
                                      ? () => onQuantityChanged(selectedQuantity - 1)
                                      : null,
                                ),
                                // Quantity Text
                                Container(
                                  alignment: Alignment.center,
                                  width: 36,
                                  child: Text(
                                    selectedQuantity.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                // Plus Button
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  icon: const Icon(Icons.add, size: 14, color: AppColors.textPrimary),
                                  onPressed: selectedQuantity < ticket.quantityLeft
                                      ? () => onQuantityChanged(selectedQuantity + 1)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper to parse inline HTML tags like <strong> or <b>
TextSpan _parseInlineTags(String text, TextStyle style) {
  // Strip all tags EXCEPT strong and b tags (e.g. clean up span, em, a, etc.)
  final cleanText = text.replaceAll(RegExp(r'<(?!/?(strong|b)\b)[^>]*>', caseSensitive: false), '');

  final regExp = RegExp(r'<(strong|b)>(.*?)<\/\1>', caseSensitive: false);
  final List<TextSpan> children = [];
  int lastEnd = 0;

  final matches = regExp.allMatches(cleanText);
  for (final match in matches) {
    if (match.start > lastEnd) {
      children.add(TextSpan(text: cleanText.substring(lastEnd, match.start)));
    }
    final content = match.group(2) ?? '';
    children.add(TextSpan(
      text: content,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ));
    lastEnd = match.end;
  }

  if (lastEnd < cleanText.length) {
    children.add(TextSpan(text: cleanText.substring(lastEnd)));
  }

  return TextSpan(style: style, children: children);
}

// ─────────────────────────────────────────────
// End of file
// ─────────────────────────────────────────────

class _ZoomableImageDialog extends StatefulWidget {
  final String imageUrl;
  const _ZoomableImageDialog({required this.imageUrl});

  @override
  State<_ZoomableImageDialog> createState() => _ZoomableImageDialogState();
}

class _ZoomableImageDialogState extends State<_ZoomableImageDialog> {
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails!.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translateByDouble(-position.dx, -position.dy, 0.0, 1.0)
        ..scaleByDouble(2.0, 2.0, 1.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onDoubleTapDown: (details) => _doubleTapDetails = details,
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image_outlined, size: 64, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
