part of 'author_cubit.dart';

@immutable
class AuthorState {
  final ApiStatus<List<Author>> getAuthorsStatus;
  final ApiStatus<Author> addAuthorStatus;

  const AuthorState({
    this.getAuthorsStatus = const IdleStatus(),
    this.addAuthorStatus = const IdleStatus(),
  });

  AuthorState copyWith({
    ApiStatus<List<Author>>? getAuthorsStatus,
    ApiStatus<Author>? addAuthorStatus,
  }) {
    return AuthorState(
      getAuthorsStatus: getAuthorsStatus ?? this.getAuthorsStatus,
      addAuthorStatus: addAuthorStatus ?? this.addAuthorStatus,
    );
  }
}
