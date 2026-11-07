Extension { #name : 'KMPlatformSpecificKeyCombination' }

{ #category : '*Replay' }
KMPlatformSpecificKeyCombination >> replayKeyBindings [
	"Only the shortcut of the current platform triggers anything"

	self platform == OSPlatform current platformFamily ifFalse: [ ^ #(  ) ].
	^ self shortcut replayKeyBindings
]
