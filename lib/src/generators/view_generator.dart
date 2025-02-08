import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../annotations.dart';

class ViewGenerator extends GeneratorForAnnotation<GenerateCrudView> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          'GenerateCrudView can only be applied to classes.',
          element: element);
    }

    final className = element.name;
    final lowerName = className.toLowerCase();

    // Group all imports at the top
    final imports = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '${lowerName}_bloc.dart';
import '${lowerName}_cubit.dart';
''';

    final classDefinition = '''
class ${className}Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${className} Page'),
      ),
      body: BlocListener<${className}Bloc, ${className}State>(
        listener: (context, state) {
          state.maybeWhen(
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
            dataChanged: (message, _) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
            orElse: () {},
          );
        },
        child: BlocBuilder<${className}Cubit, ${className}CubitState>(
          builder: (context, state) {
            return state.when(
              initial: () => Center(child: CircularProgressIndicator()),
              loaded: (${lowerName}s) => ListView.builder(
                itemCount: ${lowerName}s.length,
                itemBuilder: (context, index) {
                  final ${lowerName} = ${lowerName}s[index];
                  return ListTile(
                    title: Text(${lowerName}.name),
                    subtitle: Text(${lowerName}.id),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        context.read<${className}Bloc>().add(
                              ${className}Event.delete${className}(id: ${lowerName}.id),
                            );
                      },
                    ),
                    onTap: () {
                      // Navigate to detail page or show edit dialog
                    },
                  );
                },
              ),
              dataChanged: (_, __) => SizedBox(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Show dialog to create new ${className}
        },
      ),
    );
  }
}
''';

    return '$imports\n$classDefinition';
  }
}
