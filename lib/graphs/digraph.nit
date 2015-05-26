# Implementations for representing directed graphs, also called digraphs.
#
# Currently, there are two classes
module digraph

# An arc of a digraph
class Arc[V]
	# The source of the arc
	var source: V
	# The target of the arc
	var target: V
	# String representation of an arc
	redef fun to_s: String
	do
		return "({source.to_s}, {target.to_s})"
	end
end

# Interface for digraphs
abstract class AbstractDigraph[V: Object]

	## ---------- ##
	## Properties ##
	## ---------- ##

	# The number of vertices in this graph.
	var num_vertices = 0
	# The number of arcs in this graph.
	var num_arcs = 0

	## ---------------- ##
	## Abstract methods ##
	## ---------------- ##

	# Adds the vertex `u` to this graph.
	#
	# If `u` already belongs to the graph, then nothing happens.
	fun add_vertex(u: V) is abstract

	# Returns true if and only if `u` exists in this graph.
	fun has_vertex(u: V): Bool is abstract

	# Removes the vertex `u` from this graph and all its incident arcs.
	#
	# If the vertex does not exist in the graph, then nothing happens.
	fun remove_vertex(u: V) is abstract

	# Adds the arc `(u,v)` to this graph.
	#
	# If the arc already exists in the graph, then nothing happens.
	# If vertex `u` or vertex `v` do not exist in the graph, they are added.
	fun add_arc(u, v: V) is abstract

	# Returns true if and only if `(u,v)` is an arc in this graph.
	fun has_arc(u, v: V): Bool is abstract

	# Removes the arc `(u,v)` from this graph.
	#
	# If the arc does not exist in the graph, then nothing happens.
	fun remove_arc(u, v: V) is abstract

	# Returns the predecessors of `u`.
	#
	# If `u` does not exist, then an empty collection is returned.
	fun predecessors(u: V): Collection[V] is abstract

	# Returns the successors of `u`.
	#
	# If `u` does not exist, then an empty collection is returned.
	fun successors(u: V): Collection[V] is abstract

	# Returns the vertices of this graph.
	fun vertices: Collection[V] is abstract

	# Returns the arcs of this graph.
	fun arcs: Collection[Arc[V]] is abstract

	## -------------------- ##
	## Non abstract methods ##
	## -------------------- ##

	## ------------ ##
	## Neighborhood ##
	## ------------ ##

	# Returns true if and only if `u` is a predecessor of `v`.
	fun is_predecessor(u, v: V): Bool
	do
		return has_arc(u, v)
	end

	# Returns true if and only if `u` is a successor of `v`.
	fun is_successor(u, v: V): Bool
	do
		return has_arc(v, u)
	end

	# Returns the incoming arcs of vertex `u`.
	#
	# If `u` is not in this graph, an empty array is returned.
	fun incoming_arcs(u: V): Array[Arc[V]]
	do
		var arcs = new Array[Arc[V]]
		for v in successors(u) do
			arcs.add(new Arc[V](u, v))
		end
		return arcs
	end

	# Returns the outgoing arcs of vertex `u`.
	#
	# If `u` is not in this graph, an empty array is returned.
	fun outgoing_arcs(u: V): Array[Arc[V]]
	do
		var arcs = new Array[Arc[V]]
		for v in predecessors(u) do
			arcs.add(new Arc[V](v, u))
		end
		return arcs
	end

	## ---------------------- ##
	## String representations ##
	## ---------------------- ##

	redef fun to_s: String
	do
		var s = "vertices"
		var t = "arcs"
		if num_vertices <= 1 then s = "vertex"
		if num_arcs <= 1 then t = "arc"
		s = "Digraph of {num_vertices} {s} and {num_arcs} {t}\n"
		s += "  Vertices: {vertices.join(" ")}\n"
		s += "  Arcs: {arcs.join(" ")}"
		return s
	end

	# Returns a GraphViz string representing this digraph.
	fun to_graphviz: String
	do
		var s = "digraph \{\n"
		# Writing the vertices
		for u in vertices do
			s += "  \"{u}\" [label=\"{u}\"];\n"
		end
		# Writing the arcs
		for arc in arcs do
			s += "  {arc.source} -> {arc.target};\n"
		end
		s += "\}"
		return s
	end

	# ------- #
	# Degrees #
	# ------- #

	# Returns the number of arcs whose target is `u`.
	fun in_degree(u: V): Int
	do
		return predecessors(u).length
	end

	# Returns the number of arcs whose source is `u`.
	fun out_degree(u: V): Int
	do
		return successors(u).length
	end

	# ------------------ #
	# Paths and circuits #
	# ------------------ #

	# Returns true if and only if `vertices` is a path of this digraph.
	fun is_path(vertices: SequenceRead[V]): Bool
	do
		for i in [0..vertices.length[ do
			if not has_arc(vertices[i], vertices[i + 1]) then return false
		end
		return true
	end

	# Returns true if and only if `vertices` is a circuit of this digraph.
	fun is_circuit(vertices: SequenceRead[V]): Bool
	do
		return vertices.is_empty or (is_path(vertices) and vertices.first == vertices.last)
	end

	# Returns a shortest path between vertices `u` and `v`.
	#
	# If no path exists between `u` and `v`, it returns `null`.
	fun a_shortest_path(u, v: V): nullable List[V]
	do
		var queue = (new Array[V]).as_fifo
		var pred = new HashMap[V, nullable V]
		var visited = new HashMap[V, Bool]
		var w: nullable V
		pred[u] = null
		queue.add(u)
		loop
			w = queue.take
			if not visited.get_or_default(w, false) then
				visited[w] = true
				if w == v then break
				for wp in successors(w) do
					if not pred.keys.has(wp) then
						queue.add(wp)
						pred[wp] = w
					end
				end
			end
			if queue.is_empty then break
		end
		if w != v then
			return null
		else
			var path = new List[V]
			path.add(v)
			w = v
			while pred[w] != null do
				path.unshift(pred[w].as(not null))
				w = pred[w]
			end
			return path
		end
	end

	# Returns the distance between `u` and `v`
	#
	# If no path exists between `u` and `v`, it returns null. It is not
	# symmetric, i.e. we may have `dist(u, v) != dist(v, u)`.
	fun distance(u, v: V): nullable Int
	do
		var queue = (new Array[V]).as_fifo
		var dist = new HashMap[V, Int]
		var visited = new HashMap[V, Bool]
		var w: nullable V
		dist[u] = 0
		queue.add(u)
		loop
			w = queue.take
			if not visited.get_or_default(w, false) then
				visited[w] = true
				if w == v then break
				for wp in successors(w) do
					if not dist.keys.has(wp) then
						queue.add(wp)
						dist[wp] = dist[w] + 1
					end
				end
			end
			if queue.is_empty then break
		end
		return dist.get_or_null(v)
	end

	# -------------------- #
	# Connected components #
	# -------------------- #

	# Returns the weak connected components of this digraph.
	#
	# The weak connected components of a digraph are the usual
	# connected components of its associated undirected graph,
	# i.e. the graph obtained by replacing each arc by an edge.
	fun weak_connected_components: DisjointSet[V]
	do
		var components = new DisjointSet[V]
		components.add_all(vertices)
		for arc in arcs do
			components.union(arc.source, arc.target)
		end
		return components
	end

	# Returns the strongly connected components of this digraph.
	#
	# Two vertices `u` and `v` belong to the same strongly connected
	# component if and only if there exists a path from `u` to `v`
	# and there exists a path from `v` to `u`.
	#
	# This is computed in linear time (Tarjan's algorithm).
	fun strongly_connected_components: DisjointSet[V]
	do
		sccs = new DisjointSet[V]
		sccs.add_all(vertices)
		tarjan_index = 0
		tarjan_stack = (new Array[V]).as_lifo
		tarjan_vertex_to_index = new HashMap[V, Int]
		tarjan_ancestor = new HashMap[V, Int]
		tarjan_in_stack = new HashMap[V, Bool]
		for v in vertices do
			tarjan(v)
		end
		return sccs
	end

	# The recursive part of Tarjan's algorithm
	private fun tarjan(u: V)
	do
		tarjan_vertex_to_index[u] = tarjan_index
		tarjan_ancestor[u] = tarjan_index
		tarjan_index += 1
		tarjan_stack.add(u)
		tarjan_in_stack[u] = true
		for v in successors(u) do
			if not tarjan_vertex_to_index.keys.has(v) then
				tarjan(v)
				tarjan_ancestor[u] = tarjan_ancestor[u].min(tarjan_ancestor[v])
			else if tarjan_in_stack[v] then
				tarjan_ancestor[u] = tarjan_ancestor[u].min(tarjan_vertex_to_index[v])
			end
		end
		if tarjan_vertex_to_index[u] == tarjan_ancestor[u] then
			var v
			loop
				v = tarjan_stack.take
				tarjan_in_stack[v] = false
				sccs.union(u, v)
				if u == v then break
			end
		end
	end

	# The strongly connected components computed in Tarjan's algorithm
	private var sccs: DisjointSet[V] is noinit
	# An index used for Tarjan's algorithm
	private var tarjan_index: Int is noinit
	# A stack used for Tarjan's algorithm
	private var tarjan_stack: Queue[V] is noinit
	# A map associating with each vertex its index
	private var tarjan_vertex_to_index: HashMap[V, Int] is noinit
	# A map associating with each vertex its ancestor in Tarjan's algorithm
	private var tarjan_ancestor: HashMap[V, Int] is noinit
	# True if and only if the vertex is in the stack
	private var tarjan_in_stack: HashMap[V, Bool] is noinit
end

# A directed graph represented by hash maps
class HashMapDigraph[V: Object]
	super AbstractDigraph[V]

	# Attributes
	private var pred_map = new HashMap[V, Array[V]]
	private var succ_map = new HashMap[V, Array[V]]

	redef fun add_vertex(u: V)
	do
		if has_vertex(u) then
			return
		else
			pred_map[u] = new Array[V]
			succ_map[u] = new Array[V]
			num_vertices += 1
		end
	end

	redef fun has_vertex(u: V): Bool
	do
		return pred_map.keys.has(u)
	end

	redef fun remove_vertex(u: V)
	do
		if has_vertex(u) then
			for v in successors(u) do
				remove_arc(u, v)
			end
			for v in predecessors(u) do
				remove_arc(v, u)
			end
			succ_map.keys.remove(u)
			num_vertices -= 1
		end
	end

	redef fun add_arc(u, v: V)
	do
		if not has_vertex(u) then add_vertex(u)
		if not has_vertex(v) then add_vertex(v)
		if not has_arc(u, v) then
			succ_map[u].add(v)
			pred_map[v].add(u)
			num_arcs += 1
		end
	end

	redef fun has_arc(u, v: V): Bool
	do
		return succ_map[u].has(v)
	end

	redef fun remove_arc(u: V, v: V)
	do
		if has_vertex(u) and has_vertex(v) and has_arc(u, v) then
			succ_map[u].remove(v)
			pred_map[v].remove(u)
			num_arcs -= 1
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

	redef fun vertices: RemovableCollection[V]
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
class ArrayDigraph[V: Object]
	super AbstractDigraph[V]

	# Attributes
	private var vertex_to_index = new HashMap[V, Int]
	private var index_to_vertex = new HashMap[Int, V]
	private var matrix = new Array[Array[Bool]]

	redef fun add_vertex(u: V)
	do
		if not has_vertex(u) then
			vertex_to_index[u] = num_vertices
			index_to_vertex[num_vertices] = u
			matrix[num_vertices] = new Array[Bool].filled_with(false, num_vertices)
			for i in [0..num_vertices] do
				matrix[i][num_vertices] = false
			end
			num_vertices += 1
		end
	end

	redef fun has_vertex(u: V)
	do
		return vertex_to_index.keys.has(u)
	end

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
			num_vertices -= 1
		end
	end

	redef fun add_arc(u, v: V)
	do
		if not has_vertex(u) then add_vertex(u)
		if not has_vertex(v) then add_vertex(v)
		if not has_arc(u, v) then
			matrix[vertex_to_index[u]][vertex_to_index[v]] = true
			num_arcs += 1
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
			num_arcs -= 1
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

	redef fun vertices: RemovableCollection[V]
	do
		return vertex_to_index.keys
	end

	redef fun arcs: Array[Arc[V]]
	do
		return [for i in [0..num_vertices[
		     do for j in [0..num_vertices[
		     do if matrix[i][j] then
			new Arc[V](index_to_vertex[i], index_to_vertex[j])]
	end
end

private class QueuePair[V]
	var vertex: V
	var pred: nullable V
	redef fun to_s: String
	do
		if pred == null then
			return "{vertex.to_s}"
		else
			return "{pred.to_s} -> {vertex.to_s}"
		end
	end
end
