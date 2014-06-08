from libcpp cimport bool

cdef extern from "soplex.h" namespace "soplex":
    ctypedef long double Real

    cdef cppclass SoPlex:
        SoPlex() except +
        int numRowsReal()
        int numColsReal ()
        int numNonzerosReal ()
        bool setIntParam(int, int)
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

    enum:
        OBJSENSE_MINIMIZE "soplex::SoPlex::OBJSENSE_MINIMIZE"
        OBJSENSE_MAXIMIZE "soplex::SoPlex::OBJSENSE_MAXIMIZE"

    cdef Real infinity

    enum STATUS "soplex::SPxSolver::Status":
        OPTIMAL "soplex::SPxSolver::OPTIMAL"
        INFEASIBLE "soplex::SPxSolver::INFEASIBLE"
        UNBOUNDED "soplex::SPxSolver::UNBOUNDED"
        INForUNBD "soplex::SPxSolver::INForUNBD"
        ERROR "soplex::SPxSolver::ERROR"