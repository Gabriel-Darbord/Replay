"
Tests for the UI views of the action editors: the preview of the UI that opener actions open, the preview up to an action after each kind of opener, the highlight of the current target, named or by path, the notice shown when the target is missing, and choosing a target by clicking a wrapper.
"
Class {
	#name : 'ReplayActionEditorPreviewTest',
	#superclass : 'ReplayTestCase',
	#instVars : [
		'editor'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayActionEditorPreviewTest >> edit: anAction in: actions [
	"Show the editor of anAction, in a scenario with a step of actions"

	| step scenario |
	step := ReplayStep new.
	actions do: [ :each | step addAction: each ].
	scenario := ReplayScenario new.
	scenario addStep: step.
	editor := ReplayEditorSpy on: scenario.
	^ editor editAction: anAction
]

{ #category : 'support' }
ReplayActionEditorPreviewTest >> highlightsOf: aReplayUIManager [

	^ aReplayUIManager overlay submorphs select: [ :each | each isKindOf: ReplayAnnotation ]
]

{ #category : 'support' }
ReplayActionEditorPreviewTest >> openers [

	^ {
		  (ReplayOpenPresenter new script: 'ReplaySemanticPresenter new').
		  (ReplayBrowseClass new targetClass: ReplayStep; yourself).
		  (ReplayBrowseMethod new targetMethod: ReplayStep >> #addAction:; yourself).
		  (ReplayBrowsePackage new targetPackage: ReplayStep package; yourself) }
]

{ #category : 'support' }
ReplayActionEditorPreviewTest >> showUIView [
	"Show the UI view of the action editor, and answer it"

	editor actionEditor viewSwitcher switcher children second state: true.
	^ editor actionEditor viewSwitcher view
]

{ #category : 'support' }
ReplayActionEditorPreviewTest >> waitForEditSession [

	self waitUntil: [ editor actionEditor editSession isNotNil ].
	self waitUntil: [ editor actionEditor editSession manager overlay submorphs anySatisfy: [ :each | each isKindOf: ReplayWrapperMorph ] ].
	^ editor actionEditor editSession
]

{ #category : 'tests' }
ReplayActionEditorPreviewTest >> testAttachedUIExplainsThatItCannotBePreviewed [

	{ ReplayAttachWorld new. ReplayAttachActiveWindow new. ReplayAttachUI new } do: [ :attach |
		| focus view |
		focus := ReplayFocus new.
		self edit: focus in: { attach. focus }.

		view := self showUIView.

		self deny: (view isKindOf: SpMorphPresenter).
		self assert: (editor replayPresenterAt: 'Action target notice' ifAbsent: [ #missing ]) equals: #missing ].
	self assert: self newWindows isEmpty
]

{ #category : 'tests' }
ReplayActionEditorPreviewTest >> testClickingAWrapperTargetsItsMorph [

	| focus session wrapper manager |
	focus := ReplayFocus new.
	self edit: focus in: { self openers first. focus }.
	self showUIView.
	session := self waitForEditSession.
	manager := session manager.
	wrapper := manager overlay submorphs detect: [ :each | each isKindOf: ReplayWrapperMorph ].
	wrapper := wrapper submorphs first.

	session
		onClick: (MouseButtonEvent new
				 setType: #mouseUp
				 position: wrapper center
				 which: MouseEvent redButton
				 buttons: 0
				 hand: (HandMorph new
						  privateOwner: self currentWorld;
						  yourself)
				 stamp: Time millisecondClockValue)
		onWrapper: wrapper.

	self assert: focus target equals: wrapper reference.
	self assert: editor changedActions asArray equals: { focus }.
	self assert: (self highlightsOf: manager) size equals: 1.
	self assert: (self highlightsOf: manager) first bounds equals: (wrapper bounds expandBy: 5)
]

{ #category : 'tests' }
ReplayActionEditorPreviewTest >> testHandlerUIViewPreviewsAfterEachOpener [

	self openers do: [ :opener |
		| focus view |
		focus := ReplayFocus new.
		self edit: focus in: { opener. focus }.

		view := self showUIView.

		self assert: (view layout children last isKindOf: SpMorphPresenter).
		self waitForEditSession ].
	self assert: self newWindows isEmpty
]

{ #category : 'tests' }
ReplayActionEditorPreviewTest >> testHighlightsANamedTarget [

	| focus manager expected |
	focus := ReplayFocus target: (ReplayUIReference named: 'Field').
	self edit: focus in: { self openers first. focus }.
	self showUIView.
	manager := self waitForEditSession manager.

	self waitUntil: [ (self highlightsOf: manager) isNotEmpty ].

	manager resolve: focus target forAction: focus thenDo: [ :resolved | expected := resolved boundsInSurface ] onMissing: [ :error | self fail ].
	self waitUntil: [ expected isNotNil ].
	self assert: (self highlightsOf: manager) first bounds equals: (expected expandBy: 5).
	self assert: (editor replayPresenterAt: 'Action target notice' ifAbsent: [ nil ]) label isEmpty
]

{ #category : 'tests' }
ReplayActionEditorPreviewTest >> testHighlightsAPathTarget [

	| focus manager expected |
	focus := ReplayFocus target: (ReplayUIReference morphicPath: #( 1 )).
	self edit: focus in: { self openers first. focus }.
	self showUIView.
	manager := self waitForEditSession manager.

	self waitUntil: [ (self highlightsOf: manager) isNotEmpty ].

	expected := manager managedMorph submorphs first boundsIn: manager managedMorph.
	self assert: (self highlightsOf: manager) first bounds equals: (expected expandBy: 5)
]

{ #category : 'tests' }
ReplayActionEditorPreviewTest >> testMissingTargetShowsANoticeInsteadOfSignalling [

	| focus manager notice |
	focus := ReplayFocus target: (ReplayUIReference named: 'Not in this UI').
	self edit: focus in: { self openers first. focus }.
	self showUIView.
	manager := self waitForEditSession manager.
	notice := editor replayPresenterAt: 'Action target notice' ifAbsent: [ nil ].

	self waitUntil: [ notice label isNotEmpty ] timeout: 10 seconds.

	self assert: (notice label includesSubstring: 'Target not found').
	self assert: (self highlightsOf: manager) isEmpty
]

{ #category : 'tests' }
ReplayActionEditorPreviewTest >> testOpenerUIViewPreviewsItsOwnUI [

	self openers do: [ :opener |
		| view |
		self edit: opener in: { opener }.

		view := self showUIView.

		self assert: (view isKindOf: SpMorphPresenter).
		self assert: (view morph isKindOf: ReplayRootMorph).
		self waitUntil: [ view morph allMorphs anySatisfy: [ :each | each isKindOf: ReplayWrapperMorph ] ] ].
	self assert: self newWindows isEmpty
]
