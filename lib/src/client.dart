import 'package:caldav/src/xml/webdavresponse_parser.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart' as http_auth;
import 'dart:developer' as developer;

import './objects.dart';

class WebDavException implements Exception {
  String cause;

  WebDavException(this.cause);
}

class CalDavClient extends http_auth.BasicAuthClient {
  String host;
  int port;
  String username;
  String password;
  String protocol;
  String path;
  String baseUrl;

  CalDavClient(
      String host,
      String username,
      String password,
      String path,
      {String protocol = 'http', int port, http.BaseClient httpClient}
  ): super(username, password, inner: httpClient) {
    this.baseUrl = "$protocol://$host";
    if (port != null) {
      this.baseUrl = "$protocol://$host:$port";
    }

    // BaseURL must not end with /
    if (this.baseUrl.endsWith('"')) {
      this.baseUrl = this.baseUrl.substring(0, this.baseUrl.length-1);
    }

    this.path = path;
    if (this.path.isNotEmpty && this.path != '"') {
      this.baseUrl = [this.baseUrl, this.path].join('/');
    }
  }

  String getUrl(String path) {
    path = path.trim();

    if (path.startsWith('/')) {
      path = path.substring(1, path.length);
    }

    return [this.baseUrl, path].join('/');
  }

  /// send the request with given [method] and [path]
  Future<http.Response> _send(
      String method, String path, {String body, Map<String, String> headers}) async {
    String url = this.getUrl(path);
    var request = http.Request(method, Uri.parse(url));

    if (headers != null) request.headers.addAll(headers);
    if (body != null) {
      request.body = body;
    }

    developer.log("Connecting to $url");
    return http.Response.fromStream(await this.send(request));
  }

  /// @deprecated Use getWebDavResponse instead
  Future<List<WebDavResponse>> getWebDavResponses(String remotePath, {String body}) async {
    remotePath = sanitizePath(remotePath);
    Map<String, String> userHeader = {'Depth': '1'};
    http.Response response = await this
        ._send('PROPFIND', remotePath, headers: userHeader, body: body);
    if (response.statusCode == 301) {
      return this.getWebDavResponses(response.headers['location']);
    }

    var xmlDocument = xml.parse(response.body);
    return new WebDavResponseParser().parse(xmlDocument);
  }

  Future<WebDavResponse> getWebDavResponse(String remotePath, {String body}) async {
    remotePath = sanitizePath(remotePath);
    var responses = await this.getWebDavResponses(remotePath, body: body);
    return responses.firstWhere((response) => response.href == getFullPath(remotePath));
  }

  /// Removes API base path and leading and trailing slash of path string
  String sanitizePath(String path) {
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (path.startsWith(this.path)) {
      path = path.substring(this.path.length);
    }
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (path.endsWith('/')) {
      path = path.substring(0, path.length-1);
    }
    return path;
  }

  String getFullPath(String remotePath) {
    remotePath = sanitizePath(remotePath);
    return '/' + this.path + (remotePath.isNotEmpty ? '/' + remotePath : '') + '/';
  }

  WebDavProp findProperty(WebDavResponse response, WebDavProp property, {bool ignoreNamespace = false}) {
    for (var propStat in response.propStats) {
      for (var prop in propStat.props) {
        if ((!ignoreNamespace && prop == property) || (ignoreNamespace && prop.name == property.name)) {
          return prop;
        }
      }
    }
  }

  Future<List<WebDavCalendar>> getCalendars(String calendarPath) async {
    String body = '''<x0:propfind xmlns:x0="DAV:">
  <x0:prop>
    <x0:displayname/>
    <x0:principal-collection-set/>
  </x0:prop>
</x0:propfind>''';
    var responses = await this.getWebDavResponses(calendarPath, body: body);
    // Response object with href = this request does not have calendar information, remove it
    responses.removeWhere((response) => response.href == getFullPath(calendarPath));

    List<WebDavCalendar> list = [];
    responses.forEach((response) {
      var displayName = this.findProperty(response, new WebDavProp('displayname'));
      list.add(new WebDavCalendar(response.href, displayName.value.toString()));
    });

    return list;
  }

  void createCalendarEvent(String calendarPath) async {
    if (calendarPath.startsWith('/' + this.path)) {
      calendarPath = calendarPath.substring(this.path.length + 1);
    }

    String eventFileName = 'event-' + new DateTime.now().millisecondsSinceEpoch.toString();
    String calendarEntry = '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Example Corp.//CalDAV Client//EN
BEGIN:VEVENT
UID:20010712T182145Z-123401@example.com
DTSTAMP:20200212T182145Z
DTSTART:20200214T170000Z
DTEND:20200215T040000Z
SUMMARY:Test Event
END:VEVENT
END:VCALENDAR''';


    http.Response response = await this
        ._send('PUT', calendarPath + '/' + eventFileName + '.ics', body: calendarEntry, headers: {'Depth': '1'});
    if (response.statusCode == 301) {
      return this.createCalendarEvent(
          response.headers['location']
      );
    }

    String xml = response.body;
    developer.log(xml);
  }
}