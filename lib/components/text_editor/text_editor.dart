import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TextEditor extends QuillEditor {
  TextEditor(
      {Key? key,
      required super.controller,
      required super.focusNode,
      required super.readOnly,
      super.showCursor})
      : super(
            key: key,
            scrollable: true,
            scrollController: ScrollController(),
            autoFocus: false,
            expands: false,
            padding: EdgeInsets.zero);
}
