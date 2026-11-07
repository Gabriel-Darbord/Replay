"
I signal that the script of a Replay action failed to compile, failed while running, or answered an unexpected value.

I remember the action owning the script, so help is reported against that action even when I am caught while editing another one. When the script raised an error, I keep it as my cause; when the script answered an unexpected value, it is my subject.
"
Class {
	#name : 'ReplayScriptError',
	#superclass : 'ReplayError',
	#instVars : [
		'action',
		'cause'
	],
	#category : 'Replay-Exceptions',
	#package : 'Replay',
	#tag : 'Exceptions'
}

{ #category : 'accessing' }
ReplayScriptError >> action [
	"Answer the action whose script failed."

	^ action
]

{ #category : 'accessing' }
ReplayScriptError >> action: aReplayAction [

	action := aReplayAction
]

{ #category : 'accessing' }
ReplayScriptError >> cause [
	"Answer the error raised by the script, or nil when the script answered an unexpected value."

	^ cause
]

{ #category : 'accessing' }
ReplayScriptError >> cause: anException [

	cause := anException
]

{ #category : 'editing' }
ReplayScriptError >> helpPresenterOn: editor for: anAction [
	"Report against the action owning the script, which may not be the action being edited."

	^ (action ifNil: [ anAction ]) helpPresenterOn: editor aboutScript: self
]
