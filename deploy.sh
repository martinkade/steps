#!/bin/bash

mkdir -p ~/Desktop/Wandr
flutter clean

flutter build appbundle --release
cp build/app/outputs/bundle/release/app-release.aab ~/Desktop/Wandr

flutter build apk --release
cp build/app/outputs/apk/release/app-release.apk ~/Desktop/Wandr

# flutter build ios --release