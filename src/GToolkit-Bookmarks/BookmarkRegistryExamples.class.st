Class {
	#name : #BookmarkRegistryExamples,
	#superclass : #Object,
	#traits : 'TDatabaseHolder',
	#classTraits : 'TDatabaseHolder classTrait',
	#category : #'GToolkit-Bookmarks-Examples'
}

{ #category : #examples }
BookmarkRegistryExamples >> cleanTestRegistry [
	<gtExample>
	| registry |
	BookmarkRegistry reset.
	registry := BookmarkRegistry forTesting.
	self assert: registry database isVolatile.
	self assert: registry bookmarks isEmpty.
	^ registry
]

{ #category : #examples }
BookmarkRegistryExamples >> gtBookPageGetsBookmark [
	<gtExample>
	| db registry gtPage bookmarkPage |
	db := LeDatabase gtBook.
	gtPage := db pageNamed: 'Glamorous Toolkit'.
	registry := self testRegistry.
	registry ensureBookmarkFor: gtPage.
	bookmarkPage := registry bookmarkPageFor: gtPage.
	self assert: (registry hasBookmarkFor: gtPage).
	^ bookmarkPage
]

{ #category : #page }
BookmarkRegistryExamples >> gtPage [
	<lePage>
	<gtExample>
	<noTest>
	^ (LePage named: 'Glamorous Toolkit')
		addSnippet: (LeTextSnippet new
				string: 'A page with the same title as a page in the GT Book.';
				yourself);
		yourself
]

{ #category : #examples }
BookmarkRegistryExamples >> gtPageGetsBookmark [
	<gtExample>
	| db registry gtPage bookmarkPage |
	db := self sourceDatabase.
	gtPage := db pageNamed: 'Glamorous Toolkit'.
	registry := self testRegistry.
	registry addBookmarkFor: gtPage.
	bookmarkPage := registry bookmarkPageFor: gtPage.
	self assert: (registry hasBookmarkFor: gtPage).
	^ bookmarkPage
]

{ #category : #page }
BookmarkRegistryExamples >> page1 [
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

{ #category : #examples }
BookmarkRegistryExamples >> page1DeletesBookmark [
	<gtExample>
	| p1 registry db |
	db := self page1GetsBookmark.
	p1 := db pageNamed: 'Page 1'.
	registry := self testRegistry.
	registry removeBookmarkFor: p1.
	self assert: (registry hasBookmarkFor: p1) not.
	self assert: registry bookmarks isEmpty.
	^ db
]

{ #category : #examples }
BookmarkRegistryExamples >> page1GetsBookmark [
	<gtExample>
	| p1 registry db |
	db := self page1HasNoBookmark.
	p1 := db pageNamed: 'Page 1'.
	registry := self testRegistry.
	registry addBookmarkFor: p1.
	self assert: (registry hasBookmarkFor: p1).
	self assert: registry bookmarks size equals: 1.
	^ db
]

{ #category : #examples }
BookmarkRegistryExamples >> page1HasNoBookmark [
	<gtExample>
	| db p1 registry |
	db := self sourceDatabase.
	p1 := db pageNamed: 'Page 1'.
	registry := self testRegistry.
	self assert: (registry hasBookmarkFor: p1) not.
	self assert: registry bookmarks isEmpty.
	^ db
]

{ #category : #page }
BookmarkRegistryExamples >> page2 [
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
BookmarkRegistryExamples >> page3 [
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

{ #category : #examples }
BookmarkRegistryExamples >> sourceDatabase [
	<gtExample>
	| db |
	db := self database monitor: self cleanTestRegistry database monitor.
	self assert: db pages size equals: 4.
	self assert: db isVolatile.
	^ db
]

{ #category : #examples }
BookmarkRegistryExamples >> testRegistry [
	"NB: This will return the singleton in its current state, not a fresh one.
	To get a fresh registry use cleanTestRegistry."

	<gtExample>
	| registry |
	registry := BookmarkRegistry forTesting.
	self assert: registry database isVolatile.
	^ registry
]
