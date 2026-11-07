"
Test helper with a non-Replay class prefix used to verify generic action display names.
"
Class {
	#name : 'TestReplayAction',
	#superclass : 'ReplayAction',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'testing' }
TestReplayAction class >> shouldBeDropListElement [

	^ false
]

{ #category : 'running' }
TestReplayAction >> runOn: aReplayRunner [

	self shouldNotImplement
]
