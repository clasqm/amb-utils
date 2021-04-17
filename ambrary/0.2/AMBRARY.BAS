'AMBRARY v0.2
'(AMB library, geddit?)

'Written in QuickBASIC 4.5 for FreeDOS, 2021.
'Released under the Dowhatthefuckyouwant license.

'Scans C: for AMB files and allow user to select one for reading.

'Requires the AMB reader and at least one AMB file to be installed.
'Well, it wouldn't be much use otherwise, would it?

'This version handles up to 124 AMB files by default. Should be enough for now,
'but otherwise just change the amblimit% variable below and recompile.

DECLARE SUB Display ()
DECLARE SUB HelpMe ()
DECLARE SUB EndThis ()
DECLARE SUB AmbScan ()
DECLARE SUB ReadDB (filename$)
DECLARE SUB FillArray ()
DECLARE FUNCTION ScrollBox% (lim%, high%, wide%, LIN%, COL%)
DECLARE FUNCTION DbaseExists% (filename$)

'$STATIC

'Global string variables
COMMON SHARED tempdir$, tempfile$, ambdrive$, dbfile$
'Global arrays
COMMON SHARED filename$(), title$()
'Global numeric variables
COMMON SHARED amblimit%
IF INSTR(COMMAND$, "HELP") OR INSTR(COMMAND$, "/H") OR INSTR(COMMAND$, "/?") THEN HelpMe
amblimit% = 128
IF INSTR(COMMAND$, "256") THEN amblimit% = 256
IF INSTR(COMMAND$, "512") THEN amblimit% = 512
IF INSTR(COMMAND$, "1024") THEN amblimit% = 1024
DIM filename$(amblimit%)
DIM title$(amblimit%)
ambdrive$ = "C:"
IF INSTR(COMMAND$, "D:") THEN ambdrive$ = "D:"
IF INSTR(COMMAND$, "E:") THEN ambdrive$ = "E:"
IF INSTR(COMMAND$, "F:") THEN ambdrive$ = "F:"
tempdir$ = ENVIRON$("TEMP")
tempfile$ = tempdir$ + "\ambrary.lst"
dbfile$ = "C:\FDOS\DOC\AMBTITLE.DB"
IF INSTR(COMMAND$, "AMBTITLE") THEN SHELL "ambtitle " + ambdrive$
IF INSTR(COMMAND$, "RESCAN") THEN
    AmbScan     'any way to speed this up?
    FillArray   'feed temp file into array
    Display
    EndThis
END IF
IF DbaseExists%(dbfile$) = 1 THEN
    ReadDB (dbfile$)
ELSE
    AmbScan
    FillArray   'feed temp file into array
END IF
Display
EndThis

SUB AmbScan
    scanbat% = FREEFILE
    OPEN tempdir$ + "\rescan.bat" FOR OUTPUT AS #scanbat%
    PRINT #scanbat%, "@echo off"
    PRINT #scanbat%, "cls"
    PRINT #scanbat%, "echo."
    PRINT #scanbat%, "echo           *******************************"
    PRINT #scanbat%, "echo           ********* AMBRARY scan ********"
    PRINT #scanbat%, "echo           *******************************"
    PRINT #scanbat%, "echo           *                             *"
    PRINT #scanbat%, "echo           *  Scanning " + ambdrive$ + " for AMB files  *"
    PRINT #scanbat%, "echo           *  This could take a while:   *"
    PRINT #scanbat%, "echo           *  DOS can be slow sometimes. *"
    PRINT #scanbat%, "echo           *                             *"
    PRINT #scanbat%, "echo           *******************************"
    PRINT #scanbat%, "echo."
    PRINT #scanbat%, "dir /S /B /ON /-P " + ambdrive$ + "\*.amb > " + tempfile$
    CLOSE #scanbat%
    SHELL tempdir$ + "\rescan.bat"
    KILL tempdir$ + "\rescan.bat"
END SUB

FUNCTION DbaseExists% (filename$)
    tmp1% = FREEFILE
    OPEN filename$ FOR BINARY AS #tmp1%
    IF LOF(tmp1%) <> 0 THEN DbaseExists% = 1
    CLOSE #tmp1%
END FUNCTION

SUB Display
    SCREEN 0
    CLS
    DO
        IF choice% <> 0 THEN
            SHELL "amb " + filename$(choice%)
            choice% = 0
        ELSE
            choice% = ScrollBox%(amblimit% + 1, 23, 76, 1, 1)
        END IF
    LOOP
END SUB

SUB EndThis
    CLOSE
    END
END SUB

SUB FillArray
    tmp1% = FREEFILE
    filename$(0) = "*********** EXIT ***********"
    OPEN tempfile$ FOR INPUT AS #tmp1%
    FOR f = 1 TO amblimit%
        IF NOT EOF(tmp1%) THEN
            LINE INPUT #tmp1%, a$
            IF a$ <> "" THEN
                filename$(f) = a$
            END IF
        END IF
    NEXT f
    IF filename$(1) = "" THEN
        PRINT
        PRINT "No AMB files found on drive " + ambdrive$
        EndThis
    END IF
    CLOSE #tmp1%
    KILL tempfile$
END SUB

SUB HelpMe
    PRINT "AMBRARY v0.2"
    PRINT "A simple launcher menu for your .AMB (Ancient Machine Book) files."
    PRINT
    PRINT "USAGE: AMBRARY  [D: | E: | F:] [256 | 512 | 1024] [RESCAN] [AMBTITLE]"
    PRINT
    PRINT "The command AMBRARY, with no further parameters, will load a data"
    PRINT "file produced by AMBTITLE. If this is not found, AMBRARY will scan"
    PRINT "the C drive for AMB files and will display up to 128 of them to"
    PRINT "select for reading in the AMB reader program."
    PRINT
    PRINT "If you keep your .AMB files elsewhere, you can start Ambrary with a"
    PRINT "a parameter indicating that. e.g. AMBRARY D: . E: and F: will also be"
    PRINT "accepted. If you give more than one, the highest one will be used."
    PRINT
    PRINT "You can also increase the number of books listed. Accepted values are"
    PRINT "256, 512 and 1024. Again, the highest number given is used."
    PRINT
    PRINT "You can force a normal rescan with the RESCAN parameter, even if the"
    PRINT "AMBTITLE database is detected. Or you can force a slower AMBTITLE rescan"
    PRINT "with the AMBTITLE parameter (AMBTITLE must be installed)."
    PRINT
    PRINT "AMBRARY D: 512 and AMBRARY 512 D: work exactly the same way."
    PRINT
    PRINT "AMBRARY /D: or AMBRARY --1024 or AMBRARY -F: /256 will all work,"
    PRINT "since these traditional parameter indicators are ignored."
    EndThis
END SUB

SUB ReadDB (filename$)
    tmp1% = FREEFILE
    OPEN filename$ FOR INPUT AS #tmp1%
        entries% = 0
        DO
            LINE INPUT #tmp1%, dummy$
            entries% = entries% + 1
        LOOP UNTIL EOF(tmp1%)
        CLOSE #tmp1%
        IF entries% > amblimit% THEN entries% = amblimit%
    filename$(0) = "*********** EXIT ***********"
    title$(0) = "*********** EXIT ***********"
    OPEN filename$ FOR INPUT AS #tmp1%
    FOR f = 1 TO entries%
        IF NOT EOF(tmp1%) THEN
            LINE INPUT #tmp1%, a$
           ' PRINT a$
           ' SLEEP
            IF a$ <> "" THEN
                FOR n = 1 TO LEN(a$)
                    IF MID$(a$, n, 1) = CHR$(9) THEN MIDPOINT% = n
                NEXT n
            '    PRINT MIDPOINT%
                filename$(f) = LEFT$(a$, MIDPOINT% - 1)
                title$(f) = MID$(a$, MIDPOINT% + 1)
            END IF
        END IF
    NEXT f
    IF filename$(1) = "" THEN
        PRINT
        PRINT "No AMB files found on drive " + ambdrive$
        EndThis
    END IF
    CLOSE #tmp1%
END SUB

FUNCTION ScrollBox% (lim%, high%, wide%, LIN%, COL%)
REM ===========================================================================
REM Author: Kurt Kuzba
REM I made it a FUNCTION, as opposed to a SUB, because it is also
REM useful for menus, and you can always just disregard the return
REM value.
REM
REM Adapted by Michel Clasquin-Johnson for his own nefarious purposes.
REM ===========================================================================
    REM lim%= number of lines to display
    COLOR 7, 1: CLS : sel% = 0: top% = 0: ex% = lim%
    COLOR 1, 7: LOCATE 1, 1, 0: s$ = STRING$(wide%, " ")
    FOR t% = 0 TO high% + 1
        LOCATE LIN% + t%, COL%
        PRINT STRING$(wide% + 4, CHR$(177));
    NEXT
    LIN% = LIN% + 1: COL% = COL% + 2
    WHILE lim% = ex%
        COLOR 9, 1: LOCATE LIN% - 1, COL%
        PRINT MID$(STR$(sel% + 1), 2) + STRING$(3, CHR$(177))
        FOR t% = 0 TO (high% - 1)
            LOCATE LIN% + t%, COL%: COLOR 1, 7
            IF t% + top% = sel% THEN COLOR 7, 1
            IF title$(top% + t%) <> "" THEN
                PRINT LEFT$(title$(top% + t%) + s$, wide%);
            ELSE
                PRINT LEFT$(filename$(top% + t%) + s$, wide%);
            END IF
        NEXT: p% = 0: p$ = " HPIQGO" + CHR$(13)
        WHILE p% < 2: p% = INSTR(p$, RIGHT$(INKEY$, 1)): WEND
        SELECT CASE p%
            CASE IS = 2   'CURSOR UP
                IF sel% > 0 THEN sel% = sel% - 1
                IF sel% < top% THEN top% = sel%
            CASE IS = 3   'CURSOR DOWN
                IF sel% < (lim% - 1) THEN sel% = sel% + 1
                IF sel% > (top% + (high% - 2)) THEN top% = sel% - high% + 1
            CASE IS = 4   'PAGE UP
                top% = top% - high%: sel% = sel% - high%
                IF top% < 0 THEN top% = 0
                IF sel% < 0 THEN sel% = 0
            CASE IS = 5   'PAGE DOWN
                top% = top% + high%: sel% = sel% + high%
                IF top% >= lim% - high% THEN top% = lim% - high%
                IF top% < 0 THEN top% = 0
                IF sel% >= lim% THEN sel% = lim% - 1
            CASE IS = 6   'HOME
                top% = 0: sel% = 0
            CASE IS = 7   'END
                sel% = lim% - 1: top% = sel% - high% + 1
                IF top% < 0 THEN top% = 0
            CASE IS = 8   'ENTER
                lim% = sel%
        END SELECT
    WEND
    IF sel% = 0 THEN EndThis 'only way out of an endless loop. Yes, I know,
    ScrollBox% = sel%        'bad form to put it here and not in the main module.
END FUNCTION                 'So sue me.

