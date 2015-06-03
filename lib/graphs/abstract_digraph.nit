# Implementations for representing directed graphs, also called digraphs.
#
# Currently, there are two classes
module abstract_digraph

# An arc of a digraph
class Arc[V, L]
	# The source of the arc
	#
	# ~~~
	# var arc = new Arc[Int](0, 1)
	# assert arc.source == 0
	# ~~~
	var source: V

	# The target of the arc
	#
	# ~~~
	# var arc = new Arc[Int](0, 1)
	# assert arc.target == 1
	# ~~~
	var target: V

	# Returns the value stored in the arc
	var value: L

	redef fun to_s: String do return "({source or else "NULL"}, {target or else "NULL"}, {value or else "NULL"})"
end

# Interface for digraphs
abstract class ReadonlyDigraph[V, L]

	## ---------------- ##
	## Abstract methods ##
	## ---------------- ##

	# The number of vertices in this graph.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_vertex(0)
	# g.add_vertex(1)
	# assert g.num_vertices == 2
	# g.add_vertex(0)
	# assert g.num_vertices == 2
	# ~~~
	fun num_vertices: Int is abstract

	# The number of arcs in this graph.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(0, 1)
	# assert g.num_arcs == 1
	# g.add_arc(0, 1)
	# assert g.num_arcs == 1
	# g.add_arc(2, 3)
	# assert g.num_arcs == 2
	# ~~~
	fun num_arcs: Int is abstract

	# Returns true if and only if `u` exists in this graph.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_vertex(1)
	# assert g.has_vertex(1)
	# assert not g.has_vertex(0)
	# g.add_vertex(1)
	# assert g.has_vertex(1)
	# assert not g.has_vertex(0)
	# ~~~
	fun has_vertex(u: V): Bool is abstract

	# Returns true if and only if `(u,v)` is an arc in this graph.
	fun has_arc(u, v: V): Bool is abstract

	# Returns true if and only if `(u,v)` is an arc in this graph with label `l`.
	fun has_labelled_arc(u, v: V, l: L): Bool is abstract

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
	fun arcs: Collection[Arc[V, L]] is abstract

	# Returns the incoming arcs of vertex `u`.
	#
	# If `u` is not in this graph, an empty array is returned.
	fun incoming_arcs(u: V): Array[Arc[V, L]] is abstract

	# Returns the outgoing arcs of vertex `u`.
	#
	# If `u` is not in this graph, an empty array is returned.
	fun outgoing_arcs(u: V): Array[Arc[V, L]] is abstract

	## -------------------- ##
	## Non abstract methods ##
	## -------------------- ##

	## ---------------------- ##
	## String representations ##
	## ---------------------- ##

	redef fun to_s: String
	do
		var vertex_word = "vertices"
		var arc_word = "arcs"
		if num_vertices <= 1 then vertex_word = "vertex"
		if num_arcs <= 1 then arc_word = "arc"
		return "Digraph of {num_vertices} {vertex_word} and {num_arcs} {arc_word}"
	end

	# Returns a GraphViz string representing this digraph.
	fun to_dot: String
	do
		var s = "digraph \{\n"
		# Writing the vertices
		for u in vertices do
			s += "   \"{u.to_s.escape_to_dot}\" "
			s += "[label=\"{u.to_s.escape_to_dot}\"];\n"
		end
		# Writing the arcs
		for arc in arcs do
			s += "   {arc.source.to_s.escape_to_dot} "
			s += "-> {arc.target.to_s.escape_to_dot};\n"
		end
		s += "\}"
		return s
	end

	## ------------ ##
	## Neighborhood ##
	## ------------ ##

	# Returns true if and only if `u` is a predecessor of `v`.
	fun is_predecessor(u, v: V): Bool do return has_arc(u, v)

	# Returns true if and only if `u` is a successor of `v`.
	fun is_successor(u, v: V): Bool do return has_arc(v, u)

	# Returns the number of arcs whose target is `u`.
	fun in_degree(u: V): Int do return predecessors(u).length

	# Returns the number of arcs whose source is `u`.
	fun out_degree(u: V): Int do return successors(u).length

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
		var queue = new List[V].from([u]).as_fifo
		var pred = new HashMap[V, nullable V]
		var visited = new HashSet[V]
		var w: nullable V = null
		pred[u] = null
		while not queue.is_empty do
			w = queue.take
			if not visited.has(w) then
				visited.add(w)
				if w == v then break
				for wp in successors(w) do
					if not pred.keys.has(wp) then
						queue.add(wp)
						pred[wp] = w
					end
				end
			end
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
		var queue = new List[V].from([u]).as_fifo
		var dist = new HashMap[V, Int]
		var visited = new HashSet[V]
		var w: nullable V
		dist[u] = 0
		while not queue.is_empty do
			w = queue.take
			if not visited.has(w) then
				visited.add(w)
				if w == v then break
				for wp in successors(w) do
					if not dist.keys.has(wp) then
						queue.add(wp)
						dist[wp] = dist[w] + 1
					end
				end
			end
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
	fun weakly_connected_components: DisjointSet[V]
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

# Mutable digraph
abstract class MutableDigraph[V, L]
	super ReadonlyDigraph[V, L]

	## ---------------- ##
	## Abstract methods ##
	## ---------------- ##

	# Adds the vertex `u` to this graph.
	#
	# If `u` already belongs to the graph, then nothing happens.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int] # Or any class implementing Digraph
	# g.add_vertex(0)
	# assert g.has_vertex(0)
	# assert not g.has_vertex(1)
	# g.add_vertex(1)
	# assert g.num_vertices == 2
	# ~~~
	fun add_vertex(u: V) is abstract

	# Removes the vertex `u` from this graph and all its incident arcs.
	#
	# If the vertex does not exist in the graph, then nothing happens.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_vertex(0)
	# g.add_vertex(1)
	# assert g.has_vertex(0)
	# g.remove_vertex(0)
	# assert not g.has_vertex(0)
	# ~~~
	fun remove_vertex(u: V) is abstract

	# Adds the arc `(u,v)` to this graph.
	#
	# If the arc already exists in the graph, then nothing happens.
	# If vertex `u` or vertex `v` do not exist in the graph, they are added.
	fun add_arc(arc: Arc[V, L]) is abstract

	# Removes the arc `(u,v)` from this graph.
	#
	# If the arc does not exist in the graph, then nothing happens.
	fun remove_arc(u, v: V) is abstract

	## -------------------- ##
	## Non abstract methods ##
	## -------------------- ##

	# Adds all vertices of `vertices` to this digraph.
	#
	# If vertices appear more than once, they are only added once.
	fun add_vertices(vertices: Collection[V])
	do for u in vertices do add_vertex(u) end

	# Adds all vertices of `vertices` to this digraph.
	#
	# If vertices appear more than once, they are only added once.
	fun add_arcs(arcs: Collection[Arc[V, L]])
	do for a in arcs do add_arc(a) end
end
