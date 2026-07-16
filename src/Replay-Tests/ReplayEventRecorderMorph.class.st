"
I record Morphic mouse and keyboard events sent by Replay tests.
"
Class {
	#name : 'ReplayEventRecorderMorph',
	#superclass : 'Morph',
	#instVars : [
		'events'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'event handling' }
ReplayEventRecorderMorph >> click: anEvent [

	self record: #click event: anEvent
]

{ #category : 'event handling' }
ReplayEventRecorderMorph >> doubleClick: anEvent [

	self record: #doubleClick event: anEvent
]

{ #category : 'accessing' }
ReplayEventRecorderMorph >> eventLabels [

	^ self events collect: [ :association | association key ]
]

{ #category : 'accessing' }
ReplayEventRecorderMorph >> events [

	^ events ifNil: [ events := OrderedCollection new ]
]

{ #category : 'event handling' }
ReplayEventRecorderMorph >> handleKeyDown: anEvent [

	self record: #keyDown event: anEvent
]

{ #category : 'event handling' }
ReplayEventRecorderMorph >> handleKeyUp: anEvent [

	self record: #keyUp event: anEvent
]

{ #category : 'event handling' }
ReplayEventRecorderMorph >> handleKeystroke: anEvent [

	self record: #keystroke event: anEvent
]

{ #category : 'event handling' }
ReplayEventRecorderMorph >> handleMouseDown: anEvent [

	self record: #mouseDown event: anEvent
]

{ #category : 'event handling' }
ReplayEventRecorderMorph >> handleMouseMove: anEvent [

	self record: #mouseMove event: anEvent
]

{ #category : 'event handling' }
ReplayEventRecorderMorph >> handleMouseUp: anEvent [

	self record: #mouseUp event: anEvent
]

{ #category : 'event handling' }
ReplayEventRecorderMorph >> handleMouseWheel: anEvent [

	self record: #mouseWheel event: anEvent
]

{ #category : 'events - processing' }
ReplayEventRecorderMorph >> handlesMouseDown: anEvent [

	^ true
]

{ #category : 'events - processing' }
ReplayEventRecorderMorph >> handlesMouseMove: anEvent [

	^ true
]

{ #category : 'events - processing' }
ReplayEventRecorderMorph >> handlesMouseWheel: anEvent [

	^ true
]

{ #category : 'initialization' }
ReplayEventRecorderMorph >> initialize [

	super initialize.
	events := OrderedCollection new.
	self extent: 100 @ 60
]

{ #category : 'accessing' }
ReplayEventRecorderMorph >> lastEvent [

	^ self events last value
]

{ #category : 'recording' }
ReplayEventRecorderMorph >> record: aSymbol event: anEvent [

	self events add: aSymbol -> anEvent
]
