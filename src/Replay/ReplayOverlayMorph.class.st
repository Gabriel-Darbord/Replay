"
I am the transparent overlay that a ReplayUIManager puts over the UI it manages or attaches to. I hold the annotations of the scenario, and block the user's interactions with the UI below me when the manager owns it.

The events of a ReplayHandMorph go through me, so that a replayed drag can drop on the UI I cover.
"
Class {
	#name : 'ReplayOverlayMorph',
	#superclass : 'Morph',
	#category : 'Replay-Morphs',
	#package : 'Replay',
	#tag : 'Morphs'
}

{ #category : 'initialization' }
ReplayOverlayMorph >> initialize [

	super initialize.
	self
		beTransparent;
		hResizing: #spaceFill;
		vResizing: #spaceFill
]

{ #category : 'event handling' }
ReplayOverlayMorph >> rejectsEvent: anEvent [

	^ (anEvent hand isKindOf: ReplayHandMorph) or: [
		  super rejectsEvent: anEvent ]
]
