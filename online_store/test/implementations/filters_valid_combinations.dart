import 'package:cl_basic_types/cl_basic_types.dart';

List<Map<String, dynamic>> filterValidTestCases = [
  {'isCollection': 1},
  {'isDeleted': 0},
  {'isCollection': 1, 'isDeleted': 0},
  {'label': 'MyDocument'},

  {'MIMEType': 'image/jpeg'},
  {'extension': 'pdf'},
  {'label': '__null__'},
  {'label': '__notnull__'},

  {
    'MIMEType': ['image/png', 'image/jpeg']
  },
  {'labelStartsWith': 'Report'},
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
  {'DurationMin': 60.5},
  {'DurationMax': 3600.0},
  {'DurationMin': 120.0, 'DurationMax': 600.0},
  {'DurationMin': 1000.0, 'DurationMax': 100.0},
  {
    'isCollection': 0,
    'labelStartsWith': 'Image',
    'CreateDateYY': DateTime(2023).utcTimeStamp,
    'FileSizeMin': 100000
  },
  {
    'MIMEType': 'video/mp4',
    'DurationMin': 300.0,
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
    'labelStartsWith': 'Doc',
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

  {'FileSize': 100},
  {'FileSizeMin': 100},
  {'FileSizeMax': 100},

  {'ImageHeight': 100},
  {'ImageHeightMin': 100},
  {'ImageHeightMax': 100},

  {'ImageWidth': 100},
  {'ImageWidthMin': 100},
  {'ImageWidthMax': 100},

  {'Duration': 100},
  {'DurationMin': 100},
  {'DurationMax': 100},

  {'Duration': 100.0},
  {'DurationMin': 100.0},
  {'DurationMax': 100.0},

  {'Duration': 100.5},
  {'DurationMin': 100.5},
  {'DurationMax': 100.5},

  {'label': 'mylabel'},
  {'labelStartsWith': 'mylabel'},
  {'labelContains': 'mylabel'},

  {'description': 'mydescription'},
  {'descriptionStartsWith': 'mydescription'},
  {'descriptionContains': 'mydescription'},
];
