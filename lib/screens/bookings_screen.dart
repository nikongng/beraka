import 'package:flutter/material.dart';
import '../models.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({
    super.key,
    required this.reservations,
    required this.onCancel,
  });

  final List<Reservation> reservations;
  final Future<void> Function(Reservation) onCancel;

  String _monthName(int month) {
    const names = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return names[month];
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

  // Permet de donner une couleur au badge selon le texte du statut
  Color _getStatusColor(String status, BuildContext context) {
    final s = status.toLowerCase();
    final theme = Theme.of(context);
    if (s.contains('confirm')) return theme.colorScheme.primary;
    if (s.contains('attent')) return theme.colorScheme.secondary;
    if (s.contains('annul') || s.contains('refus')) return theme.colorScheme.error;
    return theme.colorScheme.outline;
  }

  Widget _buildStatusBadge(String status, BuildContext context) {
    final color = _getStatusColor(status, context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _reservationCard(BuildContext context, Reservation reservation, bool canCancel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de la carte : Date, Heure et Badge de statut
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${reservation.date.day} ${_monthName(reservation.date.month)} ${reservation.date.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'À ${reservation.time.format(context)} • ${reservation.guests} personne(s)',
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(reservation.status, context),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),

            // Détails du client
            _buildDetailRow(context, Icons.person_outline, 'Nom', reservation.guestName),
            const SizedBox(height: 10),
            _buildDetailRow(context, Icons.phone_outlined, 'Téléphone', reservation.phone),
            
            if (reservation.email.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildDetailRow(context, Icons.email_outlined, 'Email', reservation.email),
            ],

            if (reservation.note.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, size: 18, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reservation.note,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Réf: #${reservation.id}',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                if (canCancel)
                  OutlinedButton.icon(
                    onPressed: () => onCancel(reservation),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Annuler la réservation'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Petit widget d'aide pour afficher une icône + label + valeur
  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label : ',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = reservations.where((r) => _reservationDateTime(r).isAfter(DateTime.now())).toList();
    final history = reservations.where((r) => _reservationDateTime(r).isBefore(DateTime.now())).toList();

    return SingleChildScrollView( // <-- Ajout crucial pour permettre le défilement !
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Empêche d'être trop large sur PC
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre de la page
              const Text(
                'Mes réservations',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Section : À venir
              Row(
                children: [
                  Icon(Icons.event_available_rounded, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'À venir (${upcoming.length})',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (upcoming.isEmpty) 
                _buildEmptyState(context, 'Vous n\'avez aucune réservation prévue pour le moment.', Icons.event_busy_rounded)
              else 
                ...upcoming.map((reservation) => _reservationCard(context, reservation, true)),
              
              const SizedBox(height: 48),
              
              // Section : Historique
              Row(
                children: [
                  Icon(Icons.history_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Historique (${history.length})',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (history.isEmpty) 
                _buildEmptyState(context, 'Votre historique de réservations est vide.', Icons.history_toggle_off_rounded)
              else 
                ...history.map((reservation) => _reservationCard(context, reservation, false)),
            ],
          ),
        ),
      ),
    );
  }
}