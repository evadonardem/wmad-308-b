import 'package:http/http.dart' as http;

void main() async {
  var apiBaseUrl = 'https://jsonplaceholder.typicode.com/';

  try {
    var userListEndpoint = '${apiBaseUrl}users';
    var response = await http.get(Uri.parse(userListEndpoint));
    print('Users: ${response.body}');

    var userId = 1;
    var showUserEndpoint = '${apiBaseUrl}users/$userId';
    var responseUser = await http.get(Uri.parse(showUserEndpoint));
    print('User Details: ${responseUser.body}');

    var userAlbumsEndpoint = '${apiBaseUrl}users/$userId/albums';
    var responseAlbums = await http.get(Uri.parse(userAlbumsEndpoint));
    print('Albums of User $userId: ${responseAlbums.body}');

    var userTodosEndpoint = '${apiBaseUrl}users/$userId/todos';
    var responseTodos = await http.get(Uri.parse(userTodosEndpoint));
    print('Todos of User $userId: ${responseTodos.body}');

    var userPostsEndpoint = '${apiBaseUrl}users/$userId/posts';
    var responsePosts = await http.get(Uri.parse(userPostsEndpoint));
    print('Posts of User $userId: ${responsePosts.body}');
  } catch (e) {
    print('An error occurred: $e');
  }
}