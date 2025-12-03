import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class NiveladorScreen extends StatefulWidget {
  const NiveladorScreen({super.key});

  @override
  State<NiveladorScreen> createState() => _NiveladorScreenState();
}

class _NiveladorScreenState extends State<NiveladorScreen> {
  // Coordenadas de la "burbuja"
  double x = 0;
  double y = 0;
  
  // Suscripción al sensor
  StreamSubscription<AccelerometerEvent>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    // Escuchar el acelerómetro
    _streamSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        // Invertimos y escalamos para que se mueva como una burbuja real
        // (Si inclinas a la derecha, la burbuja sube a la izquierda)
        x = -event.x * 20; 
        y = event.y * 20;
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determinar si está nivelado (cerca del centro)
    bool isLevel = x.abs() < 5 && y.abs() < 5;
    Color bubbleColor = isLevel ? Colors.green : Colors.red;
    String statusText = isLevel ? "¡Perfecto! 🌱" : "Nivélame ⚠️";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nivelador de Maceta 📏'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statusText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: bubbleColor,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
                color: Colors.grey[200],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Centro objetivo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                  ),
                  // Burbuja móvil
                  Transform.translate(
                    offset: Offset(x, y),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bubbleColor.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color: bubbleColor.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Coloca tu celular sobre la tierra de la maceta para verificar que esté plana y el agua se distribuya bien.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
