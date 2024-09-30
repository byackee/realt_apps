// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fr';

  static String m0(language) => "Langue mise à jour en ${language}";

  static String m1(theme) => "Thème mis à jour en ${theme}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "annualYield": MessageLookupByLibrary.simpleMessage("Rendement Annuel"),
        "annually": MessageLookupByLibrary.simpleMessage("Annuel"),
        "daily": MessageLookupByLibrary.simpleMessage("Journalier"),
        "dark": MessageLookupByLibrary.simpleMessage("Sombre"),
        "darkTheme": MessageLookupByLibrary.simpleMessage("Thème sombre"),
        "english": MessageLookupByLibrary.simpleMessage("Anglais"),
        "french": MessageLookupByLibrary.simpleMessage("Français"),
        "hello": MessageLookupByLibrary.simpleMessage("Bonjour"),
        "language": MessageLookupByLibrary.simpleMessage("Langue"),
        "languageUpdated": m0,
        "lastRentReceived": MessageLookupByLibrary.simpleMessage(
            "Vos derniers loyers reçus s\'\'élèvent à "),
        "light": MessageLookupByLibrary.simpleMessage("Clair"),
        "manageEvmAddresses":
            MessageLookupByLibrary.simpleMessage("Gérer les adresses EVM"),
        "monthly": MessageLookupByLibrary.simpleMessage("Mensuel"),
        "noRentReceived":
            MessageLookupByLibrary.simpleMessage("Aucun loyer reçu"),
        "portfolio": MessageLookupByLibrary.simpleMessage("Portfolio"),
        "properties": MessageLookupByLibrary.simpleMessage("Propriétés"),
        "rented": MessageLookupByLibrary.simpleMessage("Loué"),
        "rentedUnits": MessageLookupByLibrary.simpleMessage("Unités Louées"),
        "rents": MessageLookupByLibrary.simpleMessage("Loyers"),
        "rmm": MessageLookupByLibrary.simpleMessage("RMM"),
        "rwaHoldings": MessageLookupByLibrary.simpleMessage("RWA Holdings SA"),
        "settingsTitle": MessageLookupByLibrary.simpleMessage("Paramètres"),
        "themeUpdated": m1,
        "tokens": MessageLookupByLibrary.simpleMessage("Tokens"),
        "totalPortfolio":
            MessageLookupByLibrary.simpleMessage("Total Portfolio"),
        "totalTokens": MessageLookupByLibrary.simpleMessage("Total Tokens"),
        "wallet": MessageLookupByLibrary.simpleMessage("Wallet"),
        "weekly": MessageLookupByLibrary.simpleMessage("Hebdomadaire")
      };
}
