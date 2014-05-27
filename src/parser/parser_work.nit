# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Internal algorithm and data structures for the Nit parser
module parser_work

intrude import parser_prod

# State of the parser automata as stored in the parser stack.
private class State
	# The internal state number
	readable writable var _state: Int

	# The node stored with the state in the stack
	readable writable var _nodes: nullable Object

	init(state: Int, nodes: nullable Object)
	do
		_state = state
		_nodes = nodes
	end
end

class Parser
	super TablesCapable
	# Associated lexer
	var _lexer: Lexer

	# Stack of pushed states and productions
	var _stack: Array[State]

	# Position in the stack
	var _stack_pos: Int

	# Create a new parser based on a given lexer
	init(lexer: Lexer)
	do
		_lexer = lexer
		_stack = new Array[State]
		_stack_pos = -1
		build_reduce_table
	end

	# Do a transition in the automata
	private fun go_to(index: Int): Int
	do
		var state = state
		var low = 1
		var high = parser_goto(index, 0) - 1

		while low <= high do
			var middle = (low + high) / 2
			var subindex = middle * 2 + 1 # +1 because parser_goto(index, 0) is the length

			var goal = parser_goto(index, subindex)
			if state < goal then
				high = middle - 1
			else if state > goal then
				low = middle + 1
			else
				return parser_goto(index, subindex+1)
			end
		end

		return parser_goto(index, 2) # Default value
	end

	# Push someting in the state stack
	private fun push(numstate: Int, list_node: nullable Object)
	do
		var pos = _stack_pos + 1
		_stack_pos = pos
		if pos < _stack.length then
			var state = _stack[pos]
			state.state = numstate
			state.nodes = list_node
		else
			_stack.push(new State(numstate, list_node))
		end
	end

	# The current state
	private fun state: Int
	do
		return _stack[_stack_pos].state
	end

	# Pop something from the stack state
	private fun pop: nullable Object
	do
		var res = _stack[_stack_pos].nodes
		_stack_pos = _stack_pos -1
		return res
	end

	# Build and return a full AST.
	fun parse: Start
	do
		push(0, null)

		var lexer = _lexer
		loop
			var token = lexer.peek
			if token isa AError then
				return new Start(null, token)
			end

			var state = self.state
			var index = token.parser_index
			var action_type = parser_action(state, 2)
			var action_value = parser_action(state, 3)

			var low = 1
			var high = parser_action(state, 0) - 1

			while low <= high do
				var middle = (low + high) / 2
				var subindex = middle * 3 + 1 # +1 because parser_action(state, 0) is the length

				var goal = parser_action(state, subindex)
				if index < goal then
					high = middle - 1
				else if index > goal then
					low = middle + 1
				else
					action_type = parser_action(state, subindex+1)
					action_value = parser_action(state, subindex+2)
					break
				end
			end

			if action_type == 0 then # SHIFT
				push(action_value, lexer.next)
			else if action_type == 1 then # REDUCE
				_reduce_table[action_value].action(self)
			else if action_type == 2 then # ACCEPT
				var node2 = lexer.next
				assert node2 isa EOF
				var node1 = pop
				assert node1 isa AModule
				var node = new Start(node1, node2)
				(new ComputeProdLocationVisitor).enter_visit(node)
				return node
			else if action_type == 3 then # ERROR
				var node2 = new AParserError.init_parser_error("Syntax error: unexpected {token}.", token.location, token)
				var node = new Start(null, node2)
				return node
			end
		end
	end

	var _reduce_table: Array[ReduceAction]
	private fun build_reduce_table is abstract
end

redef class Prod
	# Location on the first token after the start of a production
	# So outside the production for epilon production
	var _first_location: nullable Location
end

# Find location of production nodes
# Uses existing token locations to infer location of productions.
private class ComputeProdLocationVisitor
	super Visitor
	# Currenlty visited productions that need a first token
	var _need_first_prods: Array[Prod] = new Array[Prod]

	# Already visited epsilon productions that waits something after them
	var _need_after_epsilons: Array[Prod] = new Array[Prod]

	# Location of the last visited token in the current production
	var _last_location: nullable Location = null

	redef fun visit(n: ANode)
	do
		if n isa Token then
			var loc = n.location
			_last_location = loc

			# Add a first token to productions that need one
			if not _need_first_prods.is_empty then
				for no in _need_first_prods do
					no._first_location = loc
				end
				_need_first_prods.clear
			end

			# Find location for already visited epsilon production that need one
			if not _need_after_epsilons.is_empty then
				var loco = new Location(loc.file, loc.line_start, loc.line_start, loc.column_start, loc.column_start) 
				for no in _need_after_epsilons do
					no.location = loco
				end
				_need_after_epsilons.clear
			end
		else
			assert n isa Prod
			_need_first_prods.add(n)

			n.visit_all(self)

			var startl = n._first_location
			if startl != null then
				# Non-epsilon production
				var endl = _last_location
				assert endl != null

				n.location = new Location(startl.file, startl.line_start, endl.line_end, startl.column_start, endl.column_end)

				if not _need_after_epsilons.is_empty then
					var loc = new Location(endl.file, endl.line_end, endl.line_end, endl.column_end, endl.column_end)
					for no in _need_after_epsilons do
						# Epsilon production that finishes the current non-epsilon production
						no.location = loc
					end
					_need_after_epsilons.clear
				end
			else
				# Epsilon production in the middle or that finishes a parent non-epsilon production
				_need_after_epsilons.add(n)
			end
		end
	end

	init do end
end

# Each reduca action has its own class, this one is the root of the hierarchy.
private abstract class ReduceAction
	fun action(p: Parser) is abstract
	fun concat(l1, l2 : Array[Object]): Array[Object]
	do
		if l1.is_empty then return l2
		l1.append(l2)
		return l1
	end
	var _goto: Int
	init(g: Int) do _goto = g
end
