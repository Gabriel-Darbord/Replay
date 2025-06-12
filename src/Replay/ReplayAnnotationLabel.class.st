"
I am a simple multiline string morph.

```script|show=both
ReplayAnnotationLabel new contents: 'Each line in the string
is a line in the morph.'
```
% blank to make space
 
With rich text support:
```script|show=both
ReplayAnnotationLabel new contents: (self iconNamed: #pharo) asText
```
"
Class {
	#name : 'ReplayAnnotationLabel',
	#superclass : 'Morph',
	#category : 'Replay-Morphs',
	#package : 'Replay',
	#tag : 'Morphs'
}

{ #category : 'accessing' }
ReplayAnnotationLabel >> contents: aStringOrText [
	"Use an editor to display the rich text"

	| displayMorph |
	displayMorph := self morphDisplaying: aStringOrText.

	submorphs size = 1
		ifTrue: [ self addMorphBack: displayMorph ]
		ifFalse: [ self replaceSubmorph: (submorphs at: 2) by: displayMorph ].

	self extent: displayMorph extent.
	self overlay extent: displayMorph extent
]

{ #category : 'initialization' }
ReplayAnnotationLabel >> initialize [

	super initialize.

	"Add an overlay over the text display to prevent edition and make it draggable"
	self addMorph: Morph new beTransparent
]

{ #category : 'accessing' }
ReplayAnnotationLabel >> morphDisplaying: aStringOrText [

	^ RubEditingArea new withoutAnyDecorator
		  readOnly: true;
		  borderStyle: self borderStyle;
		  setTextWith: aStringOrText
]

{ #category : 'wiw support' }
ReplayAnnotationLabel >> morphicLayerNumber [

	^ ReplayAnnotation morphicLayerNumber
]

{ #category : 'modes' }
ReplayAnnotationLabel >> overlay [

	^ submorphs at: 1
]

{ #category : 'accessing' }
ReplayAnnotationLabel >> wantsToBeTopmost [

	^ true
]
