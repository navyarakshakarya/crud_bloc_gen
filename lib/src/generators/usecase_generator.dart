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

    return '''
import 'package:fpdart/fpdart.dart';
import '../core/exception/exception.dart';
import '../core/usecase/usecase.dart';
import '../data/models/${className.toLowerCase()}_model.dart';
import '../domain/repositories/${className.toLowerCase()}_repository.dart';

class Find${className}UseCase implements UseCase<${className}Model, String> {
  final ${className}Repository _${className.toLowerCase()}Repository;
  Find${className}UseCase(this._${className.toLowerCase()}Repository);

  @override
  Future<Either<APIException?, ${className}Model?>?> call(String? params) {
    return _${className.toLowerCase()}Repository.find${className}(params);
  }
}

class Get${className}sUseCase implements UseCase<List<${className}Model>, NoParams> {
  final ${className}Repository _${className.toLowerCase()}Repository;
  Get${className}sUseCase(this._${className.toLowerCase()}Repository);

  @override
  Future<Either<APIException?, List<${className}Model>?>?> call(NoParams? params) {
    return _${className.toLowerCase()}Repository.get${className}s();
  }
}

class Create${className}UseCase implements UseCase<${className}Model, Create${className}UseCaseParams> {
  final ${className}Repository _${className.toLowerCase()}Repository;
  Create${className}UseCase(this._${className.toLowerCase()}Repository);

  @override
  Future<Either<APIException?, ${className}Model?>?> call(Create${className}UseCaseParams? params) {
    return _${className.toLowerCase()}Repository.create${className}(params!);
  }
}

class Update${className}UseCase implements UseCase<${className}Model, Update${className}UseCaseParams> {
  final ${className}Repository _${className.toLowerCase()}Repository;
  Update${className}UseCase(this._${className.toLowerCase()}Repository);

  @override
  Future<Either<APIException?, ${className}Model?>?> call(Update${className}UseCaseParams? params) {
    return _${className.toLowerCase()}Repository.update${className}(params!);
  }
}

class Delete${className}UseCase implements UseCase<${className}Model, String> {
  final ${className}Repository _${className.toLowerCase()}Repository;
  Delete${className}UseCase(this._${className.toLowerCase()}Repository);

  @override
  Future<Either<APIException?, ${className}Model?>?> call(String? params) {
    return _${className.toLowerCase()}Repository.delete${className}(params);
  }
}

// Add UseCase params classes here...
''';
  }
}
