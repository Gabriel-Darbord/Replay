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
		help: 'Select class browse';
		items: self class environment allClasses;
		whenSelectedDo: [ :aClass |
			self targetClass: aClass.
			editor actions rebuildLayout ].
	editor registerReplayPresenter: presenter named: 'Browse class target'.
	target
		ifNil: [ presenter selectFirst ]
		ifNotNil: [ presenter selectItem: self targetClass scrollToSelection: true ].
	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: presenter;
				add: (self placementPresenterOn: editor) expand: false;
				yourself);
		yourself
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
