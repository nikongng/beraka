import 'package:flutter/material.dart';

import 'package:beraca/models.dart';
import 'package:beraca/responsive/responsive.dart';
import 'package:beraca/theme/app_theme.dart';
import 'package:beraca/widgets/section_title.dart';

class PracticalInfoSection extends StatelessWidget {
  const PracticalInfoSection({
    super.key,
    required this.reservations,
    this.onReserve,
  });

  final List<Reservation> reservations;
  final VoidCallback? onReserve;

  static const List<_PracticalInfo> _infos = [
    _PracticalInfo(
      icon: Icons.location_on_rounded,
      label: "Adresse",
      value: "Avenue du Fleuve, Lubumbashi, RDC",
    ),
    _PracticalInfo(
      icon: Icons.schedule_rounded,
      label: "Horaires",
      value: "7h00 - 17h00 Lundi a vendredi, 8h00 - 12h00 Samedi",
    ),
    _PracticalInfo(
      icon: Icons.phone_rounded,
      label: "Téléphone",
      value: "+243 998 833 016",
    ),
    _PracticalInfo(
      icon: Icons.email_rounded,
      label: "Email",
      value: "beracas@gmail.com.com",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);

    return ResponsiveContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Responsive.sectionSpacing(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              badge: "Infos pratiques",
              title: "Tout savoir avant de venir",
              subtitle:
                  "Retrouvez les coordonnées essentielles de Beraca's Valley et consultez les disponibilités avant de planifier votre événement.",
              textAlign: TextAlign.start,
            ),
            desktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 9,
                        child: _InfoPanel(
                          infos: _infos,
                          onReserve: onReserve,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 11,
                        child: _AvailabilityCalendar(
                          reservations: reservations,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _InfoPanel(
                        infos: _infos,
                        onReserve: onReserve,
                      ),
                      const SizedBox(height: 24),
                      _AvailabilityCalendar(
                        reservations: reservations,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.infos,
    this.onReserve,
  });

  final List<_PracticalInfo> infos;
  final VoidCallback? onReserve;

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(desktop ? 32 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primary.withValues(alpha: .08),
                child: const Icon(
                  Icons.info_rounded,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  "Informations pratiques",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          ...infos.map(
            (info) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _InfoRow(info: info),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppTheme.secondary.withValues(alpha: .28),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Consultez les dates disponibles et réservez votre jour idéal.",
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onReserve,
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text("Réserver une date"),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.info,
  });

  final _PracticalInfo info;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            info.icon,
            color: AppTheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                info.value,
                style: const TextStyle(
                  color: AppTheme.lightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvailabilityCalendar extends StatefulWidget {
  const _AvailabilityCalendar({
    required this.reservations,
  });

  final List<Reservation> reservations;

  @override
  State<_AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<_AvailabilityCalendar> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _visibleMonth = DateTime(now.year, now.month);
    });
  }

  Set<DateTime> get _bookedDates {
    return widget.reservations
        .where((reservation) => !_isCancelled(reservation.status))
        .map((reservation) => _dateOnly(reservation.date))
        .toSet();
  }

  int get _daysInMonth {
    return DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
  }

  int get _availableCount {
    var count = 0;
    for (var day = 1; day <= _daysInMonth; day++) {
      final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
      if (_isAvailable(date)) count++;
    }
    return count;
  }

  int get _unavailableCount => _daysInMonth - _availableCount;

  bool _isAvailable(DateTime date) {
    final day = _dateOnly(date);
    final today = _dateOnly(DateTime.now());
    return !day.isBefore(today) && !_bookedDates.contains(day);
  }

  bool _isCancelled(String status) {
    final normalized = status.toLowerCase();
    return normalized.contains('annul') || normalized.contains('cancel');
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = _monthName(_visibleMonth.month);
    final year = _visibleMonth.year;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.isDesktop(context) ? 28 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Calendrier des disponibilités",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Vert : disponible  |  Rouge : non disponible",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: "Mois précédent",
                child: IconButton.filledTonal(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: "Mois suivant",
                child: IconButton.filledTonal(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.lightBackground,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      "${_capitalize(monthLabel)} $year",
                      key: ValueKey("$monthLabel-$year"),
                      style: const TextStyle(
                        color: AppTheme.lightText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _goToToday,
                  icon: const Icon(Icons.today_rounded, size: 18),
                  label: const Text("Aujourd'hui"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              _WeekdayLabel("L"),
              _WeekdayLabel("M"),
              _WeekdayLabel("M"),
              _WeekdayLabel("J"),
              _WeekdayLabel("V"),
              _WeekdayLabel("S"),
              _WeekdayLabel("D"),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(.04, 0),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            child: _CalendarGrid(
              key: ValueKey("${_visibleMonth.year}-${_visibleMonth.month}"),
              visibleMonth: _visibleMonth,
              bookedDates: _bookedDates,
              isAvailable: _isAvailable,
              dateOnly: _dateOnly,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _LegendPill(
                color: AppTheme.success,
                label: "$_availableCount dates dispo",
              ),
              _LegendPill(
                color: AppTheme.danger,
                label: "$_unavailableCount dates non dispo",
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      "",
      "janvier",
      "février",
      "mars",
      "avril",
      "mai",
      "juin",
      "juillet",
      "août",
      "septembre",
      "octobre",
      "novembre",
      "decembre",
    ];
    return names[month];
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    super.key,
    required this.visibleMonth,
    required this.bookedDates,
    required this.isAvailable,
    required this.dateOnly,
  });

  final DateTime visibleMonth;
  final Set<DateTime> bookedDates;
  final bool Function(DateTime date) isAvailable;
  final DateTime Function(DateTime date) dateOnly;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month);
    final leadingBlanks = firstDay.weekday - 1;
    final daysInMonth =
        DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final itemCount = leadingBlanks + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: Responsive.isMobile(context) ? 6 : 8,
        crossAxisSpacing: Responsive.isMobile(context) ? 6 : 8,
      ),
      itemBuilder: (context, index) {
        if (index < leadingBlanks) {
          return const SizedBox.shrink();
        }

        final day = index - leadingBlanks + 1;
        final date = DateTime(visibleMonth.year, visibleMonth.month, day);
        final normalizedDate = dateOnly(date);
        final today = dateOnly(DateTime.now());
        final booked = bookedDates.contains(normalizedDate);
        final available = isAvailable(date);
        final past = normalizedDate.isBefore(today);

        return _CalendarDay(
          date: date,
          available: available,
          booked: booked,
          past: past,
          today: normalizedDate == today,
        );
      },
    );
  }
}

class _CalendarDay extends StatefulWidget {
  const _CalendarDay({
    required this.date,
    required this.available,
    required this.booked,
    required this.past,
    required this.today,
  });

  final DateTime date;
  final bool available;
  final bool booked;
  final bool past;
  final bool today;

  @override
  State<_CalendarDay> createState() => _CalendarDayState();
}

class _CalendarDayState extends State<_CalendarDay> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.available ? AppTheme.success : AppTheme.danger;
    final label = widget.past
        ? "Date passée"
        : widget.booked
            ? "Non disponible"
            : "Disponible";

    return Tooltip(
      message: "${_formatDate(widget.date)} - $label",
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.92, end: 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: color.withValues(alpha: _hover ? .22 : .14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.today
                    ? AppTheme.primary
                    : color.withValues(alpha: _hover ? .75 : .45),
                width: widget.today ? 2 : 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  widget.date.day.toString(),
                  style: TextStyle(
                    color: widget.available
                        ? AppTheme.success
                        : AppTheme.danger,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Positioned(
                  right: 7,
                  bottom: 7,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return "$day/$month/${date.year}";
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _LegendPill extends StatelessWidget {
  const _LegendPill({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticalInfo {
  const _PracticalInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
