import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'models.dart';
import 'services/gemini_service.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/apartments_screen.dart';
import 'screens/reservation_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/about_screen.dart';
import 'screens/admin_screen.dart';
import 'widgets/modern_app_bar.dart';
import 'widgets/modern_bottom_nav.dart';
import 'widgets/modern_drawer.dart';
import 'widgets/visitor_assistant.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GeminiService.loadConfig();
  await initSupabase();

  runApp(const BerakaApp());
}

class BerakaApp extends StatelessWidget {
  const BerakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Beraca's valley",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
      routes: {
        '/admin': (_) => const AdminScreen(),
        '/about': (_) => const AboutScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  bool _isLoading = true;
  bool _showBottomNav = true;

  final List<Reservation> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      final reservations = await SupabaseService.fetchReservations();

      if (!mounted) return;

      setState(() {
        _reservations
          ..clear()
          ..addAll(reservations);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors du chargement des réservations : $e",
          ),
        ),
      );
    }
  }

  void _onNavigate(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _onSubmitReservation(
    Reservation reservation,
  ) async {
    try {
      final saved = await SupabaseService.createReservation(
        reservation,
      );

      if (!mounted) return;

      setState(() {
        _reservations.add(saved);
        // Redirige vers l'accueil ou garde la page de réservation selon le besoin
        _currentIndex = 0; 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Réservation enregistrée : ${saved.id} (en attente de validation)",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors de la réservation : $e",
          ),
        ),
      );
    }
  }

  Future<void> _onCancelReservation(
    Reservation reservation,
  ) async {
    try {
      await SupabaseService.cancelReservation(
        reservation.id,
      );

      if (!mounted) return;

      setState(() {
        _reservations.removeWhere(
          (r) => r.id == reservation.id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Réservation annulée.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors de l'annulation : $e",
          ),
        ),
      );
    }
  }

  void _showAssistantSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
          child: VisitorAssistant(
            reservations: _reservations,
            onReserve: () {
              Navigator.pop(sheetContext);
              setState(() {
                _currentIndex = 2;
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // CORRECTION ICI : La liste des pages correspond maintenant exactement 
    // aux 5 index de votre ModernBottomNav. L'index 4 ouvre bien le ContactScreen.
    final pages = <Widget>[
      HomeScreen(
        currentIndex: _currentIndex,
        onNavigate: _onNavigate,
        reservations: _reservations,
      ),                                     // Index 0 : Accueil
      const MenuScreen(),                    // Index 1 : Menu
      ReservationScreen(
        onSubmit: _onSubmitReservation,
      ),                                     // Index 2 : Je réserve
      const ApartmentsScreen(),              // Index 3 : Appartements
      const ContactScreen(),                 // Index 4 : Contact
    ];

    return Scaffold(
      extendBody: true,
      appBar: ModernAppBar(
        currentIndex: _currentIndex,
        onNavigate: _onNavigate,
        onAbout: () {
          Navigator.pushNamed(context, "/about");
        },
        onAdmin: () async {
          await Navigator.pushNamed(context, "/admin");
          await _loadReservations();
        },
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification) {
                  final direction = notification.direction;

                  if (direction == ScrollDirection.forward && !_showBottomNav) {
                    setState(() {
                      _showBottomNav = true;
                    });
                  } else if (direction == ScrollDirection.reverse &&
                      _showBottomNav) {
                    setState(() {
                      _showBottomNav = false;
                    });
                  }
                }
                return false;
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(_currentIndex),
                  child: pages[_currentIndex],
                ),
              ),
            ),
      bottomNavigationBar: AnimatedSlide(
        offset: _showBottomNav ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _showBottomNav ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: ModernBottomNav(
            currentIndex: _currentIndex,
            onTap: _onNavigate,
          ),
        ),
      ),
      endDrawer: ModernDrawer(
        currentIndex: _currentIndex,
        onNavigate: _onNavigate,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAssistantSheet,
        tooltip: 'Assistant IA',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.onPrimary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}