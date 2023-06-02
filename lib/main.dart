import 'dart:io';

import 'package:e_books_desktop/presentation/cubits/auth/auth_cubit.dart';
import 'package:e_books_desktop/presentation/cubits/book/book_cubit.dart';
import 'package:e_books_desktop/presentation/cubits/post/post_cubit.dart';
import 'package:e_books_desktop/presentation/cubits/profile/profile_cubit.dart';
import 'package:e_books_desktop/presentation/cubits/review/review_cubit.dart';
import 'package:e_books_desktop/presentation/cubits/shelves/shelf_cubit.dart';
import 'package:e_books_desktop/presentation/cubits/theme/theme_cubit.dart';
import 'package:e_books_desktop/presentation/pages/auth_pages/code_confirm_page.dart';
import 'package:e_books_desktop/presentation/pages/auth_pages/sign_up_next.dart';
import 'package:e_books_desktop/presentation/pages/book_info_page.dart';
import 'package:e_books_desktop/presentation/pages/bookmarks_page.dart';
import 'package:e_books_desktop/presentation/pages/bookshelf_page.dart';
import 'package:e_books_desktop/presentation/pages/followers_page.dart';
import 'package:e_books_desktop/presentation/pages/loading_page.dart';
import 'package:e_books_desktop/presentation/pages/posts_page.dart';
import 'package:e_books_desktop/presentation/pages/profile_books_page.dart';
import 'package:e_books_desktop/presentation/pages/read_book_page.dart';
import 'package:e_books_desktop/presentation/pages/shelves_page.dart';
import 'package:e_books_desktop/presentation/pages/user_reviews_page.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/repository/preferences_repository.dart';
import 'presentation/di/app_module.dart';
import 'presentation/pages/auth_pages/sign_in.dart';
import 'presentation/pages/auth_pages/sign_up.dart';
import 'presentation/pages/main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppModule().provideDependencies();
  HttpOverrides.global = MyHttpOverrides();
  runApp(EBooksApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class EBooksApp extends StatefulWidget {
  late PreferencesRepository _preferencesRepository;

  EBooksApp({super.key}) {
    _preferencesRepository = AppModule.getPreferencesRepository();
  }

  @override
  State<EBooksApp> createState() => _EBooksAppState();
}

class _EBooksAppState extends State<EBooksApp> {
  late SharedPreferences prefs;

  @override
  void didChangeDependencies() async {
    prefs = await SharedPreferences.getInstance();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget._preferencesRepository.getUser(),
      builder: (context, user) {
        if (user.connectionState != ConnectionState.done) {
          return const LoadingPage();
        }
        return BlocProvider(
          create: (context) => ThemeCubit(prefs),
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) => MaterialApp(
              title: 'Flutter Demo',
              debugShowCheckedModeBanner: false,
              theme: FlexThemeData.light(
                scheme: FlexScheme.redWine,
                surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
                blendLevel: 20,
                subThemesData: const FlexSubThemesData(
                  blendOnLevel: 10,
                  blendOnColors: false,
                  inputDecoratorIsFilled: false,
                  inputDecoratorRadius: 15.0,
                  // textButtonRadius: 15.0,
                  // elevatedButtonRadius: 15.0,
                  // outlinedButtonRadius: 15.0,
                  cardRadius: 15.0,
                ),
                visualDensity: FlexColorScheme.comfortablePlatformDensity,
                useMaterial3: true,
                swapLegacyOnMaterial3: true,
                fontFamily: GoogleFonts.literata().fontFamily,
              ),
              darkTheme: FlexThemeData.dark(
                scheme: FlexScheme.redWine,
                surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
                blendLevel: 20,
                subThemesData: const FlexSubThemesData(
                  blendOnLevel: 20,
                  inputDecoratorIsFilled: false,
                  inputDecoratorRadius: 25.0,
                  cardRadius: 15.0,
                ),
                visualDensity: FlexColorScheme.comfortablePlatformDensity,
                useMaterial3: true,
                swapLegacyOnMaterial3: true,
                fontFamily: GoogleFonts.literata().fontFamily,
              ),
              themeMode: context.read<ThemeCubit>().getCurrentTheme,
              routes: {
                '/sign-in': (context) => BlocProvider<AuthCubit>(
                  create: (context) => AuthCubit(),
                  child: SignInPage(),
                ),
                '/sign-up': (context) => BlocProvider<AuthCubit>(
                  create: (context) => AuthCubit(),
                  child: SignUpPage(),
                ),
                '/sign-up-next': (context) => BlocProvider<AuthCubit>(
                  create: (context) => AuthCubit(),
                  child: SignUpNextPage(),
                ),
                '/codeConfirmPage': (context) => BlocProvider<AuthCubit>(
                  create: (context) => AuthCubit(),
                  child: const CodeConfirmPage(),
                ),
                '/book-info': (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider<BookCubit>(
                        create: (context) => BookCubit()),
                    BlocProvider<ShelfCubit>(
                        create: (context) => ShelfCubit()),
                    BlocProvider<ReviewCubit>(
                        create: (context) => ReviewCubit()),
                  ],
                  child: BookInfoPage(),
                ),
                '/shelves': (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider<ShelfCubit>(
                        create: (context) => ShelfCubit()..loadShelves()),
                  ],
                  child: ShelvesPage(),
                ),
                '/user-reviews': (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider<ReviewCubit>(
                        create: (context) => ReviewCubit()),
                  ],
                  child: UserReviewsPage(),
                ),
                '/bookshelf': (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider<ShelfCubit>(
                        create: (context) => ShelfCubit()),
                  ],
                  child: const BookshelfPage(),
                ),
                '/bookmarks': (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider<BookCubit>(
                        create: (context) => BookCubit()..loadBookmarks()),
                  ],
                  child: BookmarkPage(),
                ),
                '/profile-posts': (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider<PostCubit>(
                        create: (context) => PostCubit()),
                  ],
                  child: PostsPage(),
                ),
                '/profile-followers' : (context) => FollowersPage(),
                '/profile-books': (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider<BookCubit>(
                        create: (context) => BookCubit()),
                  ],
                  child: ProfileBooksPage(),
                ),
                '/read-book': (context) => const ReadBookPage(),
                '/main': (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider<ProfileCubit>(
                        create: (context) => ProfileCubit()..loadProfile()),
                    BlocProvider<BookCubit>(
                        create: (context) => BookCubit()..loadBooks()),
                    BlocProvider<PostCubit>(
                        create: (context) => PostCubit()),
                  ],
                  child: const MainPage(),
                ),
              },
              initialRoute: user.data == null ? '/sign-in' : '/main',
            ),
          ),
        );
      },
    );
  }
}
