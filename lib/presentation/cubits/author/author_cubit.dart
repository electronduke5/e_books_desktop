import 'package:bloc/bloc.dart';
import 'package:e_books_desktop/domain/repository/author_repository.dart';
import 'package:e_books_desktop/presentation/cubits/models_status.dart';
import 'package:e_books_desktop/presentation/di/app_module.dart';
import 'package:meta/meta.dart';

import '../../../data/models/author.dart';

part 'author_state.dart';

class AuthorCubit extends Cubit<AuthorState> {
  AuthorCubit() : super(const AuthorState());

  final AuthorRepository _authorRepository = AppModule.getAuthorRepository();

  Future<List<Author>?> loadAllAuthors() async {
    emit(state.copyWith(getAuthorsStatus: LoadingStatus()));
    try {
      final List<Author> authors = await _authorRepository.getAllAuthors();
      emit(state.copyWith(getAuthorsStatus: LoadedStatus(item: authors)));
      return authors;
    } catch (exception) {
      emit(state.copyWith(getAuthorsStatus: FailedStatus(state.getAuthorsStatus.message)));
      return null;
    }
  }

  Future<Author?> createAuthor({
    required String surname,
    required String name,
    String? patronymic,
    String? information,
  }) async {
    emit(state.copyWith(addAuthorStatus: LoadingStatus()));
    try {
      final Author author = await _authorRepository.addAuthor(
        surname: surname,
        name: name,
        patronymic: patronymic,
        information: information,
      );
      emit(state.copyWith(addAuthorStatus: LoadedStatus(item: author)));
      return author;
    } catch (exception) {
      emit(state.copyWith(addAuthorStatus: FailedStatus(state.getAuthorsStatus.message)));
      return null;
    }
  }
}
