import 'package:analyzer/dart/element/element2.dart';
import 'package:source_gen/source_gen.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'collector.dart';

List<WrapperSpec> collectWrappers(
  LibraryReader library,
  GeneratorOptions options,
) {
  final descriptors = <AutoTagClassDescriptor>[];

  for (final classElement in library.classes) {
    final autoTagAnnotation =
        _autoTagChecker.firstAnnotationOf(classElement);
    if (autoTagAnnotation == null) {
      continue;
    }

    final autoTagReader = ConstantReader(autoTagAnnotation);
    final namespace = autoTagReader.peek('namespace')?.stringValue;
    final testIdAnnotation = _testIdChecker.firstAnnotationOfExact(
      classElement,
    );
    final testIdReader =
        testIdAnnotation == null ? null : ConstantReader(testIdAnnotation);
    final testId = testIdReader?.peek('value')?.stringValue;

    final customWrapper = autoTagReader.peek('custom')?.objectValue;
    final customTemplate =
        customWrapper == null
            ? null
            : ConstantReader(customWrapper).peek('template')?.stringValue;

    descriptors.add(
      _descriptorFromMetadata(
        className: classElement.displayName,
        namespace: namespace,
        testId: testId,
        isButton: _looksLikeButton(classElement as Element2),
        customTemplate: customTemplate,
      ),
    );
  }

  return _buildWrappers(
    options: options,
    classDescriptors: descriptors,
    libraryWidgetNames: _libraryWidgets(library),
  );
}

List<WrapperSpec> _buildWrappers({
  required GeneratorOptions options,
  required Iterable<AutoTagClassDescriptor> classDescriptors,
  required Iterable<_WidgetToWrap> libraryWidgetNames,
}) {
  final wrapperSpecs = <WrapperSpec>[];
  final emittedTypes = <String>{};

  void addWrapper(WrapperSpec spec) {
    if (emittedTypes.add(spec.wrapperName)) {
      wrapperSpecs.add(spec);
    }
  }

  for (final widget in _defaultWidgets) {
    final sanitized = _sanitizeIdentifier(widget.typeName);
    if (sanitized == null) {
      continue;
    }
    addWrapper(
      WrapperSpec(
        typeName: sanitized,
        namespace: 'auto',
        prefix: options.prefix,
        testId: null,
        isButton: widget.isButton,
      ),
    );
  }

  final combinedWidgetNames = <_WidgetToWrap>[
    ...options.globalWidgets.map((e) => _WidgetToWrap(e)),
    ...libraryWidgetNames,
  ];

  for (final widget in combinedWidgetNames) {
    final sanitized = _sanitizeIdentifier(widget.name);
    if (sanitized == null) {
      continue;
    }
    addWrapper(
      WrapperSpec(
        typeName: sanitized,
        namespace: 'auto',
        prefix: options.prefix,
        testId: null,
        customTemplate: widget.customTemplate,
      ),
    );
  }

  for (final descriptor in classDescriptors) {
    addWrapper(
      WrapperSpec(
        typeName: descriptor.name,
        namespace: descriptor.namespace ?? 'auto',
        prefix: options.prefix,
        testId: descriptor.testId,
        isButton: descriptor.isButton,
        customTemplate: descriptor.customTemplate,
      ),
    );
  }

  wrapperSpecs.sortBy((spec) => spec.wrapperName);
  return wrapperSpecs;
}

Iterable<_WidgetToWrap> _libraryWidgets(LibraryReader library) sync* {
  for (final annotated in library.libraryDirectivesAnnotatedWith(
    _autoWrapChecker,
  )) {
    final widgetTypes = annotated.annotation.peek('widgetTypes');
    if (widgetTypes == null || !widgetTypes.isList) {
      continue;
    }
    final customWrapper = annotated.annotation.peek('custom')?.objectValue;
    final customTemplate =
        customWrapper == null
            ? null
            : ConstantReader(customWrapper).peek('template')?.stringValue;

    yield* _widgetNamesFromStrings(
      widgetTypes.listValue.map((entry) => entry.toStringValue()),
      customTemplate,
    );
  }
}

Iterable<_WidgetToWrap> _widgetNamesFromStrings(
  Iterable<String?> values,
  String? customTemplate,
) sync* {
  for (final value in values) {
    if (value != null && value.isNotEmpty) {
      yield _WidgetToWrap(value, customTemplate);
    }
  }
}

AutoTagClassDescriptor _descriptorFromMetadata({
  required String className,
  String? namespace,
  String? testId,
  required bool isButton,
  String? customTemplate,
}) {
  final sanitizedName = _sanitizeIdentifier(className) ?? className;
  final normalizedNamespace =
      (namespace != null && namespace.isNotEmpty) ? namespace : null;
  final normalizedTestId =
      (testId != null && testId.isNotEmpty) ? testId : null;

  return AutoTagClassDescriptor(
    name: sanitizedName,
    namespace: normalizedNamespace,
    testId: normalizedTestId,
    isButton: isButton,
    customTemplate: customTemplate,
  );
}

bool _looksLikeButton(Element2 element) {
  if (element is! InterfaceElement2) return false;
  return _inferButtonFlag(
    name: element.displayName,
    superTypes: element.allSupertypes.map(
      (type) => type.element3.displayName,
    ),
  );
}

bool _inferButtonFlag({
  required String name,
  Iterable<String> superTypes = const <String>[],
}) {
  final lower = name.toLowerCase();
  if (lower.contains('button')) {
    return true;
  }
  return superTypes.any(
    (candidate) => candidate.toLowerCase().contains('button'),
  );
}

String? _sanitizeIdentifier(String value) {
  final match = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
  return match.hasMatch(value) ? value : null;
}

const List<DefaultWidgetConfig> _defaultWidgets =
    <DefaultWidgetConfig>[
      DefaultWidgetConfig('Text'),
      DefaultWidgetConfig('SelectableText'),
      DefaultWidgetConfig('TextField'),
      DefaultWidgetConfig('TextFormField'),
      DefaultWidgetConfig('GestureDetector', isButton: true),
      DefaultWidgetConfig('InkWell', isButton: true),
      DefaultWidgetConfig('InkResponse', isButton: true),
      DefaultWidgetConfig('RawMaterialButton', isButton: true),
      DefaultWidgetConfig('ElevatedButton', isButton: true),
      DefaultWidgetConfig('FilledButton', isButton: true),
      DefaultWidgetConfig('OutlinedButton', isButton: true),
      DefaultWidgetConfig('TextButton', isButton: true),
      DefaultWidgetConfig('IconButton', isButton: true),
      DefaultWidgetConfig('FloatingActionButton', isButton: true),
      DefaultWidgetConfig('DropdownButton', isButton: true),
      DefaultWidgetConfig('PopupMenuButton', isButton: true),
      DefaultWidgetConfig('MenuItemButton', isButton: true),
      DefaultWidgetConfig('ListTile', isButton: true),
      DefaultWidgetConfig('CheckboxListTile', isButton: true),
      DefaultWidgetConfig('SwitchListTile', isButton: true),
      DefaultWidgetConfig('RadioListTile', isButton: true),
    ];

const TypeChecker _autoTagChecker = TypeChecker.fromUrl(
  'package:semantic_gen/src/annotations.dart#AutoTag',
);
const TypeChecker _testIdChecker = TypeChecker.fromUrl(
  'package:semantic_gen/src/annotations.dart#TestId',
);
const TypeChecker _autoWrapChecker = TypeChecker.fromUrl(
  'package:semantic_gen/src/annotations.dart#AutoWrapWidgets',
);

class _WidgetToWrap {
  const _WidgetToWrap(this.name, [this.customTemplate]);

  final String name;
  final String? customTemplate;
}
