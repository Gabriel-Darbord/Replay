"
I open a system browser focused on a configured package.
"
Class {
	#name : 'ReplayBrowsePackage',
	#superclass : 'ReplayBrowse',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplayBrowsePackage class >> editorClass [

	^ ReplayBrowsePackageEditor
]

{ #category : 'accessing' }
ReplayBrowsePackage class >> displayName [

	^ 'Browse Package'
]

{ #category : 'accessing' }
ReplayBrowsePackage >> targetPackage [

	target ifNil: [ self missingTarget: 'No package to browse is selected.' ].
	^ self class packageOrganizer
		  packageNamed: target
		  ifAbsent: [
		  self missingTarget: 'Cannot find the package to browse: ' , target , '.' ]
]

{ #category : 'accessing' }
ReplayBrowsePackage >> targetPackage: aPackage [

	target := aPackage name
]

{ #category : 'managing UI' }
ReplayBrowsePackage >> uiOn: runner [

	^ self browser selectPackage: self targetPackage
]
