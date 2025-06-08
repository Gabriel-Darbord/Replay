Extension { #name : 'KMModifier' }

{ #category : '*Replay' }
KMModifier >> configureReplayShortcut: aReplayShortcut [

	aReplayShortcut addFlags: self eventCode
]
