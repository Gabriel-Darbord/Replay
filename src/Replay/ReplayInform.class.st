"
I show an informational UIManager notification as a scenario action. Editor previews do not show it.
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

{ #category : 'running' }
ReplayInform >> previewOn: aReplayUIBuilder [
	"Notifications are not part of the previewed UI."
]

{ #category : 'running' }
ReplayInform >> runOn: runner [

	self uiManager inform: (Microdown asRichText: self text)
]
