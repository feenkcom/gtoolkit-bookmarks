Class {
	#name : #BaselineOfGToolkitBookmarks,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkitBookmarks
}

{ #category : #loading }
BaselineOfGToolkitBookmarks class >> loadLepiter [
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = 'gtoolkit-bookmarks' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [
			self inform: 'Repository not found.' ]
]

{ #category : #baseline }
BaselineOfGToolkitBookmarks >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'GToolkit-Bookmarks'
		]
]
