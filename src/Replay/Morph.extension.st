Extension { #name : 'Morph' }

{ #category : '*Replay' }
Morph >> replayIsStillLoading [
	"Answer whether my submorphs are still being built in the background, so that a Replay path through me must wait"

	^ false
]

{ #category : '*Replay' }
Morph >> replayHandles: anEvent with: aSelector [
	"Whether Morphic would give me anEvent to handle: I do not reject it, and I answer true to aSelector, such as handlesMouseDown:"

	^ (self rejectsEvent: anEvent) not and: [ self perform: aSelector with: anEvent ]
]
