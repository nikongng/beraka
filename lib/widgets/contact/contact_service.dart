enum ContactService {
  location,
  decoration,
  traiteur,
}

extension ContactServiceExtension on ContactService {
  String get label {
    switch (this) {
      case ContactService.location:
        return "Location d'espace";

      case ContactService.decoration:
        return "Décoration";

      case ContactService.traiteur:
        return "Service traiteur";
    }
  }
}