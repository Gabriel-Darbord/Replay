"
I am the abstract base for actions that send synthetic Morphic keyboard events to a resolved UI target. ReplayKeyChord builds these events.
"
Class {
	#name : 'ReplayKeyboardEvent',
	#superclass : 'ReplayUIHandler',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'testing' }
ReplayKeyboardEvent class >> isAbstract [

	^ self == ReplayKeyboardEvent
]
