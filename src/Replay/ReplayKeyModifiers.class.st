"
I define the keyboard modifiers once for Replay. My class side answers their masks, which are the UserInputEvent masks found in the buttons of Morphic events, their display names, and decodes them from events.

A set of modifiers is an Integer: the bitOr: of the masks of its modifiers, 0 for none. Keyboard actions, key chords and pointer actions store their modifiers this way.
"
Class {
	#name : 'ReplayKeyModifiers',
	#superclass : 'Object',
	#category : 'Replay-Keys',
	#package : 'Replay',
	#tag : 'Keys'
}

{ #category : 'masks' }
ReplayKeyModifiers class >> all [
	"Every modifier mask, in the order to show them"

	^ { self shift. self control. self alt. self command }
]

{ #category : 'masks' }
ReplayKeyModifiers class >> alt [

	^ UserInputEvent altKeyMask
]

{ #category : 'masks' }
ReplayKeyModifiers class >> command [

	^ UserInputEvent cmdKeyMask
]

{ #category : 'masks' }
ReplayKeyModifiers class >> control [

	^ UserInputEvent ctrlKeyMask
]

{ #category : 'decoding' }
ReplayKeyModifiers class >> fromEvent: aUserInputEvent [
	"The modifiers held during aUserInputEvent, Option counting as Alt"

	| modifiers |
	modifiers := 0.
	aUserInputEvent shiftPressed ifTrue: [ modifiers := modifiers bitOr: self shift ].
	aUserInputEvent controlKeyPressed ifTrue: [ modifiers := modifiers bitOr: self control ].
	(aUserInputEvent optionKeyPressed or: [ aUserInputEvent altKeyPressed ]) ifTrue: [
		modifiers := modifiers bitOr: self alt ].
	aUserInputEvent commandKeyPressed ifTrue: [ modifiers := modifiers bitOr: self command ].
	^ modifiers
]

{ #category : 'testing' }
ReplayKeyModifiers class >> hasShortcutModifier: modifiers [
	"Whether a key pressed with modifiers runs a shortcut instead of typing text: Shift alone still types"

	^ (modifiers bitAnd: self shortcutModifiers) ~= 0
]

{ #category : 'masks' }
ReplayKeyModifiers class >> kmModifierFor: aMask [
	"The Keymapping modifier of the single modifier aMask"

	aMask = self shift ifTrue: [ ^ KMModifier shift ].
	aMask = self control ifTrue: [ ^ KMModifier ctrl ].
	aMask = self alt ifTrue: [ ^ KMModifier alt ].
	aMask = self command ifTrue: [ ^ KMModifier command ].
	self error: 'Not a modifier mask: ' , aMask printString
]

{ #category : 'converting' }
ReplayKeyModifiers class >> modified: aKMKeyCombination by: modifiers [
	"aKMKeyCombination with modifiers held, Shift printed last as Keymapping does"

	| kmModifiers composed |
	kmModifiers := ({ self control. self alt. self command. self shift } select: [ :mask |
		                (modifiers bitAnd: mask) ~= 0 ]) collect: [ :mask | self kmModifierFor: mask ].
	kmModifiers ifEmpty: [ ^ aKMKeyCombination ].
	kmModifiers size = 1 ifTrue: [
		^ KMModifiedKeyCombination modifier: kmModifiers first character: aKMKeyCombination ].
	composed := KMComposedModifier new.
	kmModifiers do: [ :each | composed modifiedBy: each ].
	^ KMModifiedKeyCombination modifier: composed character: aKMKeyCombination
]

{ #category : 'printing' }
ReplayKeyModifiers class >> nameOf: aMask [
	"The display name of the single modifier aMask"

	aMask = self shift ifTrue: [ ^ 'Shift' ].
	aMask = self control ifTrue: [ ^ 'Control' ].
	aMask = self alt ifTrue: [ ^ 'Alt/Option' ].
	aMask = self command ifTrue: [ ^ 'Command' ].
	self error: 'Not a modifier mask: ' , aMask printString
]

{ #category : 'printing' }
ReplayKeyModifiers class >> namesOf: modifiers [
	"The display names of the modifiers held in modifiers"

	^ (self all select: [ :mask | (modifiers bitAnd: mask) ~= 0 ]) collect: [ :mask |
		  self nameOf: mask ]
]

{ #category : 'masks' }
ReplayKeyModifiers class >> shift [

	^ UserInputEvent shiftKeyMask
]

{ #category : 'masks' }
ReplayKeyModifiers class >> shortcutModifiers [
	"The modifiers that turn a key press into a shortcut"

	^ (self control bitOr: self alt) bitOr: self command
]
