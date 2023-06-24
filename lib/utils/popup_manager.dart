import 'package:flutter/material.dart';

class PopupManager {
  static Future<String> popupPathAdder(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Adding a path"),
              content: TextFormField(
                controller: controller,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      controller.text = '';
                    },
                    child: const Text("CANCEL")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("ADD"))
              ],
            ));

    return controller.text.trim().replaceAll('/', '');
  }
}
