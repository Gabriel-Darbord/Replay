"
I am the abstract superclass of macro tests.

Macro tests install keymaps in the shared Keymapping repository and may use the default macro registry. I snapshot the installed Replay keymaps and restore them after each test, so tests never wipe the macros a developer installed. During a test, the default registry is a registry without file, so nothing touches the developer's macro file; temporary files made with temporaryFile are deleted afterwards.
"
Class {
	#name : 'ReplayMacroTestCase',
	#superclass : 'ReplayTestCase',
	#instVars : [
		'installedKeymapEntries',
		'defaultRegistry',
		'temporaryFiles'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'testing' }
ReplayMacroTestCase class >> isAbstract [

	^ self == ReplayMacroTestCase
]

{ #category : 'support' }
ReplayMacroTestCase >> controlShortcut: aString [

	^ ReplayShortcut new
		  text: aString;
		  addFlags: 16;
		  yourself
]

{ #category : 'support' }
ReplayMacroTestCase >> defaultFindShortcut [

	^ ReplayShortcut new
		  text: 'f';
		  addFlags: OSPlatform current defaultModifier eventCode;
		  yourself
]

{ #category : 'support' }
ReplayMacroTestCase >> dispatch: aCharacter buttons: flags inCategoryNamed: aSymbol [
	"Send a keystroke to a morph attached to the keymap category named aSymbol"

	| morph |
	morph := Morph new.
	morph kmDispatcher reset.
	morph attachKeymapCategory: aSymbol.
	morph kmDispatcher dispatchKeystroke: (self keyboardEventForCharacter: aCharacter buttons: flags)
]

{ #category : 'support' }
ReplayMacroTestCase >> editorOn: aReplayMacro [
	"A macro editor on aReplayMacro, alone in its library"

	^ ReplayMacroEditor
		  on: aReplayMacro
		  inLibrary: (ReplayMacroLibrary new
				   addMacro: aReplayMacro;
				   yourself)
]

{ #category : 'support' }
ReplayMacroTestCase >> keyboardEventForCharacter: aCharacter buttons: flags [

	| event |
	event := KeyboardEvent new.
	event
		setType: #keystroke
		buttons: flags
		position: 0 @ 0
		keyValue: aCharacter asInteger
		charCode: aCharacter asInteger
		hand: nil
		stamp: Time now.
	event key: (KeyboardKey fromCharacter: aCharacter).
	^ event
]

{ #category : 'support' }
ReplayMacroTestCase >> macroNamed: aString [

	^ self macroNamed: aString shortcut: ReplayShortcut new
]

{ #category : 'support' }
ReplayMacroTestCase >> macroNamed: aString shortcut: aReplayShortcut [

	^ ReplayMacro
		  scenario: (ReplayScenario new
				   title: aString;
				   yourself)
		  shortcut: aReplayShortcut
]

{ #category : 'running' }
ReplayMacroTestCase >> setUp [

	super setUp.
	installedKeymapEntries := ReplayMacro installedKeymapEntries.
	defaultRegistry := ReplayMacroRegistry instVarNamed: 'Default'.
	ReplayMacroRegistry default: ReplayMacroRegistry new.
	temporaryFiles := OrderedCollection new
]

{ #category : 'running' }
ReplayMacroTestCase >> tearDown [

	[ super tearDown ] ensure: [
		ReplayMacro uninstallAllInstalledKeymaps.
		installedKeymapEntries do: [ :entry | entry key addKeymapEntry: entry value ].
		ReplayMacroRegistry default: defaultRegistry.
		temporaryFiles do: [ :file | file ensureDelete ] ]
]

{ #category : 'support' }
ReplayMacroTestCase >> temporaryFile [
	"A file that does not exist yet, deleted after the test"

	^ temporaryFiles add: FileLocator temp / ('replay-macros-test-' , UUID new asString , '.ston')
]

{ #category : 'support' }
ReplayMacroTestCase >> withKeymapNamed: keymapName shortcut: aShortcut inCategoryNamed: categoryName during: aBlock [

	| category keymap |
	category := KMRepository default categoryForName: categoryName.
	keymap := KMKeymap
		          named: keymapName
		          shortcut: aShortcut
		          action: [ ]
		          description: 'Replay test keymap'.
	category addKeymapEntry: keymap.
	^ aBlock ensure: [ category removeKeymapEntry: keymap ]
]
