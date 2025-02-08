import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../annotations.dart';

class DatasourceGenerator
    extends GeneratorForAnnotation<GenerateCrudDatasource> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          'GenerateCrudDatasource can only be applied to classes.',
          element: element);
    }

    final className = element.name;
    final lowerName = className.toLowerCase();

    // Group all imports at the top
    final imports = '''
import '../core/exception/exception.dart';
import '../data/models/${lowerName}_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '${lowerName}_remote_data_source.dart';
''';

    final classDefinition = '''
class ${className}RemoteDataSourceImpl implements ${className}RemoteDataSource {
  final SupabaseClient supabaseClient;
  const ${className}RemoteDataSourceImpl(this.supabaseClient);

  Future<T> _run<T>(Future<T> Function() function) async {
    try {
      return await function();
    } catch (e) {
      throw DatasourceError(message: e.toString());
    }
  }

  @override
  Future<${className}Model> create${className}(${className}Model ${lowerName}) {
    return _run(() async {
      final response = await supabaseClient
          .from('${lowerName}s')
          .insert(${lowerName}.toJson())
          .select();
      if (response.isEmpty) {
        throw DatasourceError(message: '${className} creation failed');
      }
      return ${className}Model.fromJson(response.first);
    });
  }

  @override
  Future<${className}Model> delete${className}(String id) {
    return _run(() async {
      final response =
          await supabaseClient.from('${lowerName}s').delete().eq('id', id).select();
      if (response.isEmpty) {
        throw DatasourceError(message: '${className} deletion failed');
      }
      return ${className}Model.fromJson(response.first);
    });
  }

  @override
  Future<${className}Model> find${className}(String id) {
    return _run(() async {
      final response =
          await supabaseClient.from('${lowerName}s').select().eq('id', id);
      if (response.isEmpty) {
        throw DatasourceError(message: '${className} not found');
      }
      return ${className}Model.fromJson(response.first);
    });
  }

  @override
  Future<List<${className}Model>> get${className}s() {
    return _run(() async {
      final response = await supabaseClient.from('${lowerName}s').select();
      return response.map((e) => ${className}Model.fromJson(e)).toList();
    });
  }

  @override
  Future<${className}Model> update${className}(${className}Model ${lowerName}) {
    return _run(() async {
      if (${lowerName}.id != null) {
        final response = await supabaseClient
            .from('${lowerName}s')
            .update(${lowerName}.toJson())
            .eq('id', ${lowerName}.id!)
            .select();
        if (response.isEmpty) {
          throw DatasourceError(message: '${className} update failed');
        }
        return ${className}Model.fromJson(response.first);
      }
      throw DatasourceError(message: '${className} ID not found');
    });
  }
}
''';

    return '$imports\n$classDefinition';
  }
}
