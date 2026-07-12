import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'voice_platform.dart';
import '../models.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';

String? buildCapacityReply({
  required String request,
  required int maxCapacity,
  required double perGuestBasePrice,
  required Map<String, double> packageFlatPriceNumeric,
  required bool asksPrice,
}) {
  final guestCount = _extractGuestCount(request);
  if (guestCount == null) {
    return null;
  }

  final formattedGuestCount = guestCount.toString();
  final estimatedTotal = guestCount * perGuestBasePrice;
  final perGuestEstimate = _formatCurrencyForReply(estimatedTotal);
  final perPackEstimates = packageFlatPriceNumeric.entries
      .map((entry) => '${entry.key} : ${_formatCurrencyForReply(entry.value)}')
      .join('; ');

  final buffer = StringBuffer();
  if (guestCount > maxCapacity) {
    buffer.writeln('La salle peut accueillir au maximum $maxCapacity personnes. Pour $formattedGuestCount personnes, voici des options possibles :');
    buffer.writeln('- Réduire le nombre d’invités à $maxCapacity.');
    buffer.writeln('- Diviser l’événement sur deux journées ou deux espaces.');
    buffer.writeln('- Demander un devis personnalisé pour une solution externe.');
  } else {
    buffer.writeln('Pour $formattedGuestCount personnes, la salle reste dans la capacité disponible.');
  }

  if (asksPrice) {
    buffer.writeln('');
    buffer.writeln('Estimation de coût :');
    buffer.writeln('- Modèle au couvert : $perGuestEstimate total (${perGuestBasePrice.toStringAsFixed(2)}\$ par personne).');
    buffer.writeln('- Modèle par pack (forfait indicatif) : $perPackEstimates.');
    buffer.writeln('Pour un devis précis, indiquez la date exacte, le pack souhaité et vos préférences (boissons, desserts, personnel).');
  } else {
    buffer.writeln('Contactez-nous pour un devis précis et des solutions possibles.');
  }

  return buffer.toString();
}

int? _extractGuestCount(String request) {
  final normalized = request.toLowerCase();

  final directMatch = RegExp(r'(\d+)\s*(?:personnes|personne|pers|guests?|invités?|invitées?|clients?)', caseSensitive: false).firstMatch(normalized);
  if (directMatch != null) {
    return int.tryParse(directMatch.group(1)!);
  }

  final approximateMatch = RegExp(
    r'(?:environ|approximativement|à peu près|a peu pres|pres de|près de|about)\s*(\d+)\s*(?:personnes|personne|pers|guests?|invités?|invitées?|clients?)',
    caseSensitive: false,
  ).firstMatch(normalized);
  if (approximateMatch != null) {
    return int.tryParse(approximateMatch.group(1)!);
  }

  final words = {
    'un': 1,
    'une': 1,
    'deux': 2,
    'trois': 3,
    'quatre': 4,
    'cinq': 5,
    'six': 6,
    'sept': 7,
    'huit': 8,
    'neuf': 9,
    'dix': 10,
    'onze': 11,
    'douze': 12,
    'treize': 13,
    'quatorze': 14,
    'quinze': 15,
    'seize': 16,
    'vingt': 20,
    'trente': 30,
    'quarante': 40,
    'cinquante': 50,
    'soixante': 60,
    'soixante-dix': 70,
    'quatre-vingt': 80,
    'quatre-vingts': 80,
    'cent': 100,
    'mille': 1000,
    'dizaine': 10,
    'douzaine': 12,
    'quinzaine': 15,
    'vingtaine': 20,
    'trentaine': 30,
    'quarantaine': 40,
    'cinquantaine': 50,
    'soixantaine': 60,
    'centaine': 100,
    'millier': 1000,
  };

  for (final entry in words.entries) {
    final pattern = RegExp(r'(?<!\w)' + RegExp.escape(entry.key) + r'(?!\w)\s*(?:personnes|personne|pers|guests?|invités?|invitées?|clients?)', caseSensitive: false);
    if (pattern.hasMatch(normalized)) {
      return entry.value;
    }
  }

  return null;
}

String _formatCurrencyForReply(double value) {
  if (value == value.roundToDouble()) {
    final s = value.toInt().toString();
    final reg = RegExp(r"\B(?=(\d{3})+(?!\d))");
    final formatted = s.replaceAllMapped(reg, (m) => ' ');
    return '$formatted\$';
  }
  return '${value.toStringAsFixed(2)}\$';
}

class VisitorAssistant extends StatefulWidget {
  final List<Reservation> reservations;
  final VoidCallback onReserve;

  const VisitorAssistant({
    super.key,
    required this.reservations,
    required this.onReserve,
  });

  @override
  State<VisitorAssistant> createState() => _VisitorAssistantState();
}

class _VisitorAssistantState extends State<VisitorAssistant> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechRecognizerImpl _speech = SpeechRecognizerImpl();
  final TextToSpeechImpl _tts = TextToSpeechImpl();
  
  final List<_Message> _messages = [
    const _Message(
      isUser: false,
      text: 'Bonjour, je suis l\'assistant de Beraca\'s Valley ! Je suis là pour vous aider.',
    ),
  ];
  
  bool _loading = false;
  bool _speechAvailable = false;
  bool _ttsAvailable = false;
  bool _voiceEnabled = true;
  bool _isListening = false;
  String _voiceStatus = 'Prêt à écouter';

  static const int _maxCapacity = 300;

  static const List<String> _availableMenuPacks = [
    'Pack Basique',
    'Pack Moyenne',
    'Pack VIP',
  ];

  static const String _packageDetails = '''
Packs mariage :
- Décoration Basique : 2500 USD
- Décoration Moyenne : 3000 USD
- Décoration VIP : 3500 USD

Autres cérémonies (Réunion, Conférence, Formation) : 250 USD
Mariages coutumiers et autres pour samedi : 170 USD
Mariages coutumiers pour vendredi et dimanche : 150 USD

Espace extérieur :
- Décoration Basique : 500 USD
- Décoration VIP : 850 USD
''';

  // Tarifs indicatifs (chiffres utilisés pour l'estimation)
  static const Map<String, double> _packageFlatPriceNumeric = {
    'Pack Basique': 2500.0,
    'Pack Moyenne': 3000.0,
    'Pack VIP': 3500.0,
    'Autres cérémonies': 250.0,
    'Mariage coutumier A': 170.0,
    'Mariage coutumier B': 150.0,
    'Espace extérieur Basique': 500.0,
    'Espace extérieur VIP': 850.0,
  };

  // Prix par invité pour le modèle "au couvert" (estimation)
  static const double _perGuestBasePrice = 15.0; // en $ par personne

  static const String _companyName = 'Beraca\'s Valley';
  static const String _companyDescription = 'Beraca\'s Valley est une salle de reception de charme, offrant une cuisine raffinée, des espaces de réception élégants et un service attentionné pour mariages, conférences et événements privés.';
  static const String _contactPhone = '+243 998 833 016';
  static const String _contactEmail = 'beracasvalley@gmail.com';
  static const String _contactAddress = '01, Av. Géomètre Ponga, Plateau Karavia, Lubumbashi - RDC';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  @override
  void dispose() {
    if (_speech.isListening) {
      _speech.stop();
    }
    _tts.stop();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _tts.init();
    _ttsAvailable = _tts.isAvailable;
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        setState(() {
          _isListening = status == 'listening';
          _voiceStatus = _isListening ? 'Écoute en cours…' : 'Prêt à écouter';
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _voiceStatus = 'Micro indisponible';
          _isListening = false;
        });
      },
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le micro n’est pas disponible sur cet appareil.')),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _voiceStatus = 'Écoute arrêtée');
      return;
    }

    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
          _voiceStatus = result.finalResult ? 'Commande prête à envoyer' : 'Écoute en cours…';
        });

        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          _speech.stop();
          _sendMessage();
        }
      },
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _speak(String text) async {
    if (!_voiceEnabled || !_ttsAvailable || text.trim().isEmpty) return;

    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // Ignorer les erreurs de TTS en runtime.
    }
  }

  void _toggleVoiceOutput() {
    setState(() {
      _voiceEnabled = !_voiceEnabled;
    });
    if (!_voiceEnabled) {
      _tts.stop();
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(isUser: true, text: text));
      _controller.clear();
      _loading = true;
    });
    
    _scrollToBottom();

    try {
      final reservations = widget.reservations.isEmpty
          ? await SupabaseService.fetchReservations()
          : widget.reservations;
      final menu = await SupabaseService.fetchMenu();

      final availabilityHint = _buildAvailabilityHint(reservations, text);
      final capacityReply = _buildCapacityReply(text);
      
      if (capacityReply != null) {
        if (!mounted) return;
        setState(() {
          _messages.add(_Message(isUser: false, text: capacityReply));
        });
        await _speak(capacityReply);
      } else {
        final directBooking = await _tryCreateReservationFromRequest(text, reservations);
        if (directBooking != null) {
          if (!mounted) return;
          setState(() {
            _messages.add(_Message(isUser: false, text: directBooking));
          });
          await _speak(directBooking);
        } else {
          final reply = await GeminiService.generateReply(
            context: _buildAssistantContext(
              reservations: reservations,
              menu: menu,
              availabilityHint: availabilityHint,
            ),
            request: text,
            conversationHistory: _messages.map((m) => '${m.isUser ? 'Client' : 'Assistant'} : ${m.text}').toList(),
            reservations: reservations,
            menu: menu,
          );

          if (!mounted) return;
          setState(() {
            _messages.add(_Message(isUser: false, text: reply));
          });
          await _speak(reply);
        }
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(const _Message(isUser: false, text: 'Je suis désolé, une erreur technique est survenue.'));
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _scrollToBottom();
      }
    }
  }

  String? _buildCapacityReply(String request) {
    final asksPrice = request.toLowerCase().contains('payer') || request.toLowerCase().contains('combien') || request.toLowerCase().contains('prix') || request.toLowerCase().contains('coût') || request.toLowerCase().contains('cout');

    return buildCapacityReply(
      request: request,
      maxCapacity: _maxCapacity,
      perGuestBasePrice: _perGuestBasePrice,
      packageFlatPriceNumeric: _packageFlatPriceNumeric,
      asksPrice: asksPrice,
    );
  }

  String _buildAvailabilityHint(List<Reservation> reservations, String request) {
    final lowered = request.toLowerCase();
    final hasDateRequest = lowered.contains('date') || lowered.contains('dispo') || lowered.contains('disponibil') || lowered.contains('réserver') || lowered.contains('reservation') || lowered.contains('soir') || lowered.contains('demain');
    if (!hasDateRequest) {
      return 'Le client n’a pas demandé de disponibilité spécifique.';
    }

    final confirmed = reservations.where((r) => r.isConfirmed).toList();
    if (confirmed.isEmpty) {
      return 'Aucune date confirmée n’est bloquée actuellement. Les dates restent ouvertes tant qu’elles ne sont pas réservées.';
    }

    final nextDates = confirmed.take(3).map((r) => '${r.date.day}/${r.date.month}/${r.date.year} à ${r.time.format(context)}').join('; ');
    return 'Exemples de dates déjà confirmées : $nextDates. Les autres dates semblent disponibles tant que la réservation n’est pas confirmée.';
  }

  String _buildAssistantContext({
    required List<Reservation> reservations,
    required List<Dish> menu,
    required String availabilityHint,
  }) {
    final confirmedReservations = reservations.where((r) => r.isConfirmed).toList();
    final menuSummary = menu.isEmpty
        ? 'Aucun pack ou option de décoration enregistré dans la base de données.'
        : menu.map((dish) => '${dish.name} (${dish.category})').join(', ');
    final menuDetails = menu.isEmpty
        ? 'Aucun détail de menu disponible.'
        : menu.map((dish) {
            final priceText = dish.priceText.isNotEmpty
                ? dish.priceText
                : '${dish.price.toString()} USD';
            final includesText = dish.includes.isEmpty
                ? ''
                : '\n    Services inclus : ${dish.includes.join(', ')}';
            return '- ${dish.name} (${dish.category}) : $priceText\n    ${dish.description}$includesText';
          }).join('\n');
    final bookedDates = confirmedReservations.map((r) => '${r.date.day}/${r.date.month}/${r.date.year}').toList();
    final bookedDatesText = bookedDates.isEmpty ? 'Aucune date réservée.' : bookedDates.join(', ');

    return '''
Contexte application :
- Nom : $_companyName
- Description : $_companyDescription
- Adresse : $_contactAddress
- Téléphone : $_contactPhone
- Email : $_contactEmail
- Packs et menus disponibles en base : $menuSummary
- Détails des menus disponibles :
$menuDetails
- Capacité de la salle : $_maxCapacity personnes maximum
- Dates réservées confirmées : $bookedDatesText
- Disponibilités : Les autres dates restent disponibles tant qu’elles ne sont pas confirmées.
$availabilityHint
''';
  }

  Future<String?> _tryCreateReservationFromRequest(String request, List<Reservation> reservations) async {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Premium
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: const Text('🤖', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('assistant ia', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('En ligne', style: theme.textTheme.labelSmall),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          
          // Chat View
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _loading) return const _TypingIndicatorBubble();
                return _MessageBubble(message: _messages[index]);
              },
            ),
          ),

          // Input Area Premium
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Parlez ou tapez votre message...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _toggleVoiceOutput,
                      tooltip: _voiceEnabled ? 'Voix activée' : 'Voix désactivée',
                      icon: Icon(_voiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: _toggleListening,
                      tooltip: _isListening ? 'Arrêter l’écoute' : 'Parler à l’assistant',
                      icon: Icon(_isListening ? Icons.mic_off_rounded : Icons.mic_rounded),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton.small(
                      elevation: 0,
                      onPressed: _sendMessage,
                      child: const Icon(Icons.send_rounded),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _voiceStatus,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGET ANIMÉ POUR LES BULLES DE MESSAGE (Slide + Fade In)
// ============================================================================
class _MessageBubble extends StatefulWidget {
  final _Message message;
  const _MessageBubble({required this.message});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    
    // Animation de glissement (vers le haut)
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    // Animation d'opacité (apparition)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Démarre l'animation dès que le widget est construit
    _controller.forward();
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
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Align(
            alignment: widget.message.isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: widget.message.isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: widget.message.isUser ? Radius.zero : null,
                  bottomLeft: !widget.message.isUser ? Radius.zero : null,
                ),
                boxShadow: [
                  if (widget.message.isUser) // Petite ombre pour les messages utilisateurs
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                ],
              ),
              child: Text(
                widget.message.text,
                style: TextStyle(
                  color: widget.message.isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET ANIMÉ POUR L'INDICATEUR DE FRAPPE (Vague de points)
// ============================================================================
class _TypingIndicatorBubble extends StatelessWidget {
  const _TypingIndicatorBubble();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: Radius.zero),
          ),
          child: const _AnimatedDots(),
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(); // L'animation boucle à l'infini tant que l'IA réfléchit
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Utilisation d'une fonction sinusoïdale pour un effet de vague lisse
            // Le décalage temporel (index * 0.5) fait rebondir les points un par un
            final offset = math.sin((_controller.value * 2 * math.pi) - (index * 0.5));
            return Transform.translate(
              offset: Offset(0, offset * -4), // Amplitude du rebond (vers le haut)
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _Message {
  final bool isUser;
  final String text;
  const _Message({required this.isUser, required this.text});
}