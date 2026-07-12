Extension { #name : 'KMModifiedKeyCombination' }

{ #category : '*Replay' }
KMModifiedKeyCombination >> configureReplayShortcut: aReplayShortcut [

	self modifier configureReplayShortcut: aReplayShortcut.
	self character configureReplayShortcut: aReplayShortcut
]
