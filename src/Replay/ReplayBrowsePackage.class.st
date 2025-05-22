"
Opens a browser on a package.
"
Class {
	#name : 'ReplayBrowsePackage',
	#superclass : 'ReplayBrowse',
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'accessing' }
ReplayBrowsePackage class >> displayName [

	^ 'Browse Package'
]

{ #category : 'editing' }
ReplayBrowsePackage >> settingsPresenterOn: editor [

	| presenter |
	(presenter := editor newList)
		help: 'Select the package to browse';
		items: self class packageOrganizer packages sorted;
		display: [ :each | each name ];
		whenSelectedDo: [ :aPackage |
			self targetPackage: aPackage.
			editor actions rebuildLayout ].
	target
		ifNil: [ presenter selectFirst ]
		ifNotNil: [
		presenter selectItem: self targetPackage scrollToSelection: true ].
	^ presenter
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
ReplayBrowsePackage >> ui [

	^ self browser selectPackage: self targetPackage
]
