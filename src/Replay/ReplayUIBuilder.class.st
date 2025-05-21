"
Used by the `TutorialEditor` to build the managed UI for a specific action.
**Not** used for running tutorials.
"
Class {
	#name : 'ReplayUIBuilder',
	#superclass : 'ReplayRunner',
	#instVars : [
		'endStepIndex',
		'endActionIndex',
		'callback'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'managing UI' }
ReplayUIBuilder >> buildUI [
	"Asynchronously rebuild the UI, executing the callback when done"

	self manager:
		((scenario steps at: stepIndex) actions at: actionIndex) managerOnUI.

	self currentWorld defer: [ self nextAction ].

	^ self manager ui
]

{ #category : 'running' }
ReplayUIBuilder >> nextAction [

	| step |
	actionIndex := actionIndex + 1.
	(stepIndex = endStepIndex and: [ actionIndex = endActionIndex ])
		ifTrue: [ "Reached target action" ^ callback value ].

	step := scenario steps at: stepIndex.
	actionIndex > step actions size ifTrue: [ "skip navigation"
		^ self nextStep ].

	self runAction
]

{ #category : 'managing UI' }
ReplayUIBuilder >> uiForAction: targetAction inStep: step [
	"Build the UI with the state before the given action by traversing the previous relevant actions."

	| actions action |
	stepIndex := scenario steps indexOf: step.
	actions := step actions.
	actionIndex := actions indexOf: targetAction.
	self untilStep: stepIndex upToAction: actionIndex.

	"Search backwards through current and prior steps"
	[ stepIndex > 0 ] whileTrue: [
		[ (actionIndex := actionIndex - 1) > 0 ] whileTrue: [
			action := actions at: actionIndex.
			action isUIOpener ifTrue: [ ^ self buildUI ].
			action isUICloser ifTrue: [
				ReplayMissingUIError signal: 'UI is closed at this point' ] ].

		stepIndex := stepIndex - 1.
		stepIndex > 0 ifTrue: [
			actions := (scenario steps at: stepIndex) actions.
			actionIndex := actions size + 1 ] ].

	ReplayMissingUIError signal:
		'No UI context could be found for this action'
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
