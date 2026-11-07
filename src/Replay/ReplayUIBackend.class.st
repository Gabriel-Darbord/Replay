"
I define the backend protocol used by ReplayUIManager to resolve targets, run UI actions on them, and settle the active UI framework.

I run an action on a resolved target by asking it to run on the native element first (runNativelyOn:), then on the Morphic widget (runOnMorph:). I am also the default backend, without managed UI, of runners and managers.
"
Class {
	#name : 'ReplayUIBackend',
	#superclass : 'Object',
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

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

{ #category : 'resolving' }
ReplayUIBackend >> nameOfMorph: aMorph [
	"A semantic name that resolves to aMorph, or nil when there is none"

	^ nil
]

{ #category : 'accessing' }
ReplayUIBackend >> resolver [

	^ ReplayMorphicResolver on: self
]

{ #category : 'running' }
ReplayUIBackend >> run: anAction on: aResolvedUI [
	"Run anAction on the native element of aResolvedUI when it can, otherwise on its Morphic widget"

	(anAction runNativelyOn: aResolvedUI nativeElement) ifTrue: [ ^ self ].
	anAction runOnMorph: (aResolvedUI morphRequiredFor: anAction)
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
	"The morph that Morphic paths start from and that bounds are relative to"

	^ self managedUI
]
