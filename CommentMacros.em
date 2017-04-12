//
// Published from https://github.com/wujingbo/Source-Insight-4.0-for-edk2
//
// Macros for editing EDK2 Language,
//
//   1. Comment Selected Lines (Alt+C)
//   2. Un-Comment Selected Lines (Alt+R)
//

//=============================================================================
// Debug only
//=============================================================================
function Debug (str)
{
    if (False) msg (str)
}

//=============================================================================
// Init Global Vars for comment string
//   Need sync. with GetCommentStringByLanguage() if support new language
//=============================================================================
function InitGlobalVars ()
{
    Debug ("Init. Global Vars for comment strings")

    global Language_ASL, Language_FDF, Language_INF
    global Language_DSC, Language_DEC, Language_VFR

    Language_ASL = "ACPI Source Language (ASL)"
    Language_FDF = "EDK II Flash Description File (FDF) Language"
    Language_INF = "EDK II Module Information (INF) Language"
    Language_DSC = "EDK II Platform Description (DSC) Language"
    Language_DEC = "EDK II Package Declaration (DEC) Language"
    Language_VFR = "EDK II Visual Forms Representation (VFR) Language"

    global Comment_DoubleSlash, Comment_Number

    Comment_DoubleSlash = "//"
    Comment_Number      = "#"
}

//=============================================================================
// Get Comment String By Language Type
//   Need sync. with InitGlobalVars() if support new language
//
// Parameters
//   hbuf - handle to file buffer, make sure not nil before call this function
//
// Return
//   RetString - Comment String with current language
//=============================================================================
function GetCommentStringByLanguage (hbuf)
{
    global BeInit
    var    RetString, Props

    if (BeInit == nil) {
        InitGlobalVars ()
        BeInit = True;
    }

    Props = GetBufProps(hbuf)

    if (Props.Language == Language_ASL ||
        Props.Language == Language_VFR) {

        RetString = Comment_DoubleSlash
    } else if (Props.Language == Language_FDF ||
               Props.Language == Language_INF ||
               Props.Language == Language_DSC ||
               Props.Language == Language_DEC) {

        RetString = Comment_Number
    } else {

        RetString = nil
    }

    return RetString
}

//=============================================================================
// Comment Selected Lines
//   Just set hotkey for this macro in Key Assignments.
//   This macro will call default comment lines if no matched language.
//=============================================================================
macro CommentSelectedLines ()
{
    Debug ("Comment Selected Line")

    var hbuf, hwnd
    var CommentStr, FirstLineNum, LastLineNum

    hbuf = GetCurrentBuf ()
    hwnd = GetCurrentWnd ()

    if (hbuf == nil || hwnd == nil) stop

    CommentStr = GetCommentStringByLanguage (hbuf)
    if (CommentStr == nil) {
        Comment_Lines  // Default comment lines command
        stop
    }

    //
    // Do customized comment lines as follow,
    //
    FirstLineNum = GetWndSelLnFirst (hwnd)
    LastLineNum  = GetWndSelLnLast (hwnd)

    Debug ("FirstLineNum = @FirstLineNum@, LastLineNum = @LastLineNum@")

    while (FirstLineNum <= LastLineNum) {
        PutBufLine (hbuf, FirstLineNum, CommentStr # GetBufLine (hbuf, FirstLineNum))
        FirstLineNum++
    }
}

//=============================================================================
// Un-Comment Selected Lines
//   Just set hotkey for this macro in Key Assignments.
//   This macro will call default un-comment lines if no matched language.
//=============================================================================
macro UnCommentSelectedLines()
{
    Debug ("Un-Comment Selected Line")

    var hbuf, hwnd
    var CommentStr, FirstLineNum, LastLineNum
    var CommentLength, CurrentLine, LineLength

    hbuf = GetCurrentBuf ()
    hwnd = GetCurrentWnd ()

    if (hbuf == nil || hwnd == nil) stop

    CommentStr = GetCommentStringByLanguage (hbuf)
    if (CommentStr == nil) {
        Un_Comment_Lines  // Default un-comment lines command
        stop
    }

    //
    // Do customized un-comment lines as follow,
    //
    FirstLineNum  = GetWndSelLnFirst (hwnd)
    LastLineNum   = GetWndSelLnLast (hwnd)
    CommentLength = strlen (CommentStr)

    while (FirstLineNum <= LastLineNum) {

        CurrentLine = GetBufLine (hbuf, FirstLineNum)
        LineLength  = strlen (CurrentLine)
        FirstLineNum++

        if (LineLength == 0) {
            continue
        } else if (CommentStr == strmid (CurrentLine, 0, CommentLength)) {
            PutBufLine (hbuf, FirstLineNum - 1, strmid (CurrentLine, CommentLength, LineLength))
        } else {
            continue
        }
    }
}

