"
I edit a ReplayBrowseClass: the class to browse, chosen in a list registered as 'Action class'.
"
Class {
	#name : 'ReplayBrowseClassEditor',
	#superclass : 'ReplayBrowseEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayBrowseClassEditor >> newTargetList [

	| list |
	(list := self newList)
		help: 'Select class browse';
		items: (self class environment allClasses sorted: [ :a :b | a name <= b name ]).
	action target ifNotNil: [ list selectItem: action targetClass scrollToSelection: true ].
	list whenSelectedDo: [ :aClass |
		aClass ifNotNil: [
			action targetClass: aClass.
			self actionChanged ] ].
	^ self register: list as: 'class'
]

{ #category : 'accessing' }
ReplayBrowseClassEditor >> targetLabel [

	^ 'class'
]
