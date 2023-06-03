import 'dart:io';

import 'package:e_books_desktop/data/models/book.dart';
import 'package:e_books_desktop/data/utils/image_picker.dart';
import 'package:e_books_desktop/presentation/cubits/author/author_cubit.dart';
import 'package:e_books_desktop/presentation/cubits/book/book_cubit.dart';
import 'package:e_books_desktop/presentation/cubits/models_status.dart';
import 'package:e_books_desktop/presentation/di/app_module.dart';
import 'package:e_books_desktop/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';

import '../../data/models/author.dart';
import '../widgets/search_author_widget.dart';

class StartPage extends StatelessWidget {
  StartPage({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController rating = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocListener<BookCubit, BookState>(
        listener: (context, state) {
          print('state.addBookStatus.runtimeType: ${state.addBookStatus.runtimeType}');
          if (state.addBookStatus is LoadedStatus<Book>) {
            SnackBarInfo.show(context: context, message: 'Книга успешно добавлена!', isSuccess: true);
          }

          if (state.addBookStatus is FailedStatus<Book>) {
            SnackBarInfo.show(context: context, message: 'Ошибка при добавлении книги', isSuccess: false);
          }
        },
        child: Column(
          children: [
            AppBar(
              title: const Text(
                'Добавление книги',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  const Text('Заполните все данные о вашей книге:'),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: titleController,
                                    validator: (value) {
                                      if (value?.trim().isNotEmpty == true) {
                                        return null;
                                      }
                                      return "Это обязательное поле";
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      labelText: 'Название книги',
                                      prefixIcon: const Icon(Icons.book_outlined),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                      hintText: 'Война и мир',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: yearController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    maxLength: 4,
                                    validator: (value) {
                                      if (value?.trim().isEmpty == true) {
                                        return "Это обязательное поле";
                                      }
                                      int? year = int.tryParse(value!);
                                      if (year == null) {
                                        return "Год выпуска должен быть числом";
                                      }
                                      if (year > DateTime.now().year) {
                                        return "Год выпуска не может быть в будущем";
                                      }
                                      if (year <= 1457) {
                                        return "Год выпуска не может быть таким маленьким";
                                      }
                                    },
                                    decoration: InputDecoration(
                                      counterText: '',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      labelText: 'Год выпуска',
                                      prefixIcon: const Icon(Icons.book_outlined),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                      hintText: '2012',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  () {
                                    if (AppModule.getProfileHolder().user.role?.id == 3) {
                                      context.read<AuthorCubit>().loadAllAuthors();
                                      return BlocBuilder<AuthorCubit, AuthorState>(builder: (context, state) {
                                        print(
                                            'state.getAuthorsStatus.runtimeType: ${state.getAuthorsStatus.runtimeType}');
                                        switch (state.getAuthorsStatus.runtimeType) {
                                          case LoadingStatus:
                                            return const CircularProgressIndicator();
                                          case FailedStatus:
                                            return const Text('Ошибка при получении авторов');
                                          case const (LoadedStatus<List<Author>>):
                                            List<Author> authorItems = state.getAuthorsStatus.item!;
                                            List<DropdownMenuItem<Author>> menuItemsAuthor = authorItems
                                                .map((author) => DropdownMenuItem<Author>(
                                                      value: author,
                                                      child: Text(author.getInitials()),
                                                    ))
                                                .toList();
                                            return Column(
                                              children: [
                                                // TextFormField(
                                                //   controller: authorController,
                                                //   validator: (value) {
                                                //     if (value?.trim().isNotEmpty == true) {
                                                //       return null;
                                                //     }
                                                //     return "Это обязательное поле";
                                                //   },
                                                //   decoration: InputDecoration(
                                                //     contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                //     labelText: 'Автор книги',
                                                //     prefixIcon: const Icon(Icons.person_2_outlined),
                                                //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                                //     hintText: 'А.С. Пушкин',
                                                //   ),
                                                // ),
                                                SearchAuthorField(
                                                    bookCubit: context.read<BookCubit>(), authorItems: menuItemsAuthor),
                                                const SizedBox(height: 10),
                                              ],
                                            );
                                          default:
                                            return const Text('Ошибка при получении авторов');
                                        }
                                      });
                                    }
                                    return const SizedBox();
                                  }(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Column(
                          children: [
                            BlocBuilder<BookCubit, BookState>(
                              builder: (context, state) {
                                print(state.image);
                                if (state.image != null) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        height:
                                            (MediaQuery.of(context).size.width / MediaQuery.of(context).size.height) *
                                                250,
                                        child: Image.file(File(state.image!.path)),
                                      ),
                                      // OutlinedButton.icon(
                                      //   onPressed: () {
                                      //     context.read<BookCubit>().removeImage();
                                      //   },
                                      //   icon: const Icon(Icons.delete_outline),
                                      //   label: const Text('Удалить'),
                                      // ),
                                    ],
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            BlocBuilder<BookCubit, BookState>(builder: (context, state) {
                              return ElevatedButton(
                                child: state.image == null
                                    ? const Text('Добавить обложку')
                                    : const Text('Изменить обложку'),
                                onPressed: () async {
                                  await ImageHelper().getFromGallery().then((value) {
                                    if (value != null) {
                                      context.read<BookCubit>().imageChanged(value);
                                    }
                                  });
                                },
                              );
                            }),

                            // FormBuilderFilePicker(name: 'book',
                            //   decoration: InputDecoration(labelText: "Attachments"),
                            //   maxFiles: 1,
                            //   previewImages: true,
                            //   onChanged: (value) => print(value),
                            //   typeSelectors: const [
                            //     TypeSelector(
                            //       type: FileType.any,
                            //       selector: Row(
                            //         children: <Widget>[
                            //           Icon(Icons.add_circle),
                            //           Padding(
                            //             padding: EdgeInsets.only(left: 8.0),
                            //             child: Text("Добавить книгу"),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ],
                            //   onFileLoading: (val) {
                            //
                            //   },
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Column(
                          children: [
                            BlocBuilder<BookCubit, BookState>(
                              builder: (context, state) {
                                print('book: ${state.book}');
                                if (state.book != null) {
                                  return Column(
                                    children: [
                                      Card(
                                        margin: EdgeInsets.zero,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.file_open_outlined, size: 50),
                                              Text(basename(state.book!.path)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // OutlinedButton.icon(
                                      //   onPressed: () {
                                      //     context.read<BookCubit>().removeBook();
                                      //   },
                                      //   icon: const Icon(Icons.delete_outline),
                                      //   label: const Text('Удалить'),
                                      // ),
                                    ],
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            BlocBuilder<BookCubit, BookState>(builder: (context, state) {
                              return ElevatedButton(
                                child: state.book == null ? const Text('Добавить книгу') : const Text('Изменить книгу'),
                                onPressed: () async {
                                  await ImageHelper().getFile().then((value) {
                                    if (value != null) {
                                      context.read<BookCubit>().fileChanged(value);
                                    }
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Добавление книги - 100 деняк.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 5),
                  BlocBuilder<BookCubit, BookState>(builder: (context, state) {
                    return OutlinedButton(
                      onPressed: () async {
                        print('validate key in add book: ${_formKey.currentState?.validate() ?? false}');
                        print(yearController.value.text);
                        print('image: ${state.image!.path}');
                        print('file: ${state.book!.path}');
                        if (AppModule.getProfileHolder().user.wallet < 100) {
                          SnackBarInfo.show(
                              context: context, message: 'На вашем счету недостаточно средств', isSuccess: false);
                          return;
                        } else if (_formKey.currentState?.validate() ?? false) {
                          await context
                              .read<BookCubit>()
                              .addBook(
                                image: state.image!,
                                file: state.book!,
                                title: titleController.value.text,
                                yearOfIssue: int.parse(yearController.value.text),
                                user: AppModule.getProfileHolder().user,
                                author: state.author,
                              )
                              .then((value) {
                            titleController.clear();
                            yearController.clear();
                            context.read<BookCubit>().loadBooks();
                          });
                        }
                      },
                      child: () {
                        if (state.addBookStatus is LoadingStatus<Book>) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return const Text("Добавить");
                      }(),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
