"
I build a managed UI preview up to a selected step or action for editor tooling and action debugging.

I search backwards from the target action for the last action opening a UI, ask it for a preview manager, then replay the following actions up to the target with `previewOn:` instead of `runOn:`, so actions with effects outside the preview are skipped. Navigation between steps is skipped too. Once the target is reached, I stop without closing the preview and evaluate my callback.
"
Class {
	#name : 'ReplayUIBuilder',
	#superclass : 'ReplayRunner',
	#instVars : [
		'endStepIndex',
		'endActionIndex',
		'callback'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'managing UI' }
ReplayUIBuilder >> buildUI [
	"Open the preview UI of the opener under the cursor, then asynchronously replay the actions up to the target."

	self manager: (self currentAction previewManagerOn: self).
	self defer: [ self nextAction ].
	^ self manager ui
]

{ #category : 'running' }
ReplayUIBuilder >> finish [
	"Stop replaying, keeping the preview UI, and notify."

	stepIndex := nil.
	actionIndex := nil.
	callback ifNotNil: [ callback value ]
]

{ #category : 'running' }
ReplayUIBuilder >> runAction: action [

	(stepIndex = endStepIndex and: [ actionIndex = endActionIndex ])
		ifTrue: [ "Reached target action" ^ self finish ].
	action previewOn: self
]

{ #category : 'managing UI' }
ReplayUIBuilder >> uiForAction: targetAction inStep: step [
	"Build the UI with the state before the given action by traversing the previous relevant actions."

	| actions action |
	stepIndex := scenario steps indexOf: step.
	stepIndex = 0 ifTrue: [
		ReplayError new
			messageText: 'Cannot preview a step that is not in the scenario.';
			subject: step;
			signal ].
	actions := step actions.
	actionIndex := actions indexOf: targetAction.
	actionIndex = 0 ifTrue: [
		ReplayError new
			messageText: 'Cannot preview an action that is not in the step.';
			subject: targetAction;
			signal ].
	self untilStep: stepIndex upToAction: actionIndex.

	"Search backwards through current and prior steps"
	[ stepIndex > 0 ] whileTrue: [
		[ (actionIndex := actionIndex - 1) > 0 ] whileTrue: [
			action := actions at: actionIndex.
			action isUIOpener ifTrue: [ ^ self buildUI ].
			action isUICloser ifTrue: [
				ReplayMissingUIError signal: 'UI is closed at this point.' ] ].

		stepIndex := stepIndex - 1.
		stepIndex > 0 ifTrue: [
			actions := self currentStep actions.
			actionIndex := actions size + 1 ] ].

	ReplayMissingUIError signal: 'No UI context found for this action.'
]

{ #category : 'accessing' }
ReplayUIBuilder >> untilStep: untilStepIndex upToAction: upToActionIndex [

	endStepIndex := untilStepIndex.
	endActionIndex := upToActionIndex
]

{ #category : 'callbacks' }
ReplayUIBuilder >> whenDone: aBlock [
	"A no-args block that will be executed when the UI has finished building"

	callback := aBlock
]
