#!/bin/bash

# Flutter SDK インストール
echo "Installing Flutter SDK..."

# Flutter Doctor を実行して設定を確認
flutter doctor

echo "Flutter setup completed!"

# Flame パッケージのインストール
echo "Installing Flame package..."
cd life_game_app
flutter pub get
echo "Flame package installed successfully!"