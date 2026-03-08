import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Upgrade {
  final String id;
  final String name;
  final String description;
  double baseCost;
  double costMultiplier;
  int level;
  
  // Effects
  double autoGrowRateBoost;
  double maxStashBoost;
  double autoSellRateBoost;

  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    this.costMultiplier = 1.15,
    this.level = 0,
    this.autoGrowRateBoost = 0.0,
    this.maxStashBoost = 0.0,
    this.autoSellRateBoost = 0.0,
  });

  double get currentCost => baseCost * (1 + (level * (costMultiplier - 1)));

  Map<String, dynamic> toJson() => {
    'id': id,
    'level': level,
  };

  void loadFromJson(Map<String, dynamic> json) {
    if (json['id'] == id) {
      level = json['level'] ?? 0;
    }
  }
}

class GameState extends ChangeNotifier {
  double _cash = 0.0;
  double _weedStash = 0.0;
  final double _weedPrice = 10.0; // $10 per gram

  // Prestige / Meta variables
  int _streetCred = 0;
  int _totalBusts = 0;

  // Core Stats
  final double _baseMaxStash = 10.0;
  final double _baseAutoGrowRate = 0.0; // grams per second
  final double _baseAutoSellRate = 0.0; // grams per second

  // Upgrades
  final List<Upgrade> upgrades = [
    Upgrade(
      id: 'heat_lamp',
      name: 'Heat Lamp',
      description: 'Increases auto-grow rate by 0.5g/s',
      baseCost: 50.0,
      autoGrowRateBoost: 0.5,
    ),
    Upgrade(
      id: 'shed_expansion',
      name: 'Shed Expansion',
      description: 'Increases max stash size by 50g',
      baseCost: 150.0,
      maxStashBoost: 50.0,
    ),
    Upgrade(
      id: 'corner_dealer',
      name: 'Corner Dealer (Hire)',
      description: 'Automatically sells 0.5g/s for you',
      baseCost: 500.0,
      autoSellRateBoost: 0.5,
    ),
  ];

  double get cash => _cash;
  double get weedStash => _weedStash;
  int get streetCred => _streetCred;
  int get totalBusts => _totalBusts;

  double get maxStash {
    return _baseMaxStash + upgrades.fold(0.0, (sum, u) => sum + (u.level * u.maxStashBoost));
  }
  
  double get autoGrowRate {
    return _baseAutoGrowRate + upgrades.fold(0.0, (sum, u) => sum + (u.level * u.autoGrowRateBoost));
  }

  double get autoSellRate {
    return _baseAutoSellRate + upgrades.fold(0.0, (sum, u) => sum + (u.level * u.autoSellRateBoost));
  }

  // Save/Load System
  DateTime? _lastSaved;
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  bool _enableVisualUpgrades = true;
  bool get enableVisualUpgrades => _enableVisualUpgrades;

  void toggleVisualUpgrades(bool value) {
     _enableVisualUpgrades = value;
     notifyListeners();
     _saveData();
  }

  Future<void> initSaveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _cash = prefs.getDouble('cash') ?? 0.0;
    _weedStash = prefs.getDouble('weedStash') ?? 0.0;
    _streetCred = prefs.getInt('streetCred') ?? 0;
    _totalBusts = prefs.getInt('totalBusts') ?? 0;
    _enableVisualUpgrades = prefs.getBool('visuals') ?? true;

    final String? upgradesJson = prefs.getString('upgrades');
    if (upgradesJson != null) {
      final List<dynamic> decoded = jsonDecode(upgradesJson);
      for (var jsonUpgrade in decoded) {
        final upgrade = upgrades.firstWhere((u) => u.id == jsonUpgrade['id'], orElse: () => upgrades.first);
        if (upgrade.id == jsonUpgrade['id']) {
           upgrade.loadFromJson(jsonUpgrade);
        }
      }
    }

    final int? lastSavedEpoch = prefs.getInt('lastSaved');
    if (lastSavedEpoch != null) {
      _lastSaved = DateTime.fromMillisecondsSinceEpoch(lastSavedEpoch);
      _calculateOfflineProgress();
    }

    _isLoaded = true;
    notifyListeners();
  }

  void _calculateOfflineProgress() {
    if (_lastSaved == null) return;

    final now = DateTime.now();
    final difference = now.difference(_lastSaved!);
    final secondsPassed = difference.inSeconds;

    if (secondsPassed > 0) {
      if (autoGrowRate > 0) {
        final generated = secondsPassed * autoGrowRate;
        _weedStash += generated;
        if (_weedStash > maxStash) {
          _weedStash = maxStash;
        }
        debugPrint("Offline Progress: Generated ${generated.toStringAsFixed(2)}g over $secondsPassed seconds.");
      }

      if (autoSellRate > 0) {
        // Technically this should be a complex simulation (grow, then sell, then cap), 
        // but for a simple idle game we just estimate:
        final toSell = (secondsPassed * autoSellRate).clamp(0.0, _weedStash);
        _weedStash -= toSell;
        _cash += toSell * _weedPrice;
        debugPrint("Offline Progress: Sold ${toSell.toStringAsFixed(2)}g over $secondsPassed seconds.");
      }
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('cash', _cash);
    await prefs.setDouble('weedStash', _weedStash);
    await prefs.setInt('streetCred', _streetCred);
    await prefs.setInt('totalBusts', _totalBusts);
    await prefs.setBool('visuals', _enableVisualUpgrades);
    
    final encodedUpgrades = jsonEncode(upgrades.map((u) => u.toJson()).toList());
    await prefs.setString('upgrades', encodedUpgrades);
    
    await prefs.setInt('lastSaved', DateTime.now().millisecondsSinceEpoch);
  }

  // --- Game Mechanics ---

  void tick(double dt) {
    if (!_isLoaded) return;
    
    bool changed = false;

    if (autoGrowRate > 0) {
      double generated = autoGrowRate * dt;
      if (_weedStash < maxStash) {
        _weedStash += generated;
        if (_weedStash > maxStash) {
          _weedStash = maxStash;
        }
        changed = true;
      }
    }

    if (autoSellRate > 0) {
      double sold = autoSellRate * dt;
      if (sold > _weedStash) {
        sold = _weedStash; // Don't sell more than we have
      }
      if (sold > 0) {
        _weedStash -= sold;
        _cash += sold * _weedPrice;
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
      // Throttling save to avoid writing thousands of times per second
      _throttleSave(); 
    }
  }

  // Simple throttler for manual interactions to avoid save spam loop
  DateTime _lastSaveCall = DateTime.now();
  void _throttleSave() {
     if (DateTime.now().difference(_lastSaveCall).inSeconds > 2) {
       _saveData();
       _lastSaveCall = DateTime.now();
     }
  }

  void growWeed(double amount) {
    if (_weedStash < maxStash) {
      _weedStash += amount;
      if (_weedStash > maxStash) {
        _weedStash = maxStash;
      }
      notifyListeners();
      _throttleSave();
    }
  }

  void sellWeed(double amount) {
    if (_weedStash >= amount) {
      _weedStash -= amount;
      _cash += amount * _weedPrice;
      notifyListeners();
      _throttleSave();
    }
  }

  void buyUpgrade(String id) {
    final upgrade = upgrades.firstWhere((u) => u.id == id);
    if (_cash >= upgrade.currentCost) {
      _cash -= upgrade.currentCost;
      upgrade.level++;
      notifyListeners();
      _saveData();
    }
  }

  void triggerBust() {
    // Basic prestige calculation mapping net earnings to Cred
    _streetCred += (_cash / 1000).floor() + 1; 
    _totalBusts++;

    // Reset loop
    _cash = 0;
    _weedStash = 0;
    for (var u in upgrades) {
      u.level = 0;
    }

    notifyListeners();
    _saveData();
  }
}


