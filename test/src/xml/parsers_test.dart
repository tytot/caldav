import 'package:caldav/src/xml/webdavresponse_parser.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../../_fixtures/caldav_data.dart' as data;
import 'package:caldav/src/objects.dart';
import 'package:caldav/src/types.dart' as types;

void main() {
  test('parse XML into objects', () {
    var xmlDocument = XmlDocument.parse(data.nextCloudCurrentUser);

    WebDavResponseParser parser = new WebDavResponseParser();
    var result = parser.parse(xmlDocument);
    expect(result.length, 3);
    expect(result.elementAt(0).href, '/remote.php/caldav/');
    expect(result.elementAt(1).href, '/remote.php/caldav/principals/');
    expect(result.elementAt(2).href, '/remote.php/caldav/calendars/');

    expect(result.elementAt(0).propStats.length, 1);

    var propStat = result.elementAt(0).propStats.elementAt(0);
    var currentUserPrincipal = propStat.props.firstWhere((prop) {
      return prop.name == 'current-user-principal' && prop.namespace == 'DAV:';
    });
    var href = currentUserPrincipal.value as List<WebDavProp>;
    var hrefObj = href.firstWhere(types.isHrefProp);
    expect(hrefObj.value, '/remote.php/caldav/principals/saitho/');
  });

  test('collect namespaces into a Map', () {
    var xmlDocument = XmlDocument.parse(data.nextCloudCurrentUser);

    WebDavResponseParser parser = new WebDavResponseParser();
    parser.parse(xmlDocument);

    expect(parser.namespaceMap.length, 4);
    expect(parser.namespaceMap['d'], 'DAV:');
    expect(parser.namespaceMap['s'], 'http://sabredav.org/ns');
    expect(parser.namespaceMap['cal'], 'urn:ietf:params:xml:ns:caldav');
    expect(parser.namespaceMap['cs'], 'http://calendarserver.org/ns/');
  });
}
