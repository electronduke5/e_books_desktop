part of 'book_cubit.dart';

class BookState {
  final ApiStatus<List<Book>> booksStatus;
  final ApiStatus<Book> bookmarkStatus;
  final ApiStatus<Book> addBookStatus;
  final ApiStatus<void> deleteBookStatus;
  final File? image;
  final File? book;
  final Author? author;

  BookState({
    this.booksStatus = const IdleStatus(),
    this.addBookStatus = const IdleStatus(),
    this.bookmarkStatus = const IdleStatus(),
    this.deleteBookStatus = const IdleStatus(),
    this.book,
    this.image,
    this.author,
  });

  BookState copyWith({
    ApiStatus<List<Book>>? booksStatus,
    ApiStatus<Book>? bookmarkStatus,
    ApiStatus<Book>? addBookStatus,
    ApiStatus<void>? deleteBookStatus,
    File? image ,
    File? book ,
    Author? author ,
  }) =>
      BookState(
        booksStatus: booksStatus ?? this.booksStatus,
        bookmarkStatus: bookmarkStatus ?? this.bookmarkStatus,
        addBookStatus: addBookStatus ?? this.addBookStatus,
        deleteBookStatus: deleteBookStatus ?? this.deleteBookStatus,
        image: image ?? this.image,
        book: book ?? this.book,
        author: author ?? this.author,
      );
}
