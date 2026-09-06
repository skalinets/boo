"""
body
disposed
"""
import System

ref struct Res(IDisposable):
	public N as int
	def Dispose():
		Console.WriteLine("disposed")

using r = Res():
	Console.WriteLine("body")
