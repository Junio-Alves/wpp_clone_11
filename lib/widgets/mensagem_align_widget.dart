import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MensagemAlignWidget extends StatelessWidget {
  final AlignmentGeometry aligment;
  final double larguraContainer;
  final Color color;
  final DocumentSnapshot<Object?> item;
  const MensagemAlignWidget({
    super.key,
    required this.aligment,
    required this.larguraContainer,
    required this.color,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final Timestamp horaTimeStamp = item["hora"] as Timestamp;
    final DateTime hora = horaTimeStamp.toDate();
    String data = "${hora.hour} : ${hora.minute}";
    String mensagem = item["mensagem"];

    return Align(
      alignment: aligment,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item["mensagem"],
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
