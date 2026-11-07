"
I select a text range in a resolved UI target that supports text selection, natively when the native element does (as Spec text presenters do), otherwise in the Morphic widget.
"
Class {
	#name : 'ReplaySelectText',
	#superclass : 'ReplayUIHandler',
	#instVars : [
		'startIndex',
		'stopIndex'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplaySelectText class >> editorClass [

	^ ReplaySelectTextEditor
]

{ #category : 'accessing' }
ReplaySelectText class >> displayName [

	^ 'Select text'
]

{ #category : 'testing' }
ReplaySelectText >> canRunNativelyOn: anObject [

	^ self canSelectTextIn: anObject
]

{ #category : 'testing' }
ReplaySelectText >> canSelectTextIn: anObject [

	^ anObject notNil and: [
		(anObject respondsTo: #selectionInterval:)
			or: [ anObject respondsTo: #selectFrom:to: ] ]
]

{ #category : 'printing' }
ReplaySelectText >> printOn: stream [

	super printOn: stream.
	stream nextPutAll: ': '.
	self startIndex printOn: stream.
	stream nextPutAll: '-'.
	self stopIndex printOn: stream
]

{ #category : 'running' }
ReplaySelectText >> runOnMorph: aMorph [

	self selectTextIn: aMorph
]

{ #category : 'running' }
ReplaySelectText >> runOnNative: anObject [

	self selectTextIn: anObject
]

{ #category : 'running' }
ReplaySelectText >> selectTextIn: anObject [

	(self canSelectTextIn: anObject) ifFalse: [ ^ self unsupportedTarget: anObject ].
	(anObject respondsTo: #selectionInterval:) ifTrue: [
		^ anObject selectionInterval: self selectionInterval ].
	anObject selectFrom: self selectionInterval first to: self selectionInterval last
]

{ #category : 'accessing' }
ReplaySelectText >> selectionInterval [

	^ self startIndex to: (self stopIndex max: self startIndex)
]

{ #category : 'accessing' }
ReplaySelectText >> startIndex [

	^ startIndex ifNil: [ startIndex := 1 ]
]

{ #category : 'accessing' }
ReplaySelectText >> startIndex: anInteger [

	startIndex := 1 max: anInteger asInteger
]

{ #category : 'accessing' }
ReplaySelectText >> stopIndex [

	^ stopIndex ifNil: [ stopIndex := self startIndex ]
]

{ #category : 'accessing' }
ReplaySelectText >> stopIndex: anInteger [

	stopIndex := 0 max: anInteger asInteger
]

{ #category : 'error handling' }
ReplaySelectText >> unsupportedTarget: anObject [

	ReplayError new
		messageText: 'Target ', anObject className, ' does not support text selection.';
		subject: anObject;
		signal
]
