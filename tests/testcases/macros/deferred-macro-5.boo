"""
int
string
"""
# A nested macro can defer too. The macro holding it has expanded and taken its
# namespace away by then, so it is expanded by what deferring wrote down.
import Boo.Lang.Compiler.Ast

macro outer:
	return outer.Body

macro outer.inner:
	return Deferred unless CanResolveTypes

	type = TypeOf(inner.Arguments[0])
	name = ("<none>" if type is null else type.ToString())
	return ExpressionStatement([| System.Console.WriteLine($(StringLiteralExpression(name))) |])

n = 42
s = "hello"
outer:
	inner n
	inner s
