'AMBTITLE v0.2

'Written in QuickBASIC 4.5 for FreeDOS, 2021.

'Helper program for AMBRARY

'Scans C: for AMB files and extracts the title for each one.
'AMBRARY v0.2 and later will be able to pick up this title and
'display it instead of the path and filename

'Requires the AMBPACK utility and at least one AMB file to be installed.

DECLARE SUB HelpMe ()
DECLARE SUB EndThis ()
DECLARE SUB AmbScan ()
DECLARE SUB FillArrays ()
DECLARE SUB SaveFile ()

'$STATIC

'Global string variables
COMMON SHARED tempdir$, tempfile$, ambdrive$
'Global arrays
COMMON SHARED filename$(), title$()
'Global numeric variables
COMMON SHARED amblimit%
IF INSTR(COMMAND$, "HELP") OR INSTR(COMMAND$, "/H") OR INSTR(COMMAND$, "/?") THEN HelpMe
ambdrive$ = "C:"
IF INSTR(COMMAND$, "D:") THEN ambdrive$ = "D:"
IF INSTR(COMMAND$, "E:") THEN ambdrive$ = "E:"
IF INSTR(COMMAND$, "F:") THEN ambdrive$ = "F:"
tempdir$ = ENVIRON$("TEMP")
tempfile$ = tempdir$ + "\ambrary.lst"
AmbScan     'any way to speed this up?
FillArrays  'feed temp file into array
SaveFile    'save results to a file
EndThis

SUB AmbScan
    scanbat% = FREEFILE
    OPEN tempdir$ + "\rescan.bat" FOR OUTPUT AS #scanbat%
    PRINT #scanbat%, "@echo off"
    PRINT #scanbat%, "cls"
    PRINT #scanbat%, "echo."
    PRINT #scanbat%, "echo           *******************************"
    PRINT #scanbat%, "echo           ******** AMBTITLE scan ********"
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

SUB EndThis
    CLOSE
    END
END SUB

SUB FillArrays
    'remove leftovers
    SHELL "deltree /y " + tempdir$ + "\amb > NUL"
    'get number of items
    tmp1% = FREEFILE
    OPEN tempfile$ FOR INPUT AS #tmp1%
        f = 0
        DO
            LINE INPUT #tmp1%, a$
            f = f + 1
        LOOP UNTIL EOF(tmp1%)
    CLOSE #tmp1%
    'DIM arrays
    DIM filename$(f)
    DIM title$(f)
    tmp1% = FREEFILE
    OPEN tempfile$ FOR INPUT AS #tmp1%
        f = 1
        DO UNTIL EOF(tmp1%)
            LINE INPUT #tmp1%, a$
            IF a$ <> "" THEN
                filename$(f) = a$
                PRINT "Found " + a$
                PRINT "Extracting ..."
                SHELL "ambpack u " + a$ + " " + tempdir$ + "\amb > NUL"
                tmp2% = FREEFILE
                OPEN tempdir$ + "\amb\title" FOR INPUT AS #tmp2%
                LINE INPUT #tmp2%, c$
                title$(f) = LEFT$(c$, LEN(c$) - 1)'strip trailing LF
                PRINT "Title: " + c$
                CLOSE #tmp2%
                SHELL "deltree /y " + tempdir$ + "\amb > NUL"
                f = f + 1
            END IF
        LOOP
    IF filename$(1) = "" THEN
        PRINT
        PRINT "No AMB files found on drive " + ambdrive$
        EndThis
    END IF
    CLOSE #tmp1%
    KILL tempfile$
END SUB

SUB HelpMe
    PRINT "AMBTITLE v0.2"
    PRINT "A helper program for AMBRARY."
    PRINT
    PRINT "The command AMBTITLE, with no further parameters, will scan your"
    PRINT "C drive and extract the title of each book found. This information"
    PRINT "will be stored in a file that AMBRARY 0.2 or higher can read."
    PRINT
    PRINT "If you keep your .AMB files elsewhere, you can start AMBTITLE with a"
    PRINT "parameter indicating that. e.g. AMBTITLE D:. Drives E: and F: will"
    PRINT "also be accepted. If you give more than one, the highest one is used."
    PRINT
    PRINT "You only need to run this utility when you have added new AMB books"
    PRINT "to your collection or remove them."
    PRINT
    PRINT "AMBTITLE requires DELTREE, SORT, the AMBPACK utility and at least"
    PRINT "one AMB file to be installed."
    PRINT
    EndThis
END SUB

SUB SaveFile
    PRINT "Writing results to file ..."
    PRINT
    tmp1% = FREEFILE
    OPEN "c:\fdos\doc\ambtitle.tmp" FOR OUTPUT AS #tmp1%
    FOR f = 1 TO UBOUND(filename$)
        PRINT #tmp1%, title$(f) + CHR$(9) + filename$(f)
    NEXT f
    CLOSE #tmp1%
    PRINT "Sorting file ..."
    SHELL "sort /A c:\fdos\doc\ambtitle.tmp > c:\fdos\doc\ambtitle.db"
    KILL "c:\fdos\doc\ambtitle.tmp"
END SUB

