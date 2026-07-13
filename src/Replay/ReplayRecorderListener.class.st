"
I am installed on a Morphic hand while recording. I forward copied input events to a ReplayRecorder without consuming the original events.
"
Class {
	#name : 'ReplayRecorderListener',
	#superclass : 'Object',
	#instVars : [
		'recorder'
	],
	#category : 'Replay-Recording',
	#package : 'Replay',
	#tag : 'Recording'
}

{ #category : 'instance creation' }
ReplayRecorderListener class >> on: aReplayRecorder [
	^ self new recorder: aReplayRecorder; yourself
]

{ #category : 'event handling' }
ReplayRecorderListener >> handleListenEvent: anEvent [
	recorder ifNotNil: [ recorder recordEvent: anEvent ]
]

{ #category : 'accessing' }
ReplayRecorderListener >> recorder [
	^ recorder
]

{ #category : 'accessing' }
ReplayRecorderListener >> recorder: aReplayRecorder [
	recorder := aReplayRecorder
]
