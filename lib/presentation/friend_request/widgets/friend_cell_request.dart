import 'package:cached_network_image/cached_network_image.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';

import 'package:ccvc_mobile/utils/constants/image_asset.dart';
import 'package:flutter/material.dart';

import '../../../config/resources/color.dart';
import '../../../config/resources/styles.dart';

class FriendRequestCellWidget extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final PeopleType? peopleType;
  final Function() onAccept;
  final Function() onDelete;
  const FriendRequestCellWidget({
    Key? key,
    required this.name,
    required this.avatarUrl,
    this.peopleType,
    required this.onAccept,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.teal),
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                errorWidget: (context, url, error) =>
                    Image.asset(ImageAssets.avatarDefault),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: textNormal(colorBlack, 16),
              ),
              Row(
                children: [
                  button(
                      onTap: () {
                        onAccept();
                      },
                      title: 'Xác nhận',
                      backGround: Color(0xff2374E1)),
                  const SizedBox(
                    width: 10,
                  ),
                  button(
                      onTap: () {
                        onDelete();
                      },
                      title: 'Xóa',
                      backGround: Colors.black.withOpacity(0.4))
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget button(
      {required Color backGround,
      required Function() onTap,
      required String title}) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
            color: backGround,
            borderRadius: const BorderRadius.all(Radius.circular(4))),
        child: Text(
          title,
          style: textNormalCustom(color: Colors.white),
        ),
      ),
    );
  }
}
