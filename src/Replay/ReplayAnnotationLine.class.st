"
I am the line between an annotation and its label.
"
Class {
	#name : 'ReplayAnnotationLine',
	#superclass : 'PolygonMorph',
	#category : 'Replay-Morphs',
	#package : 'Replay',
	#tag : 'Morphs'
}

{ #category : 'initialization' }
ReplayAnnotationLine >> initialize [
	"Skip PolygonMorph>>#initialize using its own custom initializer, which then calls `super initialize`"

	smoothCurve := false. "beStraightSegments"
	"At least one point is required"
	self
		vertices: { (0 @ 0) }
		color: Color black
		borderWidth: 2
		borderColor: Color red
]

{ #category : 'wiw support' }
ReplayAnnotationLine >> morphicLayerNumber [

	^ ReplayAnnotation morphicLayerNumber
]

{ #category : 'accessing' }
ReplayAnnotationLine >> wantsToBeTopmost [

	^ true
]
