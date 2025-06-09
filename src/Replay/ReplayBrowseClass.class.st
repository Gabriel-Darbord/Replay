"
Open a browser on a class.
"
Class {
	#name : 'ReplayBrowseClass',
	#superclass : 'ReplayBrowse',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayBrowseClass class >> displayName [

	^ 'Browse Class'
]

{ #category : 'editing' }
ReplayBrowseClass >> settingsPresenterOn: editor [

	| presenter |
	(presenter := editor newList)
		help: 'Select the class to browse';
		items: self class environment allClasses;
		whenSelectedDo: [ :aClass |
			self targetClass: aClass.
			editor actions rebuildLayout ].
	target
		ifNil: [ presenter selectFirst ]
		ifNotNil: [
		presenter selectItem: self targetClass scrollToSelection: true ].
	^ presenter
]

{ #category : 'accessing' }
ReplayBrowseClass >> targetClass [

	^ self class environment at: target
]

{ #category : 'accessing' }
ReplayBrowseClass >> targetClass: aClass [

	target := aClass name
]

{ #category : 'accessing' }
ReplayBrowseClass >> targetType [

	^ Class
]

{ #category : 'managing UI' }
ReplayBrowseClass >> uiOn: runner [

	^ self browser selectClass: self targetClass
]
