import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../annotations.dart';

class BlocGenerator extends GeneratorForAnnotation<GenerateCrudBloc> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          'GenerateCrudBloc can only be applied to classes.',
          element: element);
    }

    final className = element.name;
    final lowerName = className.toLowerCase();

    // Group all imports at the top
    final imports = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/entities/${lowerName}.dart';

part '${lowerName}_state.dart';
part '${lowerName}_event.dart';
part '${lowerName}_bloc.freezed.dart';
''';

    final classDefinition = '''
class ${className}Bloc extends Bloc<${className}Event, ${className}State> {
  final Find${className}UseCase _find${className}UseCase;
  final Get${className}sUseCase _get${className}sUseCase;
  final Create${className}UseCase _create${className}UseCase;
  final Update${className}UseCase _update${className}UseCase;
  final Delete${className}UseCase _delete${className}UseCase;

  ${className}Bloc({
    required Find${className}UseCase find${className}UseCase,
    required Get${className}sUseCase get${className}sUseCase,
    required Create${className}UseCase create${className}UseCase,
    required Update${className}UseCase update${className}UseCase,
    required Delete${className}UseCase delete${className}UseCase,
  })  : _find${className}UseCase = find${className}UseCase,
        _get${className}sUseCase = get${className}sUseCase,
        _create${className}UseCase = create${className}UseCase,
        _update${className}UseCase = update${className}UseCase,
        _delete${className}UseCase = delete${className}UseCase,
        super(_${className}StateInitial()) {
    on<${className}Event>((event, emit) async {
      await event.when(
        started: () => _on${className}Initialized(emit),
        find${className}: (id) => _onGet${className}Event(id, emit),
        get${className}s: () => _onGet${className}sEvent(emit),
        create${className}: (params) => _onCreate${className}Event(params, emit),
        update${className}: (params) => _onUpdate${className}Event(params, emit),
        delete${className}: (id) => _onDelete${className}Event(id, emit),
      );
    });
  }

  // Implement the event handlers here...
}
''';

    return '$imports\n$classDefinition';
  }
}
