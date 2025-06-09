"
I am responsible for triggering keyboard events.
"
Class {
	#name : 'ReplayKeyboardEvent',
	#superclass : 'ReplayUIHandler',
	#traits : 'TReplayActionWithText',
	#classTraits : 'TReplayActionWithText classTrait',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'testing' }
ReplayKeyboardEvent class >> isAbstract [

	^ self == ReplayKeyboardEvent
]

{ #category : 'events' }
ReplayKeyboardEvent >> keyDown: aCharacter [

	^ self keyDown: aCharacter buttons: 0
]

{ #category : 'events' }
ReplayKeyboardEvent >> keyDown: aCharacter buttons: buttons [
	"Mostly used for shortcuts"

	| code |
	code := aCharacter asInteger.
	^ KeyboardEvent new
		  key: (KeyboardKey fromCharacter: aCharacter);
		  setType: #keyDown
		  buttons: buttons
		  position: 0 @ 0
		  keyValue: code
		  charCode: code
		  hand: self currentWorld activeHand
		  stamp: Time millisecondClockValue
]

{ #category : 'events' }
ReplayKeyboardEvent >> keyUp: aCharacter [

	^ self keyUp: aCharacter buttons: 0
]

{ #category : 'events' }
ReplayKeyboardEvent >> keyUp: aCharacter buttons: buttons [

	| code |
	code := aCharacter asInteger.
	^ KeyboardEvent new
		  key: (KeyboardKey fromCharacter: aCharacter);
		  setType: #keyUp
		  buttons: buttons
		  position: 0 @ 0
		  keyValue: code
		  charCode: code
		  hand: self currentWorld activeHand
		  stamp: Time millisecondClockValue
]

{ #category : 'events' }
ReplayKeyboardEvent >> keystroke: aCharacter [
	"Mostly used for typing"

	| code |
	code := aCharacter asInteger.
	^ KeyboardEvent new
		  "key: (KeyboardKey fromCharacter: aCharacter);"
		  setType: #keystroke
		  buttons: 0
		  position: 0 @ 0
		  keyValue: code
		  charCode: code
		  hand: self currentWorld activeHand
		  stamp: Time millisecondClockValue
]
