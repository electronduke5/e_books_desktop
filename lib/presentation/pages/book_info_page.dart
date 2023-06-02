import 'package:collection/collection.dart';
import 'package:e_books_desktop/presentation/cubits/book/book_cubit.dart';
import 'package:e_books_desktop/presentation/cubits/models_status.dart';
import 'package:e_books_desktop/presentation/cubits/review/review_cubit.dart';
import 'package:e_books_desktop/presentation/di/app_module.dart';
import 'package:e_books_desktop/presentation/widgets/book_cover_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../data/models/author.dart';
import '../../data/models/book.dart';
import '../../data/models/review.dart';
import '../../data/models/shelf.dart';
import '../../data/models/user.dart';
import '../cubits/shelves/shelf_cubit.dart';
import '../widgets/review_widget.dart';
import '../widgets/snack_bar.dart';

class BookInfoPage extends StatelessWidget {
  BookInfoPage({Key? key}) : super(key: key);

  final scaffoldState = GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController descriptionController = TextEditingController();
  int rating = 0;

  bool checkBookmark(Book? book) {
    User user = AppModule.getProfileHolder().user;
    if (user.bookmarks == null) return false;
    if (user.bookmarks!.isEmpty) return false;
    Book? bookmark =
        user.bookmarks?.firstWhereOrNull((element) => element.id == book?.id);
    if (bookmark == null) return false;
    return true;
  }

  bool isBookmarkChecked = false;

  @override
  Widget build(BuildContext context) {
    Book? book = ModalRoute.of(context)!.settings.arguments as Book?;
    isBookmarkChecked = checkBookmark(book);
    return Scaffold(
      key: scaffoldState,
      appBar: buildAppBar(book, context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Hero(
                    tag: 'book${book!.id}',
                    child: () {
                      if (book!.image == null) {
                        return BookCoverText(book: book);
                      }
                      return Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(book.image!),
                          ),
                        ),
                      );
                    }(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book?.title ?? 'Название книги',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              () {
                                if (book?.authors?.isEmpty ?? true) {
                                  return const Text('Авторов нет');
                                }
                                for (Author author in book!.authors!) {
                                  return Text(author.getInitials(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall);
                                }
                                return const SizedBox();
                              }(),
                              // Text(book.authors.getInitials(),
                              //     style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.star_outline),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Text(book?.rating != 0.0
                                ? '${book?.rating ?? '0'}/10'
                                : 'Отзывов ещё нет'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:
                            Text('Год выпуска: ${book?.yearOfIssue ?? '0000'}'),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed('/read-book', arguments: book);
                          },
                          child: const Text(
                            'ЧИТАТЬ',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          _showSheet(book!.id);
                        },
                        child: const Text(
                          'Добавить на полку',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Отзывы',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          OutlinedButton(
                              onPressed: () {
                                _showCreateReviewSheet(book!);
                              },
                              child: const Text('Добавить отзыв'))
                        ],
                      ),
                      const SizedBox(height: 10),
                      () {
                        if (book!.reviews == null || book.reviews!.isEmpty) {
                          return const Text('Отзывов еще нет');
                        }
                        return SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: book.reviews?.length,
                            itemBuilder: (context, index) {
                              return ReviewCard(
                                review: book.reviews![index],
                              );
                            },
                          ),
                        );
                      }(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(Book? book, BuildContext context) {
    return AppBar(
      title: Text(
        "${book?.title}",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      actions: [
        BlocBuilder<BookCubit, BookState>(
          builder: (ctx, state) {
            return IconButton(
              onPressed: () async {
                await context
                    .read<BookCubit>()
                    .addBookmark(book!.id)
                    .then((value) => isBookmarkChecked = value ?? false);
              },
              //icon: Icon(checkBookmark(book) ? Icons.bookmark : Icons.bookmark_border, color: Colors.yellow,),
              icon: Icon(
                isBookmarkChecked ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.yellow,
              ),
            );
          },
        ),
      ],
    );
  }

  void _showSheet(int bookId) async {
    BuildContext context = scaffoldState.currentContext!;
    final shelves = await context.read<ShelfCubit>().loadShelves();
    scaffoldState.currentState?.showBottomSheet(
      (context) => BlocListener<ShelfCubit, ShelfState>(
        listener: (context, state) {},
        child: SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  'Выберите полку',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                BlocBuilder<ShelfCubit, ShelfState>(builder: (context, state) {
                  print(
                      'shelves status in book_info_page: ${state.shelvesStatus.runtimeType}');
                  if (state.shelvesStatus.runtimeType ==
                      LoadingStatus<List<Shelf>>) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.shelvesStatus.runtimeType ==
                      LoadedStatus<List<Shelf>>) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: shelves!.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(10),
                              // ),
                              //tileColor: Theme.of(context).colorScheme.secondaryContainer,
                              title: Text(shelves[index].title),
                              onTap: () async {
                                await context
                                    .read<ShelfCubit>()
                                    .addBookToShelf(
                                        bookId: bookId,
                                        shelfId: shelves[index].id)
                                    .then((value) {
                                  Navigator.of(context).pop();
                                  SnackBarInfo.show(
                                      context: context,
                                      message:
                                          "Книга добавлена на полку '${shelves[index].title}'",
                                      isSuccess: true);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateReviewSheet(Book book) async {
    scaffoldState.currentState?.showBottomSheet(
      (context) => BlocListener<ReviewCubit, ReviewState>(
        listener: (context, state) {
          if (state.createReviewStatus.runtimeType == LoadedStatus<Review>) {
            SnackBarInfo.show(
                context: context, message: "Отзыв доавблен", isSuccess: true);
          }
        },
        child: SizedBox(
          height: 310,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Добавление отзыва на книгу',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller: descriptionController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Это обязательное поле';
                        }
                        if (value.length >= 120) {
                          return 'Максимум - 120 символов';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Расскажите впечатления',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RatingBar.builder(
                    minRating: 1,
                    maxRating: 10,
                    direction: Axis.horizontal,
                    itemCount: 10,
                    //allowHalfRating: true,
                    glow: false,
                    updateOnDrag: true,
                    itemSize: MediaQuery.of(context).size.width / 11,
                    itemBuilder: (context, index) {
                      return Icon(Icons.star,
                          color: Theme.of(context).colorScheme.secondary);
                    },
                    onRatingUpdate: (double value) => context
                        .read<ReviewCubit>()
                        .ratingChanged(value.toInt()),
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<ReviewCubit, ReviewState>(
                    builder: (context, state) {
                      return Text('${state.rating.toString()}/10');
                    },
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<ReviewCubit, ReviewState>(
                    builder: (context, state) => ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final String description =
                              descriptionController.value.text;
                          await context
                              .read<ReviewCubit>()
                              .createReview(
                                description: description,
                                book: book,
                                rating: state.rating,
                              )
                              .then((value) => Navigator.of(context).pop());
                        }
                      },
                      child: const Text('Добавить'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
