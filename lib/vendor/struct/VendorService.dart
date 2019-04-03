import 'package:meta/meta.dart';

class VendorServiceFactory {

  List<VendorService> _serviceTypes;

}

abstract class VendorService {

  final bool isNetworkService;

  VendorServiceStatus status;
  VendorServiceState state;

  VendorService({
    @required this.isNetworkService,

    this.status,
    this.state
  });

}

enum VendorServiceStatus {

  /// If the service is not performing any action, AND the app is NOT
  /// authenticated with the service, this status should be used.
  /// This is the default [VendorServiceStatus].
  IDLE,

  /// This status should be used whilst the service is preparing to connect.
  /// For example, when performing checks to see if the service
  /// is online.
  ///
  /// THIS IS NOT FOR AUTHENTICATION. For that, you should use
  /// [VendorServiceStatus.AUTHENTICATING] instead.
  INITIALIZING,

  /// This status is used whilst performing authentication checks with the
  /// service.
  ///
  /// If authentication fails, the status should be returned to
  /// [VendorServiceStatus.IDLE] and an error should be shown.
  ///
  /// If authentication succeeds, the status should be set to
  /// [VendorServiceStatus.PROCESSING] or [VendorServiceStatus.IDLE], as
  /// applicable.
  AUTHENTICATING,

  /// When the service is performing an action, such as searching for content,
  /// this status should be used.
  PROCESSING,

  /// When the service has completed an action BUT the result has not yet
  /// been used, this status should be used.
  /// Once the result has been used, the status should be set to
  /// [VendorServiceStatus.IDLE].
  DONE

}

class VendorServiceState {

  ///
  /// Progress is a percentage expressed in decimal form of the current
  /// action that is being performed by the [VendorService].
  /// (i.e. from 0.0 to 1.0.)
  ///
  double progress;

  ///
  /// This is a human-readable message describing the current state
  /// of the [VendorService].
  ///
  String statusMessage;

}