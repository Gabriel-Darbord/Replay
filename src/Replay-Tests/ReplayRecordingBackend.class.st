Class {
	#name : 'ReplayRecordingBackend',
	#superclass : 'ReplayUIBackend',
	#instVars : [
		'lastInteraction',
		'lastAction',
		'lastResolvedUI'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'accessing' }
ReplayRecordingBackend >> lastAction [

	^ lastAction
]

{ #category : 'accessing' }
ReplayRecordingBackend >> lastInteraction [

	^ lastInteraction
]

{ #category : 'accessing' }
ReplayRecordingBackend >> lastResolvedUI [

	^ lastResolvedUI
]

{ #category : 'recording' }
ReplayRecordingBackend >> record: interactionSymbol action: anAction resolvedUI: aResolvedUI [

	lastInteraction := interactionSymbol.
	lastAction := anAction.
	lastResolvedUI := aResolvedUI
]

{ #category : 'running' }
ReplayRecordingBackend >> runClick: aReplayClick on: aResolvedUI [

	self record: #click action: aReplayClick resolvedUI: aResolvedUI
]

{ #category : 'running' }
ReplayRecordingBackend >> runFocus: aReplayFocus on: aResolvedUI [

	self record: #focus action: aReplayFocus resolvedUI: aResolvedUI
]

{ #category : 'running' }
ReplayRecordingBackend >> runShortcut: aReplayShortcut on: aResolvedUI [

	self record: #shortcut action: aReplayShortcut resolvedUI: aResolvedUI
]

{ #category : 'running' }
ReplayRecordingBackend >> runType: aReplayType on: aResolvedUI [

	self record: #type action: aReplayType resolvedUI: aResolvedUI
]
