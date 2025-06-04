Extension { #name : 'KMComposedModifier' }

{ #category : '*Replay' }
KMComposedModifier >> configureReplayShortcut: aReplayShortcut [

	modifiers do: [ :modifier |
		modifier configureReplayShortcut: aReplayShortcut ]
]
