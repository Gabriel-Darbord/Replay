Extension { #name : 'KMSingleKeyCombination' }

{ #category : '*Replay' }
KMSingleKeyCombination >> replayKeyBindings [
	"Subclasses naming a character instead of a key have no KeyboardKey"

	(key isKindOf: KeyboardKey) ifFalse: [ ^ #(  ) ].
	^ { ReplayKeyBinding chords: { ReplayKeyChord key: key name } }
]
