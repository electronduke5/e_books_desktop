import 'package:auto_size_text/auto_size_text.dart';
import 'package:e_books_desktop/data/utils/datetime_helper.dart';
import 'package:e_books_desktop/presentation/cubits/post/post_cubit.dart';
import 'package:e_books_desktop/presentation/di/app_module.dart';
import 'package:e_books_desktop/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/post.dart';
import '../../data/models/user.dart';

class PostCard extends StatelessWidget {
  const PostCard({Key? key, required this.post, this.user}) : super(key: key);

  final Post post;
  final User? user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  minRadius: 2,
                  maxRadius: 20,
                  child: Text(
                    post.user!.getInitials(),
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      '${post.user!.surname} ${post.user!.name}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      DateTimeHelper.getDateWithTime(post.dateCreated!),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
                () {
                  if (AppModule.getProfileHolder().user.id == post.user?.id) {
                    return IconButton(
                        onPressed: () async {
                          await context
                              .read<PostCubit>()
                              .deletePost(post.id)
                              .then((value) {
                            SnackBarInfo.show(
                                context: context,
                                message: 'Запись удалена',
                                isSuccess: true);
                            context.read<PostCubit>().loadPosts(user: user);
                          });
                        },
                        icon: const Icon(Icons.delete_outline));
                  }
                  return const SizedBox();
                 }(),
              ],
            ),
            const SizedBox(height: 15),
            Text(post.description),
            const SizedBox(height: 10),
            () {
              if (post.image != null) {
                return SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.network(post.image!),
                );
              } else {
                return const SizedBox();
              }
            }(),
          ],
        ),
      ),
    );
  }
}
