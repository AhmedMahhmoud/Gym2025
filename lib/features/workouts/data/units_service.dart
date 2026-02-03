import 'package:trackletics/core/network/dio_service.dart';
import 'package:trackletics/features/workouts/data/models/unit_model.dart';

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
    try {
      return _timeUnits?.firstWhere((unit) => unit.id == id);
    } catch (e) {
      return null;
    }
  }

  UnitModel? getWeightUnitById(String id) {
    try {
      return _weightUnits?.firstWhere((unit) => unit.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper methods to get default units
  UnitModel? getDefaultTimeUnit() {
    try {
      return _timeUnits?.firstWhere((unit) => unit.title == 'Sec');
    } catch (e) {
      // If no 'Sec' unit found, return the first available time unit or null
      return _timeUnits?.isNotEmpty == true ? _timeUnits!.first : null;
    }
  }

  UnitModel? getDefaultWeightUnit() {
    try {
      return _weightUnits?.firstWhere((unit) => unit.title == 'Kg');
    } catch (e) {
      // If no 'Kg' unit found, return the first available weight unit or null
      return _weightUnits?.isNotEmpty == true ? _weightUnits!.first : null;
    }
  }
}
