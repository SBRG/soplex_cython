from libcpp cimport bool

cdef extern from "soplex.h" namespace "soplex":
    ctypedef long double Real
    cdef Real infinity

    cdef cppclass SoPlex:
        SoPlex() except +
        int numRowsReal()
        int numColsReal ()
        int numNonzerosReal ()
        bool setIntParam(IntParam, int)
        bool setRealParam(RealParam, Real)
        void addColReal(LPCol)
        void addRowReal(LPRow)
        int solve()
        int status()
        Real objValueReal()
        void getPrimalReal(DVector)
        void getDualReal(DVector)
        void changeLowerReal(int, Real)
        void changeUpperReal(int, Real)
        void changeObjReal(int, Real)
        void changeElementReal(int, int, Real)

    cdef cppclass LPCol:
        LPCol(Real, DSVector, Real, Real)  except +
        LPCol()  except +
        void setLower(Real)
        void setUpper(Real)
        void upper(Real)
        void lower(Real)

    cdef cppclass LPRow:
        LPRow(Real, DSVector, Real) except +
        LPRow(DSVector, RowType, Real) except +
        LPRow() except +
    
    enum RowType "soplex::LPRow::Type":
        LESS_EQUAL "soplex::LPRow::LESS_EQUAL"
        EQUAL "soplex::LPRow::EQUAL"
        GREATER_EQUAL "soplex::LPRow::GREATER_EQUAL"
        RANGE "soplex::LPRow::GREATER_EQUAL"

    cdef cppclass DSVector:
        DSVector(int) except +
        DSVector() except +
        void add(int, Real)

    cdef cppclass DVector:
        DVector(int) except +
        DVector() except +
        Real operator[] (int)

    enum IntParam "soplex::SoPlex::IntParam":
        OBJSENSE "soplex::SoPlex::OBJSENSE"
        REPRESENTATION "soplex::SoPlex::REPRESENTATION"
        ALGORITHM "soplex::SoPlex::ALGORITHM"
        FACTOR_UPDATE_TYPE "soplex::SoPlex::FACTOR_UPDATE_TYPE"
        FACTOR_UPDATE_MAX "soplex::SoPlex::FACTOR_UPDATE_MAX"
        ITERLIMIT "soplex::SoPlex::ITERLIMIT"
        REFLIMIT "soplex::SoPlex::REFLIMIT"
        STALLREFLIMIT "soplex::SoPlex::STALLREFLIMIT"
        DISPLAYFREQ "soplex::SoPlex::DISPLAYFREQ"
        VERBOSITY "soplex::SoPlex::VERBOSITY"
        SIMPLIFIER "soplex::SoPlex::SIMPLIFIER"
        SCALER "soplex::SoPlex::SCALER"
        STARTER "soplex::SoPlex::STARTER"
        PRICER "soplex::SoPlex::PRICER"
        RATIOTESTER "soplex::SoPlex::RATIOTESTER"
        SYNCMODE "soplex::SoPlex::SYNCMODE"
        READMODE "soplex::SoPlex::READMODE"
        SOLVEMODE "soplex::SoPlex::SOLVEMODE"
        CHECKMODE "soplex::SoPlex::CHECKMODE"
        HYPER_PRICING "soplex::SoPlex::HYPER_PRICING"
        INTPARAM_COUNT "soplex::SoPlex::INTPARAM_COUNT"

    enum RealParam "soplex::Soplex::RealParam":
        FEASTOL "soplex::SoPlex::FEASTOL"
        OPTTOL "soplex::SoPlex::OPTTOL"
        EPSILON_ZERO "soplex::SoPlex::EPSILON_ZERO"
        EPSILON_FACTORIZATION "soplex::SoPlex::EPSILON_FACTORIZATION"
        EPSILON_UPDATE "soplex::SoPlex::EPSILON_UPDATE"
        EPSILON_PIVOT "soplex::SoPlex::EPSILON_PIVOT"
        INFTY "soplex::SoPlex::INFTY"
        TIMELIMIT "soplex::SoPlex::TIMELIMIT"
        OBJLIMIT_LOWER "soplex::SoPlex::OBJLIMIT_LOWER"
        OBJLIMIT_UPPER "soplex::SoPlex::OBJLIMIT_UPPER"
        FPFEASTOL "soplex::SoPlex::FPFEASTOL"
        FPOPTTOL "soplex::SoPlex::FPOPTTOL"
        MAXSCALEINCR "soplex::SoPlex::MAXSCALEINCR"
        LIFTMINVAL "soplex::SoPlex::LIFTMINVAL"
        LIFTMAXVAL "soplex::SoPlex::LIFTMAXVAL"
        SPARSITY_THRESHOLD "soplex::SoPlex::SPARSITY_THRESHOLD"
        REALPARAM_COUNT "soplex::SoPlex::REALPARAM_COUNT"


    enum:
        OBJSENSE_MINIMIZE "soplex::SoPlex::OBJSENSE_MINIMIZE"
        OBJSENSE_MAXIMIZE "soplex::SoPlex::OBJSENSE_MAXIMIZE"


    enum STATUS "soplex::SPxSolver::Status":
        OPTIMAL "soplex::SPxSolver::OPTIMAL"
        INFEASIBLE "soplex::SPxSolver::INFEASIBLE"
        UNBOUNDED "soplex::SPxSolver::UNBOUNDED"
        INForUNBD "soplex::SPxSolver::INForUNBD"
        ERROR "soplex::SPxSolver::ERROR"

    enum:
        SOLVEMODE_REAL "soplex::SoPlex::SOLVEMODE_REAL"
        SOLVEMODE_AUTO "soplex::SoPlex::SOLVEMODE_AUTO"
        SOLVEMODE_RATIONAL "soplex::SoPlex::SOLVEMODE_RATIONAL"
