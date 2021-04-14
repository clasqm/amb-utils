'AMBRARY v0.1
'(AMB library, geddit?)

'Written in QuickBASIC 4.5 for FreeDOS, 2021.

'Scans C: for AMB files and allow user to select one for reading.

'Requires the AMB reader and at least one AMB file to be installed.
'Well, it wouldn't be much use otherwise, would it?

'This version handles up to 128 AMB files by default. Should be enough for now,
'but otherwise just change the amblimit% variable below and recompile.

DECLARE SUB helpme ()
DECLARE SUB endthis ()
DECLARE SUB AmbScan ()
DECLARE SUB FillArray ()
DECLARE FUNCTION ScrollBox% (lim%, high%, wide%, LIN%, COL%)

'$STATIC

'Global string variables
COMMON SHARED tempdir$, tempfile$, ambdrive$
'Global arrays
COMMON SHARED filename$()
'Global numeric variables
COMMON SHARED amblimit%
IF INSTR(COMMAND$, "HELP") OR INSTR(COMMAND$, "/H") OR INSTR(COMMAND$, "/?") THEN helpme
amblimit% = 128
IF INSTR(COMMAND$, "256") THEN amblimit% = 256
IF INSTR(COMMAND$, "512") THEN amblimit% = 512
IF INSTR(COMMAND$, "1024") THEN amblimit% = 1024
DIM filename$(amblimit%)
ambdrive$ = "C:"
IF INSTR(COMMAND$, "D:") THEN ambdrive$ = "D:"
IF INSTR(COMMAND$, "E:") THEN ambdrive$ = "E:"
IF INSTR(COMMAND$, "F:") THEN ambdrive$ = "F:"
tempdir$ = ENVIRON$("TEMP")
tempfile$ = tempdir$ + "\ambrary.lst"
AmbScan     'any way to speed this up?
FillArray   'feed temp file into array
SCREEN 0
DO
    IF choice% <> 0 THEN
        SHELL "amb " + filename$(choice%)
        choice% = 0
    ELSE
        choice% = ScrollBox%(amblimit% + 1, 23, 76, 1, 1)
    END IF
LOOP
endthis

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

SUB endthis
    CLOSE
    END
END SUB

SUB FillArray
    tmp1% = FREEFILE
    filename$(0) = "*********** EXIT ***********"
    OPEN tempfile$ FOR INPUT AS #tmp1%
    FOR F = 1 TO amblimit%
        IF NOT EOF(tmp1%) THEN
            LINE INPUT #tmp1%, a$
            IF a$ <> "" THEN
                filename$(F) = a$
            END IF
        END IF
    NEXT F
    IF filename$(1) = "" THEN
        PRINT
        PRINT "No AMB files found on drive " + ambdrive$
        endthis
    END IF
    CLOSE #tmp1%
    KILL tempfile$
END SUB

SUB helpme
    PRINT "AMBRARY v0.1"
    PRINT "A simple launcher menu for your .AMB (Ancient Machine Book) files."
    PRINT
    PRINT "The command AMBRARY, with no further parameters, will scan your"
    PRINT "C drive and will display up to 128 of them to read in the AMB"
    PRINT "reader program."
    PRINT
    PRINT "If you keep your .AMB files elsewhere, you can start Ambrary with a"
    PRINT "a parameter indicating that. e.g. AMBRARY D: . E: and F: will also be"
    PRINT "accepted. If you give more than one, the highest one will be used."
    PRINT
    PRINT "You can also increase the number of books listed. Accepted values are"
    PRINT "256, 512 and 1024. Again, the highest number given is used."
    PRINT
    PRINT "AMBRARY D: 512 and AMBRARY 512 D: work exactly the same way."
    PRINT
    PRINT "AMBRARY /D: or AMBRARY --1024 or AMBRARY -F: /256 will all work,"
    PRINT "since these traditional parameter indicators are ignored."
    endthis
END SUB

FUNCTION ScrollBox% (lim%, high%, wide%, LIN%, COL%)
REM ===========================================================================
REM Author: Kurt Kuzba
REM I made it a FUNCTION, as opposed to a SUB, because it is also
REM useful for menus, and you can always just disregard the return
REM value.
REM
REM Adapted by Michel Claquin-Johnson for his own nefarious purposes
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
            PRINT LEFT$(filename$(top% + t%) + s$, wide%);
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
    IF sel% = 0 THEN endthis 'only way out of an endless loop. Yes, I know,
    ScrollBox% = sel%        'bad form to put it here and not in the main module.
END FUNCTION                 'So sue me.

