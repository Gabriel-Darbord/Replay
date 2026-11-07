"
I test ReplayMacroRegistry: saving and loading its file, the default registry, replacing the library without stale keymaps, importing STON, reporting bad STON, and installation at image startup.
"
Class {
	#name : 'ReplayMacroRegistryTest',
	#superclass : 'ReplayMacroTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayMacroRegistryTest >> fileWith: aString [

	| file |
	file := self temporaryFile.
	file writeStreamDo: [ :stream | stream nextPutAll: aString ].
	^ file
]

{ #category : 'support' }
ReplayMacroRegistryTest >> fileWithLibraryInstallingOnStartup: aBoolean [
	"A library with a macro bound to Control+F in the #ReplayMacroStartupTest context"

	| library macro |
	library := ReplayMacroLibrary new.
	library installsOnStartup: aBoolean.
	macro := library addMacro: (self macroNamed: 'Startup macro' keyBinding: (self controlShortcut: 'f')).
	macro contextNames: { #ReplayMacroStartupTest }.
	^ self fileWith: (STON toStringPretty: library)
]

{ #category : 'support' }
ReplayMacroRegistryTest >> registryWithInstalledMacro [
	"A registry whose macro, bound to Control+F in #ReplayMacroRegistryTest, is installed"

	| registry macro |
	registry := ReplayMacroRegistry new.
	macro := registry library addMacro: (self macroNamed: 'Installed macro' keyBinding: (self controlShortcut: 'f')).
	macro contextNames: { #ReplayMacroRegistryTest }.
	macro install.
	^ registry
]

{ #category : 'running' }
ReplayMacroRegistryTest >> tearDown [

	[ ReplayTemporaryMacroRegistry defaultFile: nil ] ensure: [ super tearDown ]
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testDefaultRegistryLoadsItsFileOnFirstAccess [

	| registry |
	ReplayTemporaryMacroRegistry defaultFile: (self fileWithLibraryInstallingOnStartup: false).
	registry := ReplayTemporaryMacroRegistry default.

	self assert: registry file equals: ReplayTemporaryMacroRegistry defaultFile.
	self assert: (registry library macros collect: [ :macro | macro name ]) asArray equals: #( 'Startup macro' ).
	self assert: ReplayTemporaryMacroRegistry default identicalTo: registry.
	self deny: registry library macros first isInstalled
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testDefaultRegistryIsOnThePreferencesFile [

	self assert: ReplayMacroRegistry defaultFile basename equals: 'replay-macros.ston'.
	self assert: ReplayMacroRegistry new file isNil
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testImportStringAddsAMacroOrALibrary [

	| registry macro library added |
	registry := ReplayMacroRegistry new.
	macro := self macroNamed: 'Imported macro' keyBinding: (self controlShortcut: 'r').
	macro contextNames: { #RubTextEditor }.
	added := registry importString: (STON toString: macro).
	self assert: (added collect: [ :each | each name ]) asArray equals: #( 'Imported macro' ).
	self assert: added first keyBinding equals: (self controlShortcut: 'r').
	self assert: added first contextNames asArray equals: { #RubTextEditor }.

	library := ReplayMacroLibrary new.
	library addMacro: (self macroNamed: 'First').
	library addMacro: (self macroNamed: 'Second').
	added := registry importString: (STON toString: library).
	self assert: (added collect: [ :each | each name ]) asArray equals: #( 'First' 'Second' ).
	self
		assert: (registry library macros collect: [ :each | each name ]) asArray
		equals: #( 'Imported macro' 'First' 'Second' )
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testImportStringKeepsIdentifiersUnique [

	| registry macro |
	registry := ReplayMacroRegistry new.
	macro := registry library addMacro: (self macroNamed: 'Macro').
	registry importString: (STON toString: macro).
	registry importString: (STON toString: macro).

	self assert: (registry library macros collect: [ :each | each identifier ] as: Set) size equals: 3
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testImportStringRejectsMalformedSton [

	| registry error |
	registry := ReplayMacroRegistry new.
	registry library addMacro: (self macroNamed: 'Kept').
	error := [ registry importString: 'ReplayMacro { #scenario : ' ] on: ReplayError do: [ :e | e ].

	self assert: (error isKindOf: ReplayError).
	self assert: (error messageText includesSubstring: 'STON').
	self assert: registry library macros size equals: 1
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testImportStringRejectsWrongType [

	| registry scenario error |
	registry := ReplayMacroRegistry new.
	scenario := ReplayScenario new
		            title: 'Not a macro';
		            yourself.
	error := [ registry importString: (STON toString: scenario) ] on: ReplayError do: [ :e | e ].

	self assert: (error isKindOf: ReplayError).
	self assert: (error messageText includesSubstring: 'ReplayScenario').
	self assert: error subject title equals: 'Not a macro'.
	self assert: registry library macros isEmpty
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testImportStringSaves [

	| registry |
	registry := ReplayMacroRegistry new
		            file: self temporaryFile;
		            yourself.
	registry importString: (STON toString: (self macroNamed: 'Imported')).

	self
		assert: ((ReplayMacroRegistry libraryFromFile: registry file) macros collect: [ :each | each name ]) asArray
		equals: #( 'Imported' )
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testLoadKeepsInstalledMacrosInstalledWithTheirNewObjects [

	| registry before beforeKeymap after |
	registry := self registryWithInstalledMacro.
	registry
		file: self temporaryFile;
		save.
	before := registry library macros first.
	beforeKeymap := before installedKeymaps first.

	registry load.
	after := registry library macros first.

	self deny: after identicalTo: before.
	self assert: after isInstalled.
	self deny: after installedKeymaps first identicalTo: beforeKeymap.
	self assert: (ReplayMacro installedKeymaps count: [ :keymap | after isOwnKeymap: keymap ]) equals: 1
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testLoadMalformedFileKeepsLibrary [

	| registry library error |
	registry := ReplayMacroRegistry new
		            file: (self fileWith: 'ReplayMacroLibrary { #macros : OrderedCollection [');
		            yourself.
	library := registry library.
	library addMacro: (self macroNamed: 'Kept').
	error := [ registry load ] on: ReplayError do: [ :e | e ].

	self assert: (error isKindOf: ReplayError).
	self assert: registry library identicalTo: library.
	self should: [ ReplayMacroRegistry onFile: registry file ] raise: ReplayError
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testLoadWrongTypeFileKeepsLibrary [

	| registry library error |
	registry := ReplayMacroRegistry new
		            file: (self fileWith: (STON toString: ReplayScenario new));
		            yourself.
	library := registry library.
	error := [ registry load ] on: ReplayError do: [ :e | e ].

	self assert: (error isKindOf: ReplayError).
	self assert: (error messageText includesSubstring: 'macro library').
	self assert: registry library identicalTo: library
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testMacroIdentitySurvivesSaveLoadEditInstallReload [

	| file firstRegistry macro secondRegistry loadedMacro thirdRegistry reloadedMacro |
	file := self temporaryFile.
	firstRegistry := ReplayMacroRegistry new
		                 file: file;
		                 yourself.
	macro := firstRegistry library addNewMacro.
	macro
		contextNames: { #RubTextEditor };
		keyBinding: (self controlShortcut: 'f').
	firstRegistry save.

	secondRegistry := ReplayMacroRegistry onFile: file.
	loadedMacro := secondRegistry library macros first.
	loadedMacro install.
	loadedMacro scenario title: 'Edited macro'.
	loadedMacro keyBinding: (self controlShortcut: 'g').
	loadedMacro updateInstalledKeymaps.
	secondRegistry save.

	thirdRegistry := ReplayMacroRegistry onFile: file.
	reloadedMacro := thirdRegistry library macros first.
	reloadedMacro install.
	self assert: reloadedMacro identifier equals: macro identifier.
	self assert: reloadedMacro name equals: 'Edited macro'.
	self assert: reloadedMacro keyBinding equals: (self controlShortcut: 'g').
	self assert: (ReplayMacro installedKeymaps count: [ :keymap | reloadedMacro isOwnKeymap: keymap ]) equals: 1
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testOnMissingFileHasEmptyLibrary [

	| registry |
	registry := ReplayMacroRegistry onFile: self temporaryFile.
	self assert: registry library macros isEmpty.
	self deny: registry file exists
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testRegistersForImageStartup [

	self assert: (SessionManager default hasRegistered: ReplayMacroRegistry name)
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testReplaceLibrarySwapsKeymapsAndRunsTheNewMacro [

	| registry oldMacro removedMacro newLibrary newMacro spy |
	registry := self registryWithInstalledMacro.
	registry file: self temporaryFile.
	oldMacro := registry library macros first.
	removedMacro := registry library addMacro: (self macroNamed: 'Removed' keyBinding: (self controlShortcut: 'g')).
	removedMacro contextNames: { #ReplayMacroRegistryTest }.
	removedMacro install.
	newLibrary := ReplayMacroLibrary new.
	newMacro := newLibrary addMacro: (STON fromString: (STON toString: oldMacro)).
	spy := ReplayMacroRunSpy new.
	newMacro scenario: spy.

	registry replaceLibrary: newLibrary.

	self assert: registry library identicalTo: newLibrary.
	self deny: removedMacro isInstalled.
	self assert: newMacro isInstalled.
	self assert: (ReplayMacro installedKeymaps count: [ :keymap | newMacro isOwnKeymap: keymap ]) equals: 1.
	self dispatch: $f buttons: 16 inCategoryNamed: #ReplayMacroRegistryTest.
	self assert: spy hasRun.
	self
		assert: ((ReplayMacroRegistry libraryFromFile: registry file) macros collect: [ :each | each identifier ]) asArray
		equals: { oldMacro identifier }
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testSaveOverwritesLongerContent [

	| registry file |
	file := self temporaryFile.
	registry := ReplayMacroRegistry new
		            file: file;
		            yourself.
	3 timesRepeat: [ registry library addNewMacro ].
	registry save.
	registry library macros removeAll.
	registry save.

	self assert: file contents equals: (STON toStringPretty: registry library).
	self assert: (ReplayMacroRegistry libraryFromFile: file) macros isEmpty
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testSavesAndLoadsLibrary [

	| file registry macro loaded |
	file := self temporaryFile.
	registry := ReplayMacroRegistry new
		            file: file;
		            yourself.
	macro := registry library addNewMacro.
	macro
		contextNames: { #RubTextEditor };
		keyBinding: (self controlShortcut: 'f').
	registry library installsOnStartup: true.
	registry save.

	loaded := (ReplayMacroRegistry onFile: file) library.
	self assert: loaded installsOnStartup.
	self assert: loaded macros size equals: 1.
	self assert: loaded macros first name equals: 'Macro 1'.
	self assert: loaded macros first identifier equals: macro identifier.
	self assert: loaded macros first contextNames asArray equals: { #RubTextEditor }.
	self deny: loaded macros first isInstalled
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testStartupCreatesTheDefaultRegistryFromItsFile [

	ReplayTemporaryMacroRegistry defaultFile: (self fileWithLibraryInstallingOnStartup: true).

	ReplayTemporaryMacroRegistry startUp: true.

	self assert: ReplayTemporaryMacroRegistry hasDefault.
	self assert: ReplayTemporaryMacroRegistry default library macros first isInstalled
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testStartupDoesNotInstallWhenTheLibraryDoesNotSaySo [

	ReplayMacroRegistry default: (ReplayMacroRegistry new
			 file: (self fileWithLibraryInstallingOnStartup: false);
			 yourself).

	ReplayMacroRegistry startUp: true.

	self assert: ReplayMacroRegistry default library macros size equals: 1.
	self deny: ReplayMacroRegistry default library macros first isInstalled
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testStartupIgnoresSessionsThatDoNotStartTheImage [

	ReplayMacroRegistry default: (ReplayMacroRegistry new
			 file: (self fileWithLibraryInstallingOnStartup: true);
			 yourself).

	ReplayMacroRegistry startUp: false.

	self assert: ReplayMacroRegistry default library macros isEmpty
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testStartupInstallsWhenTheLibrarySaysSo [

	ReplayMacroRegistry default: (ReplayMacroRegistry new
			 file: (self fileWithLibraryInstallingOnStartup: true);
			 yourself).

	ReplayMacroRegistry startUp: true.

	self assert: ReplayMacroRegistry default library macros first isInstalled
]

{ #category : 'tests' }
ReplayMacroRegistryTest >> testStartupSurvivesABadFile [

	| registry |
	ReplayTemporaryMacroRegistry defaultFile: (self fileWith: 'not STON {').
	self shouldnt: [ ReplayTemporaryMacroRegistry startUp: true ] raise: Error.
	self deny: ReplayTemporaryMacroRegistry hasDefault.

	registry := ReplayMacroRegistry new
		            file: (self fileWith: (STON toString: ReplayScenario new));
		            yourself.
	registry library addMacro: (self macroNamed: 'Kept').
	ReplayMacroRegistry default: registry.
	self shouldnt: [ ReplayMacroRegistry startUp: true ] raise: Error.
	self assert: registry library macros size equals: 1
]
