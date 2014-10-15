# cython: embedsignature=True

from cython.operator cimport dereference as deref

try:
    from sympy import Basic
except:
    class Basic:
        pass

include "soplex_constants.pxi"

cdef class Soplex:
    cdef SoPlex *soplex
    def __cinit__(self):
        self.soplex = new SoPlex()

    def __dealloc__(self):
        del self.soplex

    def __init__(self, cobra_model=None):
        if cobra_model is None:
            return
        cdef DSVector vector
        cdef LPCol col
        cdef LPRow row
        cdef Real bound
        # set the vector to be empty for now
        vector = DSVector(0)
        for metabolite in cobra_model.metabolites:
            bound = metabolite._bound
            if metabolite._constraint_sense == "E":
                row = LPRow(vector, EQUAL, bound)
                #row = LPRow(bound, vector, bound)
            elif metabolite._constraint_sense == "L":
                row = LPRow(vector, LESS_EQUAL, bound)
                #row = LPRow(-infinity, vector, bound)
            elif metabolite._constraint_sense == "G":
                row = LPRow(vector, GREATER_EQUAL, bound)
                #row = LPRow(bound, vector, infinity)
            else:
                raise ValueError(
                    "%s constraint sense %s not in {'E', 'G', 'L'}" % \
                    (repr(metabolite), metabolite._constraint_sense))
            self.soplex.addRowReal(row)
        for reaction in cobra_model.reactions:
            vector = DSVector()
            for metabolite, stoichiometry in reaction._metabolites.items():
                if isinstance(stoichiometry, Basic):
                    continue
                vector.add(cobra_model.metabolites.index(metabolite.id), stoichiometry)
            col = LPCol(reaction.objective_coefficient, vector,
                            reaction.upper_bound, reaction.lower_bound)
            self.soplex.addColReal(col)
        # TEMP: TODO REMOVE AND HANDLE PARAMTERS FOR REAL
        self.soplex.setIntParam(VERBOSITY, 0)
        self.soplex.setIntParam(SOLVEMODE, SOLVEMODE_RATIONAL)
        self.soplex.setRealParam(FPFEASTOL, 1e-20)
        self.soplex.setRealParam(FPOPTTOL, 1e-20)
        
        
    def create_problem(cls, cobra_model, objective_sense="maximize"):
        problem = cls(cobra_model)
        problem.set_objective_sense(objective_sense)
        return problem
    create_problem = classmethod(create_problem)

    cpdef set_objective_sense(self, objective_sense="maximize"):
        objective_sense = objective_sense.lower()
        if objective_sense == "maximize":
            self.soplex.setIntParam(OBJSENSE, OBJSENSE_MAXIMIZE)
        elif objective_sense == "minimize":
            self.soplex.setIntParam(OBJSENSE, OBJSENSE_MINIMIZE)

    cpdef change_variable_bounds(self, int index, Real lower_bound, Real upper_bound):
        self.soplex.changeLowerReal(index, lower_bound)
        self.soplex.changeUpperReal(index, upper_bound)

    cpdef change_variable_objective(self, int index, Real value):
        self.soplex.changeObjReal(index, value)

    cpdef change_coefficient(self, int met_index, int rxn_index, Real value):
        self.soplex.changeElementReal(met_index, rxn_index, value)

    cpdef set_parameter(self, parameter_name, value):
        name_upper = parameter_name.upper()
        if parameter_name == "verbose" or name_upper == "VERBOSITY":
            if value is True:
                self.soplex.setIntParam(VERBOSITY, 5)
            else:
                self.soplex.setIntParam(VERBOSITY, value)
        elif name_upper == "SOLVEMODE":
            self.soplex.setIntParam(SOLVEMODE, SOLVEMODE_VALUES[value.upper()]) 
        elif name_upper == "CHECKMODE":
            self.soplex.setIntParam(CHECKMODE, CHECKMODE_VALUES[value.upper()]) 
        elif parameter_name in IntParameters:
            raise NotImplementedError("todo implement " + parameter_name)
        # setRealParam section
        elif name_upper == "FEASTOL" or parameter_name == "tolerance_feasibility":
            self.soplex.setRealParam(FEASTOL, value)
        elif name_upper == "OPTTOL":
            self.soplex.setRealParam(OPTTOL, value)
        elif name_upper == "EPSILON_ZERO":
            self.soplex.setRealParam(EPSILON_ZERO, value)
        elif name_upper == "EPSILON_FACTORIZATION":
            self.soplex.setRealParam(EPSILON_FACTORIZATION, value)
        elif name_upper == "EPSILON_UPDATE":
            self.soplex.setRealParam(EPSILON_UPDATE, value)
        elif name_upper == "EPSILON_PIVOT":
            self.soplex.setRealParam(EPSILON_PIVOT, value)
        elif name_upper == "INFTY":
            self.soplex.setRealParam(INFTY, value)
        elif name_upper == "TIMELIMIT" or parameter_name == "time_limit":
            self.soplex.setRealParam(TIMELIMIT, value)
        elif name_upper == "OBJLIMIT_LOWER":
            self.soplex.setRealParam(OBJLIMIT_LOWER, value)
        elif name_upper == "OBJLIMIT_UPPER":
            self.soplex.setRealParam(OBJLIMIT_UPPER, value)
        elif name_upper == "FPFEASTOL":
            self.soplex.setRealParam(FPFEASTOL, value)
        elif name_upper == "FPOPTTOL":
            self.soplex.setRealParam(FPOPTTOL, value)
        elif name_upper == "MAXSCALEINCR":
            self.soplex.setRealParam(MAXSCALEINCR, value)
        elif name_upper == "LIFTMINVAL":
            self.soplex.setRealParam(LIFTMINVAL, value)
        elif name_upper == "LIFTMAXVAL":
            self.soplex.setRealParam(LIFTMAXVAL, value)
        elif name_upper == "SPARSITY_THRESHOLD":
            self.soplex.setRealParam(SPARSITY_THRESHOLD, value)
        else:
            raise ValueError("Unknown parameter '%s'" % parameter_name)

    def solve_problem(self, **kwargs):
        if "objective_sense" in kwargs:
            self.set_objective_sense(kwargs.pop("objective_sense"))
        for key, value in kwargs.items():
            self.set_parameter(key, value)
        self.soplex.solve()
        return self.get_status()

    cpdef get_status(self):
        cdef int status = self.soplex.status()
        if status == OPTIMAL:
            return "optimal"
        elif status == INFEASIBLE or INForUNBD:
            return "infeasible"
        elif status == UNBOUNDED:
            return "unbounded"
        else:
            return "failed"

    cpdef get_objective_value(self):
        return self.soplex.objValueReal()

    cpdef format_solution(self, cobra_model):
        status = self.get_status()
        Solution = cobra_model.solution.__class__
        if status != "optimal":  # todo handle other possible
            return Solution(None, status=status)
        solution = Solution(self.get_objective_value(), status=status)
        cdef int i
        # get primals
        cdef int nCols = self.soplex.numColsReal()
        cdef DVector x_vals = DVector(nCols)
        self.soplex.getPrimalReal(x_vals)
        solution.x = [x_vals[i] for i in range(nCols)]
        solution.x_dict = {cobra_model.reactions[i].id: x_vals[i]
                           for i in range(nCols)}
        # get duals
        cdef int nRows = self.soplex.numRowsReal()
        cdef DVector y_vals = DVector(nRows)
        self.soplex.getDualReal(y_vals)
        solution.y = [y_vals[i] for i in range(nRows)]
        solution.y_dict = {cobra_model.metabolites[i].id: y_vals[i]
                           for i in range(nRows)}
        return solution

    
    def solve(cls, cobra_model, **kwargs):
        problem = cls.create_problem(cobra_model)
        problem.solve_problem(objective_sense="maximize")
        problem.solve_problem(objective_sense="minimize")
        problem.solve_problem(objective_sense="maximize")
        problem.solve_problem(**kwargs)
        solution = problem.format_solution(cobra_model)
        return solution
    solve = classmethod(solve)
        

    @property
    def numRows(self):
        return self.soplex.numRowsReal()

    @property
    def numCols(self):
        return self.soplex.numColsReal()

# wrappers for all the functions at the module level
create_problem = Soplex.create_problem
def set_objective_sense(lp, objective_sense="maximize"):
    return lp.set_objective_sense(lp, objective_sense=objective_sense)
cpdef change_variable_bounds(lp, int index, Real lower_bound, Real upper_bound):
    return lp.change_variable_bounds(index, lower_bound, upper_bound)
cpdef change_variable_objective(lp, int index, Real value):
    return lp.change_variable_objective(index, value)
cpdef change_coefficient(lp, int met_index, int rxn_index, Real value):
    return lp.change_coefficient(met_index, rxn_index, value)
cpdef set_parameter(lp, parameter_name, value):
    return lp.set_parameter(parameter_name, value)
def solve_problem(lp, **kwargs):
    return lp.solve_problem(**kwargs)
cpdef get_status(lp):
    return lp.get_status()
cpdef get_objective_value(lp):
    return lp.get_objective_value()
cpdef format_solution(lp, cobra_model):
    return lp.format_solution(cobra_model)
solve = Soplex.solve
