import 'package:http/http.dart' as http;

void main() async {
  var apiBaseUrl = 'https://jsonplaceholder.typicode.com/';

  var usersListEndpoint = '${apiBaseUrl}users';
  var response = await http.get(
    Uri.parse(usersListEndpoint),
  );
  print(response.body);

  var userId = 4;
  var showUserEndpoint = '${apiBaseUrl}users/${userId}';
  var responseUser = await http.get(
    Uri.parse(showUserEndpoint),
  );
  print(responseUser.body);

  var showAlbumEndpoint = '${apiBaseUrl}users/${userId}/albums';
  response = await http.get(
    Uri.parse(showAlbumEndpoint),
  );
  print(response.body);

  var showTodosEndpoint = '${apiBaseUrl}users/${userId}/todos';
  response = await http.get(
    Uri.parse(showTodosEndpoint),
  );
  print(response.body);

  var showPostsEndpoint = '${apiBaseUrl}users/${userId}/posts';
  response = await http.get(
    Uri.parse(showPostsEndpoint),
  );
  print(response.body);
}
