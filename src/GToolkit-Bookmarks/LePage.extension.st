Extension { #name : #LePage }

{ #category : #'*GToolkit-Bookmarks' }
LePage >> gtCreateBookmarkActionFor: anAction [
	<lePageAction>
	self hasBookmark ifTrue: [ ^ anAction empty ].
	self isBookmark ifTrue: [ ^ anAction empty ].
	^ anAction button
		tooltip: 'Create bookmark';
		priority: 30;
		icon: BrGlamorousVectorIcons bookmark;
		action: [ :aButton | aButton phlow showObject: (BookmarkRegistry default addBookmarkFor: self) ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> gtOpenBookmarkActionFor: anAction [
	<lePageAction>
	self hasBookmark ifFalse: [ ^ anAction empty ].
	self isBookmark ifTrue: [ ^ anAction empty ].
	^ anAction button
		tooltip: 'Create bookmark';
		priority: 30;
		icon: BrGlamorousVectorIcons bookmarkFilled;
		action: [ :aButton | aButton phlow showObject: (BookmarkRegistry default bookmarkPageFor: self) ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> hasBookmark [
	^ BookmarkRegistry default hasBookmarkFor: self
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> isBookmark [
	^ (BookmarkRegistry default databaseMap values flatCollect: #values)
		includes: self
]
