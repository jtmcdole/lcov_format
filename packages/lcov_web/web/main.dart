// The entrypoint for the **client** environment.
//
// This file is compiled to javascript and executed in the browser.

// Client-specific jaspr import.
import 'package:jaspr/browser.dart';
// Imports the [App] component.
import 'package:lcov_web/app.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    print('${record.loggerName}: ${record.message}');
  });

  // Attaches the [App] component to the <body> of the page.
  runApp(App());
}
