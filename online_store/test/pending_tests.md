# Pending Tests

## Collection

- [X] C1. can create a collection with label
- [X] C2 can create a collection with label and description
- [X] C3 can't create collection with same label, returns the same object
- [X] C4 can't create collection with same label and different descripton, the new descripton is ignored
- [X] C5 can't create a collection with a file
- [ ] C6  Can create collection with parentId

## Media

- [X] M1 can't create a media without file"
- [X] M2 can create a media with only file
- [X] M3 can replace a media
- [X] M4 can create with label and update it
- [X] M5 can't create media with same file, returns the same object
- [X] M6 Can't create duplicate to existing item, even by updating
- [ ] M7 can create Media with a specific parentId
- [ ] M8 can move a media from one parent to another
- [ ] M9 moving a media to same parent don't update anything
- [ ] M10 updating a media same label  don't update anything
- [ ] M11 can create with description and update
- [ ] M12 can update createDate for a media
- [ ] M13 can create multiple media with same label

## Read or Query

- [ ] R1 test `getAll`, and confirm all the items recently created present in it, wihtout any filter. This should exclude permanently deleted, and fetch from the latest version
- [ ] R2 `getByID` returns valid entity if found
- [ ] R3 `getByID` returns NotFound error when the item is not present
- [ ] R4 `get` with id / label returns valid entity if found for collection
- [ ] R5 `get` with id / md5 returns valid entity if found for media
- [ ] R6 `get` with both id and md5 returns media with id, not by md5

## Known issues

- [ ] there is no way to differentiate soft delete and hard delete.
