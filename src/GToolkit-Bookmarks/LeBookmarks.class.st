"
I track, analyze and provide views of bookmarks.

A “bookmark” is just a private page that contains a link to a page in an external database.
From a project page we can find which bookmarks exist, or create a new bookmark if none exists.
"
Class {
	#name : #LeBookmarks,
	#superclass : #Object,
	#instVars : [
		'primaryDB',
		'testDB'
	],
	#category : #'GToolkit-Bookmarks-Model'
}

{ #category : #querying }
LeBookmarks >> bookmark2Pages [
	"Map from all private pages to external project pages."

	^ ((self primaryDB pages select: #isNamedPage)
		collect: [ :bp | 
			bp
				-> (bp allOutgoingExplicitLinks items
						select: [ :link | 
							link isTextualLink
								and: [ link targetReference content notNil
										and: [ link targetReference content isNamedPage
												and: [ link targetReference content database ~= LeDatabase primaryDB ] ] ] ]
						thenCollect: [ :l | l targetReference content ]) asSet ]) asDictionary
]

{ #category : #querying }
LeBookmarks >> bookmarkPageFor: aPage [
	^ self primaryDB pageNamed: (self newBookmarkPageTitle: aPage)
]

{ #category : #querying }
LeBookmarks >> bookmarkPages [
	"Pages with external links."
	^ (self bookmark2Pages associations
		select: [ :bp | bp value isNotEmpty ]
		thenCollect: [ :bp | bp key ]) sortedAs: #title
]

{ #category : #querying }
LeBookmarks >> bookmarksFor: aPage [
	"Given an external project page, return the private pages that link to it."

	^ (self page2Bookmarks at: aPage ifAbsent: Set empty) asOrderedCollection
]

{ #category : #updating }
LeBookmarks >> ensureBookmarkFor: aPage [
	"Return the page if it exists, else create it."

	^ (self hasBookmarkPageFor: aPage)
		ifTrue: [ self primaryDB pageNamed: (self bookmarkPageFor: aPage) ]
		ifFalse: [ self primaryDB addPage: (self newBookmarkPageFor: aPage) ]
]

{ #category : #views }
LeBookmarks >> gtBookmarksFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Bookmarks';
		tooltip: 'Bookmarks are pages in your private Lepiter databasethat link to external project pages.';
		priority: 10;
		items: [ self bookmarkPages ];
		column: 'Index'
			text: [ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray ]
			width: 45;
		column: 'Bookmark page'
			text: [ :each | each title ]
			width: 400;
		column: '# links'
			text: [ :each | (self linkedPagesFor: each) size ]
			width: 100;
		column: 'Bookmarks'
			text: [ :each | self linkedPagesSummaryFor: each ]
			width: 300;
		actionUpdateButton
]

{ #category : #views }
LeBookmarks >> gtLinksFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Links';
		priority: 20;
		items: [ self page2Bookmarks keys sortedAs: #title ];
		column: 'Index'
			text: [ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray ]
			width: 45;
		column: 'Page'
			text: [ :each | each title ]
			width: 400;
		column: '# bookmarks'
			text: [ :each | (self bookmarksFor: each) size ]
			width: 100;
		column: 'Database'
			text: [ :each | each database databaseName ]
			width: 200;
		column: 'Bookmarks'
			text: [ :each | self summaryFor: (self bookmarksFor: each) ]
			width: 200;
		send: [ :each | LePages new items: (self bookmarksFor: each) ];
		actionUpdateButton
]

{ #category : #views }
LeBookmarks >> gtPrimaryDBFor: aView [
	"Only show the full primary DB for test cases."

	<gtView>
	self testDB ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Primary DB';
		priority: 32;
		object: [ self primaryDB ];
		view: #gtLiveFor:
]

{ #category : #views }
LeBookmarks >> gtTestDatabaseFor: aView [
	<gtView>
	self testDB ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Test database';
		priority: 30;
		object: [ self testDB ];
		view: #gtLiveFor:
]

{ #category : #testing }
LeBookmarks >> hasBookmarkPageFor: aPage [
	| bookmarkPageTitle |
	bookmarkPageTitle := self newBookmarkPageTitle: aPage.
	^ self primaryDB hasPageNamed: bookmarkPageTitle
]

{ #category : #querying }
LeBookmarks >> linkedPagesFor: aPage [
	"Given a private page, return the exteranl pages it links to (bookmarks)."

	^ self bookmark2Pages at: aPage ifAbsent: Set empty
]

{ #category : #printing }
LeBookmarks >> linkedPagesSummaryFor: aBookmarkPage [
	^ self
		summaryFor: ((self linkedPagesFor: aBookmarkPage) asOrderedCollection sortedAs: #title)
]

{ #category : #updating }
LeBookmarks >> newBookmarkPageFor: aPage [
	"Creates the page but does not add it anywhere."

	^ (LePage named: (self newBookmarkPageTitle: aPage))
		addSnippet: (LeTextSnippet new
				string: 'Bookmark for: ' , aPage asRemoteLink;
				yourself);
		addSnippet: (LeTextSnippet new
				string: '*My notes ...*';
				yourself);
		yourself
]

{ #category : #updating }
LeBookmarks >> newBookmarkPageTitle: aPage [
	^ 'Bookmark for: ' , aPage title
]

{ #category : #querying }
LeBookmarks >> page2Bookmarks [
	"Reverse index of project pages to private ages that bookmark them.
	Caveat: only bookmarked pages are keys."

	| page2Bookmarks |
	page2Bookmarks := Dictionary new.
	self bookmark2Pages
		associationsDo: [ :b2p | b2p value do: [ :p | (page2Bookmarks at: p ifAbsentPut: Set new) add: b2p key ] ].
	^ page2Bookmarks
]

{ #category : #accessing }
LeBookmarks >> primaryDB [
	^ primaryDB ifNil: [ primaryDB := LeDatabase primaryDB ]
]

{ #category : #accessing }
LeBookmarks >> primaryDB: aDatabase [
	"For testing purposes we can inject an in-memory database.
	See LeBookmarksExamples."

	primaryDB := aDatabase
]

{ #category : #printing }
LeBookmarks >> summaryFor: aPageCollection [
	^ aPageCollection
		ifEmpty: [ '-' ]
		ifNotEmpty: [ aPageCollection first title
				, (aPageCollection size > 1 ifTrue: [ ', ...' ] ifFalse: [ '' ]) ]
]

{ #category : #accessing }
LeBookmarks >> testDB [
	"A place to hold a source database for testing.
	Not used for anythiung else."

	^ testDB
]

{ #category : #accessing }
LeBookmarks >> testDB: aDatabase [
	testDB := aDatabase
]
