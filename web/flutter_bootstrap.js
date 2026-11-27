{{flutter_js}}
{{flutter_build_config}}

// Append a cache-busting query so mobile browsers never run stale bundles.
if (window._flutter && _flutter.buildConfig && Array.isArray(_flutter.buildConfig.builds)) {
  var cacheBust = Date.now();
  _flutter.buildConfig.builds.forEach(function (build) {
    if (build && build.mainJsPath && build.mainJsPath.indexOf('?') === -1) {
      build.mainJsPath = build.mainJsPath + '?v=' + cacheBust;
    }
  });
}

_flutter.loader.load();
