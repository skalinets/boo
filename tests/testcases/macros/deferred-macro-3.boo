"""
int
string
"""
# Deferring still works where the method is rewritten around it.
import BooSupportingClasses.DeferredMacros

def gen():
	x = 1
	showtype x
	yield x

for i in gen():
	pass

c = def():
	y = "inner"
	showtype y
c()
