"
I am the abstract base for actions that open or interact with managed UI. My editors (ReplayUIActionEditor subclasses) show me with two views: my settings, and an interactive preview of the UI built with ReplayUIBuilder.
"
Class {
	#name : 'ReplayUIAction',
	#superclass : 'ReplayAction',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'testing' }
ReplayUIAction class >> isAbstract [

	^ self == ReplayUIAction
]
