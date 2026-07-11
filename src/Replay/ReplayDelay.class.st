"
A scenario action that pauses runner continuation for a configured number of seconds.
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

{ #category : 'editing' }
ReplayDelay >> editionPresenterOn: editor [

	^ editor newPresenter
		layout: (self secondsPresenterOn: editor labeled: 'Delay in seconds:');
		yourself
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

{ #category : 'editing' }
ReplayDelay >> secondsPresenterOn: editor labeled: label [

	| textPresenter |
	(textPresenter := editor newNumberInput)
		minimum: 0;
		numberType: Float;
		number: self seconds;
		whenNumberChangedDo: [ :aNumber |
				self seconds: aNumber.
				editor actions rebuildLayout ].
	editor registerReplayPresenter: textPresenter named: 'Action seconds'.
	editor registerReplayPresenter: textPresenter named: 'Delay seconds'.

	^ SpBoxLayout newTopToBottom
		 add: label expand: false;
		 add: textPresenter expand: false;
		 yourself
]
