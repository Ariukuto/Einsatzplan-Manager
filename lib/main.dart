import 'dart:io';
import 'package:open_filex/open_filex.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

	final lightTheme = ThemeData(
  	primaryColor: Colors.blue,
		errorColor: Colors.red,
		iconTheme: const IconThemeData(
			color: Colors.white,
		),
    useMaterial3: true,
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      home: const MyHomePage(title: 'Einsatzplan Manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

		return FutureBuilder(
			future: getExternalStorageDirectory(), 
			builder: (context, snapshot) { 
				if(snapshot.hasData) {
					final directory = snapshot.data!;
					return Scaffold(
						appBar: AppBar(
							title: Text(widget.title),
						),
						body: buildBody(directory),
						floatingActionButton: FloatingActionButton(
							onPressed: () => _add(directory),
							tooltip: 'Add',
							backgroundColor: Theme.of(context).primaryColor,
							child: Icon(Icons.add, color: Theme.of(context).iconTheme.color)
						),
					);	
				} else {
					return const SizedBox.shrink();
				}		
			},
		);
  }

	buildBody(Directory directory) {
		return StreamBuilder(
			stream: directory.list(),
			builder: (context, snapshotFile) {
				if(!snapshotFile.hasData) {
					return const Center(
						child: Text("Keine Einsatzpläne gefunden"),
					);
				} else {
					return FutureBuilder(
						future: directory.list().length,
						builder: (context, snapshotLength) {
							if(!snapshotLength.hasData) {
							  return const SizedBox.shrink();
							}
							return  ListView.builder(
								itemCount: snapshotLength.data,
								itemBuilder: (context, _) {
									return ListTile(
											title: Text(snapshotFile.data!.path.split('/').last),
											// title: Text(snapshotFile.data!.path),
											onTap: () {
												OpenFilex.open(snapshotFile.data!.path);
											},
											trailing: GestureDetector(
												child: Icon(Icons.delete_forever, color: Theme.of(context).errorColor),
												onTap: () async {
													await File(snapshotFile.data!.path).delete().then((value) => setState(() {}));
												},
											),
										);	
								}
							);
						}
					);
				}
			}
		);
	}

	void _add(Directory directory) async 
	{
		FilePickerResult? result = await FilePicker.platform.pickFiles(
			type: FileType.custom,
			allowedExtensions: ['pdf'],
		);

		if (result == null) {
			return null;
		}
		
		PlatformFile pickedFile = PlatformFile(
			path: result.files.single.path!,
			name: result.files.first.name,
			size: result.files.first.size
		);

		final file =  await File(pickedFile.path!).copy('${directory?.path}/${pickedFile.name}');

		setState(() {});
	}
}
