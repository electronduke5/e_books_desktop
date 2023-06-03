import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models/author.dart';
import '../../data/models/book.dart';

class BookCoverText extends StatelessWidget {
  BookCoverText({
    super.key,
    required this.book,
    this.height = 230,
    this.firstColor,
    this.secondColor,
  });

  final Book book;
  final double height;
  Color? firstColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
  Color? secondColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    firstColor!,
                    secondColor!,
                  ],
                )),
            height: height,
            width: height / 1.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  book.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                () {
                  if (book.authors == []) {
                    return const Text('Авторов нет');
                  }
                  for (Author author in book.authors!) {
                    return Text(author.getFullName(),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16));
                  }
                  return const Text('');
                }(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
