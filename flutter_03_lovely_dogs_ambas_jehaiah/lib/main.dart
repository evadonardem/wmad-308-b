import 'package:http/http.dart' as http;

void main() async {
  var apiBaseUrl = 'https://jsonplaceholder.typicode.com/';

  var usersListEndpoint = '${apiBaseUrl}users';

  var responseUsers = await http.get(Uri.parse(usersListEndpoint));
  print(responseUsers.body);

  var userId = 4;
  var showUserEndpoint = '${apiBaseUrl}users/$userId';
  var responseUser = await http.get(Uri.parse(showUserEndpoint));

  print(responseUser.body);

  //albums
  print('User $userId Albums');
  var showUserAlbum = '${apiBaseUrl}users/$userId/albums';
  var responseUserAlbum = await http.get(Uri.parse(showUserAlbum));

  print(responseUserAlbum.body);

  //todos
  print('User $userId Todos');
  var showUserTodos = '${apiBaseUrl}users/$userId/todos';
  var responseUserTodos = await http.get(Uri.parse(showUserTodos));

  print(responseUserTodos.body);

  //posts
  print('User $userId Posts');
  var showUserPosts = '${apiBaseUrl}users/$userId/posts';
  var responseUserPosts = await http.get(Uri.parse(showUserPosts));

  print(responseUserPosts.body);
}
