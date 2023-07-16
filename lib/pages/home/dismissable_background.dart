import 'package:flutter/material.dart';

class DeleteBackgroundCardDismiss extends StatelessWidget {
  const DeleteBackgroundCardDismiss({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
        color: Colors.red,
        child: Padding(
            padding: EdgeInsets.only(left: 50),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'DELETE',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        fontSize: 16),
                  ),
                ],
              ),
            )));
  }
}

class OtherBackgroundCardDismiss extends StatelessWidget {
  const OtherBackgroundCardDismiss({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
        color: Colors.green,
        child: Padding(
            padding: EdgeInsets.only(right: 50),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'ARCHIVER',
                style:
                    TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              ),
            )));
  }
}
