// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

class OperationsPlansList extends StatefulWidget {

	final Directory directory;

  const OperationsPlansList({
		super.key,
		required this.directory
	});

  @override
  State<OperationsPlansList> createState() => _OperationsPlansListState();
}

class _OperationsPlansListState extends State<OperationsPlansList> {

	StreamController<List<FileSystemEntity>> reloadController = StreamController<List<FileSystemEntity>>();
	List<FileSystemEntity> fileList = [];

	@override
  void initState() async {
		await getFileList();
		super.initState();
	}

	Future<void> getFileList() async {
		List<FileSystemEntity> list = [];
		await for (var entity in widget.directory.list()) {
			if(await FileSystemEntity.isFile(entity.path)) {
				list.add(entity);
			}
		}
		reloadController.sink.add(list);
	}

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
			stream: reloadController.stream,
			builder: (_, __) {
				return const Placeholder();
			}
		);
  }
}
