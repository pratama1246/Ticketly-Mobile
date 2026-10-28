import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/login_screen.dart';


// DATA MODEL
class OnboardingData {
  final String imagePath;
  final String title;
  final String subtitle;

  const OnboardingData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

// ONBOARDING SCREEN UTAMA
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoTimer;

  final List<OnboardingData> _pages = const [
    OnboardingData(
      imagePath: 'assets/images/onboarding_1.png',
      title: 'Selamat Datang di\nDunia Musikmu!',
      subtitle:
          'Temukan konser impian dan rasakan\nenergi panggung yang tak terlupakan.',
    ),
    OnboardingData(
      imagePath: 'assets/images/onboarding_2.png',
      title: 'Dapatkan Tiket Konser Artis\nFavoritmu Sekarang!',
      subtitle:
          'Pesan tiket resmi dan nikmati\npengalaman menonton tanpa khawatir.',
    ),
    OnboardingData(
      imagePath: 'assets/images/onboarding_3.png',
      title: 'Rasakan Getaran\nMusik, Langsung dari\nPanggung!',
      subtitle:
          'Bergabunglah bersama ribuan\npenonton dan buat momen berharga\ntak terlupakan.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoTimer();
  }

  // Auto-slide setiap 15 detik
  void _startAutoTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      // Hanya auto-slide jika belum di halaman terakhir
      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        // Sudah di halaman terakhir, stop timer
        _autoTimer?.cancel();
      }
    });
  }

  // Saat user geser manual, reset timer agar tidak loncat terlalu cepat
  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    if (index < _pages.length - 1) {
      _startAutoTimer(); // reset hitungan 15 detik dari awal
    } else {
      _autoTimer?.cancel(); // halaman terakhir, stop timer
    }
  }

  void _skip() {
    _autoTimer?.cancel();
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onMasuk() {
    _autoTimer?.cancel();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A3A),
      body: Column(
        children: [
          // Area gambar
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _OnboardingPage(data: _pages[index]);
                  },
                ),

                // Tombol "Lewati"
                if (_currentPage < _pages.length - 1)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    right: 20,
                    child: TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Lewati',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bagian bawah: dots + tombol
          _BottomSection(
            currentPage: _currentPage,
            totalPages: _pages.length,
            onMasuk: _onMasuk,
          ),
        ],
      ),
    );
  }
}


// WIDGET: Satu halaman onboarding
class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gambar background
        Positioned.fill(
          child: Image.asset(
            data.imagePath,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, _, _) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4A148C), Color(0xFF1A237E)],
                ),
              ),
            ),
          ),
        ),

        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 0.72, 1.0],
                colors: [
                  Colors.transparent,
                  const Color(0xFF0D0A3A).withValues(alpha: 0.7),
                  const Color(0xFF0D0A3A),
                ],
              ),
            ),
          ),
        ),

        // Teks
        Positioned(
          bottom: 32,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// WIDGET: Bagian bawah — dots + tombol Masuk
class _BottomSection extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onMasuk;

  const _BottomSection({
    required this.currentPage,
    required this.totalPages,
    required this.onMasuk,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = currentPage == totalPages - 1;
    final double bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      color: const Color(0xFF0D0A3A),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: bottomPad + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (index) {
              final bool isActive = index == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 28 : 10,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: isActive
                      ? const Color(0xFF2563EB)
                      : Colors.white.withValues(alpha: 0.35),
                ),
              );
            }),
          ),

          // Tombol Masuk atau spacer
          if (isLastPage) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onMasuk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Masuk',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ] else
            const SizedBox(height: 24 + 54),
        ],
      ),
    );
  }
}
