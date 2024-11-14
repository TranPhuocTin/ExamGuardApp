import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  void initSocket({String? teacherId}) {
    socket = IO.io('https://exam-guard-server.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'teacherId': teacherId},
    });

    socket.connect();

    socket.onConnect((_) {
      print('Socket connected');
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });

    socket.onError((error) {
      print('Socket error: $error');
    });
  }

  void disconnect() {
    socket.disconnect();
  }
} 