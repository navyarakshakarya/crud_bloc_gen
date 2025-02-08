import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generators/model_generator.dart';
import 'generators/view_generator.dart';
import 'generators/repository_generator.dart';
import 'generators/usecase_generator.dart';
import 'generators/bloc_generator.dart';
import 'generators/datasource_generator.dart';

Builder generateCrudBloc(BuilderOptions options) => SharedPartBuilder([
      ModelGenerator(),
      ViewGenerator(),
      RepositoryGenerator(),
      UseCaseGenerator(),
      BlocGenerator(),
      DatasourceGenerator(),
    ], 'crud_bloc_gen');
