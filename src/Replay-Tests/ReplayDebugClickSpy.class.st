"
I am a click that keeps the block it would debug instead of opening a debugger, for tests.
"
Class {
	#name : 'ReplayDebugClickSpy',
	#superclass : 'ReplayClick',
	#instVars : [
		'debuggedBlock'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'testing' }
ReplayDebugClickSpy class >> shouldBeDropListElement [

	^ false
]

{ #category : 'testing' }
ReplayDebugClickSpy class >> shouldBeMenuItem [

	^ false
]

{ #category : 'debugging' }
ReplayDebugClickSpy >> debug: aBlock [

	debuggedBlock := aBlock
]

{ #category : 'accessing' }
ReplayDebugClickSpy >> debuggedBlock [

	^ debuggedBlock
]
