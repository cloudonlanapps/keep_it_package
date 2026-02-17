// AI Server Service - AI server connection and session management
//
// This service provides AI-specific server connectivity including
// socket connections for real-time face recognition tasks.

// Export builders
export 'builders/get_active_ai_server.dart' show GetActiveAIServer;
export 'builders/get_server_session.dart' show GetServerSession;
// Export providers
export 'providers/active_ai_server.dart' show activeAIServerProvider;
export 'providers/socket_connection.dart'
    show SocketConnectionNotifier, socketConnectionProvider;
