"
I pause runner continuation for a configured number of seconds. I am intended for explicit demo pacing, not for waiting on UI layout.
"
Class {
	#name : 'ReplayDelay',
	#superclass : 'ReplayAction',
	#instVars : [
		'seconds'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplayDelay class >> editorClass [

	^ ReplayDelayEditor
]

{ #category : 'accessing' }
ReplayDelay class >> displayName [

	^ 'Delay'
]

{ #category : 'instance creation' }
ReplayDelay class >> seconds: aNumber [

	^ self new
		seconds: aNumber;
		yourself
]

{ #category : 'testing' }
ReplayDelay >> controlsRunnerContinuation [

	^ true
]

{ #category : 'running' }
ReplayDelay >> previewOn: aReplayUIBuilder [
	"Previews do not wait."

	aReplayUIBuilder nextAction
]

{ #category : 'printing' }
ReplayDelay >> printOn: stream [

	super printOn: stream.
	stream nextPutAll: ': '.
	self seconds printOn: stream.
	stream nextPutAll: 's'
]

{ #category : 'running' }
ReplayDelay >> runOn: runner [
	"Pause scenario and continue on UI process."

	[ (Delay forSeconds: self seconds) wait.
	runner defer: [ runner nextAction ] ] fork
]

{ #category : 'accessing' }
ReplayDelay >> seconds [

	^ seconds ifNil: [ 1 ]
]

{ #category : 'accessing' }
ReplayDelay >> seconds: aNumber [

	seconds := aNumber
]

{ #category : 'recording' }
ReplayDelay >> shouldRecordWhenTimingStripped [
	^ false
]
