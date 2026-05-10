import 'dart:io';
import 'package:flutter/material.dart';
import '../models/song_model.dart';

class AlbumArt extends StatelessWidget {
  final SongModel? song;
  final double size;
  final double borderRadius;

  const AlbumArt({
    super.key,
    required this.song,
    this.size = 300,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: const Color(0xFF282828),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: song?.albumArt != null
            ? Image.file(
          File(song!.albumArt!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF282828),
      child: Center(
        child: Icon(
          Icons.music_note,
          size: size * 0.35,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}