C    PROGRAM TO COMPUTE TIMES FOR QIBLA DETERMINATION VIA SHADOWS
C
C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C
C
C                        WRITTEN BY
C
C                     S.  KAMAL ABDALI
C             MATHEMATICAL SCIENCES DEPARTMENT
C             RENSSELAER POLYTECHNIC INSTITUTE
C               TROY,  NEW YORK 12181,  USA
C
C                  (Program written in 1977)
C                   (Last revised May 1987)
C
C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C
C
C  INPUT DATA SHOULD BE PROVIDED ON LOGICAL UNIT 5.
C    THE PROGRAM STOPS UPON ENCOUNTERING THE END-OF-FILE ON UNIT 5.
C    FOR EACH TABLE DESIRED, THE INPUT SHOULD INCLUDE THREE LINES
C    WITH THE FOLLOWING DATA LAYOUT:
C
C    LINE 1:
C      COL. 1 - 28: NAME OF PLACE. IT IS REPRODUCED ON THE TABLE.
C
C    LINE 2:
C      COL.  1 -  4: DEGREES IN LATITUDE OF PLACE. NEGATIVE IF SOUTH
C      COL.  5 -  8: MINUTES IN LATITUDE OF PLACE.
C      COL.  9 - 13: DEGREES IN LONGITUDE OF PLACE. NEGATIVE IF WEST
C      COL. 14 - 17`: MINUTES IN LONGITUDE OF PLACE.
C      COL. 18 - 25: ZONE TIME IN HOURS RELATIVE TO GMT (REAL NO.)
C               THIS IS A REAL NUMBER, NEGATIVE IF WEST OF GREENWICH
C
C      (N O T E : IF A LATITUDE OR LONGITUDE IS NEGATIVE, ONLY ITS
C                  DEGREES PART SHOULD BE PRECEDED BY A MINUS SIGN.)
C
C    LINE 3:
C      COL.  1 -  4: YEAR A.D.  (OR, 0 FOR "PERPETUAL" TABLE).
C      COL.  5 -  8: 1, IF DAYLIGHT SAVING TIME ADJUSTMENT REQUIRED,
C                    0, OTHERWISE.
C      (N O T E : THIS ADJUSTMENT IS DONE BY ADDING ONE HOUR TO ALL
C                 TIMES FROM THE SECOND SUNDAY IN MARCH UNTIL THE
C                 FIRST SUNDAY IN NOVEMBER.
C                 FOR PERPETUAL TABLES, ALL TIMES IN THE PERIOD
C                 FROM APRIL TO OCTOBER, INCLUSIVE, ARE ADVANCED 
C                 BY ONE HOUR.)
C
C
C      (N O T E : THE DATA ON LINES 2 AND 3 ARE ALL INTEGER. THEY
C       SHOULD BE RIGHT-JUSTIFIED IN THEIR RESPECTIVE FIELDS.
C       EXCEPTION: LAST ITEM ON LINE 2 MUST CONTAIN A DECIMAL POINT.)
C
C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C
C
C  THE PROGRAM OUTPUT IS ON LOGICAL UNIT 6.
C
C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C C
C
      INTEGER HOUR,YEAR,BEGDST,FINDST
      REAL LAT,LONG,TZONE
      DIMENSION TIME0(6),COALT(6)
      CHARACTER*1 NUM(6,18,31)
      DIMENSION NDMNTH(12),TIM(366,8)
      COMMON /MATH/PI
      COMMON /ASTR/OBL,DMANOM,DMLONG,ANOM0,SMLNG0,C1,C2,DELSID,SIDTM0
      COMMON/POSN/LAT,LATD,LATM,LONG,LONGD,LONGM,TZONE
      COMMON /NOTES/ NOTE1
      DIMENSION NAME(7)
      DATA NDMNTH/31,28,31,30,31,30,31,31,30,31,30,31/
      RADIAN(X)=X*PI/180
      DEGREE(IDEG,MINUTE)=IDEG+ISIGN(MINUTE,IDEG)/60.0
    1 READ (5,5,END=600) NAME,LATD,LATM,LONGD,LONGM,TZONE,YEAR,IDST
    5 FORMAT(7A4/2I4,I5,I4,F8.0/2I4)
C  0 FOR YEAR INDICATES THAT A PERPETUAL TABLE IS DESIRED. USE 1982
      NYEAR=YEAR
      IF(YEAR.EQ.0) NYEAR=2018
      CALL CONST(NYEAR)
      LAT=RADIAN(DEGREE(LATD,LATM))
      LONG=RADIAN(DEGREE(LONGD,LONGM))
      DIREC=QIBLA(0)
C  FIND BEGINNING AND ENDING DAYS FOR DAYLIGHT SAVING TIME
      CALL DAYLIT(YEAR,LEAP,IDST,BEGDST,FINDST)
      NDMNTH(2)=28+LEAP
      NDAYS=365+LEAP
      DO 400 I=1,NDAYS
C  FOR PERPETUAL QIBLA CHART, FEBRUARY 29 AND MARCH 1 HAVE SAME TIMES
      K=I
      IF (I.GT.60 .AND. YEAR .EQ.0) K=I-1
      DO 350 J=1,8
      TIM(I,J)=TSHAD(K,DIREC-PI/4.0*(J-1))
  350 CONTINUE
  400 CONTINUE
C  CORRECT FOR DAYLIGHT SAVING TIME
      IF (FINDST.EQ.0) GO TO 408
      DO 405 I=BEGDST,FINDST
      DO 405 J=1,8
  405 TIM(I,J)=TIM(I,J)+1.0
  408 CONTINUE
C QIBLA CHART COMPUTED. NOW PRINT IT OUT
      NDAYS0=1
      DO 500 N=1,12
      CALL TITLEQ(NAME,YEAR,IDST,DIREC)
      CALL HEADRQ(N,YEAR,IDST)
      ND=NDMNTH(N)
      NDAYS1=NDAYS0-1+ND
      DO 420 L=NDAYS0,NDAYS1
      DO 410 J=1,8
      T=TIM(L,J)
      HOUR=T
      MINUT=60.0*(T-INT(T))+0.5
      IF (MINUT.LT.60) GO TO 409
      MINUT=0
      HOUR=HOUR+1
  409 CALL HRMS(HOUR,MINUT,NUM(1,J,L+1-NDAYS0))
  410 CONTINUE
  420 CONTINUE
      NDAYS0=NDAYS1+1
      IF (ND.EQ.31) GO TO 435
      ND1=ND+1
      DO 430 L=ND1,31
      DO 430 J=1,8
C  BLANK OUT TIME ON NON-EXISTENT DATES
  430 CALL HRMS(-1,0,NUM(1,J,L))
  435 CONTINUE
C     WRITE(6,440) (L,((NUM(K,J,L),K=1,6),J=1,8),L=1,31)
C 440 FORMAT(I8,8(1X,6A1)/)
      DO 450 L1=1,31
      WRITE(6,445) L1, ((NUM(K,J,L1),K=1,6),J=1,8)
  445 FORMAT(I8,8(1X,6A1))   
  450 CONTINUE
  500 CONTINUE
      GO TO 1
  600 WRITE(6,610)
  610 FORMAT(/////)
      STOP
      END
C
C
      SUBROUTINE HRMS(HOUR,MINUT,HM)
C  FORM STRING HHH:MM IN HM FROM TIME OR ANGLE
C    HM IS OUTPUT STRING, HOUR IS HOURS OR DEGREES
C    IF HOUR TOO LARGE (IMPOSSIBLE TIME), MAKE STRING AN ASTERISK
C    AND MAKE NOTE1 NON-ZERO TO MARK THIS SITUATION
C    IF HOUR IS NEGATIVE(NO SUCH DATE), THEN MAKE STRING BLANK
      INTEGER HOUR
      CHARACTER*1 HM(6),DIG(10),BLANK,STAR,COLON
      COMMON /NOTES/ NOTE1
      DATA DIG/'0','1','2','3','4','5','6','7','8','9'/
      DATA BLANK/' '/,STAR/'*'/,COLON/':'/
      DO 5 I=1,6
    5 HM(I)=BLANK
      IF (HOUR.LT.0) RETURN
      HM(5)=STAR
      K=HOUR
      IF (K.LE.360) GO TO 7
      NOTE1=1
      RETURN
    7 L=K/100
      IF (L.NE.0) HM(1)=DIG(L+1)
      K=MOD(K,100)
      IF (L.NE.0 .OR. K/10.NE.0) HM(2)=DIG(K/10+1)
      HM(3)=DIG(MOD(K,10)+1)
      HM(4)=COLON
      HM(5)=DIG(MINUT/10+1)
      HM(6)=DIG(MOD(MINUT,10)+1)
      RETURN
      END
C
C
      SUBROUTINE CONST(NYEAR)
C COMPUTES ASTRO CONSTANTS FOR JAN 0 OF GIVEN YEAR
C
C  NDAYS = TIME FROM 12 HR(NOON), JAN 0, 1900 TO 0 HR, JAN 0 OF NYEAR
C  T = SAME IN JULIAN CENTURIES(UNITS OF 36525 DAYS)
C  OBL = OBLIQUITY OF ECLIPTIC
C  DMANOM,DMLONG,DELSID = DAILY MOTION (CHANGE) IN SUN'S ANOMALY,
C       SUN'S MEAN LONGITUDE, SIDEREAL TIME
C  ANOM0,SMLONG0,SIDTM0 = SUN'S MEAN ANOMALY, SUN'S MEAN LONGITUDE,
C       SIDEREAL TIME, ALL AT 0 HR, JAN 0 OF YEAR NYEAR
C  C1,C2 = COEFFICIENTS IN EQUATION OF CENTER
      DOUBLE PRECISION DMOD,DATAN
      DOUBLE PRECISION T,DPI,DDEG,SEC,DRAD,DEGREE,DX
      COMMON /MATH/PI
      COMMON /ASTR/OBL,DMANOM,DMLONG,ANOM0,SMLNG0,C1,C2,DELSID,SIDTM0
      DRAD(DEGREE)=DMOD(DEGREE,360.0D0)*DPI/180.0D0
      DDEG(IDEG,MIN,SEC)=IDEG+MIN/60.0D0+SEC/3600.0D0
      DHOUR(IHOUR,MIN,SEC)=DDEG(IHOUR,MIN,SEC)
      DPI=DATAN(1.0D0)*4.0D0
      PI=DPI
      NDAYS=(NYEAR-1900)*365+(NYEAR-1901)/4
      T=(NDAYS-0.5D0)/36525.0D0
      OBL=DRAD(DDEG(23,27,8.26D0)-DDEG(0,0,46.845D0)*T)
      DMANOM=DRAD(DDEG(35999,2,59.10D0)/36525.0D0)
      DMLONG=DRAD(DDEG(36000,46,8.13D0)/36525.0D0)
      DX=DRAD(DDEG(279,41,48.04D0)+DDEG(0,0,1.089D0)*T*T)+
     1  DRAD(DDEG(36000,46,8.13D0)*T)
      SMLNG0=DMOD(DX,2.0D0*DPI)
      DX=DRAD(DDEG(358,28,33.0D0)-DDEG(0,0,.54D0)*T*T)+
     1   DRAD(DDEG(35999,2,59.10D0)*T)
      ANOM0=DMOD(DX,2.0D0*DPI)
      DELSID=DHOUR(2400,3,4.542D0)/36525.0D0
      DX=DHOUR(6,38,45.836D0)+DMOD(DHOUR(2400,3,4.542D0)*T,24.0D0)
      SIDTM0=DMOD(DX,24.0D0)
      C1=DRAD(DDEG(1,55,10.057D0)-DDEG(0,0,17.24D0)*T-
     1     DDEG(0,0,0.052D0)*T*T)
      C2=DRAD(DDEG(0,1,12.338D0)-DDEG(0,0,0.361D0)*T)
      RETURN
      END
C
C
      SUBROUTINE DAYLIT(YEAR,LEAP,IDST,BEGIN,FINISH)
C  FINDS WHETHER YEAR IS LEAP (LEAP = 1 IF YES, 0 IF NO).
C  IF IDST IS NON-ZERO, THEN ALSO
C  COMPUTES DAY NOS. FOR DAYLIGHT SAVINGS TIME START AND END.
C  USE DAYLIGHT CALENDAR OF NORTH AMERICA
C  BEGIN = DAY NO. (WITHIN YEAR) OF SECOND SUNDAY OF MARCH
C  FINISH = DAY NO. (WITHIN YEAR) OF FIRST SUNDAY OF NOVEMBER
      INTEGER YEAR,BEGIN,FINISH,MAR0,NOV0,SUN1ST,SUN2ND
      LEAP=0
      M4=MOD(YEAR,400)
      M1=MOD(YEAR,100)
      IF (M4.EQ.0 .OR. M1.NE.0 .AND. MOD(YEAR,4).EQ.0) LEAP=1
      IF (IDST.NE.0) GO TO 5
C  NO ADJUSTMENT FOR DAYLIGHT SAVING TIME (YEAR ZERO FOR PERPETUAL)
      BEGIN=367
      FINISH=0
      RETURN
    5 IF (YEAR.NE.0) GO TO 10
C  DAYLIGHT SAVING TIME IN PERPETUAL CALENDAR FOR NORTH AMERICA
C  APPLY TO MARCH 1 THRU OCT 31.
C  PUT NOTICE IN APR AND NOV PARTS FOR MANUAL EXTRA CORRECTION
      BEGIN=31+29+1
      FINISH=BEGIN-1+31+30+31+30+31+31+30+31
      RETURN
C  NON-ZERO YEAR. FOR ANNUAL CALENDAR
C  NMAR0,NNOV0 = DAY NO. (WITHIN YEAR) ON THOSE DATES
C  JAN0,MAR0,NOV0 = DAY OF WEEK ON SUCH DATES (FRI=0,SAT=1,SUN=2,...)
C  SUN1ST,SUN2ND = DATE OF FIRST, SECOND SUNDAY IN MONTH
   10 JAN0=MOD(M4/100*124+1+M1+M1/4-LEAP,7)
      NMAR0=31+28+LEAP
      NNOV0=365+LEAP-31-30
      MAR0=MOD(NMAR0+JAN0,7)
      NOV0=MOD(NNOV0+JAN0,7)
      SUN1ST = 2-MAR0
      IF (SUN1ST .LT. 1) SUN1ST=SUN1ST+7
      SUN2ND=SUN1ST+7
      BEGIN=NMAR0+SUN2ND
      SUN1ST = 2-NOV0
      IF (SUN1ST .LT. 1) SUN1ST=SUN1ST+7
      FINISH=NNOV0+SUN1ST-1
      RETURN
      END
C
C
      FUNCTION QIBLA(I)
C  RETURNS DIRECTION OF QIBLA IN RADIANS. EASTWARD FROM NORTH IS POS.
      REAL LAT,LONG,TZONE,LONG0,LAT0
C  LONG0,LAT0 ARE LONG AND LAT OF MECCA IN RADIANS
C  (FROM DEGREE VALUES: LAT0 = 21:25:21.05 N, LONG0 = 39:49:34.35 E)
      COMMON /MATH/PI
      COMMON/POSN/LAT,LATD,LATM,LONG,LONGD,LONGM,TZONE
C     DATA LONG0,LAT0/0.6950482,.3739077/
      DATA LAT0,LONG0/0.3738934,0.6950985/
      DFLONG=LONG0-LONG
      QIBLA=ATAN2(SIN(DFLONG),COS(LAT)*TAN(LAT0)-SIN(LAT)*COS(DFLONG))
      RETURN
      END
C
C
      FUNCTION TSHAD(NDAY,BEARNG)
C  RETURNS TIME WHEN SHADOW HAS GIVEN BEARING CLOCKWISE TO NORTH
C  IF NO SUCH TIME, THEN RETURNS A LARGE NUMBER
      REAL LAT,LONG,LOCMT,LONGH,TZONE
      COMMON /MATH/ PI
      COMMON /ASTR/OBL,DMANOM,DMLONG,ANOM0,SMLNG0,C1,C2,DELSID,SIDTM0
      COMMON/POSN/LAT,LATD,LATM,LONG,LONGD,LONGM,TZONE
      TSHAD=1.0E7
C  FIRST MAKE SUN'S AZIMUTH BETWEEN 0 AND 360 DEGREES, THEN BETWEEN
C  -180 AND +180.  IF AZIMUTH IS POSITIVE, TIME IS A.M., ELSE P.M.
C  APPROXIMATE TIMES ARE 8 AM AND 4 PM.
      AZMTH=AMOD(BEARNG+3.0*PI,2.0*PI)
      TIME0=8.0
      IF (AZMTH.LT.PI) GO TO 20
      AZMTH=2.*PI-AZMTH
      TIME0=16.0
   20 LONGH=LONG*12./PI
      DAYS=NDAY+(TIME0+LONGH)/24.0
      ANOMLY=ANOM0+DMANOM*DAYS
      SMLNG=SMLNG0+DMLONG*DAYS
      SLONG=SMLNG+C1*SIN(ANOMLY)+C2*SIN(ANOMLY*2)
      RA=ATAN2(COS(OBL)*SIN(SLONG),COS(SLONG))*12.0/PI
      IF (RA.LT.0.) RA=RA+24.0
      SINDCL=SIN(OBL)*SIN(SLONG)
      DECL=ASIN(SINDCL)
      THETA1=ATAN2(COS(LAT)*COS(AZMTH),SIN(LAT))
      THETA2=ACOS(SIN(DECL)*COS(THETA1)/SIN(LAT))
C  GET (POSSIBLY TWO) VALUES OF COALT. SELECT THE LARGER ONE SO
C   THAT WE HAVE COALT <= 90.83 DEGREES (I.E. SUN ABOVE HORIZON)
      COALT1=AMOD(2.0*PI+THETA1+THETA2,2.0*PI)
      COALT2=AMOD(4.0*PI+THETA1-THETA2,2.0*PI)
      IF (AMIN1(COALT1,COALT2).GT.90.83/180.0*PI) RETURN
      COALT=AMAX1(COALT1,COALT2)
      IF (COALT.GT.90.83/180.0*PI) COALT=AMIN1(COALT1,COALT2)
      COSHA=(COS(COALT)-SIN(DECL)*SIN(LAT))/COS(DECL)/COS(LAT)
      IF (ABS(COSHA).GT.1.0) RETURN
      HA=ACOS(COSHA)*12.0/PI
      IF (TIME0.LT.12.0) HA=24.0-HA
      LOCMT=HA+RA-DELSID*DAYS-SIDTM0
      TSHAD=LOCMT-LONGH+TZONE
      IF (TSHAD.LT.0.) TSHAD=TSHAD+24.0
      IF (TSHAD.GT.24.0) TSHAD=TSHAD-24.0
      RETURN
C  50 IF (M.NE.0) RETURN
C     M=1
C     SOL=PI-SOL
C     GO TO 40
      END
C
C
      SUBROUTINE TITLEQ(NAME,YEAR,IDST,DIREC)
C  TITLES FOR QIBLA INDICATOR CHART
      INTEGER YEAR,QIBD,QIBM
      CHARACTER*1 SGNLNG,SGNLAT,SGNZON,SGNQIB
      CHARACTER*1 DIR(4),SGN(2)
      REAL LAT,LONG,TZONE
      CHARACTER*1 LATDM(6),LONGDM(6),QIBDM(6)
      DIMENSION NAME(7)
      COMMON /MATH/ PI
      COMMON/POSN/LAT,LATD,LATM,LONG,LONGD,LONGM,TZONE
      DATA DIR/'E','W','N','S'/,SGN/'+','-'/
      DEGREE(X)=X*180.0/PI
      CALL HRMS(IABS(LATD),LATM,LATDM)
      SGNLAT=DIR(3)
      IF (LATD.LT.0.) SGNLAT=DIR(4)
      CALL HRMS(IABS(LONGD),LONGM,LONGDM)
      SGNLNG=DIR(1)
      IF (LONGD.LT.0.) SGNLNG=DIR(2)
      ZONABS=ABS(TZONE)
      SGNZON=SGN(1)
      IF (TZONE .LT. 0) SGNZON=SGN(2)
      ABSQIB=ABS(DIREC*180.0/PI)
      QIBD=ABSQIB
      QIBM=60.0*(ABSQIB-INT(ABSQIB))+0.5
      IF (QIBM.LT.60) GO TO 35
      QIBM=0
      QIBD=QIBD+1
   35 CALL HRMS(QIBD,QIBM,QIBDM)
      SGNQIB=DIR(1)
      IF (DIREC.LT.0.) SGNQIB=DIR(2)
      IF(YEAR.EQ.0) GO TO 40
      WRITE(6,37) YEAR,NAME
   37 FORMAT(/////,8X,I4,' A.D.  QIBLA  INDICATOR  FOR  ',7A4)
      GO TO 45
   40 WRITE(6,42) NAME
   42 FORMAT(/////,8X,'PERPETUAL  QIBLA  INDICATOR  FOR  ',7A4)
   45 WRITE(6,48) LATDM,SGNLAT,LONGDM,SGNLNG
   48 FORMAT(1X/11X,'Latitude =',6A1,1X,A1,6X,'Longitude =',
     1  1X,6A1,1X,A1)
      WRITE(6,49) SGNZON,ZONABS,QIBDM,SGNQIB
   49 FORMAT(7X,'Zone Time = GMT ',A1,F4.1,6X,'Qibla =',6A1,1X,A1,
     1   ' (From N)' )
      WRITE(6,50)
   50 FORMAT(1X/2X,'TIME WHEN QIBLA IS AT GIVEN ANGLE TO SHADOW',
     1   ' OF VERTICAL OBJECT'/14X,'(*  indicates no such time on ',
     2   'that day)')
      RETURN
      END
C
C
      SUBROUTINE HEADRQ(N,YEAR,IDST)
C  PRINT HEADER FOR BI-MONTHLY SECTION N IN QIBLA CHART
C  IDST = 1 IF DAYLIGHT SAVING ADJUSTMENT DONE, 0 OTHERWISE
      INTEGER YEAR
      GO TO (1,2,3,4,5,6,7,8,9,10,11,12),N
    1 WRITE(6,21)
   21 FORMAT(2(1X/),27X,'J A N U A R Y')
      GO TO 100
    2 WRITE(6,22)
   22 FORMAT(2(1X/),28X,'F E B R U A R Y')
      GO TO 100
    3 WRITE(6,23)
   23 FORMAT(2(1X/),29X,'M A R C H')
      IF(YEAR.EQ.0 .AND. IDST.NE.0) WRITE(6,51)
   51 FORMAT(1X/,1X,'(In March, SUBTRACT ONE HOUR from all',
     1      ' times until SECOND SUNDAY)')
      GO TO 100
    4 WRITE(6,24)
   24 FORMAT(2(1X/),29X,'A P R I L')
      GO TO 100
    5 WRITE(6,25)
   25 FORMAT(2(1X/),31X,'M A Y')
      GO TO 100
    6 WRITE(6,26)
   26 FORMAT(2(1X/),30X,'J U N E')
      GO TO 100
    7 WRITE(6,27)
   27 FORMAT(2(1X/),30X,'J U L Y')
      GO TO 100
    8 WRITE(6,28)
   28 FORMAT(2(1X/),28X,'A U G U S T')
      GO TO 100
    9 WRITE(6,29)
   29 FORMAT(2(1X/),25X,'S E P T E M B E R')
      GO TO 100
   10 WRITE(6,30)
   30 FORMAT(2(1X/),27X,'O C T O B E R')
      GO TO 100
   11 WRITE(6,31)
   31 FORMAT(2(1X/),26X,'N O V E M B E R')
      IF (YEAR.EQ.0 .AND. IDST.NE.0) WRITE(6,52)
   52 FORMAT(1X/,1X,'(In November, SUBTRACT ONE HOUR from all'
     1   ,' times until FIRST SUNDAY)')
      GO TO 100
   12 WRITE(6,32)
   32 FORMAT(2(1X/),26X,'D E C E M B E R')
      GO TO 100
  100 WRITE(6,120) 0,45,90,135,180,225,270,315
  120 FORMAT(1X/3X,61(1H-)/
     1   15X,'ANGLE CLOCKWISE FROM SHADOW TO QIBLA',3X/,
     2   4X,'DAY',8I7,1x/,
     3   3X,61(1H-))
      RETURN
      END
