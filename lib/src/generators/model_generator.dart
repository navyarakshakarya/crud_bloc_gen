import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../annotations.dart';

class ModelGenerator extends GeneratorForAnnotation<GenerateCrudModel> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          'GenerateCrudModel can only be applied to classes.',
          element: element);
    }

    final className = element.name;
    final lowerName = className.toLowerCase();

    // Group all imports at the top
    final imports = '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${lowerName}_model.freezed.dart';
part '${lowerName}_model.g.dart';
''';

    final fields = element.fields.where((f) => !f.isStatic);
    final fieldDeclarations =
        fields.map((f) => '    required ${f.type} ${f.name},').join('\n');
    final fieldAssignments =
        fields.map((f) => '        ${f.name}: ${f.name},').join('\n');

    final classDefinition = '''
@freezed
class ${className}Model with _\$${className}Model {
  const ${className}Model._();

  const factory ${className}Model({
$fieldDeclarations
  }) = _${className}Model;

  factory ${className}Model.fromJson(Map<String, dynamic> json) =>
      _\$${className}ModelFromJson(json);

  $className toEntity() => $className(
$fieldAssignments
      );
}
''';

    return '$imports\n$classDefinition';
  }
}
