Class {
	#name : 'ReplayRecordingBackend',
	#superclass : 'ReplayUIBackend',
	#instVars : [
		'lastInteraction',
		'lastAction',
		'lastResolvedUI',
		'deferredBlocks'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'running' }
ReplayRecordingBackend >> defer: aBlock [

	self deferredBlocks add: aBlock
]

{ #category : 'accessing' }
ReplayRecordingBackend >> deferredBlockCount [

	^ self deferredBlocks size
]

{ #category : 'accessing' }
ReplayRecordingBackend >> deferredBlocks [

	^ deferredBlocks ifNil: [ deferredBlocks := OrderedCollection new ]
]

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
ReplayRecordingBackend >> runDeferredBlocks [

	| blocks |
	blocks := self deferredBlocks copy.
	deferredBlocks removeAll.
	blocks do: [ :block | block value ]
]

{ #category : 'running' }
ReplayRecordingBackend >> runFocus: aReplayFocus on: aResolvedUI [

	self record: #focus action: aReplayFocus resolvedUI: aResolvedUI
]

{ #category : 'running' }
ReplayRecordingBackend >> runPressKey: aReplayPressKey on: aResolvedUI [

	self record: #pressKey action: aReplayPressKey resolvedUI: aResolvedUI
]

{ #category : 'running' }
ReplayRecordingBackend >> runSelectText: aReplaySelectText on: aResolvedUI [

	self record: #selectText action: aReplaySelectText resolvedUI: aResolvedUI
]

{ #category : 'running' }
ReplayRecordingBackend >> runShortcut: aReplayShortcut on: aResolvedUI [

	self record: #shortcut action: aReplayShortcut resolvedUI: aResolvedUI
]

{ #category : 'running' }
ReplayRecordingBackend >> runType: aReplayType on: aResolvedUI [

	self record: #type action: aReplayType resolvedUI: aResolvedUI
]

{ #category : 'running' }
ReplayRecordingBackend >> settleUI [

	lastInteraction := #settleUI
]
