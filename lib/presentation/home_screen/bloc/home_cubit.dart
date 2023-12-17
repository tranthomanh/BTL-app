import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:ccvc_mobile/config/base/base_cubit.dart';
import 'package:ccvc_mobile/config/default_env.dart';
import 'package:ccvc_mobile/data/helper/firebase/firebase_store.dart';
import 'package:ccvc_mobile/domain/locals/prefs_service.dart';
import 'package:ccvc_mobile/domain/model/comment_model.dart';
import 'package:ccvc_mobile/domain/model/post_model.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/domain/repository/post_repository.dart';
import 'package:ccvc_mobile/domain/repository/user_repository.dart';
import 'package:ccvc_mobile/presentation/home_screen/bloc/home_state.dart';
import 'package:ccvc_mobile/utils/extensions/string_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/utils/utils.dart';
import 'package:rxdart/subjects.dart';

class HomeCubit extends BaseCubit<HomeState> {
  HomeCubit() : super(HomeStateInitial()) {
    userId = PrefsService.getUserId();
    log(userId);
    getUserModel();
    getUserInfo(userId);
    getAllPosts();
  }

  UserModel userModel = UserModel.empty();

  String userId = '';
  final BehaviorSubject<List<String>> _posts =
      BehaviorSubject<List<String>>.seeded([]);
  List<String> idPosts = [];

  Stream<List<String>> get posts => _posts.stream;

  final BehaviorSubject<int> _unreadNotis = BehaviorSubject<int>.seeded(0);

  Stream<int> get unreadNotis => _unreadNotis.stream;

  final BehaviorSubject<UserModel> _user =
      BehaviorSubject<UserModel>.seeded(UserModel());

  Stream<UserModel> get user => _user.stream;

  final BehaviorSubject<List<String>> _blockList =
      BehaviorSubject<List<String>>.seeded([]);

  Stream<List<String>> get blockList => _blockList.stream;
  Map<String, UserModel?> _userPost = {};

  PostRepository _postRepository = PostRepository();
  UserRepopsitory _userRepopsitory = UserRepopsitory();

  Future<void> createPost({
    Uint8List? image,
    required String content,
  }) async {
    showLoading();
    String imgUrl = '';
    // final UserModel? userModel = HiveLocal.getDataUser();

    final postId = getRandString(15).removeChar;
    final createAt = DateTime.now().millisecondsSinceEpoch;
    final updateAt = DateTime.now().millisecondsSinceEpoch;
    if (image != null) {
      await FireStoreMethod.uploadImageFromCreatePost(
        id: _user.value.userId ?? '',
        idPost: postId,
        file: image,
      );

      imgUrl = await FireStoreMethod.downImageCreatePost(
        id: _user.value.userId ?? '',
        idPost: postId,
      );
    }

    final PostModel model = PostModel(
      author: _user.value,
      type: image == null ? 1 : 2,
      createAt: createAt,
      updateAt: updateAt,
      content: content,
      imageUrl: imgUrl,
      likes: [],
      postId: postId,
      comments: [],
    );
    await FireStoreMethod.createPost(model: model, postId: postId);

    showContent();
  }

  Future<void> getUserModel() async {
    userModel = await FireStoreMethod.getDataUserInfo(userId);
  }

  Stream<PostModel> postList(String idPost) {
    return FirebaseFirestore.instance
        .collection(DefaultEnv.appCollection)
        .doc(DefaultEnv.developDoc)
        .collection(DefaultEnv.postsCollection)
        .doc(idPost)
        .snapshots()
        .transform(
      StreamTransformer.fromHandlers(
        handleData: (docSnap, sink) async {
          Map<String, dynamic> post = {};
          post.addAll({'post_id': docSnap.id});
          post.addAll(docSnap.data() ?? {});
          PostModel newPost = PostModel.fromJson(post);
          newPost.postId = docSnap.id;
          if (_userPost[post['user_id']] == null) {
            final user =
                await UserRepopsitory().getUserProfile(userId: post['user_id']);
            _userPost.addAll({post['user_id']: user});
            newPost.author = user;
          } else {
            newPost.author = _userPost[post['user_id']];
          }

          final comments = await FirebaseFirestore.instance
              .collection(DefaultEnv.appCollection)
              .doc(DefaultEnv.developDoc)
              .collection(DefaultEnv.postsCollection)
              .doc(docSnap.id)
              .collection('comments')
              .orderBy('create_at', descending: true)
              .get();
          List<CommentModel> cmts = [];
          for (var cmt in comments.docs) {
            cmt.data().addAll({'comment_id': cmt.id});
            CommentModel commentModel = CommentModel.fromJson(cmt.data());
            cmts.add(commentModel);
          }
          newPost.comments = cmts;
          sink.add(newPost);
        },
      ),
    );
  }

  Future<void> getAllPosts() async {
    log(DateTime.now().toString());
    showLoading();
    await getBlockList(userId);
    try {
      FirebaseFirestore.instance
          .collection(DefaultEnv.appCollection)
          .doc(DefaultEnv.developDoc)
          .collection(DefaultEnv.postsCollection)
          .orderBy('create_at', descending: false)
          .snapshots()
          .listen((event) async {
        if (event.docs == null) {
          return null;
        } else {
          idPosts = [];
          log("message");
          for (var x in event.docs) {
            // debugPrint(relationship['user_id2']);
            log('${x.id}');
            if (idPosts.indexWhere((element) => element == x.id) != -1) {
              continue;
            }

            if (!_blockList.value.contains(x.data()['user_id'])) {
              // idPosts.add(x.id);
              idPosts.insert(0, x.id);
              // log('huhu');
              // Map<String, dynamic> post = {};
              // post.addAll({'post_id': x.id});
              // post.addAll(x.data());
              // log(post.toString());
              //
              // PostModel newPost = PostModel.fromJson(post);
              //
              // //get user
              // final user = await UserRepopsitory()
              //     .getUserProfile(userId: post['user_id']);
              // newPost.author = user;
              //
              // //get comments
              // final comments = await FirebaseFirestore.instance
              //     .collection(DefaultEnv.appCollection)
              //     .doc(DefaultEnv.developDoc)
              //     .collection(DefaultEnv.postsCollection)
              //     .doc(x.id)
              //     .collection('comments')
              //     .orderBy('create_at', descending: true)
              //     .get();
              // List<CommentModel> cmts = [];
              // for (var cmt in comments.docs) {
              //   cmt.data().addAll({'comment_id': cmt.id});
              //   CommentModel commentModel = CommentModel.fromJson(cmt.data());
              //   cmts.add(commentModel);
              // }
              // newPost.comments = cmts;
              // debugPrint(newPost.toString());
              // posts.add(newPost);
            }

          }
          _posts.sink.add(idPosts);
          showContent();
        }
      });
    } catch (e) {
      log(e.toString());
      showError();
    }
  }

  Future<void> getBlockList(userid) async {
    final List<String> blocks = [];

    debugPrint('gggggggggggg');
    showLoading();
    try {
      FirebaseFirestore.instance
          .collection(DefaultEnv.appCollection)
          .doc(DefaultEnv.developDoc)
          .collection(DefaultEnv.usersCollection)
          .doc(userId)
          .collection(DefaultEnv.relationshipsCollection)
          .snapshots()
          .listen((event) async {
        if (event.docs == null && event.size == 0) {
          return null;
        } else {
          for (var i in event.docs) {
            final relationship = i.data();
            if (relationship['type'] == 2) {
              debugPrint(relationship['user_id2']);
              blocks.add(relationship['user_id2']);
            }
          }
          debugPrint(blocks.toString());
          _blockList.sink.add(blocks);
          showContent();
        }
      });
    } catch (e) {
      log(e.toString());
      showError();
    }
  }

  Future<void> getUserInfo(userId) async {
    showLoading();
    try {
      final result = await _userRepopsitory.getUserProfile(userId: userId);
      if (result != null) {
        log('pppp' + result.toString());
        _user.sink.add(result);
        //   showContent();
      } else {
        showError();
      }
    } catch (e) {
      log(e.toString());
      showError();
    }
  }

  Future<void> likePost(
      {required String postId, required List<String> likes}) async {
    log('ppppppppppppppppp');
    // try{
    //   await _postRepository.likePost(
    //     postId,
    //     _user.value.userId!,
    //     likes,
    //   );
    // await getAllPosts();
    //
    // }catch (e) {
    //   log(e.toString());
    //   showError();
    // }
  }

  Future<void> deletePost({required String postId}) async {
    // try{
    //   await _postRepository.deletePost(
    //     postId,
    //   );
    // await getAllPosts();
    // }catch (e) {
    //   log(e.toString());
    //   showError();
    // }
  }
}
