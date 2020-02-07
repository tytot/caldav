import 'package:xml/src/xml/nodes/node.dart';
import 'package:xml/src/xml/nodes/element.dart';
import 'package:xml/src/xml/nodes/attribute.dart';
import 'package:xml/src/xml/nodes/document.dart';

abstract class Parser<T> {
  String getNodeName();
  String getNodeNamespace();

  String getFullName() {
    String namespaceUrn = this.getNodeNamespace();
    if (!this.pathToNamespaceMap.containsKey(namespaceUrn)) {
      throw new ArgumentError('Unknown namespace path ' + namespaceUrn);
    }
    return this.pathToNamespaceMap[namespaceUrn] + ':' + this.getNodeName();
  }

  /// maps ns => full/namespace/urn
  Map<String, String> namespaceMap = {};
  /// maps full/namespace/urn => ns
  Map<String, String> pathToNamespaceMap = {};

  updateNamespaces(XmlNode node) {
    List<XmlAttribute> xmlAttributes = collectParentAttributes(node);
    RegExp re = new RegExp(r'xmlns:(\w+)="([\w\W]+)"');
    xmlAttributes.removeWhere((attribute) => !re.hasMatch(attribute.toString()));

    this.namespaceMap = {};
    xmlAttributes.forEach((attribute) {
      re.allMatches(attribute.toString()).forEach((match) {
        String name = match.group(1);
        String path = match.group(2);
        namespaceMap[name] = path;
        pathToNamespaceMap[path] = name;
      });
    });
  }

  List<XmlAttribute> collectParentAttributes(XmlNode node) {
    List<XmlAttribute> attributes = [];

    // If node is XMlDocument take attributes from first child node
    if (node is XmlDocument) {
      var child = node.children.first;
      if (child.toString().startsWith('<?xml')) {
        child = child.nextSibling;
      }
      while (child != null && child.text.trim() == '') {
        child = child.nextSibling;
      }
      if (child != null) {
        node = child;
      }
    }

    attributes.addAll(node.attributes);

    if (node.hasParent && !(node.parent is XmlDocument)) {
      var parentAttributes = collectParentAttributes(node.parent);
      parentAttributes.removeWhere((attribute) => attributes.indexOf(attribute) != -1);
      attributes.addAll(parentAttributes);
    }
    return attributes;
  }

  List<T> parse(XmlNode node) {
    this.updateNamespaces(node);
    List<T> list = [];

    (node as XmlElement).findAllElements(this.getFullName()).forEach((element) {
      list.add(parseSingle(element));
    });

    return list;
  }

  T parseSingle(XmlNode node, {bool rescanNs = false});
}