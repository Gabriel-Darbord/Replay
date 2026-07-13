"
I delete text around the current caret or selection in a resolved text target. I use editor deletion APIs so selection and forward/backward deletion match user behavior.
"
Class {
	#name : 'ReplayDeleteText',
	#superclass : 'ReplayUIHandler',
	#instVars : [
		'direction',
		'count'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayDeleteText class >> directionChoices [

	^ {
		#backward -> 'Backward'.
		#forward -> 'Forward' }
]

{ #category : 'accessing' }
ReplayDeleteText class >> displayName [

	^ 'Delete text'
]

{ #category : 'testing' }
ReplayDeleteText >> canDeleteTextIn: anObject [

	| editor |
	anObject ifNil: [ ^ false ].
	editor := self textEditorFor: anObject.
	^ editor notNil and: [ editor respondsTo: self deleteSelector ]
]

{ #category : 'accessing' }
ReplayDeleteText >> count [

	^ count ifNil: [ 1 ]
]

{ #category : 'accessing' }
ReplayDeleteText >> count: anInteger [

	count := 1 max: anInteger asInteger
]

{ #category : 'editing' }
ReplayDeleteText >> countPresenterOn: editor [

	| input |
	input := editor newNumberInput.
	input
		minimum: 1;
		numberType: Integer;
		number: self count;
		whenNumberChangedDo: [ :number |
			self count: number.
			editor actions rebuildLayout ].
	editor registerReplayPresenter: input named: 'Action delete count'.
	editor registerReplayPresenter: input named: self class displayName , ' count'.
	^ SpBoxLayout newTopToBottom
		add: 'Delete count:' expand: false;
		add: input expand: false;
		yourself
]

{ #category : 'private' }
ReplayDeleteText >> deleteCharacter [

	self direction = #forward ifTrue: [ ^ Character value: 127 ].
	^ Character value: 8
]

{ #category : 'private' }
ReplayDeleteText >> deleteEvent [

	| code |
	code := self deleteCharacter asInteger.
	^ KeyboardEvent new
		setType: #keystroke
		buttons: 0
		position: 0 @ 0
		keyValue: code
		charCode: code
		hand: self currentWorld activeHand
		stamp: Time millisecondClockValue
]

{ #category : 'running' }
ReplayDeleteText >> deleteSelector [

	self direction = #forward ifTrue: [ ^ #forwardDelete: ].
	^ #backspace:
]

{ #category : 'running' }
ReplayDeleteText >> deleteTextIn: anObject [

	| editor selector event |
	(self canDeleteTextIn: anObject) ifFalse: [ ^ self unsupportedTarget: anObject ].
	editor := self textEditorFor: anObject.
	selector := self deleteSelector.
	event := self deleteEvent.
	self count timesRepeat: [ editor perform: selector with: event ]
]

{ #category : 'accessing' }
ReplayDeleteText >> direction [

	^ direction ifNil: [ #backward ]
]

{ #category : 'accessing' }
ReplayDeleteText >> direction: aSymbol [

	(#(#backward #forward) includes: aSymbol)
		ifFalse: [ ReplayError new messageText: 'Unsupported delete direction: ', aSymbol asString; tag: aSymbol; signal ].
	direction := aSymbol
]

{ #category : 'editing' }
ReplayDeleteText >> directionPresenterOn: editor [

	| dropList choices |
	choices := self class directionChoices.
	dropList := editor newDropList.
	dropList
		items: choices;
		display: [ :association | association value ];
		whenSelectedItemChangedDo: [ :association |
			association ifNotNil: [
				self direction: association key.
				editor actions rebuildLayout ] ].
	dropList selectItem: (choices
		detect: [ :association | association key = self direction ]
		ifNone: [ choices first ]).
	editor registerReplayPresenter: dropList named: 'Action delete direction'.
	editor registerReplayPresenter: dropList named: self class displayName , ' direction'.
	^ SpBoxLayout newTopToBottom
		add: 'Delete direction:' expand: false;
		add: dropList expand: false;
		yourself
]

{ #category : 'printing' }
ReplayDeleteText >> printOn: stream [

	super printOn: stream.
	stream nextPutAll: ': '.
	stream nextPutAll: self direction asString.
	stream nextPutAll: ' x'.
	self count printOn: stream
]

{ #category : 'running' }
ReplayDeleteText >> runOn: runner onUI: ui [

	self deleteTextIn: ui
]

{ #category : 'running' }
ReplayDeleteText >> runOn: runner resolvedUI: resolvedUI [

	resolvedUI runDeleteText: self
]

{ #category : 'editing' }
ReplayDeleteText >> settingsPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
			spacing: 10;
			add: (self targetPresenterOn: editor) expand: false;
			add: (self directionPresenterOn: editor) expand: false;
			add: (self countPresenterOn: editor) expand: false;
			yourself);
		yourself
]

{ #category : 'private' }
ReplayDeleteText >> textEditorFor: anObject [

	(anObject respondsTo: #editor) ifTrue: [ ^ anObject editor ].
	^ anObject
]

{ #category : 'error handling' }
ReplayDeleteText >> unsupportedTarget: anObject [

	ReplayError new
		messageText: 'Target ', anObject className, ' does not support text deletion.';
		tag: anObject;
		signal
]
