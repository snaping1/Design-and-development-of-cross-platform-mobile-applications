import 'package:flutter/material.dart';

/// Иконки пунктов: в БД хранится имя иконки, здесь — соответствие IconData
const Map<String, IconData> protocolIcons = {
  'language': Icons.language,
  'cable': Icons.cable,
  'speed': Icons.speed,
  'folder_copy': Icons.folder_copy,
  'dns': Icons.dns,
};

/// Модель данных пункта основного экрана (сетевой протокол)
class Protocol {
  final int id;
  final String name;
  final String description;
  final String details;
  final String imagePath;
  final String iconName;

  const Protocol({
    required this.id,
    required this.name,
    required this.description,
    required this.details,
    required this.imagePath,
    required this.iconName,
  });

  IconData get icon => protocolIcons[iconName] ?? Icons.lan;
}
