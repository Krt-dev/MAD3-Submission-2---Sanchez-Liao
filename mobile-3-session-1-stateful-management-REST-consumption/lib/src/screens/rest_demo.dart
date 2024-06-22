//there is a problem when i delete a post because the keys in the postlit or posts will not be aligned anymore.
//resolve this

import 'dart:convert';
import 'dart:math';
//updated 6/20/24 at 7:41 PM
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:state_change_demo/src/models/post.model.dart';
import 'package:state_change_demo/src/models/user.model.dart';

class RestDemoScreen extends StatefulWidget {
  const RestDemoScreen({super.key});

  @override
  State<RestDemoScreen> createState() => _RestDemoScreenState();
}

class _RestDemoScreenState extends State<RestDemoScreen> {
  PostController controller = PostController();

  @override
  void initState() {
    super.initState();
    controller.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts"),
        leading: IconButton(
            onPressed: () {
              controller.getPosts();
            },
            icon: const Icon(Icons.refresh)),
        actions: [
          IconButton(
              onPressed: () {
                showNewPostFunction(context);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (controller.error != null) {
                return Center(
                  child: Text(controller.error.toString()),
                );
              }

              if (!controller.working) {
                return Center(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (Post post in controller.postList)
                            GestureDetector(
                              onTap: () {
                                showConfirmationDialog(context, post.id,
                                    controller); //Works when displayed
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(15),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  width: 450,
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.blueAccent),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      Text("Title: ${post.title}"),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 190),
                                        child: Row(
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  EditPostDialog.show(context,
                                                      postID: post.id,
                                                      controller: controller);
                                                },
                                                icon: const Icon(Icons.edit)),
                                            IconButton(
                                                onPressed: () {
                                                  controller.deletePost(
                                                      postId: post.id);
                                                },
                                                icon: const Icon(Icons.delete)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                            )
                        ],
                      )),
                );
              }
              return const Center(
                child: SpinKitChasingDots(
                  size: 54,
                  color: Colors.black87,
                ),
              );
            }),
      ),
    );
  }

  showNewPostFunction(BuildContext context) {
    AddPostDialog.show(context, controller: controller);
  }

//details cards
  void showConfirmationDialog(
      BuildContext context, int postId, PostController controller) {
    var posts = controller.getPostByIdLocally(postId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ID: ${posts.id}\n"),
              Text("Title: ${posts.title}"),
              Text("Body: ${posts.body}\n"),
              Text("User: ${posts.userId}\n"),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class AddPostDialog extends StatefulWidget {
  static show(BuildContext context, {required PostController controller}) =>
      showDialog(
          context: context, builder: (dContext) => AddPostDialog(controller));
  const AddPostDialog(this.controller, {super.key});

  final PostController controller;

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  late TextEditingController bodyC, titleC;

  @override
  void initState() {
    super.initState();
    bodyC = TextEditingController();
    titleC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: const Text("Add new post"),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (titleC.text.trim().isEmpty || bodyC.text.trim().isEmpty) {
              return widget.controller.showAlertIfEmpty(context);
            } else {
              await widget.controller.makePost(
                  title: titleC.text.trim(),
                  body: bodyC.text.trim(),
                  userId: 1);
              Navigator.of(context).pop();
            }
          },
          child: const Text("Add"),
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Title"),
          Flexible(
            child: TextFormField(
              controller: titleC,
            ),
          ),
          const Text("Content"),
          Flexible(
            child: TextFormField(
              controller: bodyC,
            ),
          ),
        ],
      ),
    );
  }
}

//dialog for the edit post
class EditPostDialog {
  static Future<void> show(
    BuildContext context, {
    required int postID,
    required PostController controller,
  }) async {
    late TextEditingController bodyC, titleC;

    bodyC = TextEditingController();
    titleC = TextEditingController();

    await showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: const Text("Edit Post"),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (titleC.text.trim().isEmpty || bodyC.text.trim().isEmpty) {
                return controller.showAlertIfEmpty(context);
              } else {
                await controller.editPost(
                  postId: postID,
                  title: titleC.text.trim(),
                  body: bodyC.text.trim(),
                  userId: postID,
                );
              }

              Navigator.of(context).pop();
            },
            child: const Text("Edit"),
          )
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Title"),
            Flexible(
              child: TextFormField(
                controller: titleC,
              ),
            ),
            const Text("Content"),
            Flexible(
              child: TextFormField(
                controller: bodyC,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostController with ChangeNotifier {
  Map<String, dynamic> posts = {};
  bool working = true;
  Object? error;

  List<Post> get postList => posts.values.whereType<Post>().toList();

  clear() {
    error = null;
    posts = {};
    notifyListeners();
  }

  Post getPostByIdLocally(int postId) {
    return posts[postId.toString()];
  }

  Future<void> showAlertIfEmpty(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Validation Error'),
          content: const Text('Please input all fields'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  //to generate random ID
  int generateUniqueId() {
    Random random = Random();
    int id = random.nextInt(1000000);
    return id;
  }

  Future<Post> makePost(
      {required String title,
      required String body,
      required int userId}) async {
    try {
      working = true;
      if (error != null) error = null;
      print(title);
      print(body);
      print(userId);
      http.Response res = await HttpService.post(
          url: "https://jsonplaceholder.typicode.com/posts",
          body: {"title": title, "body": body, "userId": userId});
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      // print(res.body);

      // Map<String, dynamic> result = jsonDecode(res.body);
      //instea of getting the result from the json request to be made as a new post
      //we only did it locally using the provider or controller posts map
      //so that the ID of the post would not have error after deleting since the returned ID from
      //the http request for the newly made post to the backend is 101
      int randomId = generateUniqueId();

      while (posts.containsKey(randomId.toString())) {
        randomId = generateUniqueId();
      }
      Post madePost =
          Post(id: randomId, body: body, userId: randomId, title: title);

      posts[randomId.toString()] = madePost;
      working = false;
      notifyListeners();
      return madePost;
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
      return Post.empty;
    }
  }

  Future<Post> getPostById(int postId) async {
    http.Response res = await http
        .get(Uri.parse("https://jsonplaceholder.typicode.com/posts/$postId"));
    //modified this so that if the post with the corresponding postID is being fetch from the API
    //and it is not there then it should be in the posts map or list variable locally but if not
    //then it is an error it can't be found
    if (res.statusCode != 200 && res.statusCode != 201) {
      if (posts.containsKey(postId.toString())) {
        return posts[postId.toString()];
      }
      throw Exception("${res.statusCode} | ${res.body}");
    }
    var result = jsonDecode(res.body);
    return Post.fromJson(result);
  }

  Future<void> getPosts() async {
    try {
      working = true;
      clear();
      List result = [];
      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/posts");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      result = jsonDecode(res.body);

      List<Post> tmpPost = result.map((e) => Post.fromJson(e)).toList();
      posts = {for (Post p in tmpPost) "${p.id}": p};
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  Future<void> getPostsIndi(int postId) async {
    try {
      working = true;
      clear();
      http.Response res = await HttpService.get(
          url:
              "https://jsonplaceholder.typicode.com/posts/$postId"); // dynamic postId
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      var result = jsonDecode(res.body);

      List<Post> tmpPost = [Post.fromJson(result)];
      posts = {for (Post p in tmpPost) "${p.id}": p};

      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  //delete post
  Future<void> deletePost({required int postId}) async {
    try {
      working = true;
      if (error != null) error = null;
      http.Response res = await HttpService.delete(
          url: "https://jsonplaceholder.typicode.com/posts/$postId");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      if (posts.containsKey(postId.toString())) {
        posts.remove(postId.toString());
      }
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  //edit post
  Future<void> editPost(
      {required int postId,
      required String title,
      required String body,
      required int userId}) async {
    try {
      working = true;
      if (error != null) error = null;
      http.Response res = await HttpService.put(
          url: "https://jsonplaceholder.typicode.com/posts/$postId",
          body: {"title": title, "body": body, "userId": userId});

      if (res.statusCode != 200 && res.statusCode != 201) {
        if (!posts.containsKey(postId.toString())) {
          throw Exception("${res.statusCode} | ${res.body}");
        }
      }

      Post newEditedPost =
          Post(id: postId, body: body, userId: userId, title: title);
      posts[postId.toString()] = newEditedPost;
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }
}

class UserController with ChangeNotifier {
  Map<String, dynamic> users = {};
  bool working = true;
  Object? error;

  List<User> get userList => users.values.whereType<User>().toList();

  getUsers() async {
    try {
      working = true;
      List result = [];
      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/users");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      result = jsonDecode(res.body);

      List<User> tmpUser = result.map((e) => User.fromJson(e)).toList();
      users = {for (User u in tmpUser) "${u.id}": u};
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  clear() {
    users = {};
    notifyListeners();
  }
}

class HttpService {
  static Future<http.Response> get(
      {required String url, Map<String, dynamic>? headers}) async {
    Uri uri = Uri.parse(url);
    return http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }

  static Future<http.Response> post(
      {required String url,
      required Map<dynamic, dynamic> body,
      Map<String, dynamic>? headers}) async {
    Uri uri = Uri.parse(url);
    return http.post(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }

  static Future<http.Response> delete(
      {required String url, Map<String, dynamic>? headers}) async {
    Uri uri = Uri.parse(url);
    return http.delete(uri, headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }

  static Future<http.Response> put({
    required String url,
    required Map<dynamic, dynamic> body,
    Map<String, dynamic>? headers,
  }) async {
    Uri uri = Uri.parse(url);
    return http.put(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    });
  }
}
