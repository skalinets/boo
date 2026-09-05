"""
body
disposed
"""
# A struct is disposed through its own Dispose, never through a boxed IDisposable.
import System

struct Res(IDisposable):
	public N as int
	def Dispose():
		Console.WriteLine("disposed")

using r = Res():
	Console.WriteLine("body")
