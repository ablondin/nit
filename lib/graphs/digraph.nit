# Implementations for representing directed graphs, also called digraphs.
#
# Currently, there are two classes
module digraph

import abstract_digraph

# A directed graph represented by hash maps
class HashMapDigraph[V]
	super MutableDigraph[V]

	# Attributes
	#
	private var incoming_vertices_map = new HashMap[V, Array[V]]
	private var outgoing_vertices_map = new HashMap[V, Array[V]]
	private var number_of_arcs = 0

	redef fun num_vertices do return outgoing_vertices_map.keys.length end

	redef fun num_arcs do return number_of_arcs end

	redef fun add_vertex(u)
	do
		if not has_vertex(u) then
			incoming_vertices_map[u] = new Array[V]
			outgoing_vertices_map[u] = new Array[V]
		end
	end

	redef fun has_vertex(u) do return outgoing_vertices_map.keys.has(u)

	redef fun remove_vertex(u)
	do
		if has_vertex(u) then
			for v in successors(u) do
				remove_arc(u, v)
			end
			for v in predecessors(u) do
				remove_arc(v, u)
			end
			incoming_vertices_map.keys.remove(u)
			outgoing_vertices_map.keys.remove(u)
		end
	end

	redef fun add_arc(u, v)
	do
		if not has_arc(u, v) then
			incoming_vertices_map[v].add(u)
			outgoing_vertices_map[u].add(v)
			number_of_arcs += 1
		end
	end

	redef fun has_arc(u, v)
	do
		return outgoing_vertices_map[u].has(v)
	end

	redef fun remove_arc(u, v)
	do
		if has_arc(u, v) then
			outgoing_vertices_map[u].remove(v)
			incoming_vertices_map[v].remove(u)
			number_of_arcs -= 1
		end
	end

	redef fun predecessors(u): Array[V]
	do
		if incoming_vertices_map.keys.has(u) then
			return incoming_vertices_map[u].clone
		else
			return new Array[V]
		end
	end

	redef fun successors(u): Array[V]
	do
		if outgoing_vertices_map.keys.has(u) then
			return outgoing_vertices_map[u].clone
		else
			return new Array[V]
		end
	end

	redef fun vertices: Collection[V]
	do
		return outgoing_vertices_map.keys
	end

	redef fun arcs: Collection[Array[V]]
	do
		return [for u in vertices do for v in outgoing_vertices_map[u] do [u, v]]
	end

	redef fun incoming_arcs(u): Collection[Array[V]]
	do
		if has_vertex(u) then
			return [for v in incoming_vertices_map[u] do [v, u]]
		else
			return new Array[Array[V]]
		end
	end

	redef fun outgoing_arcs(u): Collection[Array[V]]
	do
		if has_vertex(u) then
			return [for v in outgoing_vertices_map[u] do [u, v]]
		else
			return new Array[Array[V]]
		end
	end
end
