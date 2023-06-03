import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:e_books_desktop/presentation/cubits/models_status.dart';
import 'package:e_books_desktop/presentation/cubits/post/post_cubit.dart';
import 'package:e_books_desktop/presentation/cubits/profile/profile_cubit.dart';
import 'package:e_books_desktop/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/post.dart';
import '../../data/models/user.dart';
import '../../data/utils/image_picker.dart';
import '../cubits/theme/theme_cubit.dart';
import '../di/app_module.dart';
import '../widgets/popup_icon_item.dart';
import '../widgets/profile_stats_grid.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController postController = TextEditingController();
  User user = AppModule.getProfileHolder().user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: RefreshIndicator(
        onRefresh: () async {
          await context.read<ProfileCubit>().loadProfile(user: AppModule.getProfileHolder().user);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              switch (state.status.runtimeType) {
                case const (LoadedStatus<User>):
                  user = state.status.item!;
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: ProfileStatsGrid(user: state.status.item!)),
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height - 120,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  Card(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(25),
                                      ),
                                    ),
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                minRadius: 2,
                                                maxRadius: 45,
                                                child: Text(
                                                  state.status.item!.getInitials(),
                                                  style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 30),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              AutoSizeText(
                                                '${state.status.item!.surname}\n${state.status.item!.name}',
                                                style: Theme.of(context).textTheme.headlineSmall,
                                              ),
                                              const Spacer(),
                                              popupProfileMenu(context),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Divider(
                                            thickness: 2,
                                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.2),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Никнейм: ${state.status.item!.username}',
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                          Text(
                                            'Эл. почта: ${state.status.item!.email}',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Баланс: ${state.status.item!.wallet}',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  IntrinsicHeight(
                                    child: BlocListener<PostCubit, PostState>(
                                      listener: (context, state) {
                                        if (state.addPostStatus is LoadedStatus<Post>) {
                                          SnackBarInfo.show(
                                            context: context,
                                            message: 'Запись доабвлена!',
                                            isSuccess: true,
                                          );
                                        }
                                      },
                                      child: BlocBuilder<PostCubit, PostState>(
                                        builder: (context, state) {
                                          return Card(
                                            margin: EdgeInsets.zero,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Form(
                                                key: _formKey,
                                                child: Column(
                                                  children: [
                                                    const Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text('Новая запись'),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: postController,
                                                        validator: (value) {
                                                          if (value?.trim().isNotEmpty == true) {
                                                            return null;
                                                          }
                                                          return "Это обязательное поле";
                                                        },
                                                        maxLines: null,
                                                        textAlign: TextAlign.justify,
                                                        decoration: InputDecoration(
                                                          contentPadding: const EdgeInsets.all(10.0),
                                                          border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(20)),
                                                          hintText: 'Чем вы хотели поделиться?',
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    () {
                                                      if (state.image != null) {
                                                        return Column(
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  //width: 150,
                                                                  height: (MediaQuery.of(context).size.height) * 0.25,
                                                                  child: Image.file(File(state.image!.path)),
                                                                ),
                                                                Align(
                                                                  alignment: Alignment.topLeft,
                                                                  child: IconButton(onPressed: () async { await context
                                                                      .read<PostCubit>().removeImage();}, icon: const Icon(Icons.delete_outline)),
                                                                )
                                                              ],
                                                            ),
                                                            const SizedBox(height: 10),
                                                          ],
                                                        );
                                                      }
                                                      return const SizedBox();
                                                    }(),
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: OutlinedButton.icon(
                                                        onPressed: () async {
                                                          await ImageHelper().getFromGallery().then((value) {
                                                            if (value != null) {
                                                              context.read<PostCubit>().imageChanged(value);
                                                            }
                                                          });
                                                        },
                                                        icon: const Icon(Icons.add_photo_alternate_outlined),
                                                        label: Text(
                                                          state.image == null ? 'Добавить фото' : 'Изменить фото',
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(
                                                          'После публикации поста у вас снимут 50 деняк.\nПожалуйста, убедитесь, что у вас достаточно средств.',
                                                          style: Theme.of(context).textTheme.bodySmall,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        if (user.wallet < 50) {
                                                          SnackBarInfo.show(
                                                              context: context,
                                                              message: 'На вашем счету недостаточно средств',
                                                              isSuccess: false);
                                                          return;
                                                        } else if (_formKey.currentState?.validate() ?? false) {
                                                          await context
                                                              .read<PostCubit>()
                                                              .addPost(
                                                                image: state.image,
                                                                description: postController.value.text,
                                                                user: AppModule.getProfileHolder().user,
                                                              )
                                                              .then((value) {
                                                            postController.clear();
                                                            context
                                                                .read<PostCubit>().removeImage();
                                                            context
                                                                .read<ProfileCubit>()
                                                                .loadProfile(user: AppModule.getProfileHolder().user);
                                                          });
                                                        }
                                                      },
                                                      child: () {
                                                        if (state.addPostStatus is LoadingStatus<Post>) {
                                                          return const Center(child: CircularProgressIndicator());
                                                        }
                                                        return const Text('Опубликовать');
                                                      }(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                case const (LoadingStatus<User>):
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                case const (FailedStatus<User>):
                  return Center(child: Text(state.status.message ?? 'Failed load profile'));
                default:
                  return const Center(child: Text('Default'));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget popupProfileMenu(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert, size: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) => [
        PopupIconMenuItem(title: 'Выйти', icon: Icons.exit_to_app_outlined),
        PopupIconMenuItem(
          title: 'Сменить тему',
          icon: context.read<ThemeCubit>().getCurrentTheme == ThemeMode.light
              ? Icons.dark_mode_outlined
              : Icons.light_mode_outlined,
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'Выйти':
            AppModule.getPreferencesRepository().removeSavedProfile();
            Navigator.of(context).pushNamed('/sign-in');
            break;
          case 'Сменить тему':
            context.read<ThemeCubit>().switchTheme();
            break;
        }
      },
    );
  }
}
