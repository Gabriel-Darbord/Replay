"
I am the abstract base for actions that send synthetic mouse events to the Morphic widget of their target: clicks, drags and scrolls.

I hold the mouse buttons pressed during the gesture, a mask of MouseEvent buttons (redButton for the left button by default), and the keyboard modifiers held, a ReplayKeyModifiers mask. Positions are offsets from the top-left corner of the target widget, nil for its center; I convert them to World points.

My events go to the morph handling them, found by walking up the owner chain of the target, through a ReplayHandMorph: a private hand that is not a hand of the World, so a replay does not move the pointer or the mouse focus of the user.
"
Class {
	#name : 'ReplayPointerAction',
	#superclass : 'ReplayUIHandler',
	#instVars : [
		'buttons',
		'modifiers'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayPointerAction class >> buttonChoices [
	"The mouse button masks, with their display names"

	^ {
		  (MouseEvent redButton -> 'Left').
		  (MouseEvent yellowButton -> 'Right').
		  (MouseEvent blueButton -> 'Middle') }
]

{ #category : 'testing' }
ReplayPointerAction class >> isAbstract [

	^ self == ReplayPointerAction
]

{ #category : 'accessing' }
ReplayPointerAction >> buttons [
	"The mask of the mouse buttons pressed during my gesture"

	^ buttons ifNil: [ self defaultButtons ]
]

{ #category : 'accessing' }
ReplayPointerAction >> buttons: anInteger [

	buttons := anInteger
]

{ #category : 'accessing' }
ReplayPointerAction >> defaultButtons [

	^ MouseEvent redButton
]

{ #category : 'testing' }
ReplayPointerAction >> hasButton: aMask [

	^ (self buttons bitAnd: aMask) ~= 0
]

{ #category : 'accessing' }
ReplayPointerAction >> modifiers [
	"The ReplayKeyModifiers mask of the keys held during my gesture"

	^ modifiers ifNil: [ 0 ]
]

{ #category : 'accessing' }
ReplayPointerAction >> modifiers: anInteger [

	modifiers := anInteger
]

{ #category : 'events' }
ReplayPointerAction >> mouseDownEventAt: aPoint hand: aHand [

	^ MouseButtonEvent new
		setType: #mouseDown
		position: aPoint
		which: self buttons
		buttons: (self buttons bitOr: self modifiers)
		hand: aHand
		stamp: Time millisecondClockValue
]

{ #category : 'events' }
ReplayPointerAction >> mouseUpEventAt: aPoint hand: aHand [

	^ MouseButtonEvent new
		setType: #mouseUp
		position: aPoint
		which: self buttons
		buttons: self modifiers
		hand: aHand
		stamp: Time millisecondClockValue
]

{ #category : 'events' }
ReplayPointerAction >> newHandAt: aPoint [
	"A hand for my events, apart from the hand of the World"

	^ ReplayHandMorph at: aPoint in: self currentWorld
]

{ #category : 'printing' }
ReplayPointerAction >> printButtonsAndModifiersOn: stream [

	self buttons = self defaultButtons ifFalse: [
		stream nextPutAll: ' buttons='.
		(self class buttonChoices select: [ :association | self hasButton: association key ])
			do: [ :association | stream nextPutAll: association value ]
			separatedBy: [ stream nextPut: $+ ] ].
	self modifiers = 0 ifFalse: [
		stream nextPutAll: ' modifiers='.
		(ReplayKeyModifiers namesOf: self modifiers)
			do: [ :name | stream nextPutAll: name ]
			separatedBy: [ stream nextPut: $+ ] ]
]

{ #category : 'accessing' }
ReplayPointerAction >> setButton: aMask to: aBoolean [

	self buttons: (aBoolean
			 ifTrue: [ self buttons bitOr: aMask ]
			 ifFalse: [ self buttons bitClear: aMask ])
]

{ #category : 'events' }
ReplayPointerAction >> targetStartingAt: aMorph handling: selector with: anEvent [
	"The first morph of the owner chain of aMorph that handles anEvent, as Morphic dispatch would find it, or aMorph when none does"

	| target |
	target := aMorph.
	[ target notNil and: [ (target perform: selector with: anEvent) not ] ]
		whileTrue: [ target := target owner ].
	^ target ifNil: [ aMorph ]
]

{ #category : 'events' }
ReplayPointerAction >> worldPointAt: anOffset in: aMorph [
	"The World point at anOffset from the top-left corner of aMorph, or at its center when anOffset is nil"

	^ aMorph pointInWorld: (anOffset
			   ifNil: [ aMorph center ]
			   ifNotNil: [ aMorph topLeft + anOffset ])
]
