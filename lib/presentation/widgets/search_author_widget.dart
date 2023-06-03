import 'package:e_books_desktop/data/models/author.dart';
import 'package:e_books_desktop/presentation/cubits/book/book_cubit.dart';
import 'package:e_books_desktop/presentation/widgets/buy_book_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:search_choices/search_choices.dart';

import '../cubits/author/author_cubit.dart';

// ignore: must_be_immutable
class SearchAuthorField extends StatefulWidget {
  SearchAuthorField({Key? key, required this.authorItems, required this.bookCubit}) : super(key: key);

  List<DropdownMenuItem<Author>> authorItems;
  BookCubit bookCubit;

  @override
  State<SearchAuthorField> createState() => _SearchAuthorFieldState();
}

class _SearchAuthorFieldState extends State<SearchAuthorField> {
  Author? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthorCubit()..loadAllAuthors(),
      child: SearchChoices.single(
        items: widget.authorItems,
        value: _selectedItem,
        hint: 'Автор',
        dialogBox: false,
        searchHint: 'Выберите автора или добавьте его сами',
        isExpanded: true,
        menuConstraints: BoxConstraints.tight(const Size.fromHeight(350)),
        closeButton: (Author? value, BuildContext closeContext, Function updateParent) {
          return (widget.authorItems.length >= 100
              ? "Close"
              : TextButton(
                  onPressed: () async{
                    var author = await EBooksDialogs.openCreateAuthorDialog(
                      context,
                      context.read<AuthorCubit>(),
                    ).then((value) => print('created_author: ${value}'));


                  },
                  child: const Text("Добавить автора"),
                ));
        },
        disabledHint: (Function updateParent) {
          return (TextButton(
            onPressed: () {
              EBooksDialogs.openCreateAuthorDialog(
                context,
                context.read<AuthorCubit>(),
              ).then((value) async {
                if (value != null) {
                  widget.authorItems.add(DropdownMenuItem<Author>(
                    value: value as Author,
                    child: Text(value.getInitials()),
                  ));
                  widget.authorItems.indexWhere((element) {
                    return element.value == value;
                  });
                  if (widget.authorItems.indexWhere((element) => element.value == value) != -1) {
                    updateParent(value, true);
                  }
                }
              });
            },
            child: const Text("No choice, click to add one"),
          ));
        },
        displayItem: (DropdownMenuItem item, selected, Function updateParent) {
          bool deleteRequest = false;
          return ListTile(
            title: item,
            onTap: () {
              if (!deleteRequest) {
                updateParent(item.value, true);
              }
            },
            horizontalTitleGap: 0,
          );
        },
        autofocus: false,
        onChanged: (Author? value, Function? pop) {
          widget.bookCubit.authorChanged(value!);
          setState(
            () {
              if (value is! NotGiven) {
                _selectedItem = value;
              }
              // if (pop != null && value is! NotGiven) {
              //   pop();
              // }
            },
          );
        },
      ),
    );
  }
}
