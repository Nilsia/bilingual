import 'package:bilingual/models/words.dart';
import 'package:bilingual/utils/customColorScheme.dart';
import 'package:flutter/material.dart';

class WordsTile extends StatefulWidget {
  final Words words;
  final Color? backgroundColor;
  const WordsTile({super.key, required this.words, this.backgroundColor});

  @override
  State<WordsTile> createState() => _WordsTileState();
}

class _WordsTileState extends State<WordsTile> {
  late Words words;
  @override
  Widget build(BuildContext context) {
    words = super.widget.words;
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: super.widget.backgroundColor,
      alignment: Alignment.center,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Center(
                      child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: Theme.of(context)
                                .colorScheme
                                .borderAroundColor),
                        color: Theme.of(context).colorScheme.aroundColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 2),
                      child: Text(
                        words.translations[0],
                      ),
                    ),
                  )),
                )),
                Expanded(child: Center(child: Text(words.translations[1])))
              ],
            ),
          ),
          if (words.sentence.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4, bottom: 4),
                child: Text(
                  words.sentence,
                  maxLines: 3,
                  overflow: TextOverflow.fade,
                ),
              ),
            )
        ],
      ),
    );
  }
}
