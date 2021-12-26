## This module provides type definitions for all structured report entries
## that compiler can provide.
##
## Note that this module specifically does not import anything else from
## the compiler - by design it is supposed to be available in every other
## module (because almost any phase of the compiler can generate reports
## one way or another). By design report should contain as much information
## as possible and *never* be used for any conditional logic in the
## compiler - it is a final form of the output that can only be printed to
## the output (either via user-provided report hook implementation, or
## using one of the built-in ones)
##
## Not using compiler-specific types also allows this report to be easily
## reused by external tooling - custom error pretty-printers, test runners
## and so on.

import std/[options]

import ast_types, nilcheck_enums, int128

export
  ast_types,
  options.some,
  options.none,
  options.Option,
  int128.toInt128

type InstantiationInfo* = typeof(instantiationInfo())

const emptyReportId* = ReportId(0)

type
  ReportCategory* = enum
    ## Kinds of the toplevel reports. Only dispatches on report topics,
    ## such as sem, parse, macro (for `echo` in compile-time code) and so
    ## on. Subdivision is based on different phases of the compiler
    ## operation, and not on report's state itself, as those are completely
    ## orthogonal to each other (lexer might provide errors and hints,
    ## parser can provide errors, hints and warnings)

    repParser
    repLexer ## Report generated by lexer - bad tokens, lines that are too
    ## long etc.

    repSem ## Report produced directly by semantic analysis - compilation
    ## errors, warnings and hints

    repCmd ## Report related to execution of the external command - start
    ## of the command, execution failure, succes and so on.

    repDebug ## Side channel for the compiler debug report. Sem expansion
    ## traces and other helper messages designed specifically to aid
    ## development of the compiler

    repInternal ## Reports constructed during hanling of the internal
    ## compilation errors. Separate from debugging reports since they
    ## always exist - ICE, internal fatal errors etc.

    repBackend ## Backend-specific reports.

    repExternal ## Report constructed during handling of the external
    ## configuration, command-line flags, packages, modules.


  ReportKind* = enum
    ## Toplevel enum for different categories. Order of definitions is
    ## really important - elements are first separated into categories
    ## (internal reports, backend reports and so on) and can be further
    ## split into severity levels.
    ##
    ## Different naming scheme is used for a reports with different
    ## categories - this enum exists only to make it easier to work with
    ## different report kinds, without having to manage seven different
    ## enum types.

    repNone

    #--------------------------  Internal reports  ---------------------------#
    # Internal reports being
    # fatal errors begin
    rintUnknown ## Unknown internal report kind
    rintFatal ## Explicitly fatal compiler error
    rintIce ## Internal compilation error
    # fatal end

    rintCannotOpenFile
    rintWarnCannotOpenFile
    rintWarnFileChanged
    rintNotImplemented
    rintStackTrace = "StackTrace" ## Stack trace during internal
    ## compilation error handling and similar
    rintMissingStackTrace ## Stack trace would've been generated in the
    ## debug compiler build
    rintGCStats = "GCStats" ## Print GC statistics for the compiler run
    rintQuitCalled = "QuitCalled" ## `quit()` called by the macro code

    rintUnreachable ## State in the compiler code that must not be reached
    rintAssert ## Failed internal assert in the compiler
    rintSource = "Source" ## Show source in the report
                          # REFACTOR this is a global configuration option,
                          # not a hint.
    rintSuccessX ## Succesfull compilation
    # internal reports end

    #--------------------------  External reports  ---------------------------#
    # External reports
    rextUnknownCCompiler

    # malformed cmdline parameters begin
    rextInvalidHint
    rextInvalidWarning
    rextInvalidCommandLineOption ## Invalid command-line option passed to
                                 ## the compiler
    rextOnlyAllOffSupported ## Only `all:off` is supported for mass
    ## hint/warning modification. Separate diagnostics must be enabled on
    ## one-by-one basis.
    rextExpectedOnOrOff ## Command-line option expected 'on' or 'off' value
    rextExpectedOnOrOffOrList ## Command-line option expected 'on', 'off'
    ## or 'list' value.
    rextExpectedCmdArgument ## Command-line option expected argument
    rextExpectedNoCmdArgument ## Command-line option expected no arguments
    rextInvalidNumber ## Command-line switch expected a number
    rextInvalidValue
    rextUnexpectedValue ## Command-line argument had value, but it did not
    ## match with any expected.
    rextInvalidPath ## Invalid path for a command-line argument
    # end

    rextInvalidPackageName ## When adding packages from the `--nimbleDir`
    ## (or it's default value), names are validated. This error is
    ## generated if package name is not correct.

    rextDeprecated ## Report about use of the deprecated feature that is
    ## not in the semantic pass. Things like deprecated flags, compiler
    ## commands and so on.


    rextConf = "Conf" ## Processing user configutation file
    rextPath = "Path" ## Add nimble path


    # external reports end

    #----------------------------  Lexer reports  ----------------------------#
    # Lexer report begin
    # errors begin
    rlexMalformedUnderscores
    rlexMalformedTrailingUnderscre
    rlexInvalidToken
    rlexNoTabs

    # numbers
    rlexInvalidIntegerPrefix
    rlexInvalidIntegerSuffix
    rlexNumberNotInRange
    rlexExpectedHex
    rlexInvalidIntegerLiteral

    # char
    rlexInvalidCharLiteral
    rlexMissingClosingApostrophe
    rlexInvalidUnicodeCodepoint

    # string
    rlexUnclosedTripleString
    rlexUnclosedSingleString

    # comments
    rlexUnclosedComment

    # errors end

    # warnings begin
    rlexDeprecatedOctalPrefix
    rlexLinterReport
    # warnings end

    # hints begin
    rlexLineTooLong

    rlexSyntaxesCode
    # hints end

    # Lexer report end

    #---------------------------  Parser reports  ----------------------------#
    # errors begin
    # regular nim parser
    rparInvalidIndentation
    rparNestableRequiresIndentation

    rparIdentExpected
    rparIdentOrKwdExpected
    rparExprExpected
    rparMissingToken
    rparUnexpectedToken
    rparUnexpectedTokenKind

    rparFuncNotAllowed
    rparTupleTypeWithPar
    rparMisplacedParameterVar
    rparConceptNotinType
    rparRotineExpected
    rparPragmaAlreadyPresent
    rparMisplacedExport

    # template parser `filter_tmpl.nim`
    rparTemplMissingEndClose
    rparTemplInvalidExpression

    rparInvalidFilter

    # erorrs end

    # warnings begin
    rparInconsistentSpacing
    rparEnablePreviewDotOps
    rparPragmaNotFollowingTypeName
    rparPragmaBeforeGenericParameters
    # warnings end

    rparName = "Name" ## Linter report about used identifier

    #-----------------------------  Sem reports  -----------------------------#
    # semantic fatal
    rsemFatalError
    # end

    # Semantic errors begin
    rsemUserError = "UserError" ## `{.error: }`
    rsemUsageIsError

    rsemCustomError
    rsemCustomPrintMsgAndNodeError
      ## just like custom error, prints a message and renders wrongNode
    rsemTypeMismatch
    rsemTypeKindMismatch
    rsemAmbiguous

    rsemCustomUserError
      ## just like customer error, but reported as a errUser in msgs

    rsemNodeNotAllowed
      ## Generated in `filters.nim`

    rsemCannotProveNotNil
    rsemProvablyNil

    # Global Errors
    rsemCustomGlobalError
      ## just like custom error, but treat it like a "raise" and fast track the
      ## "graceful" abort of this compilation run, used by `errorreporting` to
      ## bridge into the existing `msgs.liMessage` and `msgs.handleError`.

    # Module errors
    rsemSystemNeeds
    rsemInvalidModulePath
    rsemCannotImportItself
    rsemRecursiveInclude
    rsemCannotOpenFile
    rsemExportRequiresToplevel
    rsemInvalidVisibility

    # ..
    rsemConflictingExportnims
    rsemNoMagicEqualsForType
    rsemCantConvertLiteralToType
    rsemCantConvertLiteralToRange
    rsemCantComputeOffsetof
    rsemStaticOutOfBounds ## Error generated when semfold or static bound
    ## checking sees and out-of-bounds index error.
    rsemStaticFieldNotFound # TODO DOC generated in `semfold.nim`, need
    # better documentation, right now I don't know what exactly this error
    # means and how to reproduce it in the example code.
    rsemSemfoldOverflow
    rsemSemfoldDivByZero
    rsemSemfoldInvalidConversion
    rsemInvalidIntdefine
    rsemInvalidBooldefine


    # Type definitions
    rsemCaseInUnion ## `{.union.}` type cannot use `case:` statements
    rsemOffsetInUnion ## `{.union.}` type cannot use inheritance and any
    ## other features that add implicit chunk of data before the actually
    ## listed fields.
    rsemUnexpectedInNewConcept
    rsemTooNestedConcept
    rsemIllegalRecursion
    rsemCannotInferStaticValue

    rsemVarVarNotAllowed ## `var lent`, `var var` etc. are not allowed in
    ## types
    rsemInvalidOrderInEnum
    rsemSetTooBig
    rsemTIsNotAConcreteType
    rsemRangeIsEmpty

    rsemCannotInstantiate
    rsemCannotInstantiateWithParameter
    rsemCannotGenerateGenericDestructor
    rsemUndeclaredField
    rsemInheritanceOnlyWorksWithAnEnum # I have **//ABSOLUTELY NO IDEA//**
    # what this error means. I think I might need to add something like
    # `rsemWTF`
    rsemExpectedOrdinal
    rsemExpectedOrdinalOrFloat
    rsemExpectedUnholyEnum # yes
    rsemExpectedLow0Discriminant
    rsemExpectedHighCappedDiscriminant
    rsemUnreachableElse
    rsemMissingCaseBranches
    rsemRangeDoesNotSupportNan
    rsemRangeRequiresDotDot
    rsemExpectedRange
    rsemArrayExpectsPositiveRange
    rsemExpectObjectForBase
    rsemExpectNonFinalForBase

    rsemTVoidNotAllowed
    rsemExpectedObjectForRegion
    rsemMacroBodyDependsOnGenericTypes
    rsemMalformedNotNilType
    rsemEnableNotNilExperimental
    rsemExpectedObjectType
    rsemExpectedImportedType

    # Procedure definition and instantiation
    rsemImplementationNotAllowed
    rsemImplementationExpected
    rsemRedefinitionOf
    rsemDefaultParamIsIncompatible
    rsemDeclarationVisibilityMismatch

    # Call and procedures
    rsemCallTypeMismatch
    rsemCallNotAProcOrField
    rsemExpressionCannotBeCalled
    rsemWrongNumberOfArguments
    rsemWrongNumberOfVariables
    rsemWrongNumberOfGenericParams
    rsemNoGenericParamsAllowed
    rsemAmbiguousCall
    rsemCallingConventionMismatch
    rsemHasSideEffects
    rsemCanHaveSideEffects
    rsemCantPassProcvar
    rsemUnlistedRaises
    rsemOverrideSafetyMismatch
    rsemOverrideLockMismatch
    rsemMissingMethodDispatcher
    rsemNotABaseMethod
    rsemIllegalCallconvCapture
    rsemIllegalMemoryCapture
    rsemIgnoreInvalidForLoop
    rsemMissingGenericParamsForTemplate
    rsemMisplacedMagicType
    rsemCannotInferParameterType
    rsemParameterRequiresAType
    rsemParameterRedefinition
    rsemInvalidExpression
    rsemExpectedNonemptyPattern

    rsemTemplateInstantiationTooNested
    rsemMacroInstantiationTooNested
    rsemGenericInstantiationTooNested # TODO write out list of generic,
    # macro or template instantiations. There is a `pushOwner` called for
    # each generic instantiation - can this be reused?

    rsemCannotSpawnProcWithVar
    rsemCannotSpawnMagicProc
    rsemCannotDiscardSpawn
    rsemSpawnRequiresCall
    rsemSpawnRequiresGcSafe
    rsemSpawnForbidsClosure
    rsemSpawnForbidsIterator

    rsemInvalidMethodDeclarationOrder # Right now I have no idea what this
    # error means exactly. It /does/ have a 'sort of' reproducible example
    # - https://github.com/nim-lang/Nim/issues/5325. No real tests for this
    # one of course, I mean who needs this, right?
    rsemIsNotParameterOf
    rsemParameterNotPointerToPartial


    # Identifier Lookup
    rsemUndeclaredIdentifier
    rsemExpectedIdentifier
    rsemExpectedIdentifierInExpr

    # Object and Object Construction
    rsemFieldNotAccessible
      ## object field is not accessible
    rsemFieldAssignmentInvalid
      ## object field assignment invalid syntax
    rsemFieldOkButAssignedValueInvalid
      ## object field assignment, where the field name is ok, but value is not
    rsemObjectConstructorIncorrect
      ## one or more issues encountered with object constructor

    # General Type Checks
    rsemExpressionHasNoType
      ## an expression has not type or is ambiguous

    rsemRawTypeMismatch

    rsemCannotConvertTypes
    rsemUnresolvedGenericParameter
    rsemCannotCreateFlowVarOfType
    rsemTypeNotAllowed

    # Literals
    rsemIntLiteralExpected
      ## int literal node was expected, but got something else
    rsemStringLiteralExpected
      ## string literal node was expected, but got something else

    rsemOnOrOffExpected
    rsemCallconvExpected
    rsemInnerCodeReordering
    rsemUnknownExperimental
    rsemDuplicateCaseLabel

    # view types
    rsemExpressionIsNotAPath
    rsemResultMustBorrowFirst
    rsemCannotDetermineBorrowTarget # TODO DOC need better explanation for
    # reasons of this error, right now it looks like a hacked-in check.
    rsemCannotBorrow
    rsemBorrowOutlivesSource
    rsemImmutableBorrowMutation

    # VM
    rsemTooManyRegistersRequired
    rsemVmCannotFindBreakTarget
    rsemVmNotUnused
    rsemNotAFieldSymbol
    rsemVmTooLargetOffset
    rsemVmCannotGenerateCode
    rsemVmCannotCast
    rsemVmInvalidBindSym
    rsemVmBadExpandToAst
    rsemVmCannotEvaluateAtComptime
    rsemVmCannotImportc
    rsemVmEnableFFIToImportc
    rsemVmCannotCreateNullElement
    rsemVmInvalidObjectConstructor
    rsemVmNoClosureIterators
    rsemVmCannotCallMethod
    rsemVmCallingNonRoutine

    rsemVmStackTrace
    rsemTooManyIterations

    rsemMissingImportcCompleteStruct

    rsemCyclicTree
    rsemCyclicDependency
    rsemConstExprExpected

    # Pragma
    rsemInvalidPragma
      ## suplied pragma is invalid
    rsemCannotAttachPragma
    rsemUnexpectedPragma
    rsemPropositionExpected
    rsemIllegalCustomPragma
      ## supplied pragma is not a legal custom pragma, and cannot be attached
    rsemNoReturnHasReturn
      ## a routine marked as no return, has a return type
    rsemImplicitPragmaError
      ## a symbol encountered an error when processing implicit pragmas, this
      ## should be applied to symbols and treated as a wrapper for the purposes
      ## of reporting. the original symbol is stored as the first argument
    rsemPragmaDynlibRequiresExportc
      ## much the same as `ImplicitPragmaError`, except it's a special case
      ## where dynlib pragma requires an importc pragma to exist on the same
      ## symbol
      ## xxx: pragmas shouldn't require each other, that's just bad design

    rsemWrappedError
      ## there is no meaningful error to construct, but there is an error
      ## further down the AST that invalidates the whole

    rsemSymbolKindMismatch
    rsemIllformedAst
    rsemInitHereNotAllowed
    rsemIdentExpected
    rsemTypeExpected
    rsemTypeInvalid
    rsemWrongIdent
    rsemPragmaOptionExpected
    rsemUnexpectedPushArgument
    rsemCannotPushCast
    rsemCastRequiresStatement
    rsemExportcppRequiresCpp
    rsemDynlibRequiresExportc
    rsemImportjsRequiresJs
    rsemImportjsRequiresPattern
    rsemBitsizeRequires1248
    rsemBitsizeRequiresPositive
    rsemAlignRequiresPowerOfTwo
    rsemPragmaRecursiveDependency
    rsemMisplacedDeprecation
    rsemNoUnionForJs

    rsemThisPragmaRequires01Args
    rsemMisplacedExperimental
    rsemMismatchedPopPush
    rsemExcessiveCompilePragmaArgs
    rsemLinePragmaExpectsTuple
    rsemRaisesPragmaExpectsObject

    # -- locking
    rsemLocksPragmaExpectsList
    rsemLocksPragmaBadLevel
    rsemLocksRequiresArgs
    rsemMultilockRequiresSameLevel
    rsemInvalidNestedLocking
    rsemUnguardedAccess
    rsemInvalidGuardField
    rsemLockLevelMismatch

    rsemDrNimRequiresUsesMissingResult
    rsemDrnimCannotProveLeq
    rsemDrnimCannotPorveGe

    rsemBorrowPragmaNonDot
    rsemInvalidExtern
    rsemInvalidPragmaBlock
    rsemBadDeprecatedArgs
    rsemMisplacedEffectsOf
    rsemMissingPragmaArg
    rsemErrGcUnsafe
    rsemEmptyAsm


    # end

    # Semantic warnings begin
    rsemUserWarning = "UserWarning" ## `{.warning: }`
    rsemUnknownMagic = "UnknownMagic"
    rsemDeprecated
    rsemDotForModuleImport
    rsemReorderingFail
    rsemProveField
    rsemStrictNotNil
    rsemWarnGcUnsafe
    rsemGcUnsafeListing
    rsemProveInit
    rsemUninit
    rsemWarnUnsafeCode
    rsemImplicitCstringConvert
    rsemHoleEnumConvert
    rsemAnyEnumConvert
    rsemUnusedRaises
    rsemMethodLockMismatch
    rsemUseBase
    rsemInheritFromException
    rsemPtrRegionIsDeprecated
    rsemTypedReturnDeprecated


    rsemLinterReport
    # end

    # Semantic hints begin
    rsemUserHint = "UserHint" ## `{.hint: .}` pragma encountereed
    rsemXDeclaredButNotUsed = "XDeclaredButNotUsed"
    rsemDuplicateModuleImport = "DuplicateModuleImport"
    rsemXCannotRaiseY = "XCannotRaiseY"
    rsemConvToBaseNotNeeded = "ConvToBaseNotNeeded"
    rsemConvFromXtoItselfNotNeeded = "ConvFromXtoItselfNotNeeded"

    rsemProcessing = "Processing" ## Processing module
    rsemProcessingStmt = "ProcessingStmt" ## Processing toplevel statement

    rsemExprAlwaysX = "ExprAlwaysX" ## Expression always evaluates to "X"
    rsemConditionAlwaysTrue = "CondTrue" ## Condition is always true
    rsemConditionAlwaysFalse = "CondFalse" ## Condition is always false

    rsemPattern = "Pattern" ## Term rewriting pattern has been triggered
    rsemCannotMakeSink ## Argument could not be turned into a sink
                       ## parameter. Generated once in the whole compiler
                       ## `sinkparameter_inference.nim`
    rsemCopiesToSink ## Passing data to the `sink` parameter still copies
                     ## due to control flow in the code

    hintGlobalVar = "GlobalVar" ## Track global variable declarations?

    rsemEffectsListingHint
    rsemExpandMacro = "ExpandMacro" ## Trace macro expansion progress


    rsemNonMatchingCandidates
    rsemUserRaw = "UserRaw" # REVIEW - Used in
    # `semcall.semOverloadedCall()` and `extccomp.getCompileCFileCmd()`.
    # Seems like this one should be removed, it spans multiple compiler
    # subsystems. Can't understand what it is doing.

    rsemExtendedContext = "ExtendedContext" ## Extended contextual
    ## information. Used in `ccgstmts.genStmts()` and
    ## `semexprs.semExprNoType()`
    rsemImplicitObjConv = "ImplicitObjConv"
    # end

    #------------------------  Command report kinds  -------------------------#
    rcmdExecuting
    rcmdFailedExecution
    rcmdCC

    #----------------------------  Debug reports  ----------------------------#
    rdbgTest

    #---------------------------  Backend reports  ---------------------------#
    # errors start
    rbackCannotWriteScript ## Cannot write build script to a cache file
    rbackCannotWriteMappingFile ## Canot write module compilation mapping
    ## file to cache directory
    rbackTargetNotSupported ## C compiler does not support requested target
    rbackJsonScriptMismatch # ??? used in `extccomp.nim`, TODO figure out
    # what the original mesage was responsible for exactly
    rbackCannotProduceAssembly
    # errors end

    # hints start
    rbackProducedAssembly

    rbackLinking
    rbackCompilingExtraFile ## Compiling file specified in the
    ## `{.compile:.}` pragma


    rbackUseDynLib ## Use of the dynamic library for cgen. Used in the
    ## `cgen.loadDynamicLib`
    # hints end

  ReportKinds* = set[ReportKind]

static:
  echo(
    "Nimskull compiler outputs ",
    ord(high(ReportKind)),
    " different kinds of diagnostics")

type
  ReportLineRange* = object
    ## Report location expressed as a span of lines in the file
    file*: FileIndex
    startLine*, endline*: int
    startCol*, endCol*: int

  ReportLinePoint* = object
    ## Location expressed in terms of a single point in the file
    file*: string
    line*, col*: int

  ReportLineInfo* = object
    case isRange*: bool
      of true:
        lrange*: ReportLineRange

      of false:
        lpoint*: ReportLinePoint

  ReportSeverity* = enum
    rsevDebug ## Internal compiler debug information

    rsevHint ## User-targeted hint
    rsevWarning ## User-targeted warnings
    rsevError ## User-targeted error

    rsevFatal
    rsevTrace ## Additional information about compiler actions - external
              ## commands mostly.

  ReportContextKind* = enum
    sckInstantiationOf
    sckInstantiationFrom


  ReportContext* = object
    location*: ReportLinePoint
    case kind*: ReportContextKind
      of sckInstantiationOf:
        entry*: PSym

      of sckInstantiationFrom:
        discard

  ReportBase* = object of RootObj
    context*: seq[ReportContext]

    location*: Option[ReportLineInfo] ## Location associated with report.
    ## Some reports do not have any locations associated with them (most
    ## (but not all, due to `gorge`) of the external command executions,
    ## sem tracing etc). Some reports might have additional associated
    ## location information (view type sealing reasons) - those are handled
    ## on the per-report-kind basis.

    reportInst*: ReportLinePoint ## Information about instantiation location
    ## of the reports - present for all reports in order to track their
    ## origins.

type
  LexerReportKind* = range[rlexMalformedUnderscores .. rlexSyntaxesCode]
  LexerReport* = object of ReportBase
    msg*: string
    case kind*: ReportKind
      of rlexLinterReport:
        wanted*: string
        got*: string

      else:
        discard


const
  rlexHintKinds*: set[LexerReportKind] = {rlexLineTooLong}

func severity*(rep: LexerReport): ReportSeverity =
  case rep.kind:
    of rlexHintKinds: rsevHint
    else: rsevTrace

type
  ParserReportKind* = range[rparInvalidIndentation .. rparName]
  ParserReport* = object of ReportBase
    msg*: string
    found*: string
    case kind*: ReportKind
      of rparIdentExpected .. rparUnexpectedToken:
        expected*: seq[string]

      of rparInvalidFilter:
        node*: PNode

      else:
        discard



const
  rparHintKinds* = {rparName}
  rparErrorKinds* = {rparInvalidIndentation}

func severity*(parser: ParserReport): ReportSeverity =
  case parser.kind:
    of rparHintKinds: rsevHint
    else: rsevTrace

type
  SemReportKind* = range[rsemUserError .. rsemImplicitObjConv]
  SemReportErrorKind* = range[rsemUserError .. rsemWrappedError]

  SemGcUnsafetyKind* = enum
    sgcuCallsUnsafe
    sgcuAccessesGcGlobal
    sgcuIndirectCallVia
    sgcuIndirectCallHere

  SemSideEffectCallKind* = enum
    ssefUsesGlobalState
    ssefCallsSideEffect
    ssefCallsViaHiddenIndirection
    ssefCallsViaIndirection
    ssefParameterMutation

  SemTypeMismatch* = object
    wantedTypeKind*: set[TTypeKind]
    actualType*, wantedType*: PType
    descriptionStr*: string
    procEffectsCompat*: EffectsCompat
    procCallMismatch*: set[ProcConvMismatch]

  SemCallMismatch* = object
    ## Description of the single candidate mismatch. This type is later
    ## used to construct meaningful type mismatch message, and must contain
    ## all the necessary information to provide meaningful sorting,
    ## collapse and other operations.
    target*: PSym
    expression*: PNode
    arg*: int
    case kind*: MismatchKind
      of kTypeMismatch:
        typeMismatch*: SemTypeMismatch

      of kPositionalAlreadyGiven, kUnknownNamedParam,
         kAlreadyGiven, kMissingParam:
        nameParam*: string

      else:
        discard


  SemReport* = object of ReportBase
    expression*: PNode
    expressionStr*: string ## In some cases error reporting is done deep
    ## enough after processing and only string version of the expression
    ## might be generated. Most prominent example is a `.booldefine.` and
    ## `.intdefine.` error generation.
    rtype*: PType
    psym*: PSym
    msg*: string
    case kind*: ReportKind
      of rsemDuplicateModuleImport:
        previous*: ReportLinePoint

      of rsemDuplicateCaseLabel:
        overlappingGroup*: PNode

      of rsemCannotBorrow:
        borrowPair*: tuple[mutatedHere, connectedVia: ReportLinePoint]

      of rsemBorrowOutlivesSource,
         rsemImmutableBorrowMutation,
         rsemOverrideSafetyMismatch,
         rsemOverrideLockMismatch:
        borrowsFrom*: PSym

      of rsemXCannotRaiseY:
        raisesList*: PNode

      of rsemMissingCaseBranches:
        missingBranches*: seq[PNode]

      of rsemStrictNotNil:
        nilIssue*: Nilability
        nilHistory*: seq[tuple[
          node: PNode,
          nilability: Nilability,
          info: ReportLinePoint,
          transition: NilTransition
        ]]

      of rsemGcUnsafeListing:
        gcUnsafeTrace*: seq[tuple[
          isUnsafe: PSym,
          unsafeVia: PSym,
          unsafeRelation: SemGcUnsafetyKind,
          location: ReportLinePoint
        ]]

      of rsemHasSideEffects:
        sideEffectTrace*: seq[tuple[
          isUnsafe: PSym,
          unsafeVia: PSym,
          trace: SemSideEffectCallKind,
          location: ReportLinePoint
        ]]

        sideEffectMutateConnection*: ReportLinePoint

      of rsemVmStackTrace:
        traceReason*: ReportKind
        stacktrace*: seq[tuple[
          sym: PSym,
          location: ReportLinePoint
        ]]

      of rsemWrongNumberOfArguments,
         rsemWrongNumberOfGenericParams,
         rsemInvalidOrderInEnum,
         rsemSetTooBig,
         rsemArrayExpectsPositiveRange,
         rsemExpectedLow0Discriminant,
         rsemExpectedHighCappedDiscriminant:
        countMismatch*: tuple[expected, got: Int128]


      of rsemInvalidExtern:
        externName*: string

      of rsemWrongIdent:
        expectedIdents*: seq[string]

      of rsemDrnimCannotProveLeq, rsemDrnimCannotPorveGe:
        drnimExpressions*: tuple[a, b: PNode]

      of rsemUndeclaredIdentifier:
        wantedIdent*: string
        potentiallyRecursive*: bool

      of rsemAmbiguous, rsemCallNotAProcOrField:
        candidates*: seq[PSym]

      of rsemExpandMacro, rsemPattern:
        expandedExpr*: PNode

      of rsemLockLevelMismatch, rsemMethodLockMismatch:
        anotherMethod*: PSym
        lockMismatch*: tuple[expected, got: string]

      of rsemTypeMismatch,
         rsemTypeKindMismatch,
         rsemSemfoldInvalidConversion,
         rsemCannotConvertTypes,
         rsemImplicitObjConv,
         rsemVmCannotCast,
         rsemCannotInstantiateWithParameter
           :
        typeMismatch*: seq[SemTypeMismatch]

      of rsemSymbolKindMismatch:
        expectedSymbolKind*: set[TSymKind]

      of rsemTypeNotAllowed:
        allowedType*: tuple[
          allowed: PType,
          actual: PType,
          kind: TSymKind,
          allowedFlags: TTypeAllowedFlags
        ]

      of rsemIllegalCallconvCapture, rsemIllegalMemoryCapture:
        captured*: PSym

      of rsemDeprecated, rsemRedefinitionOf,
         rsemInvalidMethodDeclarationOrder:
        alternative*: PSym

      of rsemCallTypeMismatch, rsemNonMatchingCandidates:
        callMismatches*: seq[SemCallMismatch] ## Description of all the
        ## failed candidates.

      of rsemStaticOutOfBounds:
        indexSpec*: tuple[maxIdx, usedIdx: int64]



      of rsemProcessing:
        processing*: tuple[
          isNimscript: bool,
          importStackLen: int,
          fromModule: string,
          isToplevel: bool,
          moduleStatus, path: string
        ]

      of rsemSystemNeeds, rsemStaticFieldNotFound:
        missingSymbol*: string

      of rsemConflictingExportnims:
        conflictingExports*: (PSym, PSym)

      of rsemLinterReport:
        linterFail*: tuple[wanted, got: string]

      else:
        discard

const
  rsemErrorKinds* = {rsemUserError .. rsemWrappedError}
  rsemWarningKinds* = {rsemUserWarning .. rsemUnknownMagic}
  rsemHintKinds* = {rsemUserHint .. rsemImplicitObjConv}

func severity*(report: SemReport): ReportSeverity =
  case report.kind:
    of rsemErrorKinds: result = rsevError
    of rsemWarningKinds: result = rsevWarning
    of rsemHintKinds: result = rsevHint
    else: assert false

type
  CmdReportKind* = range[rcmdExecuting .. rcmdFailedExecution]
  CmdReport* = object of ReportBase
    cmd*: string
    msg*: string
    code*: int
    case kind*: ReportKind
      of rcmdFailedExecution:
        exitOut*, exitErr*: string

      of rcmdCC:
        packageName*: string

      else:
        discard

func severity*(report: CmdReport): ReportSeverity =
  rsevTrace

type
  DebugReportKind* = range[rdbgTest .. rdbgTest]

  DebugReport* = object of ReportBase
    kind*: ReportKind

func severity*(report: DebugReport): ReportSeverity =
  rsevDebug

type
  BackendReportKind* = range[rbackCannotWriteScript .. rbackUseDynLib]
  BackendReport* = object of ReportBase
    usedCompiler*: string
    case kind*: ReportKind
      of rbackCannotWriteScript,
         rbackProducedAssembly,
         rbackCannotWriteMappingFile:
        filename*: string

      of rbackTargetNotSupported:
        requestedTarget*: string

      of rbackJsonScriptMismatch:
        jsonScriptParams*: tuple[
          outputCurrent, output, jsonFile: string]

      else:
        discard

const
  rbackErrorKinds* = {rbackCannotWriteScript}

func severity*(report: BackendReport): ReportSeverity =
  case report.kind:
    of rbackErrorKinds: rsevError
    else: rsevTrace

type
  ExternalReportKind* = range[rextUnknownCCompiler .. rextPath]
  ExternalReport* = object of ReportBase
    ## Report about external environment reads, passed configuration
    ## options etc.
    case kind*: ReportKind
      of rextInvalidHint .. rextInvalidPath:
        cmdlineSwitch*: string ## Switch in processing
        cmdlineProvided*: string ## Value passed to the command-line
        cmdlineAllowed*: seq[string] ## Allowed command-line values
        cmdlineError*: string ## Textual description of the cmdline failure

      of rextUnknownCCompiler:
        knownCompilers*: seq[string]
        passedCompiler*: string

      of rextDeprecated:
        msg*: string

      of rextInvalidPackageName:
        packageName*: string

      of rextPath:
        packagePath*: string

      else:
        discard


func severity*(report: ExternalReport): ReportSeverity =
  rsevTrace

type
  InternalReportKind* = range[rintUnknown .. rintSuccessX]

  UsedBuildParams* = object
    project*: string
    output*: string
    mem*: int
    isMaxMem*: bool
    sec*: float
    case isCompilation*: bool
      of true:
        threads*: bool
        backend*: string
        buildMode*: string
        optimize*: string
        gc*: string

      of false:
        discard

  InternalReport* = object of ReportBase
    ## Report generated for the internal compiler workings
    msg*: string
    case kind*: ReportKind
      of rintStackTrace:
        trace*: seq[StackTraceEntry] ## Generated stack trace entries

      of rintAssert:
        expression*: string

      of rintSuccessX:
        buildParams*: UsedBuildParams

      of rintCannotOpenFile .. rintWarnFileChanged:
        file*: string

      else:
        discard

const
  rintFatalKinds*: set[InternalReportKind] = {rintUnknown .. rintIce} ## Fatal internal compilation reports

func severity*(report: InternalReport): ReportSeverity =
  case report.kind:
    of rintFatalKinds: rsevFatal
    else: rsevTrace

const
  repWarnings*: ReportKinds = rsemWarningKinds # IMPLEMENT add missing
  # report kinds for all other cateogires.
  repHints*: ReportKinds    = rsemHintKinds
  repErrors*: ReportKinds   = rsemErrorKinds + rparErrorKinds


type
  ReportTypes* =
    LexerReport    |
    ParserReport   |
    SemReport      |
    CmdReport      |
    DebugReport    |
    InternalReport |
    BackendReport  |
    ExternalReport

  Report* = object
    ## Toplevel wrapper type for the compiler report
    case category*: ReportCategory
      of repLexer:
        lexReport*: LexerReport

      of repParser:
        parserReport*: ParserReport

      of repSem:
        semReport*: SemReport

      of repCmd:
        cmdReport*: CmdReport

      of repDebug:
        debugReport*: DebugReport

      of repInternal:
        internalReport*: InternalReport

      of repBackend:
        backendReport*: BackendReport

      of repExternal:
        externalReport*: ExternalReport

func kind*(report: Report): ReportKind =
  case report.category:
    of repLexer:    report.lexReport.kind
    of repParser:   report.parserReport.kind
    of repCmd:      report.cmdReport.kind
    of repSem:      report.semReport.kind
    of repDebug:    report.debugReport.kind
    of repInternal: report.internalReport.kind
    of repBackend:  report.backendReport.kind
    of repExternal: report.externalReport.kind

func severity*(
    report: Report,
    asError: ReportKinds = default(ReportKinds),
    asWarning: ReportKinds = default(ReportKinds)
  ): ReportSeverity =
  ## Return report severity accounting for 'asError' and 'asWarning'
  ## mapping sets.

  if report.kind in asError: rsevError
  elif report.kind in asWarning: rsevWarning
  else:
    case report.category:
      of repLexer:    report.lexReport.severity()
      of repParser:   report.parserReport.severity()
      of repSem:      report.semReport.severity()
      of repCmd:      report.cmdReport.severity()
      of repInternal: report.internalReport.severity()
      of repBackend:  report.backendReport.severity()
      of repDebug:    report.debugReport.severity()
      of repExternal: report.externalReport.severity()

func toReportLinePoint*(iinfo: InstantiationInfo): ReportLinePoint =
  ReportLinePoint(file: iinfo[0], line: iinfo[1], col: iinfo[2])

template reportHere*[R: ReportTypes](report: R): R =
  block:
    var tmp = report
    tmp.reportInsta = toReportLinePoint(
      instantiationInfo(fullPaths = true))

    tmp

func wrap*(rep: sink LexerReport): Report =
  assert rep.kind in {low(LexerReportKind) .. high(LexerReportKind)}
  Report(category: repLexer, lexReport: rep)

func wrap*(rep: sink ParserReport): Report =
  assert rep.kind in {low(ParserReportKind) .. high(ParserReportKind)}
  Report(category: repParser, parserReport: rep)

func wrap*(rep: sink SemReport): Report =
  assert rep.kind in {low(SemReportKind) .. high(SemReportKind)}
  Report(category: repSem, semReport: rep)

func wrap*(rep: sink BackendReport): Report =
  assert rep.kind in {low(BackendReportKind) .. high(BackendReportKind)}
  Report(category: repBackend, backendReport: rep)

func wrap*(rep: sink CmdReport): Report =
  assert rep.kind in {low(CmdReportKind) .. high(CmdReportKind)}
  Report(category: repCmd, cmdReport: rep)

func wrap*(rep: sink DebugReport): Report =
  assert rep.kind in {low(DebugReportKind) .. high(DebugReportKind)}
  Report(category: repDebug, debugreport: rep)

func wrap*(rep: sink InternalReport): Report =
  assert rep.kind in {low(InternalReportKind) .. high(InternalReportKind)}
  Report(category: repInternal, internalReport: rep)

func wrap*(rep: sink ExternalReport): Report =
  assert rep.kind in {low(ExternalReportKind) .. high(ExternalReportKind)}
  Report(category: repExternal, externalReport: rep)

func wrap*[R: ReportTypes](rep: sink R, iinfo: InstantiationInfo): Report =
  var tmp = rep
  tmp.reportInst = toReportLinePoint(iinfo)
  return wrap(tmp)


func wrap*[R: ReportTypes](
    rep: sink R, iinfo, point: ReportLinePoint): Report =
  var tmp = rep
  tmp.reportInst = iinfo
  tmp.location = some(ReportLineInfo(isRange: false, lpoint: point))
  return wrap(tmp)

func wrap*[R: ReportTypes](
    rep: sink R, iinfo: InstantiationInfo, point: ReportLinePoint): Report =
  wrap(rep, toReportLinePoint(iinfo), point)


type
  ReportList* = object
    ## List of the accumulated reports. Used for various `sem*` reporting
    ## mostly, and in other places where report might be *generated*, but
    ## not guaranteed to be printed out.
    list: seq[Report]

func addReport*(list: var ReportList, report: Report): ReportId =
  ## Add report to the report list
  list.list.add report
  result = ReportId(uint32(list.list.len))

func addReport*[R: ReportTypes](list: var ReportList, report: R): ReportId =
  addReport(list, wrap(report))

func getReport*(list: ReportList, id: ReportId): Report =
  ## Get report from the report list using it's id
  list.list[int(uint32(id) - 1)]
