import 'package:e_books_desktop/data/models/author.dart';

abstract class AuthorRepository{
  Future<List<Author>> getAllAuthors();
  Future<Author> addAuthor({
    required String surname,
    required String name,
    String? patronymic,
    String? information,
});
}