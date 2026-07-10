"
I am responsible for interacting with UI.
"
Class {
	#name : 'ReplayUIHandler',
	#superclass : 'ReplayUIAction',
	#instVars : [
		'path'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'instance creation' }
ReplayUIHandler class >> fromUIPath: collection [

	^ self new path: collection
]

{ #category : 'testing' }
ReplayUIHandler class >> isAbstract [

	^ self == ReplayUIHandler
]

{ #category : 'testing' }
ReplayUIHandler class >> shouldBeMenuItem [

	^ true
]

{ #category : 'testing' }
ReplayUIHandler >> controlsRunnerContinuation [

	^ true
]

{ #category : 'enumerating' }
ReplayUIHandler >> findElementIn: aMorph thenDo: aBlock [
	"Asynchronously wait for the Morph to be built and then find the target element."

	^ ReplayUIPathResolver
		  findPath: (path ifNil: [ #(  ) ])
		  in: aMorph
		  thenDo: aBlock
		  onMissing: [ :error | error signal ]
]

{ #category : 'editing' }
ReplayUIHandler >> helpPresenterOn: editor aboutMissingUI: error [

	| buttons |
	buttons := SpGridLayout build: [ :grid |
		           ReplayAction actionsThatOpenUI do: [ :action |
			           grid add: (editor newButton
					            icon: (self iconNamed: #add);
					            label: action displayName;
					            action: [ editor addAction: action new before: self ]) ] ].

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
						    spacing: -15;
						    add: 'Choose an action that opens a UI:' expand: false;
						    add: buttons;
						    yourself);
				   yourself);
		  yourself
]

{ #category : 'testing' }
ReplayUIHandler >> isUIHandler [

	^ true
]

{ #category : 'accessing' }
ReplayUIHandler >> path [

	^ path
]

{ #category : 'accessing' }
ReplayUIHandler >> path: aCollection [
	"Path through the owner chain, each element is a child index"

	path := aCollection
]

{ #category : 'editing' }
ReplayUIHandler >> pathOkPresenterOn: editor [
	"When the path is set"

	^ editor newPresenter
		  layout: (SpBoxLayout newLeftToRight
				   spacing: 10;
				   add: (self iconNamed: #smallOk) expand: false;
				   add: 'Target set.' expand: false;
				   yourself);
		  yourself
]

{ #category : 'editing' }
ReplayUIHandler >> pathOrWorldPresenterOn: editor [
	"Add a button that allows unsetting the path to target the current World."

	| layout pathStatePresenter targetWorldButton |
	layout := SpBoxLayout newLeftToRight.
	pathStatePresenter := self pathStatePresenterOn: editor.
	(targetWorldButton := editor newButton)
		icon: (self iconNamed: #edit);
		label: 'Target World';
		action: [
			path ifNotNil: [
					| newPresenter |
					self targetWorld.
					layout
						replace: pathStatePresenter
						with: (newPresenter := self pathUnsetPresenterOn: editor).
					editor actionEditor view rebuildLayout.
					pathStatePresenter := newPresenter ] ].

	^ editor newPresenter
		  layout: (layout
				   vAlignStart;
				   spacing: 10;
				   add: targetWorldButton expand: false;
				   add: pathStatePresenter;
				   yourself);
		  yourself
]

{ #category : 'editing' }
ReplayUIHandler >> pathPresenterOn: editor [
	"Hook to let actions decide which presenter to use for representing and editing the path."

	^ self pathOrWorldPresenterOn: editor
]

{ #category : 'editing' }
ReplayUIHandler >> pathRequiredPresenterOn: editor [
	"When the path is not set, indicate it is necessary and explain how to set it."

	^ editor newPresenter
		  layout: (SpBoxLayout newLeftToRight
				   spacing: 10;
				   add: (self iconNamed: #error) expand: false;
				   add: 'Missing target. Use the UI edition view to select one.'
				   expand: false;
				   yourself);
		  yourself
]

{ #category : 'editing' }
ReplayUIHandler >> pathSetPresenterOn: editor [
	"Hook to let actions decide which presenter to use when the path is set."

	^ self pathOkPresenterOn: editor
]

{ #category : 'editing' }
ReplayUIHandler >> pathStatePresenterOn: editor [
	"Use a different presenter whether the path is set or not."

	^ path
		  ifNil: [ self pathUnsetPresenterOn: editor ]
		  ifNotNil: [ self pathSetPresenterOn: editor ]
]

{ #category : 'editing' }
ReplayUIHandler >> pathUnsetPresenterOn: editor [
	"Hook to let actions decide which presenter to use when the path is *NOT* set."

	^ self pathWorldPresenterOn: editor
]

{ #category : 'editing' }
ReplayUIHandler >> pathWorldPresenterOn: editor [
	"When the path is not set, inform that the World is targeted."

	^ editor newPresenter
		  layout: (SpBoxLayout newLeftToRight
				   spacing: 10;
				   add: (self iconNamed: #smallInfo) expand: false;
				   add:
					   'Targeting current World. Use the UI edition view to change target.'
				   expand: false;
				   yourself);
		  yourself
]

{ #category : 'running' }
ReplayUIHandler >> runOn: runner [
	"Has control of runner continuation."

	path ifNil: [ ^ self runWithoutPathOn: runner ].

	self findElementIn: runner manager managedUI thenDo: [ :ui |
		self runOn: runner onUI: ui.
		"Let Morphic process effects from this action before continuing."
		self currentWorld defer: [ runner nextAction ] ]
]

{ #category : 'running' }
ReplayUIHandler >> runOn: runner onUI: ui [

	self subclassResponsibility
]

{ #category : 'running' }
ReplayUIHandler >> runWithoutPathOn: runner [
	"When path is nil, the default behavior is to target the current World.
	Has control of runner continuation."

	self runOn: runner onUI: self currentWorld.

	"Await UI process before continuing"
	self currentWorld defer: [ runner nextAction ]
]

{ #category : 'accessing' }
ReplayUIHandler >> targetWorld [
	"Target the current World when the path is unset"

	path := nil
]

{ #category : 'editing' }
ReplayUIHandler >> uiEditionPresenterOn: editor [
	"Presenter that highlights the current target and allows changing it"

	| builder |
	builder := ReplayUIBuilder on: editor model scenario.

	builder whenDone: [
		| manager highlight |
		manager := builder manager editor: editor.

		path ifNotNil: [ "Highlight the current target"
			self findElementIn: manager managedUI thenDo: [ :element |
				highlight := ReplayAnnotation annotateMorph: element.
				manager overlay addMorphBack: highlight ] ].

		manager clickBlock: [ :event :wrapper | "Update target highlight"
			highlight ifNotNil: [ highlight delete ].
			self path: wrapper path.
			highlight := ReplayAnnotation annotateMorph: wrapper.
			manager overlay addMorphBack: highlight ].

		manager wrapForEdition ].

	^ editor newMorph morph:
		  (builder uiForAction: self inStep: editor model currentStep)
]
