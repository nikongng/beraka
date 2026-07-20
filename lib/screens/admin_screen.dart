import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:beraca/theme/app_theme.dart';

import '../models.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';
import 'admin_reservations_screen.dart';
import 'admin_gallery_screen.dart';
import 'admin_packs_screen.dart';
import 'admin_apartments_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isAdmin = false;
  String? _userEmail;
  List<Reservation> _reservations = [];

  @override
  void initState() {
    super.initState();
    _checkAdminSession();
  }

  Widget _adminCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 320,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkAdminSession() async {
    final user = currentSupabaseUser();
    if (user != null && currentUserIsAdmin()) {
      setState(() {
        _isAdmin = true;
        _userEmail = user.email;
      });
      await _loadReservations();
    }
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _reservations = await SupabaseService.fetchReservations();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Impossible de charger les réservations : $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildAdminPanel() {
    final total = _reservations.length;
    final upcoming = _reservations
        .where((r) => _reservationDateTime(r).isAfter(DateTime.now()))
        .length;
    final confirmed = _reservations
        .where((r) => r.status.toLowerCase().contains('confirm'))
        .length;

    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 420;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Connecté comme : ${_userEmail ?? 'admin'}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 16),
        Row(
          children: [
            // Smaller buttons on phones
            if (isPhone) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _loadReservations,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Rafraîchir'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10), textStyle: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                color: Theme.of(context).colorScheme.error,
                tooltip: 'Se déconnecter',
              ),
            ] else ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _loadReservations,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Rafraîchir'),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              ),
            ]
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading) const LinearProgressIndicator(),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _adminStatCard(
                'Réservations totales', total.toString(), Icons.event_note),
            _adminStatCard(
                'À venir', upcoming.toString(), Icons.calendar_month),
            _adminStatCard(
                'Confirmées', confirmed.toString(), Icons.check_circle),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        Text('Administration rapide',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        Text(
          'Utilisez les écrans dédiés pour gérer les packs, la galerie et les appartements.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _adminCard(context, 'Réservations', Icons.event_note, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminReservationsScreen()))),
            _adminCard(context, 'Galerie', Icons.photo_library, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminGalleryScreen()))),
            _adminCard(context, 'Packs', Icons.card_giftcard, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminPacksScreen()))),
            _adminCard(context, 'Appartements', Icons.apartment, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminApartmentsScreen()))),
          ],
        ),
      ],
    );
  }

  Widget _adminStatCard(String label, String value, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 420;
    final cardWidth = isPhone ? (screenWidth - 48) / 2 : 180;
    return Container(
      width: cardWidth.toDouble(),
      padding: EdgeInsets.all(isPhone ? 12 : 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: isPhone ? 6 : 12,
              offset: isPhone ? const Offset(0, 3) : const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: isPhone ? 24 : 32),
          SizedBox(height: isPhone ? 8 : 16),
          Text(value,
              style:
                  TextStyle(fontSize: isPhone ? 20 : 28, fontWeight: FontWeight.bold)),
          SizedBox(height: isPhone ? 6 : 8),
          Text(label,
              style: TextStyle(fontSize: isPhone ? 12 : 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  DateTime _reservationDateTime(Reservation reservation) {
    return DateTime(
      reservation.date.year,
      reservation.date.month,
      reservation.date.day,
      reservation.time.hour,
      reservation.time.minute,
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!success || !currentUserIsAdmin()) {
        await signOut();
        throw 'Compte admin non autorisé.';
      }

      setState(() {
        _isAdmin = true;
        _userEmail = currentSupabaseUser()?.email;
      });
      await _loadReservations();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion admin réussie.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion : $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await signOut();
      if (!mounted) return;
      setState(() {
        _isAdmin = false;
        _userEmail = null;
        _reservations = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déconnexion réussie.')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion : $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openAssistantPanel() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assistant IA Beraca',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Générez une réponse naturelle et personnalisée avec Gemini Flash.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              _assistantActionCard(
                title: 'Réponse à une réservation',
                subtitle: 'Produit une réponse chaleureuse pour un client qui a réservé ou demandé une place.',
                onGenerate: () async {
                  final reservation = _reservations.isNotEmpty ? _reservations.first : null;
                  final contextText = reservation == null
                      ? 'Le client a demandé une réservation au restaurant Beraca\'s Valley.'
                      : 'Réservation du client ${reservation.guestName} pour ${reservation.date.day}/${reservation.date.month}/${reservation.date.year} à ${reservation.time.format(context)} pour ${reservation.guests} personnes.';
                  return GeminiService.generateReply(
                    context: contextText,
                    request: 'Rédige une réponse professionnelle, chaleureuse et concise pour confirmer ou remercier la réservation.',
                  );
                },
              ),
              const SizedBox(height: 12),
              _assistantActionCard(
                title: 'Présentation de Beraca\'s Valley',
                subtitle: 'Génère une proposition élégante pour présenter le lieu à un client.',
                onGenerate: () async {
                  return GeminiService.generateReply(
                    context: 'Beraca\'s Valley est une salle de reception de charme, avec une ambiance chaleureuse, une cuisine raffinée et un cadre idéal pour les repas, les événements et les séjours.',
                    request: 'Rédige une réponse convaincante et naturelle pour présenter Beraca\'s Valley à un client potentiel.',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _assistantActionCard({
    required String title,
    required String subtitle,
    required Future<String> Function() onGenerate,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final generated = await onGenerate();
                    await Clipboard.setData(ClipboardData(text: generated));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Réponse générée et copiée.')),
                    );
                  } catch (error) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur d’IA : $error')),
                    );
                  }
                },
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Générer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Beraca'),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Déconnexion',
              onPressed: _logout,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _isAdmin
            ? SingleChildScrollView(
                child: _buildAdminPanel(),
              )
            : _buildLoginForm(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAssistantPanel,
        tooltip: 'Assistant IA',
        backgroundColor: AppTheme.primary,
        child: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Connexion admin',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email admin'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Mot de passe'),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Se connecter'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}