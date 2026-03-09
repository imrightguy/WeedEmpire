import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EmployeeRarity { common, rare, epic, legendary }

class Employee {
  final String id;
  final String name;
  final EmployeeRarity rarity;
  final String description;
  final String role; // 'lab', 'streets', or 'office'

  final double growSpeedMultiplier;
  final double sellSpeedMultiplier;
  final double maxStashMultiplier;
  final double streetCredMultiplier;

  Employee({
    required this.id,
    required this.name,
    required this.rarity,
    required this.description,
    required this.role,
    this.growSpeedMultiplier = 1.0,
    this.sellSpeedMultiplier = 1.0,
    this.maxStashMultiplier = 1.0,
    this.streetCredMultiplier = 1.0,
  });
}

class Strain {
  final String id;
  final String name;
  final int tier;
  final double baseGrowRate;
  final double sellPrice;
  final double unlockCost;

  Strain({
    required this.id,
    required this.name,
    required this.tier,
    required this.baseGrowRate,
    required this.sellPrice,
    required this.unlockCost,
  });
}

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

class GameEvent {
  final String id;
  final String title;
  final String description;
  final int durationSeconds;
  
  // Effects
  final double autoGrowModifier;
  final double customerSpawnModifier;

  GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.durationSeconds,
    this.autoGrowModifier = 1.0,
    this.customerSpawnModifier = 1.0,
  });
}

class GameLocation {
  final String id;
  final String name;
  final String description;
  final double cost;
  final double stashBoost;
  final String assetPath;

  GameLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.stashBoost,
    required this.assetPath,
  });
}

class GameState extends ChangeNotifier {
  double _cash = 0.0;
  int _goldBars = 0;
  int get goldBars => _goldBars;

  // Ad boost state
  bool _miracleGrowActive = false;
  double _miracleGrowTimeRemaining = 0;
  bool get miracleGrowActive => _miracleGrowActive;
  double get miracleGrowTimeRemaining => _miracleGrowTimeRemaining;

  // Strains definition
  final List<Strain> strains = [
    Strain(id: 'trailer_trash', name: 'Trailer Trash', tier: 1, baseGrowRate: 1.0, sellPrice: 10.0, unlockCost: 0),
    Strain(id: 'northern_lights', name: 'Northern Lights', tier: 2, baseGrowRate: 0.5, sellPrice: 30.0, unlockCost: 10000.0),
    Strain(id: 'purple_haze', name: 'Purple Haze', tier: 3, baseGrowRate: 0.2, sellPrice: 100.0, unlockCost: 50000.0),
    Strain(id: 'diamond_kush', name: 'Diamond Kush', tier: 4, baseGrowRate: 0.05, sellPrice: 5000.0, unlockCost: 500000.0),
  ];

  int _activeStrainIndex = 0;
  int get activeStrainIndex => _activeStrainIndex;
  Strain get activeStrain => strains[_activeStrainIndex];
  
  List<String> unlockedStrains = ['trailer_trash'];

  Map<String, double> stash = {
    'trailer_trash': 0.0,
    'northern_lights': 0.0,
    'purple_haze': 0.0,
    'diamond_kush': 0.0,
  };

  double get weedStash => stash.values.fold(0.0, (sum, val) => sum + val);
  double get activeStrainStash => stash[activeStrain.id] ?? 0.0;

  void setActiveStrain(String id) {
    if (unlockedStrains.contains(id)) {
      _activeStrainIndex = strains.indexWhere((s) => s.id == id);
      notifyListeners();
      _saveData();
    }
  }

  void unlockStrain(String id) {
    if (!unlockedStrains.contains(id)) {
      final s = strains.firstWhere((s) => s.id == id);
      if (_cash >= s.unlockCost) {
        _cash -= s.unlockCost;
        unlockedStrains.add(id);
        notifyListeners();
        _saveData();
      }
    }
  }

  // Locations
  int _currentLocationIndex = 0;
  int get currentLocationIndex => _currentLocationIndex;

  final List<GameLocation> locations = [
    GameLocation(id: 'rv_park', name: 'Shady RV Park', description: 'Where it all began.', cost: 0, stashBoost: 0, assetPath: 'trailer_park_bg.png'),
    GameLocation(id: 'garage', name: 'Suburban Garage', description: 'A quiet place in the burbs.', cost: 5000, stashBoost: 500, assetPath: 'garage_bg.png'),
    GameLocation(id: 'bunker', name: 'Underground Bunker', description: 'High tech, high capacity.', cost: 50000, stashBoost: 5000, assetPath: 'bunker_bg.png'),
    GameLocation(id: 'mansion', name: 'Cartel Mansion', description: 'You made it.', cost: 500000, stashBoost: 50000, assetPath: 'mansion_bg.png'),
  ];

  GameLocation get currentLocation => locations[_currentLocationIndex];

  // Events
  GameEvent? activeEvent;
  double _eventTimeRemaining = 0;
  double _customerSpawnModifier = 1.0;
  double get customerSpawnModifier => _customerSpawnModifier;

  // Employees System
  final List<Employee> availableEmployees = [
    Employee(id: 'c1', name: 'Trailer Park Trimmer', rarity: EmployeeRarity.common, role: 'lab', description: '+5% Grow Speed', growSpeedMultiplier: 1.05),
    Employee(id: 'c2', name: 'Corner Look-out', rarity: EmployeeRarity.common, role: 'streets', description: '+5% Sell Speed', sellSpeedMultiplier: 1.05),
    Employee(id: 'c3', name: 'Shady Bookkeeper', rarity: EmployeeRarity.common, role: 'office', description: '+5% Max Stash', maxStashMultiplier: 1.05),

    Employee(id: 'r1', name: 'Botany Student', rarity: EmployeeRarity.rare, role: 'lab', description: '+15% Grow Speed', growSpeedMultiplier: 1.15),
    Employee(id: 'r2', name: 'Smooth Talker', rarity: EmployeeRarity.rare, role: 'streets', description: '+15% Sell Speed', sellSpeedMultiplier: 1.15),
    Employee(id: 'r3', name: 'Cartel Accountant', rarity: EmployeeRarity.rare, role: 'office', description: '+10% Max Stash', maxStashMultiplier: 1.10),

    Employee(id: 'e1', name: 'Mad Scientist', rarity: EmployeeRarity.epic, role: 'lab', description: '+50% Grow Speed', growSpeedMultiplier: 1.50),
    Employee(id: 'e2', name: 'Corrupt Cop', rarity: EmployeeRarity.epic, role: 'streets', description: '+50% Street Cred on Bust', streetCredMultiplier: 1.50),
    Employee(id: 'e3', name: 'Slick Politician', rarity: EmployeeRarity.epic, role: 'office', description: '+50% Max Stash', maxStashMultiplier: 1.50),

    Employee(id: 'l1', name: 'Master Botanist', rarity: EmployeeRarity.legendary, role: 'lab', description: '+100% Grow & Sell Speed', growSpeedMultiplier: 2.0, sellSpeedMultiplier: 2.0),
    Employee(id: 'l2', name: 'Cartel Boss', rarity: EmployeeRarity.legendary, role: 'office', description: '+100% Street Cred & Stash', maxStashMultiplier: 2.0, streetCredMultiplier: 2.0),
  ];

  List<String> ownedEmployees = [];
  Map<String, String?> equippedEmployees = {
    'lab': null,
    'streets': null,
    'office': null,
  };

  void rollEmployee(double cost) {
    if (_cash >= cost) {
      _cash -= cost;
      double roll = Random().nextDouble();
      EmployeeRarity hitRarity;
      if (roll < 0.01) { hitRarity = EmployeeRarity.legendary; }
      else if (roll < 0.10) { hitRarity = EmployeeRarity.epic; }
      else if (roll < 0.40) { hitRarity = EmployeeRarity.rare; }
      else { hitRarity = EmployeeRarity.common; }

      final possible = availableEmployees.where((e) => e.rarity == hitRarity).toList();
      final hit = possible[Random().nextInt(possible.length)];
      
      if (!ownedEmployees.contains(hit.id)) {
        ownedEmployees.add(hit.id);
      } else {
        // Duplicate compensation
        _streetCred += 1;
      }
      notifyListeners();
      _saveData();
    }
  }

  void equipEmployee(String id, String role) {
    if (ownedEmployees.contains(id)) {
      final emp = availableEmployees.firstWhere((e) => e.id == id);
      if (emp.role == role) {
        equippedEmployees[role] = id;
        notifyListeners();
        _saveData();
      }
    }
  }

  void unequipEmployee(String role) {
    equippedEmployees[role] = null;
    notifyListeners();
    _saveData();
  }

  Employee? getEquippedForRole(String role) {
    if (equippedEmployees[role] != null) {
      return availableEmployees.firstWhere((e) => e.id == equippedEmployees[role]);
    }
    return null;
  }

  double get employeeGrowMultiplier => (getEquippedForRole('lab')?.growSpeedMultiplier ?? 1.0) * (getEquippedForRole('office')?.growSpeedMultiplier ?? 1.0) * (getEquippedForRole('streets')?.growSpeedMultiplier ?? 1.0);
  double get employeeSellMultiplier => (getEquippedForRole('lab')?.sellSpeedMultiplier ?? 1.0) * (getEquippedForRole('office')?.sellSpeedMultiplier ?? 1.0) * (getEquippedForRole('streets')?.sellSpeedMultiplier ?? 1.0);
  double get employeeStashMultiplier => (getEquippedForRole('lab')?.maxStashMultiplier ?? 1.0) * (getEquippedForRole('office')?.maxStashMultiplier ?? 1.0) * (getEquippedForRole('streets')?.maxStashMultiplier ?? 1.0);
  double get employeeCredMultiplier => (getEquippedForRole('lab')?.streetCredMultiplier ?? 1.0) * (getEquippedForRole('office')?.streetCredMultiplier ?? 1.0) * (getEquippedForRole('streets')?.streetCredMultiplier ?? 1.0);

  // Prestige / Meta variables
  int _streetCred = 0;
  int _totalBusts = 0;

  // Core Stats
  final double _baseMaxStash = 10.0;
  final double _baseAutoSellRate = 0.0; 

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
  int get streetCred => _streetCred;
  int get totalBusts => _totalBusts;

  double get maxStash {
    return (_baseMaxStash + currentLocation.stashBoost + upgrades.fold(0.0, (sum, u) => sum + (u.level * u.maxStashBoost))) * employeeStashMultiplier;
  }
  
  double get autoGrowRate {
    return (activeStrain.baseGrowRate + upgrades.fold(0.0, (sum, u) => sum + (u.level * u.autoGrowRateBoost))) * employeeGrowMultiplier;
  }

  double get autoSellRate {
    return (_baseAutoSellRate + upgrades.fold(0.0, (sum, u) => sum + (u.level * u.autoSellRateBoost))) * employeeSellMultiplier;
  }

  // Save/Load System
  DateTime? _lastSaved;
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  bool _enableVisualUpgrades = true;
  bool get enableVisualUpgrades => _enableVisualUpgrades;
  
  bool _isGodMode = true;
  bool get isGodMode => _isGodMode;

  void toggleVisualUpgrades(bool value) {
     _enableVisualUpgrades = value;
     notifyListeners();
     _saveData();
  }

  void toggleGodMode() {
    _isGodMode = !_isGodMode;
    notifyListeners();
  }

  Future<void> initSaveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _cash = prefs.getDouble('cash') ?? 0.0;
    _goldBars = prefs.getInt('goldBars') ?? 0;
    _streetCred = prefs.getInt('streetCred') ?? 0;
    _totalBusts = prefs.getInt('totalBusts') ?? 0;
    _enableVisualUpgrades = prefs.getBool('visuals') ?? true;
    _currentLocationIndex = prefs.getInt('locationIndex') ?? 0;

    // Load new stash format or migrate old
    final oldStash = prefs.getDouble('weedStash');
    if (oldStash != null) {
      stash['trailer_trash'] = oldStash;
      prefs.remove('weedStash'); // Clean up old
    } else {
      final String? stashJson = prefs.getString('stashData');
      if (stashJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(stashJson);
        for (var key in decoded.keys) {
          stash[key] = (decoded[key] as num).toDouble();
        }
      }
    }

    final String? unlockedJson = prefs.getString('unlockedStrains');
    if (unlockedJson != null) {
      unlockedStrains = List<String>.from(jsonDecode(unlockedJson));
    }
    _activeStrainIndex = prefs.getInt('activeStrainIndex') ?? 0;

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

    final String? ownedEmployeesJson = prefs.getString('ownedEmployees');
    if (ownedEmployeesJson != null) {
      ownedEmployees = List<String>.from(jsonDecode(ownedEmployeesJson));
    }

    final String? equippedEmployeesJson = prefs.getString('equippedEmployees');
    if (equippedEmployeesJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(equippedEmployeesJson);
      equippedEmployees = {
        'lab': decoded['lab'],
        'streets': decoded['streets'],
        'office': decoded['office'],
      };
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
        if (weedStash + generated > maxStash) {
           stash[activeStrain.id] = (stash[activeStrain.id] ?? 0) + (maxStash - weedStash);
        } else {
           stash[activeStrain.id] = (stash[activeStrain.id] ?? 0) + generated;
        }
        debugPrint("Offline Progress: Generated ${generated.toStringAsFixed(2)}g of ${activeStrain.name} over $secondsPassed seconds.");
      }

      if (autoSellRate > 0) {
        final toSell = (secondsPassed * autoSellRate).clamp(0.0, activeStrainStash);
        stash[activeStrain.id] = stash[activeStrain.id]! - toSell;
        _cash += toSell * activeStrain.sellPrice;
        debugPrint("Offline Progress: Sold ${toSell.toStringAsFixed(2)}g over $secondsPassed seconds.");
      }
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('cash', _cash);
    await prefs.setInt('goldBars', _goldBars);
    await prefs.setInt('streetCred', _streetCred);
    await prefs.setInt('totalBusts', _totalBusts);
    await prefs.setBool('visuals', _enableVisualUpgrades);
    await prefs.setInt('locationIndex', _currentLocationIndex);
    
    await prefs.setString('stashData', jsonEncode(stash));
    await prefs.setString('unlockedStrains', jsonEncode(unlockedStrains));
    await prefs.setInt('activeStrainIndex', _activeStrainIndex);
    
    final encodedUpgrades = jsonEncode(upgrades.map((u) => u.toJson()).toList());
    await prefs.setString('upgrades', encodedUpgrades);

    await prefs.setString('ownedEmployees', jsonEncode(ownedEmployees));
    await prefs.setString('equippedEmployees', jsonEncode(equippedEmployees));
    
    await prefs.setInt('lastSaved', DateTime.now().millisecondsSinceEpoch);
  }

  double _timeSinceLastEvent = 0;
  final double _eventCooldown = 60.0; // 60s cooldown

  void tick(double dt) {
    if (!_isLoaded) return;
    
    bool changed = false;

    // Miracle Grow boost timer
    if (_miracleGrowActive) {
      _miracleGrowTimeRemaining -= dt;
      if (_miracleGrowTimeRemaining <= 0) {
        _miracleGrowActive = false;
        _miracleGrowTimeRemaining = 0;
      }
      changed = true;
    }

    // Event Loop
    if (activeEvent != null) {
       _eventTimeRemaining -= dt;
       if (_eventTimeRemaining <= 0) {
          activeEvent = null;
          _customerSpawnModifier = 1.0;
          _timeSinceLastEvent = 0;
          changed = true;
       }
    } else {
       _timeSinceLastEvent += dt;
       if (_timeSinceLastEvent > _eventCooldown) {
          if (DateTime.now().millisecond % 1000 < 10) { 
             _triggerRandomEvent();
             changed = true;
          }
       }
    }

    if (autoGrowRate > 0) {
      double growMultiplier = _miracleGrowActive ? 5.0 : 1.0;
      double generated = (autoGrowRate * growMultiplier * (activeEvent?.autoGrowModifier ?? 1.0)) * dt;
      if (weedStash < maxStash) {
        if (weedStash + generated > maxStash) {
           generated = maxStash - weedStash;
        }
        stash[activeStrain.id] = (stash[activeStrain.id] ?? 0) + generated;
        changed = true;
      }
    }

    if (autoSellRate > 0) {
      double sold = (autoSellRate * (activeEvent?.customerSpawnModifier ?? 1.0)) * dt;
      if (sold > activeStrainStash) {
        sold = activeStrainStash; 
      }
      if (sold > 0) {
        stash[activeStrain.id] = stash[activeStrain.id]! - sold;
        _cash += sold * activeStrain.sellPrice;
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
      _throttleSave(); 
    }
  }

  void _triggerRandomEvent() {
    activeEvent = GameEvent(
       id: 'fake_news',
       title: 'FAKE NEWS SMEAR',
       description: 'The Elite Cabal claims your weed causes dancing!\nCustomers are staying away.',
       durationSeconds: 30,
       customerSpawnModifier: 0.2, 
    );
    _eventTimeRemaining = activeEvent!.durationSeconds.toDouble();
    _customerSpawnModifier = activeEvent!.customerSpawnModifier;
  }

  void resolveEventWithCred() {
    if (activeEvent != null && _streetCred >= 10) {
       _streetCred -= 10;
       activeEvent = null;
       _customerSpawnModifier = 1.0;
       _timeSinceLastEvent = 0;
       notifyListeners();
       _saveData();
    }
  }

  DateTime _lastSaveCall = DateTime.now();
  void _throttleSave() {
     if (DateTime.now().difference(_lastSaveCall).inSeconds > 2) {
       _saveData();
       _lastSaveCall = DateTime.now();
     }
  }

  void growWeed(double amount) {
    if (weedStash < maxStash) {
      double added = amount;
      if (weedStash + amount > maxStash) {
         added = maxStash - weedStash;
      }
      stash[activeStrain.id] = (stash[activeStrain.id] ?? 0) + added;
      notifyListeners();
      _throttleSave();
    }
  }

  void sellWeed(double amount) {
    if (activeStrainStash >= amount) {
      stash[activeStrain.id] = stash[activeStrain.id]! - amount;
      _cash += amount * activeStrain.sellPrice;
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

  void buyLocation(int index) {
    if (index > _currentLocationIndex && index < locations.length) {
      final loc = locations[index];
      if (_cash >= loc.cost) {
        _cash -= loc.cost;
        _currentLocationIndex = index;
        notifyListeners();
        _saveData();
      }
    }
  }

  void triggerBust() {
    _streetCred += (((_cash / 1000).floor() + 1) * employeeCredMultiplier).floor();
    _totalBusts++;

    _cash = 0;
    stash.updateAll((key, value) => 0.0);
    for (var u in upgrades) {
      u.level = 0;
    }

    notifyListeners();
    _saveData();
  }

  // --- MONETIZATION ---

  /// "Morning Rush" reward: doubles offline earnings
  void claimMorningRush(double offlineEarnings) {
    _cash += offlineEarnings; // doubles what was already added
    notifyListeners();
    _saveData();
  }

  /// "Miracle Grow" reward: 5x grow speed for 15 minutes
  void activateMiracleGrow() {
    _miracleGrowActive = true;
    _miracleGrowTimeRemaining = 900.0; // 15 min
    notifyListeners();
  }

  /// "Get Out of Jail Free" — nullify a bust
  void nullifyBust() {
    // Called instead of triggerBust when user watches the ad
    notifyListeners();
  }

  /// Time Warp — skip forward N hours of production
  void timeWarp(int hours, int goldBarCost) {
    if (_goldBars >= goldBarCost) {
      _goldBars -= goldBarCost;
      final seconds = hours * 3600;
      if (autoGrowRate > 0) {
        final generated = (seconds * autoGrowRate).clamp(0.0, maxStash - weedStash);
        stash[activeStrain.id] = (stash[activeStrain.id] ?? 0) + generated;
      }
      if (autoSellRate > 0) {
        final toSell = (seconds * autoSellRate).clamp(0.0, activeStrainStash);
        stash[activeStrain.id] = stash[activeStrain.id]! - toSell;
        _cash += toSell * activeStrain.sellPrice;
      }
      notifyListeners();
      _saveData();
    }
  }

  /// Golden Safe — guaranteed Epic or Legendary for Gold Bars
  void rollGoldenSafe(int goldBarCost) {
    if (_goldBars >= goldBarCost) {
      _goldBars -= goldBarCost;
      double roll = Random().nextDouble();
      EmployeeRarity hitRarity = roll < 0.15 ? EmployeeRarity.legendary : EmployeeRarity.epic;
      
      final possible = availableEmployees.where((e) => e.rarity == hitRarity).toList();
      final hit = possible[Random().nextInt(possible.length)];
      
      if (!ownedEmployees.contains(hit.id)) {
        ownedEmployees.add(hit.id);
      } else {
        _streetCred += 5; // better dupe compensation
      }
      notifyListeners();
      _saveData();
    }
  }

  /// Add Gold Bars (from IAP or milestone rewards)
  void addGoldBars(int amount) {
    _goldBars += amount;
    notifyListeners();
    _saveData();
  }
}
