Extension { #name : #LeDatabase }

{ #category : #'*GToolkit-Bookmarks' }
LeDatabase >> isVolatile [
	^ self monitor isVolatileMonitor
]
