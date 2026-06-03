import 'package:flutter/foundation.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/city.dart';

// Enum for adhan audio styles
enum AdhanStyle { defaultStyle, makkah, madinah, alaqsa }

extension AdhanStyleExt on AdhanStyle {
  String get displayName {
    switch (this) {
      case AdhanStyle.defaultStyle:
        return 'Classic Adhan';
      case AdhanStyle.makkah:
        return 'Makkah';
      case AdhanStyle.madinah:
        return 'Madinah';
      case AdhanStyle.alaqsa:
        return 'Al-Aqsa';
    }
  }
}

// Simple enum for sunnah prayers
enum SunnahPrayer { beforeFajr, duha, beforeDhuhr, tahajjud, witr }

// Enum for calculation methods
enum CalculationMethodOption {
  muslimWorldLeague,
  ummAlQura,
  egyptian,
  isna,
  karachi,
}

extension CalculationMethodOptionExt on CalculationMethodOption {
  String get name {
    switch (this) {
      case CalculationMethodOption.muslimWorldLeague:
        return 'Muslim World League';
      case CalculationMethodOption.ummAlQura:
        return 'Umm al-Qura';
      case CalculationMethodOption.egyptian:
        return 'Egyptian General Authority';
      case CalculationMethodOption.isna:
        return 'ISNA (North America)';
      case CalculationMethodOption.karachi:
        return 'Karachi (Univ. of Islamic Sciences)';
    }
  }

  CalculationMethod get adhanMethod {
    switch (this) {
      case CalculationMethodOption.muslimWorldLeague:
        return CalculationMethod.muslim_world_league;
      case CalculationMethodOption.ummAlQura:
        return CalculationMethod.umm_al_qura;
      case CalculationMethodOption.egyptian:
        return CalculationMethod.egyptian;
      case CalculationMethodOption.isna:
        return CalculationMethod.north_america;
      case CalculationMethodOption.karachi:
        return CalculationMethod.karachi;
    }
  }
}

class PrayerTimeService extends ChangeNotifier {
  // Singleton pattern to ensure same state across all screens
  static final PrayerTimeService _instance = PrayerTimeService._internal();
  factory PrayerTimeService() => _instance;

  PrayerTimeService._internal() {
    _loadPreferences();
  }

  // ---------- Cities list ----------
  final List<City> availableCities = const [
    City(name: 'Your Location (GPS)', latitude: 0, longitude: 0),
    City(name: 'Mecca (مكة المكرمة)', latitude: 21.4225, longitude: 39.8262),
    City(name: 'Medina (المدينة المنورة)', latitude: 24.4672, longitude: 39.6111),
    City(name: 'Cairo (القاهرة)', latitude: 30.0444, longitude: 31.2357),
    City(name: 'Karachi (كراتشي)', latitude: 24.8607, longitude: 67.0011),
    City(name: 'London (لندن)', latitude: 51.5074, longitude: -0.1278),
    City(name: 'New York (نيويورك)', latitude: 40.7128, longitude: -74.0060),
    City(name: 'Jakarta (جاكرتا)', latitude: -6.2088, longitude: 106.8456),
    City(name: 'Kuala Lumpur (كوالالمبور)', latitude: 3.1390, longitude: 101.6869),
    City(name: 'Istanbul (إسطنبول)', latitude: 41.0082, longitude: 28.9784),
    City(name: 'Sydney (سيدني)', latitude: -33.8688, longitude: 151.2093),
    City(
  name: 'Addis Ababa (አዲስ አበባ)',
  latitude: 9.03,
  longitude: 38.74,
),
  ];

  City _selectedCity = const City(name: 'Your Location (GPS)', latitude: 0, longitude: 0);
  City get selectedCity => _selectedCity;
// ---------- Calculation method ----------
CalculationMethodOption _selectedMethod =
    CalculationMethodOption.ummAlQura;

CalculationMethodOption get selectedMethod => _selectedMethod;

  // ---------- Adhan style ----------
  AdhanStyle _selectedAdhanStyle = AdhanStyle.defaultStyle;
  AdhanStyle get selectedAdhanStyle => _selectedAdhanStyle;

  // Cached GPS coordinates
  double _cachedGpsLatitude = 0.0;
  double _cachedGpsLongitude = 0.0;
  double get cachedGpsLatitude => _cachedGpsLatitude;
  double get cachedGpsLongitude => _cachedGpsLongitude;

  // Fallback selected manual city (default to Addis Ababa)
  String _lastManualCityName = 'Addis Ababa (አዲስ አበባ)';
  double _lastManualCityLat = 9.03;
  double _lastManualCityLong = 38.74;

  // Streak system fields
  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  int _bestStreak = 0;
  int get bestStreak => _bestStreak;

  String _lastCheckInDate = "";
  String get lastCheckInDate => _lastCheckInDate;

  // Map of style to stable direct streaming audio urls from IslamCan
  final Map<AdhanStyle, String> adhanUrls = {
    AdhanStyle.defaultStyle: 'https://www.islamcan.com/audio/adhan/azan2.mp3',
    AdhanStyle.makkah: 'https://www.islamcan.com/audio/adhan/azan2.mp3',
    AdhanStyle.madinah: 'https://www.islamcan.com/audio/adhan/azan4.mp3',
    AdhanStyle.alaqsa: 'https://www.islamcan.com/audio/adhan/azan5.mp3',
  };

  // List of sunnah prayers (exactly 5 as requested by the user)
  static const List<SunnahPrayer> sunnahPrayers = [
    SunnahPrayer.beforeFajr,
    SunnahPrayer.duha,
    SunnahPrayer.beforeDhuhr,
    SunnahPrayer.tahajjud,
    SunnahPrayer.witr,
  ];

  // ---------- Preferences Cache ----------
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load selected city
      final cityName = prefs.getString('selected_city_name') ?? 'Your Location (GPS)';
      final cityLat = prefs.getDouble('selected_city_lat') ?? 0.0;
      final cityLong = prefs.getDouble('selected_city_long') ?? 0.0;
      _selectedCity = City(name: cityName, latitude: cityLat, longitude: cityLong);

      // Load cached GPS coords
      _cachedGpsLatitude = prefs.getDouble('cached_gps_lat') ?? 0.0;
      _cachedGpsLongitude = prefs.getDouble('cached_gps_long') ?? 0.0;

      // Load fallback manual city
      _lastManualCityName = prefs.getString('last_manual_city_name') ?? 'Addis Ababa (አዲስ አበባ)';
      _lastManualCityLat = prefs.getDouble('last_manual_city_lat') ?? 9.03;
      _lastManualCityLong = prefs.getDouble('last_manual_city_long') ?? 38.74;

      // Load calculation method
      final methodIndex = prefs.getInt('selected_calc_method') ?? 0;
      _selectedMethod = CalculationMethodOption.values[methodIndex];

      // Load adhan style
      final adhanIndex = prefs.getInt('selected_adhan_style') ?? 0;
      _selectedAdhanStyle = AdhanStyle.values[adhanIndex];

      // Load streak system values
      _currentStreak = prefs.getInt('spiritual_current_streak') ?? 0;
      _bestStreak = prefs.getInt('spiritual_best_streak') ?? 0;
      _lastCheckInDate = prefs.getString('spiritual_last_checkin_date') ?? "";

      debugPrint("[Preferences diagnostics] Preferences loaded successfully. Streak: $_currentStreak, Best: $_bestStreak, GPS: ($_cachedGpsLatitude, $_cachedGpsLongitude)");
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading preferences: $e");
    }
  }

  Future<void> setSelectedCity(City? city) async {
    if (city != null) {
      _selectedCity = city;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_city_name', city.name);
      await prefs.setDouble('selected_city_lat', city.latitude);
      await prefs.setDouble('selected_city_long', city.longitude);
      if (city.name != 'Your Location (GPS)') {
        _lastManualCityName = city.name;
        _lastManualCityLat = city.latitude;
        _lastManualCityLong = city.longitude;
        await prefs.setString('last_manual_city_name', city.name);
        await prefs.setDouble('last_manual_city_lat', city.latitude);
        await prefs.setDouble('last_manual_city_long', city.longitude);
      }
      debugPrint("[GPS Diagnostics] Selected City set to: ${city.name} (${city.latitude}, ${city.longitude})");
      notifyListeners();
    }
  }

  Future<void> setSelectedMethod(CalculationMethodOption method) async {
    _selectedMethod = method;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_calc_method', method.index);
    debugPrint("[Calculation method diagnostics] Method changed to: ${method.name}");
    notifyListeners();
  }

  Future<void> setSelectedAdhanStyle(AdhanStyle style) async {
    _selectedAdhanStyle = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_adhan_style', style.index);
    debugPrint("[Adhan Style diagnostics] Tone changed to: $style");
    notifyListeners();
  }

  // ---------- GPS Helper ----------
  Future<Position> _getCurrentPosition() async {
    if (_selectedCity.name != 'Your Location (GPS)' && _selectedCity.latitude != 0 && _selectedCity.longitude != 0) {
      return Position(
        latitude: _selectedCity.latitude,
        longitude: _selectedCity.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("[GPS Diagnostics] Location service disabled, fallback to cached coordinates.");
        return _getCachedPosition();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint("[GPS Diagnostics] GPS Permission denied, fallback to cached coordinates.");
          return _getCachedPosition();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("[GPS Diagnostics] GPS Permission denied forever, fallback to cached coordinates.");
        return _getCachedPosition();
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 4),
      );

      _cachedGpsLatitude = pos.latitude;
      _cachedGpsLongitude = pos.longitude;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cached_gps_lat', pos.latitude);
      await prefs.setDouble('cached_gps_long', pos.longitude);
      debugPrint("[GPS Diagnostics] Current position obtained: (${pos.latitude}, ${pos.longitude}) and cached.");

      return pos;
    } catch (e) {
      debugPrint("[GPS Diagnostics] GPS fetch failed: $e. Using cached coordinates.");
      return _getCachedPosition();
    }
  }

  Position _getCachedPosition() {
    if (_cachedGpsLatitude != 0.0 && _cachedGpsLongitude != 0.0) {
      debugPrint("[GPS Diagnostics] Using cached GPS coordinates: ($_cachedGpsLatitude, $_cachedGpsLongitude)");
      return Position(
        latitude: _cachedGpsLatitude,
        longitude: _cachedGpsLongitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
    debugPrint("[GPS Diagnostics] GPS denied and no cached GPS coordinates. Falling back to selected city: $_lastManualCityName ($_lastManualCityLat, $_lastManualCityLong)");
    return Position(
      latitude: _lastManualCityLat,
      longitude: _lastManualCityLong,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  Future<Coordinates> getEffectiveCoordinates() async {
    double lat = _selectedCity.latitude;
    double long = _selectedCity.longitude;

    if (_selectedCity.name == 'Your Location (GPS)' || (lat == 0.0 && long == 0.0)) {
      final pos = await _getCurrentPosition();
      lat = pos.latitude;
      long = pos.longitude;
      debugPrint("[GPS Diagnostics] Effective GPS location retrieved: Latitude $lat, Longitude $long");
    } else {
      debugPrint("[GPS Diagnostics] Manual city selected: ${_selectedCity.name} (Latitude $lat, Longitude $long)");
    }
    return Coordinates(lat, long);
  }

  // ---------- Streak System Operations ----------
  Future<void> checkInToday(bool isGentleMode) async {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

    final prefs = await SharedPreferences.getInstance();
    debugPrint("[Streak Diagnostics] Check-in run. Today: $todayStr, Yesterday: $yesterdayStr, Last Check-in: $_lastCheckInDate, Gentle Mode: $isGentleMode");

    if (_lastCheckInDate == todayStr) {
      debugPrint("[Streak Diagnostics] Already checked in today. Current Streak: $_currentStreak");
      return;
    }

    if (_lastCheckInDate == yesterdayStr) {
      _currentStreak++;
      debugPrint("[Streak Diagnostics] Streak incremented consecutively to: $_currentStreak");
    } else if (_lastCheckInDate.isEmpty) {
      _currentStreak = 1;
      debugPrint("[Streak Diagnostics] New streak initiated starting at 1.");
    } else {
      if (isGentleMode) {
        _currentStreak = _currentStreak > 0 ? _currentStreak : 1;
        debugPrint("[Streak Diagnostics] Missed day but preserved via Gentle Mode. Streak: $_currentStreak");
      } else {
        _currentStreak = 1;
        debugPrint("[Streak Diagnostics] Missed day without exemption. Streak reset to 1.");
      }
    }

    _lastCheckInDate = todayStr;
    if (_currentStreak > _bestStreak) {
      _bestStreak = _currentStreak;
    }

    await prefs.setInt('spiritual_current_streak', _currentStreak);
    await prefs.setInt('spiritual_best_streak', _bestStreak);
    await prefs.setString('spiritual_last_checkin_date', _lastCheckInDate);
    
    notifyListeners();
  }


  // ---------- Public API ----------
  /// Returns exact local prayer times for the given [city] and [date].
  /// Primary source: adhan package (local, on-device calculation from lat/long + date).
  /// This automatically adjusts for every city and every day — no hardcoding.
  Future<Map<String, DateTime>> getPrayerTimes([City? city, DateTime? date]) async {
    final activeCity = city ?? _selectedCity;
    double lat = activeCity.latitude;
    double long = activeCity.longitude;

    if (activeCity.name == 'Your Location (GPS)' || (lat == 0 && long == 0)) {
      final pos = await _getCurrentPosition();
      lat = pos.latitude;
      long = pos.longitude;
    }

    final now = date ?? DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // PRIMARY: local on-device mathematical calculation using adhan package
    // This uses current date + latitude + longitude + calculation method.
    // Times update automatically every day and for every city — no API needed.
    final coordinates = Coordinates(lat, long);
    final dateComponents = DateComponents(now.year, now.month, now.day);
    final params = _selectedMethod.adhanMethod.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    final localResults = {
      'Fajr': prayerTimes.fajr.toLocal(),
      'Sunrise': prayerTimes.sunrise.toLocal(),
      'Dhuhr': prayerTimes.dhuhr.toLocal(),
      'Asr': prayerTimes.asr.toLocal(),
      'Maghrib': prayerTimes.maghrib.toLocal(),
      'Isha': prayerTimes.isha.toLocal(),
    };

    debugPrint("[Prayer Times Diagnostics] adhan-package calculated times for $dateStr at ($lat, $long) using ${_selectedMethod.name}. Fajr: ${localResults['Fajr']}");
    return localResults;
  }

  /// Returns real next‑prayer info for the selected city.
  /// The returned map contains `name` (String) and `duration` (Duration).
  Map<String, dynamic> getNextPrayerInfo(City city) {
    double lat = city.latitude;
    double long = city.longitude;

    if (city.name == 'Your Location (GPS)' || (lat == 0 && long == 0)) {
      lat = _cachedGpsLatitude != 0.0 ? _cachedGpsLatitude : 21.4225;
      long = _cachedGpsLongitude != 0.0 ? _cachedGpsLongitude : 39.8262;
    }

    final coordinates = Coordinates(lat, long);
    final now = DateTime.now();
    final dateComponents = DateComponents(now.year, now.month, now.day);
    final params = _selectedMethod.adhanMethod.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    final Map<String, DateTime> today = {
      'Fajr': prayerTimes.fajr.toLocal(),
      'Sunrise': prayerTimes.sunrise.toLocal(),
      'Dhuhr': prayerTimes.dhuhr.toLocal(),
      'Asr': prayerTimes.asr.toLocal(),
      'Maghrib': prayerTimes.maghrib.toLocal(),
      'Isha': prayerTimes.isha.toLocal(),
    };

    debugPrint("[Next Prayer Diagnostics] Computing next prayer relative to $now");
    for (var entry in today.entries) {
      if (entry.value.isAfter(now)) {
        final duration = entry.value.difference(now);
        debugPrint("[Next Prayer Diagnostics] Next prayer is: ${entry.key} at ${entry.value} in ${duration.inHours}h ${duration.inMinutes.remainder(60)}m");
        return {
          'name': entry.key,
          'duration': duration,
        };
      }
    }

    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowComponents = DateComponents(tomorrow.year, tomorrow.month, tomorrow.day);
    final tomorrowTimes = PrayerTimes(coordinates, tomorrowComponents, params);
    final nextFajr = tomorrowTimes.fajr.toLocal();
    final duration = nextFajr.difference(now);

    debugPrint("[Next Prayer Diagnostics] Next prayer is tomorrow Fajr at $nextFajr in ${duration.inHours}h ${duration.inMinutes.remainder(60)}m");
    return {
      'name': 'Fajr',
      'duration': duration,
    };
  }

  /// Helper to format a DateTime into a user‑friendly string.
  String formatTime(DateTime time) => DateFormat.jm().format(time);
}

// Extension for SunnahPrayer to expose required properties.
extension SunnahPrayerExt on SunnahPrayer {
  String get key => toString().split('.').last;
  
  String get name {
    switch (this) {
      case SunnahPrayer.beforeFajr:
        return 'Before Fajr Sunnah';
      case SunnahPrayer.duha:
        return 'Duha (Chasht) Prayer';
      case SunnahPrayer.beforeDhuhr:
        return 'Before Dhuhr Sunnah';
      case SunnahPrayer.tahajjud:
        return 'Tahajjud Reminder';
      case SunnahPrayer.witr:
        return 'Witr Reminder';
    }
  }

  String get icon {
    switch (this) {
      case SunnahPrayer.beforeFajr:
        return '🌅';
      case SunnahPrayer.duha:
        return '☀️';
      case SunnahPrayer.beforeDhuhr:
        return '🕋';
      case SunnahPrayer.tahajjud:
        return '🌙';
      case SunnahPrayer.witr:
        return '📿';
    }
  }

  String get timeRange {
    switch (this) {
      case SunnahPrayer.beforeFajr:
        return 'Before Fajr Salah';
      case SunnahPrayer.duha:
        return 'After Sunrise till Dhuhr';
      case SunnahPrayer.beforeDhuhr:
        return 'Before Dhuhr Salah';
      case SunnahPrayer.tahajjud:
        return 'Last 1/3 of the Night';
      case SunnahPrayer.witr:
        return 'After Isha before sleep';
    }
  }

  String get description {
    switch (this) {
      case SunnahPrayer.beforeFajr:
        return 'Two voluntary units of prayer before Fajr obligatory prayer. The Prophet (PBUH) never left them.';
      case SunnahPrayer.duha:
        return 'Prayed in the morning, starting about 15 minutes after sunrise until 15 minutes before Dhuhr.';
      case SunnahPrayer.beforeDhuhr:
        return 'Four voluntary units (Rak\'ahs) prayed before the Dhuhr obligatory prayer.';
      case SunnahPrayer.tahajjud:
        return 'The highly recommended night vigil prayer, prayed after waking from sleep before Fajr.';
      case SunnahPrayer.witr:
        return 'The odd-numbered prayer performed at night, as the final prayer of the evening.';
    }
  }

  String get benefit {
    switch (this) {
      case SunnahPrayer.beforeFajr:
        return '"The two Rak\'ahs before Fajr are better than this world and everything in it." (Muslim)';
      case SunnahPrayer.duha:
        return '"In the morning, charity is due on every joint of your body... two rak\'ahs of Duha prayer suffices all of this." (Muslim)';
      case SunnahPrayer.beforeDhuhr:
        return '"Whoever performs four Rak\'ahs before Dhuhr and four after it, Allah makes him forbidden for the Fire." (Nasa\'i)';
      case SunnahPrayer.tahajjud:
        return '"Establish the night prayer, for it is the habit of the righteous before you, a means of drawing near to your Lord, an expiation for sins..." (Tirmidhi)';
      case SunnahPrayer.witr:
        return '"Indeed, Allah is Witr (One) and He loves the Witr prayer, so perform it." (Abu Dawud)';
    }
  }
}
