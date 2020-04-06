import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:spacex_app/Constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String url = "https://api.spacexdata.com/v3/launches/upcoming";

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'SpaceX',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Launches'),
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: choiceAction,
                itemBuilder: (BuildContext context){
                  return Constants.choices.map((String choice){
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              )
            ]

        ),
        body: new Container(
          child: new FutureBuilder<List<Launch>>(
            future: fetchLaunchs(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return new ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return new ListTile(title: Text(snapshot.data[index]
                          .name),
                          subtitle: Text(snapshot.data[index].launchDate),
                          onTap: () => onTap(snapshot.data[index], context));
                    }
                );
              } else if (snapshot.hasError) {
                return new Text("${snapshot.error}");
              }
              return new CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  void onTap(Launch launchh, BuildContext b) async
  {
    var url = launchh.url;
    if (url != null) {
      await launch(url);
    } else {
      Scaffold.of(b).showSnackBar(SnackBar(
        content: Text("Reddit campaign unavailable"),
      ));
    }
  }

  Future<List<Launch>> fetchLaunchs() async {
    final response = await http.get(url);
    //print(response.body);
    List responseJson = json.decode(response.body.toString());
    List<Launch> launchList = createUserList(responseJson);
    return launchList;
  }

  List<Launch> createUserList(List data) {
    List<Launch> list = new List();
    for (int i = 0; i < data.length; i++) {
      String name = data[i]["mission_name"];
      String launchDate = data[i]["launch_date_utc"];
      String url = data[i]["links"]["reddit_campaign"];
      print(url);
      Launch launch = new Launch(name: name, launchDate: launchDate, url: url);
      list.add(launch);
    }
    return list;
  }

  void choiceAction(String choice) {
    if (choice == Constants.upcoming) {
      setState(() {
        url="https://api.spacexdata.com/v3/launches/upcoming";
      });
    } else if (choice == Constants.past) {
      setState(() {
        url="https://api.spacexdata.com/v3/launches/past";
      });
    }
  }
}
class Launch
{
  String name;
  String launchDate;
  String url;
  Launch({this.name,this.launchDate,this.url});
}
