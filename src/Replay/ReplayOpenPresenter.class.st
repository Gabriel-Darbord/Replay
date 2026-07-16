"
I evaluate a script that creates a Spec presenter and opens it as Replay managed UI.
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

{ #category : 'editing' }
ReplayOpenPresenter >> helpPresenterOn: editor aboutScript: error [
	"The script evaluated to something else than a Spec presenter"

	| notAPresenter |
	notAPresenter := error tag. "The result of the script"

	^ editor newPresenter
		  layout: (SpBoxLayout newTopToBottom
				   spacing: 10;
				   add: (SpBoxLayout newLeftToRight
						    spacing: 10;
						    add: (self iconNamed: #error) expand: false;
						    add: error messageText;
						    yourself)
				   expand: false;
				   add: (SpBoxLayout newTopToBottom
						    add: 'Printing the unexpected value:' expand: false;
						    add: (editor newText
								     beWrapWord;
								     editable: false;
								     text: notAPresenter printString);
						    yourself);
				   add: (self
						    debugButtonPresenterOn: editor
						    labeled: 'Debug the script'
						    action: [ self debugScript ])
				   expand: false;
				   yourself);
		  yourself
]

{ #category : 'managing UI' }
ReplayOpenPresenter >> presenterOn: runner [
	"Evaluate script to obtain a Spec presenter."

	| presenter |
	presenter := Smalltalk compiler
		             receiver: runner;
		             isScripting: true;
		             evaluate: self script.
	(presenter isNil or: [ (presenter isKindOf: SpAbstractPresenter) not ])
		ifTrue: [ self unexpectedResult: presenter ].
	^ presenter
]

{ #category : 'printing' }
ReplayOpenPresenter >> printOn: stream [

	super printOn: stream.
	script isEmptyOrNil ifTrue: [ ^ self ].
	stream << ': '.
	stream nextPutAll: (script printStringLimitedTo: 100)
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

{ #category : 'running' }
ReplayOpenPresenter >> uiManagerOn: runner [

	^ ReplayUIManager new managePresenter: (self presenterOn: runner)
]

{ #category : 'managing UI' }
ReplayOpenPresenter >> uiOn: runner [
	"Evaluate script to obtain a Spec presenter and answer its Morph.
	Kept for compatibility; uiManagerOn: preserves the presenter for semantic actions."

	^ ReplayUIManager buildMorphFromSpec: (self presenterOn: runner)
]

{ #category : 'error handling' }
ReplayOpenPresenter >> unexpectedResult: notAPresenter [
	"The script evaluated to something else than a Spec presenter"

	ReplayScriptError new
		messageText:
			'Expected the script to return a Spec presenter, but got an instance of '
			, notAPresenter className , '.';
		tag: notAPresenter;
		signal
]
