import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Reader extends StatefulWidget {
  List<String> resultList;
  Reader(this.resultList);
  @override
  _ReaderState createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  bool hide = false;

  ScrollController controller;

  int page = -1;

  bool scrollLoading = false;

  bool isLoading = false;

  bool noChapter = false;

  PageController _controller = PageController(
    viewportFraction: 1,
    keepPage: false,
  );

  int chapterId;

  String chapterName;

  String viewer = 'manga';

  String res = 'FilterQuality.low';

  String direction = 'Axis.vertical';

  bool fav = false;

  Future<void> getViewerSetting() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    print(pref.getString('viewer'));
    if (pref.getString('viewer') != null) {
      setState(() {
        viewer = pref.getString('viewer');
      });
    }
    if (pref.getString('res') != null) {
      setState(() {
        res = pref.getString('res');
      });
    }
    if (pref.getString('direction') != null) {
      setState(() {
        direction = pref.getString('direction');
      });
    }
  }

  void changeSetting() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:(context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black54,
              title: Text(
                'Setting',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RaisedButton(
                          color:
                          viewer == 'manga' ? Colors.white70 : Colors.black54,
                          child: Text(
                            'Manga',
                            style: TextStyle(color: viewer == 'manga' ? Colors.black : Colors.white,),
                          ),
                          onPressed: () {
                            changeViewer('manga');
                            setState((){});
                          },
                        ),
                      ),
                      Expanded(
                        child: RaisedButton(
                          color:
                          viewer == 'webtoon' ? Colors.white70 : Colors.black54,
                          child: Text(
                            'Webtoon',
                            style: TextStyle(color: viewer == 'webtoon' ? Colors.black : Colors.white,),
                          ),
                          onPressed: () {
                            changeViewer('webtoon');
                            setState((){});
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    child: Text('Scroll Direction', style: TextStyle(color: Colors.white),),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RaisedButton(
                          color:
                          direction == 'Axis.vertical' ? Colors.white70 : Colors.black54,
                          child: Icon(Icons.swap_vertical_circle_outlined, color: direction == 'Axis.vertical' ? Colors.black : Colors.white,),
                          onPressed: () {
                            changeDir('Axis.vertical');
                            setState((){});
                          },
                        ),
                      ),
                      viewer=='webtoon'?Container():Expanded(
                        child: RaisedButton(
                          color:
                          direction == 'Axis.horizontal' ? Colors.white70 : Colors.black54,
                          child: Icon(Icons.swap_horizontal_circle_outlined, color: direction == 'Axis.horizontal' ? Colors.black : Colors.white,),
                          onPressed: () {
                            changeDir('Axis.horizontal');
                            setState((){});
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void changeViewer(String change) {
    setState(() {
      viewer = change;
    });
    saveReaderSetting();
  }

  void changeRes(String change) {
    setState(() {
      res = change;
    });
    saveReaderSetting();
  }

  void changeDir(String change) {
    setState(() {
      direction = change;
    });
    saveReaderSetting();
  }

  FilterQuality getRes(){
    if(res == 'FilterQuality.high'){
      print('high');
      return FilterQuality.high;
    }else if(res == 'FilterQuality.medium'){
      print('medium');
      return FilterQuality.medium;
    }else{
      print('low');
      return FilterQuality.low;
    }
  }

  Axis getDir(){
    if(direction == 'Axis.vertical'){
      return Axis.vertical;
    }else{
      return Axis.horizontal;
    }
  }

  Future<void> saveReaderSetting() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("viewer", viewer);
    pref.setString("res", res);
    pref.setString("direction", direction);
  }

  @override
  void initState() {
    getViewerSetting();
    scaleStateController = PhotoViewScaleStateController();
    super.initState();
  }

  @override
  void dispose() {
    scaleStateController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget appBar() {
    return AppBar(
      actions: [
        IconButton(icon: Icon(Icons.settings, color: Colors.white,), onPressed: (){
          changeSetting();
        },)
      ],
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.black87,
      title: Text(
        'Reader',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  PhotoViewScaleStateController scaleStateController;

  ScrollPhysics scrollPhy = BouncingScrollPhysics();

  bool init = true;

  String cover;

  int pageNo = 0;

  String pageContentImg;

  Future<bool> pop() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: pop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            widget.resultList.length == 0
                ? Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(child: CircularProgressIndicator()),
            )
                : viewer == 'manga'
                ? GestureDetector(
              onTap: () {
                setState(() {
                  hide = !hide;
                });
              },
              child: PageView.builder(
                reverse: direction == "Axis.horizontal"?true:false,
                controller: _controller,
                physics: scrollPhy,
                pageSnapping: true,
                clipBehavior: Clip.hardEdge,
                scrollDirection: getDir(),
                itemCount: widget.resultList.length,
                itemBuilder: (context, page) {
                  return PhotoView(
                    scaleStateController: scaleStateController,
                    loadingBuilder: (_, img) => img == null
                        ? Center(child: CircularProgressIndicator())
                        : Center(
                      child: CircularProgressIndicator(
                        value: img.expectedTotalBytes != null
                            ? img.cumulativeBytesLoaded /
                            img.expectedTotalBytes
                            : null,
                      ),
                    ),
                    scaleStateChangedCallback: (v) {
                      if (scaleStateController.scaleState ==
                          PhotoViewScaleState.initial) {
                        setState(() {
                          scrollPhy = BouncingScrollPhysics();
                        });
                      } else {
                        setState(() {
                          scrollPhy = NeverScrollableScrollPhysics();
                        });
                      }
                    },
                    errorBuilder: (_, ___, ____){return Center(child: Text('Image Src Error', style: TextStyle(color: Colors.white),),);},
                    tightMode: false,
                    filterQuality: getRes(),
                    imageProvider: NetworkImage(widget.resultList[page].toString().trimLeft()),
                    gaplessPlayback: true,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    initialScale: PhotoViewComputedScale.contained,
                  );
                },
              ),
            )
                : GestureDetector(
              onTap: () {
                setState(() {
                  hide = !hide;
                });
              },
              child: Column(
                  children: [
                Expanded(
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 5.0,
                    child: ListView.builder(
                      cacheExtent: 1000,
                      scrollDirection: Axis.vertical,
                      itemCount: widget.resultList.length,
                      itemBuilder: (context, page) {
                        return Image(
                          errorBuilder: (_, ___, ____){return Center(child: Text('Image Src Error', style: TextStyle(color: Colors.white),),);},
                          filterQuality: getRes(),
                          image: NetworkImage(widget.resultList[page].toString().trimLeft()),
                          gaplessPlayback: true,
                          loadingBuilder: (BuildContext context,
                              Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null)
                              return child;
                            return Container(
                              height: MediaQuery.of(context)
                                  .size
                                  .height *
                                  0.5,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress
                                      .expectedTotalBytes !=
                                      null
                                      ? loadingProgress
                                      .cumulativeBytesLoaded /
                                      loadingProgress
                                          .expectedTotalBytes
                                      : null,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  height: scrollLoading ? 50.0 : 0,
                  color: Colors.transparent,
                  child: Center(
                    child: new CircularProgressIndicator(),
                  ),
                ),
              ]),
            ),
            hide
                ? Container()
                : Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: appBar(),
            ),
          ],
        ),
      ),
    );
  }
}
