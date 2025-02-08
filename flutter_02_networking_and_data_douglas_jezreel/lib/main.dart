import 'package:http/http.dart' as http;

void main() async {
  var apiBaseUrl = "https://jsonplaceholder.typicode.com";

  var albumsEndpoint = '$apiBaseUrl/albums/1';
  var responseUser = await http.get(
    Uri.parse(albumsEndpoint),
  );
  print(responseUser.body);

  var userId = 4;
  var showUserEndpoint = '$apiBaseUrl/users/$userId';
  responseUser = await http.get(
    Uri.parse(showUserEndpoint),
  );
  print("User details:");
  print(responseUser.body);

  // Fetch albums of a particular user
  var userAlbumsEndpoint = '$apiBaseUrl/users/$userId/albums';
  responseUser = await http.get(Uri.parse(userAlbumsEndpoint));
  print('User $userId Albums: ${responseUser.body}');

  // Fetch todos of a particular user
  var userTodosEndpoint = '$apiBaseUrl/users/$userId/todos';
  responseUser = await http.get(Uri.parse(userTodosEndpoint));
  print('User $userId Todos: ${responseUser.body}');

  // Fetch posts of a particular user
  var userPostsEndpoint = '$apiBaseUrl/users/$userId/posts';
  responseUser = await http.get(Uri.parse(userPostsEndpoint));
  print('User $userId Posts: ${responseUser.body}');

  // Fetch comments for post 1
  var postCommentsEndpoint = '$apiBaseUrl/posts/1/comments';
  responseUser = await http.get(Uri.parse(postCommentsEndpoint));
  print('Post 1 Comments: ${responseUser.body}');

  // Fetch photos for album 1
  var albumPhotosEndpoint = '$apiBaseUrl/albums/1/photos';
  responseUser = await http.get(Uri.parse(albumPhotosEndpoint));
  print('Album 1 Photos: ${responseUser.body}');
}
