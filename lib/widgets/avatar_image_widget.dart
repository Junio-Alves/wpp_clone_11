import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/widgets/edit_image_widget.dart';

class AvatarImageWidget extends StatelessWidget {
  final Function(bool) editarFoto;
  final bool loadingImage;
  final String? imageUrl;
  final File? image;
  const AvatarImageWidget({
    super.key,
    required this.editarFoto,
    required this.loadingImage,
    this.image,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider backgroundImage() {
      if (imageUrl != null) {
        return NetworkImage(imageUrl!);
      } else if (image != null) {
        return FileImage(image!);
      } else {
        return const AssetImage("assets/images/default_user_pic.jpg");
      }
    }

    return Stack(
      children: [
        CircleAvatar(
          backgroundImage: backgroundImage(),
          radius: 100,
          child: loadingImage ? const CircularProgressIndicator() : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () => popUpEditImagem(context, editarFoto),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}
