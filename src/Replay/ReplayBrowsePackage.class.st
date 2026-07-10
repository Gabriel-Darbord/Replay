"
Open a browser on a package.
"
Class {
	#name : 'ReplayBrowsePackage',
	#superclass : 'ReplayBrowse',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayBrowsePackage class >> displayName [

	^ 'Browse Package'
]

{ #category : 'editing' }
ReplayBrowsePackage >> settingsPresenterOn: editor [

	| presenter |
	(presenter := editor newList)
		help: 'Select package browse';
		items: self class packageOrganizer packages sorted;
		display: [ :each | each name ];
		whenSelectedDo: [ :aPackage |
			self targetPackage: aPackage.
			editor actions rebuildLayout ].
	editor registerReplayPresenter: presenter named: 'Browse package target'.
	target
		ifNil: [ presenter selectFirst ]
		ifNotNil: [ presenter selectItem: self targetPackage scrollToSelection: true ].
	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: presenter;
				add: (self placementPresenterOn: editor) expand: false;
				yourself);
		yourself
]

{ #category : 'accessing' }
ReplayBrowsePackage >> targetPackage [

	^ target asPackage
]

{ #category : 'accessing' }
ReplayBrowsePackage >> targetPackage: aPackage [

	target := aPackage name
]

{ #category : 'accessing' }
ReplayBrowsePackage >> targetType [

	^ Package
]

{ #category : 'managing UI' }
ReplayBrowsePackage >> uiOn: runner [

	^ self browser selectPackage: self targetPackage
]
