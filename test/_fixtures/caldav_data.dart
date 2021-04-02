/// Result of request to webdav base url with body <x0:propfind xmlns:x0="DAV:"><x0:prop><x0:current-user-principal/></x0:prop></x0:propfind>
String nextCloudCurrentUser = '''<?xml version="1.0"?>
<d:multistatus xmlns:d="DAV:" xmlns:s="http://sabredav.org/ns" xmlns:cal="urn:ietf:params:xml:ns:caldav" xmlns:cs="http://calendarserver.org/ns/">
    <d:response>
        <d:href>/remote.php/caldav/</d:href>
        <d:propstat>
            <d:prop>
                <d:current-user-principal>
                    <d:href>/remote.php/caldav/principals/saitho/</d:href>
                </d:current-user-principal>
            </d:prop>
            <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
    </d:response>
    <d:response>
        <d:href>/remote.php/caldav/principals/</d:href>
        <d:propstat>
            <d:prop>
                <d:current-user-principal>
                    <d:href>/remote.php/caldav/principals/saitho/</d:href>
                </d:current-user-principal>
            </d:prop>
            <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
    </d:response>
    <d:response>
        <d:href>/remote.php/caldav/calendars/</d:href>
        <d:propstat>
            <d:prop>
                <d:current-user-principal>
                    <d:href>/remote.php/caldav/principals/saitho/</d:href>
                </d:current-user-principal>
            </d:prop>
            <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
    </d:response>
</d:multistatus>''';

/// Result of a request to user principal url with body <x0:propfind xmlns:x0="DAV:"><x0:prop><x1:calendar-home-set xmlns:x1="urn:ietf:params:xml:ns:caldav"/></x0:prop></x0:propfind>
String nextCloudUserHomeCalendar = '''<?xml version="1.0"?>
<d:multistatus xmlns:d="DAV:" xmlns:s="http://sabredav.org/ns" xmlns:cal="urn:ietf:params:xml:ns:caldav" xmlns:cs="http://calendarserver.org/ns/" xmlns:card="urn:ietf:params:xml:ns:carddav" xmlns:oc="http://owncloud.org/ns" xmlns:nc="http://nextcloud.org/ns">
    <d:response>
        <d:href>/remote.php/dav/principals/users/saitho/</d:href>
        <d:propstat>
            <d:prop>
                <cal:calendar-home-set>
                    <d:href>/remote.php/dav/calendars/saitho/</d:href>
                </cal:calendar-home-set>
            </d:prop>
            <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
    </d:response>
    <d:response>
        <d:href>/remote.php/dav/principals/users/saitho/calendar-proxy-read/</d:href>
        <d:propstat>
            <d:prop>
                <cal:calendar-home-set>
                    <d:href>/remote.php/dav/calendars/calendar-proxy-read/</d:href>
                </cal:calendar-home-set>
            </d:prop>
            <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
    </d:response>
    <d:response>
        <d:href>/remote.php/dav/principals/users/saitho/calendar-proxy-write/</d:href>
        <d:propstat>
            <d:prop>
                <cal:calendar-home-set>
                    <d:href>/remote.php/dav/calendars/calendar-proxy-write/</d:href>
                </cal:calendar-home-set>
            </d:prop>
            <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
    </d:response>
</d:multistatus>''';
