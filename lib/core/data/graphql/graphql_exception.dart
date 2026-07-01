import 'package:graphql/client.dart';

enum GraphQLFailureKind {
  network,
  unauthorized,
  server,
  schema,
  cache,
  unknown,
}

class AppGraphQLException implements Exception {
  AppGraphQLException({
    required this.kind,
    required this.message,
    required this.operationException,
  });

  final GraphQLFailureKind kind;
  final String message;
  final OperationException operationException;

  @override
  String toString() => 'AppGraphQLException($kind): $message';
}

void validateGraphQLResult(QueryResult result) {
  if (result.hasException) {
    throw normalizeGraphQLException(result.exception!);
  }
}

AppGraphQLException normalizeGraphQLException(OperationException exception) {
  final authError = _findAuthGraphQLError(exception.graphqlErrors);
  if (authError != null) {
    return AppGraphQLException(
      kind: GraphQLFailureKind.unauthorized,
      message: authError.message,
      operationException: exception,
    );
  }

  final linkException = exception.linkException;
  if (linkException != null) {
    return AppGraphQLException(
      kind: _classifyLinkException(linkException),
      message: _messageForLinkException(linkException),
      operationException: exception,
    );
  }

  if (exception.graphqlErrors.isNotEmpty) {
    return AppGraphQLException(
      kind: GraphQLFailureKind.schema,
      message: exception.graphqlErrors.map((e) => e.message).join('\n'),
      operationException: exception,
    );
  }

  return AppGraphQLException(
    kind: GraphQLFailureKind.unknown,
    message: exception.toString(),
    operationException: exception,
  );
}

GraphQLFailureKind _classifyLinkException(LinkException exception) {
  if (exception is NetworkException) {
    return GraphQLFailureKind.network;
  }
  if (exception is ServerException) {
    final statusCode = exception.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return GraphQLFailureKind.unauthorized;
    }
    return GraphQLFailureKind.server;
  }
  if (exception is ResponseFormatException ||
      exception is UnexpectedResponseStructureException ||
      exception is MismatchedDataStructureException) {
    return GraphQLFailureKind.schema;
  }
  if (exception is CacheMissException ||
      exception is CacheMisconfigurationException) {
    return GraphQLFailureKind.cache;
  }
  return GraphQLFailureKind.unknown;
}

String _messageForLinkException(LinkException exception) {
  if (exception is NetworkException) {
    return exception.message ??
        'Unable to connect to the server. Check the server address and network.';
  }
  if (exception is ServerException) {
    final statusCode = exception.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return 'The server rejected the current credentials.';
    }
    if (statusCode != null) {
      return 'The server returned HTTP $statusCode.';
    }
    return 'The server returned an invalid GraphQL response.';
  }
  if (exception is ResponseFormatException ||
      exception is UnexpectedResponseStructureException ||
      exception is MismatchedDataStructureException) {
    return 'The server response did not match the expected GraphQL format.';
  }
  if (exception is CacheMissException ||
      exception is CacheMisconfigurationException) {
    return 'The local GraphQL cache could not satisfy the request.';
  }
  return exception.toString();
}

GraphQLError? _findAuthGraphQLError(List<GraphQLError> errors) {
  for (final error in errors) {
    final code = error.extensions?['code']?.toString().toUpperCase();
    if (code == 'UNAUTHENTICATED' ||
        code == 'UNAUTHORIZED' ||
        code == 'FORBIDDEN') {
      return error;
    }
    final message = error.message.toLowerCase();
    if (message.contains('unauthorized') ||
        message.contains('unauthenticated') ||
        message.contains('forbidden')) {
      return error;
    }
  }
  return null;
}
