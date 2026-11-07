"
I am one key press of a key binding: a key, named as a KeyboardKey is (#S, #LEFT, #F6), and the modifiers held while it is pressed (an Integer mask, see ReplayKeyModifiers).

I name a physical key, so letter case is not part of me: Shift is a modifier like the others. Making me from an uppercase letter holds Shift, as Keymapping does (`$A asKeyCombination` is Shift + A), and decoding a keyboard event takes the modifiers of the event, whatever the case of its character. Two chords are equal when they press the same key with the same modifiers.

I am an immutable value. I convert to a Keymapping combination, decode a Morphic keyboard event (fromKeyboardEvent:), and build the synthetic Morphic keyboard events that press me (keyboardEventOfType:). My class side also names the keys that type no text, for the menus of keyboard actions.

My STON form is a short list: ReplayKeyChord[#S,64], or ReplayKeyChord[#S] without modifiers.
"
Class {
	#name : 'ReplayKeyChord',
	#superclass : 'Object',
	#instVars : [
		'key',
		'modifiers'
	],
	#category : 'Replay-Keys',
	#package : 'Replay',
	#tag : 'Keys'
}

{ #category : 'instance creation' }
ReplayKeyChord class >> character: aCharacter [

	^ self character: aCharacter modifiers: 0
]

{ #category : 'instance creation' }
ReplayKeyChord class >> character: aCharacter modifiers: anInteger [
	"The chord of the key typing aCharacter, or nil when no key types it. An uppercase letter holds Shift."

	| keyName |
	keyName := self keyNameForCharacter: aCharacter.
	keyName ifNil: [ ^ nil ].
	^ self key: keyName modifiers: ((aCharacter isLetter and: [ aCharacter isUppercase ])
			   ifTrue: [ anInteger bitOr: ReplayKeyModifiers shift ]
			   ifFalse: [ anInteger ])
]

{ #category : 'private' }
ReplayKeyChord class >> characterOfEvent: aKeyboardEvent [
	"The character of the key pressed in aKeyboardEvent, or nil for none, such as a modifier key alone"

	| character |
	character := [ aKeyboardEvent modifiedCharacter ]
		             on: Error
		             do: [ self fallbackCharacterOfEvent: aKeyboardEvent ].
	(character isNil or: [ character asInteger = 0 ]) ifTrue: [ ^ nil ].
	^ character
]

{ #category : 'private' }
ReplayKeyChord class >> fallbackCharacterOfEvent: aKeyboardEvent [
	"For events without a character code. Control + letter may come as the control character of the letter."

	| value |
	value := aKeyboardEvent keyValue ifNil: [ ^ nil ].
	((value between: 1 and: 26) and: [ (ReplayKeyModifiers fromEvent: aKeyboardEvent) ~= 0 ]) ifTrue: [
		^ Character value: $a asInteger + value - 1 ].
	^ Character value: value
]

{ #category : 'instance creation' }
ReplayKeyChord class >> fromKeyboardEvent: aKeyboardEvent [
	"The chord pressed in aKeyboardEvent, with its modifiers, or nil when it presses no key I can name"

	| modifiers character |
	modifiers := ReplayKeyModifiers fromEvent: aKeyboardEvent.
	(modifiers ~= 0 and: [ aKeyboardEvent keyValue = 0 ]) ifTrue: [ ^ nil "A modifier key alone" ].
	character := (self characterOfEvent: aKeyboardEvent) ifNil: [ ^ nil ].
	^ self character: character asLowercase modifiers: modifiers
]

{ #category : 'instance creation' }
ReplayKeyChord class >> key: aSymbol [

	^ self key: aSymbol modifiers: 0
]

{ #category : 'instance creation' }
ReplayKeyChord class >> key: aSymbol modifiers: anInteger [
	"aSymbol names a KeyboardKey"

	^ self basicNew setKey: aSymbol asSymbol modifiers: anInteger
]

{ #category : 'keys' }
ReplayKeyChord class >> keyChoices [
	"The keys that type no text, as selector -> label associations for menus"

	^ self namedKeys collect: [ :entry | entry first -> entry second ]
]

{ #category : 'keys' }
ReplayKeyChord class >> keyNameForCharacter: aCharacter [
	"The name of the key typing aCharacter without Shift, or nil when none does"

	self namedKeys
		detect: [ :entry | entry third = aCharacter ]
		ifFound: [ :entry | ^ (KeyboardKey perform: entry first) name ].
	"Other keys are named after the Latin-1 character they type"
	(aCharacter asInteger between: 33 and: 255) ifFalse: [ ^ nil ].
	^ [ (KeyboardKey value: aCharacter asUppercase asInteger) name ]
		  on: KeyNotFound
		  do: [ nil ]
]

{ #category : 'keys' }
ReplayKeyChord class >> keySelectorForCharacter: aCharacter [
	"The selector of the named key whose events carry aCharacter, or nil"

	^ self namedKeys
		  detect: [ :entry | entry third = aCharacter ]
		  ifFound: [ :entry | entry first ]
		  ifNone: [ nil ]
]

{ #category : 'events' }
ReplayKeyChord class >> keyboardEventOfType: aSymbol key: aKeyboardKey character: aCharacter modifiers: anInteger [
	"The one builder of the synthetic Morphic keyboard events of Replay.
	aSymbol is #keyDown, #keystroke or #keyUp, aKeyboardKey may be nil for a typed character."

	| event |
	event := KeyboardEvent new
		         setType: aSymbol
		         buttons: anInteger
		         position: 0 @ 0
		         keyValue: aCharacter asInteger
		         charCode: aCharacter asInteger
		         hand: self currentWorld activeHand
		         stamp: Time millisecondClockValue.
	aKeyboardKey ifNotNil: [ event key: aKeyboardKey ].
	^ event
]

{ #category : 'keys' }
ReplayKeyChord class >> namedKey: aSelector [
	"The chord of a key named by a KeyboardKey class selector, such as #left"

	^ self key: (KeyboardKey perform: aSelector) name
]

{ #category : 'keys' }
ReplayKeyChord class >> namedKeys [
	"The keys that type no text (and Space), as { KeyboardKey class selector. label. character }.
	The character is the one Morphic keyboard events carry for the key, as the OSWindow event handler maps it."

	^ {
		  { #left. 'Left'. Character arrowLeft }.
		  { #right. 'Right'. Character arrowRight }.
		  { #up. 'Up'. Character arrowUp }.
		  { #down. 'Down'. Character arrowDown }.
		  { #home. 'Home'. Character home }.
		  { #end. 'End'. Character end }.
		  { #pageUp. 'Page Up'. Character pageUp }.
		  { #pageDown. 'Page Down'. Character pageDown }.
		  { #backspace. 'Backspace'. Character backspace }.
		  { #delete. 'Delete'. Character delete }.
		  { #enter. 'Enter'. Character cr }.
		  { #escape. 'Escape'. Character escape }.
		  { #tab. 'Tab'. Character tab }.
		  { #space. 'Space'. Character space } }
]

{ #category : 'comparing' }
ReplayKeyChord >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ key = anObject key and: [ self modifiers = anObject modifiers ]
]

{ #category : 'converting' }
ReplayKeyChord >> asKMShortcut [
	"My Keymapping combination, or nil when Keymapping does not know my key"

	| keyboardKey |
	keyboardKey := self keyboardKey ifNil: [ ^ nil ].
	^ ReplayKeyModifiers modified: keyboardKey asKeyCombination by: self modifiers
]

{ #category : 'events' }
ReplayKeyChord >> character [
	"The character Morphic keyboard events carry when I am pressed: a control character for the keys that type no text, the unshifted character they type for the others, and the null character for the keys typing none"

	| keyboardKey |
	keyboardKey := self keyboardKey ifNil: [ ^ Character value: 0 ].
	self class namedKeys do: [ :entry |
		(KeyboardKey perform: entry first) = keyboardKey ifTrue: [ ^ entry third ] ].
	keyboardKey value < 256 ifTrue: [ ^ (Character value: keyboardKey value) asLowercase ].
	^ Character value: 0
]

{ #category : 'displaying' }
ReplayKeyChord >> displayString [
	"As Keymapping prints me, when it knows my key"

	^ self asKMShortcut
		  ifNotNil: [ :combination | combination asString ]
		  ifNil: [ ' + ' join: (ReplayKeyModifiers namesOf: self modifiers) , { key } ]
]

{ #category : 'ston' }
ReplayKeyChord >> fromSton: stonReader [

	stonReader parseListDo: [ :each :index |
		index = 1 ifTrue: [ key := each asSymbol ].
		index = 2 ifTrue: [ modifiers := each ] ]
]

{ #category : 'testing' }
ReplayKeyChord >> hasModifier: aMask [

	^ (self modifiers bitAnd: aMask) = aMask
]

{ #category : 'comparing' }
ReplayKeyChord >> hash [

	^ key hash bitXor: self modifiers hash
]

{ #category : 'accessing' }
ReplayKeyChord >> key [
	"The name of my KeyboardKey"

	^ key
]

{ #category : 'events' }
ReplayKeyChord >> keyboardEventOfType: aSymbol [
	"A synthetic Morphic event pressing me: #keyDown and #keyUp carry my character, #keystroke the character I type"

	^ self class
		  keyboardEventOfType: aSymbol
		  key: self keyboardKey
		  character: (aSymbol = #keystroke
				   ifTrue: [ self typedCharacter ]
				   ifFalse: [ self character ])
		  modifiers: self modifiers
]

{ #category : 'accessing' }
ReplayKeyChord >> keyboardKey [
	"Nil when no KeyboardKey has my key name"

	^ [ KeyboardKey named: key ]
		  on: KeyNotFound
		  do: [ nil ]
]

{ #category : 'accessing' }
ReplayKeyChord >> modifiers [

	^ modifiers ifNil: [ 0 ]
]

{ #category : 'printing' }
ReplayKeyChord >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self displayString;
		nextPut: $)
]

{ #category : 'initialization' }
ReplayKeyChord >> setKey: aSymbol modifiers: anInteger [

	key := aSymbol.
	modifiers := anInteger
]

{ #category : 'ston' }
ReplayKeyChord >> stonOn: stonWriter [

	stonWriter writeObject: self streamShortList: [ :array |
		array add: key.
		self modifiers = 0 ifFalse: [ array add: self modifiers ] ]
]

{ #category : 'events' }
ReplayKeyChord >> typedCharacter [
	"The character I type, as a keystroke event carries it"

	^ (self hasModifier: ReplayKeyModifiers shift)
		  ifTrue: [ self character asUppercase ]
		  ifFalse: [ self character ]
]

{ #category : 'testing' }
ReplayKeyChord >> typesText [
	"Whether pressing me types text, so that a real keyboard also sends a keystroke event"

	(ReplayKeyModifiers hasShortcutModifier: self modifiers) ifTrue: [ ^ false ].
	^ self character asInteger >= 32 and: [ self character asInteger ~= 127 ]
]

{ #category : 'converting' }
ReplayKeyChord >> withModifiers: anInteger [

	^ self class key: key modifiers: anInteger
]
