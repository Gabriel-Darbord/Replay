"
I edit a ReplayChooseMenuItem: the label of the menu item to choose ('Action item'). In submenus, the labels of the path to the item are separated by ' > ', as in 'Refactorings > Rename'.
"
Class {
	#name : 'ReplayChooseMenuItemEditor',
	#superclass : 'ReplayActionEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayChooseMenuItemEditor >> addFieldsTo: aLayout [

	aLayout add: (self
			 lineField: 'item'
			 label: 'Menu item label (in submenus: Menu > Item):'
			 get: [ action labelPath ]
			 set: [ :aString | action labelPath: aString ])
		expand: false
]
