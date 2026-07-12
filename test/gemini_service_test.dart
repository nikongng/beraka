import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beraca/data.dart';
import 'package:beraca/services/gemini_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the Gemini configuration asset', () async {
    await GeminiService.loadConfig();

    final content = await rootBundle.loadString('assets/.env');
    expect(content, contains('GEMINI_API_KEY='));
  });

  test('builds a prompt that includes the latest client message and prior history', () {
    final prompt = GeminiService.buildPrompt(
      context: 'Contexte hôtel',
      request: 'comment tu vas',
      conversationHistory: ['Client : Bonjour', 'Assistant : Bonjour !'],
    );

    expect(prompt, contains('comment tu vas'));
    expect(prompt, contains('Client : Bonjour'));
    expect(prompt, contains('Assistant : Bonjour !'));
    expect(prompt, contains('Commence par une salutation'));
  });

  test('uses a 300-guest hall capacity in the shared app data', () {
    expect(Pages.hallCapacity, 300);
  });

  test('builds a local pricing reply for anniversary requests', () {
    final reply = GeminiService.buildLocalReply(
      request: 'Pour un anniversaire avec 10 personnes, je dois payer combien ?',
    );

    expect(reply, isNotNull);
    expect(reply, contains('événement'));
    expect(reply, contains('10'));
    expect(reply, contains('2500'));
  });

  test('builds a local identity reply for who-are-you questions', () {
    final reply = GeminiService.buildLocalReply(request: 'Qui es-tu ?');

    expect(reply, isNotNull);
    expect(reply, contains('Beraca's Valley'));
  });

  test('builds a fallback reply that explains the cause', () {
    final reply = GeminiService.buildFallbackReply(
      request: 'Pour un anniversaire, je paye combien ?',
      reason: 'api_key_missing',
    );

    expect(reply, contains('clé API Gemini'));
    expect(reply, contains('anniversaire'));
  });
}
