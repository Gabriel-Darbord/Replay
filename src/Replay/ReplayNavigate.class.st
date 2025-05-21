"
A particular action that is executed at the end of a `ReplayStep`.
It is responsible for letting users navigate through the scenario.
"
Class {
	#name : 'ReplayNavigate',
	#superclass : 'ReplayAction',
	#traits : 'TReplayActionWithText',
	#classTraits : 'TReplayActionWithText classTrait',
	#instVars : [
		'skip',
		'acceptLabel',
		'cancelLabel'
	],
	#category : 'Replay',
	#package : 'Replay'
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

	^ acceptLabel ifNil: [ acceptLabel := 'Next' ]
]

{ #category : 'accessing' }
ReplayNavigate >> acceptLabel: aString [

	acceptLabel := aString
]

{ #category : 'accessing' }
ReplayNavigate >> cancelLabel [

	^ cancelLabel ifNil: [ cancelLabel := 'Stop' ]
]

{ #category : 'accessing' }
ReplayNavigate >> cancelLabel: aString [

	cancelLabel := aString
]

{ #category : 'editing' }
ReplayNavigate >> editionPresenterOn: editor [

	^ SpPresenter new
		  layout: (SpBoxLayout newTopToBottom
				   spacing: 10;
				   add: (SpCheckBoxPresenter new
						    label: 'Skip user navigation';
						    state: skip;
						    whenActivatedDo: [ skip := true ];
						    whenDeactivatedDo: [ skip := false ])
				   expand: false;
				   add: (SpBoxLayout newTopToBottom
						    add: 'Continue label:' expand: false;
						    add: (SpTextPresenter new
								     text: self acceptLabel;
								     whenTextChangedDo: [ :aString |
									     self acceptLabel: aString ]))
				   expand: false;
				   add: (SpBoxLayout newTopToBottom
						    add: 'Cancel label:' expand: false;
						    add: (SpTextPresenter new
								     text: self cancelLabel;
								     whenTextChangedDo: [ :aString |
									     self cancelLabel: aString ]))
				   expand: false;
				   add: (self
						    textPresenterOn: editor
						    labeled:
						    'Write the rich text to display on the navigation window:');
				   yourself);
		  yourself
]

{ #category : 'initialization' }
ReplayNavigate >> initialize [

	skip := false
]

{ #category : 'printing' }
ReplayNavigate >> printOn: stream [

	super printOn: stream.
	text isEmptyOrNil ifTrue: [ ^ self ].
	stream nextPutAll: ': '.
	stream nextPutAll: (text printStringLimitedTo: 100)
]

{ #category : 'running' }
ReplayNavigate >> runOn: runner [
	"Has control of runner continuation"

	skip ifTrue: [ ^ runner nextStep ].

	(SpConfirmDialog new
		 title: runner scenario title;
		 icon: (self iconNamed: #info);
		 label: (Microdown asRichText: self text);
		 acceptLabel: self acceptLabel;
		 onAccept: [ "Defer so windows appear in the same spot between steps"
			 self currentWorld defer: [ runner nextStep ] ];
		 cancelLabel: self cancelLabel;
		 onCancel: [ runner stop ]) openDialog
]

{ #category : 'accessing' }
ReplayNavigate >> text [

	^ text ifNil: [ text := 'Proceed?' ]
]
