import 'package:caldav/src/xml/webdavprop_parser.dart';
import 'package:xml/src/xml/nodes/node.dart';
import 'package:xml/src/xml/nodes/element.dart';
import 'package:xml/src/xml/nodes/text.dart';

import 'parser.dart';
import '../objects.dart';

class WebDavPropStatsParser extends Parser<WebDavPropStat> {
  WebDavPropParser propParser = new WebDavPropParser();

  @override
  String getNodeNamespace() {
    return 'DAV:';
  }

  @override
  String getNodeName() {
    return 'propstat';
  }

  @override
  WebDavPropStat parseSingle(XmlNode node, {bool rescanNs = false}) {
    XmlElement propStat = node as XmlElement;
    if (rescanNs) {
      this.updateNamespaces(node);
    }

    // todo: think about skipping if HTTP status for propStat is not 200

    WebDavPropStat propStatObj = new WebDavPropStat();
    // prop is DAV:prop
    String davNamespace = this.pathToNamespaceMap['DAV:'];
    propStat.findElements(davNamespace + ':prop').forEach((prop) {
      prop.children.forEach((child) {
        if (child is XmlText) {
          return;
        }
        propStatObj.addProp(propParser.parseSingle(child, rescanNs: true));
      });
    });

    return propStatObj;
  }
}