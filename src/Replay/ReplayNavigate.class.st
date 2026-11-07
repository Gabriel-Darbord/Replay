"
I configure the navigation prompt shown between scenario steps, including labels, skip behavior, and optional window placement.

By default I skip user navigation and the scenario goes on to the next step. Otherwise I open a dialog: accepting continues with the next step, cancelling or closing the dialog stops the scenario.

My defaults are answered but not stored, so a default navigation serializes to nothing (see `isDefault`).
"
Class {
	#name : 'ReplayNavigate',
	#superclass : 'ReplayAction',
	#traits : 'TReplayActionWithText',
	#classTraits : 'TReplayActionWithText classTrait',
	#instVars : [
		'skip',
		'acceptLabel',
		'cancelLabel',
		'placement'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayNavigate class >> displayName [

	^ 'Navigate'
]

{ #category : 'testing' }
ReplayNavigate class >> shouldBeDropListElement [

	^ false
]

{ #category : 'accessing' }
ReplayNavigate >> acceptLabel [

	^ acceptLabel ifNil: [ 'Next' ]
]

{ #category : 'accessing' }
ReplayNavigate >> acceptLabel: aString [

	acceptLabel := aString
]

{ #category : 'accessing' }
ReplayNavigate >> cancelLabel [

	^ cancelLabel ifNil: [ 'Stop' ]
]

{ #category : 'accessing' }
ReplayNavigate >> cancelLabel: aString [

	cancelLabel := aString
]

{ #category : 'testing' }
ReplayNavigate >> controlsRunnerContinuation [

	^ true
]

{ #category : 'editing' }
ReplayNavigate >> editionPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: (editor newCheckBox
						label: 'Skip user navigation';
						state: self skip;
						whenActivatedDo: [ self skip: true ];
						whenDeactivatedDo: [ self skip: false ])
				expand: false;
				add: (SpBoxLayout newTopToBottom
						add: 'Continue label:' expand: false;
						add: (editor newText
								text: self acceptLabel;
								whenTextChangedDo: [ :aString |
									self acceptLabel: aString ]))
				expand: false;
				add: (SpBoxLayout newTopToBottom
						add: 'Cancel label:' expand: false;
						add: (editor newText
								text: self cancelLabel;
								whenTextChangedDo: [ :aString |
									self cancelLabel: aString ]))
				expand: false;
				add: (self textPresenterOn: editor labeled: 'Write rich text display on navigation window:');
				add: (self placementPresenterOn: editor) expand: false;
				yourself);
		yourself
]

{ #category : 'testing' }
ReplayNavigate >> isDefault [
	"Answer whether I behave and edit like a new navigation, so I need not be serialized."

	^ self skip and: [
		  acceptLabel isNil and: [
			  cancelLabel isNil and: [ text isNil and: [ placement isNil ] ] ] ]
]

{ #category : 'accessing' }
ReplayNavigate >> placement [
	"Answer the requested dialog placement, or nil to keep the natural dialog placement."

	^ placement
]

{ #category : 'accessing' }
ReplayNavigate >> placement: aReplayPlacement [
	"An empty placement requests nothing, it is kept as nil."

	placement := (aReplayPlacement isNil or: [ aReplayPlacement isEmpty ])
		ifTrue: [ nil ]
		ifFalse: [ aReplayPlacement ]
]

{ #category : 'editing' }
ReplayNavigate >> placementPresenterOn: editor [

	^ (placement ifNil: [ ReplayPlacement new ])
		presenterOn: editor
		targetPrefixes: { 'Navigation'. self class displayName }
		whenChangedDo: [ :aPlacement |
			self placement: aPlacement.
			editor actionChanged: self ]
]

{ #category : 'running' }
ReplayNavigate >> previewOn: aReplayUIBuilder [
	"Previews go on without asking."

	aReplayUIBuilder nextStep
]

{ #category : 'running' }
ReplayNavigate >> runOn: runner [
	"Has control over the runner continuation.
	Closing the dialog without answering stops the scenario, like cancelling."

	| answered dialog window |
	self skip ifTrue: [ ^ runner nextStep ].
	answered := false.
	dialog := SpConfirmDialog new
		title: runner scenario title;
		icon: (self iconNamed: #info);
		label: (Microdown asRichText: self text);
		acceptLabel: self acceptLabel;
		onAccept: [
			answered := true.
			"Defer so windows appear in same spot between steps."
			runner defer: [ runner nextStep ] ];
		cancelLabel: self cancelLabel;
		onCancel: [
			answered := true.
			runner stop ];
		yourself.
	window := dialog asDialogWindow.
	placement ifNotNil: [ placement applyToWindowPresenter: window ].
	window whenClosedDo: [ answered ifFalse: [ runner stop ] ].
	window open.
	^ window
]

{ #category : 'accessing' }
ReplayNavigate >> skip [

	^ skip ifNil: [ true ]
]

{ #category : 'accessing' }
ReplayNavigate >> skip: aBoolean [

	skip := aBoolean
]

{ #category : 'accessing' }
ReplayNavigate >> text [

	^ text ifNil: [ 'Proceed?' ]
]
