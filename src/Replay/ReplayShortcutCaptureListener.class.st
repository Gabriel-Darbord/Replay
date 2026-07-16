"
I listen for one keyboard shortcut event on a Morphic hand, convert it through ReplayRecorder, and then uninstall myself.
"
Class {
	#name : 'ReplayShortcutCaptureListener',
	#superclass : 'Object',
	#instVars : [
		'captureBlock',
		'hand',
		'recorder'
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

	| shortcut |
	anEvent isKeyboard ifFalse: [ ^ self ].
	anEvent isKeyDown ifFalse: [ ^ self ].
	shortcut := self recorder shortcutFromEvent: anEvent.
	shortcut ifNil: [ ^ self ].
	self stop.
	captureBlock ifNotNil: [ :block | block cull: shortcut ]
]

{ #category : 'testing' }
ReplayShortcutCaptureListener >> isActive [

	^ hand notNil
]

{ #category : 'accessing' }
ReplayShortcutCaptureListener >> recorder [

	^ recorder ifNil: [ recorder := ReplayRecorder new ]
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
