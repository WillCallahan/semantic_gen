import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

import 'wrapper_collector.dart';

// TODO: Move config-related classes to a separate file.

/// Configuration values that control the behaviour of the generator.
class GeneratorOptions {
  /// Creates a [GeneratorOptions] instance.
  const GeneratorOptions({
    this.globalWidgets = const <String>[],
    this.prefix = 'test',
    this.enabled = true,
    this.configPath,
  });

  /// Attempts to parse build configuration into a [GeneratorOptions] instance.
  static GeneratorOptions parseConfig(Map<String, dynamic> config) {
    final widgetsValue = config['auto_wrap_widgets'];
    final prefixValue = config['prefix'];
    final enabledValue = config['enabled'];
    final configPathValue = config['config_path'];

    return GeneratorOptions(
      globalWidgets:
          widgetsValue is Iterable
              ? widgetsValue.map((dynamic value) => value.toString()).toList()
              : const <String>[],
      prefix:
          prefixValue is String && prefixValue.isNotEmpty
              ? prefixValue
              : 'test',
      enabled: enabledValue is bool ? enabledValue : true,
      configPath:
          configPathValue is String && configPathValue.isNotEmpty
              ? configPathValue
              : 'semantic_gen.yaml',
    );
  }

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

/// A specification for a semantic wrapper.
class WrapperSpec {
  /// Creates a new [WrapperSpec].
  WrapperSpec({
    required this.typeName,
    required this.prefix,
    required this.namespace,
    required this.testId,
    this.customTemplate,
    bool? isButton,
    bool? isTextField,
  }) : button = isButton ?? typeName.toLowerCase().contains('button'),
       textField = isTextField ?? typeName.toLowerCase().contains('field'),
       container = true,
       enabled = true;

  /// The name of the widget type.
  final String typeName;

  /// The prefix for the semantic label.
  final String prefix;

  /// The namespace for the semantic label.
  final String namespace;

  /// The test ID for the semantic label.
  final String? testId;

  /// The custom wrapper template.
  final String? customTemplate;

  /// Whether the widget is a button.
  final bool button;

  /// Whether the widget is a text field.
  final bool textField;

  /// Whether the widget is a container.
  final bool container;

  /// Whether the widget is enabled.
  final bool enabled;

  /// The name of the wrapper class.
  String get wrapperName => '${typeName}Tagged';

  /// The semantic label for the widget.
  String? get semanticsLabel {
    if (customTemplate != null) {
      return null;
    }
    if (testId != null && testId!.isNotEmpty) {
      return '$prefix:$testId';
    }
    return '$prefix:$namespace:$typeName';
  }
}

/// The default configuration for a widget.
class DefaultWidgetConfig {
  /// Creates a new [DefaultWidgetConfig].
  const DefaultWidgetConfig(this.typeName, {this.isButton});

  /// The name of the widget type.
  final String typeName;

  /// Whether the widget is a button.
  final bool? isButton;
}

/// A lightweight descriptor for a class that will receive a semantics wrapper.
@visibleForTesting
class AutoTagClassDescriptor {
  /// Creates a descriptor for tests and helper paths.
  const AutoTagClassDescriptor({
    required this.name,
    this.namespace,
    this.testId,
    required this.isButton,
    this.customTemplate,
  });

  /// Class name to wrap.
  final String name;

  /// Optional namespace used when building the semantics label.
  final String? namespace;

  /// Optional `@TestId` value that overrides the generated label.
  final String? testId;

  /// Whether the widget should expose the button semantic flag.
  final bool isButton;

  /// The custom wrapper template.
  final String? customTemplate;
}

/// A class that collects widget specifications.
class WidgetCollector {
  /// Creates a new [WidgetCollector].
  WidgetCollector(this._baseOptions);

  final GeneratorOptions _baseOptions;
  GeneratorOptions? _resolvedOptionsCache;
  bool _triedResolvingOptions = false;

  /// Collects all the wrapper specifications for a given library.
  Future<List<WrapperSpec>> collect(
    LibraryReader library,
    BuildStep buildStep,
  ) async {
    final effectiveOptions = await _effectiveOptions(buildStep);

    if (!effectiveOptions.enabled) {
      return [];
    }

    return collectWrappers(library, effectiveOptions);
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

  Future<GeneratorConfigOverrides?> _loadOverrides(BuildStep buildStep) async {
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
        return const GeneratorConfigOverrides();
      }
      return _parseOverrides(raw);
    } on AssetNotFoundException {
      return null;
    } catch (error) {
      return null;
    }
  }

  static GeneratorConfigOverrides _parseOverrides(YamlMap yaml) {
    final prefixRaw = yaml['prefix'];
    return GeneratorConfigOverrides(
      globalWidgets: _stringList(yaml['auto_wrap_widgets']),
      prefix:
          prefixRaw is String && prefixRaw.isNotEmpty
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
}
