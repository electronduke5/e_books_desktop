import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../data/models/book.dart';
import '../cubits/book/book_cubit.dart';
import '../cubits/models_status.dart';
import '../widgets/book_widget.dart';

class BookmarkPage extends StatelessWidget {
  BookmarkPage({Key? key}) : super(key: key);

  List<Book> allBooks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Закладки'),
      ),
      body: RefreshIndicator(onRefresh: () async {
        await context.read<BookCubit>().loadBookmarks();
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
                      crossAxisCount: 2,
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
      )),
    );
  }
}
