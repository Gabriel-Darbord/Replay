"
I attach Replay to an existing Morphic morph or already-rendered Spec presenter, answered by my script evaluated with the runner as self. Unlike open actions, I do not take ownership of the target UI: I only add an overlay on it, removed when the runner stops.
"
Class {
	#name : 'ReplayAttachUI',
	#superclass : 'ReplayAttach',
	#traits : 'TReplayActionWithScript',
	#classTraits : 'TReplayActionWithScript classTrait',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayAttachUI class >> displayName [

	^ 'Attach UI'
]

{ #category : 'editing' }
ReplayAttachUI >> editionPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: (self
						scriptPresenterOn: editor
						labeled: 'Write script returning an existing Morph or rendered Spec presenter:');
				add: (self
						debugButtonPresenterOn: editor
						labeled: 'Debug script'
						action: [ self debugScriptInEditor: editor ])
				expand: false;
				yourself);
		yourself
]

{ #category : 'managing UI' }
ReplayAttachUI >> uiManagerOn: runner [

	| target manager |
	target := self uiTargetOn: runner.
	manager := ReplayUIManager new.
	(target isKindOf: Morph) ifTrue: [ ^ manager attachTo: target ].
	^ manager attachToPresenter: target
]

{ #category : 'managing UI' }
ReplayAttachUI >> uiTargetOn: runner [
	"Evaluate script to obtain an existing Morph or rendered Spec presenter."

	| target |
	target := self evaluateScriptOn: runner.
	((target isKindOf: Morph) or: [ target isKindOf: SpAbstractPresenter ]) ifFalse: [
		self unexpectedScriptResult: target expected: 'an existing Morph or Spec presenter' ].
	^ target
]
