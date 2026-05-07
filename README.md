# 🐜 EDF: Iron Rain - VOIP Master Patcher (Host Stutter Fix)

<img width="792" height="697" alt="image" src="https://github.com/user-attachments/assets/d3bd31e5-7d9a-4039-b136-5b0d535975dc" />


![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)
![Unreal Engine 4](https://img.shields.io/badge/Engine-UE4-white.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

Una herramienta avanzada con Interfaz Gráfica (GUI) escrita en PowerShell para solucionar el infame problema de **congelamiento y stuttering severo al ser Host** en el modo multijugador de *Earth Defense Force: Iron Rain* en PC.

## 🛑 El Problema
En *EDF: Iron Rain*, al crear una partida (ser el Host), el motor Unreal Engine 4 fuerza la activación del chat de voz. El hilo principal del motor se satura intentando capturar y procesar el micrófono cada pocos segundos, lo que provoca tirones masivos y caídas de FPS, haciendo el juego injugable en cooperativo.

## 🛠️ La Solución
Esta herramienta parchea dinámicamente el archivo `Engine.ini` del juego, inyectando directivas a nivel de motor para modificar o amputar el subsistema de voz (VOIP), bloqueando el archivo con permisos de "Solo Lectura" para que el juego no pueda sobrescribir los cambios.

### Modos de Operación:
1. **VOIP KILLER (Recomendado):** Desactiva por completo el subsistema de voz y red de Steam. Garantiza cero tirones al ser Host. Ideal si usas Discord.
2. **VOIP RESCUE V1:** Mantiene el micrófono activo, pero fuerza al motor a procesar el audio en hilos de fondo (Background Threads).
3. **VOIP RESCUE V2:** Mantiene el micrófono activo, pero desactiva la cancelación de eco y reduce el muestreo a 8000Hz para aliviar la carga de la CPU.

## 🚀 Instalación y Uso

**Opción A: Usar el Script (.ps1)**
1. Descarga el archivo `IronRain_VOIP_Patcher.ps1`.
2. Haz clic derecho sobre él y selecciona **"Ejecutar con PowerShell"**.
3. El script pedirá permisos de Administrador automáticamente.

**Opción B: Compilar a .EXE**
El código fuente está diseñado con un sistema de auto-elevación híbrido. Puedes usar herramientas como `PS2EXE` para convertirlo en un ejecutable estándar de Windows.

## 🔄 Restauración
La herramienta incluye un botón de "Restaurar" que elimina todos los parches de VOIP inyectados y devuelve los permisos originales al archivo `Engine.ini`.

## 🤝 Contribuciones
¡Las Pull Requests son bienvenidas! Si encuentras nuevos comandos de UE4 que mejoren la estabilidad de la red sin sacrificar el audio, no dudes en aportar.
