"
I provide examples of {{gtClass:name=LeBookmarks}} using the {{gtClass:name=InMemoryMockBookmarkDatabase}} to provide the in-memory source database and the bookmarks database as standin for the actual primary database.
"
Class {
	#name : #LeBookmarksExamples,
	#superclass : #Object,
	#category : #'GToolkit-Bookmarks-Examples'
}

{ #category : #'as yet unclassified' }
LeBookmarksExamples >> emptyBookmarks [
	<gtExample>
	| databases bookmarks primaryDB testDB |
	databases := InMemoryMockBookmarkDatabases new.
	primaryDB := databases bookmarkDatabase.
	testDB := databases database.
	bookmarks := LeBookmarks new
			primaryDB: primaryDB;
			testDB: testDB.

	self assert: primaryDB isVolatile.
	self assert: testDB isVolatile.
	self assert: primaryDB pages isEmpty.
	self assert: testDB pages notEmpty.

	^ bookmarks
]

{ #category : #'as yet unclassified' }
LeBookmarksExamples >> gtPageGetsBookmark [
	"NB: for the volatile databases, the cross database links are not working."

	<gtExample>
	| bookmarks page newPage |
	bookmarks := self emptyBookmarks.
	page := bookmarks testDB pageNamed: 'Glamorous Toolkit'.	"Here we need to add a bookmark."
	newPage := bookmarks ensureBookmarkFor: page.

	self assert: bookmarks primaryDB pages size equals: 1.
	self assert: (bookmarks hasBookmarkPageFor: page).

	^ bookmarks
]

{ #category : #'as yet unclassified' }
LeBookmarksExamples >> page1DeletesBookmark [
	<gtExample>
	| bookmarks page bookmarkPage |
	bookmarks := self page2GetsBookmark.
	page := bookmarks testDB pageNamed: 'Page 1'.
	bookmarkPage := bookmarks bookmarkPageFor: page.
	bookmarkPage removeSelf.

	self assert: bookmarks primaryDB pages size equals: 2.
	self assert: (bookmarks hasBookmarkPageFor: page) not.

	^ bookmarks
]

{ #category : #'as yet unclassified' }
LeBookmarksExamples >> page1GetsBookmark [
	"NB: for the volatile databases, the cross database links are not working."

	<gtExample>
	| bookmarks page newPage |
	bookmarks := self gtPageGetsBookmark.
	page := bookmarks testDB pageNamed: 'Page 1'.
	newPage := bookmarks ensureBookmarkFor: page.

	self assert: bookmarks primaryDB pages size equals: 2.
	self assert: (bookmarks hasBookmarkPageFor: page).

	^ bookmarks
]

{ #category : #'as yet unclassified' }
LeBookmarksExamples >> page2GetsBookmark [
	"NB: for the volatile databases, the cross database links are not working."

	<gtExample>
	| bookmarks page newPage |
	bookmarks := self page1GetsBookmark.
	page := bookmarks testDB pageNamed: 'Page 2'.
	newPage := bookmarks ensureBookmarkFor: page.

	self assert: bookmarks primaryDB pages size equals: 3.
	self assert: (bookmarks hasBookmarkPageFor: page).

	^ bookmarks
]
