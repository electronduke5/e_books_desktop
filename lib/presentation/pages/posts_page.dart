import 'package:e_books_desktop/presentation/cubits/models_status.dart';
import 'package:e_books_desktop/presentation/cubits/post/post_cubit.dart';
import 'package:e_books_desktop/presentation/widgets/post_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/post.dart';
import '../../data/models/user.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  User? user;
  List<Post> userPosts = [];
  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context)?.settings.arguments as User?;

    setState(() {
      context.read<PostCubit>().loadPosts(user: user);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Записи пользователя ${user?.surname ?? ''} ${user?.name ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<PostCubit, PostState>(
          builder: (context, state){
            switch (state.allPostsStatus.runtimeType){
              case const (LoadingStatus<List<Post>>):
                return const Center(child: CircularProgressIndicator());
              case const (FailedStatus):
                return const Center(child: Text('Ошибка при получении постов'));
              case const (LoadedStatus<List<Post>>):
                return ListView.builder(
                  itemCount: state.allPostsStatus.item!.length,
                  itemBuilder: (context, index){
                    return PostCard(post: state.allPostsStatus.item![index]);
                  },
                );
              default:
                return const Center(child: Text('Ошибка при получении постов'));
            }
          },
        ),
      ),
    );
  }
}
