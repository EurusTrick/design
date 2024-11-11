//import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

import 'package:namer_app/logs_page.dart'; 
import 'package:namer_app/login_page.dart'; 
import 'package:namer_app/seguimiento_page.dart';

import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'blog_row.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:rflutter_alert/rflutter_alert.dart';

final HttpLink httpLink = HttpLink(
  "https://hackernews-402-2024-c0sm.onrender.com/graphql/");

final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
  GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  ),
);    


const String query = """
query   Links {
  links{
    url
    description    
  }
}
""";

const String loginPostMutation = """
mutation{
  tokenAuth(username:"miguelon",password:"1234"){
    token
  }
}
""";

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 34, 240, 255)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}




class ModelPage extends StatefulWidget {
  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  final opneVariable = TextEditingController();
  final highVarible = TextEditingController();
  final lowVarible = TextEditingController();
  final volumeVariable = TextEditingController();
  
  String? modelResponse;

  @override
  void dispose() {
    opneVariable.dispose();
    highVarible.dispose();
    lowVarible.dispose();
    volumeVariable.dispose();
    //gyroscopeYController.dispose();
    //gyroscopeZController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(10.0),
              child: Text(
                'MODEL',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 41, 161, 135),
                ),
              ),
            ),
            
            
            
            SizedBox(height: 20),
            Container(
              width: 300,
              child: TextField(
                controller: opneVariable,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  fillColor: Color.fromARGB(255, 127, 226, 88),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  hintText: 'Open',
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            
            
            
            SizedBox(height: 10),
            Container(
              width: 300,
              child: TextField(
                controller: highVarible,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  fillColor: Color.fromARGB(255, 127, 226, 88),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  hintText: 'high',
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            
            
            
            SizedBox(height: 10),
            Container(
              width: 300,
              child: TextField(
                controller: lowVarible,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  fillColor: Color.fromARGB(255, 127, 226, 88),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  hintText: 'Low',
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            
            
            
            SizedBox(height: 10),
            Container(
              width: 300,
              child: TextField(
                controller: volumeVariable,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  fillColor: Color.fromARGB(255, 127, 226, 88),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  hintText: 'Volume',
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          
            
            SizedBox(height: 20),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    appState
                        .callModel(
                            double.parse(opneVariable.text),
                            double.parse(highVarible.text),
                            double.parse(lowVarible.text),
                            double.parse(volumeVariable.text))
                        .then((value) {
                      setState(() {
                        modelResponse = value;
                      });
                    });
                  },
                  child: Text('PREDICT'),
                ),
                if (modelResponse != null) ...[
                  SizedBox(height: 20),
                  Text('Response: ${modelResponse}'),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class MyAppState extends ChangeNotifier {
  var username = "";
  var token = "";
  var error = "";

  GlobalKey? historyListKey;

  Future<String> callModel(
    double open,
    double high,
    double low,
    double volume,
    //double Gyroscope_y,
    //double Gyroscope_z,
  ) async {
    final url =
        Uri.parse("https://fastapiml3-latest.onrender.com/predict");
    final headers = {"Content-Type": "application/json;charset=UTF-8"};
    try {
      final prediction_instance = {
        "open": open,
        "high": high,
        "low": low,
        "volume": volume,
        //"Gyroscope_y": Gyroscope_y,
        //"Gyroscope_z": Gyroscope_z
      };
      final res = await http.post(url,
          headers: headers, body: jsonEncode(prediction_instance));
      if (res.statusCode == 200) {
        final json_prediction = res.body;
        return json_prediction;
      } else {
        return 'Error: Status ${res.statusCode}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}

class Retrain extends StatefulWidget {
  @override
  _RetrainState createState() => _RetrainState();
}

class _RetrainState extends State<Retrain> {
  final shaController = TextEditingController();
  final urlController = TextEditingController();

  @override
  void dispose() {
    shaController.dispose();
    urlController.dispose();
    super.dispose();
  }

  Future<void> sendPostRequest(String sha, String datasetUrl) async {
    final String url =
        'https://api.github.com/repos/EurusTrick/tecnologias3/dispatches';
    final String token = ''; //here should be the access token 

    final Map<String, dynamic> body = {
      "event_type": "ml_ci_cd",
      "client_payload": {
        "dataseturl": datasetUrl,
        "sha": sha,
      },
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('Request successful: ${response.body}');
    } else {
      print(
          'Request failed with status: ${response.statusCode}, ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(10.0),
              child: Text(
                'RETRAIN',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 41, 161, 135),
                ),
              ),
            ),
            
            
            SizedBox(height: 20),
            Container(
              width: 300,
              child: TextField(
                controller: shaController,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  fillColor: Color.fromARGB(255, 127, 226, 88),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  hintText: 'SHA',
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              child: TextField(
                controller: urlController,
                keyboardType: TextInputType.url,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  fillColor: Color.fromARGB(255, 127, 226, 88),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  hintText: 'Dataset URL',
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendPostRequest(shaController.text, urlController.text);
              },
              child: Text('SEND REQUEST'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final AuthLink authLink = AuthLink(
      getToken: () async{
        print('token ${appState.token}');
        return 'JWT ${appState.token}';
      },
    );

    final Link httpLink = authLink.concat(HttpLink("https://mysite-df52.onrender.com/graphql/"));
    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(),
      ),
    );
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = ModelPage();
        break;
      case 1:
        page = Retrain();
        break;
      case 2:
        page = LogsPage();
        break;
      case 3:
        page = LoginPage ();
        break;
      case 4:
        page = SeguimientoPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

     return GraphQLProvider (
      client: client, 
      child : Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            // Use a more mobile-friendly layout with BottomNavigationBar
            // on narrow screens.
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surface, // Asegura el color de fondo
                    type: BottomNavigationBarType.fixed,
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.rocket),
                        label: 'Model',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.rocket_launch),
                        label: 'Retrain',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Logs',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_box),
                        label: 'SeguimientoPage',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.login_sharp),
                        label: 'Login',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    }, 
                  ), 
                ) 
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.rocket),
                        label: Text('Model'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.rocket_launch),
                        label: Text('Retrain'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Logs'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.add_box),
                        label: Text('SeguimientoPage'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.add_box),
                        label: Text('Login'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    ));
  }
}

