Trait {
	#name : 'TReplayActionWithText',
	#instVars : [
		'text'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'as yet unclassified' }
TReplayActionWithText >> text [

	^ text ifNil: [ text := '' ]
]

{ #category : 'as yet unclassified' }
TReplayActionWithText >> text: aString [

	text := aString
]

{ #category : 'editing' }
TReplayActionWithText >> textPresenterOn: editor labeled: label [

	| textPresenter |
	(textPresenter := SpTextPresenter new)
		text: self text;
		whenTextChangedDo: [ :aString |
			self text: aString.
			editor actions rebuildLayout ].

	^ SpBoxLayout newTopToBottom
		  add: label expand: false;
		  add: textPresenter;
		  yourself
]
