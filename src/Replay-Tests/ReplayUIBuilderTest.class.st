"
Tests for ReplayUIBuilder editor previews: opener search, preview replay, and errors reported to the editor.
"
Class {
	#name : 'ReplayUIBuilderTest',
	#superclass : 'ReplayTestCase',
	#instVars : [
		'scenario',
		'builder'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayUIBuilderTest >> allPresentersIn: aPresenterOrLayout [

	| result |
	result := OrderedCollection new.
	self collectPresentersIn: aPresenterOrLayout into: result.
	^ result
]

{ #category : 'support' }
ReplayUIBuilderTest >> buildUIFor: anAction [
	"Build the preview up to the action, waiting until it is done."

	| done ui |
	done := false.
	builder := ReplayUIBuilder on: scenario.
	builder whenDone: [ done := true ].
	ui := builder uiForAction: anAction inStep: (scenario steps detect: [ :step |
		step actions includes: anAction ]).
	self waitUntil: [ done ].
	^ ui
]

{ #category : 'support' }
ReplayUIBuilderTest >> collectPresentersIn: aPresenterOrLayout into: aCollection [

	(aPresenterOrLayout isKindOf: SpAbstractPresenter) ifTrue: [
		aCollection add: aPresenterOrLayout.
		aPresenterOrLayout layout ifNotNil: [ :layout |
			self collectPresentersIn: layout into: aCollection ].
		^ self ].
	(aPresenterOrLayout respondsTo: #children) ifTrue: [
		aPresenterOrLayout children do: [ :each |
			self collectPresentersIn: each into: aCollection ] ]
]

{ #category : 'support' }
ReplayUIBuilderTest >> openScriptablePresenter [

	^ ReplayOpenPresenter new script: 'ReplayScriptablePresenter new'
]

{ #category : 'support' }
ReplayUIBuilderTest >> scenarioWithSteps: actionLists [

	scenario := ReplayScenario new title: 'Replay builder test ' , self selector.
	actionLists do: [ :actions |
		| step |
		step := ReplayStep new.
		step navigation skip: false.
		actions do: [ :action | step addAction: action ].
		scenario addStep: step ].
	^ scenario
]

{ #category : 'running' }
ReplayUIBuilderTest >> tearDown [

	builder ifNotNil: [ builder stop ].
	super tearDown
]

{ #category : 'tests' }
ReplayUIBuilderTest >> testActionNotInStepSignalsReplayError [

	self scenarioWithSteps: { { self openScriptablePresenter } }.
	builder := ReplayUIBuilder on: scenario.

	self
		should: [ builder uiForAction: ReplayClick new inStep: scenario steps first ]
		raise: ReplayError
]

{ #category : 'tests' }
ReplayUIBuilderTest >> testAttachedUIIsNotPreviewed [

	| root target |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	root addMorph: target.
	{
		ReplayAttachWorld new.
		ReplayAttachActiveWindow new.
		(ReplayAttachUI new script: 'Smalltalk globals at: #ReplayUIBuilderTestTarget') } do: [ :attach |
		| click |
		click := ReplayClick new.
		self scenarioWithSteps: { { attach. click } }.
		builder := ReplayUIBuilder on: scenario.
		Smalltalk globals at: #ReplayUIBuilderTestTarget put: target.
		[
			self
				should: [ builder uiForAction: click inStep: scenario steps first ]
				raise: ReplayMissingUIError ]
			ensure: [ Smalltalk globals removeKey: #ReplayUIBuilderTestTarget ifAbsent: [  ] ].
		self assert: builder manager isNil.
		self assert: root submorphs asArray equals: { target } ]
]

{ #category : 'tests' }
ReplayUIBuilderTest >> testBuildsBrowseClassPreview [

	| target |
	target := ReplayClick new.
	self scenarioWithSteps: { {
		(ReplayBrowseClass new targetClass: ReplayScenario; yourself).
		target } }.

	self buildUIFor: target.

	self assert: builder manager ownsUI.
	self assert: builder manager managedUI isMorph.
	self assert: self newWindows isEmpty
]

{ #category : 'tests' }
ReplayUIBuilderTest >> testBuildsPresenterPreviewReplayingActionsUpToTarget [

	| target ui |
	target := ReplayClick new.
	self scenarioWithSteps: { {
		self openScriptablePresenter.
		(ReplayPresenterScript new script: 'self record: #before').
		target.
		(ReplayPresenterScript new script: 'self record: #after') } }.

	ui := self buildUIFor: target.

	self assert: ui identicalTo: builder manager ui.
	self assert: builder manager managedPresenter log asArray equals: #( before ).
	self assert: builder isStopped.
	self assert: self newWindows isEmpty
]

{ #category : 'tests' }
ReplayUIBuilderTest >> testClosedUISignalsMissingUI [

	| target |
	target := ReplayClick new.
	self scenarioWithSteps: { { self openScriptablePresenter. ReplayCloseUI new. target } }.
	builder := ReplayUIBuilder on: scenario.

	self
		should: [ builder uiForAction: target inStep: scenario steps first ]
		raise: ReplayMissingUIError
]

{ #category : 'tests' }
ReplayUIBuilderTest >> testMissingOpenerSignalsMissingUI [

	| target |
	target := ReplayClick new.
	self scenarioWithSteps: { { ReplayScript new. target } }.
	builder := ReplayUIBuilder on: scenario.

	self
		should: [ builder uiForAction: target inStep: scenario steps first ]
		raise: ReplayMissingUIError
]

{ #category : 'tests' }
ReplayUIBuilderTest >> testMissingUIHelpDefaultsToGenericHelp [

	| actionEditor presenter |
	actionEditor := ReplayEditor new editAction: ReplayOpenPresenter new.
	presenter := ReplayMissingUIError new
		messageText: 'No UI';
		helpPresenterFor: actionEditor.

	self assert: presenter isNotNil.
	self assert: ((self allPresentersIn: presenter) anySatisfy: [ :each |
		(each isKindOf: SpButtonPresenter) and: [ each label = 'Debug exception' ] ])
]

{ #category : 'tests' }
ReplayUIBuilderTest >> testPreviewSkipsActionsWithEffectsOutsideThePreview [

	| target |
	target := ReplayClick new.
	self scenarioWithSteps: { {
		self openScriptablePresenter.
		(ReplayDelay seconds: 60).
		(ReplayInform new text: 'Not shown in previews').
		(ReplayScript new script: 'self focus: #ran').
		target } }.

	self buildUIFor: target.

	self assert: builder focus isNil
]

{ #category : 'tests' }
ReplayUIBuilderTest >> testScriptErrorHelpIsReportedAgainstTheFailingAction [

	| target editor presenter debugButtons |
	target := ReplayClick new.
	self scenarioWithSteps: { { ReplayOpenPresenter new script: '42'. target } }.
	editor := ReplayEditor on: scenario.

	presenter := (editor editAction: target) tryNewUIEditionPresenter.

	debugButtons := (self allPresentersIn: presenter) select: [ :each |
		(each isKindOf: SpButtonPresenter) and: [ each label = 'Debug the script' ] ].
	self assert: debugButtons size equals: 1
]

{ #category : 'tests' }
ReplayUIBuilderTest >> testScriptErrorHelpWithoutScriptDefaultsToGenericHelp [

	| presenter |
	presenter := ReplayScriptError new
		messageText: 'Failure';
		helpPresenterFor: (ReplayEditor new editAction: ReplayFocus new).

	self assert: presenter isNotNil.
	self assert: ((self allPresentersIn: presenter) anySatisfy: [ :each |
		(each isKindOf: SpButtonPresenter) and: [ each label = 'Debug exception' ] ])
]

{ #category : 'tests' }
ReplayUIBuilderTest >> testSearchesOpenerBackwardsAcrossStepsWithoutNavigating [

	| target |
	target := ReplayClick new.
	self scenarioWithSteps: {
		{ self openScriptablePresenter. (ReplayPresenterScript new script: 'self record: #first') }.
		{  }.
		{ (ReplayPresenterScript new script: 'self record: #third'). target } }.

	self buildUIFor: target.

	self assert: builder manager managedPresenter log asArray equals: #( first third ).
	self assert: self newWindows isEmpty
]

{ #category : 'tests' }
ReplayUIBuilderTest >> testStepNotInScenarioSignalsReplayError [

	| step |
	self scenarioWithSteps: { { self openScriptablePresenter } }.
	step := ReplayStep new.
	step addAction: ReplayClick new.
	builder := ReplayUIBuilder on: scenario.

	self
		should: [ builder uiForAction: step actions first inStep: step ]
		raise: ReplayError
]
