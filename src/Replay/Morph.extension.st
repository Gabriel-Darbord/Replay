Extension { #name : 'Morph' }

{ #category : '*Replay' }
Morph >> replayIsStillLoading [
	"Answer whether my submorphs are still being built in the background, so that a Replay path through me must wait"

	^ false
]
