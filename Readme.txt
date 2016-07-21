DETERMINING THE QIBLA DIRECTION BY SHADOWS 


This Fortran program computes the times at which the shadow of a 
vertical object makes simple angles multiples of 45 defrees) with 
the qibla, thus making it possible to determine the qibla without 
knowing the North direction and without having to measure 
arbitrary angles.

The program can be compiled by GNU Fortran under Linux and MacOS  
and in the Cygwin environment on a PC.


*** COMPILE THE FORTRAN PROGRAM ***  

    gfortran -o qibtime.exe qibtime.f 


*** PREPARE A FILE WITH LOCATION AND CALENDAR DATA *** 

Sorry, this ancient Fortran program uses the formatted, not the 
free-form, blank-delimited input! As you have the source code, 
please feel free to change to your taste the single READ statement 
that this program contains!

Input data should be provided on logical unit 5 (which is connected 
to the "standard input" by default).

The program stops upon encountering the end-of-file on unit 5. 

For each table desired, the input should include three lines with 
the following data layout: 

 Line 1:
   
   Col. 1-28: name of place. It is reproduced on the table.
 
 Line 2:
   
   Col. 1-4: degrees in latitude of place. Negative if south.
   Col. 5-8: minutes in latitude of place.
   Col. 9-13: degrees in longitude of place. Negative if west.
   CoL. 14-17: minutes in longitude of place.
        For a negative latitude or longitude is negative, 
        only the degrees part should be preceded by a minus sign.
   Col. 18-25: zone time in hours relative to GMT. Negative if 
        west of Greenwich.

 Line 3:
   
   Col. 1-4: Year A.D. (or, 0 for "perpetual" table).
   Col. 5-8: 1, if Daylight Saving Time adjustment is desired,
             0, otherwise.
   
   Note: The North American rules of Daylight Saving are followed.
         The adjustment is done by adding one hour to all times from 
	 the second Sunday in March until the first Sunday in November.
          
         For perpetual schedules, all times in the period from 
         April to October, inclusive, are advanced by one hour.)

   Note: The data on lines 2 and 3 are all integer. They should be 
         right-justified in their respective fields.
         Exception: The last item on line 2 must contain a decimal point.


*** RUN THE COMPILED EXECUTABLE ***
    
    ./qibtime.exe  < qibdata  > qibout


*** SAMPLE FILES ***

Files "qibdata" and "qibout" are provided as a sample input file and 
the expected output file.

