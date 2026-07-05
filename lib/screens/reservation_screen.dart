import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Pour le blur (effets glassmorphism)
import '../data.dart';
import '../models.dart';
import '../services/supabase_service.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({
    super.key,
    required this.onSubmit,
    this.initialMenuPack,
    this.initialEventType,
  });

  final Future<void> Function(Reservation reservation) onSubmit;
  final String? initialMenuPack;
  final String? initialEventType;

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _eventTypes = [
    'Mariage',
    'Anniversaire',
    'Réunion',
    'Conférence',
    'Cérémonie',
    'Autre',
  ];

  static const List<String> _menuPacks = [
    'Pack Basique',
    'Pack Moyenne',
    'Pack VIP',
    'Pack Boissons',
    'Pack Dessert',
  ];

  static const List<String> _fallbackMenuPacks = [
    'Pack Basique',
    'Pack Moyenne',
    'Pack VIP',
    'Pack Boissons',
    'Pack Dessert',
  ];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _people = 4;
  String? _eventType;
  String? _menuPack;
  List<String> _menuPackOptions = _fallbackMenuPacks;
  bool _isLoadingMenuPacks = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  bool _isSubmitting = false;

  // Contrôleur pour les animations d'entrée de la page
  late AnimationController _entranceController;

  // Couleurs Apple
  final Color _iosBackgroundColor = const Color(0xFFF2F2F7);
  final Color _iosSurfaceColor = Colors.white;
  final Color _iosDividerColor = const Color(0xFFC6C6C8);
  final Color _iosBlue = const Color(0xFF007AFF);

  @override
  void initState() {
    super.initState();
    // Initialisation de l'animation d'entrée (durée totale 800ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entranceController.forward(); // Lance l'animation au démarrage
    // Prefill menu pack and event type if provided
    if (widget.initialMenuPack != null) {
      _menuPack = widget.initialMenuPack;
    }
    if (widget.initialEventType != null) {
      _eventType = widget.initialEventType;
    }
    _loadMenuPacks();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadMenuPacks() async {
    try {
      final items = await SupabaseService.fetchMenu();
      final menuNames = items.map((item) => item.name).where((name) => name.isNotEmpty).toSet().toList();
      menuNames.sort();
      if (widget.initialMenuPack != null && widget.initialMenuPack!.isNotEmpty && !menuNames.contains(widget.initialMenuPack)) {
        menuNames.insert(0, widget.initialMenuPack!);
      }
      setState(() {
        _menuPackOptions = menuNames.isNotEmpty ? menuNames : _fallbackMenuPacks;
        _isLoadingMenuPacks = false;
      });
    } catch (_) {
      setState(() {
        _menuPackOptions = _fallbackMenuPacks;
        _isLoadingMenuPacks = false;
      });
    }
  }

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _iosBlue,
              onPrimary: Colors.white,
              surface: _iosSurfaceColor,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(
              // <-- Correction appliquée ici
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    HapticFeedback.selectionClick();
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _iosBlue,
              surface: _iosSurfaceColor,
            ),
            dialogTheme: DialogThemeData(
              // <-- Correction appliquée ici
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _submit() async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _eventType == null ||
        _menuPack == null ||
        _nameController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      HapticFeedback.heavyImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Veuillez remplir la date, l\'heure, le type d\'événement, le menu, votre nom et téléphone.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final noteParts = <String>[];
    noteParts.add('Type d\'événement : ${_eventType!}');
    noteParts.add('Menu souhaité : ${_menuPack!}');
    if (_commentController.text.isNotEmpty) {
      noteParts.add('Notes : ${_commentController.text}');
    }

    final reservation = Reservation(
      id: '',
      guestName: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      date: _selectedDate!,
      time: _selectedTime!,
      guests: _people,
      eventType: _eventType ?? '',
      menuPack: _menuPack ?? '',
      note: noteParts.join('\n'),
      status: 'En attente',
    );

    setState(() => _isSubmitting = true);
    var reservationSuccess = false;

    try {
      await widget.onSubmit(reservation);
      reservationSuccess = true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la réservation : $error'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }

    if (!mounted || !reservationSuccess) return;

    HapticFeedback.heavyImpact();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _people = 4;
    });

    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _commentController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Réservation enregistrée avec succès. Elle est en attente de validation admin.',
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Widget pour animer l'entrée des éléments en cascade (fade + slide up)
  Widget _buildAnimatedSection(
      {required Widget child,
      required double startDelay,
      required double endDelay}) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(startDelay, endDelay, curve: Curves.easeOutCubic),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, childWidget) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(
                0, 30 * (1 - animation.value)), // Glisse de 30px vers le haut
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedSection(
                    startDelay: 0.0,
                    endDelay: 0.4,
                    child: _buildHeader(),
                  ),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(
                    startDelay: 0.2,
                    endDelay: 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('DÉTAILS DE LA RÉSERVATION'),
                        _buildGroupedCard(
                          children: [
                            _buildListTile(
                              icon: Icons.calendar_today_rounded,
                              iconColor: Colors.redAccent,
                              title: 'Date',
                              value: _selectedDate == null
                                  ? 'Choisir'
                                  : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                              onTap: _pickDate,
                            ),
                            _buildDivider(),
                            _buildListTile(
                              icon: Icons.access_time_filled_rounded,
                              iconColor: _iosBlue,
                              title: 'Heure',
                              value: _selectedTime == null
                                  ? 'Choisir'
                                  : _selectedTime!.format(context),
                              onTap: _pickTime,
                            ),
                            _buildDivider(),
                            _buildStepperTile(),
                            _buildDivider(),
                            _buildDropdownField(
                              label: 'Type d\'événement',
                              value: _eventType,
                              options: _eventTypes,
                              onChanged: (value) =>
                                  setState(() => _eventType = value),
                            ),
                            _buildDivider(),
                            _buildDropdownField(
                              label: 'Menu souhaité',
                              value: _menuPack,
                              options: _menuPackOptions,
                              onChanged: (value) =>
                                  setState(() => _menuPack = value),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildCapacityInfo(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildAnimatedSection(
                    startDelay: 0.4,
                    endDelay: 0.8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('VOS COORDONNÉES'),
                        _buildGroupedCard(
                          children: [
                            _buildTextFieldRow(
                              controller: _nameController,
                              label: 'Nom complet',
                              keyboardType: TextInputType.name,
                            ),
                            _buildDivider(),
                            _buildTextFieldRow(
                              controller: _phoneController,
                              label: 'Téléphone',
                              keyboardType: TextInputType.phone,
                            ),
                            _buildDivider(),
                            _buildTextFieldRow(
                              controller: _emailController,
                              label: 'Email (Optionnel)',
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildAnimatedSection(
                    startDelay: 0.5,
                    endDelay: 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('DEMANDE SPÉCIALE'),
                        _buildGroupedCard(
                          children: [
                            _buildTextFieldRow(
                              controller: _commentController,
                              label: 'Allergies, anniversaire, préférences...',
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildAnimatedSection(
                    startDelay: 0.6,
                    endDelay: 1.0,
                    child: _buildSubmitButton(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Réservation',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Préparez votre venue en quelques instants.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 17,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGroupedCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 48),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: _iosDividerColor.withValues(alpha: .5),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                    fontSize: 17,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w400),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _iosBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                // Transition fluide lors du changement de texte !
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    value,
                    key: ValueKey<String>(
                        value), // Clé importante pour l'animation
                    style: TextStyle(
                      fontSize: 17,
                      color: value == 'Choisir' ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      fontWeight: value == 'Choisir'
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepperTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.people_alt_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 16),
          const Text(
            'Personnes',
            style: TextStyle(
                fontSize: 17, color: Colors.black, fontWeight: FontWeight.w400),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: _iosBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildStepperButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (_people > 1) {
                        HapticFeedback.lightImpact();
                        setState(() => _people--);
                      }
                    }),
                SizedBox(
                  width: 32,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Text(
                      '$_people',
                      key: ValueKey<int>(_people),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                _buildStepperButton(
                    icon: Icons.add,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _people++);
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton(
      {required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildTextFieldRow({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(fontSize: 17, color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 17),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: InputDecorator(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 17),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Material(
          color: Colors.transparent,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (value != null && options.contains(value)) ? value : null,
              isExpanded: true,
              hint: Text(
                'Sélectionner $label',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 17),
              ),
              items: options
                  .map(
                    (option) => DropdownMenuItem(
                      value: option,
                      child: Text(option,
                          style: TextStyle(
                              fontSize: 17, color: theme.colorScheme.onSurface)),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCapacityInfo() {
    final theme = Theme.of(context);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          _selectedDate != null && _selectedTime != null
              ? 'Capacité de la salle : ${Pages.hallCapacity} personnes.'
              : 'Sélectionnez une date et une heure pour voir la capacité.',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: _isSubmitting ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSubmitting ? null : _submit,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text(
                      'Confirmer la réservation',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
