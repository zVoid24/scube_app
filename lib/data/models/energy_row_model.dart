class EnergyRowModel {
  final String date;
  final String runtime_reb;
  final String energy_reb;
  final String cost_reb;
  final String runtime_diesel;
  final String energy_diesel;
  final String cost_diesel;
  final String runtime_bess;
  final String energyIn_bess;
  final String energyOut_bess;
  EnergyRowModel({
    required this.date,
    required this.runtime_reb,
    required this.energy_reb,
    required this.cost_reb,
    required this.runtime_diesel,
    required this.energy_diesel,
    required this.cost_diesel,
    required this.runtime_bess,
    required this.energyIn_bess,
    required this.energyOut_bess,
  });
}
