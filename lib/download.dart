import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

class Download extends StatefulWidget {
  List<String> result;

  Download(this.result);

  @override
  _DownloadState createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  bool createFolder = false;
  String folderName;
  bool exist = false;
  bool created = false;
  String savedPath;
  bool useDefault = false;
  String defaultPath = "storage/emulated/0/Download";
  bool downloading = false;
  bool downloadFinished = false;
  String error;
  bool chooseImage = false;
  List<String> _selectedItems = [];
  List<String> allImages = [];
  List<String> downloaded = [];

  void requestPermission() async {
    await Permission.storage.request();
  }

  Future<void> downloadChooseImg(List<String> imgs) async {
    setState(() {
      downloading = true;
    });
    if (useDefault) {
      for (int i = 0; i < imgs.length; i++) {
        try {
          await ImageDownloader.downloadImage(
            imgs[i].toString().trimLeft(),
            destination: AndroidDestinationType.directoryDownloads,
          );
          setState(() {
            downloaded.add(imgs[i].toString().trimLeft());
          });
        } catch (e) {
          setState(() {
            error = e.toString();
            downloadFinished = false;
            downloadFinished = false;
          });
        }
      }
    } else {
      for (int i = 0; i < imgs.length; i++) {
        try {
          await ImageDownloader.downloadImage(
            imgs[i].toString().trimLeft(),
            destination: AndroidDestinationType.directoryDownloads
              ..subDirectory(
                  "$folderName/${imgs[i].split('/').last.split('.').first}.png"),
          );
          setState(() {
            downloaded.add(imgs[i].toString().trimLeft());
          });
        } catch (e) {
          setState(() {
            error = e.toString();
            downloadFinished = false;
            downloadFinished = false;
          });
        }
      }
    }
    setState(() {
      downloading = false;
      downloadFinished = true;
      _selectedItems = [];
    });
  }

  _createFolder() async {
    setState(() {
      downloaded = [];
      chooseImage = false;
      _selectedItems = [];
    });
    final path = Directory("storage/emulated/0/Download/$folderName");
    if ((await path.exists())) {
      // TODO:
      setState(() {
        exist = true;
        savedPath = path.path;
      });
      print("exist");
    } else {
      // TODO:
      print("not exist");
      await path.create();
      setState(() {
        created = true;
        savedPath = path.path;
      });
    }
  }

  @override
  void initState() {
    allImages = widget.result;
    requestPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              '* If you found Source Error in image list,\nRecommend choose image to download.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
            Card(
              child: ListTile(
                contentPadding: EdgeInsets.all(10.0),
                title: Text('Choose Directory'),
                subtitle: Text('New or Download folder'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.create_new_folder,
                      ),
                      onPressed: () {
                        setState(() {
                          useDefault = false;
                          createFolder = true;
                          downloaded = [];
                          chooseImage = false;
                          _selectedItems = [];
                        });
                      },
                    ),
                    IconButton(
                        icon: Icon(Icons.folder_rounded),
                        onPressed: () {
                          setState(() {
                            useDefault = true;
                            createFolder = false;
                          });
                        }),
                  ],
                ),
              ),
            ),
            createFolder
                ? Card(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration:
                                  InputDecoration(hintText: 'Folder Name'),
                              onChanged: (data) {
                                setState(() {
                                  folderName = data;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                              icon: Icon(Icons.create_new_folder),
                              onPressed: () {
                                _createFolder();
                              }),
                        ],
                      ),
                    ),
                  )
                : Container(),
            exist
                ? Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10.0),
                      title: Text('$folderName already existed'),
                      subtitle: Text(
                          'Download images will be saved in this folder.\nPath : Internal Storage/Download/$folderName'),
                    ),
                  )
                : Container(),
            created
                ? Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10.0),
                      title: Text('$folderName folder created!'),
                      subtitle: Text(
                          'Download images will be saved in this folder.\nPath : Internal Storage/Download/$folderName'),
                    ),
                  )
                : Container(),
            useDefault
                ? Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10.0),
                      title: Text('Using default Download Folder!'),
                      subtitle: Text(
                          'Download images will be saved in this.\nPath : Internal Storage/Download'),
                    ),
                  )
                : Container(),
            exist || created || useDefault
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text('Choose Images'),
                        onPressed: downloading == false
                            ? () {
                                setState(() {
                                  chooseImage = true;
                                });
                              }
                            : null,
                      ),
                    ),
                  )
                : Container(),
            downloading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '....Downloading...',
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      ),
                    ),
                  )
                : downloadFinished
                    ? error == null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                  'Download Finished.\nCheck in File Manger'),
                            ),
                          )
                        : Center(
                            child: Text(error),
                          )
                    : Container(),
            chooseImage && downloading == false
                ? Card(
                    child: ListTile(
                      title: Text('Long Press to select'),
                      subtitle: Text('Tap to deselect'),
                      leading: Icon(Icons.list_alt),
                      trailing: IconButton(
                        icon: _selectedItems.length == allImages.length
                            ? Icon(Icons.check_box)
                            : Icon(Icons.check_box_outline_blank),
                        onPressed: () {
                          if (_selectedItems.length == allImages.length) {
                            setState(() {
                              _selectedItems.clear();
                            });
                          } else {
                            setState(() {
                              _selectedItems.clear();
                              _selectedItems.addAll(allImages);
                            });
                          }
                        },
                      ),
                    ),
                  )
                : Container(),
            chooseImage
                ? Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: allImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: (_selectedItems.contains(allImages[index]) && downloading == false)
                              ? Colors.blue.withOpacity(0.5)
                              : Colors.transparent,
                          child: ListTile(
                            onTap: downloading
                                ? null
                                : () {
                                    if (_selectedItems
                                        .contains(allImages[index])) {
                                      setState(() {
                                        _selectedItems.removeWhere(
                                            (val) => val == allImages[index]);
                                      });
                                    }
                                  },
                            onLongPress: downloading
                                ? null
                                : () {
                                    if (!_selectedItems
                                        .contains(allImages[index])) {
                                      setState(() {
                                        _selectedItems.add(allImages[index]);
                                      });
                                    }
                                  },
                            title: ListTile(
                                leading:
                                    widget.result[index] == "Image Source Error"
                                        ? Container(
                                            color: Colors.grey,
                                            width: 50,
                                          )
                                        : Image.network(
                                            allImages[index],
                                            width: 50,
                                          ),
                                title: Text(allImages[index]),
                                subtitle: downloading
                                    ? downloaded.contains(allImages[index])
                                        ? Text('Downloaded')
                                        : _selectedItems
                                                .contains(allImages[index])
                                            ? LinearProgressIndicator()
                                            : Container()
                                    : Container()),
                          ),
                        );
                      },
                    ),
                  )
                : Container(),
          ],
        ),
      ),
      bottomNavigationBar:
          chooseImage && _selectedItems.length != 0 && downloading == false
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                      onPressed: () {
                        downloadChooseImg(_selectedItems);
                      },
                      child: Text('Download')),
                )
              : null,
    );
  }
}
