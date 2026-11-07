"
I press a named keyboard key (see ReplayKeyChord class>>namedKeys), optionally repeated and with modifiers (a ReplayKeyModifiers mask).

Like a real keyboard, each press sends a key down event, a keystroke event when the key types text (Space without shortcut modifier), and a key up event. Morphic and Rubric act on the key down of the keys that type no text: a keystroke for them would insert a control character.
"
Class {
	#name : 'ReplayPressKey',
	#superclass : 'ReplayKeyboardEvent',
	#instVars : [
		'keySelector',
		'repeatCount',
		'modifiers'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplayPressKey class >> editorClass [

	^ ReplayPressKeyEditor
]

{ #category : 'accessing' }
ReplayPressKey class >> displayName [

	^ 'Press key'
]

{ #category : 'accessing' }
ReplayPressKey class >> keyChoices [

	^ ReplayKeyChord keyChoices
]

{ #category : 'accessing' }
ReplayPressKey >> chord [
	"The key I press, with my modifiers"

	^ (ReplayKeyChord namedKey: self keySelector) withModifiers: self modifiers
]

{ #category : 'initialization' }
ReplayPressKey >> initialize [

	super initialize.
	keySelector := #left.
	repeatCount := 1
]

{ #category : 'accessing' }
ReplayPressKey >> keyLabel [

	^ self class keyChoices
		detect: [ :association | association key = self keySelector ]
		ifFound: [ :association | association value ]
		ifNone: [ self keySelector asString ]
]

{ #category : 'accessing' }
ReplayPressKey >> keySelector [

	^ keySelector ifNil: [ keySelector := #left ]
]

{ #category : 'accessing' }
ReplayPressKey >> keySelector: aSymbol [

	keySelector := aSymbol
]

{ #category : 'accessing' }
ReplayPressKey >> modifiers [

	^ modifiers ifNil: [ 0 ]
]

{ #category : 'accessing' }
ReplayPressKey >> modifiers: anInteger [

	modifiers := anInteger
]

{ #category : 'running' }
ReplayPressKey >> pressKeyOn: ui [

	| chord |
	chord := self chord.
	self repeatCount timesRepeat: [
		(chord keyboardEventOfType: #keyDown) sentTo: ui.
		chord typesText ifTrue: [ (chord keyboardEventOfType: #keystroke) sentTo: ui ].
		(chord keyboardEventOfType: #keyUp) sentTo: ui ]
]

{ #category : 'printing' }
ReplayPressKey >> printOn: stream [

	super printOn: stream.
	stream
		nextPutAll: ': ';
		nextPutAll: self keyLabel.
	self modifiers = 0 ifFalse: [
		stream
			nextPutAll: ' modifiers=';
			print: self modifiers ].
	self repeatCount = 1 ifFalse: [
		stream
			nextPutAll: ' x';
			print: self repeatCount ]
]

{ #category : 'accessing' }
ReplayPressKey >> repeatCount [

	^ repeatCount ifNil: [ repeatCount := 1 ]
]

{ #category : 'accessing' }
ReplayPressKey >> repeatCount: anInteger [

	repeatCount := 1 max: anInteger asInteger
]

{ #category : 'running' }
ReplayPressKey >> runOnMorph: aMorph [

	self pressKeyOn: aMorph
]
