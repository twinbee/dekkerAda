---------------------------------------------------------------
-- Author:	Matthew Bennett																	---
-- Class:		CSC410 Burgess																	---
-- Date:		09-01-04 							Modified: 9-05-04					---
-- Desc:		Assignment 1:DEKKER's ALGORITHM									---
--	a simple implementation of															---
--	Dekker's algorithm which describes mutual exclusion for	---
--  two processes (TASKS) assuming fair hardware.						---
-- Dekker's algorithm as described in												---
--  "Algorithms for Mutual Exclusion", M. Raynal						---
--  MIT PRESS Cambridge, 1974 ISBN: 0-262-18119-3						---
----------------------------------------------------------------
-- dependencies
WITH ADA.TEXT_IO; USE ADA.TEXT_IO;
WITH ADA.NUMERICS.FLOAT_RANDOM; --USE ADA.NUMERICS.FLOAT_RANDOM;
WITH ADA.INTEGER_TEXT_IO; USE ADA.INTEGER_TEXT_IO;
--WITH ADA.INTEGER_IO; USE ADA.INTEGER_IO;
WITH ADA.CALENDAR; USE ADA.CALENDAR;
-- (provides cast: natural -> time for input into delay)
--WITH ADA.STRINGS; USE ADA.STRINGS;
WITH ADA.STRINGS.UNBOUNDED; USE ADA.STRINGS.UNBOUNDED;
----------------------------------------------------------------
----------------------------------------------------------------
-- specifications

PACKAGE BODY as1 IS

PROCEDURE dekker IS
--implementation of the driver and user interface
	turn : Integer RANGE 0..1 			:= 0; --called for by dekker's
	flag : ARRAY(0..1) OF Boolean		:= (OTHERS => FALSE);--dekker's

	tempString  : Unbounded_String; --buffer used to hold the output for a task
	tempString0 : Unbounded_String := To_Unbounded_String("");
	 --buffer used to make the spaces for indents

  --user defined at runtime--
	iterations_user : Integer RANGE 0..100			:= 10;	-- iterations per task
	tasks_user  		: Integer RANGE 0..100			:= 2;   -- num proccesses

	TASK TYPE single_task IS
	  -- "an ENTRY is a TASK's version of a PROCEDURE or FUNCTION"
		ENTRY start (id_self : IN Integer; id_other : IN Integer; iterations_in : IN Integer);
	END single_task; 

  --we have to use a pointer every time we throw off a new task
	TYPE p_ptr IS ACCESS single_task; --reference type
	ptr : ARRAY(0..tasks_user) OF p_ptr; --how do we allocate dynamically?

	-- "since TASK TYPE single_task is part of PROCEDURE dekker,
	-- we must define it here or in a specifications file "
	TASK BODY single_task IS
			i,j : Integer 				:= 0;		-- identity, other task' identity
			iterations : Integer 	:= 0;		-- # of iterations
			G : Ada.Numerics.Float_Random.Generator;	-- yields a random Natural after seed

	BEGIN --single_task
	-- this is Dekker's algorithm implementation, the tasks themselves
			ACCEPT Start (id_self : IN Integer; id_other : IN Integer; iterations_in : IN Integer) DO
				i := id_self;
				j := id_other;
				iterations := iterations_user;
			END Start;

	FOR x IN 1 .. iterations LOOP
  	Ada.Numerics.Float_Random.Reset(G); --like seed_rand(time(0)) in c
		delay (Standard.Duration( (Ada.Numerics.Float_Random.Random(G) ) ) );
			
		-- Begin Dekker's Algorithm
		flag(i) := TRUE; --"requesting & in-CS" combined
				
		WHILE flag(j) LOOP
			IF turn = j THEN
			BEGIN
				flag(i) := FALSE; --fell in
				WHILE turn = j LOOP
					null; --event loop, do nothing
				END loop;
				flag(i) := TRUE;
			END; -- for begin
			END IF;
		END LOOP;
	
		-- Critical Section
		FOR x IN 0..8*i LOOP
			tempString0 := tempString0 & To_UnBounded_String(" "); --build up indent
		END LOOP;
		tempString := tempString0 & To_Unbounded_String(Integer'Image(i) & " in  CS");
		Put_Line( To_String(tempString) );
		tempString0 := To_UnBounded_String("");

	  DELAY Standard.Duration( ( (Ada.Numerics.Float_Random.random(G) ) ));
		
		FOR x IN 0..8*i LOOP
			tempString0 := tempString0 & To_UnBounded_String(" "); --build up indent
		END LOOP;
		tempString := tempString0 & To_Unbounded_String(Integer'Image(i) & " out CS");
		Put_Line( To_String(tempString) );
		tempString0 := To_UnBounded_String("");
		-- end Critical Section
	
		turn := j; --"next process"
		flag(i) := FALSE; --"finished with my critical section"

		END LOOP;
	END single_task;

----------------------------------------------------------------
----------------------------------------------------------------
-- implementation
BEGIN --procedure dekker

	--sanity checking on the input
	LOOP
		put("# tasks[1-2]:       ");
		get(tasks_user);
		EXIT WHEN (tasks_user > 0 AND tasks_user <= 2);
	END LOOP;
	LOOP
		put("# iterations[1-20]: ");
		get(iterations_user);
		EXIT WHEN (iterations_user > 0 AND iterations_user <= 20);
	END LOOP;


	-- For each proccess, start it and pass them their id's
	FOR x IN 0 .. (tasks_user-1)
	LOOP
		ptr(x) := NEW single_task;
		ptr(x).Start(x,1-x, iterations_user);
	END LOOP;

END dekker;

END as1;
