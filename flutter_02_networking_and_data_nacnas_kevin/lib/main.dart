import 'package:http/http.dart' as http;

void main() async {
  var apiBaseUrl = 'https://jsonplaceholder.typicode.com/';

  var usersListEndpoint = '${apiBaseUrl}users';
  var responseUsers = await http.get(
    Uri.parse(usersListEndpoint),
  );
  print("List of Users");
  print(responseUsers.body);

  var userId = 1;
  var showUserEndpoint = '${apiBaseUrl}users/${userId}';
  var responseUser = await http.get(
    Uri.parse(showUserEndpoint),
  );
  print("User Details");
  print(responseUser.body);

  //fetch albums of a particular user
  var userComments = 'comments';
  var userId2 = 1;
  var showCommentEndpoint = '${apiBaseUrl}users/${userId2}/${userComments}';
  var commentUser = await http.get(
    Uri.parse(showCommentEndpoint),
  );
  print("Users Comments");
  print(commentUser.body);
  //fecth todos of a particular user
    var userTodos = 'todos';
  var userId3 = 1;
  var showTodosEndpoint = '${apiBaseUrl}users/${userId3}/${userTodos}';
  var todosUser = await http.get(
    Uri.parse(showTodosEndpoint),
  );
  print("Users Todos");
  print(todosUser.body);

  //fetch posts of a particular user
    var userPosts = 'posts';
  var userId4 = 1;
  var showPostsEndpoint = '${apiBaseUrl}users/${userId4}/${userPosts}';
  var postsUser = await http.get(
    Uri.parse(showPostsEndpoint),
  );
  print("Users Posts");
  print(postsUser.body);
}
