"
I am installed on a Morphic hand while a ReplayRecorder records. I forward copies of the input events to my recorder without consuming the original events.

A hand may still give me the event during which my recorder stopped: I forward events only while my recorder is recording.
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

	recorder isRecording ifTrue: [ recorder recordEvent: anEvent ]
]

{ #category : 'accessing' }
ReplayRecorderListener >> recorder [
	^ recorder
]

{ #category : 'accessing' }
ReplayRecorderListener >> recorder: aReplayRecorder [
	recorder := aReplayRecorder
]
