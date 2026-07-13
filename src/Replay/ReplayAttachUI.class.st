"
I attach Replay to an existing Morphic morph or already-rendered Spec presenter. Unlike open actions, I do not take ownership of the target UI.
"
Class {
	#name : 'ReplayAttachUI',
	#superclass : 'ReplayOpenUI',
	#traits : 'TReplayActionWithScript',
	#classTraits : 'TReplayActionWithScript classTrait',
	#instVars : [
		'script'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayAttachUI class >> displayName [

	^ 'Attach UI'
]

{ #category : 'printing' }
ReplayAttachUI >> printOn: stream [

	super printOn: stream.
	script isEmptyOrNil ifTrue: [ ^ self ].
	stream << ': '.
	stream nextPutAll: (script printStringLimitedTo: 100)
]

{ #category : 'running' }
ReplayAttachUI >> runOn: runner [

	runner manager: (self uiManagerOn: runner)
]

{ #category : 'editing' }
ReplayAttachUI >> settingsPresenterOn: editor [

	^ editor newPresenter
		layout: (self scriptPresenterOn: editor labeled: 'Write script returning an existing Morph or rendered Spec presenter:');
		yourself
]

{ #category : 'accessing' }
ReplayAttachUI >> settingsViewName [

	^ 'Attach UI settings'
]

{ #category : 'editing' }
ReplayAttachUI >> uiEditionPresenterOn: editor [

	^ self noEditionPresenterOn: editor
]

{ #category : 'running' }
ReplayAttachUI >> uiManagerOn: runner [

	| target manager |
	target := self uiTargetOn: runner.
	manager := ReplayUIManager new.
	(target isKindOf: Morph)
		ifTrue: [ manager attachTo: target ]
		ifFalse: [ manager attachToPresenter: target ].
	^ manager
]

{ #category : 'managing UI' }
ReplayAttachUI >> uiTargetOn: runner [
	"Evaluate script to obtain an existing Morph or rendered Spec presenter."

	| target |
	target := Smalltalk compiler
		receiver: runner;
		isScripting: true;
		evaluate: self script.
	((target isKindOf: Morph) or: [ target isKindOf: SpAbstractPresenter ]) ifFalse: [
		self unexpectedResult: target ].
	^ target
]

{ #category : 'error handling' }
ReplayAttachUI >> unexpectedResult: anObject [

	ReplayScriptError new
		messageText: 'Expected script to return an existing Morph or Spec presenter, but got instance ' , anObject className , '.';
		tag: anObject;
		signal
]
