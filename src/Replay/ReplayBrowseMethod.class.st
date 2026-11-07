"
I open a system browser focused on a configured method reference, stored as 'Class#selector' or 'Class class#selector'.
"
Class {
	#name : 'ReplayBrowseMethod',
	#superclass : 'ReplayBrowse',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplayBrowseMethod class >> editorClass [

	^ ReplayBrowseMethodEditor
]

{ #category : 'accessing' }
ReplayBrowseMethod class >> displayName [

	^ 'Browse Method'
]

{ #category : 'accessing' }
ReplayBrowseMethod >> targetMethod [

	| parts class |
	target ifNil: [ self missingTarget: 'No method to browse is selected.' ].
	parts := $# split: target. "= '{class}#{selector}', class can be 'Foo class'"
	parts size = 2 ifFalse: [
		self missingTarget: 'Invalid method to browse: ' , target , '.' ].
	class := (self class environment classNamed: parts first) ifNil: [
		self missingTarget: 'Cannot find the class of the method to browse: ' , target , '.' ].
	^ class
		  compiledMethodAt: parts second asSymbol
		  ifAbsent: [ self missingTarget: 'Cannot find the method to browse: ' , target , '.' ]
]

{ #category : 'accessing' }
ReplayBrowseMethod >> targetMethod: aMethod [

	target := aMethod methodClass name , '#' , aMethod selector
]

{ #category : 'managing UI' }
ReplayBrowseMethod >> uiOn: runner [

	^ self browser selectMethod: self targetMethod
]
