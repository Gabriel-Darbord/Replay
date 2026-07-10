"
I am responsible for interacting with UI.
"
Class {
	#name : 'ReplayUIHandler',
	#superclass : 'ReplayUIAction',
	#instVars : [
		'path',
		'reference'
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
ReplayUIHandler >> allowsWorldTarget [
	^ true
]

{ #category : 'testing' }
ReplayUIHandler >> controlsRunnerContinuation [

	^ true
]

{ #category : 'enumerating' }
ReplayUIHandler >> findElementIn: aMorph thenDo: aBlock [
	"Compatibility path for editor highlights that resolve against an explicit Morph."

	^ (ReplayMorphicResolver on: (ReplayMorphicBackend on: aMorph))
		resolve: self uiReference
		thenDo: [ :resolved | aBlock value: resolved morph ]
		onMissing: [ :error | error signal ]
]

{ #category : 'testing' }
ReplayUIHandler >> hasSpecificTarget [

	path ifNotNil: [ ^ true ].
	reference ifNil: [ ^ false ].
	^ reference isWorld not
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
	"Path through owner chain, each element child index"

	path := aCollection.
	reference := nil
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
	"Compatibility hook for older editor code."

	^ self targetPresenterOn: editor
]

{ #category : 'editing' }
ReplayUIHandler >> pathPresenterOn: editor [
	"Hook to let actions decide which presenter to use for representing and editing the UI target."

	^ self targetPresenterOn: editor
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
	"Use a different presenter depending on the selected UI target."

	^ self targetStatePresenterOn: editor
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

{ #category : 'accessing' }
ReplayUIHandler >> reference [

	^ reference
]

{ #category : 'accessing' }
ReplayUIHandler >> reference: aReplayUIReference [

	reference := aReplayUIReference.
	path := nil
]

{ #category : 'running' }
ReplayUIHandler >> runOn: runner [
	"Has control over runner continuation."

	| uiReference |
	uiReference := self uiReference.
	uiReference isWorld ifTrue: [ ^ self runWithoutPathOn: runner ].

	runner manager
		resolve: uiReference
		thenDo: [ :resolved |
			runner isStopped ifFalse: [
				self runOn: runner resolvedUI: resolved.
				"Let UI process action effects before continuing."
				self currentWorld defer: [
					runner isStopped ifFalse: [ runner nextAction ] ] ] ]
		onMissing: [ :error |
			runner isStopped ifFalse: [ error signal ] ]
]

{ #category : 'running' }
ReplayUIHandler >> runOn: runner onUI: ui [

	self subclassResponsibility
]

{ #category : 'running' }
ReplayUIHandler >> runOn: runner resolvedUI: resolvedUI [

	^ self runOn: runner onUI: (resolvedUI morphRequiredFor: self class displayName)
]

{ #category : 'running' }
ReplayUIHandler >> runWithoutPathOn: runner [
	"When path is nil, the default behavior is to target the current World.
	Has control of runner continuation."

	self runOn: runner onUI: self currentWorld.

	"Await UI process before continuing"
	self currentWorld defer: [ runner nextAction ]
]

{ #category : 'editing' }
ReplayUIHandler >> semanticTargetPresenterOn: editor [

	| targetNamePresenter |
	(targetNamePresenter := editor newText)
		text: self targetName;
		whenTextChangedDo: [ :aString |
			self targetName: aString.
			editor actions rebuildLayout ].

	^ SpBoxLayout newTopToBottom
		spacing: 4;
		add: 'Semantic target name:' expand: false;
		add: targetNamePresenter expand: false;
		yourself
]

{ #category : 'editing' }
ReplayUIHandler >> targetControlsPresenterOn: editor [

	| layout |
	layout := SpBoxLayout newLeftToRight
		vAlignStart;
		spacing: 10;
		yourself.
	self allowsWorldTarget ifTrue: [
		layout add: (self targetWorldButtonPresenterOn: editor) expand: false ].
	layout add: (self targetStatePresenterOn: editor) expand: false.

	^ editor newPresenter
		layout: layout;
		yourself
]

{ #category : 'accessing' }
ReplayUIHandler >> targetName [

	^ (reference notNil and: [ reference isNamed ])
		ifTrue: [ reference value ]
		ifFalse: [ '' ]
]

{ #category : 'accessing' }
ReplayUIHandler >> targetName: aString [

	| trimmed |
	trimmed := aString
		ifNil: [ '' ]
		ifNotNil: [ aString trimBoth ].
	trimmed
		ifEmpty: [
			reference ifNotNil: [
				reference isNamed ifTrue: [ reference := nil ] ] ]
		ifNotEmpty: [ self targetNamed: trimmed ]
]

{ #category : 'accessing' }
ReplayUIHandler >> targetNamed: aString [

	self reference: (ReplayUIReference named: aString)
]

{ #category : 'editing' }
ReplayUIHandler >> targetNamedPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newLeftToRight
				spacing: 10;
				add: (self iconNamed: #smallOk) expand: false;
				add: ('Semantic target: ' , self targetName) expand: false;
				yourself);
		yourself
]

{ #category : 'editing' }
ReplayUIHandler >> targetPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: (self targetControlsPresenterOn: editor) expand: false;
				add: (self semanticTargetPresenterOn: editor) expand: false;
				yourself);
		yourself
]

{ #category : 'editing' }
ReplayUIHandler >> targetStatePresenterOn: editor [

	(reference notNil and: [ reference isNamed ])
		ifTrue: [ ^ self targetNamedPresenterOn: editor ].
	(path notNil or: [ reference notNil and: [ reference isMorphicPath ] ])
		ifTrue: [ ^ self pathSetPresenterOn: editor ].
	^ self allowsWorldTarget
		ifTrue: [ self pathWorldPresenterOn: editor ]
		ifFalse: [ self pathUnsetPresenterOn: editor ]
]

{ #category : 'accessing' }
ReplayUIHandler >> targetWorld [
	"Target current World when path unset"

	path := nil.
	reference := nil
]

{ #category : 'editing' }
ReplayUIHandler >> targetWorldButtonPresenterOn: editor [

	^ editor newButton
		icon: (self iconNamed: #edit);
		label: 'Target World';
		action: [
			self targetWorld.
			editor actionEditor view rebuildLayout ];
		yourself
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

{ #category : 'accessing' }
ReplayUIHandler >> uiReference [

	reference ifNotNil: [ ^ reference ].
	^ path
		ifNil: [ ReplayUIReference world ]
		ifNotNil: [ ReplayUIReference morphicPath: path ]
]
