library json_schema.browser;

import 'package:w_transport/src/browser_transport_platform.dart';
import 'package:w_transport/src/browser_transport_platform_with_sockjs.dart';
import 'package:w_transport/src/constants.dart' show v3Deprecation;
import 'package:w_transport/src/global_transport_platform.dart';

export 'package:w_transport/src/browser_transport_platform.dart'
    show BrowserTransportPlatform, browserTransportPlatform;
export 'package:w_transport/src/browser_transport_platform_with_sockjs.dart'
    show BrowserTransportPlatformWithSockJS, browserTransportPlatformWithSockJS;

/// Configures json_schema for use in the browser via dart:html.
void configureJsonSchemaForBrowser() {
  globalJsonSchema = browserJsonSchema;
}