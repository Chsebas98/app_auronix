# Arquitectura General del Sistema Ando-UI

Ando-UI es la aplicación cliente móvil desarrollada en **Flutter 3.44 / Dart 3.12**. Consume los servicios del backend existente `micro-auronix` (Spring Boot 3, Java 21) mediante:
1. **API REST (HTTP/JSON)**: Para autenticación, gestión de perfil, creación de solicitudes de viaje (con cabecera obligatoria `Idempotency-Key`) e historial.
2. **WebSockets (STOMP/WS)**: Canales bidireccionales dedicados para transmisión de posición GPS del conductor/cliente y actualización en tiempo real del ciclo de vida del viaje (`SOLICITADO` -> `OFERTADO` -> `ACEPTADO` -> `EN_CURSO` -> finalizado). En el ambiente de desarrollo local se utiliza conexión directa no segura (`ws://`), mientras que en entornos remotos de staging y producción la configuración conmuta a transporte cifrado (`wss://`) con certificados SSL según las variables de entorno inyectadas.

La arquitectura cliente utiliza **Clean Architecture Feature-First** con patrón **BLoC** para la gestión de estado reactiva y **Atomic Design** en los componentes visuales de presentación.
