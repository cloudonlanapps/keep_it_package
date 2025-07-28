
# Query Spec

There are three query APIs provided

1. /entity/<int:entity_id>
2. /entity/match
3. /entity/query
4. /entity/query/loopback

## /entity/<int:entity_id>

API to query by Id that returns a single Entity Object or an Error

## /entity/match

API to match unique fields that returns a single Entity Object or an Error

Match API's only purpose is to check if the item already exists. This is done by matching the unique fields.
isCollection == True and label is an unique field, hence label matches only.
md5 is available only when isCollection  == false and its an unique value based on the media uploaded.

## /entity/query

API to query Entities based on parameters that returns a list of Entity object, encapsulated in a dictionary with metadata or an Error.

### Terminology

* parameter - parameters that are specified in the query.
* fields - fields in the entity object.
fields are mapped with one or more parameters to create different kind of queries.  
The fields are of different types, Bool, Int, Double, String, DateTime, enumerated etc. But the parameters are either Int, String or double. When querying for other types, the values are either integerized or stringified. This avoid many complexities in handling different formats.
* Bool values are converted to bool with the following: [true --> 1,  false --> 0].
* Date and DateTime values are converted into utcTimeStamp.

Some fields are nullable. So, sometimes we may need to query for entities with those fields set to valid value or having set to Null. To handle these type of queries, some parameters carry specal values \_\_null\_\_  and \_\_notnull\_\_. These parameters are called 'Null supported Parameters'

### Naming Convention

* The parameter names are always same as field names or have field name as prefix.
* There is no specific naming conventions, though snake case is preferred. Many fields are named with Pascal case or camel case due to various legacy reasons, like how exif tools name them to avoid unnecessary conversion. Due to which the Parameters have mixed case.
* All the parameter names and field names are case sensitive.

The following table lists all the parameters in alphabetic order

| Parameter                                                          | Null supported |                                  | Types Supported                     | Test group  | Remarks                                                                                                                                                                                                                                                                                      |
| ------------------------------------------------------------------ | :------------: | -------------------------------- | ----------------------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| addedDate\[YY\]\[MM\][DD\]<br>updateDate[YY[MM[DD]]](From\|Till)   |       No       | Integerized DateTime             |                                     | addedDate   |                                                                                                                                                                                                                                                                                              |
| CreateDate\[YY\]\[MM\][DD\]<br>updateDate[YY[MM[DD]]](From\|Till)  |      Yes       | Integerized DateTime             | isCollection=0                      | CreateDate  |                                                                                                                                                                                                                                                                                              |
| description[Contains]                                              |       No       | String                           |                                     |             |                                                                                                                                                                                                                                                                                              |
| Duration[\|Min\|Max]                                               |       No       | Double                           | type=video, audio                   |             |                                                                                                                                                                                                                                                                                              |
| extension: String<br>MIMEType: String<br>type: String<br>          |       No       | String                           | isCollection=0                      | fileType    |                                                                                                                                                                                                                                                                                              |
| FileSize[\|Min\|Max]                                               |       No       | Int,  in Bytes, NonZero Unsigned | isCollefdtion=0                     |             |                                                                                                                                                                                                                                                                                              |
| ImageHeight[\|Min\|Max]                                            |       No       | Int, NonZero, Unsigned           | isCollection=0<br>type=image, video |             |                                                                                                                                                                                                                                                                                              |
| ImageWidth[\|Min\|Max]                                             |       No       | Int, NonZero, Unsigned           | isCollection=0<br>type=image, video |             |                                                                                                                                                                                                                                                                                              |
| isCollection                                                       |       No       | Integerized Bool                 |                                     | Basics      |                                                                                                                                                                                                                                                                                              |
| isDeleted                                                          |       No       | Integerized Bool                 |                                     |             |                                                                                                                                                                                                                                                                                              |
| label[\|StartsWith\|Contains]                                      |      Yes       | String                           |                                     |             | Query with a label.  label is partially unique field. i.e., this unique only when IsCollection is 1. hence Its suggested to use this fled with isCollection field to get a meaningful result.<br>if searching for a unique labeled collection, use /entity/match instead of this parameters. |
| parentId                                                           |      Yes       | Int, NonZero, Unsigned           |                                     | Basics      |                                                                                                                                                                                                                                                                                              |
| updatedDate\[YY\]\[MM\][DD\]<br>updateDate[YY[MM[DD]]](From\|Till) |       No       | Integerized DateTime             |                                     | updatedDate |                                                                                                                                                                                                                                                                                              |

### Query with Dates



###  Tests
- [ ] F1 without any filter, getAll retrieves all the items in the repo
- [ ] F2 isCollection - helps to filter out collections from media
- [ ] F3 parentId helps to filter out items based on parentID (null or any valid collectionId)
- [ ] CD1 CreateDateTime retrives files with the exact time, with second accurate
- [ ] F4 CreateDate[HH] retrieves all files with the same day. Not just exact Date&Time
- [ ] F5 CreateDate_year & CreateDate_month - Combination extracts all the items from the days in that year and month,
- [ ] F6 CreateDate_month & CreateDate_day - Combination extracts all the items for the given month and day for every available years

  

- [ ] F3 From a collection, can return images from a specific (month, day) (ignoring year)

- [ ] F4 From a collection, can return images from a specific month, given (year, month)
#### Query: isCollection
	This test h
