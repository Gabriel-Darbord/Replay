"
I build a managed UI preview up to a selected step or action for editor tooling and action debugging.
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
	"Asynchronously rebuild UI, executing the callback when done."

	self manager: ((self currentStep actions at: actionIndex) uiManagerOn: self).
	self defer: [ self nextAction ].
	^ self manager ui
]

{ #category : 'running' }
ReplayUIBuilder >> nextAction [

	actionIndex := actionIndex + 1.
	(stepIndex = endStepIndex and: [ actionIndex = endActionIndex ])
		ifTrue: [ "Reached target action" ^ callback value ].

	actionIndex > self currentStep actions size ifTrue: [ "skip navigation"
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
