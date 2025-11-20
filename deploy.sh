#!/bin/bash

mkdir -p ~/Desktop/wandr
flutter clean

flutter build appbundle --release
cp build/app/outputs/bundle/release/app-release.aab ~/Desktop/wandr

flutter build apk --release
cp build/app/outputs/apk/release/app-release.apk ~/Desktop/wandr

# flutter build ios --release