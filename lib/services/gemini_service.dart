import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models.dart';

class GeminiService {
  static String _apiKey = '';

  static Future<void> loadConfig() async {
    try {
      final content = await rootBundle.loadString('assets/.env');
      for (final line in content.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) {
          continue;
        }
        final parts = trimmed.split('=');
        if (parts.isNotEmpty && parts.first.trim() == 'GEMINI_API_KEY') {
          _apiKey = parts.sublist(1).join('=').trim();
          break;
        }
      }
    } catch (_) {
      _apiKey = '';
    }
  }

  static const String _model = 'gemini-2.5-flash';

  static String buildPrompt({
    required String context,
    required String request,
    List<String> conversationHistory = const [],
  }) {
    final historyBlock = conversationHistory.isEmpty
        ? 'Historique : aucun.'
        : 'Historique de conversation :\n${conversationHistory.join('\n')}';

    return '''
Tu es l’assistant expert de Beraca’s Valley pour l’organisation d’événements.
Réponds en français, avec un ton chaleureux, professionnel et direct.
Commence par une salutation seulement si c’est la première réponse de l’assistant dans cette conversation.
Si l’historique contient déjà un message de l’assistant ou s’il y a eu une salutation précédente, réponds directement sans nouvelle salutation.
Analyse la demande du client en identifiant le type d’événement, la date, le nombre d’invités et le besoin principal.
Donne une réponse structurée : 1) ce que propose Beraca’s Valley, 2) les packs pertinents, 3) les tarifs estimés ou forfaits, 4) les actions suivantes.
Pour les questions de prix, fournis des montants clairs ou une fourchette et indique s’il s’agit d’une estimation.
Pour les demandes d’anniversaire, mariage, réunion ou conférence, recommande le pack le plus adapté et mentionne les tarifs exacts du contexte.
Ne fabrique pas d’information et n’ajoute pas de détails qui ne sont pas présents dans le contexte.
Si le client demande “qui es-tu ?” ou une variante similaire, réponds clairement : “Je suis l’assistant de Beraca’s Valley spécialisé dans l’organisation d’événements.”
Si le client n’a pas donné assez de détails, pose une question de clarification précise et utile.
Ne dis pas que tu es une IA.
Ne recommande pas de cliquer sur un bouton de l’application sauf si le client demande explicitement comment faire une réservation.
Rédige toujours une réponse complète et claire. Si la réponse est longue, finis par une phrase complète et ne coupe pas au milieu d’une idée.
Inclut les informations suivantes dans ta réponse si le client les demande : présentation de Beraca’s Valley, packs disponibles, contact, adresse, email, téléphone, disponibilité générale et menu.
L'horaire de beraca's valley est ouvert du lundi au vendredi de 8h a 17h et samedi de 8h a 12h

Contexte : $context
$historyBlock
Dernière demande du client : $request
''';
  }

  static Future<String> generateReply({
    required String context,
    required String request,
    List<String> conversationHistory = const [],
    List<Reservation>? reservations,
    List<Dish>? menu,
  }) async {
    final localReply = buildLocalReply(request: request);
    if (localReply != null) {
      return localReply;
    }

    if (_apiKey.isEmpty) {
      return buildFallbackReply(request: request, reason: 'api_key_missing');
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
    );

    final prompt = buildPrompt(
      context: context,
      request: request,
      conversationHistory: conversationHistory,
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.25,
          'topK': 40,
          'topP': 0.9,
          'maxOutputTokens': 2500,
          'candidateCount': 1,
        },
      }),
    );

    if (response.statusCode != 200) {
      return buildFallbackReply(request: request, reason: 'api_error');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // The API may return multiple 'parts' for a candidate; concatenate them to form the full reply.
    String reply = '';
    try {
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates != null && candidates.isNotEmpty) {
        final first = candidates.first as Map<String, dynamic>;
        final content = first['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts != null && parts.isNotEmpty) {
          reply = parts.map((p) => (p['text'] ?? '').toString()).join('\n').trim();
        } else if (content != null && content['text'] != null) {
          reply = content['text'].toString().trim();
        }
      }
    } catch (_) {
      reply = '';
    }

    if (reply.isEmpty) {
      return buildFallbackReply(request: request, reason: 'empty_response');
    }
    if (_isLikelyTruncated(reply)) {
      final compactReply = _trimToMeaningfulLength(reply);
      return '$compactReply\n\nJe peux continuer si vous le souhaitez.';
    }

    return reply;
  }

  static bool _isLikelyTruncated(String text) {
    final lower = text.toLowerCase();
    final unfinishedEndings = ['...', '…', 'et', 'ou', 'ainsi', 'alors', 'si', 'mais', 'en', 'pour'];
    return unfinishedEndings.any((ending) => lower.endsWith(' $ending')) || lower.endsWith('...') || lower.endsWith('…') || text.length > 1800;
  }

  static String _trimToMeaningfulLength(String text) {
    const maxLength = 1600;
    if (text.length <= maxLength) {
      return text;
    }

    final trimmed = text.substring(0, maxLength).trimRight();
    final lastPeriod = trimmed.lastIndexOf('.');
    if (lastPeriod > 1000) {
      return trimmed.substring(0, lastPeriod + 1);
    }
    return trimmed;
  }

  static String? buildLocalReply({required String request}) {
    final lowered = request.toLowerCase();
    final asksPrice = lowered.contains('payer') || lowered.contains('combien') || lowered.contains('prix') || lowered.contains('coût') || lowered.contains('cout');
    final mentionsEvent = lowered.contains('anniversaire') || lowered.contains('birthday') || lowered.contains('anniv') || lowered.contains('mariage') || lowered.contains('réunion') || lowered.contains('conference') || lowered.contains('événement') || lowered.contains('evenement');
    final asksWho = lowered.contains('qui es-tu') || lowered.contains('qui est tu') || lowered.contains('qui êtes-vous') || lowered.contains('qui etes vous') || lowered.contains('tu es qui');
    final asksHelp = lowered.contains('aide') || lowered.contains('help') || lowered.contains('organiser') || lowered.contains('préparer') || lowered.contains('preparer');
    final asksAvailability = lowered.contains('dispo') || lowered.contains('disponible') || lowered.contains('date') || lowered.contains('libre') || lowered.contains('ouvert');

    if (asksWho) {
      return 'Je suis l’assistant de Beraca’s Valley spécialisé dans l’organisation d’événements. Je peux vous aider pour les tarifs, les packs et la préparation d’un événement.';
    }

    if (asksPrice && mentionsEvent) {
      final guestCount = _extractGuestCount(request);
      const basePackEstimate = 2500.0;
      final perGuestEstimate = guestCount != null ? guestCount * 15.0 : 0.0;

      if (guestCount == null) {
        return 'Le tarif dépend du type d’événement, du nombre d’invités, du pack choisi et de la formule. Donnez simplement le nombre de personnes et la date pour un devis plus précis.';
      }

      final packLabel = guestCount <= 20 ? 'Pack Basique' : 'Pack Moyen';
      return 'Pour un événement de $guestCount personnes, une estimation simple est de ${_formatCurrency(basePackEstimate)} pour le $packLabel, ou environ ${_formatCurrency(perGuestEstimate)} au couvert. Pour un devis précis, donnez la date et le type de formule souhaité.';
    }

    if (asksHelp && mentionsEvent) {
      return 'Je peux vous aider à organiser votre événement. Dites-moi le type d’événement, le nombre d’invités et la date pour vous proposer une solution adaptée.';
    }

    if (asksAvailability && mentionsEvent) {
      return 'Je peux vous aider à vérifier la disponibilité. Donnez-moi la date souhaitée et le nombre d’invités pour vous répondre plus précisément.';
    }

    if (mentionsEvent) {
      return 'Je peux vous aider pour votre événement. Dites-moi si vous souhaitez un devis, une disponibilité ou un pack adapté.';
    }

    return null;
  }

  static int? _extractGuestCount(String request) {
    final match = RegExp(r'(\d+)\s*(?:personnes|personne|pers|guests?|invités|invité)', caseSensitive: false).firstMatch(request);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  static String _formatCurrency(double value) {
    if (value == value.roundToDouble()) {
      final intValue = value.toInt();
      final formatted = intValue.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ');
      return '$formatted USD';
    }
    return '${value.toStringAsFixed(2)} USD';
  }

  static String buildFallbackReply({required String request, String? reason}) {
    final lowered = request.toLowerCase();
    final cause = switch (reason) {
      'api_key_missing' => 'la clé API Gemini n’est pas disponible',
      'api_error' => 'l’appel à l’API Gemini a échoué',
      'empty_response' => 'l’API Gemini n’a renvoyé aucun texte exploitable',
      _ => 'le service de réponse n’a pas pu répondre correctement',
    };

    if (lowered.contains('réserver') || lowered.contains('reservation') || lowered.contains('table') || lowered.contains('place')) {
      return 'Je peux vous aider à préparer votre réservation. Le service est actuellement en mode de secours car $cause. Dites-moi la date, le nombre d’invités et le type d’événement pour un suivi plus précis.';
    }

    if (lowered.contains('menu') || lowered.contains('plat') || lowered.contains('repas')) {
      return 'Nous proposons des packs de qualité et des menus adaptés à votre événement. Le service est actuellement en mode de secours car $cause. Dites-moi si vous cherchez un menu mariage, professionnel ou extérieur.';
    }

    if (lowered.contains('qui es-tu') || lowered.contains('qui est tu') || lowered.contains('qui êtes-vous') || lowered.contains('qui etes vous')) {
      return 'Je suis l’assistant de Beraca’s Valley spécialisé dans l’organisation d’événements. Le service est actuellement en mode de secours car $cause. Pour une aide précise, donnez votre type d’événement, la date et le nombre d’invités.';
    }

    return 'Je peux vous aider à organiser votre événement. Le service est actuellement en mode de secours car $cause. Indiquez votre besoin (anniversaire, mariage, conférence, date, nombre d’invités) pour que je vous donne une réponse plus précise.';
  }
}
