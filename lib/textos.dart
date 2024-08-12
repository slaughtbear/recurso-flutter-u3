import 'package:flutter/material.dart';  // Importa el paquete de Material Design para usar widgets y estilos de Flutter

// Define una clase llamada 'Textos' que extiende StatelessWidget
class Textos extends StatelessWidget {
  // Constructor de la clase, que recibe un parámetro llamado 'temp' que es obligatorio
  const Textos({super.key, required this.temp});

  // Parámetro que almacena la temperatura; puede ser nulo
  final double? temp;

  // Método que construye la interfaz de usuario del widget
  @override
  Widget build(BuildContext context) {
    // Verifica el valor de 'temp' y retorna un widget diferente según el rango de temperatura

    if (temp! <= 0) {  // Si la temperatura es menor o igual a 0
      return Container(  // Retorna un widget Container
        padding: const EdgeInsets.all(8),  // Aplica un padding de 8 píxeles en todos los lados
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,  // Forma rectangular para el contenedor
          color: Colors.lightBlue,  // Color de fondo azul claro
          borderRadius: BorderRadius.circular(10),  // Bordes redondeados con radio de 10 píxeles
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,  // Centra el contenido horizontalmente
          children: [
            Text(
              "Hace frio",  // Texto que se mostrará
              style: const TextStyle(
                fontSize: 15,  // Tamaño de fuente de 15 píxeles
                fontWeight: FontWeight.bold,  // Fuente en negrita
              ),
            ),
          ],
        ),
      );
    } else if (temp! > 0 && temp! <= 30) {  // Si la temperatura está entre 0 y 30 grados
      return Container(  // Retorna un widget Container
        padding: const EdgeInsets.all(8),  // Aplica un padding de 8 píxeles en todos los lados
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,  // Forma rectangular para el contenedor
          color: Colors.lightGreen,  // Color de fondo verde claro
          borderRadius: BorderRadius.circular(10),  // Bordes redondeados con radio de 10 píxeles
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,  // Centra el contenido horizontalmente
          children: [
            Text(
              "La temperatura está agradable",  // Texto que se mostrará
              style: const TextStyle(
                fontSize: 15,  // Tamaño de fuente de 15 píxeles
                fontWeight: FontWeight.bold,  // Fuente en negrita
              ),
            ),
          ],
        ),
      );
    } else {  // Si la temperatura es mayor a 30 grados
      return Container(  // Retorna un widget Container
        padding: const EdgeInsets.all(8),  // Aplica un padding de 8 píxeles en todos los lados
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,  // Forma rectangular para el contenedor
          color: Colors.red,  // Color de fondo rojo
          borderRadius: BorderRadius.circular(10),  // Bordes redondeados con radio de 10 píxeles
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,  // Centra el contenido horizontalmente
          children: [
            Text(
              "La temperatura está muy alta",  // Texto que se mostrará
              style: const TextStyle(
                fontSize: 15,  // Tamaño de fuente de 15 píxeles
                fontWeight: FontWeight.bold,  // Fuente en negrita
              ),
            ),
          ],
        ),
      );
    }
  }
}
