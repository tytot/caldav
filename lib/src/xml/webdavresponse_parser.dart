import 'package:caldav/src/xml/webdavpropstats_parser.dart';
import 'package:xml/src/xml/nodes/node.dart';
import 'package:xml/src/xml/nodes/document.dart';
import 'package:xml/src/xml/nodes/element.dart';
import '../objects.dart';
import './parser.dart';

class WebDavResponseParser extends Parser<WebDavResponse> {
  @override
  String getNodeNamespace() {
    return 'DAV:';
  }

  @override
  String getNodeName() {
    return 'response';
  }

  List<WebDavResponse> parse(XmlNode node) {
    this.updateNamespaces(node);
    List<WebDavResponse> list = [];

    XmlDocument document = node as XmlDocument;

    document.findAllElements(this.getFullName()).forEach((element) {
      list.add(parseSingle(element));
    });

    return list;
  }

  @override
  WebDavResponse parseSingle(XmlNode node, {bool rescanNs = false}) {
    if (rescanNs) {
      this.updateNamespaces(node);
    }
    XmlElement response = node as XmlElement;
    WebDavResponse responseObj = new WebDavResponse();

    // href is DAV:href
    String davNamespace = this.pathToNamespaceMap['DAV:'];
    responseObj.href =
        response.findElements(davNamespace + ':href').single.text;
    responseObj.propStats = new WebDavPropStatsParser().parse(response);
    return responseObj;
  }
}
