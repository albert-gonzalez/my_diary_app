import 'package:flutter_quill/flutter_quill.dart';

class TextEditorToolbar {
  static QuillToolbar create({required controller}) => QuillToolbar.basic(
        controller: controller,
        showAlignmentButtons: true,
        showFontFamily: false,
        showFontSize: false,
        showImageButton: false,
        showVideoButton: false,
        showColorButton: false,
        showBackgroundColorButton: false,
        showSearchButton: false,
        showCodeBlock: false,
        showListCheck: false,
        showCenterAlignment: false,
        showJustifyAlignment: false,
        showLeftAlignment: false,
        showRightAlignment: false);
}