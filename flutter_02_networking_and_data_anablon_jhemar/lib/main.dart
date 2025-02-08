import 'package:http/http.dart' as http;

void main() async {
  var apiBaseUrl = "https://jsonplaceholder.typicode.com";

  var albumsEndpoint = '$apiBaseUrl/albums/1';
  var response = await http.get(
    Uri.parse(albumsEndpoint),
  );
  print(response.body);

  var userId = 4;
  var showUserEndpoint = '$apiBaseUrl/users/$userId';
  response = await http.get(
    Uri.parse(showUserEndpoint),
  );
  print("User");
  print(response.body);

  // Fetch albums of a particular user
  var userAlbumsEndpoint = '$apiBaseUrl/users/$userId/albums';
  response = await http.get(Uri.parse(userAlbumsEndpoint));
  print('User $userId Albums: ${response.body}');

  // Fetch todos of a particular user
  var userTodosEndpoint = '$apiBaseUrl/users/$userId/todos';
  response = await http.get(Uri.parse(userTodosEndpoint));
  print('User $userId Todos: ${response.body}');

  // Fetch posts of a particular user
  var userPostsEndpoint = '$apiBaseUrl/users/$userId/posts';
  response = await http.get(Uri.parse(userPostsEndpoint));
  print('User $userId Posts: ${response.body}');

  // Fetch comments for post 1
  var postCommentsEndpoint = '$apiBaseUrl/posts/1/comments';
  response = await http.get(Uri.parse(postCommentsEndpoint));
  print('Post 1 Comments: ${response.body}');

  // Fetch photos for album 1
  var albumPhotosEndpoint = '$apiBaseUrl/albums/1/photos';
  response = await http.get(Uri.parse(albumPhotosEndpoint));
  print('Album 1 Photos: ${response.body}');
}
