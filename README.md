# 📍 Campus Geo Audit – Flutter

**Autor:** Christian Salinas

---

## 🧭 Descripción del Proyecto

Este proyecto es una aplicación móvil desarrollada en **Flutter** que implementa un sistema de detección de proximidad basado en GPS utilizando una arquitectura eficiente y sostenible.

El objetivo es demostrar cómo una app geoespacial puede:

* Obtener ubicación del usuario de forma optimizada
* Detectar cercanía a un punto de interés (POI)
* Reducir consumo energético
* Evitar reconstrucciones innecesarias de UI
* Preparar la carga diferida (lazy loading) de recursos pesados como modelos 3D

Todo esto aplicando principios de **software verde** 🌱.

---

## ⚙️ Tecnologías Utilizadas

| Tecnología                | Uso                              |
| ------------------------- | -------------------------------- |
| Flutter                   | Desarrollo multiplataforma       |
| Riverpod                  | Gestión de estado sin `setState` |
| Geolocator                | Obtención de ubicación           |
| Path Provider             | Cache local                      |
| HTTP                      | Descarga de modelos remotos      |
| Android Location Services | GPS del sistema                  |

---

## 🧠 Arquitectura Implementada

El proyecto utiliza una arquitectura desacoplada basada en:

### 🔹 Repository Pattern

Encapsula la lógica de ubicación para evitar mezclar UI con lógica del sistema.

### 🔹 Riverpod State Management

Permite:

* Evitar rebuilds innecesarios
* Reducir uso de CPU
* Prevenir memory leaks
* Cancelar streams automáticamente

### 🔹 Event-Based Location

Se utilizan streams del sistema en lugar de polling manual.

Esto significa:

✔ Menor consumo de batería
✔ Menor uso de CPU
✔ Mayor estabilidad

---

## 📏 Funcionalidad Principal

La aplicación:

1. Solicita permisos de ubicación
2. Verifica si el GPS está activo
3. Escucha cambios de posición del usuario
4. Calcula la distancia hacia un Punto de Interés (POI)
5. Determina si el usuario está dentro de un radio de **50 metros**

Cuando el usuario entra en ese radio:

➡️ Se activa la lógica de carga diferida (lazy loading)

Esto permite que recursos pesados como modelos `.glb` solo se descarguen cuando sean necesarios.

---

## 🌱 Optimización Energética

Se aplicaron las siguientes estrategias:

* Uso de `LocationAccuracy.low` en modo normal
* `distanceFilter` para evitar actualizaciones constantes
* Streams del sistema en lugar de polling continuo
* Cancelación automática de listeners

Esto reduce:

🔋 Consumo de batería
📡 Uso innecesario del GPS
🧠 Uso de CPU

---

## 📦 Instalación

### 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/TU_USUARIO/campus-geo-audit.git
cd campus-geo-audit
```

### 2️⃣ Instalar dependencias

```bash
flutter pub get
```

### 3️⃣ Ejecutar

```bash
flutter run
```

---

## 🔐 Permisos Requeridos

### Android

Archivo:

```
android/app/src/main/AndroidManifest.xml
```

Debe incluir:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

---

## 🚀 Funcionamiento

Al iniciar la app:

1. Se solicitan permisos
2. Se activa el GPS
3. Se calcula distancia al POI
4. Se muestra si el usuario está dentro o fuera del radio de 50m

---

## 🧪 Modo Debug vs Modo Producción

Durante pruebas:

```dart
accuracy: LocationAccuracy.high
distanceFilter: 1
```

En producción (modo verde):

```dart
accuracy: LocationAccuracy.low
distanceFilter: 25
```

Esto reduce el impacto energético del sistema.

---

## 📚 Propósito Académico

Este proyecto fue desarrollado como parte de una auditoría técnica orientada a:

* Arquitectura eficiente
* Optimización de recursos móviles
* Diseño sostenible en apps geoespaciales

---

## 👨‍💻 Autor

**Christian Salinas**

Desarrollador Flutter
Proyecto académico – Auditoría de eficiencia geoespacial
