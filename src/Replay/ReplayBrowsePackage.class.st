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

{ #category : 'accessing' }
ReplayBrowsePackage class >> displayName [

	^ 'Browse Package'
]

{ #category : 'editing' }
ReplayBrowsePackage >> settingsPresenterOn: editor [
	"Without a target, nothing is selected until the user chooses a package."

	| presenter |
	(presenter := editor newList)
		help: 'Select package browse';
		items: (self class packageOrganizer packages sorted: [ :a :b | a name <= b name ]);
		display: [ :each | each name ].
	editor registerReplayPresenter: presenter named: 'Browse package target'.
	target ifNotNil: [
		presenter selectItem: self targetPackage scrollToSelection: true ].
	presenter whenSelectedDo: [ :aPackage |
		aPackage ifNotNil: [
			self targetPackage: aPackage.
			editor actions rebuildLayout ] ].
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

{ #category : 'accessing' }
ReplayBrowsePackage >> targetType [

	^ Package
]

{ #category : 'managing UI' }
ReplayBrowsePackage >> uiOn: runner [

	^ self browser selectPackage: self targetPackage
]
