#region license
// Copyright (c) 2004, Rodrigo B. de Oliveira (rbo@acm.org)
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
//     * Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//     * Neither the name of Rodrigo B. de Oliveira nor the names of its
//     contributors may be used to endorse or promote products derived from this
//     software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

namespace Boo.Lang.Extensions

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Environments

macro using:
"""
Disposes each value when the block is left. How it is disposed depends on the
type, so this defers until the types are known.
"""
	return Deferred unless CanResolveTypes

	# A later value may name an earlier one, so ask in the order written.
	types = []
	for expression as Expression in using.Arguments:
		types.Add(TypeOf(expression))

	expansion as Statement = using.Body
	index = len(types)
	for expression as Expression in reversed(using.Arguments):
		index -= 1
		temp = ReferenceExpression(Context.GetUniqueName("using", "disposable"))
		disposal as Statement

		if IsDisposedInPlace(types[index]):
			# Disposing a copy would lose what Dispose writes.
			named = NamedValue(expression)
			if named is null:
				assignment = [| $temp = $expression |].withLexicalInfoFrom(expression)
				disposal = ExpressionStatement([| $temp.Dispose() |])
			else:
				assignment = expression
				disposal = ExpressionStatement([| $named.Dispose() |])
		else:
			assignment = [| $temp = $expression as System.IDisposable |].withLexicalInfoFrom(expression)
			disposal = [|
				if $temp is not null:
					$temp.Dispose()
					$temp = null
			|]

		# A statement without a position sends the debugger to the top of the file.
		disposal.LexicalInfo = expression.LexicalInfo

		expansion = [|
			$assignment
			try:
				$expansion
			ensure:
				$disposal
		|]

	return expansion

/// A struct is disposed where it stands, since reaching it through IDisposable boxes it.
internal def IsDisposedInPlace(type as IType) as bool:
	return false if type is null or not type.IsValueType
	return My[of TypeSystemServices].Instance.IDisposableType.IsAssignableFrom(type)

/// The plain name a using argument binds to, or null when it binds none.
internal def NamedValue(expression as Expression) as ReferenceExpression:
	assignment = expression as BinaryExpression
	return null if assignment is null or assignment.Operator != BinaryOperatorType.Assign

	target = assignment.Left
	return null if target.NodeType != NodeType.ReferenceExpression
	return ReferenceExpression(target.LexicalInfo, (target as ReferenceExpression).Name)
