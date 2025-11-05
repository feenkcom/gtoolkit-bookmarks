Extension { #name : #LePage }

{ #category : #'*GToolkit-Bookmarks' }
LePage >> bookmark2PageMap [
	"Map from all bookmark pages in the primary db to pages in this page's database.
	Reverse of `self page2BookmarkMap`."

	^ ((LeDatabase primaryDB pages select: #isNamedPage)
		collect: [ :b | b -> (b linkedPagesInDatabase: self database) ]) asDictionary
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> bookmarkRegistry [
	^ self database isVolatile
		ifTrue: [ BookmarkRegistryOLD forTesting ]
		ifFalse: [ BookmarkRegistryOLD default ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> explicitReferencesFromPrimaryDB [
	"These are the private db pages that 'bookmark' this page.
	Similar to explicitReferences, but we also check that the link 
	really points to this page, not just one with the same title."

	^ (LeDatabase primaryDB pages
		select: [ :page | 
			page allOutgoingExplicitLinks items
				detect: [ :link | 
					link isTextualLink
						and: [ link targetPageTitle = self title and: [ link targetReference content = self ] ] ]
				ifFound: [ true ]
				ifNone: [ false ] ]) sort: [ :a :b | a title < b title ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> gtBookmarkActionFor: anAction [
	<lePageAction>
	self isBookmark ifTrue: [ ^ anAction empty ].
	^ anAction button
		tooltip: (self hasBookmark ifTrue: [ 'Inspect bookmark' ] ifFalse: [ 'Create bookmark' ]);
		priority: 30;
		icon: (self hasBookmark
				ifTrue: [ BrGlamorousVectorIcons bookmarkFilled ]
				ifFalse: [ BrGlamorousVectorIcons bookmark ]);
		action: [ :aButton | 
			| bookmarkPage |
			bookmarkPage := self bookmarkRegistry ensureBookmarkFor: self.
			aButton icon: BrGlamorousVectorIcons bookmarkFilled.
			aButton phlow spawnObject: bookmarkPage ];
		primaryModifierAction: [ :aButton | 
			| bookmarkPage |
			bookmarkPage := self bookmarkRegistry ensureBookmarkFor: self.
			aButton icon: BrGlamorousVectorIcons bookmarkFilled.
			aButton phlow showObject: bookmarkPage ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> gtBookmarkRegistryActionFor: anAction [
	<lePageAction>
	self isBookmark ifFalse: [ ^ anAction empty ].
	^ anAction button
		tooltip: 'Inspect bookmarks';
		priority: 30;
		icon: BrGlamorousVectorIcons bookmark;
		action: [ :aButton | aButton phlow spawnObject: self bookmarkRegistry ];
		primaryModifierAction: [ :aButton | aButton phlow showObject: self bookmarkRegistry ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> gtReferringPagesActionFor: anAction [
	<lePageAction>
	self isBookmark ifTrue: [ ^ anAction empty ].
	self explicitReferencesFromPrimaryDB ifEmpty: [ ^ anAction empty ].
	^ anAction button
		tooltip: 'Inspect referring pages';
		priority: 31;
		icon: BrGlamorousVectorIcons left;
		action: [ :aButton | aButton phlow spawnObject: self explicitReferencesFromPrimaryDB ];
		primaryModifierAction: [ :aButton |  ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> hasBookmark [
	^ self bookmarkRegistry hasBookmarkFor: self
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> isBookmark [
	^ self bookmarkRegistry bookmarks includes: self
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> linkedPagesInDatabase: aDatabase [
	^ (self linksToDatabase: aDatabase) collect: [ :l | l targetReference content ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> linksToDatabase: aDatabase [
	^ self allOutgoingExplicitLinks items
		select: [ :link | 
			link isTextualLink
				and: [ link targetReference content notNil
						and: [ link targetReference content isNamedPage
								and: [ link targetReference content database = aDatabase ] ] ] ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> page2BookmarkMap [
	"Map from all pages in this database to bookmark pages in the primary db with links to pages
	in this database. Reverse of `self bookmark2PageMap`."

	| page2BookmarkMap |
	page2BookmarkMap := ((self database pages select: #isNamedPage)
			collect: [ :p | p -> Set new ]) asDictionary.
	(LeDatabase primaryDB pages select: #isNamedPage)
		do: [ :b | 
			(b linkedPagesInDatabase: self database)
				do: [ :p | (page2BookmarkMap at: p) add: b ] ].
	^ page2BookmarkMap
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> pageForBookmark [
	^ self bookmarkRegistry pageForBookmark: self
]
