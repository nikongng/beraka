import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'date_picker_field.dart';
import 'modern_text_field.dart';
import 'send_button.dart';
import 'service_dropdown.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({
    super.key,
    this.onSubmit,
  });

  final Future<void> Function(ContactRequest request)? onSubmit;

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateController = TextEditingController();
  final _guestsController = TextEditingController(text: '100'); // Remplacement du int _guests
  final _messageController = TextEditingController();
  
  final List<String> _services = [
    "Location d'espace",
    "Décoration",
    "Service traiteur",
    "Mariage",
    "Anniversaire",
    "Conférence",
    "Séminaire",
    "Autre",
  ];

  String? _selectedService;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _guestsController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Ce champ est obligatoire";
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Veuillez saisir votre numéro";
    }

    if (value.replaceAll(' ', '').length < 9) {
      return "Numéro invalide";
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Veuillez saisir votre e-mail";
    }

    final regex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!regex.hasMatch(value.trim())) {
      return "Adresse e-mail invalide";
    }

    return null;
  }

  // Nouvelle validation pour s'assurer que l'entrée est bien un nombre
  String? _validateGuests(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Veuillez indiquer le nombre d'invités";
    }
    if (int.tryParse(value.trim()) == null) {
      return "Veuillez entrer un nombre valide";
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedService == null) {
      _showErrorDialog(
        "Veuillez sélectionner un service.",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = ContactRequest(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      service: _selectedService!, 
      eventDate: _dateController.text.trim(),
      guests: int.tryParse(_guestsController.text.trim()) ?? 100, // Conversion du texte en entier
      message: _messageController.text.trim(),
    );

    try {
      if (widget.onSubmit != null) {
        await widget.onSubmit!(request);
      } else {
        await _sendEmail(request);
      }

      if (!mounted) return;

      _clearForm();

      await _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;

      _showErrorDialog(
        "Une erreur est survenue.\nVeuillez réessayer.",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();

    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _dateController.clear();
    _guestsController.text = '100'; // Réinitialisation de la valeur
    _messageController.clear();

    setState(() {
      _selectedService = null;
    });
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 72,
                  color: Colors.green,
                ),
                SizedBox(height: 20),
                Text(
                  "Demande envoyée",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Notre équipe vous contactera rapidement.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text("Erreur"),
          content: Text(message),
        );
      },
    );
  }

  Future<void> _sendEmail(ContactRequest request) async {
    const email = 'beracasvalley@gmail.com';
    const subject = 'Demande de contact - Beraca\'s Valley';
    final body = '''Nom : ${request.fullName}
Téléphone : ${request.phone}
Email : ${request.email}
Service : ${request.service}
Date souhaitée : ${request.eventDate}
Nombre de personnes : ${request.guests}

Message :
${request.message}
''';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Impossible d’ouvrir le client mail.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >= 900;

    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Envoyez-nous votre demande",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              "Remplissez le formulaire ci-dessous et notre équipe vous répondra dans les meilleurs délais.",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),

            const SizedBox(height: 32),

            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: ModernTextField(
                      controller: _nameController,
                      label: "Nom complet",
                      hint: "Votre nom",
                      icon: Icons.person_outline,
                      validator: _required,
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: ModernTextField(
                      controller: _phoneController,
                      label: "Téléphone",
                      hint: "+243...",
                      icon: Icons.phone_outlined,
                      keyboardType:
                          TextInputType.phone,
                      validator: _validatePhone,
                    ),
                  ),
                ],
              )
            else ...[
              ModernTextField(
                controller: _nameController,
                label: "Nom complet",
                hint: "Votre nom",
                icon: Icons.person_outline,
                validator: _required,
              ),

              const SizedBox(height: 18),

              ModernTextField(
                controller: _phoneController,
                label: "Téléphone",
                hint: "+243...",
                icon: Icons.phone_outlined,
                keyboardType:
                    TextInputType.phone,
                validator: _validatePhone,
              ),
            ],

            const SizedBox(height: 18),
                        if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ModernTextField(
                      controller: _emailController,
                      label: "Adresse e-mail",
                      hint: "exemple@email.com",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ServiceDropdown(
                      value: _selectedService,
                      services: _services,
                      onChanged: (value) {
                        setState(() {
                          _selectedService = value;
                        });
                      },
                    ),
                  ),
                ],
              )
            else ...[
              ModernTextField(
                controller: _emailController,
                label: "Adresse e-mail",
                hint: "exemple@email.com",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
              ),
              const SizedBox(height: 18),
              ServiceDropdown(
                value: _selectedService,
                services: _services,
                onChanged: (value) {
                  setState(() {
                    _selectedService = value;
                  });
                },
              ),
            ],

            const SizedBox(height: 18),

            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DatePickerField(
                      controller: _dateController,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ModernTextField(
                      controller: _guestsController,
                      label: "Nombre d'invités",
                      hint: "Ex: 100",
                      icon: Icons.people_outline,
                      keyboardType: TextInputType.number,
                      validator: _validateGuests,
                    ),
                  ),
                ],
              )
            else ...[
              DatePickerField(
                controller: _dateController,
              ),
              const SizedBox(height: 18),
              ModernTextField(
                controller: _guestsController,
                label: "Nombre d'invités",
                hint: "Ex: 100",
                icon: Icons.people_outline,
                keyboardType: TextInputType.number,
                validator: _validateGuests,
              ),
            ],

            const SizedBox(height: 18),

            ModernTextField(
              controller: _messageController,
              label: "Décrivez votre événement",
              hint:
                  "Type d'événement, nombre de tables, décoration souhaitée, informations complémentaires...",
              icon: Icons.chat_bubble_outline_rounded,
              maxLines: 6,
              textInputAction: TextInputAction.done,
              validator: _required,
            ),

            const SizedBox(height: 32),

            SendButton(
              isLoading: _isLoading,
              text: "Envoyer ma demande",
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

///
/// Données envoyées lors de la soumission du formulaire.
///
class ContactRequest {
  const ContactRequest({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.service,
    required this.eventDate,
    required this.guests,
    required this.message,
  });

  final String fullName;
  final String phone;
  final String email;
  final String service;
  final String eventDate;
  final int guests;
  final String message;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'service': service,
      'eventDate': eventDate,
      'guests': guests,
      'message': message,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  ContactRequest copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? service,
    String? eventDate,
    int? guests,
    String? message,
  }) {
    return ContactRequest(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      service: service ?? this.service,
      eventDate: eventDate ?? this.eventDate,
      guests: guests ?? this.guests,
      message: message ?? this.message,
    );
  }

  @override
  String toString() {
    return '''
ContactRequest(
  fullName: $fullName,
  phone: $phone,
  email: $email,
  service: $service,
  eventDate: $eventDate,
  guests: $guests,
  message: $message,
)
''';
  }
}