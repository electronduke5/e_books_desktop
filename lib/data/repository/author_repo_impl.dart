import 'package:e_books_desktop/data/api_service.dart';
import 'package:e_books_desktop/data/utils/constants.dart';
import 'package:e_books_desktop/domain/repository/author_repository.dart';

import '../models/author.dart';

class AuthorRepositoryImpl with ApiService<Author> implements AuthorRepository {
  @override
  String apiRoute = ApiConstUrl.authorUrl;

  @override
  Future<Author> addAuthor({required String surname, required String name, String? patronymic, String? information}) {
    return post(
      fromJson: (Map<String, dynamic> json) => Author.fromJson(json),
      data: {
        'surname': surname,
        'name': name,
        'patronymic': patronymic,
        'information': information,
      },
    );
  }

  @override
  Future<List<Author>> getAllAuthors() {
    return getAll(
      fromJson: (Map<String, dynamic> json) => Author.fromJson(json),
    );
  }
}
