# Implementations for representing directed graphs, also called digraphs.
#
# Currently, there are two classes
module digraph

import abstract_digraph

# A directed graph represented by hash maps
class HashMapDigraph[V, L]
	super MutableDigraph[V, L]

	# Attributes
	#
	private var pred_map = new HashMap[V, Array[Arc[V, L]]]
	private var succ_map = new HashMap[V, Array[Arc[V, L]]]
	private var number_of_arcs = 0

	redef fun num_vertices: Int do return pred_map.keys.length end

	redef fun num_arcs: Int do return number_of_arcs end

	redef fun add_vertex(u: V)
	do
		if not has_vertex(u) then
			pred_map[u] = new Array[Arc[V, L]]
			succ_map[u] = new Array[Arc[V, L]]
		end
	end

	redef fun has_vertex(u: V): Bool do return pred_map.keys.has(u)

	redef fun remove_vertex(u: V)
	do
		if has_vertex(u) then
			for v in successors(u) do
				remove_arc(u, v)
			end
			for v in predecessors(u) do
				remove_arc(v, u)
			end
			pred_map.keys.remove(u)
			succ_map.keys.remove(u)
		end
	end

	redef fun add_arc(arc: Arc[V, L])
	do
		var u = arc.source
		var v = arc.target
		if not has_vertex(u) then add_vertex(u)
		if not has_vertex(v) then add_vertex(v)
		if not has_arc(arc) then
			succ_map[u].add(arc)
			pred_map[v].add(arc)
			number_of_arcs += 1
		end
	end

	redef fun has_arc(u, v: V): Bool do return has_vertex(u) and has_vertex(v) and succ_map[u].has(v)

	redef fun remove_arc(u: V, v: V)
	do
		if has_vertex(u) and has_vertex(v) and has_arc(u, v) then
			succ_map[u].remove(v)
			pred_map[v].remove(u)
			number_of_arcs -= 1
		end
	end

	redef fun predecessors(u: V): Array[V]
	do
		if pred_map.keys.has(u) then
			return pred_map[u]
		else
			return new Array[V]
		end
	end

	redef fun successors(u: V): Array[V]
	do
		if succ_map.keys.has(u) then
			return succ_map[u]
		else
			return new Array[V]
		end
	end

	redef fun vertices: Collection[V]
	do
		return succ_map.keys
	end

	redef fun arcs: Array[Arc[V]]
	do
		var arcs = new Array[Arc[V]]
		for u in vertices do
			for v in succ_map[u] do
				arcs.add(new Arc[V](u, v))
			end
		end
		return arcs
	end
end

# A directed graph represented by a bidimensional array
class ArrayDigraph[V, L]
	super MutableDigraph[V, L]

	# Attributes
	private var vertex_to_index = new HashMap[V, Int]
	private var index_to_vertex = new HashMap[Int, V]
	private var matrix = new Array[Array[Bool]]
	private var number_of_arcs = 0

	redef fun num_vertices: Int do return matrix.length end

	redef fun num_arcs: Int do return number_of_arcs end

	redef fun add_vertex(u: V)
	do
		if not has_vertex(u) then
			vertex_to_index[u] = num_vertices
			index_to_vertex[num_vertices] = u
			matrix[num_vertices] = new Array[Bool].filled_with(false, num_vertices)
			for i in [0..num_vertices] do
				matrix[i][num_vertices] = false
			end
		end
	end

	redef fun has_vertex(u: V) do return vertex_to_index.keys.has(u)

	redef fun remove_vertex(u: V)
	do
		if has_vertex(u) then
			for v in successors(u) do
				remove_arc(u, v)
			end
			for v in predecessors(u) do
				remove_arc(v, u)
			end
			var ui = vertex_to_index[u]
			matrix[ui] = matrix[num_vertices - 1]
			for i in [0..num_vertices[ do
				matrix[i][ui] = matrix[i][num_vertices - 1]
				matrix[i].remove_at(num_vertices - 1)
			end
			vertex_to_index.keys.remove(u)
			index_to_vertex.keys.remove(ui)
		end
	end

	redef fun add_arc(arc: Arc[V, L])
	do
		var u = arc.source
		var v = arc.target
		if not has_vertex(u) then add_vertex(u)
		if not has_vertex(v) then add_vertex(v)
		if not has_arc(u, v) then
			matrix[vertex_to_index[u]][vertex_to_index[v]] = true
			number_of_arcs += 1
		end
	end

	redef fun has_arc(u, v: V): Bool
	do
		return matrix[vertex_to_index[u]][vertex_to_index[v]]
	end

	redef fun remove_arc(u: V, v: V)
	do
		if has_vertex(u) and has_vertex(v) and has_arc(u, v) then
			matrix[vertex_to_index[u]][vertex_to_index[v]] = false
			number_of_arcs -= 1
		end
	end

	redef fun predecessors(u: V): Collection[V]
	do
		var ui = vertex_to_index[u]
		return [for i in [0..num_vertices[
			do if matrix[i][ui] then index_to_vertex[i]]
	end

	redef fun successors(u: V): Collection[V]
	do
		var ui = vertex_to_index[u]
		return [for i in [0..num_vertices[
			do if matrix[ui][i] then index_to_vertex[i]]
	end

	redef fun vertices: Collection[V] do return vertex_to_index.keys

	redef fun arcs: Array[Arc[V, L]]
	do
		return [for i in [0..num_vertices[
		     do for j in [0..num_vertices[
		     do if matrix[i][j] then
			new Arc[V](index_to_vertex[i], index_to_vertex[j])]
	end
end
