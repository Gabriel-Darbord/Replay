"
I evaluate a script that creates a Spec presenter and opens it as Replay managed UI.

My script is evaluated with the runner as self. The presenter is kept by the manager backend, so semantic actions and presenter scripts can act on it.
"
Class {
	#name : 'ReplayOpenPresenter',
	#superclass : 'ReplayOpenUI',
	#traits : 'TReplayActionWithScript',
	#classTraits : 'TReplayActionWithScript classTrait',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayOpenPresenter class >> displayName [

	^ 'Open Presenter'
]

{ #category : 'managing UI' }
ReplayOpenPresenter >> presenterOn: runner [
	"Evaluate script to obtain a Spec presenter."

	| presenter |
	presenter := self evaluateScriptOn: runner.
	(presenter isKindOf: SpAbstractPresenter) ifFalse: [
		self unexpectedScriptResult: presenter expected: 'a Spec presenter' ].
	^ presenter
]

{ #category : 'editing' }
ReplayOpenPresenter >> settingsPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: (self
						scriptPresenterOn: editor
						labeled: 'Write the script that creates and returns the Spec presenter:');
				add: (self placementPresenterOn: editor) expand: false;
				yourself);
		yourself
]

{ #category : 'accessing' }
ReplayOpenPresenter >> settingsViewName [

	^ 'Presenter settings'
]

{ #category : 'managing UI' }
ReplayOpenPresenter >> uiManagerOn: runner [

	^ ReplayUIManager new managePresenter: (self presenterOn: runner)
]
