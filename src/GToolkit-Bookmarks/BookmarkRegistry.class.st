"
I keeps track of which bookmarks exist for a source database in the target database where they are stored.

Normally I am a singleton, with the target being the private database of the user.
```
BookmarkRegistry default
```

I can also have a testing instance that uses in-memory databases.
```
BookmarkRegistry forTesting
```

Data:
(i) the target bookmark storage database,
(ii) a dictionary mapping databases (by name) to dictionaries mapping page titles to bookmark titles.
NB: the latter may be needed in case of conflicts.
"
Class {
	#name : #BookmarkRegistry,
	#superclass : #Object,
	#traits : 'TGtUniqueInstance',
	#classTraits : 'TGtUniqueInstance classTrait',
	#instVars : [
		'database',
		'databaseMap'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'GToolkit-Bookmarks-Model'
}

{ #category : #'instance creation' }
BookmarkRegistry class >> forTesting [
	^ self new
		initializeForTesting;
		yourself
]

{ #category : #acccessing }
BookmarkRegistry class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : #updating }
BookmarkRegistry >> addBookmarkFor: aPage [
	"To do: detect conflict in page names and generate a new, unique name for the bookmark page."

	| bookmarkPage bookmarkMap |
	bookmarkPage := self newBookmarkPageFor: aPage.
	self database addPage: bookmarkPage.
	bookmarkMap := self bookmarkMapFor: aPage database.
	self assert: (self hasBookmarkFor: aPage) not.
	bookmarkMap at: aPage title put: bookmarkPage.
	^ bookmarkPage
]

{ #category : #accessing }
BookmarkRegistry >> bookmarkMapFor: aDatabase [
	^ self databaseMap at: aDatabase databaseName ifAbsentPut: Dictionary new
]

{ #category : #accessing }
BookmarkRegistry >> bookmarkPageFor: aPage [
	^ (self bookmarkMapFor: aPage database) at: aPage title
]

{ #category : #accessing }
BookmarkRegistry >> database [
	"The database where bookmarks are stored.
	This is normally the primary (private) database, unless we are running tests."

	^ database
]

{ #category : #accessing }
BookmarkRegistry >> databaseMap [
	"Maps databases to dictionaries that map pages to their bookmark pages."

	^ databaseMap
]

{ #category : #accessing }
BookmarkRegistry >> hasBookmarkFor: aPage [
	^ (self bookmarkMapFor: aPage database) includesKey: aPage title
]

{ #category : #initialization }
BookmarkRegistry >> initialize [
	super initialize.
	database := LeDatabase primaryDB.
	databaseMap := Dictionary new
]

{ #category : #initialization }
BookmarkRegistry >> initializeForTesting [
	"Use an in-memory db for testing."

	database := LeDatabase new monitor: LeVolatileMonitor new.
	LeBasicDatabasesRegistry new
		defaultLogicalDatabase: (LeLogicalDatabase new primaryDB: database)
]

{ #category : #updating }
BookmarkRegistry >> newBookmarkPageFor: aPage [
	^ (LePage named: 'Bookmark for: ' , aPage title)
		addSnippet: (LeTextSnippet new
				string: 'Bookmark for: ' , aPage asRemoteLink;
				yourself);
		addSnippet: (LeTextSnippet new
				string: '*My notes ...*';
				yourself);
		yourself
]

{ #category : #accessing }
BookmarkRegistry >> removeBookmarkFor: aPage [
	| bookmarkMap |
	bookmarkMap := self bookmarkMapFor: aPage database.
	self assert: (self hasBookmarkFor: aPage).
	(bookmarkMap at: aPage title) removeSelf.
	bookmarkMap removeKey: aPage title.
	self assert: (self hasBookmarkFor: aPage) not
]
