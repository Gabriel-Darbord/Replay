"
I am the abstract editor of the browse actions (ReplayBrowse): a list to choose what to browse, then the window placement. Without a target, nothing is selected until the user chooses one.

My subclasses build the list (`newTargetList`), registered as 'Action class', 'Action method' or 'Action package'.
"
Class {
	#name : 'ReplayBrowseEditor',
	#superclass : 'ReplayOpenUIEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'testing' }
ReplayBrowseEditor class >> isAbstract [

	^ self == ReplayBrowseEditor
]

{ #category : 'building' }
ReplayBrowseEditor >> addFieldsTo: aLayout [

	aLayout add: self newTargetList.
	super addFieldsTo: aLayout
]

{ #category : 'building' }
ReplayBrowseEditor >> newTargetList [
	"The presenter that chooses the target of my action"

	self subclassResponsibility
]

{ #category : 'accessing' }
ReplayBrowseEditor >> settingsViewName [

	^ 'Select ' , self targetLabel
]

{ #category : 'accessing' }
ReplayBrowseEditor >> targetLabel [

	self subclassResponsibility
]
