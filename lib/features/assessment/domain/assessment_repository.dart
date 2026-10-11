import '../../../shared/domain/app_types.dart';
import 'assessment.dart';

/// Contract separating assessment use cases from data source implementation.
abstract interface class AssessmentRepository {
  Future<List<Assessment>> getAvailable({AppLanguage? language});
}
