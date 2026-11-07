"
I am the abstract resolver that turns ReplayUIReference values into ReplayResolvedUIElement objects for a backend.

Subclasses answer, for each kind of reference they support, a lookup block (see lookupFor:forAction:). A lookup answers the resolved element, or signals a ReplayMissingUIError saying what is missing. Because the target may not exist yet, for instance while a deferred UI rebuild is pending, I retry a failing lookup once per UI cycle, scheduled through the backend, until it succeeds or my timeout elapses. The missingBlock then receives the error of the last attempt. References that I cannot resolve at all are reported at once.

I keep no state about a resolution: one resolver can serve several of them.
"
Class {
	#name : 'ReplayUIResolver',
	#superclass : 'Object',
	#instVars : [
		'backend',
		'timeout'
	],
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'accessing' }
ReplayUIResolver class >> defaultTimeout [

	^ 3 seconds
]

{ #category : 'testing' }
ReplayUIResolver class >> isAbstract [

	^ self == ReplayUIResolver
]

{ #category : 'instance creation' }
ReplayUIResolver class >> on: aBackend [

	^ self new
		backend: aBackend;
		yourself
]

{ #category : 'accessing' }
ReplayUIResolver >> backend [

	^ backend
]

{ #category : 'accessing' }
ReplayUIResolver >> backend: aBackend [

	backend := aBackend
]

{ #category : 'resolving' }
ReplayUIResolver >> lookupFor: aReference forAction: anAction [
	"A block looking aReference up for anAction, which may be nil, or nil when I cannot resolve aReference.
	The block answers the resolved element, or signals a ReplayMissingUIError."

	self subclassResponsibility
]

{ #category : 'error handling' }
ReplayUIResolver >> missing: aReference because: aString [

	^ self missing: aReference because: aString details: Dictionary new
]

{ #category : 'error handling' }
ReplayUIResolver >> missing: aReference because: aString details: aDictionary [
	"Signal that aReference cannot be resolved now, for the reason aString"

	^ (self missingError: aReference because: aString details: aDictionary) signal
]

{ #category : 'error handling' }
ReplayUIResolver >> missingError: aReference because: aString details: aDictionary [

	^ ReplayMissingUIError new
		  messageText: aString;
		  subject: (aDictionary
				   at: #backend put: backend;
				   at: #reference put: aReference;
				   yourself);
		  yourself
]

{ #category : 'resolving' }
ReplayUIResolver >> resolve: aReference forAction: anAction thenDo: foundBlock onMissing: missingBlock [
	"Resolve aReference for anAction, now or in a later UI cycle, then evaluate foundBlock with the resolved element.
	When the lookup still fails after my timeout, evaluate missingBlock with the ReplayMissingUIError of its last attempt."

	| lookup |
	lookup := self lookupFor: aReference forAction: anAction.
	lookup ifNil: [
		^ missingBlock value: (self
				   missingError: aReference
				   because: self class name , ' cannot resolve ' , aReference printString , '.'
				   details: Dictionary new) ].
	^ self
		  retry: lookup
		  until: DateAndTime now + self timeout
		  thenDo: foundBlock
		  onMissing: missingBlock
]

{ #category : 'resolving' }
ReplayUIResolver >> resolve: aReference thenDo: foundBlock [

	^ self
		resolve: aReference
		thenDo: foundBlock
		onMissing: [ :error | error signal ]
]

{ #category : 'resolving' }
ReplayUIResolver >> resolve: aReference thenDo: foundBlock onMissing: missingBlock [

	^ self
		  resolve: aReference
		  forAction: nil
		  thenDo: foundBlock
		  onMissing: missingBlock
]

{ #category : 'resolving' }
ReplayUIResolver >> resolvedElementFor: aReference nativeElement: anObject morph: aMorph [

	^ ReplayResolvedUIElement
		backend: backend
		reference: aReference
		nativeElement: anObject
		morph: aMorph
]

{ #category : 'resolving' }
ReplayUIResolver >> retry: lookupBlock until: aDateAndTime thenDo: foundBlock onMissing: missingBlock [
	"Evaluate lookupBlock now, and again in the next UI cycle while it fails before aDateAndTime"

	| found failure |
	found := lookupBlock
		         on: ReplayMissingUIError
		         do: [ :error | failure := error ].
	failure ifNil: [ ^ foundBlock value: found ].
	DateAndTime now < aDateAndTime ifTrue: [
		^ self schedule: [
			  self
				  retry: lookupBlock
				  until: aDateAndTime
				  thenDo: foundBlock
				  onMissing: missingBlock ] ].
	failure messageText: failure messageText , ' Gave up after ' , self timeout asMilliSeconds printString , ' ms.'.
	^ missingBlock value: failure
]

{ #category : 'resolving' }
ReplayUIResolver >> schedule: aBlock [

	backend defer: aBlock
]

{ #category : 'accessing' }
ReplayUIResolver >> timeout [
	"How long to retry a lookup that fails, a Duration"

	^ timeout ifNil: [ self class defaultTimeout ]
]

{ #category : 'accessing' }
ReplayUIResolver >> timeout: aDuration [

	timeout := aDuration
]
