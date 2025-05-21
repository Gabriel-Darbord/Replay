Trait {
	#name : 'TReplayActionWithScript',
	#instVars : [
		'script'
	],
	#traits : 'TReplayActionWithDebugging',
	#classTraits : 'TReplayActionWithDebugging classTrait',
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'debugging' }
TReplayActionWithScript >> debugScript [

	| compiler method debugSession |
	compiler := Smalltalk compiler.
	compiler ast: (compiler parse: self script) asDoit.
	method := compiler compile.

	debugSession := self debug: [
		                method valueWithReceiver: nil arguments: #(  ) ].

	4 timesRepeat: [ debugSession stepInto ]
]

{ #category : 'accessing' }
TReplayActionWithScript >> script [

	^ script ifNil: [ script := '' ]
]

{ #category : 'accessing' }
TReplayActionWithScript >> script: aString [

	script := aString
]

{ #category : 'editing' }
TReplayActionWithScript >> scriptPresenterOn: editor labeled: label [

	| codePresenter |
	(codePresenter := SpCodePresenter new)
		text: self script;
		whenTextChangedDo: [ :aString |
			self script: aString.
			editor actions rebuildLayout ].

	^ SpBoxLayout newTopToBottom
		  add: label expand: false;
		  add: codePresenter;
		  yourself
]
