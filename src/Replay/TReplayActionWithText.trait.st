"
Applies to actions that use a string as text.
"
Trait {
	#name : 'TReplayActionWithText',
	#instVars : [
		'text'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'accessing - text' }
TReplayActionWithText >> appendText: aCharacterOrString [

	self text: (aCharacterOrString isString
			 ifTrue: [ self text , aCharacterOrString ]
			 ifFalse: [ self text copyWith: aCharacterOrString ])
]

{ #category : 'accessing' }
TReplayActionWithText >> text [

	^ text ifNil: [ text := '' ]
]

{ #category : 'accessing' }
TReplayActionWithText >> text: aString [

	text := aString
]

{ #category : 'editing' }
TReplayActionWithText >> textPresenterOn: editor labeled: label [

	| textPresenter |
	(textPresenter := editor newText)
		text: self text;
		whenTextChangedDo: [ :aString |
			self text: aString.
			editor actions rebuildLayout ].

	^ SpBoxLayout newTopToBottom
		  add: label expand: false;
		  add: textPresenter;
		  yourself
]
