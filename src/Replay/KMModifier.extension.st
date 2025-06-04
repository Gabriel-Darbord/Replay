Extension { #name : 'KMModifier' }

{ #category : '*Replay' }
KMModifier >> configureReplayShortcut: aReplayShortcut [

	aReplayShortcut flags: (aReplayShortcut flags bitOr: self eventCode)
]
