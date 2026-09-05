"""
body
after N=77
"""
# A ref struct is disposed in place, so what Dispose writes is still there.
import System

ref struct Res(IDisposable):
	public N as int
	def Dispose():
		N = 77

def f():
	using r = Res(N: 1):
		Console.WriteLine("body")
	Console.WriteLine("after N=${r.N}")

f()
