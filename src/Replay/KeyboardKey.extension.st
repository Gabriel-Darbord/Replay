Extension { #name : 'KeyboardKey' }

{ #category : '*Replay' }
KeyboardKey >> asCharacter [

	| keyChar keyTable |
	keyChar := value asCharacter.
	(keyTable := self class keyFromCharacterTable)
		at: keyChar
		ifPresent: [ :key | key value == value ifTrue: [ ^ keyChar ] ]
		ifAbsent: [ ^ keyChar ].

	"Use inverse mapping based on key name"
	keyTable associationsDo: [ :charAndKey |
		charAndKey value name asUppercase = name ifTrue: [ ^ charAndKey key ] ].

	self error: 'Equivalent character not found'
]

{ #category : '*Replay' }
KeyboardKey >> configureReplayShortcut: aReplayShortcut [

	aReplayShortcut appendText: self asCharacter
]
