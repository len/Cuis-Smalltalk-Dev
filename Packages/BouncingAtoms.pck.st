'From Cuis 4.2 of 25 July 2013 [latest update: #2390] on 27 June 2015 at 3:24:53.754316 pm'!
'Description A port of Bouncing Atoms with the atoms in a SystemWindow. A pop-up menu enables selection of options, including an active plot of infection history, also in a SystemWindow.'!
!provides: 'BouncingAtoms' 1 8!
!classDefinition: #AtomMorph category: #BouncingAtoms!
EllipseMorph subclass: #AtomMorph
	instanceVariableNames: 'velocity'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BouncingAtoms'!
!classDefinition: 'AtomMorph class' category: #BouncingAtoms!
AtomMorph class
	instanceVariableNames: ''!

!classDefinition: #HeaterCoolerAtom category: #BouncingAtoms!
AtomMorph subclass: #HeaterCoolerAtom
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BouncingAtoms'!
!classDefinition: 'HeaterCoolerAtom class' category: #BouncingAtoms!
HeaterCoolerAtom class
	instanceVariableNames: ''!

!classDefinition: #BouncingAtomsMorph category: #BouncingAtoms!
RectangleLikeMorph subclass: #BouncingAtomsMorph
	instanceVariableNames: 'infectionHistory transmitInfection recentTemperatures temperature historyWindow nAtoms'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BouncingAtoms'!
!classDefinition: 'BouncingAtomsMorph class' category: #BouncingAtoms!
BouncingAtomsMorph class
	instanceVariableNames: ''!

!classDefinition: #GraphMorph category: #BouncingAtoms!
FunctionGraphMorph subclass: #GraphMorph
	instanceVariableNames: 'data points yScaleFactor'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BouncingAtoms'!
!classDefinition: 'GraphMorph class' category: #BouncingAtoms!
GraphMorph class
	instanceVariableNames: ''!


!AtomMorph commentStamp: '<historical>' prior: 0!
AtomMorph represents an atom used in the simulation of
an ideal gas. It's container is typically a BouncingAtomsMorph.

Try:

	BouncingAtomsMorph  new

to open the gas simulation or:

	AtomMorph example

to open an instance in the current world!

!BouncingAtomsMorph commentStamp: 'dhn 6/3/2015 16:20' prior: 0!
This morph shows how an ideal gas simulation might work. When it gets step messages, it makes all its atom submorphs move along their velocity vectors, bouncing when they hit a wall. It also exercises the Morphic damage reporting and display architecture. Here are some things to try:

  1. Resize this morph as the atoms bounce around.
  2. Use the pop-up menu, try the available choices.
  3. Switch the shape of atoms from ellipse to rectangle.
  4. Start an infection.
  5. Show infection history.
  6. Start another infection with the history window open.
  7. Set the atom count morph size for a low density of atoms. Start an infection.
     Quickly add a Heater/Cooler Atom with a velocity change factor.
     Note the effect on atoms passing over it.
!

!GraphMorph commentStamp: '<historical>' prior: 0!
Normalize points in a collection, plot them in a graph, with lines drawn between them.!

!AtomMorph methodsFor: 'private' stamp: 'jm 8/10/1998 17:40'!
bounceIn: aRect
	"Move this atom one step along its velocity vector and make it bounce if it goes outside the given rectangle. Return true if it is bounced."

	| p vx vy px py bounced |
	p := self morphPosition.		"dhn 4/4/2015"
	vx := velocity x.		vy := velocity y.
	px := p x + vx.		py := p y + vy.
	bounced := false.
	px > aRect right ifTrue: [
		px := aRect right - (px - aRect right).
		vx := velocity x negated.
		bounced := true].
	py > aRect bottom ifTrue: [
		py :=  aRect bottom - (py - aRect bottom).
		vy := velocity y negated.
		bounced := true].
	px < aRect left ifTrue: [
		px := aRect left - (px - aRect left).
		vx := velocity x negated.
		bounced := true].
	py < aRect top ifTrue: [
		py :=  aRect top - (py - aRect top).
		vy := velocity y negated.
		bounced := true].
	self morphPosition: px @ py.	"dhn 4/4/2015"
	bounced ifTrue: [self velocity: vx @ vy].
	^ bounced
! !

!AtomMorph methodsFor: 'initialization' stamp: 'dgd 3/7/2003 14:13'!
defaultBorderWidth
"answer the default border width for the receiver"
	^ 0! !

!AtomMorph methodsFor: 'initialization' stamp: 'dgd 3/7/2003 14:13'!
defaultColor
"answer the default color/fill style for the receiver"
	^ Color blue! !

!AtomMorph methodsFor: 'drawing' stamp: 'jmv 6/16/2015 10:02'!
drawOn: aCanvas
	"Note: Set 'drawAsRect' to true to make the atoms draw faster. When testing the speed of other aspects of Morphic, such as its damage handling efficiency for large numbers of atoms, it is useful to make drawing faster."

	| drawAsRect |
	drawAsRect _ owner valueOfProperty: #drawAsRect.
	drawAsRect 
		ifNil: [super drawOn: aCanvas]
		ifNotNil: [
			drawAsRect 	"rectangles are faster to draw"
				ifTrue: [aCanvas fillRectangle: self morphLocalBounds color: color]
				ifFalse: [super drawOn: aCanvas]]! !

!AtomMorph methodsFor: 'accessing'!
infected

	^ color = Color red! !

!AtomMorph methodsFor: 'accessing' stamp: 'dhn 6/3/2015 17:57'!
infected: aBoolean

	(self valueOfProperty: #velocityDelta) ifNil: [
		aBoolean
			ifTrue: [self color: Color red]
			ifFalse: [self color: Color blue]]! !

!AtomMorph methodsFor: 'initialization' stamp: 'jmv 6/16/2015 09:58'!
initialize
	"Make a new atom with a random position and velocity."
	super initialize.
""
	self morphExtent: 8 @ 7.
	self
		randomPositionIn: (0 @ 0 corner: 300 @ 300)
		maxVelocity: 10! !

!AtomMorph methodsFor: 'initialization' stamp: 'jmv 6/16/2015 09:57'!
randomPositionIn: aRectangle maxVelocity: maxVelocity
	"Give this atom a random position and velocity."

	| origin xtent |
	origin := aRectangle origin.
	xtent := (aRectangle extent - self morphExtent) rounded.
	self morphPosition:		"dhn 4/4/2015"
		(origin x + xtent x atRandom) @
		(origin y + xtent y atRandom).
	velocity :=
		(maxVelocity - (2 * maxVelocity) atRandom) @
		(maxVelocity - (2 * maxVelocity) atRandom).
! !

!AtomMorph methodsFor: 'accessing'!
velocity

	^ velocity! !

!AtomMorph methodsFor: 'accessing'!
velocity: newVelocity

	velocity := newVelocity.! !

!AtomMorph class methodsFor: 'examples' stamp: 'dhn 4/4/2015 17:41'!
example
	"
	AtomMorph example
	"
	|a b|
	a _ AtomMorph new openInWorld. 
	a color: Color random.
	b _ Display boundingBox.
 	[1000 timesRepeat:  [a bounceIn: b.  (Delay forMilliseconds: 20) wait]. 
	 a delete] fork.! !

!AtomMorph class methodsFor: 'new-morph participation' stamp: 'di 6/22/97 09:07'!
includeInNewMorphMenu
	"Not to be instantiated from the menu"
	^ false! !

!HeaterCoolerAtom methodsFor: 'private' stamp: 'dhn 6/17/2015 10:59'!
bounceIn: aRect

	^ super bounceIn: aRect
! !

!HeaterCoolerAtom methodsFor: 'initialization' stamp: 'dhn 6/3/2015 16:14'!
defaultColor
	"Set the color of the receiver based on property #velocityDelta"
	
	self valueOfProperty: #velocityDelta ifPresentDo: [:x |
	x < 0
		ifTrue: [^ Color lightGray]
		ifFalse: [^ Color pink]]! !

!HeaterCoolerAtom methodsFor: 'drawing' stamp: 'dhn 6/17/2015 18:02'!
drawOn: aCanvas

	super drawOn: aCanvas! !

!HeaterCoolerAtom methodsFor: 'initialization' stamp: 'dhn 6/4/2015 12:21'!
initialize
	| f x |
	f _ FillInTheBlankMorph
		request: '-100 < factor < 100 % Cooler/Hotter' 
		initialAnswer: '-10'.
	x _ f asNumber.
	(x > -100 and: x < 100) 
		ifTrue: [self setProperty: #velocityDelta toValue: x]
		ifFalse: [self setProperty: #velocityDelta toValue: 0].
	super initialize.
! !

!BouncingAtomsMorph methodsFor: 'other' stamp: 'jmv 6/16/2015 10:02'!
addAtoms: n
	"Add a bunch of new atoms."

	nAtoms _ n.
	n timesRepeat: [
		| a |
		a _ AtomMorph new.
		self addMorph: a.
		a randomPositionIn: self morphLocalBounds maxVelocity: 10.].
	historyWindow ifNotNil: [historyWindow yScaleFactor: n].
	self stopStepping.
! !

!BouncingAtomsMorph methodsFor: 'submorphs-add/remove'!
addMorphFront: aMorph
	"Called by the 'embed' meta action. We want non-atoms to go to the back."
	"Note: A user would not be expected to write this method. However, a sufficiently advanced user (e.g, an e-toy author) might do something equivalent by overridding the drag-n-drop messages when they are implemented."

	(aMorph isMemberOf: AtomMorph)
		ifTrue: [super addMorphFront: aMorph]
		ifFalse: [super addMorphBack: aMorph].! !

!BouncingAtomsMorph methodsFor: 'other' stamp: 'dhn 6/4/2015 11:58'!
collisionPairs
	"Return a list of pairs of colliding atoms, which are assumed to be
circles of known radius. This version uses the morph's positions--i.e.
the top-left of their bounds rectangles--rather than their centers."

	| count sortedAtoms radius twoRadii radiiSquared collisions p1 continue j p2 distSquared m1 m2 |
	count := submorphs size.
	sortedAtoms := submorphs 
				asSortedCollection: [:mt1 :mt2 | mt1 morphPosition x < mt2 morphPosition x].
	radius := 8.
	twoRadii := 2 * radius.
	radiiSquared := radius squared * 2.
	collisions := OrderedCollection new.
	1 to: count - 1
		do: 
			[:i | 
			m1 := sortedAtoms at: i.
			p1 := m1 morphPosition.
			continue := (j := i + 1) <= count.
			[continue] whileTrue: 
					[m2 := sortedAtoms at: j.
					p2 := m2 morphPosition.
					continue := p2 x - p1 x <= twoRadii  
								ifTrue: 
									[distSquared := (p1 x - p2 x) squared + (p1 y - p2 y) squared.
									distSquared < radiiSquared 
										ifTrue: [
											collisions add: (Array with: m1 with: m2).
											m1 valueOfProperty: #velocityDelta ifPresentDo: [:x |
												m2 velocity:  m2 velocity * (100 + x) / 100.0].
											m2 valueOfProperty: #velocityDelta ifPresentDo: [:x |
												m1 velocity:  m1 velocity * (100 + x) / 100.0]].
									(j := j + 1) <= count]
								ifFalse: [false]]].
	^collisions! !

!BouncingAtomsMorph methodsFor: 'initialization' stamp: 'dgd 3/7/2003 14:14'!
defaultColor
"answer the default color/fill style for the receiver"
	^ Color
		r: 0.8
		g: 1.0
		b: 0.8! !

!BouncingAtomsMorph methodsFor: 'menu' stamp: 'dhn 5/20/2015 11:08'!
drawAsRect
	"Toggle the #drawAsRect property"
	self 
		setProperty: #drawAsRect 
		toValue: (self valueOfProperty: #drawAsRect) not
! !

!BouncingAtomsMorph methodsFor: 'menu' stamp: 'dhn 4/23/2015 18:05'!
handlesMouseDown: aMouseButtonEvent
	^ true! !

!BouncingAtomsMorph methodsFor: 'initialization' stamp: 'dhn 5/27/2015 19:45'!
initialize
	"initialize the state of the receiver"
	| win |
	super initialize.
	self reset.
	win _ self embeddedInMorphicWindowLabeled: 'Bouncing Atoms'.
	win 	setProperty: #minimumExtent toValue: 88@85.
	self setProperty: #drawAsRect toValue: false.
	win model: self.
	win openInWorld.
	win owner doOneCycleNow.
	self addAtoms: 30.
	self when: #morphicStep evaluate: [ :v | self step].
	self startSteppingStepTime: 20

! !

!BouncingAtomsMorph methodsFor: 'menu' stamp: 'dhn 6/27/2015 14:50'!
installHeaterCooler
	"Replace an atom with a heater/cooler atom"
	| a x |

	x _ self submorphs at: self submorphs size atRandom.
	x delete.	"Take away an atom"
	nAtoms _ nAtoms - 1.

	a _ HeaterCoolerAtom new.
	a randomPositionIn: self morphLocalBounds maxVelocity: 10.
	{(a valueOfProperty: #velocityDelta) < 0} print.
	self addMorph: a.	"Add an atom"
! !

!BouncingAtomsMorph methodsFor: 'menu' stamp: 'dhn 6/2/2015 20:16'!
mouseButton2Activity
	"Show a pop-up menu"
	| tuples list index |
	tuples _ #(
		('Set Atom Count...'				#setAtomCount)
		('Start Infection'				#startInfection)
		('Show Infection History'		#showInfectionHistory)
		('Toggle Atom as Rectangle'	#drawAsRect)
		('Heater/Cooler Atom'			#installHeaterCooler)
	).
	list _ tuples collect: [:ea | ea first].
	index _ (PopUpMenu labelArray: list) 
		startUpWithCaption: 'Bouncing Atoms'.
	index > 0 ifTrue: [self perform: ((tuples at: index) at: 2)]
! !

!BouncingAtomsMorph methodsFor: 'other' stamp: 'dhn 6/27/2015 15:10'!
reportInfection

	| count |
	self collisionPairs do: [:pair | | infected |
		infected := false.
		pair do: [:atom | atom infected ifTrue: [infected := true]].
		infected
			ifTrue: [pair do: [:atom | atom infected: true]]].

	count := 0.
	self submorphsDo: [:m | m infected ifTrue: [count := count + 1]].
	count > 0 ifTrue: [infectionHistory addLast: count].
	historyWindow ifNotNil: [
		historyWindow 
			data: infectionHistory;
			yScaleFactor: nAtoms;
			update: #redraw].
	count = nAtoms ifTrue: [
		transmitInfection := false.
		self stopStepping].
! !

!BouncingAtomsMorph methodsFor: 'initialization' stamp: 'jmv 6/16/2015 09:58'!
reset
	infectionHistory := OrderedCollection new: 500.
	infectionHistory add: 0.
	transmitInfection _ false.
! !

!BouncingAtomsMorph methodsFor: 'menu' stamp: 'dhn 4/18/2015 17:04'!
setAtomCount

	| countString count |
	countString _ FillInTheBlankMorph 
		request: 'Number of atoms?' 
		initialAnswer: self submorphCount printString.
	countString isEmpty ifTrue: [^ self].
	self removeAllMorphs.
	count _ countString asInteger.
	self addAtoms: count.
	self reset.
	self startSteppingStepTime: 20.
! !

!BouncingAtomsMorph methodsFor: 'menu' stamp: 'dhn 5/26/2015 19:49'!
showInfectionHistory
	"Show a graph of the infection history"
	historyWindow _ GraphMorph new.
	historyWindow 
		data: infectionHistory;
		yScaleFactor: nAtoms;
		domain: (-0.8 to: 11);
		update: #redraw.
	(historyWindow embeddedInMorphicWindowLabeled: 'Infection History') openInWorld
! !

!BouncingAtomsMorph methodsFor: 'menu' stamp: 'dhn 6/2/2015 19:49'!
startInfection

	self submorphsDo: [:m | m infected: false].
	(self submorphs at: self submorphs size atRandom) infected: true.
	infectionHistory := OrderedCollection new: 500.
	infectionHistory add: 0.
	transmitInfection := true.
	self startStepping.
! !

!BouncingAtomsMorph methodsFor: 'stepping and presenter' stamp: 'dhn 6/17/2015 18:08'!
step
	"Bounce those atoms!!"

	| r bounces |
	bounces := 0.
	r := 0@0 corner: (self morphExtent - (8@8)).
	self submorphsDo: [ :m |
		(m isKindOf: AtomMorph) ifTrue: [
			(m bounceIn: r) ifTrue: [bounces := bounces + 1]]].
	"compute a 'temperature' that is proportional to the number of bounces
	 divided by the circumference of the enclosing rectangle"
	self updateTemperature: (10000.0 * bounces) / (r width + r height).
	transmitInfection ifTrue: [self reportInfection].
! !

!BouncingAtomsMorph methodsFor: 'testing' stamp: 'dhn 4/16/2015 13:03'!
stepTime
	"As fast as possible."
	"^ 0  entirely too fast"
	^ 20.	"let's try this"
! !

!BouncingAtomsMorph methodsFor: 'other' stamp: 'dhn 5/26/2015 19:40'!
transmitInfection

	| count |
	self collisionPairs do: [:pair | | infected |
		infected := false.
		pair do: [:atom | atom infected ifTrue: [infected := true]].
		infected
			ifTrue: [pair do: [:atom | atom infected: true]]].

	count := 0.
	self submorphsDo: [:m | m infected ifTrue: [count := count + 1]].
	{count. infectionHistory size.} print.
	count > 0 ifTrue: [infectionHistory addLast: count].
	historyWindow ifNotNil: [
		historyWindow 
			data: infectionHistory;
			yScaleFactor: nAtoms;
			update: #redraw].
	count = submorphs size ifTrue: [
		transmitInfection := false.
		self stopStepping].
! !

!BouncingAtomsMorph methodsFor: 'other' stamp: 'dgd 2/22/2003 13:36'!
updateTemperature: currentTemperature 
	"Record the current temperature, which is taken to be the number of atoms that have bounced in the last cycle. To avoid too much jitter in the reading, the last several readings are averaged."

	recentTemperatures isNil 
		ifTrue: 
			[recentTemperatures := OrderedCollection new.
			20 timesRepeat: [recentTemperatures add: 0]].
	recentTemperatures removeLast.
	recentTemperatures addFirst: currentTemperature.
	temperature := recentTemperatures sum asFloat / recentTemperatures size! !

!BouncingAtomsMorph methodsFor: 'other' stamp: 'dhn 6/3/2015 13:25'!
velocityChange: atom1 and: atom2
	! !

!BouncingAtomsMorph class methodsFor: 'as yet unclassified' stamp: 'dhn 4/18/2015 15:52'!
how
"
	BouncingAtomsMorph new.
"! !

!BouncingAtomsMorph class methodsFor: 'as yet unclassified' stamp: 'dhn 6/17/2015 11:25'!
includeInNewMorphMenu
	"Not to be instantiated from the menu"
	^ false! !

!GraphMorph methodsFor: 'drawing' stamp: 'dhn 5/26/2015 20:12'!
asNormalizedPoints: aCollection
	"Answer an array of points which are mapped on [0, T] in both dimensions, where T is a multiple of 10"
	| yArray yFactor xArray xFactor result |
	yFactor _ 10 raisedTo: yMax log asInteger.
	yArray _ yFactor * (self normalize: aCollection asOrderedCollection with: yScaleFactor).
	xFactor _ 10 raisedTo: xMax log asInteger.
	xArray _ xFactor * (self normalize: (0 to: aCollection size) asArray).
	result _ OrderedCollection new.
	1
		to: yArray size
		do: [ :i |
			result add: (xArray at: i) @ (yArray at: i) ].
	^ result.! !

!GraphMorph methodsFor: 'accessing' stamp: 'dhn 5/6/2015 09:33'!
color: aColor

	super color: aColor.
! !

!GraphMorph methodsFor: 'accessing' stamp: 'dhn 5/23/2015 16:09'!
data: aCollection

	data _ aCollection
! !

!GraphMorph methodsFor: 'drawing' stamp: 'dhn 5/29/2015 18:21'!
drawOn: aCanvas
	| fully |
	fully _ 10 raisedTo: yMax log asInteger.

	aCanvas line: (self toMorphic:0@yMin) to: (self toMorphic: 0 @ yMax) width: 2 color: Color lightGray.
	aCanvas line: (self toMorphic: xMin@0) to: (self toMorphic: xMax@0) width: 2 color: Color lightGray.
	aCanvas line: (self toMorphic: 0@fully) to: (self toMorphic: xMax@fully) width: 2 color: Color lightRed.

	points ifNotNil: [
		1 to: points size - 1 do: [:n |
			aCanvas line: (self toMorphic: (points at: n)) to: (self toMorphic: (points at: n + 1)) width: 2 color: Color black]]! !

!GraphMorph methodsFor: 'initialization' stamp: 'dhn 5/23/2015 16:02'!
initialize

	super initialize
! !

!GraphMorph methodsFor: 'drawing' stamp: 'dhn 5/23/2015 11:50'!
normalize: aCollection
	"Answer aCollection divided by its maximum"
	| max |
	max _ aCollection inject: 0 into: [:a :c | (a > c)
		ifTrue: [a]
		ifFalse: [c]].
	^ OrderedCollection new
		addAll: aCollection / (max * 1.0)! !

!GraphMorph methodsFor: 'drawing' stamp: 'dhn 5/26/2015 20:09'!
normalize: aCollection with: aFactor
	"Answer aCollection divided by its maximum and scaled by maximum/aFactor"
	| max |
	max _ aCollection inject: 0 into: [:a :c | (a > c)
		ifTrue: [a]
		ifFalse: [c]].
	^ OrderedCollection new
		addAll: (aCollection / (max * 1.0)) * (max / aFactor)! !

!GraphMorph methodsFor: 'drawing' stamp: 'dhn 5/26/2015 12:18'!
update: aSymbol
	"Re-normalize data if parameter = #redraw"
	super update: aSymbol.
	(aSymbol == #redraw and: (data size > 1)) ifTrue: [points _ self asNormalizedPoints: data]
! !

!GraphMorph methodsFor: 'accessing' stamp: 'dhn 5/26/2015 12:25'!
yScaleFactor: aNumber

	yScaleFactor _ aNumber
! !