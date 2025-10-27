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

{ #category : #cleanup }
BookmarkRegistry class >> reset [
	self cleanUniqueInstance
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

{ #category : #testing }
BookmarkRegistry >> allBookmarksExist [
	"If a bookmark page is deleted, the map will contain invalid bopokmarks."

	^ (self bookmarks reject: [ :bm | bm database isDatabase ]) isEmpty
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
BookmarkRegistry >> bookmarks [
	^ self databaseMap values flatCollect: #values
]

{ #category : #updating }
BookmarkRegistry >> checkAllBookmarksExist [
	"We can also do this any time a single bookmark fails to exist."

	^ self allBookmarksExist ifFalse: [ self initializeDatabaseMap ]
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

{ #category : #updating }
BookmarkRegistry >> ensureBookmarkFor: aPage [
	^ (self bookmarkMapFor: aPage database)
		at: aPage title
		ifPresent: [ :p | p ]
		ifAbsent: [ self addBookmarkFor: aPage ]
]

{ #category : #querying }
BookmarkRegistry >> entries [
	"Transform the dictionary of dictionaries to a flat table."

	^ (self databaseMap associations
		flatCollect: [ :dbMap | 
			dbMap value associations
				collect: [ :pageBookmark | 
					{pageBookmark value.
						pageBookmark key.
						dbMap key} ] ]) sortedAs: #second
]

{ #category : #views }
BookmarkRegistry >> gtBookmarksFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Bookmarks';
		items: [ self entries ];
		column: 'Index'
			text: [ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray ]
			width: 45;
		column: 'Bookmark'
			text: [ :each | each first title ]
			width: 350;
		column: 'Page'
			text: [ :each | each second ]
			width: 250;
		column: 'Database'
			text: [ :each | each third ]
			width: 200;
		send: [ :each | each first ];
		actionButtonIcon: BrGlamorousVectorIcons refresh
			tooltip: 'Update'
			action: [ :aButton :aTab | 
				self initializeDatabaseMap.
				aTab phlow fireViewUpdateWish ]
]

{ #category : #accessing }
BookmarkRegistry >> hasBookmarkFor: aPage [
	"Sanity check: if the bookmark no longer exists, we reinitialize the map."

	| map |
	map := self bookmarkMapFor: aPage database.
	^ map
		at: aPage title
		ifPresent: [ :bm | 
			| bmExists |
			bmExists := bm database isDatabase.
			bmExists ifFalse: [ self initializeDatabaseMap ].
			bmExists ]
		ifAbsent: [ false ]
]

{ #category : #initialization }
BookmarkRegistry >> initialize [
	super initialize.
	database := LeDatabase primaryDB.
	self initializeDatabaseMap
]

{ #category : #initialization }
BookmarkRegistry >> initializeDatabaseMap [
	| bookmarkPages |
	databaseMap := Dictionary new.
	bookmarkPages := self database pages
			select: [ :p | p title beginsWith: 'Bookmark for: ' ].
	bookmarkPages
		do: [ :bookmark | 
			| page |
			page := bookmark children first outgoingExplicitLinks first targetReference
					content.
			(self bookmarkMapFor: page database) at: page title put: bookmark ]
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
