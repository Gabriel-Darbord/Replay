"
I resolve Morphic references against the surface morph of my backend: Morphic paths, child indexes walked down from the surface, and the keyboard focus, when the focused morph is inside the surface. I do not resolve semantic names.

A path lookup fails while a morph on the path is still loading its children (see Morph>>replayIsStillLoading) or misses the next child; its error details list the children available where the walk stopped.
"
Class {
	#name : 'ReplayMorphicResolver',
	#superclass : 'ReplayUIResolver',
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'error handling' }
ReplayMorphicResolver >> childSummariesOf: aMorph [

	^ aMorph submorphs withIndexCollect: [ :child :index |
		  (Dictionary new: 6)
			  at: #index put: index;
			  at: #class put: child class name;
			  at: #bounds put: child bounds printString;
			  at: #visible put: child visible;
			  at: #submorphCount put: child submorphs size;
			  at: #printString put: (child printStringLimitedTo: 80);
			  yourself ]
]

{ #category : 'resolving' }
ReplayMorphicResolver >> lookUpKeyboardFocus: aReference [

	| focus |
	focus := self currentWorld activeHand keyboardFocus.
	focus ifNil: [
		self missing: aReference because: 'No Morphic keyboard focus is available.' ].
	(self morph: focus isInSurface: backend surfaceMorph) ifFalse: [
		self missing: aReference because: 'Keyboard focus is outside the managed UI.' ].
	^ self resolvedElementFor: aReference nativeElement: focus morph: focus
]

{ #category : 'resolving' }
ReplayMorphicResolver >> lookUpPath: aReference [
	"Walk the child indexes of aReference down from the surface morph"

	| current |
	current := backend surfaceMorph ifNil: [
		           self missing: aReference because: 'No root morph was available.' ].
	aReference value withIndexDo: [ :childIndex :position |
		current replayIsStillLoading ifTrue: [
			self
				missingPath: aReference
				at: current
				because: 'Waiting for ' , current class name , ' to finish loading at path position ' , position printString , '.' ].
		(childIndex isInteger and: [ childIndex between: 1 and: current submorphs size ]) ifFalse: [
			self
				missingPath: aReference
				at: current
				because: (current submorphs
						 ifEmpty: [ current class name , ' has no submorphs at path position ' , position printString , '.' ]
						 ifNotEmpty: [
							 'Path index ' , childIndex printString , ' at position ' , position printString , ' is outside '
							 , current submorphs size printString , ' submorph(s) of ' , current class name , '.' ]) ].
		current := current submorphs at: childIndex ].
	^ self resolvedElementFor: aReference nativeElement: current morph: current
]

{ #category : 'resolving' }
ReplayMorphicResolver >> lookupFor: aReference forAction: anAction [

	aReference isMorphicPath ifTrue: [ ^ [ self lookUpPath: aReference ] ].
	aReference isKeyboardFocus ifTrue: [ ^ [ self lookUpKeyboardFocus: aReference ] ].
	^ nil
]

{ #category : 'error handling' }
ReplayMorphicResolver >> missingPath: aReference at: aMorph because: aString [
	"Signal that the walk of the path of aReference stopped at aMorph"

	^ self
		  missing: aReference
		  because: 'Could not resolve UI target at path ' , aReference value printString , ': ' , aString
		  details: (Dictionary new
				   at: #root put: backend surfaceMorph;
				   at: #path put: aReference value;
				   at: #reason put: aString;
				   at: #availableChildren put: (self childSummariesOf: aMorph);
				   yourself)
]

{ #category : 'testing' }
ReplayMorphicResolver >> morph: aMorph isInSurface: surfaceMorph [

	surfaceMorph ifNil: [ ^ false ].
	aMorph == surfaceMorph ifTrue: [ ^ true ].
	^ aMorph ownerChain includes: surfaceMorph
]
