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
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'accessing' }
ReplayAnnotationLabel >> contents: aStringOrText [

	| editorMorph |
	self removeAllMorphs.

	"Use an editor to display the rich text"
	(editorMorph := RubEditingArea new)
		borderStyle: self borderStyle;
		setTextWith: aStringOrText.

	self addMorph: editorMorph.
	self extent: editorMorph extent.

	"Add an overlay over the editor to prevent edition and make it draggable"
	self addMorph: (Morph new beTransparent extent: self extent)
]

{ #category : 'wiw support' }
ReplayAnnotationLabel >> morphicLayerNumber [

	^ ReplayAnnotation morphicLayerNumber
]

{ #category : 'accessing' }
ReplayAnnotationLabel >> wantsToBeTopmost [

	^ true
]
