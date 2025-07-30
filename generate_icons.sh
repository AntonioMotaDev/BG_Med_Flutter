#!/bin/bash

# Script para generar iconos de Flutter desde una imagen PNG
# Uso: ./generate_icons.sh logo.png

if [ $# -eq 0 ]; then
    echo "Uso: $0 <imagen.png>"
    echo "Ejemplo: $0 logo.png"
    exit 1
fi

INPUT_IMAGE=$1

if [ ! -f "$INPUT_IMAGE" ]; then
    echo "Error: El archivo $INPUT_IMAGE no existe"
    exit 1
fi

echo "Generando iconos para Flutter..."

# Crear directorios si no existen
mkdir -p assets/icons

# Tamaños para Android
echo "Generando iconos para Android..."
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi

# Android iconos
convert "$INPUT_IMAGE" -resize 72x72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png
convert "$INPUT_IMAGE" -resize 48x48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png
convert "$INPUT_IMAGE" -resize 96x96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
convert "$INPUT_IMAGE" -resize 144x144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
convert "$INPUT_IMAGE" -resize 192x192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# Android iconos adaptativos (API 26+)
convert "$INPUT_IMAGE" -resize 108x108 android/app/src/main/res/mipmap-hdpi/ic_launcher_foreground.png
convert "$INPUT_IMAGE" -resize 72x72 android/app/src/main/res/mipmap-mdpi/ic_launcher_foreground.png
convert "$INPUT_IMAGE" -resize 144x144 android/app/src/main/res/mipmap-xhdpi/ic_launcher_foreground.png
convert "$INPUT_IMAGE" -resize 216x216 android/app/src/main/res/mipmap-xxhdpi/ic_launcher_foreground.png
convert "$INPUT_IMAGE" -resize 288x288 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png

# iOS iconos
echo "Generando iconos para iOS..."
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset

# iOS tamaños
convert "$INPUT_IMAGE" -resize 20x20 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png
convert "$INPUT_IMAGE" -resize 40x40 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png
convert "$INPUT_IMAGE" -resize 60x60 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png
convert "$INPUT_IMAGE" -resize 29x29 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png
convert "$INPUT_IMAGE" -resize 58x58 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png
convert "$INPUT_IMAGE" -resize 87x87 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png
convert "$INPUT_IMAGE" -resize 40x40 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png
convert "$INPUT_IMAGE" -resize 80x80 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png
convert "$INPUT_IMAGE" -resize 120x120 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png
convert "$INPUT_IMAGE" -resize 120x120 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png
convert "$INPUT_IMAGE" -resize 180x180 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png
convert "$INPUT_IMAGE" -resize 76x76 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png
convert "$INPUT_IMAGE" -resize 152x152 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png
convert "$INPUT_IMAGE" -resize 167x167 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png
convert "$INPUT_IMAGE" -resize 1024x1024 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png

# Web iconos
echo "Generando iconos para Web..."
mkdir -p web/icons
convert "$INPUT_IMAGE" -resize 192x192 web/icons/Icon-192.png
convert "$INPUT_IMAGE" -resize 512x512 web/icons/Icon-512.png

# macOS iconos
echo "Generando iconos para macOS..."
mkdir -p macos/Runner/Assets.xcassets/AppIcon.appiconset
convert "$INPUT_IMAGE" -resize 16x16 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon_16x16.png
convert "$INPUT_IMAGE" -resize 32x32 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon_16x16@2x.png
convert "$INPUT_IMAGE" -resize 32x32 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon_32x32.png
convert "$INPUT_IMAGE" -resize 64x64 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon_32x32@2x.png
convert "$INPUT_IMAGE" -resize 128x128 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon_128x128.png
convert "$INPUT_IMAGE" -resize 256x256 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png
convert "$INPUT_IMAGE" -resize 256x256 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon_256x256.png
convert "$INPUT_IMAGE" -resize 512x512 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png
convert "$INPUT_IMAGE" -resize 512x512 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon_512x512.png
convert "$INPUT_IMAGE" -resize 1024x1024 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png

echo "¡Iconos generados exitosamente!"
echo "Ahora ejecuta: flutter clean && flutter pub get" 