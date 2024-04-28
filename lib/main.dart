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
      home: const MyHomePage(title: 'FFW Marktbreit'),
			onGenerateRoute: (settings) {
				
			},
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
							title: Text(widget.title, style: const TextStyle(color: Colors.white)),
							backgroundColor: Colors.redAccent,
							actions: [
								IconButton(
									icon: const Icon(Icons.settings, size: 30, color: Colors.white),
									onPressed: () => Navigator. .push(
										context,
										MaterialPageRoute(
											builder: (context) => const Placeholder(),
										),
									),
								)
							],
						),
						body: buildBody(directory),
						floatingActionButton: FloatingActionButton(
							onPressed: () => _add(directory),
							tooltip: 'Add',
							backgroundColor: Colors.redAccent,
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
		var fileList = directory.listSync().where((v) => FileSystemEntity.isFileSync(v.path)).toList();
		return ListView.separated(
			itemCount: fileList.length,
			separatorBuilder: (_, __) => const Divider(), 
			itemBuilder: (context, i) => ListItem(i, fileList) 
		);
	}

	ListTile ListItem(int index, List<FileSystemEntity> fileList) {
		var file = fileList[index];
		var path = file.path;
		var fileName = File(path).uri.pathSegments.last;
		var lastModified = (file as File).lastModifiedSync();
		var subtitle = "${lastModified.day}.${lastModified.month}.${lastModified.year}";
		return ListTile(
			title: Text(fileName),
			subtitle: Text("Hinzugefügt: $subtitle "),
			onTap: () => OpenFilex.open(path),
			trailing: GestureDetector(
			child: Icon(Icons.delete_forever, color: Theme.of(context).errorColor),
			onTap: () async => File(path).delete().then((value) => setState(() {})),
			),
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

		await File(pickedFile.path!).copy('${directory.path}/${pickedFile.name}');

		setState(() {});
	}
}


