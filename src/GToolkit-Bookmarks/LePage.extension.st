Extension { #name : #LePage }

{ #category : #'*GToolkit-Bookmarks' }
LePage >> bookmarkRegistry [
	^ self database isVolatile
		ifTrue: [ BookmarkRegistry forTesting ]
		ifFalse: [ BookmarkRegistry default ]
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
			aButton phlow fireViewUpdateWish.
			aButton phlow spawnObject: bookmarkPage ];
		primaryModifierAction: [ :aButton | 
			| bookmarkPage |
			bookmarkPage := self bookmarkRegistry ensureBookmarkFor: self.
			aButton phlow fireViewUpdateWish.
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
