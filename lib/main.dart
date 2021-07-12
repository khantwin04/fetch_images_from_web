import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getimages/bloc/search_images_cubit.dart';
import 'package:getimages/download.dart';
import 'package:getimages/home.dart';
import 'package:getimages/reader.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchImagesCubit>(
          create: (_) => SearchImagesCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: LandingPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Fetch_IMG',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text('Fetch Images from website'),
              Text('Forbidden Images can\'t be fetched'),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Search from Google'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home(),));
                  },
                ),
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Paste or Enter Url'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyHomePage(),));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  String url;

  MyHomePage({this.url = ''});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String url;
  List<dynamic> imgList = [];
  List<String> imgString = [];
  bool filter = false;
  String error;
  bool loading = false;
  bool showImg = false;

  void filterData(String tag, List<dynamic> imgList) {
    setState(() {
      showImg = true;
      imgString = [];
    });
    for (int i = 0; i < imgList.length; i++) {
      if (imgList[i].attributes[tag].toString().trimLeft() == 'null') {
        setState(() {
          imgString.add('Image Source Error');
        });
      } else {
        setState(() {
          imgString.add(imgList[i].attributes[tag].toString().trimLeft());
        });
      }
      print(imgList[i].attributes[tag].toString().trimLeft());
    }
  }

  @override
  void didChangeDependencies() {
    if (widget.url != '') {
      BlocProvider.of<SearchImagesCubit>(context).loadUrl(widget.url);
      setState(() {
        showImg = false;
        imgList = [];
        imgString = [];
        filter = false;
        loading = true;
        error = null;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Save Images',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: BlocConsumer<SearchImagesCubit, SearchImagesState>(
          listener: (context, state) {
            if (state is SearchImagesSuccess) {
              setState(() {
                imgList = state.result;
                loading = false;
              });
            } else if (state is SearchImagesFail) {
              setState(() {
                error = state.error;
                loading = false;
              });
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                TextFormField(
                  initialValue: widget.url,
                  decoration: InputDecoration(
                    hintText: 'Paste url or Enter url',
                  ),
                  textInputAction: TextInputAction.done,
                  onChanged: (data) {
                    setState(() {
                      url = data;
                    });
                  },
                  onFieldSubmitted: (data) {
                    BlocProvider.of<SearchImagesCubit>(context).loadUrl(data);
                    setState(() {
                      showImg = false;
                      imgList = [];
                      imgString = [];
                      filter = false;
                      loading = true;
                      error = null;
                    });
                  },
                ),
                loading ? LinearProgressIndicator() : Container(),
                error != null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          error,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(),
                imgList.length == 0
                    ? Container()
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                'Found ${imgList.length} results',
                                style: TextStyle(fontSize: 18),
                              ),
                              trailing: ElevatedButton(
                                child: Text('Filter With'),
                                onPressed: () {
                                  setState(() {
                                    filter = true;
                                  });
                                },
                              ),
                            ),
                          ),
                          filter
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                        child: ElevatedButton(
                                            onPressed: () {
                                              filterData('src', imgList);
                                            },
                                            child: Text('src'))),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        child: ElevatedButton(
                                            onPressed: () {
                                              filterData(
                                                  'data-lazy-src', imgList);
                                            },
                                            child: FittedBox(
                                                child: Text('data-lazy-src')))),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        child: ElevatedButton(
                                            onPressed: () {
                                              filterData('data-src', imgList);
                                            },
                                            child: Text('data-src'))),
                                  ],
                                )
                              : Container(),
                          filter
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    decoration:
                                        InputDecoration(hintText: 'Custom Tag'),
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (data) {
                                      filterData(data, imgList);
                                    },
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                imgList.length == 0
                    ? Container()
                    : showImg
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: imgString.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                imgString[index],
                                errorBuilder: (_, ___, ____) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Source Error'),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: imgList.length,
                            itemBuilder: (context, index) {
                              return Card(
                                  margin: EdgeInsets.all(10.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      imgList[index].outerHtml.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ));
                            },
                          ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: imgString.length == 0
          ? null
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Read in Viewer'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Reader(imgString),
                        ));
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Download'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Download(imgString),
                        ));
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
