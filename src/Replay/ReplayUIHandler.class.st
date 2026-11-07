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

{ #category : 'editing' }
ReplayUIHandler class >> editorClass [

	^ ReplayUIHandlerEditor
]

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
ReplayUIHandler >> ensureReady: aResolvedUIElement on: runner [
	"Check that I am ready to run on aResolvedUIElement (see ensureReadyOn:). An error other than a missing UI stops the runner."

	^ [ self ensureReadyOn: aResolvedUIElement ]
		  on: Error
		  do: [ :error |
			  (error isKindOf: ReplayMissingUIError) ifFalse: [ runner stop ].
			  error pass ]
]

{ #category : 'running' }
ReplayUIHandler >> ensureReadyOn: aResolvedUIElement [
	"Signal a ReplayMissingUIError while I am not ready to run on aResolvedUIElement, my resolved target, so that a run waits for it like for a missing target.
	Only runs check it, not the editor while it shows the target. I am always ready by default."
]

{ #category : 'running' }
ReplayUIHandler >> runOn: runner [
	"Has control over runner continuation."

	| manager |
	self target isWorld ifTrue: [ ^ self runOnWorldOf: runner ].
	manager := runner manager.
	manager ifNil: [ ^ self missingManagerFor: runner ].
	manager
		resolve: self target
		forAction: self
		readyWhen: [ :resolved | self ensureReady: resolved on: runner ]
		thenDo: [ :resolved | self runOn: runner found: resolved ]
		onMissing: [ :error | self runOn: runner missing: error ]
]

{ #category : 'running' }
ReplayUIHandler >> runOn: runner found: aResolvedUIElement [

	runner isStopped ifTrue: [ ^ self ].
	runner protect: [ self runOn: runner resolvedUI: aResolvedUIElement ].
	"Let UI process action effects before continuing."
	runner defer: [ runner nextAction ]
]

{ #category : 'running' }
ReplayUIHandler >> runOn: runner missing: aReplayMissingUIError [

	runner isStopped ifFalse: [ runner protect: [ aReplayMissingUIError signal ] ]
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

	| world resolver element |
	self allowsWorldTarget ifFalse: [ ^ self missingTarget ].
	world := self currentWorld.
	element := ReplayResolvedUIElement
		           backend: runner backend
		           reference: self target
		           nativeElement: world
		           morph: world.
	resolver := runner backend resolver.
	resolver
		retry: [
			self ensureReady: element on: runner.
			element ]
		for: (resolver timeoutFor: self)
		thenDo: [ :resolved | self runOn: runner found: resolved ]
		onMissing: [ :error | self runOn: runner missing: error ]
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

{ #category : 'accessing' }
ReplayUIHandler >> targetWorld [

	target := nil
]
