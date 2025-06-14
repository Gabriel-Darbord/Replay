"
Triggers an information event using `UIManager>>#inform:`.
"
Class {
	#name : 'ReplayInform',
	#superclass : 'ReplayAction',
	#traits : 'TReplayActionWithText',
	#classTraits : 'TReplayActionWithText classTrait',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayInform class >> displayName [

	^ 'Inform'
]

{ #category : 'editing' }
ReplayInform >> editionPresenterOn: editor [

	^ editor newPresenter
		  layout: (SpBoxLayout new
				   add: (self
						    textPresenterOn: editor
						    labeled:
							    'Write the rich text to display with an information event:');
				   add: (editor newButton
						    icon: (self iconNamed: #smallDoIt);
						    label: 'Preview';
						    action: [ self inform: self text ])
				   expand: false;
				   yourself);
		  yourself
]

{ #category : 'printing' }
ReplayInform >> printOn: stream [

	super printOn: stream.
	text isEmptyOrNil ifTrue: [ ^ self ].
	stream nextPutAll: ': '.
	stream nextPutAll: (text printStringLimitedTo: 100)
]

{ #category : 'running' }
ReplayInform >> runOn: runner [

	self uiManager inform: (Microdown asRichText: self text)
]
