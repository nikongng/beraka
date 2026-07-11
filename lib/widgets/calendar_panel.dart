import 'package:flutter/material.dart';


class CalendarPanel extends StatefulWidget {
  final List<dynamic> reservations; // J'utilise dynamic ici pour la compilation, mais gardez votre type original si besoin

  const CalendarPanel({super.key, required this.reservations});

  @override
  State<CalendarPanel> createState() => _CalendarPanelState();
}

class _CalendarPanelState extends State<CalendarPanel> {
  DateTime _visibleMonth = DateTime.now();

  Set<DateTime> get _bookedDays {
    return widget.reservations
        .where((r) => r.status.toLowerCase().contains('confirm'))
        .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
        .toSet();
  }

  void _prevMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  List<DateTime?> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final startWeekday = first.weekday; // 1 = Mon
    final total = last.day;

    final days = <DateTime?>[];

    // fill leading nulls as previous month days (we'll show empty boxes)
    final leading = startWeekday - 1;
    for (var i = 0; i < leading; i++) {
      days.add(null);
    }

    for (var d = 1; d <= total; d++) {
      days.add(DateTime(month.year, month.month, d));
    }

    // ensure full weeks (trailing nulls)
    while (days.length % 7 != 0) {
      days.add(null);
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(_visibleMonth);
    final booked = _bookedDays;
    final today = DateTime.now();

    final upcoming = widget.reservations
        .where((r) => r.status.toLowerCase().contains('confirm'))
        .where((r) => DateTime(r.date.year, r.date.month, r.date.day)
            .isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Détection de la taille de l'écran (si largeur < 800, on considère que c'est un mobile)
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isMobile
              // Disposition MOBILE : On empile (Calendrier en haut, Légende en bas)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendarSection(days, booked, today, isMobile),
                    const SizedBox(height: 32),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 16),
                    _buildLegendSection(upcoming),
                  ],
                )
              // Disposition BUREAU : Côte à côte
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildLegendSection(upcoming),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 3,
                      child: _buildCalendarSection(days, booked, today, isMobile),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLegendSection(List<dynamic> upcoming) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Disponibilités',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(children: [
          Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                  color: Colors.green.shade200, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          const Text('Disponible', style: TextStyle(fontSize: 14)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                  color: Colors.red.shade200, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          const Text('Réservé', style: TextStyle(fontSize: 14)),
        ]),
        const SizedBox(height: 24),
      ],
    );
  }
  Widget _buildCalendarSection(
      List<DateTime?> days, Set<DateTime> booked, DateTime today, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_monthName(_visibleMonth.month)} ${_visibleMonth.year}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Weekday labels
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _WeekdayLabel('Lun'),
            _WeekdayLabel('Mar'),
            _WeekdayLabel('Mer'),
            _WeekdayLabel('Jeu'),
            _WeekdayLabel('Ven'),
            _WeekdayLabel('Sam'),
            _WeekdayLabel('Dim'),
          ],
        ),

        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            // Sur mobile, on fait des cases plus carrées pour la lisibilité
            childAspectRatio: isMobile ? 1.0 : 1.45,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            if (day == null) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }

            final normalized = DateTime(day.year, day.month, day.day);
            final isToday = normalized.year == today.year &&
                normalized.month == today.month &&
                normalized.day == today.day;
            final isBooked = booked.contains(normalized);

            final bgColor = isBooked
                ? Colors.red.shade100
                : (normalized.isBefore(
                        DateTime(today.year, today.month, today.day))
                    ? Colors.grey.shade100
                    : Colors.green.shade50);

            final textColor = isBooked
                ? Colors.red.shade800
                : (normalized.isBefore(
                        DateTime(today.year, today.month, today.day))
                    ? Colors.grey.shade500
                    : Colors.green.shade800);

            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: isToday
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5)
                    : null,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _monthName(int month) {
    const names = [
      '',
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];

    return names[month];
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 12),
        ),
      ),
    );
  }
}