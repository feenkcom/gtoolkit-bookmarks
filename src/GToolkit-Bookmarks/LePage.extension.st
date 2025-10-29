Extension { #name : #LePage }

{ #category : #'*GToolkit-Bookmarks' }
LePage >> bookmarkRegistry [
	^ self database isVolatile
		ifTrue: [ BookmarkRegistry forTesting ]
		ifFalse: [ BookmarkRegistry default ]
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
LePage >> hasBookmark [
	^ self bookmarkRegistry hasBookmarkFor: self
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> isBookmark [
	^ self bookmarkRegistry bookmarks includes: self
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> pageForBookmark [
	^ self bookmarkRegistry pageForBookmark: self
]
