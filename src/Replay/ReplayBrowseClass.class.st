"
I open a system browser focused on a configured class name.
"
Class {
	#name : 'ReplayBrowseClass',
	#superclass : 'ReplayBrowse',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplayBrowseClass class >> editorClass [

	^ ReplayBrowseClassEditor
]

{ #category : 'accessing' }
ReplayBrowseClass class >> displayName [

	^ 'Browse Class'
]

{ #category : 'accessing' }
ReplayBrowseClass >> targetClass [

	target ifNil: [ self missingTarget: 'No class to browse is selected.' ].
	^ (self class environment classNamed: target) ifNil: [
		  self missingTarget: 'Cannot find the class to browse: ' , target , '.' ]
]

{ #category : 'accessing' }
ReplayBrowseClass >> targetClass: aClass [

	target := aClass name
]

{ #category : 'managing UI' }
ReplayBrowseClass >> uiOn: runner [

	^ self browser selectClass: self targetClass
]
