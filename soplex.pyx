# cython: embedsignature=True

from cython.operator cimport dereference as deref


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
                vector.add(cobra_model.metabolites.index(metabolite.id), stoichiometry)
            col = LPCol(reaction.objective_coefficient, vector,
                            reaction.upper_bound, reaction.lower_bound)
            self.soplex.addColReal(col)
        # TEMP: TODO REMOVE
        self.soplex.setIntParam(VERBOSITY, 0)
        
        
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
        raise NotImplementedError("todo")

    def solve_problem(self, **kwargs):
        if "objective_sense" in kwargs:
            self.set_objective_sense(kwargs["objective_sense"])
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
