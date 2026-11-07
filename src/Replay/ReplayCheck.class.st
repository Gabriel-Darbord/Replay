"
I check a condition on the UI, which makes a scenario a test, or makes it wait for the UI to be ready.

My script is the condition: it answers true or false, with my target as self (its Spec presenter, or its widget when it has none, or the World without a target). I wait until it answers true, for my timeout in seconds, and then let the scenario go on. If it is still false then, the run fails with a ReplayMissingUIError that tells my condition. A condition that fails or answers something else than a Boolean fails the run at once.

Editor previews skip me, so a condition is only evaluated when the scenario runs.
"
Class {
	#name : 'ReplayCheck',
	#superclass : 'ReplayUIHandler',
	#traits : 'TReplayActionWithScript',
	#classTraits : 'TReplayActionWithScript classTrait',
	#instVars : [
		'timeout'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayCheck class >> defaultTimeout [
	"In seconds"

	^ 3
]

{ #category : 'accessing' }
ReplayCheck class >> displayName [

	^ 'Check'
]

{ #category : 'editing' }
ReplayCheck class >> editorClass [

	^ ReplayCheckEditor
]

{ #category : 'running' }
ReplayCheck >> ensureReadyOn: aResolvedUIElement [
	"Wait until my condition holds on my target"

	| result |
	result := self evaluateScriptOn:
		          (aResolvedUIElement nativeElement ifNil: [ aResolvedUIElement morph ]).
	result == true ifTrue: [ ^ self ].
	result == false ifFalse: [
		^ self unexpectedScriptResult: result expected: 'true or false' ].
	ReplayMissingUIError new
		messageText: 'The check is still false: ' , (self script printStringLimitedTo: 200)
			, (self hasSpecificTarget
					 ifTrue: [ ', on ' , self target description , '.' ]
					 ifFalse: [ '.' ]);
		subject: aResolvedUIElement;
		signal
]

{ #category : 'running' }
ReplayCheck >> previewOn: aReplayUIBuilder [
	"Previews do not evaluate my condition, nor wait for it."

	aReplayUIBuilder nextAction
]

{ #category : 'running' }
ReplayCheck >> resolutionTimeout [

	^ self timeout seconds
]

{ #category : 'running' }
ReplayCheck >> runOn: runner resolvedUI: aResolvedUIElement [
	"My condition held when my target was ready: nothing left to do"
]

{ #category : 'running' }
ReplayCheck >> runOnMorph: aMorph [
	"Not sent: see runOn:resolvedUI:"
]

{ #category : 'evaluating' }
ReplayCheck >> scriptReceiverOn: anObject [
	"My condition is evaluated with anObject as self: the target when I run (see ensureReadyOn:)"

	^ anObject
]

{ #category : 'accessing' }
ReplayCheck >> timeout [
	"How long to wait for my condition to hold, in seconds"

	^ timeout ifNil: [ self class defaultTimeout ]
]

{ #category : 'accessing' }
ReplayCheck >> timeout: aNumber [

	timeout := aNumber = self class defaultTimeout ifFalse: [ aNumber ]
]
