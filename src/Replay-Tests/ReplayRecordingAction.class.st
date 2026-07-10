"
Test helper action that records its label in a shared log when run.
"
Class {
	#name : 'ReplayRecordingAction',
	#superclass : 'ReplayAction',
	#instVars : [
		'label',
		'log'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'instance creation' }
ReplayRecordingAction class >> label: aSymbol log: aCollection [

	^ self new
		  label: aSymbol;
		  log: aCollection;
		  yourself
]

{ #category : 'testing' }
ReplayRecordingAction class >> shouldBeDropListElement [

	^ false
]

{ #category : 'accessing' }
ReplayRecordingAction >> label [

	^ label
]

{ #category : 'accessing' }
ReplayRecordingAction >> label: aSymbol [

	label := aSymbol
]

{ #category : 'accessing' }
ReplayRecordingAction >> log [

	^ log
]

{ #category : 'accessing' }
ReplayRecordingAction >> log: aCollection [

	log := aCollection
]

{ #category : 'running' }
ReplayRecordingAction >> runOn: aReplayRunner [

	log add: label
]
