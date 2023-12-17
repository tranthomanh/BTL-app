import 'dart:typed_data';

import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/utils/constants/image_asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class PickImageWidget extends StatefulWidget {
  final Uint8List? image;
  final Function removeImage;

  const PickImageWidget({
    Key? key,
    required this.image,
    required this.removeImage,
  }) : super(key: key);

  @override
  State<PickImageWidget> createState() => _PickImageWidgetState();
}

class _PickImageWidgetState extends State<PickImageWidget> {
  void removeImg() {
    widget.removeImage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.image == null ? Container() : imageWidget();
  }

  Widget imageWidget() {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorDBDFEF.withOpacity(0.5)),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: MemoryImage(widget.image ?? Uint8List(0)),
            ),
            boxShadow: [
              BoxShadow(
                color: color6566E9.withOpacity(0.05),
                offset: const Offset(0, 4),
                blurRadius: 10,
              )
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () {
              removeImg();
            },
            child: SvgPicture.asset(ImageAssets.icRemoveImg),
          ),
        )
      ],
    );
  }
}
