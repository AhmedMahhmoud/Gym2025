import 'package:gym/core/network/dio_service.dart';
import 'package:gym/features/workouts/data/models/unit_model.dart';

class UnitsService {
  static final UnitsService _instance = UnitsService._internal();
  factory UnitsService() => _instance;
  UnitsService._internal();

  final DioService _dioService = DioService();

  List<UnitModel>? _timeUnits;
  List<UnitModel>? _weightUnits;

  List<UnitModel> get timeUnits => _timeUnits ?? [];
  List<UnitModel> get weightUnits => _weightUnits ?? [];

  Future<void> initialize() async {
    await Future.wait([
      _loadTimeUnits(),
      _loadWeightUnits(),
    ]);
  }

  Future<void> _loadTimeUnits() async {
    try {
      final response = await _dioService.get('/api/Workouts/GetTimeUnit');
      final List<dynamic> data = response.data;
      _timeUnits = data.map((json) => UnitModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading time units: $e');
      _timeUnits = [];
    }
  }

  Future<void> _loadWeightUnits() async {
    try {
      final response = await _dioService.get('/api/Workouts/GetWeightUnit');
      final List<dynamic> data = response.data;
      _weightUnits = data.map((json) => UnitModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading weight units: $e');
      _weightUnits = [];
    }
  }

  // Helper methods to get specific units
  UnitModel? getTimeUnitById(String id) {
    return _timeUnits?.firstWhere((unit) => unit.id == id);
  }

  UnitModel? getWeightUnitById(String id) {
    return _weightUnits?.firstWhere((unit) => unit.id == id);
  }

  // Helper methods to get default units
  UnitModel? getDefaultTimeUnit() {
    return _timeUnits?.firstWhere((unit) => unit.title == 'Sec');
  }

  UnitModel? getDefaultWeightUnit() {
    return _weightUnits?.firstWhere((unit) => unit.title == 'Kg');
  }
}
