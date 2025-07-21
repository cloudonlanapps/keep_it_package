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
  {'addedDate_from': DateTime(2023).millisecondsSinceEpoch},
  {
    'CreateDate_till': DateTime(2023, 12, 31, 23, 59, 59).millisecondsSinceEpoch
  },
  {
    'updatedDate_from': DateTime(2024).millisecondsSinceEpoch,
    'updatedDate_till':
        DateTime(2024, 12, 31, 23, 59, 59).millisecondsSinceEpoch
  },
  {
    'addedDate_from': DateTime(2023).millisecondsSinceEpoch,
    'addedDate_till': DateTime(2023, 12, 31, 23, 59, 59).millisecondsSinceEpoch
  },
  {
    'CreateDate_from': DateTime(2023).millisecondsSinceEpoch,
    'CreateDate_till': DateTime(2023, 12, 31, 23, 59, 59).millisecondsSinceEpoch
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
  {'CreateDate_day': 15},
  {'CreateDate_month': 3},
  {'CreateDate_year': 2024},
  {'CreateDate_month': 7, 'CreateDate_day': 4},
  {
    'isCollection': 0,
    'label_starts_with': 'Image',
    'CreateDate_year': 2023,
    'FileSizeMin': 100000
  },
  {
    'MIMEType': 'video/mp4',
    'Duration_min': 300.0,
    'CreateDate_from': DateTime(2024).millisecondsSinceEpoch
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
    'addedDate_from': DateTime(2023).millisecondsSinceEpoch,
    'updatedDate_till':
        DateTime(2023, 12, 31, 23, 59, 59).millisecondsSinceEpoch
  },
  {
    'label_starts_with': 'Doc',
    'CreateDate_from': DateTime(2023).millisecondsSinceEpoch,
    'CreateDate_till':
        DateTime(2023, 12, 31, 23, 59, 59).millisecondsSinceEpoch,
    'addedDate_from': DateTime(2023).millisecondsSinceEpoch,
    'addedDate_till': DateTime(2023, 12, 31, 23, 59, 59).millisecondsSinceEpoch,
    'updatedDate_from': DateTime(2023).millisecondsSinceEpoch,
    'updatedDate_till':
        DateTime(2023, 12, 31, 23, 59, 59).millisecondsSinceEpoch
  },
  {
    'isCollection': 1,
    'isDeleted': 0,
    'label': 'Test',
    'id': [11, 12],
    'parentId': '__notnull__',
    'FileSizeMin': 500,
    'FileSizeMax': 10000,
    'addedDate_from': DateTime(2023).millisecondsSinceEpoch
  },
  {
    'label': 'Combo',
    'md5': ['a', 'b'],
    'MIMEType': 'image/gif',
    'extension': 'gif',
    'ImageWidth': 800,
    'ImageHeight': 600,
    'Duration': 120,
    'CreateDate_year': 2022
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
];
