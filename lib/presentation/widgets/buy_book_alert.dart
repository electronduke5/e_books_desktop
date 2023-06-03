import 'package:e_books_desktop/presentation/cubits/models_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/author.dart';
import '../cubits/author/author_cubit.dart';

class EBooksDialogs {
  static Future openCreateAuthorDialog(BuildContext context, AuthorCubit authorCubit) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    Author? author;

    final TextEditingController surnameController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController patronymicController = TextEditingController();
    final TextEditingController infoController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => authorCubit),
          ],
          child: AlertDialog(
            title: const Text('Добавление автора'),
            content: BlocBuilder<AuthorCubit, AuthorState>(
              bloc: authorCubit,
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: surnameController,
                          validator: (value) {
                            if (value?.trim().isNotEmpty == true) {
                              return null;
                            }
                            return "Это обязательное поле";
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                            labelText: 'Фамилия',
                            prefixIcon: const Icon(Icons.looks_one_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            hintText: 'Пушкин',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: nameController,
                          validator: (value) {
                            if (value?.trim().isNotEmpty == true) {
                              return null;
                            }
                            return "Это обязательное поле";
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                            labelText: 'Имя',
                            prefixIcon: const Icon(Icons.looks_two_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            hintText: 'Александр',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: patronymicController,
                          validator: (value) {
                            if (value?.trim().isNotEmpty == true) {
                              return null;
                            }
                            return "Это обязательное поле";
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                            labelText: 'Отчество',
                            prefixIcon: const Icon(Icons.looks_3_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            hintText: 'Сергеевич',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: infoController,
                          validator: (value) {
                            if (value?.trim().isNotEmpty == true) {
                              return null;
                            }
                            return "Это обязательное поле";
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                            labelText: 'Информация об авторе',
                            prefixIcon: const Icon(Icons.info_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, null);
                },
                child: const Text('Отмена'),
              ),
              BlocBuilder<AuthorCubit, AuthorState>(
                  bloc: authorCubit,
                  builder: (context, state) {
                    return TextButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          String surname = surnameController.value.text;
                          String name = nameController.value.text;
                          String patronymic = patronymicController.value.text;
                          String info = infoController.value.text;
                          await context
                              .read<AuthorCubit>()
                              .createAuthor(
                                surname: surname,
                                name: name,
                                patronymic: patronymic,
                                information: info,
                              )
                              .then((value) {
                            if (value != null) {
                              author = value;
                              print('VALUEVALUE2244: ${author}');
                              print('VALUEVALUE2222: ${value}');
                              Navigator.pop(context, value);
                            }
                          });
                        }
                      },
                      child: () {
                        if (state.addAuthorStatus is LoadingStatus) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return const Text('Добавить');
                        }
                      }(),
                    );
                  }),
            ],
          ),
        );
      },
    );

  }
}
