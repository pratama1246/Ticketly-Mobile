import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../service/auth_service.dart';
import '../service/api_service.dart';
import 'home_page.dart';
import 'my_tickets_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'legal_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _name = '';
  String _email = '';
  String _profilePic = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadProfile();
  }

  Future<void> _checkAuthAndLoadProfile() async {
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

    final profile = await AuthService.getProfile();
    if (mounted) {
      if (profile != null) {
        setState(() {
          _name = profile['username'] ?? '';
          _email = profile['email'] ?? '';
          _profilePic = profile['foto'] ?? '';
          _isLoading = false;
        });
      } else {
        // Fallback to local session cache if offline or API error
        final cachedUser = await AuthService.getUser();
        setState(() {
          if (cachedUser != null) {
            _name = cachedUser['username'] ?? '';
            _email = cachedUser['email'] ?? '';
            _profilePic = cachedUser['foto'] ?? '';
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _profilePic.isNotEmpty && _profilePic.startsWith('http');

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: Column(
        children: [
          // White Top AppBar Area
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
              left: 24,
              right: 24,
            ),
            child: Text(
              'Akun',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          
          // Body content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.bluePrimary),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _checkAuthAndLoadProfile,
                    color: AppColors.bluePrimary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // Blue curved header
                          ClipPath(
                            clipper: BottomArcClipper(),
                            child: Container(
                              height: 220,
                              width: double.infinity,
                              color: const Color(0xFF4285F4), // Bright vibrant blue matching mockup
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white,
                                    backgroundImage: hasImage
                                        ? NetworkImage(ApiService.normalizeImageUrl(_profilePic))
                                        : null,
                                    child: !hasImage
                                        ? const Icon(Icons.person, size: 50, color: AppColors.textHint)
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _email,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 20), // visual spacing for arc curve height
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Menu Items List
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              children: [
                                _MenuCard(
                                  icon: Icons.edit_outlined,
                                  title: 'Edit Nama Profil',
                                  iconColor: const Color(0xFFFBBF24),
                                  iconBgColor: const Color(0xFFFEF3C7),
                                  textColor: AppColors.textPrimary,
                                  onTap: () async {
                                    final result = await Navigator.push<Map<String, String>>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfileScreen(
                                          currentName: _name,
                                          currentEmail: _email,
                                          currentProfilePic: _profilePic,
                                        ),
                                      ),
                                    );
                                    if (result != null && mounted) {
                                      setState(() {
                                        _name = result['name'] ?? _name;
                                        _email = result['email'] ?? _email;
                                        _profilePic = result['profilePic'] ?? _profilePic;
                                      });
                                    }
                                  },
                                ),
                                _MenuCard(
                                  icon: Icons.lock_outlined,
                                  title: 'Ubah Kata Sandi',
                                  iconColor: const Color(0xFFFBBF24),
                                  iconBgColor: const Color(0xFFFEF3C7),
                                  textColor: AppColors.textPrimary,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Fitur Ubah Kata Sandi belum tersedia'),
                                      ),
                                    );
                                  },
                                ),
                                _MenuCard(
                                  icon: Icons.settings_outlined,
                                  title: 'Pengaturan',
                                  iconColor: const Color(0xFFFBBF24),
                                  iconBgColor: const Color(0xFFFEF3C7),
                                  textColor: AppColors.textPrimary,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Fitur Pengaturan belum tersedia'),
                                      ),
                                    );
                                  },
                                ),
                                _MenuCard(
                                  icon: Icons.description_outlined,
                                  title: 'Syarat & Ketentuan',
                                  iconColor: const Color(0xFF3B82F6),
                                  iconBgColor: const Color(0xFFEFF6FF),
                                  textColor: AppColors.textPrimary,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LegalScreen(
                                          title: 'Syarat & Ketentuan',
                                          endpoint: '/api/terms',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _MenuCard(
                                  icon: Icons.privacy_tip_outlined,
                                  title: 'Kebijakan Privasi',
                                  iconColor: const Color(0xFF10B981),
                                  iconBgColor: const Color(0xFFECFDF5),
                                  textColor: AppColors.textPrimary,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LegalScreen(
                                          title: 'Kebijakan Privasi',
                                          endpoint: '/api/privacy',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _MenuCard(
                                  icon: Icons.logout,
                                  title: 'Keluar',
                                  iconColor: const Color(0xFFEF4444),
                                  iconBgColor: const Color(0xFFFEE2E2),
                                  textColor: const Color(0xFFEF4444),
                                  onTap: () async {
                                    final navigator = Navigator.of(context);
                                    final messenger = ScaffoldMessenger.of(context);
                                    
                                    await AuthService.logout();
                                    
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Berhasil keluar akun'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                    navigator.pushReplacement(
                                      MaterialPageRoute(builder: (context) => const HomePage()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: TicketlyBottomNavBar(
        currentIndex: 2,
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
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const MyTicketsScreen(),
                transitionDuration: Duration.zero,
              ),
            );
          }
        },
      ),
    );
  }
}

class BottomArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color iconBgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.iconBgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF9CA3AF),
          size: 24,
        ),
        onTap: onTap,
      ),
    );
  }
}
