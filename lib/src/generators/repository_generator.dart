import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../annotations.dart';

class RepositoryGenerator
    extends GeneratorForAnnotation<GenerateCrudRepository> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          'GenerateCrudRepository can only be applied to classes.',
          element: element);
    }

    final className = element.name;

    return '''
import 'package:fpdart/fpdart.dart';
import '../core/exception/exception.dart';
import '../data/models/${className.toLowerCase()}_model.dart';
import '../domain/use_cases/create_${className.toLowerCase()}_usecase.dart';
import '../domain/use_cases/update_${className.toLowerCase()}_usecase.dart';

abstract interface class ${className}Repository {
  Future<Either<APIException?, List<${className}Model>?>?> get${className}s();
  Future<Either<APIException?, ${className}Model?>?> find${className}(String? id);
  Future<Either<APIException?, ${className}Model?>?> create${className}(Create${className}UseCaseParams params);
  Future<Either<APIException?, ${className}Model?>?> update${className}(Update${className}UseCaseParams params);
  Future<Either<APIException?, ${className}Model?>?> delete${className}(String? params);
}

class ${className}RepositoryImpl implements ${className}Repository {
  final ${className}RemoteDataSource dataSource;
  const ${className}RepositoryImpl(this.dataSource);

  Future<Either<APIException?, T?>?> _run<T>(Future<T> Function() function) async {
    try {
      final response = await function();
      return right(response);
    } on DatasourceError catch (e) {
      return left(APIException(message: 'DatasourceError: \$e'));
    }
  }

  @override
  Future<Either<APIException?, ${className}Model?>?> find${className}(String? id) {
    return _run(() => dataSource.find${className}(id!));
  }

  @override
  Future<Either<APIException?, List<${className}Model>?>?> get${className}s() {
    return _run(() => dataSource.get${className}s());
  }

  @override
  Future<Either<APIException?, ${className}Model?>?> create${className}(Create${className}UseCaseParams params) {
    return _run(() => dataSource.create${className}(params.toModel()));
  }

  @override
  Future<Either<APIException?, ${className}Model?>?> update${className}(Update${className}UseCaseParams params) {
    return _run(() => dataSource.update${className}(params.toModel()));
  }

  @override
  Future<Either<APIException?, ${className}Model?>?> delete${className}(String? params) {
    return _run(() => dataSource.delete${className}(params!));
  }
}
''';
  }
}
