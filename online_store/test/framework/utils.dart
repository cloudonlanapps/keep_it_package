// ignore_for_file: avoid_print, print required for testing

import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

// Generates a random alphanumeric string of a specified length,
/// prefixed with a given string.
///
/// [length]: The desired total length of the random part of the string.
///           The final string length will be `prefix.length + length`.
///           Must be a non-negative integer.
/// [prefix]: The string to prepend to the random part.
///
/// Returns a string with the given prefix followed by a random alphanumeric string.
///
/// Throws [ArgumentError] if [length] is negative.
String randomString(int length, {String? prefix, String? suffix}) {
  if (length < 0) {
    throw ArgumentError('Length cannot be negative.');
  }

  const alphanumeric =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  final buffer = prefix == null
      ? StringBuffer()
      : StringBuffer(prefix); // Start with the prefix

  for (var i = 0; i < length; i++) {
    buffer.write(alphanumeric[random.nextInt(alphanumeric.length)]);
  }
  if (suffix != null) {
    buffer.write(suffix);
  }

  return buffer.toString();
}

/// Generates a simple Lorem Ipsum-like text.
///
/// [paragraphs]: The number of paragraphs to generate.
/// [minSentencesPerParagraph]: Minimum number of sentences per paragraph.
/// [maxSentencesPerParagraph]: Maximum number of sentences per paragraph.
/// [minWordsPerSentence]: Minimum number of words per sentence.
/// [maxWordsPerSentence]: Maximum number of words per sentence.
///
/// Returns a [String] containing the generated Lorem Ipsum text.
///
/// Throws [ArgumentError] if min/max values are invalid (e.g., min > max).
String generateLoremIpsum({
  int paragraphs = 3,
  int minSentencesPerParagraph = 3,
  int maxSentencesPerParagraph = 7,
  int minWordsPerSentence = 5,
  int maxWordsPerSentence = 15,
}) {
  if (paragraphs <= 0) return '';
  if (minSentencesPerParagraph <= 0 ||
      maxSentencesPerParagraph <= 0 ||
      minSentencesPerParagraph > maxSentencesPerParagraph) {
    throw ArgumentError('Invalid sentence count parameters.');
  }
  if (minWordsPerSentence <= 0 ||
      maxWordsPerSentence <= 0 ||
      minWordsPerSentence > maxWordsPerSentence) {
    throw ArgumentError('Invalid word count parameters.');
  }

  final words = <String>[
    'lorem',
    'ipsum',
    'dolor',
    'sit',
    'amet',
    'consectetur',
    'adipiscing',
    'elit',
    'sed',
    'do',
    'eiusmod',
    'tempor',
    'incididunt',
    'ut',
    'labore',
    'et',
    'dolore',
    'magna',
    'aliqua',
    'ut',
    'enim',
    'ad',
    'minim',
    'veniam',
    'quis',
    'nostrud',
    'exercitation',
    'ullamco',
    'laboris',
    'nisi',
    'ut',
    'aliquip',
    'ex',
    'ea',
    'commodo',
    'consequat',
    'duis',
    'aute',
    'irure',
    'dolor',
    'in',
    'reprehenderit',
    'in',
    'voluptate',
    'velit',
    'esse',
    'cillum',
    'dolore',
    'eu',
    'fugiat',
    'nulla',
    'pariatur',
    'excepteur',
    'sint',
    'occaecat',
    'cupidatat',
    'non',
    'proident',
    'sunt',
    'in',
    'culpa',
    'qui',
    'officia',
    'deserunt',
    'mollit',
    'anim',
    'id',
    'est',
    'laborum'
  ];

  final random = Random();
  final buffer = StringBuffer();

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  for (var p = 0; p < paragraphs; p++) {
    final numSentences = random
            .nextInt(maxSentencesPerParagraph - minSentencesPerParagraph + 1) +
        minSentencesPerParagraph;
    for (var s = 0; s < numSentences; s++) {
      final numWords =
          random.nextInt(maxWordsPerSentence - minWordsPerSentence + 1) +
              minWordsPerSentence;
      for (var w = 0; w < numWords; w++) {
        final word = words[random.nextInt(words.length)];
        if (w == 0) {
          buffer.write(capitalizeFirstLetter(word));
        } else {
          buffer.write(' $word');
        }
      }
      buffer.write('. '); // End sentence
    }
    buffer.write('\n\n'); // End paragraph
  }

  return buffer.toString().trim(); // Trim trailing newlines
}

/* void main() {
  // Example usage:

  // generateRandomPatternImage('my_pattern.jpg'); // Custom JPG filename, random dimensions
  // generateRandomPatternImage( 'fixed_size_pattern.png', width: 800, height: 600); // Custom PNG filename, fixed dimensions
  generateRandomPatternImage('my_random_image.png');
} */

/// Generates an image with random patterns.
///
/// This function creates an image of a specified or random size (up to 1024x1024)
/// and fills it with various random geometric patterns like rectangles, circles,
/// and lines. The output image can be saved as either a PNG or JPEG file
/// depending on the provided file extension.
///
/// [outputFileName]: (Optional) The name of the output file. If not provided,
///                   a default name like 'random_pattern_image.png' will be used.
///                   The file extension (.png or .jpg) determines the output format.
/// [width]: (Optional) The desired width of the image. If not provided, a random
///          width up to 1024 pixels will be generated.
/// [height]: (Optional) The desired height of the image. If not provided, a random
///           height up to 1024 pixels will be generated.
void generateRandomPatternImage(String outputFileName,
    {int? width, int? height}) {
  final random = Random();
  const minDimension = 16;
  const maxDimension = 1024;

  // Determine image dimensions
  // Determine image dimensions
  // Ensure random dimensions are at least minDimension
  final imgWidth = width != null
      ? max(width,
          minDimension) // If width is provided, use it, but ensure it's at least minDimension
      : random.nextInt(maxDimension - minDimension + 1) +
          minDimension; // Random between minDimension and maxDimension

  final imgHeight = height != null
      ? max(height,
          minDimension) // If height is provided, use it, but ensure it's at least minDimension
      : random.nextInt(maxDimension - minDimension + 1) +
          minDimension; // Random between minDimension and maxDimension

  // print('Generating an image of size: ${imgWidth}x$imgHeight');

  // Determine output file name and format
  final finalOutputFileName = outputFileName;
  final fileExtension = finalOutputFileName.split('.').last.toLowerCase();
  img.ImageFormat format;

  if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
    format = img.ImageFormat.jpg;
    //  print('Output format will be JPEG.');
  } else {
    format = img.ImageFormat.png;
    //print('Output format will be PNG.');
  }

  // Initialize Image
  final image = img.Image(width: imgWidth, height: imgHeight);

  // Fill with a random background color
  final backgroundColor = img.ColorRgb8(
      random.nextInt(256), random.nextInt(256), random.nextInt(256));
  for (var y = 0; y < imgHeight; y++) {
    for (var x = 0; x < imgWidth; x++) {
      image.setPixel(x, y, backgroundColor);
    }
  }

  // Draw random rectangles
  final numRectangles = random.nextInt(5) + 3; // 3 to 7 rectangles
  for (var i = 0; i < numRectangles; i++) {
    final x1 = random.nextInt(imgWidth);
    final y1 = random.nextInt(imgHeight);
    final rectWidth = random.nextInt(imgWidth - x1) + 1;
    final rectHeight = random.nextInt(imgHeight - y1) + 1;
    final color = img.ColorRgb8(
        random.nextInt(256), random.nextInt(256), random.nextInt(256));
    img.drawRect(image,
        x1: x1, y1: y1, x2: x1 + rectWidth, y2: y1 + rectHeight, color: color);
  }

  // Draw random circles
  final numCircles = random.nextInt(4) + 2; // 2 to 5 circles
  for (var i = 0; i < numCircles; i++) {
    final centerX = random.nextInt(imgWidth);
    final centerY = random.nextInt(imgHeight);
    final radius = random.nextInt(min(imgWidth, imgHeight) ~/ 4) + 10;
    final color = img.ColorRgb8(
        random.nextInt(256), random.nextInt(256), random.nextInt(256));
    img.drawCircle(image, x: centerX, y: centerY, radius: radius, color: color);
  }

  // Draw random lines
  final numLines = random.nextInt(10) + 5; // 5 to 14 lines
  for (var i = 0; i < numLines; i++) {
    final x1 = random.nextInt(imgWidth);
    final y1 = random.nextInt(imgHeight);
    final x2 = random.nextInt(imgWidth);
    final y2 = random.nextInt(imgHeight);
    final color = img.ColorRgb8(
        random.nextInt(256), random.nextInt(256), random.nextInt(256));
    img.drawLine(image, x1: x1, y1: y1, x2: x2, y2: y2, color: color);
  }

  // Optionally, draw some random pixels for 'noise'
  final numPixels = (imgWidth * imgHeight * 0.01).toInt();
  for (var i = 0; i < numPixels; i++) {
    final x = random.nextInt(imgWidth);
    final y = random.nextInt(imgHeight);
    final color = img.ColorRgb8(
        random.nextInt(256), random.nextInt(256), random.nextInt(256));
    image.setPixel(x, y, color);
  }

  // Save Image
  List<int>? bytes;
  if (format == img.ImageFormat.jpg) {
    bytes = img.encodeJpg(image);
  } else {
    bytes = img.encodePng(image);
  }

  File(finalOutputFileName).writeAsBytesSync(bytes);
}

// Helper function to get the minimum of two integers
int min(int a, int b) {
  return a < b ? a : b;
}
