import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../annotations.dart';

class UseCaseGenerator extends GeneratorForAnnotation<GenerateCrudUseCases> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          'GenerateCrudUseCases can only be applied to classes.',
          element: element);
    }

    final className = element.name;
    final lowerName = className.toLowerCase();

    // Group all imports at the top
    final imports = '''
import 'package:fpdart/fpdart.dart';
import '../core/exception/exception.dart';
import '../core/usecase/usecase.dart';
import '../data/models/${lowerName}_model.dart';
import '../domain/repositories/${lowerName}_repository.dart';
''';

    final classDefinitions = '''
class Find${className}UseCase implements UseCase<${className}Model, String> {
  final ${className}Repository _${lowerName}Repository;
  Find${className}UseCase(this._${lowerName}Repository);

  @override
  Future<Either<APIException?, ${className}Model?>?> call(String? params) {
    return _${lowerName}Repository.find${className}(params);
  }
}

class Get${className}sUseCase implements UseCase<List<${className}Model>, NoParams> {
  final ${className}Repository _${lowerName}Repository;
  Get${className}sUseCase(this._${lowerName}Repository);

  @override
  Future<Either<APIException?, List<${className}Model>?>?> call(NoParams? params) {
    return _${lowerName}Repository.get${className}s();
  }
}

class Create${className}UseCase implements UseCase<${className}Model, Create${className}UseCaseParams> {
  final ${className}Repository _${lowerName}Repository;
  Create${className}UseCase(this._${lowerName}Repository);

  @override
  Future<Either<APIException?, ${className}Model?>?> call(Create${className}UseCaseParams? params) {
    return _${lowerName}Repository.create${className}(params!);
  }
}

class Update${className}UseCase implements UseCase<${className}Model, Update${className}UseCaseParams> {
  final ${className}Repository _${lowerName}Repository;
  Update${className}UseCase(this._${lowerName}Repository);

  @override
  Future<Either<APIException?, ${className}Model?>?> call(Update${className}UseCaseParams? params) {
    return _${lowerName}Repository.update${className}(params!);
  }
}

class Delete${className}UseCase implements UseCase<${className}Model, String> {
  final ${className}Repository _${lowerName}Repository;
  Delete${className}UseCase(this._${lowerName}Repository);

  @override
  Future<Either<APIException?, ${className}Model?>?> call(String? params) {
    return _${lowerName}Repository.delete${className}(params);
  }
}

// Add UseCase params classes here...
''';

    return '$imports\n$classDefinitions';
  }
}
