; demo texts/scrollys etc.

;****************** UPPER SCROLLY *********************
chartext LABEL BYTE
	;0=end of text 
	db	"                                   "
        db      "                                   "
        db      "                                   "
	db	"BEWARE!     INCOMING ANOTHER BORING SCROLLY! "
	db	"LUCKILY IT IS FROM THE FUTURE CREW, SO YOU "
	db	"HAVE A CHANCE OF SURVIVAL...     OK, WANNA KNOW "
	db	"WHAT THIS DEMO IS CALLED? IF SO, TAKE A GLANCE "
	db	"DOWNWARDS!",1
	db	"                              "
	db	"WELL, THIS SCROLLY IS WHERE ALL "
	db	"THE CRAP GOES... SO IF YOU WANT TO LEARN SOMETHING "
	db	"INTERESTING, LOWER YOUR EYES ABOUT FIFTY PIXELS!",1
	db	"                              "
	db	"SO, WHERE IS THIS DEMO FROM? NATURALLY FROM "
	db	"======###========   "
	db	"GOT IT? IF YOU DID NOT, DOES FINLAND RING A BELL? "
	db	"WELL, THE NICE FLAGGY WILL MAKE A REAPPEARANCE TOO "
	db	"SO DO NOT WORRY IF YOU MISSED IT..."
	db	"               "
        db      "ANYWAY, THERE SHOULD BE CRAP IN THIS SCROLLY, "
	db	"GOTTA THINK OF SOMETHING... YEAH, THE "
	db	"STANDARD GREETINGS: "
	db	"                              "
	db	"WERE YOU INCLUDED? WELL, JUST KEEPING UP THE CRAP-STANDARD, "
	db	"HERE ARE THE ACTUAL GREETINGS: "
	db	"                              "
	db	"WAS NOT FUNNY ON THE SECOND TIME WAS IT? WELL, LETS ROLL "
	db	"IT AGAIN. GREETINGS GOES TO, IN ALPHABETICAL ORDER:   "
        db      "BINARYHEART,  "
	db	"GREMLINS,  "
	db	"SPACEPIGS,  "
	db	"THG,  "
	db	"TIME WARRIORS,  "
	db	"TRSI AND TDT,  "
	db	"ULTRA FORCE,  "
	db	"AND TO EVERYBODY WORTH THEM!     "
        db      "SOME OF THOSE TEAMS WHAT WE GREETED ARE THERE BECAUSE "
        db      "WE THINK THEY HAVE RELEASED SOME GREAT STUFF! THE OTHERS "
	db	"ARE THERE JUST BECAUSE... YA KNOW..."
	db	"               "
        db      "OH YEAH, A MESSAGE TO BCG OF SORCERERS...        "
        db      "NOT FC NOR ITS MEMBERS ARE DEAD AS YOU CAN SEE... "
	db	"WE ARE ALL LIVE AND WELL!     "
	db	"YOU SHOULD NOT SPREAD RUMORS BASED ON YOUR OWN "
	db	"LIMITED KNOWLEDGE. HOPE YOU GOT THAT!"
	db	"               "
        db      "THEN SOME SPECIAL AND PERSONAL GREETZ FROM ICE TO: "
        db      "ALL ESTONIANS, ESPECIALLY TO ONE NAMED TANEL: I "
	db	"HOPE THAT WE CAN SOMEDAY AGAIN GET A GOOD "
        db      "MODEM CONNECTION!     "
	db	"JAN VEGAR VEISETH, STILL IN THE ARMY?     "
        db      "MICHAEL HEMBO, KEEP UP THE GOOD WORK! I HOPE THAT OUR "
	db	"SOUND CONFERENCING WILL GROW WORLDWIDE SOON     "
        db      "SCOTT DUDLEY FOR ANSWERING MY FUNNY MESSAGES ABOUT HIS "
	db	"BBS SOFTWARE     "
        db      "BINARYHEART!  B I G SORRY THAT I MESSED THINGS UP BUT I "
	db	"HOPE THAT YOU CAN CONTACT ME AGAIN NOW AND WE CAN REALLY "
	db	"GET INTO BUSINESS! AND THIS TIME I REALLY MEAN IT!!!     "
	db	"               "
        db      "SORRY IF I FORGOT SOMEONE BUT I AM GETTING VERY TIRED NOW "
	db	"AND MY WRITING AND THINKING IS NOT UP TO ITS USUAL "
	db	"HIGH STANDARDS... THIS IS THE BEST I CAN DO AT THIS TIME "
	db	"OF THE NIGHT!     "
        db      "THAT WAS THE END OF THE SPECIAL GREETINGS... "
	db	"               "
        db      "HMM. I SUPPOSE YOU ALL WANT TO HEAR SOME TECHNICAL THINGS "
        db      "ABOUT THIS DEMO?"
	db	"               "
        db      "WELL, THE SCROLLY IS ABOUT SEVENTY PIXELS BIG... "
	db	"WE FIRST THOUGHT A TWO HUNDRED PIXEL SCROLLY WOULD BE NICE, "
	db	"BUT THEN WE THOUGHT SOMETHING ELSE IN THE DEMO MIGHT BE "
	db	"NICE TOO... SO WE HAD TO LIMIT THE SCROLLY A BIT. WELL, IT "
	db	"STILL TAKES NEARLY FIVE SCAN LINES, GOTTA GET PSI TO OPTIMIZE "
	db	"IT..."
	db	"               "
	db	"BY THE WAY, THE LOGOS IN THE MIDDLE ARE DRAWN BY PSI"
	db	"AND NOT BY DR.VENKMAN WHO HAS DRAWN THE FONTS..."
	db	"               "
        db      "THE STARFIELD IS SIMPLE BUT IF YOU LOOK IT CLOSER "
        db      "YOU WILL NOTICE THAT IT DOES NOT GO LIKE A NORMAL ONE! "
        db      "IT HAS SOME LITTLE SINUS THINGS IN IT TOO.. I THINK "
        db      "ITS FUNNY.. BTW THERE IS A SPECIAL WONDERKEY IN THIS "
        db      "PROGRAM WHICH WILL ADJUST THE DRUNKEN STARS EFFECT... "
        db      "HEHEH.. HAVE FUN SEEKING IT, OR GET THE SOURCE CODE "
	db	"FROM OUR BBS AND CHECK IT FROM THERE ... THAT EFFECT IS "
	db	"QUITE SIMPLE BUT NICE ANYWAY..."
	db	"               "
        db      "ANYWAY I THINK THIS IS THE MOST BRILLIANT PIECE OF CRAP "
        db      "WE HAVE MANAGED TO PUT UP! "
        db      "USUALLY OUR PROJECTS GO DOWN BECAUSE OF THE LIMITED TIME "
	db	"RESOURCES. WE DO HAVE DOZENS OF NEAT ROUTINES, BUT NO TIME "
	db	"TO INTEGRATE THEM INTO A DEMO...    "
        db      "JUST TO WARM YOU UP FOR OUR FUTURE RELEASES WE SHOULD HAVE "
	db	"THINGS LIKE "
        db      "THREE DIMENSIONAL FILLED VECTORGRAPHICS WITH INCONVEX, "
	db	"SPECIAL THINGS, "
        db      "REALLY !FAST! VECTOR BALLS, "
        db      "SOME NICE BITMAP EFFECTS AND LOTS OF OTHERS "
	db	"ALL WITH VGA AND SB... "
	db	"               "
	db	"WE HOPE YOU CAN MAKE NICE DEMOS AS WELL, WITH OR WITHOUT "
	db	"THE HELP OF THE SOURCE CODE WE ARE RELEASING, THE INFO IS "
	db	"IN THE LOWER SCROLLY. IF YOU USE OUR CODE, "
        db      "DO NOT BE SO LAME AND IDIOTIC THAT YOU SIMPLY "
        db      "RIP MOST OF THE CODE AND CHANGE THE GRAPHICS AND MUSIC "
        db      "AND DO NOTHING ELSE! ADD SOME OF YOUR OWN EFFECTS AND "
        db      "EXPERIMENT WITH THE CODE! BE CREATIVE!    "
	db	"WITH ALL THE SOURCE RELEASED WITH THE STMIK YOU "
	db	"SHOULD HAVE NO TROUBLES MAKING A GREAT DEMO WITH "
	db	"VGA AND SOUNDBLASTER SUPPORT AND FOUR CHANNEL MUSICS! "
	db	"JUST REMEMBER TO GIVE US THE CREDITS AND GREETINGS WE "
	db	"DESERVE..."
	db	"               "
        db      "RIGHT NOW I AM REALLY BORED OF WRITING THIS SCROLLY AND I "
        db      "THINK IT IS TIME TO SWITCH TO THE LOWER TEXT BECAUSE AT "
	db	"THIS TIME OF NIGHT... OR IS IT MORNING BECAUSE I CAN SEE "
	db	"THE SUN COMING UP... I WILL NOT GUARANTEE WHAT "
        db      "KIND OF BIZARRE TEXTS WILL APPEAR ACCIDENTALLY IN HERE. "
	db	"HUH.. I THINK I WILL JUST REPEAT THE WHOLE THING!..    "
	db	"HAVE FUN AND DRINK COKE... OR WHATEVER... AT LEAST I WAS "
	db	"DOING IT WHILE WRITING THIS SCROLLTEXT...     "
        db      "A FINAL WORD TO OUR GFX MAKER: NEXT TIME PUT SOME SMILEYS IN "
	db	"YOUR FONTS.. I AM JUST USED TO THEM AND I SEEM NOT TO GET "
	db	"RID OF THOSE DARN CHARACTERS..."
	db	"               "
        db      "ICE OF FC LOGGING OUT..."
        db      "                                                           ",0
	
;****************** LOWER SCROLLY *********************

wrtext	LABEL BYTE
	;0=restart text
	;1=wait for screen clearance
	;2=center following line (till 13)
	;3=wait till mark
	;10=reverse enter
	;13=enter
	db	3,3
wrtextinit LABEL BYTE
        db      2,'HEY, I THINK',13
        db      2,'THE REAL INFO',13
        db      2,'IS RIGHT HERE!',13,1

	db	13
        db      2,'ARE YOU READY?',13,1

	db	13
        db      2,'GOOD, LETS START...',13,1

	db	13
        db      2,'HI YOU OUT THERE!',13,1

        db      2,'THE GREETINGS',13
        db      2,'AND OTHER CHAT',13
        db      2,'IS IN THE',13
        db      2,'UPPER SCROLLY...',13,1

	db	13
        db      2,'SO SWITCH TO THERE',13
        db      2,'IF YOU LIKE THEM...',13,1

        db      2,'OK, LETS CUT THE',13
        db      2,'CRAP AND BEGIN OUR ',13
	db	2,'INFORMATIVE',13
        db      2,'MESSAGES!',13,1

	db	13
        db      2,'FIRST THE FLAG',13
        db      2,'OF OUR COUNTRY',13,1

        db      2,'AND THIS IS NOT ANY',13
        db      2,'DAMN PATRIOTISM,',13
        db      2,'WE PRESENT IT',13
        db      2,'JUST FOR FUN!',13,1

        db      2,'yybbyyyy',13
	db	2,'bbbbbbbb',13
	db	2,'yybbyyyy',13
        db      2,'UUPS!, FIXING...',13,10,10,10,10
	db	2,'wwbbwwww',13
	db	2,'bbbbbbbb',13
        db      2,'wwbbwwww',13,1

        db      2,'HEYY! WHAT WAS',13
        db      2,'THAT!? ROLL IT',13
        db      2,'ONCE MORE!',13,1

        db      2,'wwbbwwww',13
	db	2,'bbbbbbbb',13
        db      2,'wwbbwwww',13
        db      2,'THAT IS FINLAND!',13,1

        db      2,'FEEL FEEL',13
        db      2,'TO ASK TO',13,1
        db      2,'JOIN OUR SUPERB',13
        db      2,'TEAM...',13,1
	
	db	2,'...IF YOU THINK',13
        db      2,'YOU HAVE THE SKILLS',13
        db      2,'FOR PERFECTION!',13,1

	db	2,'OK, TIME TO',13
	db	2,'TELL YOU HOW',13
	db	2,'TO CONTACT FC!',13
	db	2,'JUST TAKE A PICK:',13,1
	
	db	2,'THE FASTEST WAY IS',13
	db	2,'TO CALL OUR BBS:',13
	db	2,'SILICON DRAGON!',13
	db	2,'HERE IS THE INFO',13,10,10
	db	2,'SILICON DRAGON!',13,10
	db	2,'SILICON DRAGON!',13,10,1
		
        db      2,'FIDONET 2:222/101',13
	db	2,'WRITE A MESSAGE TO',13
	db	2,'THE SYSOP, CALL:',13
	db	2,'+358-21-500318',13,10
	db	2,'+358-21-500318',13,10
	db	2,'+358-21-500318',13,10
	db	2,'+358-21-500318',13,10
	db	2,'+358-21-500318',13,1
	
        db      2,'BY THE WAY THE',13
        db      2,'SYSOP IS CALLED',13
        db      2,'JANI LAAKSO',13
        db      2,'ALIAS ICE OF FC',13,1

	db	2,'WE WILL ALSO GIVE',13
	db	2,'YOU SOME CONTACT',13
	db	2,'ADDRESSES WHERE',13
	db	2,'YOU CAN SEND...',13,1
	
	db	2,'...SOME NEW SOFT',13
	db	2,'LIKE YOUR OWN',13
	db	2,'DEMOS ETC...',13
	db	2,'HERE THEY COME:',13,1
	
	db	2,'DR.VENKMAN',13
	db	2,'POSTE RESTANTE',13
        db      2,'SF-90630 OULU',13
	db	2,'FINLAND, EUROPE',13,1

	db	2,'ICE OF FC',13
	db	2,'PYORAMAENTIE 13',13
	db	2,'SF-20300 TURKU',13
	db	2,'FINLAND, EUROPE',13,1
	
	db	2,'OR BY FIDONET TO',13
	db	2,'ICE/FC,',13
	db	2,'2:222/101',13,10
	db	2,'2:222/101',13,10
	db	2,'2:222/101',13,10
	db	2,'2:222/101',13,10
	db	2,'2:222/101',13,1

        db      2,'OR BY INTERNET',13
        db      2,'JANI.LAAKSO,',13
        db      2,'F152.N222.Z2.',13
        db      2,'FIDONET.ORG',13,10,10
        db      2,'F152.N222.Z2.',13
        db      2,'FIDONET.ORG',13,10,10
        db      2,'F152.N222.Z2.',13
        db      2,'FIDONET.ORG',13,10,10,1
	
	db	13,2,'THEN TO THE',13
	db	2,'CREDITS:',13,1
	
	db	13,2,'CODING:',13
	db	2,'PSI',13,10
	db	2,'PSI',13,1

	db	13,2,'GFX:',13
	db	2,'DR.VENKMAN',13,10
	db	2,'DR.VENKMAN',13,1

	db	13,2,'MUSIC:',13
	db	2,'LORD SOTH',13,10
	db	2,'LORD SOTH',13,1

        db      13,2,'TEXTS AND BBS',13
	db	2,'ICE',13,10
	db	2,'ICE',13,1

	db	2,'BY THE WAY, ARE YA',13
	db	2,'INTERESTED IN THE',13
	db	2,'THE SOURCE CODE',13
	db	2,'OF THIS DEMO?',13,1
	
	db	13,2,'YEAH, THE',13
	db	2,'SOURCE CODE',13,10
	db	2,'SOURCE CODE',13,10
	db	2,'SOURCE CODE',13,10
	db	2,'SOURCE CODE',13,10
	db	2,'SOURCE CODE',13,10,1
	
	db	2,'THE ONE IN',13
	db	2,'ASSEMBLER',13
	db	2,'YOU KNOW...',13,1
	
	db	13
	db	2,'IF SO, GET THE',13
	db	2,'STMIK!',13,1
	
	db	2,'IT IS THE',13
	db	2,'SCREAM TRACKER',13
	db	2,'MUSIC INTERFACE',13
	db	2,'KIT!',13,1
	
	db	2,'AS A LITTLE',13
	db	2,'EXAMPLE ON HOW',13
	db	2,'TO USE IT,',13,1
	
	db	2,'THE DEMO',13
	db	2,'SOURCE CODE',13
	db	2,'IS INCLUDED!',13,1
	
	db	2,'YOU CAN REQUEST',13
	db	2,'THE FILE FROM',13
	db	2,'OUR BBS WITH THE',13
	db	2,'MAGIC NAME:',13,1
	
	db	13
	db	2,'  STMIK ',13,10
	db	2,'  STMIK ',13,10
	db	2,'  STMIK ',13,10
	db	2,'  STMIK ',13,10
        db      2,'  STMIK ',13,10,1
	
        db      2,'OF COURSE YOU CAN',13
        db      2,'ALSO GET IT BY',13
        db      2,'LOGGING IN',13
	db	2,'NORMALLY!',13,1

	db	2,'WELL, THIS IS',13
	db	2,'ABOUT ALL IN',13
	db	2,'THIS SCROLLY',13,1
	
	db	2,'READ THE ABOVE',13
	db	2,'CRAP INSTEAD',13
	db	2,'AND REMEMBER',13
	db	2,'TO HAVE...',13,1
	
	db	2,'A REALLY HOT',13
	db	2,'SUMMER, OR A',13
	db	2,'COOL ONE IF',13
	db	2,'YOU...',13,1
	
	db	2,'HAPPEN TO',13
	db	2,'LIVE IN',13
        db      2,'FINLAND...',13,1

        db      2,'YOU CAN NOW RISE',13
        db      2,'YOUR EYES TO THE',13
        db      2,'UPPER SCROLLY...',13,1

	db	1,1

	db	13
        db      2,'LETS REPEAT...',13,1

        db      1,0

;****************** ENDING SCREEN *********************

endtext LABEL BYTE
db	"Hope you had a nice MENTAL SURGERY from the Future Crew!",13,10
db	13,10
db	13,10
db	"To contact us, either call our 24h BBS:",13,10
db	13,10
db	"Silicon Dragon, +358-21-500318, Fidonet 2:222/101",13,10
db	13,10
db	13,10
db	"Or write to one of the following addresses:",13,10
db	13,10
db	"DR.VENKMAN                ICE OF FC",13,10
db	"POSTE RESTANTE            PYORAMAENTIE 13",13,10
db	"SF-90630 OULU             SF-20300 TURKU",13,10
db	"FINLAND, EUROPE           FINLAND, EUROPE",13,10
db	"$"

