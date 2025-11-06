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
	<gtExample>
	| bookmarks gtPage |
	bookmarks := self emptyBookmarks.
	gtPage := bookmarks testDB pageNamed: 'Glamorous Toolkit'.
	
	"Here we need to add a bookmark."

	self assert: bookmarks primaryDB isVolatile.
	self assert: bookmarks testDB isVolatile.
	self assert: bookmarks primaryDB pages isEmpty.
	self assert: bookmarks testDB pages notEmpty.

	^ bookmarks
]
