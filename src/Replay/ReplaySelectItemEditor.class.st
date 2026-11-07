"
I edit a ReplaySelectItem: after its target, the label of the item to select ('Action item'). In a tree, the labels of the path from a root to the item are separated by ' > ', as in 'Kernel > Object'.
"
Class {
	#name : 'ReplaySelectItemEditor',
	#superclass : 'ReplayUIHandlerEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplaySelectItemEditor >> addFieldsTo: aLayout [

	aLayout add: (self
			 lineField: 'item'
			 label: 'Item label (tree path: Parent > Child):'
			 get: [ action labelPath ]
			 set: [ :aString | action labelPath: aString ])
		expand: false
]
