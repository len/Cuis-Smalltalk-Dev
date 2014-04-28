'From Squeak3.7 of ''4 September 2004'' [latest update: #5989] on 11 November 2008 at 12:35:52 am'!
	"Part of the tool to track down unwanted pointers into the segment.  Break all owner pointers in submorphs, scripts, and viewers in flaps."

| wld morphs |
wld _ arrayOfRoots detect: [:obj | 
	obj isMorph ifTrue: [obj isWorldMorph] ifFalse: [false]] ifNone: [nil].
wld ifNil: [wld _ arrayOfRoots detect: [:obj | obj isMorph] 
				ifNone: [^ self error: 'can''t find a root morph']].
morphs _ IdentitySet new: 400.
wld allMorphsDo: [ :m |  morphs add: m ].
morphs do: [:mm | 	"break the back pointers"
	mm isInMemory ifTrue: [
	(mm respondsTo: #target) ifTrue: [
		mm nearestOwnerThat: [:ow | ow == mm target 
			ifTrue: [mm target: nil. true]
			ifFalse: [false]]].
	(mm respondsTo: #arguments) ifTrue: [
		mm arguments do: [:arg | arg ifNotNil: [
			mm nearestOwnerThat: [:ow | ow == arg
				ifTrue: [mm arguments at: (mm arguments indexOf: arg) put: nil. true]
				ifFalse: [false]]]]].
	mm eventHandler ifNotNil: ["recipients point back up"
		(morphs includesAllOf: (mm eventHandler allRecipients)) ifTrue: [
			mm eventHandler: nil]].
	"temporary, until using Model for PartsBin"
	(mm isMorphicModel) ifTrue: [
		(mm model isMorphicModel) ifTrue: [
			mm model breakDependents]].
	(mm isTextMorph) ifTrue: [mm setContainer: nil]]].
(Smalltalk includesKey: #Owners) ifTrue: [Smalltalk at: #Owners put: nil].
	"in case findOwnerMap: is commented out"
"self findOwnerMap: morphs."
morphs do: [:mm | 	"break the back pointers"
	mm isInMemory ifTrue: [mm privateOwner: nil]].
"more in extensions?"

! !
	"Handle a mouse down event."
	| grabbedMorph handHadHalos handler |
	grabbedMorph _ self morphToGrab: evt.
	grabbedMorph ifNotNil:[
		grabbedMorph isSticky ifTrue:[^self].
		^evt hand grabMorph: grabbedMorph].

	handHadHalos _ evt hand halo notNil.
	evt hand halo: nil. "shake off halos"
	evt hand releaseKeyboardFocus. "shake of keyboard foci"
	evt shiftPressed ifTrue:[
		^evt hand 
			waitForClicksOrDrag: self 
			event: evt 
			selectors: { #findWindow:. nil. nil. #dragThroughOnDesktop:}
			threshold: 5].
	self isWorldMorph ifTrue: [
		handHadHalos ifTrue: [^self addAlarm: #invokeWorldMenu: with: evt after: 200].
		^self invokeWorldMenu: evt
	].
	"otherwise, explicitly ignore the event if we're not the world,
	so that we could be picked up if need be"
	self isWorldMorph ifFalse:[evt wasHandled: false].
! !
	"Put up the world menu, triggered by the passed-in event.
	Perhaps a good place to disable it if needed"

	self putUpWorldMenu: evt! !
	"Bring me to the front and make me able to respond to mouse and keyboard"

	"Bring me to the front and make me able to respond to mouse and keyboard"

	| oldTop |
	self owner 
		ifNil: [^self	"avoid spurious activate when drop in trash"].
	oldTop := TopWindow.
	TopWindow := self.
	oldTop ifNotNil: [
	self owner firstSubmorph == self 
		ifFalse: [
			"Bring me (with any flex) to the top if not already"
			self owner addMorphFront: self].
	labelArea ifNotNil:  [
			self setStripeColorsFrom: self paneColorToUse].
	self isCollapsed 
		ifFalse: [
			model modelWakeUpIn: self.
			self positionSubmorphs.
			labelArea ifNil: [self adjustBorderUponActivationWhenLabeless]]! !
	"System level event handling."

	anEvent wasHandled ifTrue:[^self].
	self handlesKeyboard ifFalse:	[^ self].
	anEvent wasHandled: true.
	self keyStroke: anEvent! !