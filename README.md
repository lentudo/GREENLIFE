# Greenlife 🌱

Aplicación móvil enfocada al cuidado de plantas en estilo comunidad, es decir de tipo ecológico.GreenLife🌿, la herramienta perfecta para crear una comunidad de usuarios que gusten de un gestor de contenido sobre las plantas de su agrado, hasta priorizar la ubicacion de sus viveros mas cercanos, los cuidados como lo es el riego, fotos y demas informacion que sea facilmente visible en la aplicacion. Ademas, incluye un panel administrador que permite la gestion de usuarios con rol "user", asi como de sus plantas creadas.

## DEPENDENCIAS UTILIZADAS EN EL PROYECTO (pubspec.yaml):

dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8

 
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4


  firebase_storage: ^12.3.2  # Para subir fotos
  uuid: ^4.5.1               # Para nombres únicos de archivos
  image_picker: ^1.1.2       # Para abrir cámara/galería
  intl: ^0.17.0              # Para formatear fechas

  firebase_messaging: ^15.1.3
  google_maps_flutter: ^2.10.0
  geolocator: ^13.0.1
  http: ^1.2.0
  sensors_plus: ^6.1.0
  flutter_local_notifications: ^18.0.1
  timezone: ^0.9.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true


## ARCHIVO ANDROID MANIFEST.XML:

<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.INTERNET" />
    <application
        android:label="greenlife"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
           
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
       
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="AIzaSyBkdiawA2C1j8rS6Mc0eccRd9dcURvcAXQ"/>
    </application>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>

