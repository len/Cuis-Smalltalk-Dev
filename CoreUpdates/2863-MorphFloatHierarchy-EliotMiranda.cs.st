SystemChangeNotifier uniqueInstance doSilently:
	[| boxedFloat floatClassVars soonToBeFloat smallFloat |
	boxedFloat := Float.
	floatClassVars := Float classVariablesString.
	soonToBeFloat := Number subclass: #SoonToBeFloat
							instanceVariableNames: ''
							classVariableNames: ''
							poolDictionaries: ''
							category: 'Kernel-Numbers'.
	smallFloat := soonToBeFloat subclass: #SmallFloat64
							instanceVariableNames: ''
							classVariableNames: ''
							poolDictionaries: ''
							category: 'Kernel-Numbers'.
	'!!SoonToBeFloat class methodsFor: ''instance creation'' stamp: ''eem 11/25/2014 07:54''!!
basicNew
	^Float basicNew: 2!! !!
!!SoonToBeFloat class methodsFor: ''instance creation'' stamp: ''eem 11/25/2014 07:54''!!
basicNew: anInteger
	^Float basicNew: 2!! !!' readStream fileIn.

	[soonToBeFloat variableWordSubclass: #Float
							instanceVariableNames: ''
							classVariableNames: floatClassVars
							poolDictionaries: ''
							category: 'Kernel-Numbers']
		on: Error, Warning
		do: [:ex|
			Transcript newLine; nextPutAll: ex messageText; flush.
			ex isResumable ifFalse:
				[Notification adoptInstance: ex].
			ex resume: true].
	soonToBeFloat classPool: Float classPool.
	Float classPool: nil.
	soonToBeFloat
		comment: Float comment asString
		stamp: Float organization commentStamp.
	Float class selectors do:
		[:s|
		(soonToBeFloat class includesSelector: s) ifFalse:
			[soonToBeFloat class recompile: s from: Float class.
			 soonToBeFloat class organization
				classify: s
				under: (Float class organization categoryOfElement: s)]].

	(Float selectors reject: [:s| (Float >> s) primitive between: 40 and: 59]) do:
		[:s|
		 soonToBeFloat recompile: s from: Float.
		 soonToBeFloat organization
			classify: s
			under: (Float organization categoryOfElement: s).
		 Float removeSelector: s].
	[boxedFloat setName: #BoxedFloat64.
	 Smalltalk renameClass: Float from: #Float to: #BoxedFloat64.
	 soonToBeFloat setName: #Float.
	 Smalltalk renameClass: soonToBeFloat from: #SoonToBeFloat to: #Float]
		on: AttemptToWriteReadOnlyGlobal
		do: [:ex| ex resume: true].

	'!!Float class methodsFor: ''instance creation'' stamp: ''eem 11/25/2014 07:54''!!
basicNew
	^BoxedFloat64 basicNew: 2!! !!

!!Float class methodsFor: ''instance creation'' stamp: ''eem 11/25/2014 07:54''!!
basicNew: anInteger
	^BoxedFloat64 basicNew: 2!! !!
!!BoxedFloat64 class methodsFor: ''instance creation'' stamp: ''eem 11/25/2014 07:54''!!
basicNew: sizeRequested 
	"Primitive. Answer an instance of this class with the number
	 of indexable variables specified by the argument, sizeRequested.
	 Fail if this class is not indexable or if the argument is not a
	 positive Integer, or if there is not enough memory available. 
	 Essential. See Object documentation whatIsAPrimitive."

	<primitive: 71>
	sizeRequested isInteger ifTrue:
		[^sizeRequested = 2
			ifTrue: "arg okay; space must be low."
				[OutOfMemory signal.
				 self basicNew: sizeRequested]  "retry if user proceeds"
			ifFalse:
				[self error: ''a Float shall always have two slots'']].
	self primitiveFailed!! !!

!!SmallFloat64 class methodsFor: ''instance creation'' stamp: ''eem 11/25/2014 07:54''!!
basicNew: anInteger
	^self basicNew!! !!
!!SmallFloat64 class methodsFor: ''instance creation'' stamp: ''eem 11/25/2014 07:54''!!
basicNew
	self error: ''SmallFloat64s can only be created by performing arithmetic''!! !!' readStream fileIn.

	boxedFloat class selectors do:
		[:s|
		((#(basicNew basicNew:) includes: s) not
		 and: [soonToBeFloat class includesSelector: s]) ifTrue:
			[boxedFloat class removeSelector: s]].

	{boxedFloat. boxedFloat class. Float. Float class} do:
		[:bfc| | binding |
		binding := bfc binding.
		bfc selectorsAndMethodsDo:
			[:s :m|
			 [m methodClassAssociation: binding]
				on: MessageNotUnderstood
				do: [:ex| m literalAt: m numLiterals put: binding]].
		bfc organization removeEmptyCategories; sortCategories].
	"shrink method dictionaries after removals; rehash does not shrink :-("
	{boxedFloat. boxedFloat class} do:
		[:bfc| | nmd |
		nmd := MethodDictionary new.
		bfc selectorsAndMethodsDo:
			[:s :m| nmd at: s put: m].
		bfc methodDict: nmd].

	"Compile the SmallFloat64 primitives.
	 These have primitive number 500 + the corresponding boxed primitive number"
	boxedFloat selectors do:
		[:s| | code |
		code := (boxedFloat sourceCodeAt: s) asString.
		code := code copyReplaceAll: '<primitive: ' with: '<primitive: 5'.
		smallFloat
			compile: code
			classified: (boxedFloat organization categoryOfElement: s)
			withStamp: 'eem 11/25/2014 07:54'
			notifying: nil].
	smallFloat organization sortCategories.

	boxedFloat comment: 'My instances hold 64-bit Floats in heap objects.  This is the only representation on 32-bit systems.  But on 64-bit systems SmallFloat64 holds a subset of the full 64-bit double-precision range in immediate objects.'
		stamp: 'eem 11/25/2014 07:54'.
	smallFloat comment: 'My instances represent 64-bit Floats whose exponent fits in 8 bits as immediate objects.  This representation is only available on 64-bit systems, not 32-bit systems.'
		stamp: 'eem 11/25/2014 07:54'.

	Undeclared removeUnreferencedKeys]
