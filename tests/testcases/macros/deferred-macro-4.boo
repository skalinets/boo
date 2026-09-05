"""
int
string
after
"""
# A macro defined right here defers just as one from an assembly does.
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro localshowtype:
	return MacroExpansion.Deferred unless CanResolveTypes

	type = TypeOf(localshowtype.Arguments[0])
	name = ("<none>" if type is null else type.ToString())
	return ExpressionStatement([| System.Console.WriteLine($(StringLiteralExpression(name))) |])

n = 42
s = "hello"
localshowtype n
localshowtype s
print "after"
