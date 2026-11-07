"
I listen for one key press on a Morphic hand, decode it as a ReplayKeyBinding, give it to my capture block, and then uninstall myself. Modifier keys pressed alone are not captured.
"
Class {
	#name : 'ReplayShortcutCaptureListener',
	#superclass : 'Object',
	#instVars : [
		'captureBlock',
		'hand'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'instance creation' }
ReplayShortcutCaptureListener class >> onHand: aHandMorph do: aBlock [

	| listener |
	listener := self new.
	listener startOnHand: aHandMorph do: aBlock.
	^ listener
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
	binding := ReplayKeyBinding fromKeyboardEvent: anEvent.
	binding ifNil: [ ^ self ].
	self stop.
	captureBlock ifNotNil: [ :block | block cull: binding ]
]

{ #category : 'testing' }
ReplayShortcutCaptureListener >> isActive [

	^ hand notNil
]

{ #category : 'capturing' }
ReplayShortcutCaptureListener >> startOnHand: aHandMorph do: aBlock [

	hand ifNotNil: [ self stop ].
	hand := aHandMorph.
	captureBlock := aBlock.
	hand ifNotNil: [ hand addEventListener: self ]
]

{ #category : 'capturing' }
ReplayShortcutCaptureListener >> stop [

	hand ifNotNil: [
		hand removeEventListener: self.
		hand := nil ]
]
