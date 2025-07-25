import 'package:cl_basic_types/cl_basic_types.dart';

List<Map<String, dynamic>> filterValidTestCases = [
  {'isCollection': 1},
  {'isDeleted': 0},
  {'isCollection': 1, 'isDeleted': 0},
  {'label': 'MyDocument'},
  {'label': 'document', 'md5': 'a1b2c3d4e5f67890'},
  {'MIMEType': 'image/jpeg'},
  {'extension': 'pdf'},
  {'label': '__null__'},
  {'label': '__notnull__'},
  {'md5': '__notnull__'},
  {
    'MIMEType': ['image/png', 'image/jpeg']
  },
  {'label_starts_with': 'Report'},
  {'id': 123},
  {'parentId': 456},
  {'ImageHeight': 1080},
  {'ImageWidth': 1920},
  {'Duration': 300},
  {'parentId': '__null__'},
  {'id': '__notnull__'},
  {'ImageWidth': '__notnull__'},
  {'FileSizeMin': 1024},
  {'FileSizeMax': 1048576},
  {'FileSizeMin': 50000, 'FileSizeMax': 100000},
  {'FileSizeMin': 1000000, 'FileSizeMax': 500000},
  {'addedDateFrom': DateTime(2023).utcTimeStamp},
  {'CreateDateTill': DateTime(2023, 12, 31, 23, 59, 59).utcTimeStamp},
  {
    'updatedDateFrom': DateTime(2024).utcTimeStamp,
    'updatedDateTill': DateTime(2024, 12, 31, 23, 59, 59).utcTimeStamp
  },
  {
    'addedDateFrom': DateTime(2023).utcTimeStamp,
    'addedDateTill': DateTime(2023, 12, 31, 23, 59, 59).utcTimeStamp
  },
  {
    'CreateDateFrom': DateTime(2023).utcTimeStamp,
    'CreateDateTill': DateTime(2023, 12, 31, 23, 59, 59).utcTimeStamp
  },
  {
    'id': [1, 5, 10]
  },
  {
    'parentId': [7, 8]
  },
  {'Duration_min': 60.5},
  {'Duration_max': 3600.0},
  {'Duration_min': 120.0, 'Duration_max': 600.0},
  {'Duration_min': 1000.0, 'Duration_max': 100.0},
  {
    'isCollection': 0,
    'label_starts_with': 'Image',
    'CreateDateYY': DateTime(2023).utcTimeStamp,
    'FileSizeMin': 100000
  },
  {
    'MIMEType': 'video/mp4',
    'Duration_min': 300.0,
    'CreateDateFrom': DateTime(2024).utcTimeStamp
  },
  {
    'parentId': '__notnull__',
    'isDeleted': 0,
    'ImageHeight': 720,
    'ImageWidth': 1280
  },
  {
    'isCollection': 1,
    'isDeleted': 0,
    'label': 'Report',
    'md5': 'abcd',
    'MIMEType': 'image/png',
    'extension': 'png',
    'id': [1, 2, 3],
    'parentId': [4, 5],
    'FileSizeMin': 1000,
    'FileSizeMax': 2000,
    'addedDateFrom': DateTime(2023).utcTimeStamp,
    'updatedDateTill': DateTime(2023, 12, 31, 23, 59, 59).utcTimeStamp
  },
  {
    'label_starts_with': 'Doc',
    'CreateDateFrom': DateTime(2023).utcTimeStamp,
    'CreateDateTill': DateTime(2023, 12, 31, 23, 59, 59).utcTimeStamp,
    'addedDateFrom': DateTime(2023).utcTimeStamp,
    'addedDateTill': DateTime(2023, 12, 31, 23, 59, 59).utcTimeStamp,
    'updatedDateFrom': DateTime(2023).utcTimeStamp,
    'updatedDateTill': DateTime(2023, 12, 31, 23, 59, 59).utcTimeStamp
  },
  {
    'isCollection': 1,
    'isDeleted': 0,
    'label': 'Test',
    'id': [11, 12],
    'parentId': '__notnull__',
    'FileSizeMin': 500,
    'FileSizeMax': 10000,
    'addedDateFrom': DateTime(2023).utcTimeStamp
  },
  {
    'label': 'Combo',
    'md5': ['a', 'b'],
    'MIMEType': 'image/gif',
    'extension': 'gif',
    'ImageWidth': 800,
    'ImageHeight': 600,
    'Duration': 120,
    'CreateDateYY': DateTime(2022).utcTimeStamp
  },
  {},
  {'isDeleted': '0'},
  {'id': '123'},
  {'FileSizeMin': '1024'},
  {'parentId': <int>[]},
  {'isCollection': null},
  {'label': null},
  {
    'parentId': ['__null__']
  },
  {'CreateDate': DateTime.now().utcTimeStamp},
  // Begin with year
  {'CreateDateYY': DateTime.now().utcTimeStamp},
  {'CreateDateYYMM': DateTime.now().utcTimeStamp},
  {'CreateDateYYMMDD': DateTime.now().utcTimeStamp},
  {'CreateDateYYMMDDHH': DateTime.now().utcTimeStamp},
  {'CreateDateYYMMHH': DateTime.now().utcTimeStamp},
  {'CreateDateYYDD': DateTime.now().utcTimeStamp},
  {'CreateDateYYDDHH': DateTime.now().utcTimeStamp},
  {'CreateDateYYHH': DateTime.now().utcTimeStamp},

  // Begin with month
  {'CreateDateMM': DateTime.now().utcTimeStamp},
  {'CreateDateMMDD': DateTime.now().utcTimeStamp},
  {'CreateDateMMDDHH': DateTime.now().utcTimeStamp},
  {'CreateDateMMHH': DateTime.now().utcTimeStamp},

  {'CreateDateDD': DateTime.now().utcTimeStamp},
  {'CreateDateDDHH': DateTime.now().utcTimeStamp},

  {'CreateDateHH': DateTime.now().utcTimeStamp},

  {'CreateDateFrom': DateTime.now().utcTimeStamp},
  {'CreateDateTill': DateTime.now().utcTimeStamp},

  {'CreateDateYYFrom': DateTime.now().utcTimeStamp},
  {'CreateDateYYTill': DateTime.now().utcTimeStamp},

  {'CreateDateYYMMFrom': DateTime.now().utcTimeStamp},
  {'CreateDateYYMMTill': DateTime.now().utcTimeStamp},

  {'CreateDateYYMMDDFrom': DateTime.now().utcTimeStamp},
  {'CreateDateYYMMDDTill': DateTime.now().utcTimeStamp},
];
