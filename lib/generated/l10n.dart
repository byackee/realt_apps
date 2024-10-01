// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message(
      'Settings',
      name: 'settingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Dark Theme`
  String get darkTheme {
    return Intl.message(
      'Dark Theme',
      name: 'darkTheme',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Theme updated to {theme}`
  String themeUpdated(Object theme) {
    return Intl.message(
      'Theme updated to $theme',
      name: 'themeUpdated',
      desc: '',
      args: [theme],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Language updated to {language}`
  String languageUpdated(Object language) {
    return Intl.message(
      'Language updated to $language',
      name: 'languageUpdated',
      desc: '',
      args: [language],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `French`
  String get french {
    return Intl.message(
      'French',
      name: 'french',
      desc: '',
      args: [],
    );
  }

  /// `Manage EVM Addresses`
  String get manageEvmAddresses {
    return Intl.message(
      'Manage EVM Addresses',
      name: 'manageEvmAddresses',
      desc: '',
      args: [],
    );
  }

  /// `Hello`
  String get hello {
    return Intl.message(
      'Hello',
      name: 'hello',
      desc: '',
      args: [],
    );
  }

  /// `Your last rent received amounts to `
  String get lastRentReceived {
    return Intl.message(
      'Your last rent received amounts to ',
      name: 'lastRentReceived',
      desc: '',
      args: [],
    );
  }

  /// `Portfolio`
  String get portfolio {
    return Intl.message(
      'Portfolio',
      name: 'portfolio',
      desc: '',
      args: [],
    );
  }

  /// `Total Portfolio`
  String get totalPortfolio {
    return Intl.message(
      'Total Portfolio',
      name: 'totalPortfolio',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get wallet {
    return Intl.message(
      'Wallet',
      name: 'wallet',
      desc: '',
      args: [],
    );
  }

  /// `RMM`
  String get rmm {
    return Intl.message(
      'RMM',
      name: 'rmm',
      desc: '',
      args: [],
    );
  }

  /// `RWA Holdings SA`
  String get rwaHoldings {
    return Intl.message(
      'RWA Holdings SA',
      name: 'rwaHoldings',
      desc: '',
      args: [],
    );
  }

  /// `Properties`
  String get properties {
    return Intl.message(
      'Properties',
      name: 'properties',
      desc: '',
      args: [],
    );
  }

  /// `Rented`
  String get rented {
    return Intl.message(
      'Rented',
      name: 'rented',
      desc: '',
      args: [],
    );
  }

  /// `Rented Units`
  String get rentedUnits {
    return Intl.message(
      'Rented Units',
      name: 'rentedUnits',
      desc: '',
      args: [],
    );
  }

  /// `Tokens`
  String get tokens {
    return Intl.message(
      'Tokens',
      name: 'tokens',
      desc: '',
      args: [],
    );
  }

  /// `Total Tokens`
  String get totalTokens {
    return Intl.message(
      'Total Tokens',
      name: 'totalTokens',
      desc: '',
      args: [],
    );
  }

  /// `Rents`
  String get rents {
    return Intl.message(
      'Rents',
      name: 'rents',
      desc: '',
      args: [],
    );
  }

  /// `Annual Yield`
  String get annualYield {
    return Intl.message(
      'Annual Yield',
      name: 'annualYield',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get daily {
    return Intl.message(
      'Daily',
      name: 'daily',
      desc: '',
      args: [],
    );
  }

  /// `Weekly`
  String get weekly {
    return Intl.message(
      'Weekly',
      name: 'weekly',
      desc: '',
      args: [],
    );
  }

  /// `Monthly`
  String get monthly {
    return Intl.message(
      'Monthly',
      name: 'monthly',
      desc: '',
      args: [],
    );
  }

  /// `Annually`
  String get annually {
    return Intl.message(
      'Annually',
      name: 'annually',
      desc: '',
      args: [],
    );
  }

  /// `No rent received`
  String get noRentReceived {
    return Intl.message(
      'No rent received',
      name: 'noRentReceived',
      desc: '',
      args: [],
    );
  }

  /// `Finances`
  String get finances {
    return Intl.message(
      'Finances',
      name: 'finances',
      desc: '',
      args: [],
    );
  }

  /// `Others`
  String get others {
    return Intl.message(
      'Others',
      name: 'others',
      desc: '',
      args: [],
    );
  }

  /// `Insights`
  String get insights {
    return Intl.message(
      'Insights',
      name: 'insights',
      desc: '',
      args: [],
    );
  }

  /// `Characteristics`
  String get characteristics {
    return Intl.message(
      'Characteristics',
      name: 'characteristics',
      desc: '',
      args: [],
    );
  }

  /// `Construction Year`
  String get constructionYear {
    return Intl.message(
      'Construction Year',
      name: 'constructionYear',
      desc: '',
      args: [],
    );
  }

  /// `Property Stories`
  String get propertyStories {
    return Intl.message(
      'Property Stories',
      name: 'propertyStories',
      desc: '',
      args: [],
    );
  }

  /// `Total Units`
  String get totalUnits {
    return Intl.message(
      'Total Units',
      name: 'totalUnits',
      desc: '',
      args: [],
    );
  }

  /// `Lot Size`
  String get lotSize {
    return Intl.message(
      'Lot Size',
      name: 'lotSize',
      desc: '',
      args: [],
    );
  }

  /// `Square Feet`
  String get squareFeet {
    return Intl.message(
      'Square Feet',
      name: 'squareFeet',
      desc: '',
      args: [],
    );
  }

  /// `Offering`
  String get offering {
    return Intl.message(
      'Offering',
      name: 'offering',
      desc: '',
      args: [],
    );
  }

  /// `Initial Launch Date`
  String get initialLaunchDate {
    return Intl.message(
      'Initial Launch Date',
      name: 'initialLaunchDate',
      desc: '',
      args: [],
    );
  }

  /// `Rental Type`
  String get rentalType {
    return Intl.message(
      'Rental Type',
      name: 'rentalType',
      desc: '',
      args: [],
    );
  }

  /// `Rent Start Date`
  String get rentStartDate {
    return Intl.message(
      'Rent Start Date',
      name: 'rentStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Total Investment`
  String get totalInvestment {
    return Intl.message(
      'Total Investment',
      name: 'totalInvestment',
      desc: '',
      args: [],
    );
  }

  /// `Underlying Asset Price`
  String get underlyingAssetPrice {
    return Intl.message(
      'Underlying Asset Price',
      name: 'underlyingAssetPrice',
      desc: '',
      args: [],
    );
  }

  /// `Initial Maintenance Reserve`
  String get initialMaintenanceReserve {
    return Intl.message(
      'Initial Maintenance Reserve',
      name: 'initialMaintenanceReserve',
      desc: '',
      args: [],
    );
  }

  /// `Gross Rent (Monthly)`
  String get grossRentMonth {
    return Intl.message(
      'Gross Rent (Monthly)',
      name: 'grossRentMonth',
      desc: '',
      args: [],
    );
  }

  /// `Net Rent (Monthly)`
  String get netRentMonth {
    return Intl.message(
      'Net Rent (Monthly)',
      name: 'netRentMonth',
      desc: '',
      args: [],
    );
  }

  /// `Annual Percentage Yield`
  String get annualPercentageYield {
    return Intl.message(
      'Annual Percentage Yield',
      name: 'annualPercentageYield',
      desc: '',
      args: [],
    );
  }

  /// `Blockchain`
  String get blockchain {
    return Intl.message(
      'Blockchain',
      name: 'blockchain',
      desc: '',
      args: [],
    );
  }

  /// `Token Address`
  String get tokenAddress {
    return Intl.message(
      'Token Address',
      name: 'tokenAddress',
      desc: '',
      args: [],
    );
  }

  /// `Network`
  String get network {
    return Intl.message(
      'Network',
      name: 'network',
      desc: '',
      args: [],
    );
  }

  /// `Token Symbol`
  String get tokenSymbol {
    return Intl.message(
      'Token Symbol',
      name: 'tokenSymbol',
      desc: '',
      args: [],
    );
  }

  /// `Contract Type`
  String get contractType {
    return Intl.message(
      'Contract Type',
      name: 'contractType',
      desc: '',
      args: [],
    );
  }

  /// `Rental Status`
  String get rentalStatus {
    return Intl.message(
      'Rental Status',
      name: 'rentalStatus',
      desc: '',
      args: [],
    );
  }

  /// `Yield Evolution`
  String get yieldEvolution {
    return Intl.message(
      'Yield Evolution',
      name: 'yieldEvolution',
      desc: '',
      args: [],
    );
  }

  /// `Price Evolution`
  String get priceEvolution {
    return Intl.message(
      'Price Evolution',
      name: 'priceEvolution',
      desc: '',
      args: [],
    );
  }

  /// `View on RealT`
  String get viewOnRealT {
    return Intl.message(
      'View on RealT',
      name: 'viewOnRealT',
      desc: '',
      args: [],
    );
  }

  /// `Not specified`
  String get notSpecified {
    return Intl.message(
      'Not specified',
      name: 'notSpecified',
      desc: '',
      args: [],
    );
  }

  /// `No price evolution. The last price is:`
  String get noPriceEvolution {
    return Intl.message(
      'No price evolution. The last price is:',
      name: 'noPriceEvolution',
      desc: '',
      args: [],
    );
  }

  /// `Price Evolution:`
  String get priceEvolutionPercentage {
    return Intl.message(
      'Price Evolution:',
      name: 'priceEvolutionPercentage',
      desc: '',
      args: [],
    );
  }

  /// `No yield evolution. The last value is:`
  String get noYieldEvolution {
    return Intl.message(
      'No yield evolution. The last value is:',
      name: 'noYieldEvolution',
      desc: '',
      args: [],
    );
  }

  /// `Yield Evolution:`
  String get yieldEvolutionPercentage {
    return Intl.message(
      'Yield Evolution:',
      name: 'yieldEvolutionPercentage',
      desc: '',
      args: [],
    );
  }

  /// `Unknown City`
  String get unknownCity {
    return Intl.message(
      'Unknown City',
      name: 'unknownCity',
      desc: '',
      args: [],
    );
  }

  /// `Name Unavailable`
  String get nameUnavailable {
    return Intl.message(
      'Name Unavailable',
      name: 'nameUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get other {
    return Intl.message(
      'Other',
      name: 'other',
      desc: '',
      args: [],
    );
  }

  /// `Total Value`
  String get totalValue {
    return Intl.message(
      'Total Value',
      name: 'totalValue',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get amount {
    return Intl.message(
      'Amount',
      name: 'amount',
      desc: '',
      args: [],
    );
  }

  /// `APY`
  String get apy {
    return Intl.message(
      'APY',
      name: 'apy',
      desc: '',
      args: [],
    );
  }

  /// `Revenue`
  String get revenue {
    return Intl.message(
      'Revenue',
      name: 'revenue',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get day {
    return Intl.message(
      'Day',
      name: 'day',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get month {
    return Intl.message(
      'Month',
      name: 'month',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get year {
    return Intl.message(
      'Year',
      name: 'year',
      desc: '',
      args: [],
    );
  }

  /// `App Name`
  String get appName {
    return Intl.message(
      'App Name',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `mobile app for Community`
  String get appDescription {
    return Intl.message(
      'mobile app for Community',
      name: 'appDescription',
      desc: '',
      args: [],
    );
  }

  /// `RealTokens list`
  String get realTokensList {
    return Intl.message(
      'RealTokens list',
      name: 'realTokensList',
      desc: '',
      args: [],
    );
  }

  /// `Recent changes`
  String get recentChanges {
    return Intl.message(
      'Recent changes',
      name: 'recentChanges',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedback {
    return Intl.message(
      'Feedback',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }

  /// `Application`
  String get application {
    return Intl.message(
      'Application',
      name: 'application',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get author {
    return Intl.message(
      'Author',
      name: 'author',
      desc: '',
      args: [],
    );
  }

  /// `Thanks`
  String get thanks {
    return Intl.message(
      'Thanks',
      name: 'thanks',
      desc: '',
      args: [],
    );
  }

  /// `Thank you to everyone who contributed to this project.`
  String get thankYouMessage {
    return Intl.message(
      'Thank you to everyone who contributed to this project.',
      name: 'thankYouMessage',
      desc: '',
      args: [],
    );
  }

  /// `Special thanks to @Sigri, @ehpst, and pitsbi for their support.`
  String get specialThanks {
    return Intl.message(
      'Special thanks to @Sigri, @ehpst, and pitsbi for their support.',
      name: 'specialThanks',
      desc: '',
      args: [],
    );
  }

  /// `Donate`
  String get donate {
    return Intl.message(
      'Donate',
      name: 'donate',
      desc: '',
      args: [],
    );
  }

  /// `Support the project`
  String get supportProject {
    return Intl.message(
      'Support the project',
      name: 'supportProject',
      desc: '',
      args: [],
    );
  }

  /// `If you like this app and want to support its development, you can donate.`
  String get donationMessage {
    return Intl.message(
      'If you like this app and want to support its development, you can donate.',
      name: 'donationMessage',
      desc: '',
      args: [],
    );
  }

  /// `PayPal`
  String get paypal {
    return Intl.message(
      'PayPal',
      name: 'paypal',
      desc: '',
      args: [],
    );
  }

  /// `Crypto`
  String get crypto {
    return Intl.message(
      'Crypto',
      name: 'crypto',
      desc: '',
      args: [],
    );
  }

  /// `Crypto Donation Address`
  String get cryptoDonationAddress {
    return Intl.message(
      'Crypto Donation Address',
      name: 'cryptoDonationAddress',
      desc: '',
      args: [],
    );
  }

  /// `Send your donations to the following address:`
  String get sendDonations {
    return Intl.message(
      'Send your donations to the following address:',
      name: 'sendDonations',
      desc: '',
      args: [],
    );
  }

  /// `Address copied to clipboard`
  String get addressCopied {
    return Intl.message(
      'Address copied to clipboard',
      name: 'addressCopied',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Week`
  String get week {
    return Intl.message(
      'Week',
      name: 'week',
      desc: '',
      args: [],
    );
  }

  /// `Rent Received Graph`
  String get rentGraph {
    return Intl.message(
      'Rent Received Graph',
      name: 'rentGraph',
      desc: '',
      args: [],
    );
  }

  /// `Token Distribution by Property Type`
  String get tokenDistribution {
    return Intl.message(
      'Token Distribution by Property Type',
      name: 'tokenDistribution',
      desc: '',
      args: [],
    );
  }

  /// `Single Family`
  String get singleFamily {
    return Intl.message(
      'Single Family',
      name: 'singleFamily',
      desc: '',
      args: [],
    );
  }

  /// `Multi Family`
  String get multiFamily {
    return Intl.message(
      'Multi Family',
      name: 'multiFamily',
      desc: '',
      args: [],
    );
  }

  /// `Duplex`
  String get duplex {
    return Intl.message(
      'Duplex',
      name: 'duplex',
      desc: '',
      args: [],
    );
  }

  /// `Condominium`
  String get condominium {
    return Intl.message(
      'Condominium',
      name: 'condominium',
      desc: '',
      args: [],
    );
  }

  /// `Mixed-Use`
  String get mixedUse {
    return Intl.message(
      'Mixed-Use',
      name: 'mixedUse',
      desc: '',
      args: [],
    );
  }

  /// `Commercial`
  String get commercial {
    return Intl.message(
      'Commercial',
      name: 'commercial',
      desc: '',
      args: [],
    );
  }

  /// `SFR Portfolio`
  String get sfrPortfolio {
    return Intl.message(
      'SFR Portfolio',
      name: 'sfrPortfolio',
      desc: '',
      args: [],
    );
  }

  /// `MFR Portfolio`
  String get mfrPortfolio {
    return Intl.message(
      'MFR Portfolio',
      name: 'mfrPortfolio',
      desc: '',
      args: [],
    );
  }

  /// `Resort Bungalow`
  String get resortBungalow {
    return Intl.message(
      'Resort Bungalow',
      name: 'resortBungalow',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }

  /// `Search...`
  String get searchHint {
    return Intl.message(
      'Search...',
      name: 'searchHint',
      desc: '',
      args: [],
    );
  }

  /// `All Cities`
  String get allCities {
    return Intl.message(
      'All Cities',
      name: 'allCities',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get rentalStatusAll {
    return Intl.message(
      'All',
      name: 'rentalStatusAll',
      desc: '',
      args: [],
    );
  }

  /// `Rented`
  String get rentalStatusRented {
    return Intl.message(
      'Rented',
      name: 'rentalStatusRented',
      desc: '',
      args: [],
    );
  }

  /// `Partially Rented`
  String get rentalStatusPartiallyRented {
    return Intl.message(
      'Partially Rented',
      name: 'rentalStatusPartiallyRented',
      desc: '',
      args: [],
    );
  }

  /// `Not Rented`
  String get rentalStatusNotRented {
    return Intl.message(
      'Not Rented',
      name: 'rentalStatusNotRented',
      desc: '',
      args: [],
    );
  }

  /// `Sort by Name`
  String get sortByName {
    return Intl.message(
      'Sort by Name',
      name: 'sortByName',
      desc: '',
      args: [],
    );
  }

  /// `Sort by Value`
  String get sortByValue {
    return Intl.message(
      'Sort by Value',
      name: 'sortByValue',
      desc: '',
      args: [],
    );
  }

  /// `Sort by APY`
  String get sortByAPY {
    return Intl.message(
      'Sort by APY',
      name: 'sortByAPY',
      desc: '',
      args: [],
    );
  }

  /// `Ascending`
  String get ascending {
    return Intl.message(
      'Ascending',
      name: 'ascending',
      desc: '',
      args: [],
    );
  }

  /// `Descending`
  String get descending {
    return Intl.message(
      'Descending',
      name: 'descending',
      desc: '',
      args: [],
    );
  }

  /// `Token Distribution by City`
  String get tokenDistributionByCity {
    return Intl.message(
      'Token Distribution by City',
      name: 'tokenDistributionByCity',
      desc: '',
      args: [],
    );
  }

  /// `Token Distribution by Region`
  String get tokenDistributionByRegion {
    return Intl.message(
      'Token Distribution by Region',
      name: 'tokenDistributionByRegion',
      desc: '',
      args: [],
    );
  }

  /// `Token Distribution by Country`
  String get tokenDistributionByCountry {
    return Intl.message(
      'Token Distribution by Country',
      name: 'tokenDistributionByCountry',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
