import 'dart:io';
import 'package:image/image.dart';

void main() {
  final img = Image(width: 512, height: 512);
  fill(img, color: ColorRgb8(79, 70, 229)); // Indigo primary
  fillCircle(img, x: 256, y: 256, radius: 180, color: ColorRgb8(6, 182, 212)); // Cyan
  drawCircle(img, x: 256, y: 256, radius: 180, color: ColorRgb8(255, 255, 255)); // White ring
  drawCircle(img, x: 256, y: 256, radius: 176, color: ColorRgb8(255, 255, 255));
  // Clock hands
  drawLine(img, x1: 256, y1: 256, x2: 256, y2: 130, color: ColorRgb8(255, 255, 255), thickness: 8);
  drawLine(img, x1: 256, y1: 256, x2: 340, y2: 256, color: ColorRgb8(255, 255, 255), thickness: 8);
  fillCircle(img, x: 256, y: 256, radius: 14, color: ColorRgb8(255, 255, 255));
  
  final pngBytes = encodePng(img);
  File('assets/images/app_logo.png').writeAsBytesSync(pngBytes);
  print('app_logo.png generated successfully');
}
