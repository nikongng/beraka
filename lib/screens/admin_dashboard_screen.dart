import 'package:flutter/material.dart';

import 'package:beraka_hotel_restaurant/theme/app_theme.dart';

// --- STREAMS & EFFECT REQUIS POUR LE LOOK PREMIUM ---

/// Widget d'animation pour l'apparition fluide et décalée des composants
class _FadeSlideTransition extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _FadeSlideTransition({
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<_FadeSlideTransition> createState() => _FadeSlideTransitionState();
}

class _FadeSlideTransitionState extends State<_FadeSlideTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _offsetAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Widget personnalisé créant un effet de pulsation fluide pour le chargement squelette (sans package externe)
class _PulsingSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _PulsingSkeleton({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<_PulsingSkeleton> createState() => _PulsingSkeletonState();
}

class _PulsingSkeletonState extends State<_PulsingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  List<Reservation> _reservations = [];
  String _activeFilter = 'TOUTES';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _reservations = await SupabaseService.fetchReservations();
      _reservations.sort((a, b) => _reservationDateTime(b).compareTo(_reservationDateTime(a)));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $error'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        // Ajoute un léger délai artificiel pour apprécier la fluidité du squelette
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() => _isLoading = false);
      }
    }
  }

  int get totalReservations => _reservations.length;
  
  int get upcomingReservations => _reservations
      .where((r) => _reservationDateTime(r).isAfter(DateTime.now()))
      .length;
      
  int get pastReservations => _reservations
      .where((r) => _reservationDateTime(r).isBefore(DateTime.now()))
      .length;
      
  int get confirmedReservations => _reservations
      .where((r) => r.status.toLowerCase().contains('confirm'))
      .length;

  List<Reservation> get _filteredReservations {
    if (_activeFilter == 'TOUTES') return _reservations;
    return _reservations.where((r) {
      final status = r.status.toLowerCase();
      if (_activeFilter == 'CONFIRMÉES') return status.contains('confirm');
      if (_activeFilter == 'EN ATTENTE') return status.contains('attent') || status.contains('pending');
      if (_activeFilter == 'ANNULÉES') return status.contains('annul') || status.contains('cancel');
      return true;
    }).toList();
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

  void _showReservationDetails(Reservation reservation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      builder: (context) {
        final dateStr = '${reservation.date.day.toString().padLeft(2, '0')}/${reservation.date.month.toString().padLeft(2, '0')}/${reservation.date.year}';
        final timeStr = reservation.time.format(context);
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicateur de drag
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Détails de la réservation',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.darkBackground),
                  ),
                  _StatusBadge(status: reservation.status),
                ],
              ),
              const SizedBox(height: 24),
              
              // Profil Client
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      reservation.guestName.isNotEmpty ? reservation.guestName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.guestName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.darkBackground),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID de la réservation : #BKV-${reservation.guestName.hashCode.toString().substring(0, 4)}',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 24),

              // Détails clés
              _DetailRow(icon: Icons.calendar_today_rounded, label: 'Date', value: dateStr),
              const SizedBox(height: 16),
              _DetailRow(icon: Icons.access_time_rounded, label: 'Heure', value: timeStr),
              const SizedBox(height: 16),
              _DetailRow(icon: Icons.people_outline_rounded, label: 'Invités', value: '${reservation.guests} personnes'),
              
              const SizedBox(height: 32),
              
              // Actions interactives animées
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.5),
                      ),
                      child: Text('Fermer', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Statut de la réservation de ${reservation.guestName} mis à jour !'),
                            backgroundColor: AppTheme.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Confirmer', style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. En-tête Dynamique
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 90,
              title: _FadeSlideTransition(
                delay: const Duration(milliseconds: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vue d\'ensemble',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Gérez vos réservations et statistiques en temps réel',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                _FadeSlideTransition(
                  delay: const Duration(milliseconds: 100),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                      child: Icon(Icons.admin_panel_settings, color: theme.colorScheme.primary),
                    ),
                  ),
                )
              ],
            ),

            // 2. Grille de Statistiques avec Animations Décalées
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isDesktop ? 1.7 : 2.1,
                ),
                delegate: SliverChildListDelegate([
                  _FadeSlideTransition(
                    delay: const Duration(milliseconds: 100),
                    child: _StatCard(
                      title: 'Réservations totales',
                      value: totalReservations.toString(),
                      icon: Icons.event_note_rounded,
                      color: theme.colorScheme.primary,
                      trend: '+12%',
                    ),
                  ),
                  _FadeSlideTransition(
                    delay: const Duration(milliseconds: 180),
                    child: _StatCard(
                      title: 'À venir',
                      value: upcomingReservations.toString(),
                      icon: Icons.hourglass_top_rounded,
                      color: AppTheme.warning,
                      trend: 'Stable',
                    ),
                  ),
                  _FadeSlideTransition(
                    delay: const Duration(milliseconds: 260),
                    child: _StatCard(
                      title: 'Passées',
                      value: pastReservations.toString(),
                      icon: Icons.history_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  _FadeSlideTransition(
                    delay: const Duration(milliseconds: 340),
                    child: _StatCard(
                      title: 'Confirmées',
                      value: confirmedReservations.toString(),
                      icon: Icons.check_circle_outline_rounded,
                      color: AppTheme.success,
                      trend: '+8%',
                    ),
                  ),
                ]),
              ),
            ),

            // 3. Sélecteur de filtres interactif
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              sliver: SliverToBoxAdapter(
                child: _FadeSlideTransition(
                  delay: const Duration(milliseconds: 400),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['TOUTES', 'CONFIRMÉES', 'EN ATTENTE', 'ANNULÉES'].map((filter) {
                        final isActive = _activeFilter == filter;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _activeFilter = filter);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isActive ? theme.colorScheme.onSurface : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive ? Colors.transparent : theme.colorScheme.outlineVariant,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            // 4. Titre de la liste des réservations
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              sliver: SliverToBoxAdapter(
                child: _FadeSlideTransition(
                  delay: const Duration(milliseconds: 450),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Réservations Récentes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadData,
                        icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
                        tooltip: 'Rafraîchir',
                      )
                    ],
                  ),
                ),
              ),
            ),

            // 5. Contenu dynamique : chargement squelette, vide ou liste animée
            if (_isLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: _SkeletonReservationTile(),
                    ),
                    childCount: 5,
                  ),
                ),
              )
            else if (_filteredReservations.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded, size: 64, color: theme.colorScheme.surfaceContainerHighest),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune réservation trouvée',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Créer un délai décalé pour chaque tuile
                      final delay = Duration(milliseconds: 100 + (index * 50));
                      return _FadeSlideTransition(
                        delay: delay,
                        child: _ReservationTile(
                          reservation: _filteredReservations[index],
                          onTap: () => _showReservationDetails(_filteredReservations[index]),
                        ),
                      );
                    },
                    childCount: _filteredReservations.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered ? widget.color.withValues(alpha: 0.3) : Theme.of(context).colorScheme.outlineVariant,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _isHovered ? 0.12 : 0.03),
              blurRadius: _isHovered ? 24 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icone ronde sophistiquée
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: widget.color, size: 28),
            ),
            const SizedBox(width: 16),
            // Textes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        widget.value,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (widget.trend != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.trend!.contains('+') 
                              ? AppTheme.success.withValues(alpha: 0.1)
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.trend!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: widget.trend!.contains('+') 
                                ? AppTheme.success
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationTile extends StatefulWidget {
  final Reservation reservation;
  final VoidCallback onTap;

  const _ReservationTile({
    required this.reservation,
    required this.onTap,
  });

  @override
  State<_ReservationTile> createState() => _ReservationTileState();
}

class _ReservationTileState extends State<_ReservationTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = '${widget.reservation.date.day.toString().padLeft(2, '0')}/${widget.reservation.date.month.toString().padLeft(2, '0')}/${widget.reservation.date.year}';
    final timeStr = widget.reservation.time.format(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? theme.colorScheme.primary.withValues(alpha: 0.25) : theme.colorScheme.outlineVariant,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: _isHovered ? 0.04 : 0.01),
                blurRadius: _isHovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar stylé
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                foregroundColor: theme.colorScheme.primary,
                child: Text(
                  widget.reservation.guestName.isNotEmpty ? widget.reservation.guestName[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 16),
              // Détails textuels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reservation.guestName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 13, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '$dateStr à $timeStr',
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.people_alt_rounded, size: 13, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.reservation.guests} pers.',
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Statut stylé
              _StatusBadge(status: widget.reservation.status),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text = status.toUpperCase();
    final theme = Theme.of(context);

    final statusLower = status.toLowerCase();
    if (statusLower.contains('confirm')) {
      bgColor = AppTheme.success.withValues(alpha: 0.12);
      textColor = AppTheme.success;
    } else if (statusLower.contains('attent') || statusLower.contains('pending')) {
      bgColor = AppTheme.warning.withValues(alpha: 0.12);
      textColor = AppTheme.warning;
    } else if (statusLower.contains('annul') || statusLower.contains('cancel')) {
      bgColor = AppTheme.danger.withValues(alpha: 0.12);
      textColor = AppTheme.danger;
    } else {
      bgColor = theme.colorScheme.surfaceContainerHighest;
      textColor = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Squelette de chargement pour la liste des réservations
class _SkeletonReservationTile extends StatelessWidget {
  const _SkeletonReservationTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: const Row(
        children: [
          _PulsingSkeleton(width: 44, height: 44, borderRadius: 22),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PulsingSkeleton(width: 120, height: 16),
                SizedBox(height: 8),
                Row(
                  children: [
                    _PulsingSkeleton(width: 80, height: 12),
                    SizedBox(width: 12),
                    _PulsingSkeleton(width: 50, height: 12),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          _PulsingSkeleton(width: 70, height: 24, borderRadius: 20),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }
}

// ============================================================================
// MOCKS (CLASSES SIMULÉES) - À RETIRER À L'INTÉGRATION SUPABASE FINALE
// ============================================================================

class Reservation {
  final String guestName;
  final int guests;
  final DateTime date;
  final TimeOfDay time;
  final String status;

  Reservation({
    required this.guestName,
    required this.guests,
    required this.date,
    required this.time,
    required this.status,
  });
}

class SupabaseService {
  static Future<List<Reservation>> fetchReservations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      Reservation(guestName: 'Jean Dupont', guests: 4, date: DateTime.now().add(const Duration(days: 1)), time: const TimeOfDay(hour: 19, minute: 30), status: 'Confirmée'),
      Reservation(guestName: 'Marie Curie', guests: 2, date: DateTime.now().add(const Duration(days: 2)), time: const TimeOfDay(hour: 20, minute: 00), status: 'En attente'),
      Reservation(guestName: 'Elon Musk', guests: 10, date: DateTime.now().subtract(const Duration(days: 1)), time: const TimeOfDay(hour: 12, minute: 00), status: 'Passée'),
      Reservation(guestName: 'Ada Lovelace', guests: 6, date: DateTime.now().add(const Duration(days: 5)), time: const TimeOfDay(hour: 18, minute: 45), status: 'Confirmée'),
      Reservation(guestName: 'Steve Jobs', guests: 1, date: DateTime.now().subtract(const Duration(days: 3)), time: const TimeOfDay(hour: 14, minute: 15), status: 'Annulée'),
    ];
  }
}