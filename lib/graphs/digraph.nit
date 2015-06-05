# Implementations for representing directed graphs, also called digraphs.
#
# Currently, there are two classes
module digraph

import abstract_digraph

# A directed graph represented by hash maps
class HashMapDigraph[V, A]
	super MutableDigraph[V, A]

	# Attributes
	#
	private var incoming_arcs_map = new HashMap[V, Array[Arc[V, A]]]
	private var outgoing_arcs_map = new HashMap[V, Array[Arc[V, A]]]
	private var number_of_arcs = 0

	redef fun num_vertices: Int do return outgoing_arcs_map.keys.length end

	redef fun num_arcs: Int do return number_of_arcs end

	redef fun add_vertex(u: V)
	do
		if not has_vertex(u) then
			incoming_arcs_map[u] = new Array[Arc[V, A]]
			outgoing_arcs_map[u] = new Array[Arc[V, A]]
		end
	end

	redef fun has_vertex(u: V): Bool do return outgoing_arcs_map.keys.has(u)

	redef fun remove_vertex(u: V)
	do
		if has_vertex(u) then
			for v in successors(u) do
				remove_arc(u, v)
			end
			for v in predecessors(u) do
				remove_arc(v, u)
			end
			incoming_arcs_map.keys.remove(u)
			outgoing_arcs_map.keys.remove(u)
		end
	end

	redef fun add_arc(u, v: V, l: nullable A)
	do
		if not has_vertex(u) then add_vertex(u)
		if not has_vertex(v) then add_vertex(v)
		if not has_arc(u, v) then
			var arc = new Arc[V, A](u, v, l)
			incoming_arcs_map[v].add(arc)
			outgoing_arcs_map[u].add(arc)
			number_of_arcs += 1
		end
	end

	redef fun has_arc(u, v: V): Bool
	do
		if has_vertex(u) and has_vertex(v) then
			for arc in outgoing_arcs_map[u] do
				if arc.target == v then return true
			end
		end
		return false
	end

	redef fun get_arc_value(u, v: V): nullable A do
		if has_vertex(u) and has_vertex(v) then
			for arc in outgoing_arcs_map[u] do
				if arc.target == v then return arc.value
			end
		end
		return null
	end

	redef fun remove_arc(u: V, v: V)
	do
		if has_vertex(u) and has_vertex(v) then
			for arc in outgoing_arcs_map[u] do
				if arc.target == v then
					outgoing_arcs_map[u].remove(arc)
					incoming_arcs_map[v].remove(arc)
					number_of_arcs -= 1
					return
				end
			end
		end
	end

	redef fun predecessors(u: V): nullable Array[V]
	do
		if incoming_arcs_map.keys.has(u) then
			return [for arc in incoming_arcs_map[u] do arc.source]
		else
			return null
		end
	end

	redef fun successors(u: V): nullable Array[V]
	do
		if outgoing_arcs_map.keys.has(u) then
			return [for arc in outgoing_arcs_map[u] do arc.target]
		else
			return null
		end
	end

	redef fun vertices: Collection[V]
	do
		return outgoing_arcs_map.keys
	end

	redef fun arcs: Collection[Arc[V, A]]
	do
		return [for u in vertices do for arc in outgoing_arcs_map[u] do arc]
	end

	redef fun incoming_arcs(u: V): nullable Collection[Arc[V, A]]
	do
		if has_vertex(u) then
			return incoming_arcs_map[u]
		else
			return null
		end
	end

	redef fun outgoing_arcs(u: V): nullable Collection[Arc[V, A]]
	do
		if has_vertex(u) then
			return outgoing_arcs_map[u]
		else
			return null
		end
	end

	redef fun change_arc_value(u, v: V, l: A)
	do
		if not has_arc(u, v) then
			add_arc(u, v, l)
		else
			for arc in outgoing_arcs_map[u] do
				if arc.source == u then arc.value = l
			end
		end
	end
end
