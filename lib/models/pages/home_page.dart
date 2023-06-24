import 'package:bilingual/models/database_manager.dart';
import 'package:bilingual/models/pages/home/dismissable_background.dart';
import 'package:bilingual/models/pages/home/words_tile.dart';
import 'package:bilingual/models/words.dart';
import 'package:bilingual/utils/backup_manager.dart';
import 'package:bilingual/utils/customColorScheme.dart';
import 'package:bilingual/utils/popup_manager.dart';
import 'package:bilingual/utils/tools.dart';
import 'package:flutter/material.dart';

/*mettre en valeur le premier mot
une ligne grise une ligne sur 2
ajouter du padding (aération)
menu en bas : archives, nouveau, tout
*/

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Words> wordsList = [];
  final String languages = 'fren';
  DatabaseManager mdb = DatabaseManager(hasToInit: false);

  DateTime selectedDate = DateTime.now();
  TextEditingController word1TEC = TextEditingController(),
      word2TEC = TextEditingController(),
      sentenceTEC = TextEditingController(),
      dateTEC = TextEditingController();

  DismissDirection currentDismissDirection = DismissDirection.startToEnd;
  Widget backgroundTiles = const DeleteBackgroundCardDismiss();

  BackupManager backupManager = BackupManager();

  Offset _tapPosition = Offset.zero;

  List<Color> backgroundList = [];

  final double wordsTileHeight = 80;

  List<String?> allPathes = ["/custom", null, "/new", "/archive"];
  String? selectedPath = "/new";
  int _selectedIndexBNB = 2;

  RenderObject? overlay;

  @override
  void initState() {
    overlay = Overlay.of(context).context.findRenderObject();
    initControllers();
    updateWordsList();
    initAllPathes();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    backgroundList = [
      Theme.of(context).colorScheme.backgroundListDistinct1,
      Theme.of(context).colorScheme.backgroundListDistinct2
    ];
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTapDown: moreTapped,
              child: const Icon(Icons.more_vert),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              child: Icon(Icons.settings),
            ),
          )
        ],
        title: const Text("Bilingual"),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            /* SliverAppBar(pinned: true, toolbarHeight: 120, title: buildForm()), */
            SliverFixedExtentList(
              itemExtent: wordsTileHeight,
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int i) =>
                      buildWordsTile(wordsList[i], i),
                  childCount: wordsList.length),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.star_border), label: "Custom"),
          BottomNavigationBarItem(
              icon: Icon(Icons.all_inclusive_rounded), label: "All"),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: "New"),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: "Archive")
        ],
        currentIndex: _selectedIndexBNB,
        onTap: _onItemBOBTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showWordsDialog(popupAction: PopupAction.add),
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  void moreTapped(TapDownDetails details) {
    _getTapPosition(details);
    overlay = Overlay.of(context).context.findRenderObject();

    List<PopupMenuItem> items = getOnlyCustomPathes()
        .map((e) => PopupMenuItem(
              value: e,
              child: Text(e ?? '/error'),
            ))
        .toList();

    showMenu(
            context: context,
            position: RelativeRect.fromRect(
                Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
                Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                    overlay!.paintBounds.size.height)),
            items: items)
        .then((value) {
      if (value != null) {
        selectedPath = value;
      }
      _selectedIndexBNB = 0;
      updateWordsList();
      setState(() {});
    });
  }

  Iterable<String?> getOnlyCustomPathes() {
    return allPathes.getRange(4, allPathes.length);
  }

  void _onItemBOBTapped(int index) {
    _selectedIndexBNB = index;

    selectedPath = index != 0
        ? allPathes[index]
        : (getOnlyCustomPathes().toList().firstOrNull ?? allPathes[index]);

    updateWordsList();
  }

  void initControllers({Words? words}) {
    words ??= Words(0, ["", ""], DateTime.now(), '/', '', '');
    word1TEC = TextEditingController(text: words.translations[0]);
    word2TEC = TextEditingController(text: words.translations[1]);
    sentenceTEC = TextEditingController(text: words.sentence);
    dateTEC = TextEditingController(text: Tools.formatDate(words.creationDate));
  }

  Future<bool> onSubmitWords(
      {String? s, required PopupAction popupAction, Words? words}) async {
    if (words != null && popupAction == PopupAction.add) {
      mdb.addWords(words).then((value) {
        if (value <= -1) {
          Tools.showNormalSnackBar(context, "Cannot clone the words");
        }
        updateWordsList();
      });
      initControllers();
      return true;
    }
    if (word1TEC.text.trim().isEmpty) {
      Tools.showNormalSnackBar(context, "The word 1 is empty");
    } else if (word2TEC.text.trim().isEmpty) {
      Tools.showNormalSnackBar(context, "The word 2 is empty");
    } else {
      switch (popupAction) {
        case PopupAction.add:
          mdb
              .addWords(Words(
                  0,
                  [word1TEC.text.trim(), word2TEC.text.trim()],
                  selectedDate,
                  selectedPath ?? '/new',
                  sentenceTEC.text.trim(),
                  languages))
              .then((value) {
            if (value <= -1) {
              Tools.showNormalSnackBar(
                  context, "An error occured while adding the words.");
            }
            updateWordsList();
          });
          break;
        case PopupAction.edit:
          if (words == null) {
            Tools.showNormalSnackBar(context, "A strange error occured");
            return false;
          }
          print(selectedPath);
          mdb
              .updateWords(Words(
                  words.id,
                  [word1TEC.text.trim(), word2TEC.text.trim()],
                  selectedDate,
                  selectedPath ?? "/new",
                  sentenceTEC.text.trim(),
                  languages))
              .then((v) {
            if (v <= -1) {
              Tools.showNormalSnackBar(
                  context, "An error occured during the edition of the words.");
            }
            updateWordsList();
          });
        default:
      }
      initControllers();
      return true;
    }
    return false;
  }

  void checkDirectionChanged(DismissUpdateDetails dismissUpdateDetails) {
    DismissDirection dismissDirection = dismissUpdateDetails.direction;
    if (dismissDirection != currentDismissDirection) {
      setState(() {
        switch (dismissDirection) {
          // delete
          case DismissDirection.startToEnd:
            backgroundTiles = const DeleteBackgroundCardDismiss();
            currentDismissDirection = dismissDirection;
            break;

          case DismissDirection.endToStart:
            backgroundTiles = const OtherBackgroundCardDismiss();
            currentDismissDirection = dismissDirection;
            break;
          default:
        }
      });
    }
  }

  void onDismissed(
    DismissDirection direction,
    int wordsID,
    int index,
  ) {
    if (direction == DismissDirection.startToEnd) {
      removeWords(wordsID, index);
    } else if (direction == DismissDirection.endToStart) {
      mdb.setWordsPath(wordsID, "/archive").then((value) {
        if (value <= -1) {
          Tools.showNormalSnackBar(context, "Cannot put the words in archive.");
        }
        updateWordsList();
      });
    }
  }

  void removeWords(int wordsID, int index) {
    mdb.removeWords(wordsID).then((v) async {
      if (v <= -1) {
        Tools.showNormalSnackBar(
            context, "An error occured during the suppression of the words.");
      } else {
        setState(() {
          Words removed = wordsList.removeAt(index);
          backupManager.addBackup((p0) => mdb.addWords(p0), removed);
        });
        Tools.showNormalSnackBar(context, "You have removed words",
            duration: const Duration(milliseconds: 2000),
            snackBarAction: SnackBarAction(
                label: 'RESTAURER',
                onPressed: () async {
                  backupManager.executeBackup().then((value) {
                    if (value <= -1) {
                      Tools.showNormalSnackBar(context,
                          'An error occured durint the restauration of the words.');
                    }
                    backupManager.clear();
                    updateWordsList();
                  });
                }));
      }
    });
  }

  Widget buildWordsTile(Words words, int i) {
    List<PopupMenuItem> items = [
      const PopupMenuItem(
        value: "remove",
        child: Text("remove"),
      ),
      const PopupMenuItem(
        value: "edit",
        child: Text("Edit"),
      ),
      const PopupMenuItem(
        value: "clone",
        child: Text("Clone"),
      )
    ];

    overlay = Overlay.of(context).context.findRenderObject();

    return Dismissible(
        direction: DismissDirection.horizontal,
        onUpdate: checkDirectionChanged,
        onDismissed: (DismissDirection direction) =>
            onDismissed(direction, words.id, i),
        background: backgroundTiles,
        key: ValueKey<Words>(words),
        child: GestureDetector(
          onTapDown: _getTapPosition,
          onLongPress: () async => await showMenu(
                  context: context,
                  position: RelativeRect.fromRect(
                      Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
                      Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                          overlay!.paintBounds.size.height)),
                  items: items)
              .then((value) {
            switch (value) {
              case "remove":
                removeWords(words.id, i);
                break;
              case "edit":
                showWordsDialog(popupAction: PopupAction.edit, words: words);
                break;
              case "clone":
                onSubmitWords(popupAction: PopupAction.add, words: words);
            }
          }),
          child: WordsTile(
            backgroundColor: backgroundList[i % 2],
            words: words,
          ),
        ));
  }

  void _getTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = referenceBox.globalToLocal(details.globalPosition);
    });
  }

  void showWordsDialog({Words? words, required PopupAction popupAction}) {
    initControllers(words: words);
    selectedPath = words != null ? words.containingPath : "/new";

    final String title, mainButton;
    switch (popupAction) {
      case PopupAction.edit:
        title = "Editing an element";
        mainButton = "EDIT";
        break;
      case PopupAction.add:
        title = "Adding an element";
        mainButton = "ADD";
        break;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
              height: 280,
              child: buildForm(
                  words: words,
                  popupAction: popupAction,
                  update: () => setState(() {}))),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("CANCEL")),
            TextButton(
                onPressed: () {
                  onSubmitWords(popupAction: popupAction, words: words)
                      .then((value) {
                    if (value) {
                      Navigator.of(context).pop();
                    }
                  });
                },
                child: Text(mainButton))
          ],
        );
      }),
    );
  }

  buildForm(
      {Words? words,
      required PopupAction popupAction,
      required void Function() update}) {
    var items =
        Tools.nullFilter(allPathes.getRange(1, allPathes.length).toList())
            .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList();
    return Column(
      children: [
        Row(
          children: [
            // word1
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                height: 30,
                child: Center(
                    child: TextFormField(
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  onFieldSubmitted: word2TEC.text.trim().isEmpty ||
                          sentenceTEC.text.trim().isEmpty
                      ? null
                      : (_) => onSubmitWords(popupAction: popupAction),
                  onChanged: (value) => update(),
                  textInputAction: word2TEC.text.trim().isEmpty
                      ? TextInputAction.next
                      : TextInputAction.go,
                  controller: word1TEC,
                )),
              ),
            )),
            // word 2
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SizedBox(
                height: 30,
                child: Center(
                    child: TextFormField(
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  onFieldSubmitted: word1TEC.text.trim().isEmpty ||
                          sentenceTEC.text.trim().isEmpty
                      ? null
                      : (_) =>
                          onSubmitWords(popupAction: popupAction, words: words),
                  onChanged: (value) => update(),
                  controller: word2TEC,
                  textInputAction: word1TEC.text.trim().isEmpty
                      ? TextInputAction.next
                      : TextInputAction.go,
                )),
              ),
            )),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        // sentence
        SizedBox(
          height: 100,
          child: TextFormField(
            expands: true,
            maxLines: null,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onFieldSubmitted: word2TEC.text.trim().isEmpty ||
                    sentenceTEC.text.trim().isEmpty
                ? null
                : (_) => onSubmitWords(popupAction: popupAction, words: words),
            onChanged: (value) => update(),
            textInputAction: sentenceTEC.text.trim().isEmpty
                ? TextInputAction.next
                : TextInputAction.go,
            controller: sentenceTEC,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        // date
        InkWell(
          onTap: () async {
            selectedDate = await Tools.selectDate(
                    context, DateTime.now(), dateTEC,
                    setState: () => update()) ??
                DateTime.now();
          },
          child: SizedBox(
            child: TextFormField(
              controller: dateTEC,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              enabled: false,
            ),
          ),
        ),
        // path
        Row(
          children: [
            DropdownButton(
                value: selectedPath,
                items: items,
                onChanged: (String? s) async {
                  selectedPath = s ?? "/uknown";
                  if (selectedPath == allPathes.last) {
                    String res = await PopupManager.popupPathAdder(context);
                    if (res.isNotEmpty) {
                      if (res[0] != '/') {
                        res = '/$res';
                      }
                      selectedPath = res;
                      allPathes.insert(allPathes.length - 1, selectedPath);
                    }
                  }
                  update();
                })
          ],
        )
      ],
    );
  }

  void initAllPathes() {
    mdb.init().then((value) async {
      mdb.getAllPathes().then((value) {
        value.removeWhere(
            (element) => element == '/new' || element == "/archive");
        allPathes.addAll(value);
        setState(() {});
      });
    });
  }

  void sortWords() {
    wordsList.sort((a, b) => -a.creationDate.compareTo(b.creationDate));
  }

  void updateWordsList() {
    mdb.init().then((v) => {
          mdb.getAllWords(path: selectedPath).then(
              (value) => {wordsList = value, sortWords(), setState(() {})})
        });
  }
}
