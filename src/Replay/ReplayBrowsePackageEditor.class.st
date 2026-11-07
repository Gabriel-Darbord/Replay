"
I edit a ReplayBrowsePackage: the package to browse, chosen in a list registered as 'Action package'.
"
Class {
	#name : 'ReplayBrowsePackageEditor',
	#superclass : 'ReplayBrowseEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayBrowsePackageEditor >> newTargetList [

	| list |
	(list := self newList)
		help: 'Select package browse';
		items: (self class packageOrganizer packages sorted: [ :a :b | a name <= b name ]);
		display: [ :each | each name ].
	action target ifNotNil: [ list selectItem: action targetPackage scrollToSelection: true ].
	list whenSelectedDo: [ :aPackage |
		aPackage ifNotNil: [
			action targetPackage: aPackage.
			self actionChanged ] ].
	^ self register: list as: 'package'
]

{ #category : 'accessing' }
ReplayBrowsePackageEditor >> targetLabel [

	^ 'package'
]
