import 'dart:typed_data';
import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/presentation/home_screen/bloc/create_post_cubit.dart';
import 'package:ccvc_mobile/presentation/home_screen/ui/widget/pick_image_widget.dart';
import 'package:ccvc_mobile/utils/constants/image_asset.dart';
import 'package:ccvc_mobile/widgets/button/button_custom_bottom.dart';
import 'package:ccvc_mobile/widgets/dialog/show_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreatePostScreen extends StatefulWidget {
  final UserModel userModel;
  final Function(Uint8List? image, String content) createPost;

  const CreatePostScreen({
    Key? key,
    required this.userModel,
    required this.createPost,
  }) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  TextEditingController textEditingController = TextEditingController();
  final CreatePostCubit cubit = CreatePostCubit();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bài viết mới',
                style: textNormalCustom(fontSize: 18, color: textTitle),
              ),
              GestureDetector(
                onTap: () {
                  cubit.pickImage();
                },
                child: SvgPicture.asset(
                  ImageAssets.icImage,
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: textEditingController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        cubit.isPost.add(true);
                      } else if (cubit.imageSubject.valueOrNull == null &&
                          value.isEmpty) {
                        cubit.isPost.add(false);
                      }
                    },
                    decoration: InputDecoration(
                      hintStyle:
                          textNormalCustom(fontSize: 14, color: Colors.grey),
                      border: InputBorder.none,
                      hintText: 'Bạn đang nghĩ gì?',
                    ),
                  ),
                  spaceH20,
                  StreamBuilder<Uint8List?>(
                    stream: cubit.imageSubject.stream,
                    builder: (context, snapshot) {
                      final data = snapshot.data;
                      return PickImageWidget(
                        image: data,
                        removeImage: () {
                          cubit.imageSubject.add(null);
                          if (textEditingController.text.isEmpty) {
                            cubit.isPost.add(false);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          spaceH20,
          Row(
            children: [
              Expanded(
                child: ButtonCustomBottom(
                  title: 'Đóng',
                  isColorBlue: true,
                  onPressed: () {
                    if (cubit.isPost.value) {
                      showDiaLogCustom(
                        context,
                        title: 'Bài đăng',
                        textContent: 'Bạn có chắc muốn thoát không ?',
                        btnRightTxt: 'Xác nhận',
                        btnLeftTxt: 'Đóng',
                        funcBtnRight: () {
                          Navigator.pop(context, '');
                        },
                      );
                    } else {
                      Navigator.pop(context, '');
                    }
                  },
                ),
              ),
              spaceW15,
              StreamBuilder<bool>(
                stream: cubit.isPost.stream,
                builder: (context, snapshot) {
                  final isPost = snapshot.data ?? false;

                  return Expanded(
                    child: ButtonCustomBottom(
                      title: 'Đăng',
                      isColorBlue: isPost,
                      onPressed: () {
                        if (cubit.isPost.value) {
                          widget.createPost(
                            cubit.imageSubject.value,
                            textEditingController.text,
                          );
                          Navigator.pop(context, '');
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          spaceH10,
        ],
      ),
    );
  }
}
