class BasicWebDavObject {
  String path;

  BasicWebDavObject(this.path);

  @override
  String toString() {
    return 'BasicWebDavObject{path: $path}';
  }
}

class WebDavResource extends BasicWebDavObject {
  WebDavResourceType resourceType;

  WebDavResource(path, this.resourceType) : super(path);

  @override
  String toString() {
    return 'WebDavResource{path: $path, resourceType: $resourceType}';
  }
}

class WebDavResponse {
  late String href;
  late List<WebDavPropStat> propStats;
}

class WebDavProp {
  String name;
  String namespace;
  dynamic value; // string or List<WebDavProp>

  WebDavProp(this.name, {this.namespace = 'DAV:'});

  @override
  String toString() {
    return 'WebDavProp{name: $name, namespace: $namespace, value: ${value.toString()}';
  }

  @override
  bool operator ==(o) {
    return o is WebDavProp && name == o.name && namespace == o.namespace;
  }

  WebDavResourceType toWebDavResourceType() {
    return new WebDavResourceType(name, namespace: namespace);
  }
}

class WebDavPropStat {
  List<WebDavProp> props = [];

  addProp(WebDavProp prop) {
    this.props.add(prop);
  }
}

class WebDavCalendar {
  String path;
  String ctag;
  String displayName;

  WebDavCalendar(this.path, this.ctag, this.displayName);

  @override
  String toString() {
    return '$displayName $ctag (path: $path)';
  }
}

class WebDavEntry {
  String path;
  String etag;
  String? data;

  WebDavEntry(this.path, this.etag, this.data);

  @override
  String toString() {
    return '$etag (path: $path)';
  }
}

class WebDavResourceType {
  String name;
  String namespace;
  WebDavResourceType(this.name, {this.namespace = 'DAV:'});

  String toString() {
    return 'WebDavResourceType{name: $name, namespace: $namespace}';
  }

  String toXmlName() {
    return this.namespace + ':' + this.name;
  }
}
