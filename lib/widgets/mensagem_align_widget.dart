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
    final Timestamp horaTimeStamp = item["hora"] as Timestamp..toDate();
    final DateTime hora = horaTimeStamp.toDate();
    String data = "${hora.hour} : ${hora.minute}";

    return Align(
      alignment: aligment,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          width: larguraContainer,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item["mensagem"],
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              Text(
                data,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
