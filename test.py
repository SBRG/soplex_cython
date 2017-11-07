import soplex
import cobra
cobra.solvers.solver_dict = {"soplex": soplex}

import cobra.test
#cobra.test.solvers.test_all()

m = cobra.test.create_test_model('ecoli')

a = soplex.Soplex(m)
s = soplex.solve(m)
print(repr(s))
#from IPython import embed; embed()
