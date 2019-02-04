import 'package:flutter/widgets.dart';
import 'package:kamino/vendor/struct/ClawsVendorConfiguration.dart';
import 'package:kamino/vendor/struct/LocalOfficialVendorConfiguration.dart';
import 'package:flutter_liquidcore/liquidcore.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';

/// A delegate for integrating with the claws-client.
class LocalOfficialVendorConfigurationDelegate
    extends LocalVendorConfiguration {
  ClawsVendorConfiguration _configuration;

  String uri;

  /// When developing, the [uri] can be http://localhost:8082/microserver.js.
  /// If you want to receive scraper updates without updating the app, you
  /// can try providing a bundled script hosted on github instead.
  LocalOfficialVendorConfigurationDelegate({this.uri = "@flutter_assets/assets/microserver.js"});

  @override
  void setVendorConfiguration(ClawsVendorConfiguration configuration) {
    this._configuration = configuration;
  }

  @override
  Future<MicroServiceSubscription> playMedia(
      String mediaType, Map<String, String> query, BuildContext context) async {

    bool disconnected = false;

    List sourceList = [];
    List<Future> futureList = [];

    String title = _configuration.formatTitle(mediaType,
      query['title'],
      query['releaseDate'],
      query['season'],
      query['episode'],
    );

    MicroService microService = new MicroService(this.uri);

    var subscription = new MicroServiceSubscription(microService);

    microService.onErrorListener = (service, error) {
      // An unexpected error occurred in the MicroService.
      // Log and disconnect the service.
      disconnect(service, context, 'An unexpected error occurred!');
      print('Unexpected microservice error: $error');
    };
    microService.onExitListener = (service, error) {
      disconnected = true;
    };
    await microService.addEventListener('disconnected',
        (service, event, eventPayload) {
      // The service has been disconnected from.
      disconnected = true;
    });
    await microService.addEventListener('ready',
        (service, event, eventPayload) {
      // The service is ready. Request links
      service.emit('request_links', {
        'type': mediaType,
        'query': query,
      });
    });
    await microService.addEventListener('result',
        (service, event, eventPayload) {
      if (eventPayload['event'] == 'result') {
        if (disconnected) {
          // Already received a disconnected, ignore further ones.
          return;
        }

        futureList.add(_configuration.onSourceFound(
            sourceList, eventPayload, context, subscription,
            title: title));
      }
    });
    await microService.addEventListener('error',
        (service, event, eventPayload) {
      print("error $event");
      if (!disconnected) {
        // Stop the server, an error occurred.
        disconnect(service, context, eventPayload.toString());
      }
    });
    await microService.addEventListener('done',
        (service, event, eventPayload) async {
      if (!disconnected) {
        await Future.wait(futureList);

        if (!disconnected) {
          print('All sources received');
          _configuration.onComplete(context, title, sourceList);
        }
      }
    });
    // Start the service.
    await microService.start();

    return subscription;
  }

  void disconnect(MicroService service, BuildContext context,
      [String message]) {
    service.emit('disconnected');
    if (message != null) {
      _configuration.showMessage('Error', message, context);
    }
  }
}

class MicroServiceSubscription extends VendorSubscription {
  MicroService _microService;

  MicroServiceSubscription(MicroService microService) {
    _microService = microService;
  }

  Future<dynamic> disconnect() {
    disconnected = true;

    if (_microService.isStarted) {
      return _microService.emit('disconnected');
    }

    // Disconnect was called too soon, disconnect as soon as
    // the service is started.
    _microService.onStartListener = (service) {
      service.emit('disconnected');
    };
    return null;
  }
}
