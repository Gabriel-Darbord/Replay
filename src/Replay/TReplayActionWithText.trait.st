"
I add text storage to actions that carry plain string input.
"
Trait {
	#name : 'TReplayActionWithText',
	#instVars : [
		'text'
	],
	#category : 'Replay-Traits',
	#package : 'Replay',
	#tag : 'Traits'
}

{ #category : 'accessing - text' }
TReplayActionWithText >> appendText: aCharacterOrString [

	self text: (aCharacterOrString isString
			 ifTrue: [ self text , aCharacterOrString ]
			 ifFalse: [ self text copyWith: aCharacterOrString ])
]

{ #category : 'printing' }
TReplayActionWithText >> printOn: stream [

	super printOn: stream.
	self printDetail: text on: stream
]

{ #category : 'accessing' }
TReplayActionWithText >> text [

	^ text ifNil: [ '' ]
]

{ #category : 'accessing' }
TReplayActionWithText >> text: aString [

	text := aString
]
