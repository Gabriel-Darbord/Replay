"
I resolve ReplayUIReference values against a Morphic surface using semantic names when possible and morph paths otherwise.
"
Class {
	#name : 'ReplayMorphicResolver',
	#superclass : 'ReplayUIResolver',
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'testing' }
ReplayMorphicResolver >> morph: aMorph isInSurface: surfaceMorph [

	surfaceMorph ifNil: [ ^ false ].
	aMorph == surfaceMorph ifTrue: [ ^ true ].
	^ aMorph ownerChain includes: surfaceMorph
]

{ #category : 'resolving' }
ReplayMorphicResolver >> resolve: aReference thenDo: foundBlock onMissing: missingBlock [

	aReference isKeyboardFocus ifTrue: [
		^ self
			resolveKeyboardFocus: aReference
			thenDo: foundBlock
			onMissing: missingBlock ].
	aReference isMorphicPath ifFalse: [
		^ self
			missingReference: aReference
			reason: 'Morphic backend can only resolve Morphic path or keyboard focus references.'
			onMissing: missingBlock ].
	^ ReplayUIPathResolver new
		root: backend surfaceMorph;
		path: aReference value;
		scheduleWith: [ :block | backend defer: block ];
		whenFound: [ :morph |
			foundBlock value: (self
				resolvedElementFor: aReference
				nativeElement: morph
				morph: morph) ];
		whenMissing: missingBlock;
		resolve
]

{ #category : 'resolving' }
ReplayMorphicResolver >> resolveKeyboardFocus: aReference thenDo: foundBlock onMissing: missingBlock [

	| focus surface |
	focus := World activeHand keyboardFocus.
	focus ifNil: [
		^ self
			missingReference: aReference
			reason: 'No Morphic keyboard focus is available.'
			onMissing: missingBlock ].
	surface := backend surfaceMorph.
	(self morph: focus isInSurface: surface) ifFalse: [
		^ self
			missingReference: aReference
			reason: 'Keyboard focus is outside the managed UI.'
			onMissing: missingBlock ].
	^ foundBlock value: (self
		resolvedElementFor: aReference
		nativeElement: focus
		morph: focus)
]

{ #category : 'testing' }
ReplayMorphicResolver >> supportsReference: aReference [

	^ aReference isMorphicPath or: [ aReference isKeyboardFocus ]
]
