import 'package:http/http.dart' as http;

void main() async {
  var apiBaseURL= 'https://jsonplaceholder.typicode.com/albums/1';
  
  var usersListEndpoint ='${apiBaseURL}users';
  var response = await http.get(
    Uri.parse(usersListEndpoint),
  );
  print ("List of Users:");
  print(response.body);

  var userId = 4;
  var showUserEndpoint = '${apiBaseURL}users/${userId}';
  var responseUser = await http.get(
    Uri.parse(showUserEndpoint),
    );
    print ("User Details:");
    print(response.body);

  var showAlbumsEndpoint = '${apiBaseURL}users/${userId}/albums';
  response = await http.get(
    Uri.parse(showAlbumsEndpoint),
    );
    print ("User Albums:");
    print(response.body);

  var showToDosEndpoint = '${apiBaseURL}users/${userId}/todos';
  response = await http.get(
    Uri.parse(showToDosEndpoint),
    );
    print ("User To Do's:");
    print(response.body);

  var showPostsEndpoint = '${apiBaseURL}users/${userId}/posts';
  response = await http.get(
    Uri.parse(showPostsEndpoint),
    );
    print ("User Details:");
    print(response.body);
}