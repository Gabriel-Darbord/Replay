"
I am the abstract base for actions that act on a target UI element.

My target is a ReplayUIReference. Without one, I target the current World, which needs no managed UI; actions that need a real target answer false to allowsWorldTarget. Any other target is resolved by the manager of the runner, possibly over several UI cycles, into a ReplayResolvedUIElement.

The backend of the resolved element runs me: it first asks me to run on the native element (a Spec presenter for instance) with runNativelyOn:, and when I cannot, it gives me the Morphic widget with runOnMorph:. Subclasses that can act on native elements override canRunNativelyOn: and runOnNative:; resolvers also ask canRunNativelyOn: to accept a native element that has no widget yet.
"
Class {
	#name : 'ReplayUIHandler',
	#superclass : 'ReplayUIAction',
	#instVars : [
		'target'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'testing' }
ReplayUIHandler class >> isAbstract [

	^ self == ReplayUIHandler
]

{ #category : 'testing' }
ReplayUIHandler class >> shouldBeMenuItem [

	^ true
]

{ #category : 'instance creation' }
ReplayUIHandler class >> target: aReplayUIReference [

	^ self new target: aReplayUIReference
]

{ #category : 'testing' }
ReplayUIHandler >> allowsWorldTarget [
	^ true
]

{ #category : 'testing' }
ReplayUIHandler >> canRunNativelyOn: anObject [
	"Whether I can act on anObject, the native element of a resolved target, instead of its Morphic widget"

	^ false
]

{ #category : 'testing' }
ReplayUIHandler >> controlsRunnerContinuation [

	^ true
]

{ #category : 'testing' }
ReplayUIHandler >> hasSpecificTarget [

	^ self target isWorld not
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

{ #category : 'error handling' }
ReplayUIHandler >> missingManagerFor: runner [

	ReplayMissingUIError new
		messageText: 'No Replay UI is available for target ', self target printString, '.';
		subject: runner;
		signal
]

{ #category : 'error handling' }
ReplayUIHandler >> missingTarget [

	ReplayMissingUIError new
		messageText: self class displayName , ' needs a target: choose one in its settings.';
		subject: self;
		signal
]

{ #category : 'editing' }
ReplayUIHandler >> missingTargetPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newLeftToRight
				spacing: 10;
				add: (self iconNamed: #error) expand: false;
				add: 'Missing target. Use UI edition view to select one.' expand: false;
				yourself);
		yourself
]

{ #category : 'running' }
ReplayUIHandler >> resolveTargetWith: aReplayUIManager thenDo: foundBlock onMissing: missingBlock [

	^ aReplayUIManager
		  resolve: self target
		  forAction: self
		  thenDo: foundBlock
		  onMissing: missingBlock
]

{ #category : 'running' }
ReplayUIHandler >> runNativelyOn: anObject [
	"Act on anObject, the native element of a resolved target, if I can. Answer whether I did."

	(anObject notNil and: [ self canRunNativelyOn: anObject ]) ifFalse: [ ^ false ].
	self runOnNative: anObject.
	^ true
]

{ #category : 'running' }
ReplayUIHandler >> runOn: runner [
	"Has control over runner continuation."

	| manager |
	self target isWorld ifTrue: [ ^ self runOnWorldOf: runner ].
	manager := runner manager.
	manager ifNil: [ ^ self missingManagerFor: runner ].
	self
		resolveTargetWith: manager
		thenDo: [ :resolved |
			runner isStopped ifFalse: [
				runner protect: [ self runOn: runner resolvedUI: resolved ].
				"Let UI process action effects before continuing."
				runner defer: [ runner nextAction ] ] ]
		onMissing: [ :error |
			runner isStopped ifFalse: [ runner protect: [ error signal ] ] ]
]

{ #category : 'running' }
ReplayUIHandler >> runOn: runner resolvedUI: resolvedUI [

	resolvedUI run: self
]

{ #category : 'running' }
ReplayUIHandler >> runOnMorph: aMorph [
	"Act on aMorph, the Morphic widget of my target"

	self subclassResponsibility
]

{ #category : 'running' }
ReplayUIHandler >> runOnNative: anObject [
	"Act on anObject, a native element. Only sent when canRunNativelyOn: answers true, so subclasses overriding it override me."

	self shouldNotImplement
]

{ #category : 'running' }
ReplayUIHandler >> runOnWorldOf: runner [
	"Act on the current World, which needs no managed UI. Has control over runner continuation."

	| world |
	self allowsWorldTarget ifFalse: [ ^ self missingTarget ].
	world := self currentWorld.
	self runOn: runner resolvedUI: (ReplayResolvedUIElement
			 backend: runner backend
			 reference: self target
			 nativeElement: world
			 morph: world).
	runner defer: [ runner nextAction ]
]

{ #category : 'editing' }
ReplayUIHandler >> semanticTargetPresenterOn: editor [

	| targetNamePresenter |
	(targetNamePresenter := editor newText)
		text: self targetName;
		whenTextChangedDo: [ :aString |
			self targetName: aString.
			editor actionChanged: self ].
	editor registerReplayPresenter: targetNamePresenter named: 'Action target name'.
	editor registerReplayPresenter: targetNamePresenter named: self class displayName , ' target name'.

	^ SpBoxLayout newTopToBottom
		spacing: 4;
		add: 'Semantic target name:' expand: false;
		add: targetNamePresenter expand: false;
		yourself
]

{ #category : 'accessing' }
ReplayUIHandler >> target [
	"The reference to the UI element I act on, the current World by default"

	^ target ifNil: [ ReplayUIReference world ]
]

{ #category : 'accessing' }
ReplayUIHandler >> target: aReplayUIReference [
	"Target the referenced UI element. Nil or a World reference target the current World."

	target := (aReplayUIReference notNil and: [ aReplayUIReference isWorld not ])
		          ifTrue: [ aReplayUIReference ]
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

	^ self target isNamed
		ifTrue: [ self target value ]
		ifFalse: [ '' ]
]

{ #category : 'accessing' }
ReplayUIHandler >> targetName: aString [
	"Target the presenter with the semantic name aString. An empty name clears a semantic target."

	| trimmed |
	trimmed := aString
		ifNil: [ '' ]
		ifNotNil: [ aString trimBoth ].
	trimmed
		ifEmpty: [ self target isNamed ifTrue: [ self targetWorld ] ]
		ifNotEmpty: [ self targetNamed: trimmed ]
]

{ #category : 'accessing' }
ReplayUIHandler >> targetNamed: aString [

	self target: (ReplayUIReference named: aString)
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
ReplayUIHandler >> targetPathPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newLeftToRight
				spacing: 10;
				add: (self iconNamed: #smallOk) expand: false;
				add: 'Target set.' expand: false;
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

	self target isNamed ifTrue: [ ^ self targetNamedPresenterOn: editor ].
	self target isMorphicPath ifTrue: [ ^ self targetPathPresenterOn: editor ].
	^ self allowsWorldTarget
		ifTrue: [ self worldTargetPresenterOn: editor ]
		ifFalse: [ self missingTargetPresenterOn: editor ]
]

{ #category : 'accessing' }
ReplayUIHandler >> targetWorld [

	target := nil
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
	builder := ReplayUIBuilder on: editor scenario.

	builder whenDone: [
		| manager highlight |
		manager := builder manager editor: editor.

		self hasSpecificTarget ifTrue: [ "Highlight the current target"
			self
				resolveTargetWith: manager
				thenDo: [ :resolved |
					resolved hasMorph ifTrue: [
						highlight := ReplayAnnotation annotateMorph: resolved morph.
						manager overlay addMorphBack: highlight ] ]
				onMissing: [ :error | "Nothing to highlight" ] ].

		manager clickBlock: [ :event :wrapper | "Update target highlight"
			highlight ifNotNil: [ highlight delete ].
			self target: wrapper reference.
			highlight := ReplayAnnotation annotateMorph: wrapper.
			manager overlay addMorphBack: highlight ].

		manager wrapForEdition ].

	^ editor newMorph morph:
		  (builder uiForAction: self inStep: editor currentStep)
]

{ #category : 'editing' }
ReplayUIHandler >> worldTargetPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newLeftToRight
				spacing: 10;
				add: (self iconNamed: #smallInfo) expand: false;
				add: 'Targeting current World. Use UI edition view to change target.' expand: false;
				yourself);
		yourself
]
