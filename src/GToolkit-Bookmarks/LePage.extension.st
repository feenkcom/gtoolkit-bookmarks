Extension { #name : #LePage }

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
			aButton phlow
				spawnObject: (self hasBookmark
						ifTrue: [ BookmarkRegistry default bookmarkPageFor: self ]
						ifFalse: [ BookmarkRegistry default addBookmarkFor: self ]) ];
		primaryModifierAction: [ :aButton | 
			aButton phlow
				showObject: (self hasBookmark
						ifTrue: [ BookmarkRegistry default bookmarkPageFor: self ]
						ifFalse: [ BookmarkRegistry default addBookmarkFor: self ]) ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> gtBookmarkRegistryActionFor: anAction [
	<lePageAction>
	self isBookmark ifFalse: [ ^ anAction empty ].
	^ anAction button
		tooltip: 'Inspect bookmarks';
		priority: 30;
		icon: BrGlamorousVectorIcons bookmark;
		action: [ :aButton | aButton phlow spawnObject: BookmarkRegistry default ];
		primaryModifierAction: [ :aButton | aButton phlow showObject: BookmarkRegistry ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> hasBookmark [
	^ BookmarkRegistry default hasBookmarkFor: self
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> isBookmark [
	^ BookmarkRegistry default bookmarks includes: self
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> pageForBookmark [
	^ BookmarkRegistry default pageForBookmark: self
]
