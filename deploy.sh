#!/bin/bash

flutter build appbundle --release
cp build/app/outputs/bundle/release/app-release.aab ~/Desktop

flutter build ios --release