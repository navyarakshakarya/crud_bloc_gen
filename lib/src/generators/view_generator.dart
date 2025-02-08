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

    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '${className.toLowerCase()}_bloc.dart';
import '${className.toLowerCase()}_cubit.dart';

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
              loaded: (${className.toLowerCase()}s) => ListView.builder(
                itemCount: ${className.toLowerCase()}s.length,
                itemBuilder: (context, index) {
                  final ${className.toLowerCase()} = ${className.toLowerCase()}s[index];
                  return ListTile(
                    title: Text(${className.toLowerCase()}.name),
                    subtitle: Text(${className.toLowerCase()}.id),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        context.read<${className}Bloc>().add(
                              ${className}Event.delete${className}(id: ${className.toLowerCase()}.id),
                            );
                      },
                    ),
                    onTap: () {
                      // Navigate to detail page or show edit dialog
                    },
                  );
                },
              ),
              dataChanged: (_, __) => SizedBox(), // This state is handled in the listener
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
  }
}
