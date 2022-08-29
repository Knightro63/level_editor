import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/styles/lsi_functions.dart';
import 'package:spark/spark.dart';

import 'ui/tileset.dart';
import 'ui/levelModifers.dart';

import 'src/navigation/navigation.dart';
import 'src/database/filePicker.dart';
import 'src/styles/globals.dart';

class UIScreen extends StatefulWidget {
  const UIScreen({Key? key}):super(key: key);
  @override
  _UIPageState createState() => _UIPageState();
}

class _UIPageState extends State<UIScreen> {
  double deviceWidth = 0;
  double deviceHeight = 0;
  bool resetNav = false;
  bool updateTileScene = false;
  late LevelScene levelScene;
  String info = '';
  Timer? infoTimer;
  int? selectedAnimation;

  String? openSelFilePath;
  String? openJleFilePath;

  LevelEditorCallbacks? prevLevelCall;

  late Grid grid;
  Grid getGrid(){
    Grid _grid = Grid();
    setState(() {
      _grid = levelScene.levelInfo[levelScene.selectedLevel].grid;
    });
    return _grid;
  }

  @override
  void initState(){
    grid = Grid();
    levelScene = LevelScene(
      onStartUp: () => setState(() {
        _onLevelSceneCreated();
      })
    );
    super.initState();
  }
  @override
  void dispose(){
    infoTimer?.cancel();
    super.dispose();
  }
  static Future<void>? _writeToFile(String path, {String? spark, Uint8List? image}){
    final file = File(path);
    if(spark != null){
      return file.writeAsString(spark);
    }
    else if(image != null){
      return file.writeAsBytes(image);
    }
  }
  void setInfo(String newInfo){
    setState(() {
      info = newInfo;
    });
    infoTimer = Timer(const Duration(seconds: 3), (){
      setState(() {
        info = '';
      });
      infoTimer?.cancel();
    });
  }

  void setGrid(dynamic data, String call){
    if(data == null){
      callBacks(call: LSICallbacks.UpdatedNav);
      setState(() {});
    }
    else{
      switch (call) {
        case 'color':
          levelScene.levelInfo[levelScene.selectedLevel].grid.color = data;
          break;
        case 'X':
          levelScene.levelInfo[levelScene.selectedLevel].grid.width = data;
          break;
        case 'Y':
          levelScene.levelInfo[levelScene.selectedLevel].grid.height = data;
          break;
        case 'width':
          levelScene.levelInfo[levelScene.selectedLevel].grid.boxSize = Size(data*1.0,levelScene.levelInfo[levelScene.selectedLevel].grid.boxSize.height);
          break;
        case 'height':
          levelScene.levelInfo[levelScene.selectedLevel].grid.boxSize = Size(levelScene.levelInfo[levelScene.selectedLevel].grid.boxSize.width,data*1.0);
          break;
        case 'stroke':
          levelScene.levelInfo[levelScene.selectedLevel].grid.lineWidth = data;
          break;
        default:
      }
    }
    levelScene.update();
  }
  void jleCallback({required LevelEditorCallbacks call, Offset? details}){
    if(prevLevelCall == call && call != LevelEditorCallbacks.onTap) return;
    prevLevelCall = call;
    switch (call) {
      case LevelEditorCallbacks.onTap:
        setState(() {
          resetNav = true;
        });
        break;
      case LevelEditorCallbacks.newObject:
        openJleFilePath = null;
        levelScene.clear();
        break;
      case LevelEditorCallbacks.open:
        GetFilePicker.pickFiles(['jle','spark']).then((value)async{
          if(value != null){
            setState(() {
              setInfo('Opening File!');
              for(int i = 0; i < value.files.length;i++){
                if(!kIsWeb){
                  openJleFilePath = value.files[0].path;
                  JLELoader.load(value.files[0].path!,levelScene);
                }
                else{
                  JLELoader.load(utf8.decode(value.files[i].bytes!),levelScene);
                }
              }
            });
          }
        }); 
        levelScene.clear();
        break;
      case LevelEditorCallbacks.save:
        setState(() {
          setInfo('Saving File!');
          if(openJleFilePath != null){
            LevelExporter.export(levelScene).then((value){
              _writeToFile(
                openJleFilePath!,
                spark: value
              );
            });
          }
          else if(openJleFilePath == null){
            GetFilePicker.saveFile('untilted', 'spark').then((path){
              LevelExporter.export(levelScene).then((value){
                _writeToFile(
                  path!,
                  spark: value
                );
              });
              setState(() {
                openJleFilePath = path;
              });
            }).catchError((e){
              setInfo('Error Saving!');
            });
          }
        });

        break;
      case LevelEditorCallbacks.removeObject:
        setState(() {

        });
        break;
      default:
    }
  }
  void callBacks({required LSICallbacks call}){
    switch (call) {
      case LSICallbacks.UpdatedNav:
        setState(() {
          resetNav = !resetNav;
        });
        break;
      case LSICallbacks.Clear:
        setState(() {
          resetNav = !resetNav;
          levelScene.clear();
        });
        break;
      case LSICallbacks.UpdateLevel:
        setState(() {
          updateTileScene = !updateTileScene;
          levelScene.update();
        });
        break;
      default:
    }
  }
  void _onLevelSceneCreated(){
    WidgetsBinding.instance.addPostFrameCallback((_) { 
      if(!levelScene.loaded){
        levelScene.camera.position.x = -7.5;
        levelScene.camera.position.y = 4.5;
        levelScene.rayCasting = true;
        levelScene.camera.cameraControls = CameraControls(
          panX: true,
          panY: true,
          zoom: true
        );
        levelScene.loaded = true;
        levelScene.update();
        setState(() {});
      }
    });
  }
  Widget levelSheetEditor(){
    return Stack(
      children:[
        Align(
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            height: deviceHeight-30,
            width: deviceWidth-240,
            child: LevelEditor(
              scene: levelScene,
              interactive: true,
              callback: jleCallback,
            )
          )
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: 
          SizedBox(
            height: 25,
            width: deviceWidth-240,
            child: Text(info)
          )
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
          height: deviceHeight-32,
          width: 240,
          margin: const EdgeInsets.only(top: 5),
          padding: const EdgeInsets.fromLTRB(5,0,5,5),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            boxShadow: [BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 5,
              offset: const Offset(2,2),
            ),]
          ),
          child: ListView(
            children: [
              Tileset(
                scene: levelScene,
                width: 240,
                height: deviceHeight/2.75,
                update: updateTileScene,
                callback: callBacks,
              )
            ],
          )
        )
      ),
      Container(
        height: 30,
        width: deviceWidth,
        padding: const EdgeInsets.fromLTRB(5,0,5,0),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          //borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: [BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            offset: const Offset(2,2),
          ),]
        ),
        child: LevelModifers(
          scene: levelScene,
          //height: 30,
          width: deviceWidth,
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    double safePadding = MediaQuery.of(context).padding.top;
    deviceHeight = MediaQuery.of(context).size.height-safePadding-25;

    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(deviceWidth,50), 
          child:Navigation(
            height: 25,
            callback: callBacks,
            reset: resetNav,
            navData: [
                NavItems(
                  name: 'File',
                  subItems:[ 
                    NavItems(
                      name: 'New',
                      icon: Icons.new_label_outlined,
                      function: (data){
                        openJleFilePath = null;
                        openSelFilePath = null;
                        callBacks(call: LSICallbacks.Clear);
                      }
                    ),
                    NavItems(
                      name: 'Open',
                      icon: Icons.folder_open,
                      function: (data){
                        setState(() {
                          setInfo('Opening File!');
                          callBacks(call: LSICallbacks.Clear);
                          GetFilePicker.pickFiles(['spark','jle']).then((value)async{
                            if(value != null){
                              for(int i = 0; i < value.files.length;i++){
                                JLELoader.load(value.files[0].path!, levelScene).then((load){
                                  openJleFilePath = value.files[0].path;
                                  updateTileScene = true;
                                  levelScene.update();
                                });
                              }
                            }
                          });
                        });
                      }
                    ),
                    NavItems(
                      name: 'Save',
                      icon: Icons.save,
                      function: (data){
                        callBacks(call: LSICallbacks.UpdatedNav);
                        if(openJleFilePath != null){
                          setState(() {
                            setInfo('Saving File!');
                            LevelExporter.export(levelScene).then((value){
                              _writeToFile(
                                openJleFilePath!,
                                spark: value
                              );
                            });
                          });
                        }
                      }
                    ),
                    NavItems(
                      name: 'Save As',
                      icon: Icons.save_outlined,
                      function: (data){
                        setState(() {
                          setInfo('Saving File As!');
                          callBacks(call: LSICallbacks.UpdatedNav);
                          if(levelScene.levelInfo[levelScene.selectedLevel].hasImageData && !kIsWeb){
                            GetFilePicker.saveFile('untilted', 'jle').then((path){
                              LevelExporter.export(levelScene).then((value){
                                _writeToFile(
                                  path!,
                                  spark: value
                                );
                              });
                              setState(() {
                                openJleFilePath = path;
                              });
                            });
                          }
                          else if(kIsWeb){
                            LevelExporter.export(levelScene).then((value){
                              _writeToFile(
                                'Temp.jle',
                                spark: value
                              );
                            });
                          }
                        });
                      }
                    ),
                    NavItems(
                      name: 'Import',
                      icon: Icons.file_download_outlined,
                      subItems: [
                        NavItems(
                          name: 'object',
                          icon: Icons.image,
                          function: (data){
                            callBacks(call: LSICallbacks.UpdatedNav);
                            setState(() {
                              setInfo('Importing Object!');
                            });
                            GetFilePicker.pickFiles(['jpg','jpeg','png']).then((value)async{
                              if(value != null){
                                for(int i = 0; i < value.files.length;i++){
                                  if(!kIsWeb){
                                    levelScene.loadObject(value.files[0].path!,LoadedType.single).then((value){
                                      updateTileScene = true;
                                      levelScene.update();
                                      setState(() {});
                                    });
                                  }
                                  else{
                                    levelScene.loadObject(utf8.decode(value.files[i].bytes!),LoadedType.single).then((value){
                                      updateTileScene = true;
                                      levelScene.update();
                                      setState(() {});
                                    });
                                  }
                                }
                              }
                            });
                          },
                        ),
                        NavItems(
                          name: 'object sheet',
                          icon: Icons.image,
                          show: true,
                          function: (data){
                            callBacks(call: LSICallbacks.UpdatedNav);
                            setState(() {
                              setInfo('Importing Object Sheet!');
                            });
                            GetFilePicker.pickFiles(['jpg','jpeg','png']).then((value)async{
                              if(value != null){
                                for(int i = 0; i < value.files.length;i++){
                                  if(!kIsWeb){
                                    levelScene.loadObject(value.files[0].path!,LoadedType.sheet).then((value){
                                      updateTileScene = true;
                                      levelScene.update();
                                      setState(() {});
                                    });
                                  }
                                  else{
                                    levelScene.loadObject(utf8.decode(value.files[i].bytes!),LoadedType.sheet).then((value){
                                      updateTileScene = true;
                                      levelScene.update();
                                      setState(() {});
                                    });
                                  }
                                }
                              }
                            });
                          },
                        ),
                        NavItems(
                          name: 'tileset',
                          icon: Icons.image,
                          show: true,
                          function: (data){
                            callBacks(call: LSICallbacks.UpdatedNav);
                            setState(() {
                              setInfo('Importing Tile Set!');
                            });
                            GetFilePicker.pickFiles(['jpg','jpeg','png']).then((value)async{
                              if(value != null){
                                for(int i = 0; i < value.files.length;i++){
                                  if(!kIsWeb){
                                    levelScene.updateTileset(
                                      path: value.files[0].path!,
                                      name: value.files[0].name
                                    ).then((value){
                                      levelScene.update();
                                      updateTileScene = true;
                                      setState(() {});
                                    });
                                  }
                                  else{
                                    levelScene.updateTileset(
                                      path: utf8.decode(value.files[i].bytes!),
                                      name: value.files[0].name
                                    );
                                  }
                                }
                              }
                            });
                          },
                        ),
                      ]
                    ),
                    NavItems(
                      name: 'Export',
                      icon: Icons.file_upload_outlined,
                      subItems: [
                        NavItems(
                          name: 'json',
                          icon: Icons.file_copy_outlined,
                          function: (data){
                            callBacks(call: LSICallbacks.UpdatedNav);
                            GetFilePicker.saveFile('untilted', 'json').then((path){
                              LevelExporter.export(levelScene,ExportType.json).then((value){
                                _writeToFile(
                                  path!,
                                  spark: value
                                );
                              });
                            });
                          }
                        ),
                        NavItems(
                          name: 'level image',
                          icon: Icons.image,
                          function: (data){
                            setState(() {
                              setInfo('Exporing Image!');
                              callBacks(call: LSICallbacks.UpdatedNav);
                              if(levelScene.levelInfo[levelScene.selectedLevel].hasImageData){
                                GetFilePicker.saveFile('untilted', 'png').then((path){
                                  LevelExporter.exportPNG('',levelScene).then((value){
                                    _writeToFile(
                                      path!,
                                      image: value
                                    );
                                  });
                                });
                              }
                            });
                          }
                        )
                      ]
                    ),
                    NavItems(
                      name: 'Quit',
                      icon: Icons.exit_to_app,
                      function: (data){
                        callBacks(call: LSICallbacks.UpdatedNav);
                        SystemNavigator.pop();
                      }
                    ),
                  ]
                ),
                NavItems(
                  name: 'View',
                  subItems:[
                    NavItems(
                      name: 'Grid',
                      icon: Icons.grid_on_outlined,
                      subItems: [
                        NavItems(
                          name: 'color',
                          icon: Icons.color_lens_outlined,
                          function: (data){
                            LSIFunctions.changeColor(
                              context, 
                              grid.color
                            ).then((value){
                              setGrid(value, 'color');
                            });
                            callBacks(call: LSICallbacks.UpdatedNav);
                          }
                        ),
                        NavItems(
                          name: 'X',
                          icon: Icons.grid_on_sharp,
                          quarterTurns: 1,
                          input: grid.width,
                          function: (data){
                            setGrid(int.parse(data), 'X');
                          }
                        ),
                        NavItems(
                          name: 'Y',
                          icon: Icons.grid_on_sharp,
                          input: grid.height,
                          function: (data){
                            setGrid(int.parse(data), 'Y');
                          }
                        ),
                        NavItems(
                          name: 'stroke',
                          icon: Icons.line_weight,
                          input: grid.lineWidth,
                          function: (data){
                            setGrid(double.parse(data), 'stroke');
                          }
                        ),
                      ]
                    ),
                    NavItems(
                      name: 'Reset Camera',
                      icon: Icons.camera_indoor_outlined,
                      function: (e){
                        callBacks(call: LSICallbacks.UpdatedNav);
                        levelScene.camera.reset();
                      }
                    )
                  ]
                )
              ]
            ),
        ),
        body: levelSheetEditor()
      ),
    );
  }
}