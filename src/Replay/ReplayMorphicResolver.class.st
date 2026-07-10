"
I resolve Morphic Replay UI references.
"
Class {
	#name : 'ReplayMorphicResolver',
	#superclass : 'ReplayUIResolver',
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'resolving' }
ReplayMorphicResolver >> resolve: aReference thenDo: foundBlock onMissing: missingBlock [

	aReference isMorphicPath ifFalse: [
		^ self
			missingReference: aReference
			reason: 'Morphic backend can only resolve Morphic path references.'
			onMissing: missingBlock ].
	^ ReplayUIPathResolver
		findPath: aReference value
		in: backend surfaceMorph
		thenDo: [ :morph |
			foundBlock value: (self
				resolvedElementFor: aReference
				nativeElement: morph
				morph: morph) ]
		onMissing: missingBlock
]

{ #category : 'testing' }
ReplayMorphicResolver >> supportsReference: aReference [

	^ aReference isMorphicPath
]
