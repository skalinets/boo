namespace BooSupportingClasses.DeferredMacros

import Boo.Lang.Compiler.Ast

macro showtype:
"""
Reports the type its argument turned out to have, which it can only know once
the method bodies are processed.
"""
	return Deferred unless CanResolveTypes

	type = TypeOf(showtype.Arguments[0])
	name = ("<none>" if type is null else type.ToString())
	return ExpressionStatement([| System.Console.WriteLine($(StringLiteralExpression(name))) |])

macro showtypetwice:
"""
Expands into another macro, which the reify pass has to expand in turn.
"""
	return Deferred unless CanResolveTypes

	type = TypeOf(showtypetwice.Arguments[0])
	name = ("<none>" if type is null else type.ToString())
	literal = StringLiteralExpression(name)
	return [|
		print $literal
		print $literal
	|]

macro neverready:
"""
Never answers, so the compiler runs out of places to ask.
"""
	return Deferred
