import 'dart:convert';
import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/utils.dart';
import '../../models/win32/win32.dart';
import '../../pages/interface.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  ProjectsPageState createState() => ProjectsPageState();
}

class ProjectsPageState extends State<ProjectsPage> {
  final TextEditingController folderEmojiController = TextEditingController();
  final TextEditingController folderTitleController = TextEditingController();
  final TextEditingController projectEmojiController = TextEditingController();
  final TextEditingController projectTitleController = TextEditingController();
  final TextEditingController projectPathController = TextEditingController();
  final List<ProjectGroup> projects = Boxes().projects;

  int activeProject = -1;
  double opacity = 0;
  int timerDelay = 300;
  List<double> heights = <double>[];
  @override
  void initState() {
    heights = List<double>.filled(projects.length, 0);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    folderEmojiController.dispose();
    folderTitleController.dispose();
    projectEmojiController.dispose();
    projectTitleController.dispose();
    projectPathController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      data: Theme.of(context).listTileTheme.copyWith(horizontalTitleGap: 10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: const Text("Projects", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            leading: Container(
              height: double.infinity,
              width: 50,
              child: const Icon(Icons.add),
            ),
            onTap: () async {
              projects.add(ProjectGroup(title: "New Project Group", emoji: "✨", projects: <ProjectInfo>[]));
              heights = List<double>.filled(projects.length, 0);
              await Boxes.updateSettings("projects", jsonEncode(projects));

              setState(() {});
            },
          ),
          ConstrainedBox(
            constraints: interfaceConstraints!,
            child: ReorderableListView.builder(
              shrinkWrap: true,
              dragStartBehavior: DragStartBehavior.down,
              itemCount: projects.length,
              physics: const BouncingScrollPhysics(),
              scrollController: ScrollController(),
              itemBuilder: (BuildContext context, int mainIndex) {
                final ProjectGroup project = projects[mainIndex];
                return Column(
                  key: ValueKey<int>(mainIndex),
                  children: <Widget>[
                    ListTile(
                      leading: Text(project.emoji),
                      title: Text(project.title),
                      onTap: () {
                        if (activeProject == mainIndex) {
                          activeProject = -1;
                        } else {
                          activeProject = mainIndex;
                        }
                        heights = List<double>.filled(projects.length, 0);
                        setState(() {});
                        if (activeProject != -1) {
                          Future<void>.delayed(const Duration(milliseconds: 100), () {
                            if (!mounted) return;
                            heights[mainIndex] = double.infinity;
                            setState(() {});
                          });
                        }
                      },
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Container(
                          width: 50,
                          height: double.infinity,
                          child: Row(children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                  child: const Icon(Icons.edit),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        folderEmojiController.value = TextEditingValue(text: project.emoji);
                                        folderTitleController.value = TextEditingValue(text: project.title);

                                        return AlertDialog(
                                          content: Container(
                                              width: 300,
                                              height: 100,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  TextField(
                                                    decoration: InputDecoration(
                                                      labelText: "Emoji ( Press Win + . to toggle Emoji Picker)",
                                                      hintText: "Emoji ( Press Win + . to toggle Emoji Picker)",
                                                      isDense: true,
                                                      border: UnderlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black.withOpacity(0.5))),
                                                    ),
                                                    controller: folderEmojiController,
                                                    inputFormatters: <TextInputFormatter>[
                                                      LengthLimitingTextInputFormatter(1),
                                                    ],
                                                    style: const TextStyle(fontSize: 14),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  TextField(
                                                    decoration: InputDecoration(
                                                      labelText: "Title",
                                                      hintText: "Title",
                                                      isDense: true,
                                                      border: UnderlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black.withOpacity(0.5))),
                                                    ),
                                                    controller: folderTitleController,
                                                    style: const TextStyle(fontSize: 14),
                                                  ),
                                                  const SizedBox(height: 10),
                                                ],
                                              )),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                projects.removeAt(mainIndex);
                                                heights = List<double>.filled(projects.length, 0);
                                                activeProject = -1;

                                                await Boxes.updateSettings("projects", jsonEncode(projects));
                                                setState(() {});
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Delete"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                projects[mainIndex].emoji = folderEmojiController.value.text;
                                                projects[mainIndex].title = folderTitleController.value.text;
                                                await Boxes.updateSettings("projects", jsonEncode(projects));
                                                setState(() {});
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Save"),
                                            ),
                                          ],
                                        );
                                      },
                                    ).then((_) {});
                                  }),
                            ),
                            // ! ADD NEW PROJECT
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                child: const Icon(Icons.add),
                                onTap: () async {
                                  projects[mainIndex].projects.add(ProjectInfo(emoji: "🎀", title: "New Project", stringToExecute: "C:\\"));
                                  await Boxes.updateSettings("projects", jsonEncode(projects));
                                  if (activeProject != mainIndex) {
                                    heights = List<double>.filled(projects.length, 0);
                                    activeProject = mainIndex;
                                    setState(() {});
                                    Future<void>.delayed(const Duration(milliseconds: 100), () {
                                      if (!mounted) return;
                                      heights[mainIndex] = double.infinity;
                                      setState(() {});
                                    });
                                  } else {
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: Duration(milliseconds: timerDelay),
                      child: Container(
                        constraints: BoxConstraints(maxHeight: heights[mainIndex]),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 40, 0),
                          child: ReorderableListView.builder(
                            shrinkWrap: true,
                            dragStartBehavior: DragStartBehavior.down,
                            itemCount: projects[mainIndex].projects.length,
                            physics: const BouncingScrollPhysics(),
                            scrollController: ScrollController(),
                            itemBuilder: (BuildContext context, int index) {
                              final ProjectInfo projectItem = projects[mainIndex].projects[index];
                              return ListTile(
                                key: ValueKey<int>(index),
                                leading: Text(projectItem.emoji),
                                title: Text(projectItem.title),
                                onTap: () {
                                  WinUtils.open(projectItem.stringToExecute);
                                  setState(() {});
                                },
                                trailing: Container(
                                  height: double.infinity,
                                  width: 50,
                                  padding: const EdgeInsets.only(right: 15),
                                  child: InkWell(
                                    child: const Icon(Icons.edit),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          projectEmojiController.value = TextEditingValue(text: projectItem.emoji);
                                          projectTitleController.value = TextEditingValue(text: projectItem.title);
                                          projectPathController.value = TextEditingValue(text: projectItem.stringToExecute);
                                          return AlertDialog(
                                            content: Container(
                                                width: 300,
                                                height: 250,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    TextField(
                                                      decoration: InputDecoration(
                                                        labelText: "Emoji ( Press Win + . to toggle Emoji Picker)",
                                                        hintText: "Emoji ( Press Win + . to toggle Emoji Picker)",
                                                        isDense: true,
                                                        border: UnderlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black.withOpacity(0.5))),
                                                      ),
                                                      controller: projectEmojiController,
                                                      inputFormatters: <TextInputFormatter>[
                                                        LengthLimitingTextInputFormatter(1),
                                                      ],
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    TextField(
                                                      decoration: InputDecoration(
                                                        labelText: "Title",
                                                        hintText: "Title",
                                                        isDense: true,
                                                        border: UnderlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black.withOpacity(0.5))),
                                                      ),
                                                      controller: projectTitleController,
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: <Widget>[
                                                        Expanded(
                                                          flex: 2,
                                                          child: TextField(
                                                            decoration: InputDecoration(
                                                              labelText: "Path to execute",
                                                              hintText: "Path to execute",
                                                              isDense: true,
                                                              border: UnderlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black.withOpacity(0.5))),
                                                            ),
                                                            controller: projectPathController,
                                                            style: const TextStyle(fontSize: 14),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 30,
                                                          height: 50,
                                                          child: Tooltip(
                                                            message: "Pick a file path\nDelete filename if you want the path.",
                                                            child: InkWell(
                                                              onTap: () async {
                                                                final OpenFilePicker file = OpenFilePicker()
                                                                  ..filterSpecification = <String, String>{
                                                                    'All Files': '*.*',
                                                                  }
                                                                  ..defaultFilterIndex = 0
                                                                  ..defaultExtension = 'exe'
                                                                  ..title = 'Select any file';

                                                                final File? result = file.getFile();
                                                                if (result != null) {
                                                                  if (!mounted) return;
                                                                  projectItem.stringToExecute = result.path;
                                                                  projectPathController.value = TextEditingValue(text: result.path);

                                                                  print("xx");
                                                                  setState(() {});
                                                                }
                                                              },
                                                              child: Container(height: double.infinity, child: const Icon(Icons.folder_copy, size: 20)),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text("You can Write:\n - a Folder Path or file to open\n - a command like vscode C:\\somepath\\\n - a link",
                                                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6), fontSize: 12))
                                                  ],
                                                )),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: const Text("Cancel"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  projects[mainIndex].projects.removeAt(index);
                                                  await Boxes.updateSettings("projects", jsonEncode(projects));
                                                  setState(() {});
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Delete"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  projects[mainIndex].projects[index].emoji = projectEmojiController.value.text;
                                                  projects[mainIndex].projects[index].title = projectTitleController.value.text;
                                                  projects[mainIndex].projects[index].stringToExecute = projectPathController.value.text;
                                                  await Boxes.updateSettings("projects", jsonEncode(projects));
                                                  setState(() {});
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Save"),
                                              ),
                                            ],
                                          );
                                        },
                                      ).then((_) {});
                                    },
                                  ),
                                ),
                              );
                            },
                            onReorder: (int oldIndex, int newIndex) async {
                              if (oldIndex < newIndex) newIndex -= 1;
                              final ProjectInfo item = projects[mainIndex].projects.removeAt(oldIndex);
                              projects[mainIndex].projects.insert(newIndex, item);
                              await Boxes.updateSettings("projects", jsonEncode(projects));
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
              onReorder: (int oldIndex, int newIndex) async {
                activeProject = -1;
                if (oldIndex < newIndex) newIndex -= 1;
                final ProjectGroup item = projects.removeAt(oldIndex);
                projects.insert(newIndex, item);
                final double hh = heights[oldIndex];
                heights[oldIndex] = heights[newIndex];
                heights[newIndex] = hh;
                activeProject = newIndex;
                timerDelay = 50;
                await Boxes.updateSettings("projects", jsonEncode(projects));
                setState(() {});
                Future<void>.delayed(const Duration(milliseconds: 500), () => timerDelay = 300);
              },
            ),
          ),
        ],
      ),
    );
  }
}
