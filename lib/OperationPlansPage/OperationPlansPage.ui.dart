import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class OperationPlansPage extends StatefulWidget {
  const OperationPlansPage({super.key, required this.title});

  final String title;

  @override
  State<OperationPlansPage> createState() => _OperationPlansPageState();
}

class _OperationPlansPageState extends State<OperationPlansPage> {

	StreamController<List<FileSystemEntity>> fileListController = StreamController<List<FileSystemEntity>>();
	
	late Directory? directory;

	@override
	 initState() {
		super.initState();
		getExternalStorageDirectory().then((dir) {
				directory = dir;
				getFileList();
		});
	}

	Future<void> getFileList() async {
		List<FileSystemEntity> list = [];
		if(directory != null) {
			await for (var entity in directory!.list()) {
				if(await FileSystemEntity.isFile(entity.path)) {
					list.add(entity);
				}
			}
			await Future.delayed(const Duration(milliseconds: 500));
			fileListController.sink.add(list.reversed.toList());
		}		
	}

  @override
  Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(widget.title, style: const TextStyle(color: Colors.white)),
				backgroundColor: Colors.redAccent,
				actions: const [
					IconButton(
						icon: Icon(Icons.settings, size: 30, color: Colors.white),
						onPressed: null,
					)
				],
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () => _add(),
				tooltip: 'Add',
				backgroundColor: Colors.redAccent,
				child: Icon(Icons.add, color: Theme.of(context).iconTheme.color)
			),
			body: StreamBuilder(
				stream: fileListController.stream,
				builder: (context, fileListSnapShot) {
					if(fileListSnapShot.hasData) {
						if(fileListSnapShot.data!.isEmpty) {
							return const Text("Keine Pläne gefunden");
						}
						return ListView.separated(
							itemCount: fileListSnapShot.data?.length ?? 0,
							separatorBuilder: (_, __) => const Divider(), 
							itemBuilder: (context, i) => listItem(i, fileListSnapShot.data ?? [])
						);
					} else {
						return const Center(
							child: Text("Lade Pläne ..."),
						);
					}
				}
			)
		);	
  }

	listItem(int index, List<FileSystemEntity> fileList) {
		return FutureBuilder(
			future: (fileList[index] as File).lastModified(),
			builder: (context, lastModifiedSnapShot) {
					var file = fileList[index];
					var path = file.path;
					var fileName = File(path).uri.pathSegments.last;
					var subtitle = "${lastModifiedSnapShot.data?.day ?? ""}.${lastModifiedSnapShot.data?.month ?? ""}.${lastModifiedSnapShot.data?.year ?? ""}";
				return ListTile(
					title: Text(fileName),
					subtitle: Text("Hinzugefügt: $subtitle "),
					onTap: () => OpenFilex.open(path),
					trailing: GestureDetector(
					child: Icon(Icons.delete_forever, color: Theme.of(context).errorColor),
					onTap: () async => File(path).delete().then((value) => getFileList()),
					),
				);
			}
		);
	}

	void _add() async
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

		await File(pickedFile.path!).copy('${directory?.path}/${pickedFile.name}');

		getFileList();
	}
}
