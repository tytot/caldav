import 'package:xml/src/xml/nodes/node.dart';
import 'package:xml/src/xml/nodes/element.dart';
import 'package:xml/src/xml/nodes/text.dart';

import 'parser.dart';
import '../objects.dart';

class WebDavPropParser extends Parser<WebDavProp> {
  @override
  String getNodeNamespace() {
    return 'DAV:';
  }

  @override
  String getNodeName() {
    return 'prop';
  }

  @override
  WebDavProp parseSingle(XmlNode node, {bool rescanNs = false}) {
    if (rescanNs) {
      this.updateNamespaces(node);
    }

    XmlElement element = node as XmlElement;
    if (!this.namespaceMap.containsKey(element.name.prefix)) {
      throw new ArgumentError(
          'Unknown namespace ' + (element.name.prefix ?? 'null'));
    }
    String namespaceUri = this.namespaceMap[element.name.prefix]!;
    WebDavProp propObj =
        new WebDavProp(element.name.local, namespace: namespaceUri);

    List<WebDavProp> propList = <WebDavProp>[];

    for (var child in element.children) {
      if (child is XmlText) {
        propObj.value = child.toString();

        // for some reason during unit test it had 3 items with the first and last ones being line breaks
        // However this did not occur when testing with live data from NextCloud
        // that is why we'll continue with next child if trimmed value is empty.
        // if a non-empty text child occurs, its value will be returned instead.
        // if no child occurs it will return an empty value
        // Note that if a non-XmlText item occurs after an empty text value and no XmlText comes after that, the value will be a List of Non-XmlText items
        if (propObj.value.trim().isEmpty) {
          continue;
        }
        return propObj;
      }
      propList.add(parseSingle(child));
    }
    propObj.value = propList;
    return propObj;
  }
}
