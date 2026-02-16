// Server Service - Network and authentication management
//
// This service provides server connection, authentication, and network scanning
// functionality. All models come from cl_server_dart_client package.

// Export models from cl_server_dart_client (package exports first)
export 'package:cl_server_dart_client/cl_server_dart_client.dart'
    show
        CLServer,
        CLSocket,
        NetworkScanner,
        RESTAPi,
        RemoteServiceLocationConfig,
        Server,
        ServerHealthStatus,
        ServerPreferences;

// Export builders
export 'builders/get_active_a_i_server.dart' show GetActiveAIServer;
export 'builders/get_auth_status.dart'
    show AuthActions, AuthStatusData, GetAuthStatus;
export 'builders/get_available_servers.dart' show GetAvailableServers;
export 'builders/get_nw_scanner.dart' show GetNetworkScanner;
export 'builders/get_server_session.dart' show GetServerSession;

// Export providers
export 'providers/active_ai_server.dart' show activeAIServerProvider;
export 'providers/available_servers.dart' show availableServersProvider;
export 'providers/network_scanner.dart' show networkScannerProvider;
export 'providers/server_health_check.dart' show serverHealthCheckProvider;
export 'providers/server_preference.dart' show serverPreferenceProvider;
export 'providers/server_provider.dart' show serverProvider;
export 'providers/socket_connection.dart'
    show SocketConnectionNotifier, socketConnectionProvider;
