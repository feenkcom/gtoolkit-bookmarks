"
I keep track of which bookmarks exist for a source database in the target database where they are stored.

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
		'page2BookmarkMap'
	],
	#classInstVars : [
		'uniqueInstance',
		'testInstance'
	],
	#category : #'GToolkit-Bookmarks-Model'
}

{ #category : #cleanup }
BookmarkRegistry class >> cleanTestInstance [
	testInstance := nil
]

{ #category : #'instance creation' }
BookmarkRegistry class >> forTesting [
	"For testing purposes we have a `second singleton' that uses volatile databases."

	^ self testInstance
]

{ #category : #cleanup }
BookmarkRegistry class >> reset [
	"Resetting the registry will clear the singletons, forcing a fresh instance to be created and initialized.
	This will refresh the map, and, in the case of the test registry, will also empty the bookmark database."

	self cleanUniqueInstance.
	self cleanTestInstance
]

{ #category : #'instance creation' }
BookmarkRegistry class >> testInstance [
	"For testing purposes we have a `second singleton' that uses volatile databases."

	^ testInstance
		ifNil: [ testInstance := self new
					initializeForTesting;
					yourself ]
]

{ #category : #updating }
BookmarkRegistry >> addBookmarkFor: aPage [
	"To do: detect conflict in page names and generate a new, unique name for the bookmark page."

	| bookmarkPage |
	bookmarkPage := self newBookmarkPageFor: aPage.
	self database addPage: bookmarkPage.
	self assert: (self hasBookmarkFor: aPage) not.
	self page2BookmarkMap at: aPage put: bookmarkPage.
	^ bookmarkPage
]

{ #category : #testing }
BookmarkRegistry >> allBookmarksExist [
	"If a bookmark page is deleted, the map will contain invalid bopokmarks."

	^ (self bookmarks reject: [ :bm | bm database isDatabase ]) isEmpty
]

{ #category : #querying }
BookmarkRegistry >> bookmarkPageFor: aPage [
	^ self page2BookmarkMap at: aPage
]

{ #category : #querying }
BookmarkRegistry >> bookmarks [
	^ self page2BookmarkMap values
]

{ #category : #updating }
BookmarkRegistry >> checkAllBookmarksExist [
	"We can also do this any time a single bookmark fails to exist."

	^ self allBookmarksExist ifFalse: [ self initializePage2BookmarkMap ]
]

{ #category : #accessing }
BookmarkRegistry >> database [
	"The database where bookmarks are stored.
	This is normally the primary (private) database, unless we are running tests."

	^ database
]

{ #category : #updating }
BookmarkRegistry >> ensureBookmarkFor: aPage [
	^ self page2BookmarkMap
		at: aPage
		ifPresent: [ :p | p ]
		ifAbsent: [ self addBookmarkFor: aPage ]
]

{ #category : #querying }
BookmarkRegistry >> entries [
	"Transform the dictionary to a flat table."

	^ self page2BookmarkMap associations
		collect: [ :pb | 
			{pb value.
				pb key.
				pb value database} ]
]

{ #category : #views }
BookmarkRegistry >> gtBookmarksFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Bookmarks';
		priority: 20;
		items: [ self entries ];
		column: 'Index'
			text: [ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray ]
			width: 45;
		column: 'Bookmark'
			text: [ :each | each first title ]
			width: 500;
		send: [ :each | each first ];
		actionButtonIcon: BrGlamorousVectorIcons refresh
			tooltip: 'Update'
			action: [ :aButton :aTab | 
				self database isVolatile ifFalse: [ self initializePage2BookmarkMap ].
				aTab phlow fireViewUpdateWish ]
]

{ #category : #views }
BookmarkRegistry >> gtTestDatabaseFor: aView [
	<gtView>
	self database isVolatile ifFalse: [^ aView empty].
	^ aView forward
		title: 'Test bookmark database';
		priority: 30;
		object: [ self database ];
		view: #gtLiveFor:
]

{ #category : #testing }
BookmarkRegistry >> hasBookmarkFor: aPage [
	"Sanity check: if the bookmark no longer exists, we reinitialize the map."

	^ self page2BookmarkMap
		at: aPage
		ifPresent: [ :bm | 
			| bmExists |
			bmExists := bm database isDatabase.
			bmExists ifFalse: [ self initializePage2BookmarkMap ].
			bmExists ]
		ifAbsent: [ false ]
]

{ #category : #initialization }
BookmarkRegistry >> initialize [
	super initialize.
	database := LeDatabase primaryDB.
	self initializePage2BookmarkMap
]

{ #category : #initialization }
BookmarkRegistry >> initializeForTesting [
	"Use an in-memory db for testing."

	database := LeDatabase new monitor: LeVolatileMonitor new.
	LeBasicDatabasesRegistry new
		defaultLogicalDatabase: (LeLogicalDatabase new primaryDB: database).
	self initializePage2BookmarkMap
]

{ #category : #initialization }
BookmarkRegistry >> initializePage2BookmarkMap [
	page2BookmarkMap := ((self database pages
			select: [ :p | p title beginsWith: 'Bookmark for: ' ])
			collect: [ :bookmark | (self pageForBookmark: bookmark) -> bookmark ])
			asDictionary
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
BookmarkRegistry >> page2BookmarkMap [
	^ page2BookmarkMap
]

{ #category : #querying }
BookmarkRegistry >> pageForBookmark: aBookmarkPage [
	^ aBookmarkPage children first outgoingExplicitLinks first targetReference content
]

{ #category : #querying }
BookmarkRegistry >> pages [
	^ self page2BookmarkMap keys
]

{ #category : #updating }
BookmarkRegistry >> removeBookmarkFor: aPage [
	self assert: (self hasBookmarkFor: aPage).
	(self page2BookmarkMap at: aPage) removeSelf.
	self page2BookmarkMap removeKey: aPage.
	self assert: (self hasBookmarkFor: aPage) not
]
