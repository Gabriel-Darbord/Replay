"
I am a simple multiline string morph.

```script|show=both
TutorialAnnotationLabel new contents: 'Each line in the string
is a line in the morph.'
``` 
"
Class {
	#name : 'ReplayAnnotationLabel',
	#superclass : 'Morph',
	#instVars : [
		'contents',
		'margins'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'accessing' }
ReplayAnnotationLabel >> contents: aStringOrText [

	| lines y |
	self removeAllMorphs.
	contents := aStringOrText.
	lines := OrderedCollection new.
	contents string lineIndicesDo: [ :start :end :_ |
		lines add: (contents copyFrom: start to: end) ].
	y := margins ifNil: [ 0 ] ifNotNil: [ margins top ].

	lines do: [ :line |
		| morph |
		morph := StringMorph new contents: line.
		morph position: margins left @ y.
		self addMorphBack: morph. "First line is first submorph"
		y := y + morph height ].

	self fitContents
]

{ #category : 'accessing' }
ReplayAnnotationLabel >> fitContents [

	| newBounds boundsChanged |
	newBounds := self measureContents.
	boundsChanged := bounds extent ~= newBounds.
	self extent: newBounds. "default short-circuits if bounds not changed"
	boundsChanged ifFalse: [ self changed ]
]

{ #category : 'initialization' }
ReplayAnnotationLabel >> initialize [

	super initialize.
	margins := Margin fromNumber: 5.
	self color: Color white
]

{ #category : 'accessing' }
ReplayAnnotationLabel >> margins [

	^ margins
]

{ #category : 'accessing' }
ReplayAnnotationLabel >> margins: aMargin [

	margins := aMargin
]

{ #category : 'accessing' }
ReplayAnnotationLabel >> measureContents [

	| font width height |
	font := TextStyle defaultFont.
	width := 0.
	height := 0.
	contents string lines ifNotEmpty: [ :lines |
		width := lines max: [ :line | font widthOfString: line ].
		height := lines size * font height ].
	margins ifNotNil: [
		width := width + margins left + margins right.
		height := height + margins top + margins bottom ].
	^ (width @ height + (self layoutInset * 2)) ceiling
]

{ #category : 'wiw support' }
ReplayAnnotationLabel >> morphicLayerNumber [

	^ ReplayAnnotation morphicLayerNumber
]

{ #category : 'accessing' }
ReplayAnnotationLabel >> wantsToBeTopmost [

	^ true
]
