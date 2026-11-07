"
I am the abstract root of executable Replay scenario actions. Subclasses carry editable action state and know how to run themselves in a ReplayRunner.

Actions are model objects, serialized with STON: they build no UI. The ReplayEditor edits an action with an instance of the class its class answers to editorClass (a ReplayActionEditor subclass).
"
Class {
	#name : 'ReplayAction',
	#superclass : 'Object',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplayAction class >> editorClass [
	"The class of the presenters that edit my instances in a ReplayEditor"

	^ ReplayActionEditor
]

{ #category : 'editing' }
ReplayAction class >> actionsForDropList [

	^ self selectActions: [ :action | action shouldBeDropListElement ]
]

{ #category : 'editing' }
ReplayAction class >> actionsForMenu [

	^ self selectActions: [ :action | action shouldBeMenuItem ]
]

{ #category : 'editing' }
ReplayAction class >> actionsThatOpenUI [

	^ self selectActions: [ :action | action new isUIOpener ]
]

{ #category : 'accessing' }
ReplayAction class >> displayName [

	| className |
	className := self name asString.
	^ (className beginsWith: 'Replay')
		ifTrue: [ className allButFirst: 6 ]
		ifFalse: [ className ]
]

{ #category : 'testing' }
ReplayAction class >> isAbstract [

	^ self == ReplayAction
]

{ #category : 'enumerating' }
ReplayAction class >> selectActions: aBlock [

	^ (self allSubclasses select: [ :c |
		   c isAbstract not and: [ aBlock value: c ] ]) sorted: [ :c1 :c2 |
		  c1 name < c2 name ]
]

{ #category : 'testing' }
ReplayAction class >> shouldBeDropListElement [

	^ true
]

{ #category : 'testing' }
ReplayAction class >> shouldBeMenuItem [

	^ false
]

{ #category : 'testing' }
ReplayAction >> controlsRunnerContinuation [
	"Answer whether this action will explicitly continue the runner later."

	^ false
]

{ #category : 'recording' }
ReplayAction >> copyWithoutRecordedTiming [
	| copy |
	copy := self copy.
	copy removeRecordedTiming.
	^ copy
]

{ #category : 'testing' }
ReplayAction >> hasScript [
	"Whether I evaluate a script (see TReplayActionWithScript)"

	^ false
]

{ #category : 'testing' }
ReplayAction >> isClick [

	^ false
]

{ #category : 'testing' }
ReplayAction >> isUICloser [

	^ false
]

{ #category : 'testing' }
ReplayAction >> isUIHandler [

	^ false
]

{ #category : 'testing' }
ReplayAction >> isUIOpener [

	^ false
]

{ #category : 'running' }
ReplayAction >> previewOn: aReplayUIBuilder [
	"Replay myself to rebuild an editor preview of the UI.
	Actions with effects outside of the preview UI, or that take time, override me to skip them."

	self runOn: aReplayUIBuilder
]

{ #category : 'printing' }
ReplayAction >> printDetail: aString on: stream [
	"Print a short configuration detail after my name, if there is one."

	aString isEmptyOrNil ifTrue: [ ^ self ].
	stream nextPutAll: ': '.
	stream nextPutAll: (aString printStringLimitedTo: 100)
]

{ #category : 'printing' }
ReplayAction >> printOn: stream [

	stream nextPutAll: self class displayName
]

{ #category : 'recording' }
ReplayAction >> removeRecordedTiming [
	"Subclasses with duration-bearing state can clear it here when recorded timing is stripped."
]

{ #category : 'running' }
ReplayAction >> runOn: aReplayRunner [

	self subclassResponsibility
]

{ #category : 'recording' }
ReplayAction >> shouldRecordWhenTimingStripped [
	^ true
]
