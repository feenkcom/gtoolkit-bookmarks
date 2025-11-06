Extension { #name : #LePage }

{ #category : #'*GToolkit-Bookmarks' }
LePage >> gtCreateBookmarkActionFor: anAction [
	"NB: this is a gtACtion, not a lePageAction, because it will show in the gtPageActionsDropdownMenuFor:"

	<gtAction>
	self database isPrimary ifTrue: [ ^ anAction empty ].
	^ anAction button
		tooltip: 'Bookmark this page';
		priority: 30;
		icon: BrGlamorousVectorIcons bookmark;
		target: LePageActionTarget;
		menuItemGroup: BrMenuItemGroupConfiguration navigation;
		action: [ :aButton | 
			| bookmarkPage |
			bookmarkPage := LeBookmarks new ensureBookmarkFor: self.
			aButton phlow spawnObject: bookmarkPage ]
]
