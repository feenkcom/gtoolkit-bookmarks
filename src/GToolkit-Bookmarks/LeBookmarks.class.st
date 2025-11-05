"
I track, analyze and provide views of bookmarks.

A “bookmark” is just a private page that contains a link to a page in an external database.
From a project page we can find which bookmarks exist, or create a new bookmark if none exists.
"
Class {
	#name : #LeBookmarks,
	#superclass : #Object,
	#category : #'GToolkit-Bookmarks-Model'
}

{ #category : #accessing }
LeBookmarks >> bookmark2Pages [
	"Map from all private pages to external project pages."

	^ ((LeDatabase primaryDB pages select: #isNamedPage)
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

{ #category : #accessing }
LeBookmarks >> bookmarkPages [
	"Pages with external links."
	^ (self bookmark2Pages associations
		select: [ :bp | bp value isNotEmpty ]
		thenCollect: [ :bp | bp key ]) sortedAs: #title
]

{ #category : #queries }
LeBookmarks >> bookmarksFor: aPage [
	"Given an external project page, return the private pages that link to it."

	^ (self page2Bookmarks at: aPage ifAbsent: Set empty) asOrderedCollection
]

{ #category : #views }
LeBookmarks >> gtBookmarksFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Bookmarks';
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
			text: [ :each | (self linkedPagesSummaryFor: each)  ]
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

{ #category : #queries }
LeBookmarks >> linkedPagesFor: aPage [
	"Given a private page, return the exteranl pages it links to (bookmarks)."

	^ self bookmark2Pages at: aPage ifAbsent: Set empty
]

{ #category : #accessing }
LeBookmarks >> linkedPagesSummaryFor: aBookmarkPage [
	^ self
		summaryFor: ((self linkedPagesFor: aBookmarkPage) asOrderedCollection sortedAs: #title)
]

{ #category : #accessing }
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
LeBookmarks >> summaryFor: aPageCollection [
	^ aPageCollection
		ifEmpty: [ '-' ]
		ifNotEmpty: [ aPageCollection first title
				, (aPageCollection size > 1 ifTrue: [ ', ...' ] ifFalse: [ '' ]) ]
]
