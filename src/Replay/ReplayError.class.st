"
I am the base exception raised by Replay when a scenario or action cannot run as requested.

I can carry the object the problem is about in my subject, for example a missing target or an unexpected value, so tools and tests can inspect it.
"
Class {
	#name : 'ReplayError',
	#superclass : 'Error',
	#instVars : [
		'subject'
	],
	#category : 'Replay-Exceptions',
	#package : 'Replay',
	#tag : 'Exceptions'
}

{ #category : 'editing' }
ReplayError >> helpPresenterOn: editor for: action [

	^ action helpPresenterOn: editor about: self
]

{ #category : 'accessing' }
ReplayError >> subject [
	"Answer the object this error is about, or nil."

	^ subject
]

{ #category : 'accessing' }
ReplayError >> subject: anObject [

	subject := anObject
]
