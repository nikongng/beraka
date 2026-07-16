import 'package:flutter/material.dart';

import '../models.dart';
import '../services/supabase_service.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() => _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  bool _isLoading = true;
  bool _isMoreLoading = false;
  bool _isSaving = false;
  final int _pageSize = 30;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController(text: '4');
  final TextEditingController _noteController = TextEditingController();
  final List<String> _eventTypes = [
    'Mariage',
    'Anniversaire',
    'Réunion',
    'Conférence',
    'Cérémonie',
    'Cocktail',
    'Autre',
  ];
  String? _selectedEventType = 'Mariage';
  String? _selectedMenuPack;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<Reservation> _reservations = [];
  List<Dish> _menuItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadReservations(), _loadMenuItems()]);
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    try {
      _reservations = await SupabaseService.fetchReservationsPaged(from: 0, limit: _pageSize);
    } catch (_) {
      _reservations = [];
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadMenuItems() async {
    try {
      _menuItems = await SupabaseService.fetchMenu();
    } catch (_) {
      _menuItems = [];
    }
  }

  Future<void> _loadMore() async {
    if (_isMoreLoading) return;
    setState(() => _isMoreLoading = true);
    try {
      final more = await SupabaseService.fetchReservationsPaged(from: _reservations.length, limit: _pageSize);
      if (more.isNotEmpty) {
        setState(() => _reservations.addAll(more));
      }
    } catch (_) {}
    setState(() => _isMoreLoading = false);
  }

  Reservation? get _latestReservation {
    if (_reservations.isEmpty) return null;
    return _reservations.reduce((a, b) {
      final aDate = DateTime(a.date.year, a.date.month, a.date.day, a.time.hour, a.time.minute);
      final bDate = DateTime(b.date.year, b.date.month, b.date.day, b.time.hour, b.time.minute);
      return aDate.isAfter(bDate) ? a : b;
    });
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      locale: const Locale('fr', 'FR'),
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selectedDate != null) {
      setState(() => _selectedDate = selectedDate);
    }
  }

  Future<void> _pickTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
    );
    if (selectedTime != null) {
      setState(() => _selectedTime = selectedTime);
    }
  }

  Future<void> _createReservation() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final guests = int.tryParse(_guestsController.text.trim()) ?? 1;
    final eventType = _selectedEventType ?? 'Autre';
    final menuPack = _selectedMenuPack ?? '';
    final note = _noteController.text.trim();

    if (name.isEmpty || phone.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplissez le nom, le téléphone, la date et l’heure.')),
      );
      return;
    }

    if (guests <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indiquez un nombre de personnes valide.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final reservation = Reservation(
        id: '',
        guestName: name,
        phone: phone,
        email: email,
        date: _selectedDate!,
        time: _selectedTime!,
        guests: guests,
        eventType: eventType,
        menuPack: menuPack,
        note: note.isEmpty ? 'Réservation créée par l’admin.' : 'Réservation créée par l’admin.\n$note',
        status: 'Confirmée',
      );
      final created = await SupabaseService.createReservation(reservation);
      setState(() {
        _reservations.insert(0, created);
        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _guestsController.text = '4';
        _noteController.clear();
        _selectedEventType = 'Mariage';
        _selectedMenuPack = null;
        _selectedDate = null;
        _selectedTime = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation créée avec succès.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création : $error')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _cancelReservation(String reservationId) async {
    setState(() => _isSaving = true);
    try {
      await SupabaseService.cancelReservation(reservationId);
      setState(() {
        _reservations.removeWhere((reservation) => reservation.id == reservationId);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation annulée.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d’annuler la réservation : $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showReservationDetails(Reservation reservation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      builder: (context) {
        final dateString = '${reservation.date.day.toString().padLeft(2, '0')}/${reservation.date.month.toString().padLeft(2, '0')}/${reservation.date.year}';
        final timeString = reservation.time.format(context);
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Détails de la réservation', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Client : ${reservation.guestName}'),
              const SizedBox(height: 8),
              Text('Téléphone : ${reservation.phone}'),
              if (reservation.email.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Email : ${reservation.email}'),
              ],
              const SizedBox(height: 8),
              Text('Date : $dateString'),
              const SizedBox(height: 8),
              Text('Heure : $timeString'),
              const SizedBox(height: 8),
              Text('Invités : ${reservation.guests}'),
              const SizedBox(height: 8),
              Text('Événement : ${reservation.eventType}'),
              if (reservation.menuPack.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Pack : ${reservation.menuPack}'),
              ],
              const SizedBox(height: 8),
              Text('Statut : ${reservation.status}'),
              if (reservation.note.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Notes :', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(reservation.note),
              ],
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _guestsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réservations')),
      body: RefreshIndicator(
        onRefresh: _loadReservations,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Créer une réservation',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: 'Nom du client'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(labelText: 'Téléphone'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: 'Email (facultatif)'),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedEventType,
                                    decoration: const InputDecoration(labelText: 'Type d’événement'),
                                    items: _eventTypes
                                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                        .toList(),
                                    onChanged: (value) => setState(() => _selectedEventType = value),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedMenuPack,
                                    decoration: const InputDecoration(labelText: 'Menu pack'),
                                    items: _menuItems
                                        .map((item) => DropdownMenuItem(value: item.name, child: Text(item.name)))
                                        .toList(),
                                    onChanged: (value) => setState(() => _selectedMenuPack = value),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _pickDate,
                                    child: Text(_selectedDate == null
                                        ? 'Choisir une date'
                                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _pickTime,
                                    child: Text(_selectedTime == null
                                        ? 'Choisir une heure'
                                        : _selectedTime!.format(context)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _guestsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Nombre de personnes'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _noteController,
                              decoration: const InputDecoration(labelText: 'Notes supplémentaires'),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _isSaving ? null : _createReservation,
                              child: _isSaving
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Créer la réservation'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dernière réservation',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            if (_latestReservation == null)
                              Text('Aucune réservation trouvée.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
                            else
                              ListTile(
                                title: Text('${_latestReservation!.guestName} • ${_latestReservation!.guests} personnes'),
                                subtitle: Text('${_latestReservation!.date.day}/${_latestReservation!.date.month}/${_latestReservation!.date.year} - ${_latestReservation!.time.format(context)}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () => _showReservationDetails(_latestReservation!),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Liste des réservations', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (_reservations.isEmpty)
                      Center(child: Text('Aucune réservation disponible.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _reservations.length + 1,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          if (index == _reservations.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: _isMoreLoading
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton(
                                        onPressed: _loadMore,
                                        child: const Text('Charger plus'),
                                      ),
                              ),
                            );
                          }
                          final r = _reservations[index];
                          return ListTile(
                            title: Text('${r.guestName} • ${r.guests} personnes'),
                            subtitle: Text('${r.date.day}/${r.date.month}/${r.date.year} - ${r.time.format(context)}'),
                            onTap: () => _showReservationDetails(r),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'details') {
                                  _showReservationDetails(r);
                                } else if (value == 'cancel') {
                                  _cancelReservation(r.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'details', child: Text('Voir détails')),
                                PopupMenuItem(value: 'cancel', child: Text(r.isCancelled ? 'Réserv. déjà annulée' : 'Annuler la réservation')),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
