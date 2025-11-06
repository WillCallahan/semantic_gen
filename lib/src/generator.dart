import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

/// Configuration values that control the behaviour of [AutoTagGenerator].
class GeneratorOptions {
  /// Creates a [GeneratorOptions] instance.
  const GeneratorOptions({
    this.globalWidgets = const <String>[],
    this.prefix = 'test',
    this.enabled = true,
    this.configPath,
  });

  /// Additional widget type names that should always be wrapped.
  final List<String> globalWidgets;

  /// Prefix applied to all generated semantics labels.
  final String prefix;

  /// Whether code generation should be performed.
  final bool enabled;

  /// Optional configuration file path relative to the package root.
  final String? configPath;

  /// Builds a new instance applying [overrides] on top of the current values.
  GeneratorOptions withOverrides(GeneratorConfigOverrides overrides) {
    return GeneratorOptions(
      globalWidgets: overrides.globalWidgets ?? globalWidgets,
      prefix: overrides.prefix ?? prefix,
      enabled: overrides.enabled ?? enabled,
      configPath: configPath,
    );
  }
}

/// Partial configuration values provided by an external file.
class GeneratorConfigOverrides {
  /// Creates a overrides bag.
  const GeneratorConfigOverrides({
    this.globalWidgets,
    this.prefix,
    this.enabled,
  });

  /// Additional widget type names that should always be wrapped.
  final List<String>? globalWidgets;

  /// Prefix applied to all generated semantics labels.
  final String? prefix;

  /// Whether code generation should be performed.
  final bool? enabled;

  /// Whether the overrides bag is empty.
  bool get isEmpty =>
      globalWidgets == null && prefix == null && enabled == null;
}

/// Collects and emits wrappers that add deterministic semantics labels.
class AutoTagGenerator extends Generator {
  /// Creates a new generator.
  AutoTagGenerator(GeneratorOptions options) : _baseOptions = options;

  /// Attempts to parse build configuration into a [GeneratorOptions] instance.
  static GeneratorOptions parseConfig(Map<String, dynamic> config) {
    final widgetsValue = config['auto_wrap_widgets'];
    final prefixValue = config['prefix'];
    final enabledValue = config['enabled'];
    final configPathValue = config['config_path'];

    return GeneratorOptions(
      globalWidgets: widgetsValue is Iterable
          ? widgetsValue.map((dynamic value) => value.toString()).toList()
          : const <String>[],
      prefix: prefixValue is String && prefixValue.isNotEmpty
          ? prefixValue
          : 'test',
      enabled: enabledValue is bool ? enabledValue : true,
      configPath: configPathValue is String && configPathValue.isNotEmpty
          ? configPathValue
          : 'semantic_gen.yaml',
    );
  }

  /// Options supplied to this generator.
  GeneratorOptions get options => _baseOptions;
  final GeneratorOptions _baseOptions;

  GeneratorOptions? _resolvedOptionsCache;
  bool _triedResolvingOptions = false;

  static const Set<String> _defaultWidgets = <String>{
    'Text',
    'SelectableText',
    'TextField',
    'TextFormField',
  };

  static const TypeChecker _autoTagChecker = TypeChecker.fromUrl(
    'package:semantic_gen/src/annotations.dart#AutoTag',
  );
  static const TypeChecker _testIdChecker = TypeChecker.fromUrl(
    'package:semantic_gen/src/annotations.dart#TestId',
  );
  static const TypeChecker _autoWrapChecker = TypeChecker.fromUrl(
    'package:semantic_gen/src/annotations.dart#AutoWrapWidgets',
  );

  @override
  Future<String> generate(
    LibraryReader library,
    BuildStep buildStep,
  ) async {
    final effectiveOptions = await _effectiveOptions(buildStep);
    final buffer = _createBuffer(buildStep);

    if (!effectiveOptions.enabled) {
      buffer.writeln('// semantic_gen disabled via configuration.');
      return buffer.toString();
    }

    final wrappers = _collectWrappers(library, effectiveOptions);

    if (wrappers.isEmpty) {
      log.fine(
        'semantic_gen: no wrappers to emit for ${buildStep.inputId.path}.',
      );
      return buffer.toString();
    }

    for (final wrapper in wrappers) {
      buffer
        ..writeln('class ${wrapper.wrapperName} extends StatelessWidget {')
        ..writeln(
            '  const ${wrapper.wrapperName}({Key? key, required this.child}) : super(key: key);')
        ..writeln()
        ..writeln('  final ${wrapper.typeName} child;')
        ..writeln()
        ..writeln('  @override')
        ..writeln('  Widget build(BuildContext context) {')
        ..writeln('    return Semantics(')
        ..writeln("      label: '${wrapper.semanticsLabel}',")
        ..writeln('      container: ${wrapper.container},')
        ..writeln('      button: ${wrapper.button},')
        ..writeln('      textField: ${wrapper.textField},')
        ..writeln('      enabled: ${wrapper.enabled},')
        ..writeln('      child: child,')
        ..writeln('    );')
        ..writeln('  }')
        ..writeln('}')
        ..writeln();
    }

    return buffer.toString();
  }

  Future<GeneratorOptions> _effectiveOptions(BuildStep buildStep) async {
    if (_resolvedOptionsCache != null) {
      return _resolvedOptionsCache!;
    }
    if (_triedResolvingOptions) {
      return _baseOptions;
    }
    _triedResolvingOptions = true;

    final overrides = await _loadOverrides(buildStep);
    if (overrides != null && !overrides.isEmpty) {
      _resolvedOptionsCache = _baseOptions.withOverrides(overrides);
    } else {
      _resolvedOptionsCache = _baseOptions;
    }
    return _resolvedOptionsCache!;
  }

  Future<GeneratorConfigOverrides?> _loadOverrides(
    BuildStep buildStep,
  ) async {
    final configPath = _baseOptions.configPath;
    if (configPath == null || configPath.isEmpty) {
      return null;
    }

    final assetId = AssetId(buildStep.inputId.package, configPath);
    try {
      final yamlContent = await buildStep.readAsString(assetId);
      final raw = loadYaml(yamlContent);
      if (raw == null) {
        return const GeneratorConfigOverrides();
      }
      if (raw is! YamlMap) {
        log.warning(
          'semantic_gen: expected $configPath to contain a YAML map. Ignoring.',
        );
        return const GeneratorConfigOverrides();
      }
      return _parseOverrides(raw);
    } on AssetNotFoundException {
      return null;
    } catch (error, stackTrace) {
      log.severe(
        'semantic_gen: failed to load $configPath',
        error,
        stackTrace,
      );
      return null;
    }
  }

  static GeneratorConfigOverrides _parseOverrides(YamlMap yaml) {
    final prefixRaw = yaml['prefix'];
    return GeneratorConfigOverrides(
      globalWidgets: _stringList(yaml['auto_wrap_widgets']),
      prefix: prefixRaw is String && prefixRaw.isNotEmpty
          ? prefixRaw
          : prefixRaw != null && prefixRaw.toString().isNotEmpty
              ? prefixRaw.toString()
              : null,
      enabled: _boolValue(yaml['enabled']),
    );
  }

  static List<String>? _stringList(dynamic value) {
    if (value is Iterable) {
      final result = <String>[];
      for (final entry in value) {
        final raw = entry?.toString();
        if (raw == null) {
          continue;
        }
        final candidate = raw.trim();
        if (candidate.isNotEmpty) {
          result.add(candidate);
        }
      }
      return result;
    }
    return null;
  }

  static bool? _boolValue(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
    }
    return null;
  }

  StringBuffer _createBuffer(BuildStep buildStep) {
    return StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
      ..writeln('// coverage:ignore-file')
      ..writeln('// ignore_for_file: type=lint')
      ..writeln("part of '${buildStep.inputId.pathSegments.last}';")
      ..writeln();
  }

  List<_WrapperSpec> _collectWrappers(
    LibraryReader library,
    GeneratorOptions options,
  ) {
    final descriptors = <AutoTagClassDescriptor>[];

    for (final classElement in library.classes) {
      final autoTagAnnotation = _autoTagChecker.firstAnnotationOf(classElement);
      if (autoTagAnnotation == null) {
        continue;
      }

      final autoTagReader = ConstantReader(autoTagAnnotation);
      final namespace = autoTagReader.peek('namespace')?.stringValue;
      final testIdAnnotation =
          _testIdChecker.firstAnnotationOfExact(classElement);
      final testIdReader =
          testIdAnnotation == null ? null : ConstantReader(testIdAnnotation);
      final testId = testIdReader?.peek('value')?.stringValue;

      descriptors.add(
        descriptorFromMetadata(
          className: classElement.displayName,
          namespace: namespace,
          testId: testId,
          isButton: _looksLikeButton(classElement),
          isTextField: _looksLikeTextField(classElement),
        ),
      );
    }

    return _buildWrappers(
      options: options,
      classDescriptors: descriptors,
      libraryWidgetNames: _libraryWidgetNames(library),
    );
  }

  /// Builds a descriptor that mirrors analyzer metadata for unit tests.
  @visibleForTesting
  AutoTagClassDescriptor describeClassForTest({
    required String name,
    String? namespace,
    String? testId,
    bool isButton = false,
    bool isTextField = false,
  }) {
    return AutoTagClassDescriptor(
      name: name,
      namespace: namespace?.isNotEmpty == true ? namespace : null,
      testId: testId?.isNotEmpty == true ? testId : null,
      isButton: isButton,
      isTextField: isTextField,
    );
  }

  /// Collects wrapper specs without needing analyzer-driven discovery.
  @visibleForTesting
  List<AutoTagWrapperPreview> collectWrappersForTesting({
    Iterable<AutoTagClassDescriptor> classDescriptors =
        const <AutoTagClassDescriptor>[],
    Iterable<String> libraryWidgetNames = const <String>[],
    GeneratorOptions? optionsOverride,
  }) {
    final specs = _buildWrappers(
      options: optionsOverride ?? _baseOptions,
      classDescriptors: classDescriptors,
      libraryWidgetNames: libraryWidgetNames,
    );

    return specs
        .map(
          (spec) => AutoTagWrapperPreview(
            wrapperName: spec.wrapperName,
            semanticsLabel: spec.semanticsLabel,
            button: spec.button,
            textField: spec.textField,
          ),
        )
        .toList(growable: false);
  }

  List<_WrapperSpec> _buildWrappers({
    required GeneratorOptions options,
    required Iterable<AutoTagClassDescriptor> classDescriptors,
    required Iterable<String> libraryWidgetNames,
  }) {
    final wrapperSpecs = <_WrapperSpec>[];
    final emittedTypes = <String>{};

    void addWrapper(_WrapperSpec spec) {
      if (emittedTypes.add(spec.wrapperName)) {
        wrapperSpecs.add(spec);
      }
    }

    final combinedWidgetNames = <String>{
      ..._defaultWidgets,
      ...options.globalWidgets,
      ...libraryWidgetNames,
    };

    for (final widgetName in combinedWidgetNames) {
      final sanitized = _sanitizeIdentifier(widgetName);
      if (sanitized == null) {
        log.warning('Skipping invalid widget name: $widgetName');
        continue;
      }
      addWrapper(
        _WrapperSpec(
          typeName: sanitized,
          namespace: 'auto',
          prefix: options.prefix,
          testId: null,
        ),
      );
    }

    for (final descriptor in classDescriptors) {
      addWrapper(
        _WrapperSpec(
          typeName: descriptor.name,
          namespace: descriptor.namespace ?? 'auto',
          prefix: options.prefix,
          testId: descriptor.testId,
          isButton: descriptor.isButton,
          isTextField: descriptor.isTextField,
        ),
      );
    }

    wrapperSpecs.sortBy((spec) => spec.wrapperName);
    return wrapperSpecs;
  }

  Iterable<String> _libraryWidgetNames(LibraryReader library) sync* {
    for (final annotated
        in library.libraryDirectivesAnnotatedWith(_autoWrapChecker)) {
      final widgetTypes = annotated.annotation.peek('widgetTypes');
      if (widgetTypes == null || !widgetTypes.isList) {
        continue;
      }
      yield* widgetNamesFromStrings(
        widgetTypes.listValue.map((entry) => entry.toStringValue()),
      );
    }
  }

  /// Exposes [_libraryWidgetNames] for tests.
  @visibleForTesting
  Iterable<String> libraryWidgetNamesForTesting(LibraryReader library) =>
      _libraryWidgetNames(library);

  /// Normalises widget names coming from configuration sources.
  @visibleForTesting
  static Iterable<String> widgetNamesFromStrings(
    Iterable<String?> values,
  ) sync* {
    for (final value in values) {
      if (value != null && value.isNotEmpty) {
        yield value;
      }
    }
  }

  /// Builds a descriptor from analyzer metadata for use in tests.
  @visibleForTesting
  AutoTagClassDescriptor descriptorFromMetadata({
    required String className,
    String? namespace,
    String? testId,
    required bool isButton,
    required bool isTextField,
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
      isTextField: isTextField,
    );
  }

  static bool _looksLikeButton(InterfaceElement2 element) {
    return inferButtonFlag(
      name: element.displayName,
      superTypes:
          element.allSupertypes.map((type) => type.element3.displayName),
    );
  }

  static bool _looksLikeTextField(InterfaceElement2 element) {
    return inferTextFieldFlag(
      name: element.displayName,
      superTypes:
          element.allSupertypes.map((type) => type.element3.displayName),
    );
  }

  /// Heuristic used by tests and the generator to detect button-like widgets.
  @visibleForTesting
  static bool inferButtonFlag({
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

  /// Heuristic used by tests and the generator to detect text-field widgets.
  @visibleForTesting
  static bool inferTextFieldFlag({
    required String name,
    Iterable<String> superTypes = const <String>[],
  }) {
    final lower = name.toLowerCase();
    if (lower.contains('textfield') || lower.contains('editor')) {
      return true;
    }
    return superTypes.any((candidate) {
      final value = candidate.toLowerCase();
      return value.contains('textfield') ||
          value.contains('formfield') ||
          value.contains('editable');
    });
  }

  /// Validates whether [value] can be used as a Dart identifier.
  @visibleForTesting
  static bool isValidIdentifier(String value) =>
      _sanitizeIdentifier(value) != null;

  static String? _sanitizeIdentifier(String value) {
    final match = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
    return match.hasMatch(value) ? value : null;
  }
}

class _WrapperSpec {
  _WrapperSpec({
    required this.typeName,
    required this.prefix,
    required this.namespace,
    required this.testId,
    bool? isButton,
    bool? isTextField,
  })  : button = isButton ?? typeName.toLowerCase().contains('button'),
        textField = isTextField ?? typeName.toLowerCase().contains('field'),
        container = true,
        enabled = true;

  final String typeName;
  final String prefix;
  final String namespace;
  final String? testId;
  final bool button;
  final bool textField;
  final bool container;
  final bool enabled;

  String get wrapperName => '${typeName}Tagged';

  String get semanticsLabel {
    if (testId != null && testId!.isNotEmpty) {
      return '$prefix:$testId';
    }
    return '$prefix:$namespace:$typeName';
  }
}

/// Lightweight descriptor for a class that will receive a semantics wrapper.
@visibleForTesting
class AutoTagClassDescriptor {
  /// Creates a descriptor for tests and helper paths.
  const AutoTagClassDescriptor({
    required this.name,
    this.namespace,
    this.testId,
    required this.isButton,
    required this.isTextField,
  });

  /// Class name to wrap.
  final String name;

  /// Optional namespace used when building the semantics label.
  final String? namespace;

  /// Optional `@TestId` value that overrides the generated label.
  final String? testId;

  /// Whether the widget should expose the button semantic flag.
  final bool isButton;

  /// Whether the widget should expose the text field semantic flag.
  final bool isTextField;
}

/// Public view of a generated wrapper used exclusively for testing.
@visibleForTesting
class AutoTagWrapperPreview {
  /// Creates an immutable snapshot of a wrapper specification.
  const AutoTagWrapperPreview({
    required this.wrapperName,
    required this.semanticsLabel,
    required this.button,
    required this.textField,
  });

  /// Name of the generated wrapper class.
  final String wrapperName;

  /// Final semantics label applied by the wrapper.
  final String semanticsLabel;

  /// Whether the wrapper marks its child as a button.
  final bool button;

  /// Whether the wrapper marks its child as a text field.
  final bool textField;
}
