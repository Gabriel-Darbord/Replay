Extension { #name : 'KeyboardKey' }

{ #category : '*Replay' }
KeyboardKey >> configureReplayShortcut: aReplayShortcut [

	aReplayShortcut appendText: self asCharacter
]
