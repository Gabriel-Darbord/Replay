"
I am a ReplayEditor that remembers the actions that its action editors report as changed (actionChanged:), for tests that check that each edit notifies once.
"
Class {
	#name : 'ReplayEditorSpy',
	#superclass : 'ReplayEditor',
	#instVars : [
		'changedActions'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'editing' }
ReplayEditorSpy >> actionChanged: anAction [

	self changedActions add: anAction.
	super actionChanged: anAction
]

{ #category : 'accessing' }
ReplayEditorSpy >> changedActions [

	^ changedActions ifNil: [ changedActions := OrderedCollection new ]
]
