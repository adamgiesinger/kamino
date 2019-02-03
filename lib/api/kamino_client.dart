import 'dart:io';

import 'package:async/async.dart';
import 'package:http/http.dart';

/// HttpClient based off package:http's IOClient but with better error handling
/// for disconnections.
///
class KaminoHttpClient extends BaseClient {
  /// The underlying `dart:io` HTTP client.
  HttpClient _inner;

  Function _onError;

  KaminoHttpClient([HttpClient inner, Function onError]) : super() {
    _inner = inner ?? new HttpClient();
    _onError = onError;
  }

  /// Sends an HTTP request and asynchronously returns the response.
  Future<StreamedResponse> send(BaseRequest request) async {
    var stream = request.finalize();

    try {
      var ioRequest = await _inner.openUrl(request.method, request.url);

      ioRequest
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..contentLength =
            request.contentLength == null ? -1 : request.contentLength
        ..persistentConnection = request.persistentConnection;
      request.headers.forEach((name, value) {
        ioRequest.headers.set(name, value);
      });

      var response =
          await stream.pipe(DelegatingStreamConsumer.typed(ioRequest));
      var headers = <String, String>{};
      response.headers.forEach((key, values) {
        headers[key] = values.join(',');
      });

      Stream<List<int>> streamResponse =
          DelegatingStream.typed<List<int>>(response).handleError(
              _onError ??
                  (error) {
                    throw new ClientException(error.message, error.uri);
                  },
              test: (error) => error is HttpException);

      return new StreamedResponse(streamResponse, response.statusCode,
          contentLength:
              response.contentLength == -1 ? null : response.contentLength,
          request: request,
          headers: headers,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase);
    } on HttpException catch (error) {
      throw new ClientException(error.message, error.uri);
    }
  }

  /// Closes the client. This terminates all active connections. If a client
  /// remains unclosed, the Dart process may not terminate.
  void close({bool force: true}) {
    if (_inner != null) {
      _inner.close(force: force);
    }
    _inner = null;
  }
}