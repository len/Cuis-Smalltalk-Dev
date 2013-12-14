'From Squeak3.7 of ''4 September 2004'' [latest update: #5989] on 2 December 2008 at 11:07:32 am'!
	"This is a tool to track down unwanted pointers into the segment.  If we don't deal with these pointers, the segment turns out much smaller than it should.  These pointers keep a subtree of objects out of the segment.
1) assemble all objects should be in seg:  morph tree, presenter, scripts, player classes, metaclasses.  Put in a Set.
2) Remove the roots from this list.  Ask for senders of each.  Of the senders, forget the ones that are in the segment already.  Keep others.  The list is now all the 'incorrect' pointers into the segment."

	| inSeg testRoots pointIn xRoots |
	Smalltalk garbageCollect.
	inSeg := IdentitySet new: 200.
	arrayOfRoots := rootArray.
	testRoots := rootArray.
	xRoots := testRoots.
	xRoots do: 
			[:obj | 
			"root is a project"

			obj isMorph 
				ifTrue: 
					[obj allMorphs do: 
							[:mm | 
							inSeg add: mm].
					]].
	testRoots do: [:each | inSeg remove: each ifAbsent: []].
	"want them to be pointed at from outside"
	pointIn := IdentitySet new: 400.
	inSeg do: [:ob | pointIn addAll: (Smalltalk pointersTo: ob except: inSeg)].
	testRoots do: [:each | pointIn remove: each ifAbsent: []].
	pointIn remove: inSeg array ifAbsent: [].
	pointIn remove: pointIn array ifAbsent: [].
	inSeg do: 
			[:obj | 
			(obj isMorph) 
				ifTrue: 
					[pointIn remove: (obj instVarAt: 3)
						ifAbsent: 
							["submorphs"

							].
					"associations in extension"
					pointIn remove: obj extension ifAbsent: [].
					obj extension ifNotNil: 
							[obj extension otherProperties ifNotNil: 
									[obj extension otherProperties 
										associationsDo: [:ass | pointIn remove: ass ifAbsent: []]
									"*** and extension actorState"
									"*** and ActorState instantiatedUserScriptsDictionary ScriptInstantiations"]]].
			].
	"*** presenter playerlist"
	self halt: 'Examine local variables pointIn and inSeg'.
	^pointIn! !
	"The methods we are allowed to use.  (MethodFinder new initialize) "

	Approved _ Set new.
	AddAndRemove _ Set new.
	Blocks _ Set new.
	"These modify an argument and are not used by the MethodFinder: longPrintOn: printOn: storeOn: sentTo: storeOn:base: printOn:base: absPrintExactlyOn:base: absPrintOn:base: absPrintOn:base:digitCount: writeOn: writeScanOn: possibleVariablesFor:continuedFrom: printOn:format:"

"Object"  
	#("in class, instance creation" initialInstance  newFrom: readCarefullyFrom:
"accessing" at: basicAt: basicSize bindWithTemp: in: size yourself 
"testing" ifNil: ifNil:ifNotNil: ifNotNil: ifNotNil:ifNil: isColor isFloat isFraction isInMemory isInteger isMorph isNil isNumber isPoint isPseudoContext isText isTransparent isWebBrowser knownName notNil pointsTo: wantsSteps 
"comparing" = == closeTo: hash hashMappedBy: identityHash identityHashMappedBy: identityHashPrintString ~= ~~ 
"copying" clone copy shallowCopy 
"dependents access" canDiscardEdits dependents hasUnacceptedEdits 
"updating" changed changed: okToChange update: windowIsClosing 
"printing" fullPrintString isLiteral longPrintString printString storeString stringForReadout stringRepresentation 
"class membership" class isKindOf: isKindOf:orOf: isMemberOf: respondsTo: xxxClass 
"error handling" 
"user interface" defaultLabelForInspector initialExtent modelWakeUp 
"system primitives" asOop instVarAt: instVarNamed: 
"private" 
"associating" -> 
"converting" as: asOrderedCollection asString 
"casing" caseOf: caseOf:otherwise: 
"binding" bindingOf: 
"macpal" contentsChanged currentEvent currentHand currentWorld flash ifKindOf:thenDo: instanceVariableValues 
"flagging" flag: 
"translation support" "objects from disk" "finalization" ) do: [:sel | Approved add: sel].
	#(at:add: at:modify: at:put: basicAt:put: "NOT instVar:at:"
"message handling" perform: perform:orSendTo: perform:with: perform:with:with: perform:with:with:with: perform:withArguments: perform:withArguments:inSuperclass: 
) do: [:sel | AddAndRemove add: sel].

"Boolean, True, False, UndefinedObject"  
	#("logical operations" & eqv: not xor: |
"controlling" and: ifFalse: ifFalse:ifTrue: ifTrue: ifTrue:ifFalse: or:
"copying" 
"testing" isEmptyOrNil) do: [:sel | Approved add: sel].

"Behavior" 
	#("initialize-release"
"accessing" compilerClass decompilerClass evaluatorClass format methodDict parserClass sourceCodeTemplate subclassDefinerClass
"testing" instSize instSpec isBits isBytes isFixed isPointers isVariable isWeak isWords
"copying"
"printing" printHierarchy
"creating class hierarchy"
"creating method dictionary"
"instance creation" basicNew basicNew: new new:
"accessing class hierarchy" allSubclasses allSubclassesWithLevelDo:startingLevel: allSuperclasses subclasses superclass withAllSubclasses withAllSuperclasses
"accessing method dictionary" allSelectors changeRecordsAt: compiledMethodAt: compiledMethodAt:ifAbsent: firstCommentAt: lookupSelector: selectors selectorsDo: selectorsWithArgs: "slow but useful ->" sourceCodeAt: sourceCodeAt:ifAbsent: sourceMethodAt: sourceMethodAt:ifAbsent:
"accessing instances and variables" allClassVarNames allInstVarNames allSharedPools classVarNames instVarNames instanceCount sharedPools someInstance subclassInstVarNames
"testing class hierarchy" inheritsFrom: kindOfSubclass
"testing method dictionary" canUnderstand: classThatUnderstands: hasMethods includesSelector: scopeHas:ifTrue: whichClassIncludesSelector: whichSelectorsAccess: whichSelectorsReferTo: whichSelectorsReferTo:special:byte: whichSelectorsStoreInto:
"enumerating"
"user interface"
"private" indexIfCompact) do: [:sel | Approved add: sel].

"ClassDescription"
	#("initialize-release" 
"accessing" classVersion isMeta name theNonMetaClass
"copying" 
"printing" classVariablesString instanceVariablesString sharedPoolsString
"instance variables" checkForInstVarsOK: 
"method dictionary" 
"organization" category organization whichCategoryIncludesSelector:
"compiling" acceptsLoggingOfCompilation wantsChangeSetLogging
"fileIn/Out" definition
"private" ) do: [:sel | Approved add: sel].

"Class"
	#("initialize-release" 
"accessing" classPool
"testing"
"copying" 
"class name" 
"instance variables" 
"class variables" classVarAt: classVariableAssociationAt:
"pool variables" 
"compiling" 
"subclass creation" 
"fileIn/Out" ) do: [:sel | Approved add: sel]. 

"Metaclass"
	#("initialize-release" 
"accessing" soleInstance
"copying" "instance creation" "instance variables"  "pool variables" "class hierarchy"  "compiling"
"fileIn/Out"  nonTrivial ) do: [:sel | Approved add: sel].

"Context, BlockContext"
	#(receiver client method receiver tempAt: 
"debugger access" mclass pc selector sender shortStack sourceCode tempNames tempsAndValues
"controlling"  "printing" "system simulation" 
"initialize-release" 
"accessing" hasMethodReturn home numArgs
"evaluating" value value:ifError: value:value: value:value:value: value:value:value:value: valueWithArguments:
"controlling"  "scheduling"  "instruction decoding"  "printing" "private"  "system simulation" ) do: [:sel | Approved add: sel].
	#(value: "<- Association has it as a store" ) do: [:sel | AddAndRemove add: sel].

"Message"
	#("inclass, instance creation" selector: selector:argument: selector:arguments:
"accessing" argument argument: arguments sends:
"printing" "sending" ) do: [:sel | Approved add: sel].
	#("private" setSelector:arguments:) do: [:sel | AddAndRemove add: sel].

"Magnitude"
	#("comparing" < <= > >= between:and:
"testing" max: min: min:max: ) do: [:sel | Approved add: sel].

"Date, Time"
	#("in class, instance creation" fromDays: fromSeconds: fromString: newDay:month:year: newDay:year: today
	"in class, general inquiries" dateAndTimeNow dayOfWeek: daysInMonth:forYear: daysInYear: firstWeekdayOfMonth:year: indexOfMonth: leapYear: nameOfDay: nameOfMonth:
"accessing" day leap monthIndex monthName weekday year
"arithmetic" addDays: subtractDate: subtractDays:
"comparing"
"inquiries" dayOfMonth daysInMonth daysInYear daysLeftInYear firstDayOfMonth previous:
"converting" asSeconds
"printing" mmddyy mmddyyyy printFormat: 
"private" firstDayOfMonthIndex: weekdayIndex 
	"in class, instance creation" fromSeconds: now 
	"in class, general inquiries" dateAndTimeFromSeconds: dateAndTimeNow millisecondClockValue millisecondsToRun: totalSeconds
"accessing" hours minutes seconds
"arithmetic" addTime: subtractTime:
"comparing"
"printing" intervalString print24 
"converting") do: [:sel | Approved add: sel].
	#("private" hours: hours:minutes:seconds: day:year: 
		 ) do: [:sel | AddAndRemove add: sel].

"Number"
	#("in class" readFrom:base: 
"arithmetic" * + - / // \\ abs negated quo: reciprocal rem:
"mathematical functions" arcCos arcSin arcTan arcTan: cos exp floorLog: ln log log: raisedTo: raisedToInteger: sin sqrt squared tan
"truncation and round off" ceiling detentBy:atMultiplesOf:snap: floor roundTo: roundUpTo: rounded truncateTo: truncated
"comparing"
"testing" even isDivisibleBy: isInf isInfinite isNaN isZero negative odd positive sign strictlyPositive
"converting" @ asInteger asNumber asPoint asSmallAngleDegrees degreesToRadians radiansToDegrees
"intervals" to: to:by: 
"printing" printStringBase: storeStringBase: ) do: [:sel | Approved add: sel].

"Integer"
	#("in class" primesUpTo:
"testing" isPowerOfTwo
"arithmetic" alignedTo:
"comparing"
"truncation and round off" atRandom normalize
"enumerating" timesRepeat:
"mathematical functions" degreeCos degreeSin factorial gcd: lcm: take:
"bit manipulation" << >> allMask: anyMask: bitAnd: bitClear: bitInvert bitInvert32 bitOr: bitShift: bitXor: lowBit noMask:
"converting" asCharacter asColorOfDepth: asFloat asFraction asHexDigit
"printing" asStringWithCommas hex hex8 radix:
"system primitives" lastDigit replaceFrom:to:with:startingAt:
"private" "benchmarks" ) do: [:sel | Approved add: sel].

"SmallInteger, LargeNegativeInteger, LargePositiveInteger"
	#("arithmetic" "bit manipulation" highBit "testing" "comparing" "copying" "converting" "printing" 
"system primitives" digitAt: digitLength 
"private" fromString:radix: ) do: [:sel | Approved add: sel].
	#(digitAt:put: ) do: [:sel | AddAndRemove add: sel].

"Float"
	#("arithmetic"
"mathematical functions" reciprocalFloorLog: reciprocalLogBase2 timesTwoPower:
"comparing" "testing"
"truncation and round off" exponent fractionPart integerPart significand significandAsInteger
"converting" asApproximateFraction asIEEE32BitWord asTrueFraction
"copying") do: [:sel | Approved add: sel].

"Fraction, Random"
	#(denominator numerator reduced next nextValue) do: [:sel | Approved add: sel].
	#(setNumerator:denominator:) do: [:sel | AddAndRemove add: sel].

"Collection"
	#("accessing" anyOne
"testing" includes: includesAllOf: includesAnyOf: includesSubstringAnywhere: isEmpty isSequenceable occurrencesOf:
"enumerating" collect: collect:thenSelect: count: detect: detect:ifNone: detectMax: detectMin: detectSum: inject:into: reject: select: select:thenCollect:
"converting" asBag asCharacterSet asSet asSortedArray asSortedCollection asSortedCollection:
"printing"
"private" maxSize
"arithmetic"
"math functions" average max median min range sum) do: [:sel | Approved add: sel].
	#("adding" add: addAll: addIfNotPresent:
"removing" remove: remove:ifAbsent: removeAll: removeAllFoundIn: removeAllSuchThat: remove:ifAbsent:) do: [:sel | AddAndRemove add: sel].

"SequenceableCollection"
	#("comparing" hasEqualElements:
"accessing" allButFirst allButLast at:ifAbsent: atAll: atPin: atRandom: atWrap: fifth first fourth identityIndexOf: identityIndexOf:ifAbsent: indexOf: indexOf:ifAbsent: indexOf:startingAt:ifAbsent: indexOfSubCollection:startingAt: indexOfSubCollection:startingAt:ifAbsent: last second sixth third
"removing"
"copying" , copyAfterLast: copyAt:put: copyFrom:to: copyReplaceAll:with: copyReplaceFrom:to:with: copyUpTo: copyUpToLast: copyWith: copyWithout: copyWithoutAll: forceTo:paddingWith: shuffled sortBy:
"enumerating" collectWithIndex: findFirst: findLast: pairsCollect: with:collect: withIndexCollect: polynomialEval:
"converting" asArray asDictionary asFloatArray asIntegerArray asStringWithCr asWordArray reversed
"private" copyReplaceAll:with:asTokens: ) do: [:sel | Approved add: sel].
	#( swap:with:) do: [:sel | AddAndRemove add: sel].

"ArrayedCollection, Bag"
	#("private" defaultElement 
"sorting" isSorted
"accessing" cumulativeCounts sortedCounts sortedElements "testing" "adding" add:withOccurrences: "removing" "enumerating" 
	) do: [:sel | Approved add: sel].
	#( mergeSortFrom:to:by: sort sort: add: add:withOccurrences:
"private" setDictionary ) do: [:sel | AddAndRemove add: sel].

"Other messages that modify the receiver"
	#(atAll:put: atAll:putAll: atAllPut: atWrap:put: replaceAll:with: replaceFrom:to:with:  removeFirst removeLast) do: [:sel | AddAndRemove add: sel].

	self initialize2.

"
MethodFinder new initialize.
MethodFinder new organizationFiltered: Set
"

! !
	"Initialize the scripting system.  Sometimes this method is vacuously changed just to get it in a changeset so that its invocation will occur as part of an update"

	(Smalltalk at: #ScriptingSystem ifAbsent: [nil]) ifNil:
		[Smalltalk at: #ScriptingSystem put: self new]

"StandardScriptingSystem initialize"! !
	"Return the (prospective) handler for a mouse down event. The handler is temporarily installed and can be used for morphs further down the hierarchy to negotiate whether the inner or the outer morph should finally handle the event.
	Note: Halos handle blue button events themselves so we will only be asked if there is currently no halo on top of us."
	self wantsHaloFromClick ifFalse:[^nil].
	anEvent handler ifNil:[^self].
	anEvent handler isPlayfieldLike ifTrue:[^self]. "by default exclude playfields"
	(anEvent shiftPressed)
		ifFalse:[^nil] "let outer guy have it"
		ifTrue:[^self] "let me have it"
! !
	"Answer the message-list menu"
	"Changed by emm to include menu-item for breakpoints"

	shifted ifTrue: [^ self shiftedMessageListMenu: aMenu].

	aMenu addList:#(
			('what to show...'			offerWhatToShowMenu)
                	('toggle break on entry'		toggleBreakOnEntry)
            		-
			('browse full (b)' 			browseMethodFull)
			('browse hierarchy (h)'			classHierarchy)
			('browse method (O)'			openSingleMessageBrowser)
			('browse protocol (p)'			browseFullProtocol)
			-
			('fileOut'				fileOutMessage)
			-
			('senders of... (n)'			browseSendersOfMessages)
			('implementors of... (m)'		browseMessages)
			('inheritance (i)'			methodHierarchy)
			('versions (v)'				browseVersions)
			-
			('inst var refs...'			browseInstVarRefs)
			('inst var defs...'			browseInstVarDefs)
			('class var refs...'			browseClassVarRefs)
			('class variables'			browseClassVariables)
			('class refs (N)'			browseClassRefs)
			-
			('remove method (x)'			removeMessage)
			-
			('more...'				shiftedYellowButtonActivity)).
	^ aMenu
! !
	"Unload the receiver from global registries"

	Smalltalk at: #FileList ifPresent: [:cl |
	cl unregisterFileReader: self]! !
	"Allow the user to refine the list of messages."

	| aMenu evt |
	messageList size <= 1 
		ifTrue: [^self inform: 'this is not a propitious filtering situation'].

	"would like to get the evt coming in but thwarted by the setInvokingView: circumlocution"
	evt := self currentWorld activeHand lastEvent.
	aMenu := OldMenuMorph new defaultTarget: self.
	aMenu addTitle: 'Filter by only showing...'.
	aMenu addStayUpItem.
	aMenu 
		addList: #(#('unsent messages' #filterToUnsentMessages 'filter to show only messages that have no senders') #- #('messages that send...' #filterToSendersOf 'filter to show only messages that send a selector I specify') #('messages that do not send...' #filterToNotSendersOf 'filter to show only messages that do not send a selector I specify') #- #('messages whose selector is...' #filterToImplementorsOf 'filter to show only messages with a given selector I specify') #('messages whose selector is NOT...' #filterToNotImplementorsOf 'filter to show only messages whose selector is NOT a seletor I specify') #- #('messages in current change set' #filterToCurrentChangeSet 'filter to show only messages that are in the current change set') #('messages not in current change set' #filterToNotCurrentChangeSet 'filter to show only messages that are not in the current change set') #- #('messages in any change set' #filterToAnyChangeSet 'filter to show only messages that occur in at least one change set') #('messages not in any change set' #filterToNotAnyChangeSet 'filter to show only messages that do not occur in any change set in the system') #- #('messages authored by me' #filterToCurrentAuthor 'filter to show only messages whose authoring stamp has my initials') #('messages not authored by me' #filterToNotCurrentAuthor 'filter to show only messages whose authoring stamp does not have my initials') #- #('messages logged in .changes file' #filterToMessagesInChangesFile 'filter to show only messages whose latest source code is logged in the .changes file') #('messages only in .sources file' #filterToMessagesInSourcesFile 'filter to show only messages whose latest source code is logged in the .sources file') #- #('messages with prior versions' #filterToMessagesWithPriorVersions 'filter to show only messages that have at least one prior version') #('messages without prior versions' #filterToMessagesWithoutPriorVersions 'filter to show only messages that have no prior versions') #- #('uncommented messages' #filterToUncommentedMethods 'filter to show only messages that do not have comments at the beginning') #('commented messages' #filterToCommentedMethods 'fileter to show only messages that have comments at the beginning') #- #('messages that...' #filterToMessagesThat 'let me type in a block taking a class and a selector, which will specify yea or nay concerning which elements should remain in the list')).
	aMenu popUpEvent: evt hand lastEvent in: evt hand world! !
	"Unload the receiver from global registries"

	Smalltalk at: #FileList ifPresent: [:cl |
	cl unregisterFileReader: self]! !