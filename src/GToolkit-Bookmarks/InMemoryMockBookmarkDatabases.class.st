"
I am an in-memory database holder for *two* databases that share a common monitor.
One is the source database for bookmarks, and the other is bookmark database that stands in for the primaryDB for testing purposes.

"
Class {
	#name : #InMemoryMockBookmarkDatabases,
	#superclass : #Object,
	#traits : 'TDatabaseHolder',
	#classTraits : 'TDatabaseHolder classTrait',
	#instVars : [
		'bookmarkDatabase'
	],
	#category : #'GToolkit-Bookmarks-Examples'
}

{ #category : #accessing }
InMemoryMockBookmarkDatabases >> bookmarkDatabase [
	^ bookmarkDatabase
]

{ #category : #accessing }
InMemoryMockBookmarkDatabases >> database [
	^ database
]

{ #category : #view }
InMemoryMockBookmarkDatabases >> gtBookmarkDatabaseFor: aView [
	<gtView>
	^ aView forward
		title: 'Bookmarks';
		priority: 20;
		object: [ self bookmarkDatabase ];
		view: #gtLiveFor:;
		actionUpdateButton
]

{ #category : #view }
InMemoryMockBookmarkDatabases >> gtDatabaseFor: aView [
	<gtView>
	^ aView forward
		title: 'Source Database';
		priority: 10;
		object: [ self database ];
		view: #gtLiveFor:;
		actionUpdateButton
]

{ #category : #page }
InMemoryMockBookmarkDatabases >> gtPage [
	<lePage>
	<gtExample>
	<noTest>
	^ (LePage named: 'Glamorous Toolkit')
		addSnippet: (LeTextSnippet new
				string: 'A page with the same title as a page in the GT Book.';
				yourself);
		yourself
]

{ #category : #initialization }
InMemoryMockBookmarkDatabases >> initialize [
	| volatileMonitor |
	volatileMonitor := LeVolatileMonitor new.
	database := LeDatabase new monitor: volatileMonitor.
	bookmarkDatabase := LeDatabase new monitor: volatileMonitor.
	LeBasicDatabasesRegistry new
		defaultLogicalDatabase: (LeLogicalDatabase new primaryDB: bookmarkDatabase).
	self initializeDatabase
]

{ #category : #page }
InMemoryMockBookmarkDatabases >> page1 [
	<lePage>
	<gtExample>
	<noTest>
	^ (LePage named: 'Page 1')
		addSnippet: (LeTextSnippet new
				string: 'A sample page.';
				yourself);
		addSnippet: (LeTextSnippet new
				string: 'I link to [[Page 2]].';
				yourself);
		yourself
]

{ #category : #page }
InMemoryMockBookmarkDatabases >> page2 [
	<lePage>
	<gtExample>
	<noTest>
	^ (LePage named: 'Page 2')
		addSnippet: (LeTextSnippet new
				string: 'Another sample page';
				yourself);
		addSnippet: (LeTextSnippet new
				string: 'I link to [[Page 1]] and [[Page 3]].';
				yourself);
		yourself
]

{ #category : #page }
InMemoryMockBookmarkDatabases >> page3 [
	<lePage>
	<gtExample>
	<noTest>
	^ (LePage named: 'Page 3')
		addSnippet: (LeTextSnippet new
				string: 'Yet another sample page';
				yourself);
		addSnippet: (LeTextSnippet new
				string: 'I link to [[Page 1]] and [[Page 2]].';
				yourself);
		yourself
]
