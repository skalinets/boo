"""
body
after N=99
"""
# The struct the caller named is disposed, not a copy of it.
import System

struct Res(IDisposable):
	public N as int
	def Dispose():
		N = 99

def f():
	using r = Res(N: 1):
		Console.WriteLine("body")
	Console.WriteLine("after N=${r.N}")

f()
