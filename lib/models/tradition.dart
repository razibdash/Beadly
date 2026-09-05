import 'package:flutter/material.dart';

/// Identifies a supported prayer/chant tradition.
enum TraditionId { hindu, islam, christian, buddhist, sikh, custom }

/// Static metadata describing a tradition: its default chant, target count,
/// and the icon shown on the tradition-selection screen. The rest of the app
/// shell (layout, navigation, screens) is identical across traditions - only
/// these values change.
class Tradition {
  final TraditionId id;
  final String label;
  final String subtitle;
  final String defaultChant;
  final int defaultTarget;
  final IconData icon;

  const Tradition({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.defaultChant,
    required this.defaultTarget,
    required this.icon,
  });

  static const List<Tradition> all = [
    Tradition(
      id: TraditionId.hindu,
      label: 'Sanatan / Hindu',
      subtitle: 'Japa mala — 108 beads',
      defaultChant: 'Hare Krishna Maha Mantra',
      defaultTarget: 108,
      icon: Icons.circle_outlined,
    ),
    Tradition(
      id: TraditionId.islam,
      label: 'Islam',
      subtitle: 'Tasbih / Dhikr — 33 or 99',
      defaultChant: 'SubhanAllah',
      defaultTarget: 33,
      icon: Icons.brightness_2_outlined,
    ),
    Tradition(
      id: TraditionId.christian,
      label: 'Christianity',
      subtitle: 'Rosary — 50 or 59',
      defaultChant: 'Hail Mary',
      defaultTarget: 59,
      icon: Icons.add_outlined,
    ),
    Tradition(
      id: TraditionId.buddhist,
      label: 'Buddhism',
      subtitle: 'Mala — 108 beads',
      defaultChant: 'Om Mani Padme Hum',
      defaultTarget: 108,
      icon: Icons.data_usage_outlined,
    ),
    Tradition(
      id: TraditionId.sikh,
      label: 'Sikhism',
      subtitle: 'Naam Simran',
      defaultChant: 'Waheguru',
      defaultTarget: 108,
      icon: Icons.hexagon_outlined,
    ),
    Tradition(
      id: TraditionId.custom,
      label: 'Custom / Other',
      subtitle: 'Set your own target count',
      defaultChant: 'My Chant',
      defaultTarget: 108,
      icon: Icons.adjust_outlined,
    ),
  ];

  static Tradition byId(TraditionId id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all.first);

  static Tradition fromName(String name) {
    final id = TraditionId.values.firstWhere(
      (e) => e.name == name,
      orElse: () => TraditionId.custom,
    );
    return byId(id);
  }
}
