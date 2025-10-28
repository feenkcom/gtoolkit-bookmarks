Extension { #name : #BrGlamorousVectorIcons }

{ #category : #'*GToolkit-Bookmarks' }
BrGlamorousVectorIcons class >> bookmarkFilled [
	<script: 'self bookmark'>
	^ [ BlElement new
		size: 16 @ 16;
		geometry: (BlSvgPath new
				svg: 'M 12 14 L 12 2 L 4 2 L 4 14 L 8 11.230769 Z'
				viewbox: (0 @ 0 extent: 16 @ 16));
		background: Color darkGray;
		border: Color darkGray ] asStencil
]
