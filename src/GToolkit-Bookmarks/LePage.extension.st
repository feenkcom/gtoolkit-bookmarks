Extension { #name : #LePage }

{ #category : #'*GToolkit-Bookmarks' }
LePage >> gtBookmarkedPagesFor: anAction [
	<gtAction>
	| pages |
	pages := LeBookmarks new linkedPagesFor: self.
	pages ifEmpty: [ ^ anAction empty ].
	self database isPrimary ifFalse: [ ^ anAction empty ].
	^ anAction button
		tooltip: 'All (' , pages size printString , ') pages bookmarked from here';
		priority: 20;
		icon: BrGlamorousVectorIcons changes;
		target: LePageActionTarget;
		menuItemGroup: BrMenuItemGroupConfiguration navigation;
		action: [ :aButton | aButton phlow spawnObject: (LePages new items: (pages sortedAs: #title)) ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> gtBookmarksFor: anAction [
	<gtAction>
	| bookmarks |
	bookmarks := LeBookmarks new bookmarksFor: self.
	bookmarks ifEmpty: [ ^ anAction empty ].
	self database isPrimary ifTrue: [ ^ anAction empty ].
	^ anAction button
		tooltip: 'All (' , bookmarks size printString , ') bookmarks for this page';
		priority: 20;
		icon: BrGlamorousVectorIcons changes;
		target: LePageActionTarget;
		menuItemGroup: BrMenuItemGroupConfiguration navigation;
		action: [ :aButton | aButton phlow spawnObject: (LePages new items: (bookmarks sortedAs: #title)) ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> gtBookmarksForThisDatabaseFor: anAction [
	<gtAction>
	| bookmarks |
	bookmarks := LeBookmarks new bookmarksForDatabase: self database.
	bookmarks ifEmpty: [ ^ anAction empty ].
	self database isPrimary ifTrue: [ ^ anAction empty ].
	^ anAction button
		tooltip: 'All (' , bookmarks size printString , ') bookmarks for this database';
		priority: 22;
		icon: LeIcons lepiterDatabase;
		target: LePageActionTarget;
		menuItemGroup: BrMenuItemGroupConfiguration navigation;
		action: [ :aButton | aButton phlow spawnObject: (LePages new items: (bookmarks sortedAs: #title)) ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> gtCreateBookmarkActionFor: anAction [
	<gtAction>
	self database isPrimary ifTrue: [ ^ anAction empty ].
	^ anAction button
		tooltip: 'Bookmark this page';
		priority: 10;
		icon: BrGlamorousVectorIcons bookmark;
		target: LePageActionTarget;
		menuItemGroup: BrMenuItemGroupConfiguration navigation;
		action: [ :aButton | 
			| bookmarkPage |
			bookmarkPage := LeBookmarks new ensureBookmarkFor: self.
			aButton phlow spawnObject: bookmarkPage ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> gtInspectBookmarkActionFor: anAction [
	<gtAction>
	^ anAction button
		tooltip: 'All bookmarks';
		priority: 40;
		icon: BrGlamorousVectorIcons inspect;
		target: LePageActionTarget;
		menuItemGroup: BrMenuItemGroupConfiguration navigation;
		action: [ :aButton | aButton phlow spawnObject: LeBookmarks new ]
]

{ #category : #'*GToolkit-Bookmarks' }
LePage >> gtMapForThisDatabaseFor: anAction [
	<gtAction>
	self database isPrimary ifTrue: [ ^ anAction empty ].
	^ anAction button
		tooltip: 'Map of bookmarks for this database';
		priority: 25;
		icon: LeIcons lepiterDatabase;
		target: LePageActionTarget;
		menuItemGroup: BrMenuItemGroupConfiguration navigation;
		action: [ :aButton | 
			aButton phlow
				spawnObject: (LeBookmarks new mapFor: GtMondrian new forDatabase: self database) ]
]
