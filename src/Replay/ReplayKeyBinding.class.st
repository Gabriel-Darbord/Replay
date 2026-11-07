"
I am a key binding: the sequence of key chords (ReplayKeyChord) that triggers a shortcut, such as Cmd + T then Cmd + S. Each chord holds its own modifiers. I am empty when no key is bound.

A macro holds one of me, a Shortcut action replays one, and ReplayKeyBindingPresenter edits one.

I am an immutable value, equal to a binding with the same chords; editing me answers a new binding. I convert to Keymapping (asKMShortcut) and from it (fromKMCombination:, fromKeymap:). The conversion from Keymapping relies on the replayKeyBindings extension of its combinations: it answers no binding for the combinations I cannot represent, and one binding per alternative of a choice. fromKeyboardEvent: decodes the binding a Morphic key press stands for.

My STON form is a short list of chords: ReplayKeyBinding[ReplayKeyChord[#T,64],ReplayKeyChord[#S,64]].
"
Class {
	#name : 'ReplayKeyBinding',
	#superclass : 'Object',
	#instVars : [
		'chords'
	],
	#category : 'Replay-Keys',
	#package : 'Replay',
	#tag : 'Keys'
}

{ #category : 'instance creation' }
ReplayKeyBinding class >> character: aCharacter modifiers: anInteger [
	"The binding of one chord, typing aCharacter with modifiers held"

	^ self chords: { (ReplayKeyChord character: aCharacter modifiers: anInteger) ifNil: [
			   self error: 'No key types ' , aCharacter printString ] }
]

{ #category : 'instance creation' }
ReplayKeyBinding class >> chords: aCollectionOfReplayKeyChords [

	^ self basicNew setChords: aCollectionOfReplayKeyChords asArray
]

{ #category : 'instance creation' }
ReplayKeyBinding class >> fromKMCombination: aKMKeyCombination [
	"The binding of a Keymapping combination, or nil when I cannot represent it.
	For a choice of combinations, the binding of its first alternative."

	^ aKMKeyCombination replayKeyBindings
		  ifEmpty: [ nil ]
		  ifNotEmpty: [ :bindings | bindings first ]
]

{ #category : 'instance creation' }
ReplayKeyBinding class >> fromKeyboardEvent: aKeyboardEvent [
	"The binding of the key pressed in aKeyboardEvent, or nil when it presses no key I can name"

	^ (ReplayKeyChord fromKeyboardEvent: aKeyboardEvent) ifNotNil: [ :chord |
		  self chords: { chord } ]
]

{ #category : 'instance creation' }
ReplayKeyBinding class >> fromKeymap: aKMKeymap [

	^ self fromKMCombination: aKMKeymap shortcut
]

{ #category : 'instance creation' }
ReplayKeyBinding class >> new [

	^ self chords: #(  )
]

{ #category : 'combining' }
ReplayKeyBinding >> , aReplayKeyBinding [

	^ self class chords: self chords , aReplayKeyBinding chords
]

{ #category : 'comparing' }
ReplayKeyBinding >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ self chords = anObject chords
]

{ #category : 'converting' }
ReplayKeyBinding >> asKMShortcut [
	"My Keymapping shortcut, KMNoShortcut when I am empty, or nil when Keymapping does not know one of my keys"

	| combinations |
	self isEmpty ifTrue: [ ^ KMNoShortcut new ].
	combinations := self chords collect: [ :chord | chord asKMShortcut ifNil: [ ^ nil ] ].
	^ combinations allButFirst
		  inject: combinations first
		  into: [ :shortcut :next | shortcut , next ]
]

{ #category : 'accessing' }
ReplayKeyBinding >> chords [

	^ chords
]

{ #category : 'copying' }
ReplayKeyBinding >> copyReplacingChordAt: anIndex with: aReplayKeyChord [

	^ self class chords: (self chords copy
			   at: anIndex put: aReplayKeyChord;
			   yourself)
]

{ #category : 'copying' }
ReplayKeyBinding >> copyWith: aReplayKeyChord [

	^ self class chords: (self chords copyWith: aReplayKeyChord)
]

{ #category : 'copying' }
ReplayKeyBinding >> copyWithoutChordAt: anIndex [

	^ self class chords: (self chords copyWithoutIndex: anIndex)
]

{ #category : 'printing' }
ReplayKeyBinding >> displayString [

	^ ', ' join: (self chords collect: [ :chord | chord displayString ])
]

{ #category : 'ston' }
ReplayKeyBinding >> fromSton: stonReader [

	| readChords |
	readChords := OrderedCollection new.
	stonReader parseListDo: [ :each :index | readChords add: each ].
	chords := readChords asArray
]

{ #category : 'comparing' }
ReplayKeyBinding >> hash [

	^ self chords hash
]

{ #category : 'testing' }
ReplayKeyBinding >> isEmpty [

	^ self chords isEmpty
]

{ #category : 'testing' }
ReplayKeyBinding >> isKeymappable [
	"Whether Keymapping can install me: I have chords, and it knows each of their keys"

	^ self notEmpty and: [ self chords allSatisfy: [ :chord | chord keyboardKey notNil ] ]
]

{ #category : 'testing' }
ReplayKeyBinding >> matchesKeymap: aKMKeymap [
	"Whether I trigger aKMKeymap, or one of its alternatives"

	self isEmpty ifTrue: [ ^ false ].
	^ aKMKeymap shortcut replayKeyBindings includes: self
]

{ #category : 'testing' }
ReplayKeyBinding >> notEmpty [

	^ self isEmpty not
]

{ #category : 'printing' }
ReplayKeyBinding >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self displayString;
		nextPut: $)
]

{ #category : 'initialization' }
ReplayKeyBinding >> setChords: anArray [

	chords := anArray
]

{ #category : 'ston' }
ReplayKeyBinding >> stonOn: stonWriter [

	stonWriter writeObject: self streamShortList: [ :array |
		self chords do: [ :chord | array add: chord ] ]
]

{ #category : 'converting' }
ReplayKeyBinding >> withAddedModifiers: anInteger [
	"Myself with anInteger modifiers also held on each chord"

	^ self class chords: (self chords collect: [ :chord |
			   chord withModifiers: (chord modifiers bitOr: anInteger) ])
]
