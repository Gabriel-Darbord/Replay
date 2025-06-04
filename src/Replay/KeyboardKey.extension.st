Extension { #name : 'KeyboardKey' }

{ #category : '*Replay' }
KeyboardKey >> configureReplayShortcut: aReplayShortcut [

	aReplayShortcut text:
		(aReplayShortcut text copyWith: self asCharacter)
]
