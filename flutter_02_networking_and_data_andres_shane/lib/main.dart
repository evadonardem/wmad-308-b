import 'package:http/http.dart' as http;

void main() async {
  var apiBaseUrl = 'https://jsonplaceholder.typicode.com/';

  var usersListEndpoint = '${apiBaseUrl}users';
  var responseUsers = await http.get(
    Uri.parse(usersListEndpoint),
  );
  print("List of user:");
  print(responseUsers.body);

  var userId = 4;
  var showUserEndpoint = '${apiBaseUrl}users/${userId}';
  var responseUser = await http.get(
    Uri.parse(showUserEndpoint),
  );
  print("User details:");
  print(responseUser.body);

//albums

  var userId = 4;
  var showUserEndpoint = '${apiBaseUrl}users/4/albums${userId}';
  var responseUser = await http.get(
    Uri.parse(showUserEndpoint),
  );
  print("User details:");
  print(responseUser.body);
}

//todos
//posts