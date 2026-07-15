class AppConfig {
  // Dirección IP real de tu computadora para que el celular físico pueda conectarse
  // Para el emulador de Android usa 10.0.2.2, para celular real usa tu IP (192.168.1.108)
  static const String baseUrl = "http://192.168.1.108:8080/api";
  
  static String? userEmail;
  static String? userName;
  static String? userId;
}
