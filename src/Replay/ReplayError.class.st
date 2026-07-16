"
I am the base exception raised by Replay when a scenario or action cannot run as requested.
"
Class {
	#name : 'ReplayError',
	#superclass : 'Error',
	#category : 'Replay-Exceptions',
	#package : 'Replay',
	#tag : 'Exceptions'
}

{ #category : 'editing' }
ReplayError >> helpPresenterOn: editor for: action [

	^ action helpPresenterOn: editor about: self
]

{ #category : 'accessing' }
ReplayError >> tag [
	"Can be used to hold an arbitrary object"

	^ tag
]
