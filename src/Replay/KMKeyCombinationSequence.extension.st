Extension { #name : 'KMKeyCombinationSequence' }

{ #category : '*Replay' }
KMKeyCombinationSequence >> configureReplayShortcut: aReplayShortcut [

	self sequence do: [ :shortcut |
		shortcut configureReplayShortcut: aReplayShortcut ]
]
