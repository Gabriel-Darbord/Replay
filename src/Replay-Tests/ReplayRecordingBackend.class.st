"
I am a test backend: I record the last action run on me instead of running it, and keep deferred blocks until a test runs them. My managed UI is any morph a test gives me.
"
Class {
	#name : 'ReplayRecordingBackend',
	#superclass : 'ReplayUIBackend',
	#instVars : [
		'lastInteraction',
		'lastAction',
		'lastResolvedUI',
		'deferredBlocks',
		'managedUI'
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

{ #category : 'accessing' }
ReplayRecordingBackend >> managedUI [

	^ managedUI
]

{ #category : 'accessing' }
ReplayRecordingBackend >> managedUI: aMorph [

	managedUI := aMorph
]

{ #category : 'recording' }
ReplayRecordingBackend >> record: interactionSymbol action: anAction resolvedUI: aResolvedUI [

	lastInteraction := interactionSymbol.
	lastAction := anAction.
	lastResolvedUI := aResolvedUI
]

{ #category : 'running' }
ReplayRecordingBackend >> run: anAction on: aResolvedUI [

	self record: #run action: anAction resolvedUI: aResolvedUI
]

{ #category : 'running' }
ReplayRecordingBackend >> runDeferredBlocks [

	| blocks |
	blocks := self deferredBlocks copy.
	deferredBlocks removeAll.
	blocks do: [ :block | block value ]
]

{ #category : 'running' }
ReplayRecordingBackend >> settleUI [

	lastInteraction := #settleUI
]
