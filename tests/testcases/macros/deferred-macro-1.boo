"""
string
int
int
System.Collections.Generic.List[of string]
int
"""
# A macro that defers until it can see what it was handed.
import BooSupportingClasses.DeferredMacros
import System.Collections.Generic

s = "hello"
n = 42
showtype s
showtype n
showtype n + 1
showtype List[of string]()
showtype "abc".Length
