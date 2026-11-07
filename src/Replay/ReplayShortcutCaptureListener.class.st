"
I listen for one key press on a Morphic hand, decode it as a ReplayKeyBinding, give it to my capture block, and then uninstall myself. Modifier keys pressed alone are not captured.

A capture is cancelled, and my cancel block evaluated, when Escape is pressed, when cancel is sent, or when a key is pressed while my condition (captureWhile:) no longer holds: the presenter that asked for the binding is not shown anymore, and the key must not edit a binding nobody sees.
"
Class {
	#name : 'ReplayShortcutCaptureListener',
	#superclass : 'Object',
	#instVars : [
		'captureBlock',
		'cancelBlock',
		'condition',
		'hand'
	],
	#category : 'Replay-Keys',
	#package : 'Replay',
	#tag : 'Keys'
}

{ #category : 'instance creation' }
ReplayShortcutCaptureListener class >> onHand: aHandMorph do: aBlock [

	^ self new
		  whenCapturedDo: aBlock;
		  startOnHand: aHandMorph;
		  yourself
]

{ #category : 'capturing' }
ReplayShortcutCaptureListener >> cancel [
	"Stop listening without capturing"

	self isActive ifFalse: [ ^ self ].
	self stop.
	cancelBlock ifNotNil: [ :block | block value ]
]

{ #category : 'initialization' }
ReplayShortcutCaptureListener >> captureWhile: aBlock [
	"Capture only while aBlock answers true, and cancel otherwise"

	condition := aBlock
]

{ #category : 'accessing' }
ReplayShortcutCaptureListener >> hand [

	^ hand
]

{ #category : 'event handling' }
ReplayShortcutCaptureListener >> handleListenEvent: anEvent [

	| binding |
	anEvent isKeyboard ifFalse: [ ^ self ].
	anEvent isKeyDown ifFalse: [ ^ self ].
	(condition isNil or: [ condition value ]) ifFalse: [ ^ self cancel ].
	binding := ReplayKeyBinding fromKeyboardEvent: anEvent.
	binding ifNil: [ ^ self ].
	binding = (ReplayKeyBinding chords: { ReplayKeyChord namedKey: #escape }) ifTrue: [ ^ self cancel ].
	self stop.
	captureBlock ifNotNil: [ :block | block cull: binding ]
]

{ #category : 'testing' }
ReplayShortcutCaptureListener >> isActive [

	^ hand notNil
]

{ #category : 'capturing' }
ReplayShortcutCaptureListener >> startOnHand: aHandMorph [

	hand ifNotNil: [ self stop ].
	hand := aHandMorph.
	hand ifNotNil: [ hand addEventListener: self ]
]

{ #category : 'capturing' }
ReplayShortcutCaptureListener >> stop [

	hand ifNotNil: [
		hand removeEventListener: self.
		hand := nil ]
]

{ #category : 'initialization' }
ReplayShortcutCaptureListener >> whenCancelledDo: aBlock [

	cancelBlock := aBlock
]

{ #category : 'initialization' }
ReplayShortcutCaptureListener >> whenCapturedDo: aBlock [

	captureBlock := aBlock
]
