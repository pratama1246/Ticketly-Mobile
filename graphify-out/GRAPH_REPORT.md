# Graph Report - ticketly  (2026-08-25)

## Corpus Check
- 128 files · ~178,274 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 923 nodes · 1214 edges · 67 communities (53 shown, 14 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 66 edges (avg confidence: 0.86)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Checkout State & Processing Logic
- Windows Runner Native Win32 Layer
- Flutter Theme & Design Tokens
- Event Detail & Checkout Views
- Onboarding Carousel & Timer
- Screen Navigation & View Controllers
- macOS Flutter Engine Runner
- API Client & REST Networking
- User Tickets & Order History
- Home Page Mock Data & Animation
- Event Detail Data Model
- API Constants & Endpoint Config
- Reusable UI Card Components
- Linux GTK Engine Integration
- Profile & Account Management
- Order & Event Data Models
- Event Entity & Schedule Models
- Event List Screen & Cards
- Password Reset & Recovery UI
- Event Card UI Component
- Flutter Main Entrypoint & Search
- User Registration & SSO UI
- User Login & Auth UI
- Home Page & Splash Screen
- Windows Runner Main Entrypoint
- macOS & Web App Icon Assets
- Bottom Navigation Bar Widget
- Web Manifest & PWA Configuration
- Android Launcher Icon Assets
- OTP Verification Screen UI
- Forgot Password Form UI
- Checkout & Ticket Navigation
- Section Header UI Widget
- Desktop CMake Build Configurations
- Flutter Project Configuration & Rules
- App Design System & Typography
- Flutter Widget Test Suite
- Backend Architecture & API Standards
- Android Main Activity Host
- Auth & Security Illustration Assets
- Onboarding Illustration Assets
- iOS App Store & High-Res Icons
- JWT Auth & Session Management
- Order Lifecycle & Checkout Spec
- Ticketly Brand Identity Assets
- Event Detail Screen Controller
- Zoomable Image Dialog Component
- Domain Validation Rule
- Email Validation Rule
- iOS Launch Screen Documentation
- Nullable String Type Annotation
- Dynamic Base URL Resolver
- Mobile Architecture Overview
- Flutter Web HTML Shell

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 24 edges
2. `MessageHandler` - 12 edges
3. `FlutterWindow` - 10 edges
4. `Create` - 10 edges
5. `WndProc` - 10 edges
6. `MessageHandler` - 9 edges
7. `_MyApplication` - 7 edges
8. `WindowClassRegistrar` - 7 edges
9. `Destroy` - 7 edges
10. `OnCreate` - 6 edges

## Surprising Connections (you probably didn't know these)
- `Linux CMake Application Project` --semantically_similar_to--> `Windows CMake Application Project`  [INFERRED] [semantically similar]
  linux/CMakeLists.txt → windows/CMakeLists.txt
- `macOS AppIcon 512x512` --semantically_similar_to--> `Web PWA Icon 512x512`  [INFERRED] [semantically similar]
  macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png → web/icons/Icon-512.png
- `CI4 REST API Integration Map` --references--> `Ticketly Backend Architecture Guidelines`  [INFERRED]
  README.md → AGENTS.md
- `Custom JWT Auth Flow` --conceptually_related_to--> `Mobile JWT Auth and Session Cache`  [INFERRED]
  AGENTS.md → README.md
- `CI4 REST API Integration Map` --conceptually_related_to--> `API Response Structure Standard`  [INFERRED]
  README.md → AGENTS.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Flutter Desktop and Web Runner Platform Embeddings** — linux_cmakelists_linux_project, windows_cmakelists_windows_project, web_index_html_entrypoint [EXTRACTED 1.00]
- **Stateless Custom JWT Authentication Flow** — agents_jwt_auth_flow, readme_auth_session_management, readme_api_integration [INFERRED 0.95]
- **Ticketly Mobile Design Tokens System** — design_app_colors, design_app_typography, design_app_dimensions [EXTRACTED 1.00]
- **Mobile App Onboarding Carousel Assets** — assets_images_onboarding_1_image, assets_images_onboarding_2_image, assets_images_onboarding_3_image [INFERRED 0.85]
- **Authentication and Security UI Assets** — assets_icons_google_icon, assets_images_forgot_password_illustration_image, assets_images_otp_verification_illustration_image [INFERRED 0.85]
- **Android App Launcher Icon Assets (ic_launcher)** — android_app_src_main_res_mipmap_mdpi_ic_launcher, android_app_src_main_res_mipmap_hdpi_ic_launcher, android_app_src_main_res_mipmap_xhdpi_ic_launcher, android_app_src_main_res_mipmap_xxhdpi_ic_launcher, android_app_src_main_res_mipmap_xxxhdpi_ic_launcher [INFERRED 0.95]
- **Android App Launcher Icon Assets (launcher_icon)** — android_app_src_main_res_mipmap_mdpi_launcher_icon, android_app_src_main_res_mipmap_hdpi_launcher_icon, android_app_src_main_res_mipmap_xhdpi_launcher_icon, android_app_src_main_res_mipmap_xxhdpi_launcher_icon, android_app_src_main_res_mipmap_xxxhdpi_launcher_icon [INFERRED 0.95]
- **iOS App Icon Asset Set (AppIcon.appiconset)** — ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_50x50_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_50x50_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_57x57_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_57x57_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_72x72_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_72x72_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_83_5x83_5_2x [INFERRED 0.95]
- **iOS Launch Image Asset Set (LaunchImage.imageset)** — ios_runner_assets_xcassets_launchimage_imageset_launchimage, ios_runner_assets_xcassets_launchimage_imageset_launchimage_2x, ios_runner_assets_xcassets_launchimage_imageset_launchimage_3x [INFERRED 0.95]
- **macOS AppIcon Asset Set** — macos_runner_assets_xcassets_appicon_appiconset_app_icon_16, macos_runner_assets_xcassets_appicon_appiconset_app_icon_32, macos_runner_assets_xcassets_appicon_appiconset_app_icon_64, macos_runner_assets_xcassets_appicon_appiconset_app_icon_128, macos_runner_assets_xcassets_appicon_appiconset_app_icon_256, macos_runner_assets_xcassets_appicon_appiconset_app_icon_512, macos_runner_assets_xcassets_appicon_appiconset_app_icon_1024 [INFERRED 0.95]
- **Web & PWA Icon Asset Set** — web_favicon, web_icons_icon_192, web_icons_icon_512, web_icons_icon_maskable_192, web_icons_icon_maskable_512 [INFERRED 0.95]

## Communities (67 total, 14 thin omitted)

### Community 0 - "Checkout State & Processing Logic"
Cohesion: 0.02
Nodes (84): int?, _agreeProcessing, _agreeTnC, _apiAdminFee, _apiGrandTotal, _apiPlatformFee, _apiSubTotal, _apiTaxAmount (+76 more)

### Community 1 - "Windows Runner Native Win32 Layer"
Cohesion: 0.06
Nodes (55): RECT, unique_ptr, DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM (+47 more)

### Community 2 - "Flutter Theme & Design Tokens"
Cohesion: 0.04
Nodes (53): accentYellow, accentYellowBright, AppColors, AppRadius, AppShadows, AppSpacing, AppTextStyles, badge (+45 more)

### Community 3 - "Event Detail & Checkout Views"
Cohesion: 0.04
Nodes (51): checkout_screen.dart, build, _buildBody, _buildBottomNavigationBar, _buildEventDetailView, _buildMetaRow, _buildPoster, _buildStatusBadge (+43 more)

### Community 4 - "Onboarding Carousel & Timer"
Cohesion: 0.05
Nodes (41): dart:async, _autoTimer, build, createState, _currentPage, data, dispose, imagePath (+33 more)

### Community 5 - "Screen Navigation & View Controllers"
Cohesion: 0.06
Nodes (42): event_list_screen.dart, AccountScreen, _AccountScreenState, CheckoutScreen, _CheckoutScreenState, ForgotPasswordScreen, _ForgotPasswordScreenState, _avatarUrl (+34 more)

### Community 6 - "macOS Flutter Engine Runner"
Cohesion: 0.07
Nodes (23): Any, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS, FlutterSceneDelegate (+15 more)

### Community 7 - "API Client & REST Networking"
Cohesion: 0.06
Nodes (33): Client, ../constants/api_constants.dart, dart:convert, ApiService, _client, concerts, events, featured (+25 more)

### Community 8 - "User Tickets & Order History"
Cohesion: 0.07
Nodes (32): account_screen.dart, OrderDetailModel, OrderItemModel, build, _checkAuthAndLoadTickets, _completedOrders, createState, _errorMessage (+24 more)

### Community 9 - "Home Page Mock Data & Animation"
Cohesion: 0.07
Nodes (28): Animation, AnimationController, ../data/home_dummy_data.dart, answer, concertEvents, description, faqItems, FaqModel (+20 more)

### Community 10 - "Event Detail Data Model"
Cohesion: 0.07
Nodes (29): 0, bulletDescriptions, category, date, description, EventDetailModel, eventStatus, fromJson (+21 more)

### Community 11 - "API Constants & Endpoint Config"
Cohesion: 0.07
Nodes (27): dart:io, ApiConstants, featuredEvents, landingEvents, listEvents, build, createState, currentEmail (+19 more)

### Community 12 - "Reusable UI Card Components"
Cohesion: 0.09
Nodes (26): _MenuCard, _TicketCard, _TaglineAndSearch, _BottomSection, _OnboardingPage, _EventMetaRow, _HeroBannerSlide, bgColor (+18 more)

### Community 13 - "Linux GTK Engine Integration"
Cohesion: 0.11
Nodes (20): FlView, GApplication, gboolean, gchar, GObject, GtkApplication, main(), first_frame_cb() (+12 more)

### Community 14 - "Profile & Account Management"
Cohesion: 0.09
Nodes (21): CustomClipper, edit_profile_screen.dart, BottomArcClipper, build, _checkAuthAndLoadProfile, createState, _email, getClip (+13 more)

### Community 15 - "Order & Event Data Models"
Cohesion: 0.09
Nodes (21): event_model.dart, 0, createdAt, eventDate, eventName, eventPoster, eventTime, fromJson (+13 more)

### Community 16 - "Event Entity & Schedule Models"
Cohesion: 0.11
Nodes (18): DateTime?, badge, date, eventDate, EventModel, formatIndonesianDate, formatIndonesianTime, fromJson (+10 more)

### Community 17 - "Event List Screen & Cards"
Cohesion: 0.12
Nodes (16): event_card.dart, event_detail_screen.dart, EventListScreen, events, subtitle, title, build, events (+8 more)

### Community 18 - "Password Reset & Recovery UI"
Cohesion: 0.12
Nodes (16): build, code, _confirmPasswordController, createState, dispose, email, _formKey, _handleResetPassword (+8 more)

### Community 19 - "Event Card UI Component"
Cohesion: 0.12
Nodes (15): double?, badge, build, event, EventCard, _EventCardImage, eventDate, _getMonthAbbreviation (+7 more)

### Community 20 - "Flutter Main Entrypoint & Search"
Cohesion: 0.14
Nodes (13): build, main, TicketlyApp, build, controller, onChanged, onTap, TicketlySearchBar (+5 more)

### Community 21 - "User Registration & SSO UI"
Cohesion: 0.14
Nodes (13): build, _buildSSOButton, _confirmPasswordController, createState, dispose, _emailController, _formKey, _handleRegister (+5 more)

### Community 22 - "User Login & Auth UI"
Cohesion: 0.15
Nodes (12): forgot_password_screen.dart, _buildSSOButton, createState, dispose, _emailController, _formKey, _handleLogin, _isLoading (+4 more)

### Community 23 - "Home Page & Splash Screen"
Cohesion: 0.17
Nodes (11): home_page.dart, build, createState, _ctrl, dispose, _fade, initState, _LogoWidget (+3 more)

### Community 24 - "Windows Runner Main Entrypoint"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 25 - "macOS & Web App Icon Assets"
Cohesion: 0.18
Nodes (12): macOS AppIcon 1024x1024, macOS AppIcon 128x128, macOS AppIcon 16x16, macOS AppIcon 256x256, macOS AppIcon 32x32, macOS AppIcon 512x512, macOS AppIcon 64x64, Web Favicon (+4 more)

### Community 26 - "Bottom Navigation Bar Widget"
Cohesion: 0.18
Nodes (10): IconData, activeIcon, build, currentIndex, icon, index, label, _NavItem (+2 more)

### Community 27 - "Web Manifest & PWA Configuration"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 28 - "Android Launcher Icon Assets"
Cohesion: 0.29
Nodes (10): ic_launcher.png (hdpi), launcher_icon.png (hdpi), ic_launcher.png (mdpi), launcher_icon.png (mdpi), ic_launcher.png (xhdpi), launcher_icon.png (xhdpi), ic_launcher.png (xxhdpi), launcher_icon.png (xxhdpi) (+2 more)

### Community 29 - "OTP Verification Screen UI"
Cohesion: 0.20
Nodes (9): Color, build, _controllers, createState, dispose, email, _focusNodes, _isLoading (+1 more)

### Community 30 - "Forgot Password Form UI"
Cohesion: 0.20
Nodes (9): FormState, build, createState, dispose, _emailController, _formKey, _isLoading, ../service/auth_service.dart (+1 more)

### Community 31 - "Checkout & Ticket Navigation"
Cohesion: 0.25
Nodes (8): _navigateToCheckout, build, _handleConfirmEmail, build, build, _buildTicketCard, _handleVerifyCode, MaterialPageRoute

### Community 32 - "Section Header UI Widget"
Cohesion: 0.33
Nodes (5): build, onLihatSemua, SectionHeader, title, VoidCallback?

### Community 33 - "Desktop CMake Build Configurations"
Cohesion: 0.47
Nodes (6): Linux CMake Application Project, Flutter Linux Library Target, Linux Runner Executable Target, Windows CMake Application Project, Flutter Windows C++ Wrapper Target, Windows Runner Executable Target

### Community 34 - "Flutter Project Configuration & Rules"
Cohesion: 0.40
Nodes (5): Flutter Analysis and Linter Options, SVG Iconography Standard, Flutter Assets Configuration, Flutter Dependencies and Plugins, Ticketly Flutter Package Definition

### Community 35 - "App Design System & Typography"
Cohesion: 0.40
Nodes (5): AppColors Design Tokens, AppDimensions Spacing and Radius, App Typography Poppins Hierarchy, Flutter App Design System, Ticket Tier Design and Color Scheme

### Community 36 - "Flutter Widget Test Suite"
Cohesion: 0.40
Nodes (4): package:flutter/material.dart, package:flutter_test/flutter_test.dart, package:ticketly/main.dart, main

### Community 37 - "Backend Architecture & API Standards"
Cohesion: 0.50
Nodes (4): Existing Implementation Priority Principle, API Response Structure Standard, Ticketly Backend Architecture Guidelines, CI4 REST API Integration Map

### Community 39 - "Auth & Security Illustration Assets"
Cohesion: 1.00
Nodes (3): Google Auth Icon SVG, Forgot Password Security Shield Illustration, OTP Verification Key and Shield Illustration

### Community 40 - "Onboarding Illustration Assets"
Cohesion: 0.67
Nodes (3): Onboarding 1 Concert Festival Heart Hands Image, Onboarding 2 K-Pop Concert Lightstick Image, Onboarding 3 Stadium Stage Performance Image

## Knowledge Gaps
- **541 isolated node(s):** `ApiConstants`, `featuredEvents`, `landingEvents`, `listEvents`, `HomeDummyData` (+536 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `EventDetailModel` connect `Event Detail Data Model` to `Checkout State & Processing Logic`, `Event Detail & Checkout Views`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **Why does `FlutterWindow` connect `Windows Runner Native Win32 Layer` to `macOS Flutter Engine Runner`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **What connects `ApiConstants`, `featuredEvents`, `landingEvents` to the rest of the system?**
  _541 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Checkout State & Processing Logic` be split into smaller, more focused modules?**
  _Cohesion score 0.023529411764705882 - nodes in this community are weakly interconnected._
- **Should `Windows Runner Native Win32 Layer` be split into smaller, more focused modules?**
  _Cohesion score 0.05803571428571429 - nodes in this community are weakly interconnected._
- **Should `Flutter Theme & Design Tokens` be split into smaller, more focused modules?**
  _Cohesion score 0.037037037037037035 - nodes in this community are weakly interconnected._
- **Should `Event Detail & Checkout Views` be split into smaller, more focused modules?**
  _Cohesion score 0.038461538461538464 - nodes in this community are weakly interconnected._