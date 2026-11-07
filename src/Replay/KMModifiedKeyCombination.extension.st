Extension { #name : 'KMModifiedKeyCombination' }

{ #category : '*Replay' }
KMModifiedKeyCombination >> replayKeyBindings [

	^ self character replayKeyBindings collect: [ :binding |
		  binding withAddedModifiers: self modifier replayModifiers ]
]
