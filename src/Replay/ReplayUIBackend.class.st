"
Abstract base for UI backend adapters used by ReplayUIManager.
"
Class {
	#name : 'ReplayUIBackend',
	#superclass : 'Object',
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'testing' }
ReplayUIBackend >> canRun: anAction nativelyOn: nativeElement [

	^ false
]

{ #category : 'running' }
ReplayUIBackend >> defer: aBlock [

	self currentWorld defer: aBlock
]

{ #category : 'accessing' }
ReplayUIBackend >> managedPresenter [

	^ nil
]

{ #category : 'accessing' }
ReplayUIBackend >> managedUI [

	^ nil
]

{ #category : 'resolving' }
ReplayUIBackend >> resolve: aReference forAction: anAction thenDo: foundBlock onMissing: missingBlock [

	^ self resolver
		resolve: aReference
		forAction: anAction
		thenDo: foundBlock
		onMissing: missingBlock
]

{ #category : 'resolving' }
ReplayUIBackend >> resolve: aReference thenDo: foundBlock onMissing: missingBlock [

	^ self resolver
		resolve: aReference
		thenDo: foundBlock
		onMissing: missingBlock
]

{ #category : 'accessing' }
ReplayUIBackend >> resolver [

	^ ReplayUIResolver on: self
]

{ #category : 'accessing' }
ReplayUIBackend >> root [

	^ self managedUI
]

{ #category : 'running' }
ReplayUIBackend >> runClick: aReplayClick on: aResolvedUI [

	aReplayClick clickOn: aResolvedUI clickTarget
]

{ #category : 'running' }
ReplayUIBackend >> runFocus: aReplayFocus on: aResolvedUI [

	| target |
	target := aResolvedUI focusTarget.
	target ifNil: [ target := aResolvedUI morphRequiredFor: 'focus' ].
	target takeKeyboardFocus
]

{ #category : 'running' }
ReplayUIBackend >> runPressKey: aReplayPressKey on: aResolvedUI [

	aReplayPressKey pressKeyOn: aResolvedUI keyboardTarget
]

{ #category : 'running' }
ReplayUIBackend >> runSelectText: aReplaySelectText on: aResolvedUI [

	| native |
	native := aResolvedUI nativeElement.
	(aReplaySelectText canSelectTextIn: native) ifTrue: [
		^ aReplaySelectText selectTextIn: native ].
	aReplaySelectText selectTextIn:
		(aResolvedUI morphRequiredFor: aReplaySelectText class displayName)
]

{ #category : 'running' }
ReplayUIBackend >> runShortcut: aReplayShortcut on: aResolvedUI [

	aReplayShortcut shortcutOn: aResolvedUI keyboardTarget
]

{ #category : 'running' }
ReplayUIBackend >> runType: aReplayType on: aResolvedUI [

	aReplayType typeOn: aResolvedUI keyboardTarget
]

{ #category : 'accessing' }
ReplayUIBackend >> semanticScriptReceiver [

	^ nil
]

{ #category : 'running' }
ReplayUIBackend >> settleUI [

	self currentWorld doOneCycle
]

{ #category : 'accessing' }
ReplayUIBackend >> surfaceMorph [

	^ self managedUI
]
