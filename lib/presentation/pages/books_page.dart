import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../data/models/book.dart';
import '../cubits/book/book_cubit.dart';
import '../cubits/models_status.dart';
import '../widgets/book_widget.dart';
import '../widgets/custom_search_delegate.dart';
import '../widgets/popup_icon_item.dart';

class BooksPage extends StatelessWidget {
  BooksPage({Key? key}) : super(key: key);

  Book? book;
  List<Book> allBooks = [];



  @override
  Widget build(BuildContext context) {
    context.read<BookCubit>().loadBooks();
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: const Text(
              'Книги',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(books: allBooks),
                    );
                  },
                  icon: const Icon(Icons.search)),
              PopupMenuButton<String>(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                onSelected: (value) async {
                  allBooks = await _onSelected(
                      context: context, value: value, books: allBooks);
                },
                icon: const Icon(Icons.filter_list),
                itemBuilder: (context) {
                  return [
                    PopupIconMenuItem(
                      title: 'По возрастанию рейтинга',
                      icon: Icons.arrow_upward,
                    ),
                    PopupIconMenuItem(
                      title: 'По убыванию рейтинга',
                      icon: Icons.arrow_downward,
                    ),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: buildBooksList(context),
          ),
        ],
      ),
    );
  }

  Widget buildBooksList(BuildContext context) {
    int _getAxisCount() {
      if(MediaQuery.of(context).size.width > 770) {
        return 4;
      }
      else if (MediaQuery.of(context).size.width > 575) {
        return 3;
      }
      else {
        return 2;
      }
    }
    return RefreshIndicator(onRefresh: () async {
      await context.read<BookCubit>().loadBooks().then((value) {
        allBooks = value ?? allBooks;
      });
    }, child: BlocBuilder<BookCubit, BookState>(
      builder: (context, state) {
        switch (state.booksStatus.runtimeType) {
          case const (LoadingStatus<List<Book>>):
            return const Center(child: CircularProgressIndicator());
          case const (LoadedStatus<List<Book>>):
            if (state.booksStatus.item == null) {
              return const Center(child: CircularProgressIndicator());
            }
            allBooks = state.booksStatus.item!;
            return Column(
              children: [
                Expanded(
                  child: MasonryGridView.count(
                    crossAxisCount: _getAxisCount(),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    itemCount: allBooks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return BookWidget(book: allBooks[index]);
                    },
                  ),
                ),
                const SizedBox(height: 60),
              ],
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    ));
  }

  Future<List<Book>> _onSelected(
      {required BuildContext context,
      required List<Book> books,
      required String value}) async {
    switch (value) {
      case 'По возрастанию рейтинга':
        await context
            .read<BookCubit>()
            .loadBooks()
            .then((value) => allBooks = value!);
        books.sort((a, b) => a.rating!.compareTo(b.rating!));
        break;
      case 'По убыванию рейтинга':
        await context
            .read<BookCubit>()
            .loadBooks()
            .then((value) => allBooks = value!);
        books.sort((b, a) => a.rating!.compareTo(b.rating!));
        break;
    }
    return books;
  }
}
