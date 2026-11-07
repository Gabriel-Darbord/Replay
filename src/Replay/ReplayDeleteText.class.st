"
I delete text around the current caret or selection in a resolved text target. I use editor deletion APIs so selection and forward/backward deletion match user behavior.

I find the text editor of Rubric editing areas, and of the text morphs holding one (such as the widgets of Spec text inputs and text presenters), natively or in the Morphic widget.
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

{ #category : 'editing' }
ReplayDeleteText class >> editorClass [

	^ ReplayDeleteTextEditor
]

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
ReplayDeleteText >> canRunNativelyOn: anObject [

	^ self canDeleteTextIn: anObject
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
		ifFalse: [ ReplayError new messageText: 'Unsupported delete direction: ', aSymbol asString; subject: aSymbol; signal ].
	direction := aSymbol
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
ReplayDeleteText >> runOnMorph: aMorph [

	self deleteTextIn: aMorph
]

{ #category : 'running' }
ReplayDeleteText >> runOnNative: anObject [

	self deleteTextIn: anObject
]

{ #category : 'private' }
ReplayDeleteText >> textEditorFor: anObject [
	"The text editor of anObject: its own, the one of its text area for scrolled text morphs and text fields, or anObject itself"

	(anObject respondsTo: #editor) ifTrue: [ ^ anObject editor ].
	(anObject respondsTo: #textArea) ifTrue: [ ^ self textEditorFor: anObject textArea ].
	^ anObject
]

{ #category : 'error handling' }
ReplayDeleteText >> unsupportedTarget: anObject [

	ReplayError new
		messageText: 'Target ', anObject className, ' does not support text deletion.';
		subject: anObject;
		signal
]
