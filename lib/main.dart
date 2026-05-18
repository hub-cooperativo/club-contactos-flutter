import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// =========================================================================
// 1. INICIALIZACIÓN DE LA APP Y CONEXIÓN A SUPABASE
// =========================================================================

void main() async {
  // Asegura que los bindings de Flutter estén listos antes de inicializar Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos Supabase con la URL y la Anon Key provistas para tu proyecto
  await Supabase.initialize(
    url: 'https://kkppqachcvzskhoyxdsj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrcHBxYWNoY3Z6c2tob3l4ZHNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwNDU0NDQsImV4cCI6MjA5NDYyMTQ0NH0.LzqG6F5jiRaV8ov9Y8IaL7Zv7r6TwaiHwwaZPArjHlQ',
  );

  runApp(const MyApp());
}

// Clase principal que configura el diseño y tema visual de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Contactos Club',
      debugShowCheckedModeBanner: false, // Quita la etiqueta 'Debug' de la esquina
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Usa el diseño moderno Material 3 de Google
      ),
      home: const FormularioContacto(),
    );
  }
}

// =========================================================================
// 2. FORMULARIO DE REGISTRO (CON ESTADO DINÁMICO)
// =========================================================================

class FormularioContacto extends StatefulWidget {
  const FormularioContacto({super.key});

  @override
  State<FormularioContacto> createState() => _FormularioContactoState();
}

class _FormularioContactoState extends State<FormularioContacto> {
  // Llave global para validar el estado del formulario de forma segura
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar y manipular el texto que escribe el usuario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  // Variable de estado para mostrar un indicador de carga mientras guarda
  bool _estaCargando = false;

  // Acceso directo al cliente oficial de Supabase
  final _supabaseClient = Supabase.instance.client;

  // Método asíncrono para enviar los datos a Supabase
  Future<void> _guardarContacto() async {
    // Si el formulario no pasa las validaciones visuales, detenemos la ejecución
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _estaCargando = true; // Activa el círculo de progreso
    });

    try {
      // Obtenemos los valores limpios (sin espacios en blanco extras)
      final nombre = _nombreController.text.trim();
      final email = _emailController.text.trim();
      final telefono = _telefonoController.text.trim();

      // Enviamos el insert a la tabla 'contactos' usando los nombres de columna exactos:
      // - nombre
      // - telefono
      // - email
      await _supabaseClient.from('contactos').insert({
        'nombre': nombre,
        'telefono': telefono,
        'email': email,
      });

      // Si todo sale bien, notificamos con un mensaje verde de éxito
      _mostrarMensaje('¡Contacto registrado exitosamente!', Colors.green);

      // Limpiamos las cajas de texto de la interfaz
      _nombreController.clear();
      _emailController.clear();
      _telefonoController.clear();

    } catch (error) {
      // En caso de error (ej. desconexión o violación de reglas), mostramos un mensaje rojo
      _mostrarMensaje('Error al guardar: $error', Colors.red);
    } finally {
      setState(() {
        _estaCargando = false; // Desactiva el círculo de progreso
      });
    }
  }

  // Función interna para renderizar barras de notificación en la pantalla (Snackbars)
  void _mostrarMensaje(String mensaje, Color colorFondo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        backgroundColor: colorFondo,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Liberamos los controladores de memoria al cerrar la vista para evitar fugas de rendimiento
  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // =========================================================================
  // 3. DISEÑO VISUAL DE LA PANTALLA (INTERFAZ)
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fondo sutil para dar contraste a la tarjeta
      appBar: AppBar(
        title: const Text('AI Quick Wins - Registro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Bordes redondeados elegantes
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey, // Asignamos nuestra llave de validación
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono decorativo de contactos
                    Icon(Icons.contact_mail_rounded, size: 64, color: Colors.deepPurple[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Nuevo Contacto',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Sincronizado directo con Supabase',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Divider(height: 32),

                    // --- Campo: Nombre ---
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Campo: Teléfono ---
                    TextFormField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone, // Muestra el teclado numérico en móviles
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu teléfono';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Campo: Email ---
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress, // Teclado optimizado con el arroba @
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu correo';
                        }
                        // Validación simple de patrón de email
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                          return 'Ingresa un formato de correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // --- Botón de Enviar o Indicador de Carga ---
                    _estaCargando
                        ? const CircularProgressIndicator() // Si carga, muestra círculo de espera
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _guardarContacto, // Dispara la función asíncrona
                              icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                              label: const Text(
                                'Guardar en Supabase',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}