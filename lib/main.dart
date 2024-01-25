// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MainApp());
// }

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Text('Hello World!'),
//         ),
//       ),
//     );
//   }
// }



import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> repositories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('https://api.github.com/users/freeCodeCamp/repos'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        for (var repo in data) {
          final commitResponse = await http.get(Uri.parse('https://api.github.com/repos/freeCodeCamp/${repo['name']}/commits'));

          if (commitResponse.statusCode == 200) {
            final List<dynamic> commits = json.decode(commitResponse.body);

            repositories.add({
              'name': repo['name'],
              'description': repo['description'] ?? 'No description available',
              'lastCommit': commits.isNotEmpty ? commits[0]['commit']['message'] : 'No commits',
            });
          } else {
            // Handle commit API error
            repositories.add({
              'name': repo['name'],
              'description': repo['description'] ?? 'No description available',
              'lastCommit': 'Failed to fetch commits',
            });
          }
        }

        setState(() {});
      } else {
        // Handle repositories API error
        throw Exception('Failed to load repositories. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle generic error
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    repositories.clear();
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Repositories'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : repositories.isEmpty
                ? Center(child: Text('No data available'))
                : ListView.builder(
                    itemCount: repositories.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(repositories[index]['name']),
                        subtitle: Text(repositories[index]['description']),
                        trailing: Text(repositories[index]['lastCommit']),
                      );
                    },
                  ),
      ),
    );
  }
}
