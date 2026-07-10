"
I select a text range in a resolved UI element that supports selectionInterval:.
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

{ #category : 'accessing' }
ReplaySelectText class >> displayName [

	^ 'Select text'
]

{ #category : 'testing' }
ReplaySelectText >> canSelectTextIn: anObject [

	^ anObject notNil and: [ anObject respondsTo: #selectionInterval: ]
]

{ #category : 'editing' }
ReplaySelectText >> indexPresenterOn: editor labeled: label value: value update: updateBlock [

	| input |
	(input := editor newNumberInput)
		minimum: 1;
		numberType: Integer;
		number: value;
		whenNumberChangedDo: [ :number |
				updateBlock value: number.
				editor actions rebuildLayout ].
	^ SpBoxLayout newTopToBottom
		add: label expand: false;
		add: input expand: false;
		yourself
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
ReplaySelectText >> runOn: runner onUI: ui [

	self selectTextIn: ui
]

{ #category : 'running' }
ReplaySelectText >> runOn: runner resolvedUI: resolvedUI [

	resolvedUI runSelectText: self
]

{ #category : 'running' }
ReplaySelectText >> selectTextIn: anObject [

	(self canSelectTextIn: anObject) ifFalse: [
		^ self unsupportedTarget: anObject ].
	anObject selectionInterval: self selectionInterval
]

{ #category : 'accessing' }
ReplaySelectText >> selectionInterval [

	^ self startIndex to: (self stopIndex max: self startIndex)
]

{ #category : 'editing' }
ReplaySelectText >> settingsPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: (self targetPresenterOn: editor) expand: false;
				add: (self startIndexPresenterOn: editor) expand: false;
				add: (self stopIndexPresenterOn: editor) expand: false;
				yourself);
		yourself
]

{ #category : 'accessing' }
ReplaySelectText >> startIndex [

	^ startIndex ifNil: [ startIndex := 1 ]
]

{ #category : 'accessing' }
ReplaySelectText >> startIndex: anInteger [

	startIndex := 1 max: anInteger asInteger
]

{ #category : 'editing' }
ReplaySelectText >> startIndexPresenterOn: editor [

	^ self indexPresenterOn: editor labeled: 'Selection start:' value: self startIndex update: [ :number |
		self startIndex: number ]
]

{ #category : 'accessing' }
ReplaySelectText >> stopIndex [

	^ stopIndex ifNil: [ stopIndex := self startIndex ]
]

{ #category : 'accessing' }
ReplaySelectText >> stopIndex: anInteger [

	stopIndex := 0 max: anInteger asInteger
]

{ #category : 'editing' }
ReplaySelectText >> stopIndexPresenterOn: editor [

	^ self indexPresenterOn: editor labeled: 'Selection stop:' value: self stopIndex update: [ :number |
		self stopIndex: number ]
]

{ #category : 'error handling' }
ReplaySelectText >> unsupportedTarget: anObject [

	ReplayError new
		messageText: 'Target ', anObject className, ' does not support text selection.';
		tag: anObject;
		signal
]
