"
Headless tests for Replay UI backend selection.
"
Class {
	#name : 'ReplayUIBackendTest',
	#superclass : 'ReplayTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayUIBackendTest >> testAddingLabeledAnnotationToNonWorldOverlayDoesNotFail [

	| root target manager annotation |
	root := Morph new extent: 300 @ 200.
	target := Morph new bounds: (10 @ 10 extent: 80 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new attachTo: target.
	annotation := ReplayAnnotation annotate: target bounds label: 'Detached annotation'.

	self shouldnt: [ manager addOverlay: annotation ] raise: Error.
	self deny: annotation label isInWorld.
	manager close
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotateDefersOverlayThroughManagerBackend [

	| backend manager runner action resolved target |
	backend := ReplayRecordingBackend new.
	manager := ReplayUIManager new
		manage: (Morph new extent: 200 @ 100)
		usingBackend: backend.
	runner := ReplayRunner on: ReplayScenario new.
	runner manager: manager.
	target := Morph new bounds: (10 @ 10 extent: 80 @ 30).
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Target')
		nativeElement: target
		morph: target.
	action := ReplayAnnotate new text: 'Deferred annotation'; yourself.

	action runOn: runner resolvedUI: resolved.

	self assert: backend deferredBlockCount equals: 1.
	self assert: manager overlay submorphs isEmpty.
	backend runDeferredBlocks.
	self assert: manager overlay submorphs size equals: 1
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotatePlacementSettingsPresenterBuilds [

	| action presenter |
	action := ReplayAnnotate new placement: #below; text: 'Placed'; yourself.
	presenter := ReplayEditor new editAction: action.

	self assert: presenter notNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationAutomaticPlacementPrefersRightWhenItFits [

	| root manager annotation targetBounds |
	root := Morph new
		bounds: (100 @ 100 extent: 600 @ 300);
		yourself.
	root openInWorld.
	manager := ReplayUIManager new attachTo: root.
	targetBounds := 40 @ 80 extent: 80 @ 40.
	annotation := ReplayAnnotation annotate: targetBounds label: 'Automatic right placement'.

	[
		manager addOverlay: annotation.
		self assert: annotation label bounds left >= annotation targetBoundsInWorld right.
		self deny: (annotation label bounds intersects: annotation targetBoundsInWorld) ]

		ensure: [
			manager close.
			root delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationExplicitPlacementFallsBackWhenPreferredSideDoesNotFit [

	| worldBounds root manager annotation targetBounds |
	worldBounds := World visibleClearArea.
	root := Morph new
		bounds: ((worldBounds right - 180) @ (worldBounds top + 40) extent: 160 @ 120);
		yourself.
	root openInWorld.
	manager := ReplayUIManager new attachTo: root.
	targetBounds := 100 @ 20 extent: 50 @ 40.
	annotation := ReplayAnnotation
		annotate: targetBounds
		label: 'Preferred right fallback should move away from the target when the right side is crowded by the screen edge.'.
	annotation placement: #right.

	[
		manager addOverlay: annotation.
		self assert: annotation label bounds right <= worldBounds right.
		self deny: (annotation label bounds intersects: annotation targetBoundsInWorld) ]

		ensure: [
			manager close.
			root delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationHonorsExplicitAbovePlacement [

	| root manager annotation targetBounds |
	root := Morph new
		bounds: (200 @ 200 extent: 500 @ 320);
		yourself.
	root openInWorld.
	manager := ReplayUIManager new attachTo: root.
	targetBounds := 160 @ 160 extent: 80 @ 40.
	annotation := ReplayAnnotation annotate: targetBounds label: 'Explicit above placement'.
	annotation placement: #above.

	[
		manager addOverlay: annotation.
		self assert: annotation label bounds bottom <= annotation targetBoundsInWorld top.
		self deny: (annotation label bounds intersects: annotation targetBoundsInWorld) ]

		ensure: [
			manager close.
			root delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationHonorsExplicitLeftPlacement [

	| root manager annotation targetBounds |
	root := Morph new bounds: (200 @ 100 extent: 500 @ 260); yourself.
	root openInWorld.
	manager := ReplayUIManager new attachTo: root.
	targetBounds := 220 @ 80 extent: 80 @ 40.
	annotation := ReplayAnnotation
		annotate: targetBounds
		label: 'Explicit left placement'.
	annotation placement: #left.

	[
		manager addOverlay: annotation.
		self assert: annotation label bounds right <= annotation targetBoundsInWorld left.
		self deny: (annotation label bounds intersects: annotation targetBoundsInWorld) ]

		ensure: [
			manager close.
			root delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationLabelStaysInsideVisibleWorldNearRightEdge [

	| worldBounds root manager annotation targetBounds |
	worldBounds := World visibleClearArea.
	root := Morph new
		bounds: ((worldBounds right - 180) @ (worldBounds top + 40) extent: 160 @ 120);
		yourself.
	root openInWorld.
	manager := ReplayUIManager new attachTo: root.
	targetBounds := 100 @ 20 extent: 50 @ 40.
	annotation := ReplayAnnotation annotate: targetBounds label: 'Right edge annotation'.

	[
		manager addOverlay: annotation.
		self assert: annotation label bounds right <= worldBounds right.
		self assert: annotation label bounds left >= worldBounds left.
		self deny: (annotation label bounds intersects: annotation targetBoundsInWorld) ]
		ensure: [
			manager close.
			root delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationLabelsAndLinesAreNotWorldTopmost [

	self deny: ReplayAnnotationLabel new wantsToBeTopmost.
	self deny: ReplayAnnotationLine new wantsToBeTopmost
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationLayoutAvoidsOtherAnnotatedTargets [

	| root manager firstAnnotation secondAnnotation |
	root := Morph new bounds: (100 @ 100 extent: 500 @ 260); yourself.
	root openInWorld.
	manager := ReplayUIManager new attachTo: root.
	firstAnnotation := ReplayAnnotation
		annotate: (170 @ 80 extent: 80 @ 40)
		label: 'First target'.
	secondAnnotation := ReplayAnnotation
		annotate: (20 @ 80 extent: 80 @ 40)
		label: 'Second annotation label that wants the right side'.

	[
		manager addOverlay: firstAnnotation.
		manager addOverlay: secondAnnotation.
		self deny: (secondAnnotation label bounds intersects: firstAnnotation targetBoundsInWorld).
		self deny: (firstAnnotation label bounds intersects: secondAnnotation targetBoundsInWorld) ]
		ensure: [
			manager close.
			root delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationLayoutAvoidsSiblingLabelOverlap [

	| root manager firstAnnotation secondAnnotation |
	root := Morph new
		bounds: (100 @ 100 extent: 400 @ 260);
		yourself.
	root openInWorld.
	manager := ReplayUIManager new attachTo: root.
	firstAnnotation := ReplayAnnotation
		annotate: (20 @ 20 extent: 90 @ 40)
		label: 'First annotation label'.
	secondAnnotation := ReplayAnnotation
		annotate: (20 @ 70 extent: 90 @ 40)
		label: 'Second annotation label'.

	[
		manager addOverlay: firstAnnotation.
		manager addOverlay: secondAnnotation.
		self deny: (firstAnnotation label bounds intersects: secondAnnotation label bounds).
		self deny: (firstAnnotation label bounds intersects: firstAnnotation targetBoundsInWorld).
		self deny: (secondAnnotation label bounds intersects: secondAnnotation targetBoundsInWorld) ]
		ensure: [
			manager close.
			root delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachToMorphWithoutOwnerFails [

	| target |
	target := Morph new extent: 100 @ 50.

	self
		should: [ ReplayUIManager new attachTo: target ]
		raise: ReplayError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'without an owner').
			self assert: error subject equals: target ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachToUnrenderedSpecPresenterFails [

	| presenter |
	presenter := ReplaySemanticPresenter new.

	self
		should: [ ReplayUIManager new attachToPresenter: presenter ]
		raise: ReplayError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'without an adapter').
			self assert: error subject equals: presenter ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachUIActionAttachesToScriptMorph [

	| root target runner action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	root addMorph: target.
	runner := ReplayRunner new focus: target.
	action := ReplayAttachUI new.
	action script: 'self focus'.

	action runOn: runner.

	self assert: runner manager notNil.
	self deny: runner manager ownsUI.
	self assert: runner manager managedUI equals: target.
	self assert: runner manager overlay owner equals: root
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachUIActionRejectsUnexpectedScriptResult [

	| runner action |
	runner := ReplayRunner new.
	action := ReplayAttachUI new.
	action script: '42'.

	self
		should: [ action runOn: runner ]
		raise: ReplayScriptError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'existing Morph or Spec presenter').
			self assert: error subject equals: 42 ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachedMorphManagerAllowsUserInteraction [

	| root target manager |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new attachTo: target.

	self deny: manager blocksUserInteraction
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachedMorphManagerDoesNotInstallBlockingOverlayHandlers [

	| root target manager |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new attachTo: target.

	self assert: manager overlay eventHandler isNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachedMorphManagerDoesNotOwnUI [

	| root target manager |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new attachTo: target.

	self deny: manager ownsUI.
	self assert: manager managedUI equals: target.
	self assert: manager overlay owner equals: root.
	self assert: manager overlay bounds equals: target bounds
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachedMorphManagerResolvesRelativeToManagedMorph [

	| root target child manager resolved |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	child := Morph new bounds: (1 @ 1 corner: 20 @ 20).
	target addMorph: child.
	root addMorph: target.
	manager := ReplayUIManager new attachTo: target.

	manager resolver
		resolve: (ReplayUIReference morphicPath: #( 1 ))
		thenDo: [ :element | resolved := element ].

	self assert: resolved morph equals: child
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachedOverlayDoesNotParticipateInOwnerTableLayout [

	| root target manager originalBounds overlay |
	root := Morph new
		extent: 200 @ 100;
		changeTableLayout;
		yourself.
	target := Morph new
		bounds: (0 @ 0 extent: 200 @ 100);
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		yourself.
	root addMorph: target.
	root doLayoutIn: root bounds.
	originalBounds := target bounds.
	manager := ReplayUIManager new attachTo: target.
	overlay := manager overlay.
	root doLayoutIn: root bounds.

	self assert: target bounds equals: originalBounds.
	self assert: overlay bounds equals: originalBounds.
	self assert: overlay disableTableLayout.
	self assert: overlay hResizing equals: #rigid.
	self assert: overlay vResizing equals: #rigid
]

{ #category : 'tests' }
ReplayUIBackendTest >> testClearAnnotationsActionEditionPresenterBuilds [

	| presenter |
	presenter := ReplayEditor new editAction: ReplayClearAnnotations new.

	self assert: presenter notNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testClearAnnotationsActionRemovesOverlayMorphs [

	| manager runner marker |
	manager := ReplayUIManager new manage: (Morph new extent: 100 @ 50).
	runner := ReplayRunner new manager: manager.
	marker := Morph new extent: 10 @ 10.
	manager addOverlay: marker.

	self assert: manager overlay submorphs size equals: 1.
	ReplayClearAnnotations new runOn: runner.
	self assert: manager overlay submorphs isEmpty
]

{ #category : 'tests' }
ReplayUIBackendTest >> testClickActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplayClick new.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Button')
		nativeElement: Object new
		morph: Morph new.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: backend lastInteraction equals: #run.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testClickCanSendMouseDownAndMouseUpWithoutSyntheticClick [

	| action target |
	target := ReplayEventRecorderMorph new.
	action := ReplayClick new
		mousePhase: #downUp;
		yourself.
	action clickOn: target.
	self assert: target eventLabels asArray equals: #(mouseDown mouseUp)
]

{ #category : 'tests' }
ReplayUIBackendTest >> testClickCanSendOnlyMouseDown [

	| action target |
	target := ReplayEventRecorderMorph new.
	action := ReplayClick new
		mousePhase: #down;
		yourself.
	action clickOn: target.
	self assert: target eventLabels asArray equals: #(mouseDown)
]

{ #category : 'tests' }
ReplayUIBackendTest >> testClickCanSendOnlyMouseUp [

	| action target |
	target := ReplayEventRecorderMorph new.
	action := ReplayClick new
		mousePhase: #up;
		yourself.
	action clickOn: target.
	self assert: target eventLabels asArray equals: #(mouseUp)
]

{ #category : 'tests' }
ReplayUIBackendTest >> testClickCanTargetLocalPositionWithModifiers [

	| action target downEvent clickEvent |
	target := ReplayEventRecorderMorph new bounds: (10 @ 20 extent: 100 @ 60).
	action := ReplayClick new
		position: 25 @ 15;
		modifiers: UserInputEvent cmdKeyMask;
		yourself.
	action clickOn: target.
	self assert: target eventLabels asArray equals: #(mouseDown click mouseUp).
	downEvent := target events first value.
	clickEvent := target events second value.
	self assert: downEvent position equals: 35 @ 35.
	self assert: downEvent redButtonPressed.
	self assert: downEvent commandKeyPressed.
	self assert: clickEvent position equals: downEvent position
]

{ #category : 'tests' }
ReplayUIBackendTest >> testClickCountSendsDoubleClick [

	| action target |
	target := ReplayEventRecorderMorph new.
	action := ReplayClick new clickCount: 2; yourself.
	action clickOn: target.
	self assert: target eventLabels asArray equals: #(mouseDown click mouseUp mouseDown click doubleClick mouseUp)
]

{ #category : 'tests' }
ReplayUIBackendTest >> testCloseAttachedMorphManagerRemovesOnlyReplayOverlay [

	| root target manager overlay |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new attachTo: target.
	overlay := manager overlay.

	manager close.

	self assert: overlay owner isNil.
	self assert: target owner equals: root
]

{ #category : 'tests' }
ReplayUIBackendTest >> testCloseUIActionClearsRunnerManager [

	| runner manager |
	runner := ReplayRunner new.
	manager := ReplayUIManager new manage: (Morph new extent: 100 @ 50); yourself.
	runner manager: manager.

	ReplayCloseUI new runOn: runner.

	self assert: runner manager isNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testDeleteTextActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplayDeleteText new direction: #backward; count: 2; yourself.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Field')
		nativeElement: RubEditingArea new
		morph: Morph new.
	action runOn: ReplayRunner new resolvedUI: resolved.
	self assert: backend lastInteraction equals: #run.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testDeleteTextBackendFallsBackToMorph [

	| action morph resolved |
	action := ReplayDeleteText new direction: #forward; count: 1; yourself.
	morph := RubEditingArea new.

	[
		morph setTextWith: 'abc'.
		morph selectFrom: 2 to: 1.
		resolved := ReplayResolvedUIElement
			backend: ReplayUIBackend new
			reference: (ReplayUIReference named: 'Field')
			nativeElement: Object new
			morph: morph.
		action runOn: ReplayRunner new resolvedUI: resolved.
		self assert: morph text asString equals: 'ac' ]

		ensure: [ morph delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testDeleteTextBackendPrefersNativeElement [

	| action native morph resolved |
	action := ReplayDeleteText new direction: #backward; count: 1; yourself.
	native := RubEditingArea new.
	morph := RubEditingArea new.

	[
		native setTextWith: 'abc'.
		native selectFrom: 4 to: 3.
		morph setTextWith: 'xyz'.
		morph selectFrom: 4 to: 3.
		resolved := ReplayResolvedUIElement
			backend: ReplayUIBackend new
			reference: (ReplayUIReference named: 'Field')
			nativeElement: native
			morph: morph.
		action runOn: ReplayRunner new resolvedUI: resolved.
		self assert: native text asString equals: 'ab'.
		self assert: morph text asString equals: 'xyz' ]

		ensure: [
			native delete.
			morph delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testDeleteTextBackwardDeletesPreviousRubricCharacter [

	| action area |
	action := ReplayDeleteText new direction: #backward; count: 1; yourself.
	area := RubEditingArea new.

	[
		area setTextWith: 'abcdef'.
		area selectFrom: 4 to: 3.
		action deleteTextIn: area.
		self assert: area text asString equals: 'abdef' ]

		ensure: [ area delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testDeleteTextCountRepeatsBackwardDeletion [

	| action area |
	action := ReplayDeleteText new direction: #backward; count: 2; yourself.
	area := RubEditingArea new.

	[
		area setTextWith: 'abcdef'.
		area selectFrom: 5 to: 4.
		action deleteTextIn: area.
		self assert: area text asString equals: 'abef' ]

		ensure: [ area delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testDeleteTextDeletesSelectionBeforeCount [

	| action area |
	action := ReplayDeleteText new direction: #backward; count: 1; yourself.
	area := RubEditingArea new.

	[
		area setTextWith: 'abcdef'.
		area selectFrom: 2 to: 4.
		action deleteTextIn: area.
		self assert: area text asString equals: 'aef' ]

		ensure: [ area delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testDeleteTextForwardDeletesNextRubricCharacter [

	| action area |
	action := ReplayDeleteText new direction: #forward; count: 1; yourself.
	area := RubEditingArea new.

	[
		area setTextWith: 'abcdef'.
		area selectFrom: 4 to: 3.
		action deleteTextIn: area.
		self assert: area text asString equals: 'abcef' ]

		ensure: [ area delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testDeleteTextRejectsUnsupportedTarget [

	| action |
	action := ReplayDeleteText new.
	self should: [ action deleteTextIn: Object new ] raise: ReplayError
]

{ #category : 'tests' }
ReplayUIBackendTest >> testDeleteTextSettingsPresenterBuilds [

	| action presenter |
	action := ReplayDeleteText new direction: #forward; count: 2; yourself.
	presenter := ReplayEditor new editAction: action.
	self assert: presenter notNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testDragActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplayDrag new startPosition: 5 @ 5; endPosition: 40 @ 25; steps: 3; yourself.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Slider')
		nativeElement: Object new
		morph: ReplayEventRecorderMorph new.
	action runOn: ReplayRunner new resolvedUI: resolved.
	self assert: backend lastInteraction equals: #run.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testDragSendsDownMoveAndUpEvents [

	| action target downEvent firstMove upEvent |
	target := ReplayEventRecorderMorph new bounds: (10 @ 20 extent: 100 @ 60).
	action := ReplayDrag new
		startPosition: 10 @ 5;
		endPosition: 40 @ 20;
		steps: 2;
		modifiers: UserInputEvent shiftKeyMask;
		yourself.
	action dragOn: target.
	self assert: target eventLabels asArray equals: #(mouseDown mouseMove mouseMove mouseUp).
	downEvent := target events first value.
	firstMove := target events second value.
	upEvent := target events last value.
	self assert: downEvent position equals: 20 @ 25.
	self assert: downEvent redButtonPressed.
	self assert: downEvent shiftPressed.
	self assert: firstMove startPoint equals: 20 @ 25.
	self assert: firstMove endPoint equals: 35 @ 32.5.
	self assert: firstMove redButtonPressed.
	self assert: upEvent position equals: 50 @ 40.
	self deny: upEvent redButtonPressed.
	self assert: upEvent shiftPressed
]

{ #category : 'tests' }
ReplayUIBackendTest >> testFocusActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplayFocus new.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Field')
		nativeElement: Object new
		morph: Morph new.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: backend lastInteraction equals: #run.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testManagedMorphAndOverlayResizeWithRootWindow [

	| manager morph resizedExtent window |
	morph := Morph new extent: 100 @ 50.
	manager := ReplayUIManager new manage: morph.
	resizedExtent := 300 @ 160.

	[
		manager openLabeled: 'Replay resize test'.
		World doOneCycle.
		window := manager managedUI owner owner.
		window extent: resizedExtent.
		World doOneCycle.
		self assert: manager managedUI extent equals: manager overlay extent.
		self assert: manager managedUI extent x > 250.
		self assert: manager managedUI extent y > 120 ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testManagedMorphManagerBlocksUserInteraction [

	| manager |
	manager := ReplayUIManager new manage: (Morph new extent: 100 @ 50).

	self assert: manager blocksUserInteraction
]

{ #category : 'tests' }
ReplayUIBackendTest >> testManagingMorphUsesMorphicBackend [

	| manager morph |
	morph := Morph new.
	manager := ReplayUIManager new manage: morph; yourself.
	self assert: manager backend class equals: ReplayMorphicBackend.
	self assert: manager backend managedUI equals: morph.
	self assert: manager managedUI equals: morph.
	self assert: manager managedPresenter isNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testManagingMorphUsesMorphicResolver [

	| manager morph |
	morph := Morph new.
	manager := ReplayUIManager new manage: morph; yourself.

	self assert: manager resolver class equals: ReplayMorphicResolver.
	self assert: manager surfaceMorph equals: morph
]

{ #category : 'tests' }
ReplayUIBackendTest >> testManagingPresenterUsesSpecBackend [

	| manager presenter |
	presenter := ReplayEditor new.
	manager := ReplayUIManager new managePresenter: presenter; yourself.
	self assert: manager backend class equals: ReplaySpecBackend.
	self assert: manager backend managedPresenter equals: presenter.
	self assert: manager managedPresenter equals: presenter.
	self assert: manager managedUI isMorph
]

{ #category : 'tests' }
ReplayUIBackendTest >> testManagingPresenterUsesSpecResolver [

	| manager presenter |
	presenter := ReplaySemanticPresenter new.
	manager := ReplayUIManager new managePresenter: presenter; yourself.

	self assert: manager resolver class equals: ReplaySpecResolver.
	self assert: manager managedPresenter equals: presenter.
	self assert: manager surfaceMorph isMorph
]

{ #category : 'tests' }
ReplayUIBackendTest >> testMorphicBackendHasNoSemanticScriptReceiverByDefault [

	| backend |
	backend := ReplayMorphicBackend on: Morph new.
	self assert: backend semanticScriptReceiver isNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testMorphicResolverResolvesKeyboardFocusWithinManagedSurface [
	| root target manager hand previousFocus resolved |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (20 @ 10 extent: 50 @ 30).
	root addMorph: target.
	manager := ReplayUIManager new observe: root.
	hand := World activeHand.
	previousFocus := hand keyboardFocus.

	[
		hand keyboardFocus: target.
		manager resolver
			resolve: ReplayUIReference keyboardFocus
			thenDo: [ :element | resolved := element ].
		self assert: resolved morph equals: target ]

		ensure: [
			hand keyboardFocus: previousFocus.
			manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testObserveMorphDoesNotCreateOverlay [
	| root target manager |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 extent: 80 @ 30).
	root addMorph: target.
	manager := ReplayUIManager new observe: target.
	[
		self assert: manager managedUI equals: target.
		self assert: manager overlay isNil.
		self deny: manager ownsUI ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testObserveRootMorphDoesNotRequireOwnerOrOverlay [
	| root manager |
	root := Morph new extent: 200 @ 100.
	manager := ReplayUIManager new observe: root.
	[
		self assert: manager managedUI equals: root.
		self assert: manager overlay isNil.
		self deny: manager ownsUI ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testOpenLabeledAppliesRequestedContentExtent [

	| manager morph requestedExtent |
	morph := Morph new extent: 100 @ 50.
	requestedExtent := 420 @ 180.
	manager := ReplayUIManager new manage: morph.

	[
		manager
			openLabeled: 'Replay requested extent test'
			placement: (ReplayPlacement extent: requestedExtent).
		20 timesRepeat: [ World doOneCycle ].
		self assert: manager ui extent equals: requestedExtent.
		self assert: manager managedUI extent equals: requestedExtent.
		self assert: manager overlay extent equals: requestedExtent ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testOpenLabeledAppliesRequestedWindowBounds [

	| manager morph requestedBounds window |
	morph := Morph new extent: 100 @ 50.
	requestedBounds := 80 @ 90 extent: 480 @ 260.
	manager := ReplayUIManager new manage: morph.

	[
		manager
			openLabeled: 'Replay requested bounds test'
			placement: (ReplayPlacement bounds: requestedBounds).
		20 timesRepeat: [ World doOneCycle ].
		window := manager ui window.
		self assert: window bounds origin equals: requestedBounds origin.
		self assert: window bounds extent equals: requestedBounds extent.
		self assert: manager managedUI extent equals: manager overlay extent ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testOpenLabeledPreservesManagedContentExtent [

	| manager morph targetExtent |
	targetExtent := 321.0 @ 123.0.
	morph := Morph new extent: targetExtent.
	manager := ReplayUIManager new manage: morph.

	[
		manager openLabeled: 'Replay preserved extent test'.
		20 timesRepeat: [ World doOneCycle ].
		self assert: manager ui extent equals: targetExtent.
		self assert: manager managedUI extent equals: targetExtent.
		self assert: manager overlay extent equals: targetExtent.
		self assert: manager ui window extent x >= targetExtent x.
		self assert: manager ui window extent y >= targetExtent y ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testOwnedMorphManagerInstallsBlockingOverlayHandlers [

	| manager |
	manager := ReplayUIManager new manage: (Morph new extent: 100 @ 50).

	self assert: manager ownsUI.
	self assert: manager overlay eventHandler notNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPointerActionSettingsPresentersBuild [

	self assert: (ReplayEditor new editAction: ReplayClick new) notNil.
	self assert: (ReplayEditor new editAction: ReplayScroll new) notNil.
	self assert: (ReplayEditor new editAction: ReplayDrag new) notNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPressKeyActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplayPressKey new.
	action keySelector: #right.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Field')
		nativeElement: Object new
		morph: Morph new.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: backend lastInteraction equals: #run.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPressKeyBuildsKeyboardKeyEvents [
	"Like the OSWindow event handler, the events of a key typing no text carry its control character"

	| action down up |
	action := ReplayPressKey new.
	action
		keySelector: #left;
		modifiers: ReplayKeyModifiers shift.
	down := action chord keyboardEventOfType: #keyDown.
	up := action chord keyboardEventOfType: #keyUp.

	self assert: down isKeyDown.
	self assert: up isKeyUp.
	self assert: down key equals: KeyboardKey left.
	self assert: down keyValue equals: Character arrowLeft asInteger.
	self assert: down keyCharacter equals: Character arrowLeft.
	self assert: up keyValue equals: Character arrowLeft asInteger.
	self assert: down buttons equals: ReplayKeyModifiers shift.
	self assert: up buttons equals: ReplayKeyModifiers shift
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPressKeyChoicesResolveToKeyboardKeys [

	ReplayPressKey keyChoices do: [ :association |
		self assert: ((KeyboardKey perform: association key) isKindOf: KeyboardKey) ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPressKeyMovesRubricCursorWithoutTyping [

	| action area |
	action := ReplayPressKey new
		          keySelector: #left;
		          yourself.
	area := RubEditingArea new.

	[
		area setTextWith: 'a'.
		area selectFrom: 2 to: 1.
		action pressKeyOn: area.
		self assert: area text asString equals: 'a'.
		self assert: area selectionInterval equals: (1 to: 0) ] ensure: [ area delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPressKeySendsDownAndUp [

	| action target |
	target := ReplayEventRecorderMorph new.
	action := ReplayPressKey new.
	action keySelector: #left.
	action pressKeyOn: target.

	self assert: target eventLabels asArray equals: #( keyDown keyUp ).
	self assert: target events first value key equals: KeyboardKey left.
	self assert: target events second value key equals: KeyboardKey left
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPressKeyEditsTextFieldLikeAKeyboard [
	"Each key acts once: Morphic acts on the key down of keys typing no text, and a keystroke for them would insert a control character"

	| field morph area |
	field := SpTextInputFieldPresenter new.
	field text: 'abcd'.
	morph := field build.
	area := morph textArea.
	[
	area selectFrom: 3 to: 2.
	(ReplayPressKey new keySelector: #backspace; yourself) pressKeyOn: area.
	self assert: area text asString equals: 'acd'.
	self assert: area selectionInterval equals: (2 to: 1).
	(ReplayPressKey new keySelector: #space; yourself) pressKeyOn: area.
	self assert: area text asString equals: 'a cd'.
	(ReplayPressKey new keySelector: #right; repeatCount: 2; yourself) pressKeyOn: area.
	self assert: area text asString equals: 'a cd'.
	self assert: area selectionInterval equals: (5 to: 4) ] ensure: [ morph delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPressKeyEnterSubmitsTextFieldWithoutTyping [

	| field submitted morph |
	submitted := nil.
	field := SpTextInputFieldPresenter new.
	field
		text: 'abcd';
		whenSubmitDo: [ :text | submitted := text ].
	morph := field build.
	[
	(ReplayPressKey new keySelector: #enter; yourself) pressKeyOn: morph textArea.
	self assert: submitted equals: 'abcd'.
	self assert: morph textArea text asString equals: 'abcd' ] ensure: [ morph delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPressKeySendsKeystrokeOnlyForKeysTypingText [

	| target |
	target := ReplayEventRecorderMorph new.
	(ReplayPressKey new keySelector: #space; yourself) pressKeyOn: target.
	self assert: target eventLabels asArray equals: #( keyDown keystroke keyUp ).
	self assert: target events second value keyCharacter equals: Character space.

	target := ReplayEventRecorderMorph new.
	(ReplayPressKey new keySelector: #space; modifiers: ReplayKeyModifiers control; yourself) pressKeyOn: target.
	self assert: target eventLabels asArray equals: #( keyDown keyUp ).

	#( #enter #tab #backspace #escape #delete ) do: [ :selector |
		target := ReplayEventRecorderMorph new.
		(ReplayPressKey new keySelector: selector; yourself) pressKeyOn: target.
		self assert: target eventLabels asArray equals: #( keyDown keyUp ) ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPressKeyTabInsertsOneTabInTextArea [

	| area |
	area := RubEditingArea new.
	[
	area setTextWith: 'ab'.
	area selectFrom: 2 to: 1.
	(ReplayPressKey new keySelector: #tab; yourself) pressKeyOn: area.
	self assert: area text asString equals: (String with: $a with: Character tab with: $b) ] ensure: [ area delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPressKeySettingsPresenterBuilds [

	| action presenter |
	action := ReplayPressKey new.
	action
		keySelector: #left;
		repeatCount: 3;
		modifiers: ReplayKeyModifiers shift.
	presenter := ReplayEditor new editAction: action.

	self assert: presenter notNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testClickRequiresMorphWhenItCannotClickNatively [

	| resolved |
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: Object new
		morph: nil.

	self
		should: [ ReplayClick new runOn: ReplayRunner new resolvedUI: resolved ]
		raise: ReplayMissingUIError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'Click').
			self assert: error subject equals: resolved ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testFocusFallsBackToMorph [

	| morph resolved |
	morph := ReplayEventRecorderMorph new.
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: nil
		morph: morph.

	ReplayFocus new runOn: ReplayRunner new resolvedUI: resolved.

	self assert: morph eventLabels asArray equals: #( takeKeyboardFocus )
]

{ #category : 'tests' }
ReplayUIBackendTest >> testFocusPrefersNativeElement [

	| native morph resolved |
	native := ReplayEventRecorderMorph new.
	morph := ReplayEventRecorderMorph new.
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: native
		morph: morph.

	ReplayFocus new runOn: ReplayRunner new resolvedUI: resolved.

	self assert: native eventLabels asArray equals: #( takeKeyboardFocus ).
	self assert: morph eventLabels isEmpty
]

{ #category : 'tests' }
ReplayUIBackendTest >> testTypeRunsOnMorphRatherThanNativeElement [

	| native morph resolved |
	native := ReplayEventRecorderMorph new.
	morph := ReplayEventRecorderMorph new.
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: native
		morph: morph.

	(ReplayType new text: 'a') runOn: ReplayRunner new resolvedUI: resolved.

	self assert: morph eventLabels asArray equals: #( keystroke ).
	self assert: native eventLabels isEmpty
]

{ #category : 'tests' }
ReplayUIBackendTest >> testScrollActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplayScroll new direction: #down; count: 3; yourself.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'List')
		nativeElement: Object new
		morph: ReplayEventRecorderMorph new.
	action runOn: ReplayRunner new resolvedUI: resolved.
	self assert: backend lastInteraction equals: #run.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testScrollSendsWheelEventsAtLocalPositionWithModifiers [

	| action target firstEvent |
	target := ReplayEventRecorderMorph new bounds: (10 @ 20 extent: 100 @ 60).
	action := ReplayScroll new
		direction: #up;
		count: 2;
		position: 30 @ 10;
		modifiers: UserInputEvent altKeyMask;
		yourself.
	action scrollOn: target.
	self assert: target eventLabels asArray equals: #(mouseWheel mouseWheel).
	firstEvent := target events first value.
	self assert: firstEvent position equals: 40 @ 30.
	self assert: firstEvent isUp.
	self assert: firstEvent altKeyPressed
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSelectTextActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplaySelectText new.
	action
		startIndex: 2;
		stopIndex: 5.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Field')
		nativeElement: ReplaySelectableTarget new
		morph: Morph new.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: backend lastInteraction equals: #run.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSelectTextBackendFallsBackToMorph [

	| action morph resolved |
	action := ReplaySelectText new
		startIndex: 3;
		stopIndex: 4;
		yourself.
	morph := ReplaySelectableTarget new.
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: Object new
		morph: morph.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: morph selectionInterval equals: (3 to: 4)
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSelectTextBackendPrefersNativeElement [

	| action native morph resolved |
	action := ReplaySelectText new
		startIndex: 2;
		stopIndex: 5;
		yourself.
	native := ReplaySelectableTarget new.
	morph := ReplaySelectableTarget new.
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: native
		morph: morph.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: native selectionInterval equals: (2 to: 5).
	self assert: morph selectionInterval isNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSelectTextNormalizesStopBeforeStart [

	| action |
	action := ReplaySelectText new
		startIndex: 4;
		stopIndex: 2;
		yourself.
	self assert: action selectionInterval equals: (4 to: 4)
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSelectTextRejectsUnsupportedTarget [

	| action |
	action := ReplaySelectText new.
	self
		should: [ action selectTextIn: Object new ]
		raise: ReplayError
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSelectTextSupportsRubricEditingArea [

	| action area |
	action := ReplaySelectText new
		startIndex: 2;
		stopIndex: 4;
		yourself.
	area := RubEditingArea new.
	[
		area setTextWith: 'abcdef'.
		action selectTextIn: area.
		self assert: area selectionInterval equals: (2 to: 4) ]
		ensure: [ area delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSelectTextThenTypeReplacesRubricSelection [

	| area selectAction typeAction |
	area := RubEditingArea new.
	selectAction := ReplaySelectText new
		startIndex: 2;
		stopIndex: 4;
		yourself.
	typeAction := ReplayType new text: 'X'.
	[
		area setTextWith: 'abcdef'.
		selectAction selectTextIn: area.
		typeAction typeOn: area.
		self assert: area text asString equals: 'aXef' ]
		ensure: [ area delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testShortcutActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplayShortcut keyBinding: (ReplayKeyBinding character: $s modifiers: 0).
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Shortcut target')
		nativeElement: Object new
		morph: Morph new.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: backend lastInteraction equals: #run.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testShortcutIgnoresUnknownKeys [

	| action target |
	target := ReplayEventRecorderMorph new.
	action := ReplayShortcut keyBinding:
		          (ReplayKeyBinding chords: { ReplayKeyChord key: #NOT_A_KEY modifiers: ReplayKeyModifiers command }).
	self shouldnt: [ action shortcutOn: target ] raise: Error.
	self assert: target eventLabels isEmpty
]

{ #category : 'tests' }
ReplayUIBackendTest >> testShortcutSendsAKeyDownPerChordWithItsModifiers [

	| action target |
	target := ReplayEventRecorderMorph new.
	action := ReplayShortcut keyBinding: (ReplayKeyBinding fromKMCombination: $t meta , $s).
	action shortcutOn: target.

	self assert: target eventLabels asArray equals: #( keyDown keyDown ).
	self assert: target events first value key equals: (KeyboardKey named: #T).
	self assert: target events first value buttons equals: ReplayKeyModifiers command.
	self assert: target events first value keyCharacter equals: $t.
	self assert: target events second value key equals: (KeyboardKey named: #S).
	self assert: target events second value buttons equals: 0
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecBackendKeepsNonLeftButtonClickOnMorphicFallback [

	| clicked button backend action resolved |
	clicked := false.
	button := SpButtonPresenter new.
	button action: [ clicked := true ].
	backend := ReplaySpecBackend presenter: button morph: nil.
	action := ReplayClick new.
	action buttons: MouseEvent yellowButton.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Button')
		nativeElement: button
		morph: nil.

	self
		should: [ backend run: action on: resolved ]
		raise: ReplayMissingUIError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'Click') ].
	self deny: clicked
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecBackendResolvesNamedPresenterSemantically [

	| presenter manager action runner |
	presenter := ReplaySemanticPresenter new.
	manager := ReplayUIManager new managePresenter: presenter.
	runner := ReplayRunner new manager: manager.
	action := ReplayFocus new targetNamed: 'Field'.

	[
		manager openLabeled: 'Replay semantic resolver test'.
		self shouldnt: [ action runOn: runner ] raise: Error ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecBackendRunsNativeButtonClick [

	| clicked button backend action resolved |
	clicked := false.
	button := SpButtonPresenter new.
	button action: [ clicked := true ].
	backend := ReplaySpecBackend presenter: button morph: nil.
	action := ReplayClick new.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Button')
		nativeElement: button
		morph: nil.

	backend run: action on: resolved.

	self assert: clicked
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecBackendUsesPresenterAsSemanticScriptReceiver [

	| presenter backend |
	presenter := ReplayEditor new.
	backend := ReplaySpecBackend presenter: presenter morph: Morph new.
	self assert: backend semanticScriptReceiver equals: presenter
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecResolverDoesNotResolveNonNativeClickBeforeMorphExists [

	| presenter backend action resolver capturedError |
	presenter := ReplayButtonSemanticPresenter new.
	backend := ReplaySpecBackend presenter: presenter morph: nil.
	action := ReplayClick new.
	action buttons: MouseEvent yellowButton.
	resolver := ReplaySpecResolver on: backend.
	resolver timeout: Duration zero.

	resolver
		resolve: (ReplayUIReference named: 'Button')
		forAction: action
		thenDo: [ :element | self fail: 'Unexpected native-only resolution' ]
		onMissing: [ :error | capturedError := error ].

	self assert: capturedError class equals: ReplayMissingUIError.
	self deny: presenter clicked
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecResolverKeepsSemanticPresenterAsNativeElement [

	| presenter manager resolved |
	presenter := ReplaySemanticPresenter new.
	manager := ReplayUIManager new managePresenter: presenter.

	manager resolver
		resolve: (ReplayUIReference named: 'Field')
		thenDo: [ :element | resolved := element ].

	self assert: resolved nativeElement equals: presenter field.
	self assert: resolved morph isMorph
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecResolverRetriesMissingSemanticNameUntilTimeout [

	| presenter manager resolver capturedError |
	presenter := ReplaySemanticPresenter new.
	manager := ReplayUIManager new managePresenter: presenter.
	resolver := manager resolver timeout: 100 milliSeconds.

	resolver
		resolve: (ReplayUIReference named: 'Missing')
		thenDo: [ :element | self fail ]
		onMissing: [ :error | capturedError := error ].

	self assert: capturedError isNil.
	self waitUntil: [ capturedError notNil ].
	self assert: capturedError class equals: ReplayMissingUIError.
	self assert: (capturedError messageText includesSubstring: 'No Spec presenter named ''Missing''').
	self assert: (capturedError messageText includesSubstring: 'Gave up after 100 ms')
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecResolverResolvesNativeButtonClickBeforeMorphExists [

	| presenter backend action resolved |
	presenter := ReplayButtonSemanticPresenter new.
	backend := ReplaySpecBackend presenter: presenter morph: nil.
	action := ReplayClick new.

	backend
		resolve: (ReplayUIReference named: 'Button')
		forAction: action
		thenDo: [ :element | resolved := element ]
		onMissing: [ :error | error signal ].

	self assert: resolved notNil.
	self assert: resolved nativeElement equals: presenter button.
	self deny: resolved hasMorph.
	action runOn: ReplayRunner new resolvedUI: resolved.
	self assert: presenter clicked
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecResolverResolvesNativeFocusBeforeMorphExists [

	| presenter backend action resolved |
	presenter := ReplaySemanticPresenter new.
	backend := ReplaySpecBackend presenter: presenter morph: nil.
	action := ReplayFocus new.

	backend
		resolve: (ReplayUIReference named: 'Field')
		forAction: action
		thenDo: [ :element | resolved := element ]
		onMissing: [ :error | error signal ].

	self assert: resolved notNil.
	self assert: resolved nativeElement equals: presenter field.
	self deny: resolved hasMorph
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecResolverResolvesNativeSelectTextBeforeMorphExists [

	| presenter backend action resolved |
	presenter := ReplaySemanticPresenter new.
	backend := ReplaySpecBackend presenter: presenter morph: nil.
	action := ReplaySelectText new
		startIndex: 1;
		stopIndex: 4;
		yourself.

	backend
		resolve: (ReplayUIReference named: 'Field')
		forAction: action
		thenDo: [ :element | resolved := element ]
		onMissing: [ :error | error signal ].

	self assert: resolved notNil.
	self assert: resolved nativeElement equals: presenter field.
	self deny: resolved hasMorph.
	action runOn: ReplayRunner new resolvedUI: resolved.
	self assert: presenter field selectionInterval equals: (1 to: 4)
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecificTargetUIActionWithoutManagerRaisesMissingUI [

	| action |
	action := ReplayFocus new.
	action targetNamed: 'Field'.
	self
		should: [ action runOn: ReplayRunner new ]
		raise: ReplayMissingUIError
]

{ #category : 'tests' }
ReplayUIBackendTest >> testTypeActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplayType new.
	action text: 'abc'.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Field')
		nativeElement: Object new
		morph: Morph new.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: backend lastInteraction equals: #run.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testTypeActionRequiresKeyboardTargetFromResolvedUI [

	| action resolved |
	action := ReplayType new.
	action text: 'a'.
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: Object new
		morph: nil.

	self
		should: [ action runOn: ReplayRunner new resolvedUI: resolved ]
		raise: ReplayMissingUIError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'Type') ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testUIHandlerClearingSemanticNameReturnsToWorldTarget [

	| action |
	action := ReplayFocus new.
	action targetNamed: 'Field'.
	action targetName: '   '.

	self assert: action target isWorld.
	self deny: action hasSpecificTarget
]

{ #category : 'tests' }
ReplayUIBackendTest >> testUIHandlerKeepsOneTarget [

	| action |
	action := ReplayFocus new.
	action targetNamed: 'Field'.
	action target: (ReplayUIReference morphicPath: #( 1 2 )).

	self assert: action target equals: (ReplayUIReference morphicPath: #( 1 2 )).
	self assert: action targetName equals: ''.
	self assert: action hasSpecificTarget.
	action target: ReplayUIReference world.
	self deny: action hasSpecificTarget
]

{ #category : 'tests' }
ReplayUIBackendTest >> testUIHandlerTargetNamedCreatesSemanticReference [

	| action |
	action := ReplayFocus new.
	action targetNamed: 'Field'.

	self assert: action target isNamed.
	self assert: action target value equals: 'Field'.
	self assert: action targetName equals: 'Field'.
	self assert: action hasSpecificTarget
]

{ #category : 'tests' }
ReplayUIBackendTest >> testUIHandlerTargetPresenterBuildsForSemanticTarget [

	| action presenter |
	action := ReplayFocus new.
	action targetNamed: 'Field'.
	presenter := ReplayEditor new editAction: action.

	self assert: presenter notNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testUIResolverTimeout [

	| resolver |
	resolver := ReplaySpecResolver on: (ReplaySpecBackend presenter: ReplayEditor new morph: Morph new).
	self assert: resolver timeout equals: ReplayUIResolver defaultTimeout.
	resolver timeout: 50 milliSeconds.
	self assert: resolver timeout equals: 50 milliSeconds
]

{ #category : 'tests' }
ReplayUIBackendTest >> testUIResolverSchedulesRetryThroughBackend [

	| backend resolver ran |
	backend := ReplayRecordingBackend new.
	resolver := ReplayUIResolver on: backend.
	ran := false.

	resolver schedule: [ ran := true ].

	self deny: ran.
	self assert: backend deferredBlockCount equals: 1.
	backend runDeferredBlocks.
	self assert: ran
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotateWithoutTargetRaisesMissingUI [

	self
		should: [ (ReplayAnnotate new text: 'Nowhere') runOn: ReplayRunner new ]
		raise: ReplayMissingUIError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'Annotate needs a target') ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testClickPhasesReachTheOwnerHandlingMouseDown [
	"A split click sends its mouse up to the morph that got the mouse down"

	| handler leaf |
	handler := ReplayEventRecorderMorph new.
	leaf := Morph new bounds: (10 @ 10 extent: 20 @ 20).
	handler addMorph: leaf.

	(ReplayClick new mousePhase: #down; yourself) clickOn: leaf.
	(ReplayClick new mousePhase: #up; yourself) clickOn: leaf.

	self assert: handler eventLabels asArray equals: #( mouseDown mouseUp )
]

{ #category : 'tests' }
ReplayUIBackendTest >> testDebugClickResolvesNamedTargetThroughManager [

	| presenter manager click |
	presenter := ReplayButtonSemanticPresenter new.
	manager := ReplayUIManager new managePresenter: presenter.
	click := ReplayDebugClickSpy new.
	click targetNamed: 'Button'.

	click debugClickIn: manager.

	self assert: click debuggedBlock notNil.
	self deny: presenter clicked.
	click debuggedBlock value.
	self assert: presenter clicked
]

{ #category : 'tests' }
ReplayUIBackendTest >> testLabeledAnnotationShowsItsLabelOnceInWorld [

	| root target manager annotation |
	root := Morph new bounds: (100 @ 100 extent: 300 @ 200).
	target := Morph new bounds: (110 @ 110 extent: 80 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new attachTo: target.
	annotation := ReplayAnnotation annotate: target bounds label: 'Shown later'.
	manager addOverlay: annotation.
	self deny: annotation label isInWorld.

	[
		root openInWorld.
		self assert: annotation label isInWorld.
		self assert: annotation line isInWorld ] ensure: [
			manager close.
			root delete ].
	self deny: annotation label isInWorld
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecBackendRunsTextActionsOnTextPresenters [

	{ SpTextInputFieldPresenter. SpTextPresenter } do: [ :presenterClass |
		| presenter morph backend resolved |
		presenter := presenterClass new.
		presenter text: 'abcdef'.
		morph := presenter build.
		backend := ReplaySpecBackend presenter: presenter morph: morph.
		resolved := ReplayResolvedUIElement
			backend: backend
			reference: (ReplayUIReference named: 'Text')
			nativeElement: presenter
			morph: morph.
		[
			(ReplaySelectText new startIndex: 2; stopIndex: 4; yourself) runOn: ReplayRunner new resolvedUI: resolved.
			self assert: morph textArea selectionInterval equals: (2 to: 4).
			(ReplayDeleteText new direction: #backward; yourself) runOn: ReplayRunner new resolvedUI: resolved.
			self assert: presenter text asString equals: 'aef'.
			(ReplayType new text: 'X') runOn: ReplayRunner new resolvedUI: resolved.
			self assert: presenter text asString equals: 'aXef' ] ensure: [ morph delete ] ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecNativeClickSkipsDisabledButton [

	| clicked button morph resolved |
	clicked := false.
	button := SpButtonPresenter new.
	button
		action: [ clicked := true ];
		disable.
	self deny: (ReplayClick new canRunNativelyOn: button).

	morph := button build.
	resolved := ReplayResolvedUIElement
		backend: (ReplaySpecBackend presenter: button morph: morph)
		reference: (ReplayUIReference named: 'Button')
		nativeElement: button
		morph: morph.
	[ ReplayClick new runOn: ReplayRunner new resolvedUI: resolved ] ensure: [ morph delete ].

	self deny: clicked
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecNativeClickSkipsHiddenButton [

	| button |
	button := SpButtonPresenter new.
	button hide.

	self deny: (ReplayClick new canRunNativelyOn: button)
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecNativeClickOnToolbarButtonsActsLikeTheirWidgets [

	| button toggle received |
	button := SpToolbarButtonPresenter new.
	button action: [ :presenter | received := presenter ].
	ReplayClick new runNativelyOn: button.
	self assert: received identicalTo: button.

	toggle := SpToolbarToggleButtonPresenter new.
	toggle action: [ :presenter | received := presenter ].
	received := nil.
	self deny: toggle isSelected.
	ReplayClick new runNativelyOn: toggle.
	self assert: toggle isSelected.
	self assert: received identicalTo: toggle.
	ReplayClick new runNativelyOn: toggle.
	self deny: toggle isSelected
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecResolverTimesOutOnNamedPresenterThatNeverRenders [

	| presenter resolver capturedError |
	presenter := ReplayButtonSemanticPresenter new.
	resolver := (ReplaySpecResolver on: (ReplaySpecBackend presenter: presenter morph: nil))
		timeout: 100 milliSeconds;
		yourself.

	resolver
		resolve: (ReplayUIReference named: 'Button')
		forAction: (ReplayClick new buttons: MouseEvent yellowButton; yourself)
		thenDo: [ :element | self fail: 'Unexpected resolution without widget' ]
		onMissing: [ :error | capturedError := error ].

	self waitUntil: [ capturedError notNil ].
	self assert: (capturedError messageText includesSubstring: 'was found, but it has no rendered widget').
	self assert: (capturedError messageText includesSubstring: 'Gave up after 100 ms')
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecResolverWaitsForTheWidgetOfANamedPresenter [

	| presenter resolved morph |
	presenter := ReplayButtonSemanticPresenter new.

	(ReplaySpecResolver on: (ReplaySpecBackend presenter: presenter morph: nil))
		resolve: (ReplayUIReference named: 'Button')
		forAction: (ReplayClick new buttons: MouseEvent yellowButton; yourself)
		thenDo: [ :element | resolved := element ]
		onMissing: [ :error | self fail: error messageText ].

	self assert: resolved isNil.
	morph := presenter build.
	[
		self waitUntil: [ resolved notNil ].
		self assert: resolved nativeElement identicalTo: presenter button.
		self assert: resolved morph identicalTo: presenter button adapter widget ] ensure: [ morph delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testUIReferencesAreValues [

	self assert: (ReplayUIReference named: 'Field') equals: (ReplayUIReference named: 'Field').
	self assert: (ReplayUIReference named: 'Field') hash equals: (ReplayUIReference named: 'Field') hash.
	self assert: (ReplayUIReference morphicPath: #( 1 2 )) equals: (ReplayUIReference morphicPath: #( 1 2 )).
	self deny: (ReplayUIReference named: 'Field') equals: (ReplayUIReference named: 'Other').
	self deny: (ReplayUIReference morphicPath: #( 1 )) equals: (ReplayUIReference named: #( 1 )).
	self assert: ReplayUIReference world equals: ReplayUIReference world
]

{ #category : 'tests' }
ReplayUIBackendTest >> testBuildingAMorphFromSpecSendsNoDeprecatedMessage [
	"A deprecated send is rewritten in place or logged with its receiver, which kept every built window alive."

	| deprecations |
	(Deprecation class canUnderstand: #deprecationsWhile:) ifFalse: [ ^ self skip ].
	deprecations := Deprecation deprecationsWhile: [
		ReplaySpecBackend buildMorphFromSpec: (SpLabelPresenter new label: 'Replay'; yourself) ].
	self assert: deprecations isEmpty
]
