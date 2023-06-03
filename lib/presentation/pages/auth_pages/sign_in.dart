import 'package:e_books_desktop/presentation/cubits/auth/auth_cubit.dart';
import 'package:e_books_desktop/presentation/cubits/models_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user.dart';
import '../../widgets/snack_bar.dart';

class SignInPage extends StatelessWidget {
  SignInPage({Key? key}) : super(key: key);

  final TextEditingController _emailController =
      TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            switch (state.apiStatus.runtimeType) {
              case const (FailedStatus<User>):
                SnackBarInfo.show(
                  context: context,
                  message: state.apiStatus.message?.substring(11) ??
                      'Неверный логин или пароль',
                  isSuccess: false,
                );
                context
                    .read<AuthCubit>()
                    .state
                    .copyWith(apiStatus: const IdleStatus());
                break;
              case const (LoadedStatus<User>):
                  Navigator.of(context).pushNamed('/codeConfirmPage', arguments: {
                    'email': _emailController.value.text,
                    'hash': state.hash,
                  });

                break;
            }
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: SizedBox(
                    width:  MediaQuery.of(context).size.width / 2.3,
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Form(
                          key: _key,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Укажите свой адрес\n электронной почты, чтобы получить проверочный код',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 25),
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20.0),
                                    labelText: 'Эл. адрес',
                                    suffixIcon: Icon(Icons.alternate_email),
                                    hintText: 'example@mail.ru',
                                  ),
                                ),
                              ),
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) => ElevatedButton(
                                  onPressed: () async {
                                    if (_key.currentState?.validate() ?? false) {
                                      context
                                          .read<AuthCubit>()
                                          .emailChanged(_emailController.value.text);

                                      await context.read<AuthCubit>().sendAuthCode().then((value) {
                                        if(state.apiStatus is FailedStatus<User>){
                                          SnackBarInfo.show(
                                            context: context,
                                            message: state.apiStatus.message?.substring(11) ??
                                                'Ошибка при отправке кода',
                                            isSuccess: false,
                                          );
                                        }
                                        else if(state.apiStatus is LoadedStatus<User>){
                                          SnackBarInfo.show(
                                              context: context,
                                              message:
                                              'На вашу почту отправлено письмо для подтверждения почты!',
                                              isSuccess: true);
                                        }
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text('Дальше'),
                                  ),
                                ),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushReplacementNamed('/sign-up');
                                  },
                                  child: Text('Ещё нет профиля?')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
