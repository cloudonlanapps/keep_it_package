import 'package:cl_basic_types/cl_basic_types.dart';

final mimeTypes = MimeTypes();

class MimeTypes {
  Map<CLMediaType, List<String>> get byType => {
        CLMediaType.image: image,
        CLMediaType.video: video,
        CLMediaType.audio: audio,
        CLMediaType.file: pdf,
        CLMediaType.text: text
      };

  List<String> get all => [
        for (final type in CLMediaType.values)
          if (byType.containsKey(type)) ...byType[type]! else ...[]
      ];

  final List<String> pdf = [
    'application/pdf',
    // While less common and generally deprecated for new applications,
    // 'application/x-pdf' was an older, non-standard MIME type you might
    // still encounter in legacy systems or specific browser behaviors.
    // It's best to stick to 'application/pdf' for modern use.
    // 'application/x-pdf',
  ];
  final List<String> text = [
    // Generic plain text
    'text/plain',

    // Common structured text formats
    'text/html', // For HTML documents
    'text/css', // For CSS stylesheets
    'text/javascript', // For JavaScript code (also application/javascript)
    'text/xml', // For XML documents (also application/xml)
    'text/csv', // For Comma-Separated Values files
    'text/calendar', // For iCalendar files (.ics)
    'text/markdown', // For Markdown files (.md)
    'text/rtf', // For Rich Text Format (RTF) files (also application/rtf)

    // Programming language source code (often treated as plain text or more specific x-types)
    'text/x-c', // For C/C++ source code (.c, .h, .cpp)
    'text/x-java-source', // For Java source code (.java)
    'text/x-python', // For Python source code (.py)
    'text/x-shellscript', // For shell scripts (.sh)
    'text/x-php', // For PHP source code
    'text/x-perl', // For Perl source code (.pl)
    'text/x-ruby', // For Ruby source code (.rb)
    'text/x-go', // For Go source code (.go)
    'text/x-csharp', // For C// source code (.cs)
    'text/x-json', // Sometimes seen for JSON, but application/json is standard
    'text/x-yaml', // For YAML files

    // Other specific text-based formats
    'text/tab-separated-values', // For Tab-Separated Values files (.tsv)
    'text/uri-list', // For lists of URIs
    'text/vcard', // For vCard files
    'text/vtt', // For WebVTT (Web Video Text Tracks) files
    'text/sgml', // For SGML documents
    'text/enriched',
    'text/richtext',
    'text/uri-list',
    'text/troff', // For troff/man pages
    'text/x-asm', // Assembly language
    'text/x-component', // HTML components/behaviors (.htc)
    'text/x-setext', // Structurally Extended Text

    // Less common or older/vendor-specific text types
    // "text/asp",
    // "text/html-script",
    // "text/iuls",
    // "text/scriptlet",
    // "text/webviewhtml",
    // "text/x-hdml",
    // "text/x-jscript",
    // "text/x-ms-odc",
    // "text/x-ms-rqe",
    // "text/x-pascal",
    // "text/x-vcalendar",
    // "text/x-vcard",
    // "text/vnd.abc",
  ];

  final List<String> image = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/bmp',
    'image/svg+xml',
    'image/tiff',
    'image/webp',
    'image/avif',
    'image/apng',
    // Less common or older/vendor-specific, but sometimes encountered:
    // 'image/x-icon',  // For favicons (.ico)
    // 'image/jp2',     // JPEG 2000
    // 'image/jxr',     // JPEG XR
    // 'image/vnd.microsoft.icon', // Another favicon type
    // 'image/vnd.dwg', // AutoCAD Drawing Database (vector, but often treated as image)
    // 'image/vnd.dxf', // AutoCAD DXF (vector, but often treated as image)
    // 'image/vnd.wap.wbmp', // Wireless Bitmap (for older mobile devices)
    // 'image/cis-cod',
    // 'image/cgm',
    // 'image/fits',
    // 'image/g3fax',
    // 'image/ief',
    // 'image/naplps',
    // 'image/prs.btif',
    // 'image/prs.pti',
    // 'image/sgi',
    // 'image/t38',
    // 'image/vnd.adobe.photoshop', // For PSD files
    // 'image/vnd.djvu',
    // 'image/vnd.dvb.studio',
    // 'image/vnd.fpx',
    // 'image/vnd.fst',
    // 'image/vnd.ms-modi',
    // 'image/vnd.net-fpx',
    // 'image/vnd.radiance',
    // 'image/vnd.rn-realpix',
    // 'image/vnd.wap.wbmp',
    // 'image/vnd.xiff',
    // 'image/x-cmu-raster',
    // 'image/x-cmx',
    // 'image/x-freehand',
    // 'image/x-mrsid-image',
    // 'image/x-pcx',
    // 'image/x-pict',
    // 'image/x-portable-anymap',
    // 'image/x-portable-bitmap',
    // 'image/x-portable-graymap',
    // 'image/x-portable-pixmap',
    // 'image/x-rgb',
    // 'image/x-tga',
    // 'image/x-xbitmap',
    // 'image/x-xpixmap',
    // 'image/x-xwindowdump',
  ];
  final List<String> video = [
    'video/mp4',
    'video/mpeg',
    'video/webm',
    'video/ogg',
    'video/avi',
    'video/quicktime', // For .mov files
    'video/x-msvideo', // Common for .avi
    'video/x-flv', // Flash Video
    'video/x-ms-wmv', // Windows Media Video
    'video/3gpp', // For .3gp files
    'video/3gpp2', // For .3g2 files
    'video/mp2t', // MPEG transport stream, often for .ts (HLS segments)
    'video/x-matroska', // For .mkv files (though not universally supported)
    'video/quicktime', // For .mov files
    'video/vnd.mpegurl', // For .m3u8 playlists (though application/x-mpegURL is also used)
    // Less common or older/vendor-specific, but sometimes encountered:
    // 'video/x-m4v',      // Often for MP4 videos specifically for Apple devices
    // 'video/divx',
    // 'video/x-dv',       // Digital Video (DV)
    // 'video/h264',
    // 'video/h265',
    // 'video/vp8',
    // 'video/vp9',
    // 'video/mpv',
    // 'video/vob',        // DVD Video Object
    // 'video/f4v',        // Flash Video for F4V files
    // 'video/vnd.dlna.mpeg-tts',
    // 'video/vnd.ms-playready.media.pyv',
    // 'video/vnd.uvvu.mp4',
    // 'video/vnd.vivo',
    // 'video/x-la-asf',
    // 'video/x-ms-asf',
    // 'video/x-sgi-movie',
  ];
  final List<String> audio = [
    'audio/mpeg', // Most common for MP3 files (also audio/mp3)
    'audio/mp3',
    'audio/wav', // For WAV (Waveform Audio File Format)
    'audio/ogg', // For Ogg Vorbis or Ogg Opus
    'audio/aac', // For AAC (Advanced Audio Coding)
    'audio/mp4', // For M4A (MPEG-4 Audio) files, which often use AAC
    'audio/flac', // For FLAC (Free Lossless Audio Codec)
    'audio/aiff', // For AIFF (Audio Interchange File Format)
    'audio/x-aiff', // Common alternative for AIFF
    'audio/midi', // For MIDI files
    'audio/x-midi', // Common alternative for MIDI
    'audio/amr', // Adaptive Multi-Rate (used in mobile devices)
    'audio/opus', // For Opus codec (often within Ogg container)
    'audio/webm', // WebM audio (often with Opus or Vorbis codec)
    'audio/basic', // For au and snd files (older, less common)
    // Less common or older/vendor-specific, but sometimes encountered:
    // 'audio/vnd.rn-realaudio', // For RealAudio files
    // 'audio/x-ms-wma',   // For Windows Media Audio files
    // 'audio/x-pn-wav',   // Another variation for WAV
    // 'audio/adpcm',
    // 'audio/vnd.dts',
    // 'audio/vnd.dts.hd',
    // 'audio/vnd.lucent.olpc.epc',
    // 'audio/vnd.ms-playready.media.pya',
    // 'audio/vnd.nuera.ecelp4800',
    // 'audio/vnd.nuera.ecelp7470',
    // 'audio/vnd.nuera.ecelp9600',
    // 'audio/vnd.qcelp',
    // 'audio/vnd.rip',
    // 'audio/x-caf',      // Apple Core Audio Format
    // 'audio/x-sbc',
  ];
}
