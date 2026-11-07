"
I edit a ReplayShortcut: after its target, its key binding with a ReplayKeyBindingPresenter, and a ReplayShortcutDescriptionPresenter that lists the keymaps of the image: selecting one adopts its binding.

The key binding presenter is registered as 'Action key binding', its parts as 'Action key list', 'Action key chooser', 'Action add key button', ..., 'Action shift', 'Action control', 'Action alt option' and 'Action command', and the keymap list as 'Action keymap list'.
"
Class {
	#name : 'ReplayShortcutEditor',
	#superclass : 'ReplayUIHandlerEditor',
	#instVars : [
		'keyBindingPresenter'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayShortcutEditor >> addFieldsTo: aLayout [

	aLayout
		add: self newKeyBindingPresenter expand: false;
		add: self newKeymapList
]

{ #category : 'accessing' }
ReplayShortcutEditor >> keyBindingPresenter [

	^ keyBindingPresenter
]

{ #category : 'building' }
ReplayShortcutEditor >> newKeyBindingPresenter [

	keyBindingPresenter := ReplayKeyBindingPresenter
		                       on: action keyBinding
		                       whenChangedDo: [ :binding |
			                       action keyBinding: binding.
			                       self actionChanged ].
	keyBindingPresenter namedPresenters do: [ :association | self register: association value as: association key ].
	^ self register: keyBindingPresenter as: 'key binding'
]

{ #category : 'building' }
ReplayShortcutEditor >> newKeymapList [
	"Selecting a keymap shows its binding, which my key binding presenter gives to my action"

	| descriptionPresenter |
	(descriptionPresenter := self instantiate: ReplayShortcutDescriptionPresenter)
		categories: KMRepository default categories keys;
		selectKeymapOf: action keyBinding.
	descriptionPresenter shortcutList whenSelectedDo: [ :keymap |
		(ReplayKeyBinding fromKeymap: keymap) ifNotNil: [ :binding | keyBindingPresenter keyBinding: binding ] ].
	self register: descriptionPresenter shortcutList as: 'keymap list'.
	^ self labeled: 'Select a shortcut in the list to use it:' expandedField: descriptionPresenter
]
