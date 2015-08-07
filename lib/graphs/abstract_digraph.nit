# Implementations for representing directed graphs, also called digraphs.
#
# Currently, there are two classes
module abstract_digraph

# Interface for digraphs
abstract class AbstractDigraph[V: Object]

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
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(0, 1)
	# g.add_arc(1, 2)
	# assert g.has_arc(0, 1)
	# assert g.has_arc(1, 2)
	# assert not g.has_arc(0, 2)
	# ~~~
	fun has_arc(u, v: V): Bool is abstract

	# Returns the predecessors of `u`.
	#
	# If `u` does not exist, then it returns null.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(0, 1)
	# g.add_arc(1, 2)
	# g.add_arc(0, 2)
	# assert g.predecessors(2).has(0)
	# assert g.predecessors(2).has(1)
	# assert not g.predecessors(2).has(2)
	# ~~~
	fun predecessors(u: V): Collection[V] is abstract

	# Returns the successors of `u`.
	#
	# If `u` does not exist, then an empty collection is returned.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(0, 1)
	# g.add_arc(1, 2)
	# g.add_arc(0, 2)
	# assert not g.successors(0).has(0)
	# assert g.successors(0).has(1)
	# assert g.successors(0).has(2)
	# ~~~
	fun successors(u: V): Collection[V] is abstract

	# Returns an iterator over the vertices of this graph.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(0, 1)
	# g.add_arc(0, 2)
	# g.add_arc(1, 2)
	# var vs = new HashSet[Int]
	# for v in g.vertices_iterator do vs.add(v)
	# assert vs == new HashSet[Int].from([0,1,2])
	# ~~~
	fun vertices_iterator: Iterator[V] is abstract

	## -------------------- ##
	## Non abstract methods ##
	## -------------------- ##

	## ------------- ##
	## Basic methods ##
	## ------------- ##

	# Returns true if and only if this graph is empty.
	#
	# An empty graph is a graph without vertex and arc.
	#
	# ~~~
	# import digraph
	# assert (new HashMapDigraph[Int]).is_empty
	# ~~~
	fun is_empty: Bool do return num_vertices == 0 and num_arcs == 0

	# Returns an array containing the vertices of this graph.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_vertices([0,2,4,5])
	# assert g.vertices.length == 4
	# ~~~
	fun vertices: Array[V] do return [for u in vertices_iterator do u]

	# Returns an iterator over the arcs of this graph
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(0, 1)
	# g.add_arc(0, 2)
	# g.add_arc(1, 2)
	# for arc in g.arcs_iterator do
	# 	assert g.has_arc(arc[0], arc[1])
	# end
	# ~~~
	fun arcs_iterator: Iterator[Array[V]] do return new ArcsIterator[V](self)

	# Returns the arcs of this graph.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(1, 3)
	# g.add_arc(2, 3)
	# assert g.arcs.length == 2
	# ~~~
	fun arcs: Array[Array[V]] do return [for arc in arcs_iterator do arc]

	# Returns the incoming arcs of vertex `u`.
	#
	# If `u` is not in this graph, an empty array is returned.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(1, 3)
	# g.add_arc(2, 3)
	# for arc in g.incoming_arcs(3) do
	# 	assert g.is_predecessor(arc[0], arc[1])
	# end
	# ~~~
	fun incoming_arcs(u: V): Collection[Array[V]]
	do
		if has_vertex(u) then
			return [for v in predecessors(u) do [v, u]]
		else
			return new Array[Array[V]]
		end
	end

	# Returns the outgoing arcs of vertex `u`.
	#
	# If `u` is not in this graph, an empty array is returned.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(1, 3)
	# g.add_arc(2, 3)
	# g.add_arc(1, 2)
	# for arc in g.outgoing_arcs(1) do
	# 	assert g.is_successor(arc[1], arc[0])
	# end
	# ~~~
	fun outgoing_arcs(u: V): Collection[Array[V]]
	do
		if has_vertex(u) then
			return [for v in successors(u) do [u, v]]
		else
			return new Array[Array[V]]
		end
	end

	## ---------------------- ##
	## String representations ##
	## ---------------------- ##

	redef fun to_s
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
		for u in vertices_iterator do
			s += "   \"{u.to_s.escape_to_dot}\" "
			s += "[label=\"{u.to_s.escape_to_dot}\"];\n"
		end
		# Writing the arcs
		for arc in arcs do
			s += "   {arc[0].to_s.escape_to_dot} "
			s += "-> {arc[1].to_s.escape_to_dot};"
		end
		s += "\}"
		return s
	end

	## ------------ ##
	## Neighborhood ##
	## ------------ ##

	# Returns true if and only if `u` is a predecessor of `v`.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(1, 3)
	# assert g.is_predecessor(1, 3)
	# assert not g.is_predecessor(3, 1)
	# ~~~
	fun is_predecessor(u, v: V): Bool do return has_arc(u, v)

	# Returns true if and only if `u` is a successor of `v`.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(1, 3)
	# assert not g.is_successor(1, 3)
	# assert g.is_successor(3, 1)
	# ~~~
	fun is_successor(u, v: V): Bool do return has_arc(v, u)

	# Returns the number of arcs whose target is `u`.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(1, 3)
	# g.add_arc(2, 3)
	# assert g.in_degree(3) == 2
	# assert g.in_degree(1) == 0
	# ~~~
	fun in_degree(u: V): Int do return predecessors(u).length

	# Returns the number of arcs whose source is `u`.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(1, 2)
	# g.add_arc(1, 3)
	# g.add_arc(2, 3)
	# assert g.out_degree(3) == 0
	# assert g.out_degree(1) == 2
	# ~~~
	fun out_degree(u: V): Int do return successors(u).length

	# ------------------ #
	# Paths and circuits #
	# ------------------ #

	# Returns true if and only if `vertices` is a path of this digraph.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(1, 2)
	# g.add_arc(2, 3)
	# g.add_arc(3, 4)
	# assert g.is_path([1,2,3])
	# assert not g.is_path([1,3,3])
	# ~~~
	fun is_path(path: SequenceRead[V]): Bool
	do
		for i in [0..path.length - 1[ do
			if not has_arc(path[i], path[i + 1]) then return false
		end
		return true
	end

	# Returns true if and only if `vertices` is a circuit of this digraph.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(1, 2)
	# g.add_arc(2, 3)
	# g.add_arc(3, 1)
	# assert g.is_circuit([1,2,3,1])
	# assert not g.is_circuit([1,3,2,1])
	# ~~~
	fun is_circuit(path: SequenceRead[V]): Bool
	do
		return path.is_empty or (is_path(path) and path.first == path.last)
	end

	# Returns a shortest path from vertex `u` to `v`.
	#
	# If no path exists between `u` and `v`, it returns `null`.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(1, 2)
	# g.add_arc(2, 3)
	# g.add_arc(3, 4)
	# assert g.a_shortest_path(1, 4).length == 4
	# g.add_arc(1, 3)
	# assert g.a_shortest_path(1, 4).length == 3
	# assert g.a_shortest_path(4, 1) == null
	# ~~~
	fun a_shortest_path(u, v: V): nullable Sequence[V]
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
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(1, 2)
	# g.add_arc(2, 3)
	# g.add_arc(3, 4)
	# assert g.distance(1, 4) == 3
	# g.add_arc(1, 3)
	# assert g.distance(1, 4) == 2
	# assert g.distance(4, 1) == null
	# ~~~
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
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(1, 2)
	# g.add_arc(2, 3)
	# g.add_arc(4, 5)
	# assert g.weakly_connected_components.number_of_subsets == 2
	# ~~~
	fun weakly_connected_components: DisjointSet[V]
	do
		var components = new DisjointSet[V]
		components.add_all(vertices)
		for arc in arcs_iterator do
			components.union(arc[0], arc[1])
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
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(1, 2)
	# g.add_arc(2, 3)
	# g.add_arc(3, 1)
	# g.add_arc(3, 4)
	# g.add_arc(4, 5)
	# g.add_arc(5, 6)
	# g.add_arc(6, 5)
	# assert g.strongly_connected_components.number_of_subsets == 3
	# ~~~
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
end

# Arcs iterator
class ArcsIterator[V: Object]
	super Iterator[Array[V]]

	# The graph whose arcs are iterated over
	var graph: AbstractDigraph[V]
	# Attributes
	#
	private var sources_iterator: Iterator[V] = graph.vertices_iterator
	private var targets_iterator: Iterator[V] is noinit

	init do if not graph.is_empty then targets_iterator = graph.successors(sources_iterator.item).iterator

	redef fun is_ok do return not graph.is_empty and sources_iterator.is_ok and targets_iterator.is_ok

	redef fun item do return [sources_iterator.item, targets_iterator.item]

	redef fun next
	do
		if targets_iterator.is_ok then
			targets_iterator.next
		else if sources_iterator.is_ok then
			sources_iterator.next
			targets_iterator = graph.successors(sources_iterator.item).iterator
		end
	end
end

# Mutable digraph
abstract class MutableDigraph[V: Object]
	super AbstractDigraph[V]

	## ---------------- ##
	## Abstract methods ##
	## ---------------- ##

	# Adds the vertex `u` to this graph.
	#
	# If `u` already belongs to the graph, then nothing happens.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
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
	# If there is already an arc from `u` to `v` in this graph, then
	# nothing happens. If vertex `u` or vertex `v` do not exist in the
	# graph, they are added.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(0, 1)
	# g.add_arc(1, 2)
	# assert g.has_arc(0, 1)
	# assert g.has_arc(1, 2)
	# assert not g.has_arc(1, 0)
	# g.add_arc(1, 2)
	# assert g.num_arcs == 2
	# ~~~
	fun add_arc(u, v: V) is abstract

	# Removes the arc `(u,v)` from this graph.
	#
	# If the arc does not exist in the graph, then nothing happens.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_arc(0, 1)
	# assert g.num_arcs == 1
	# g.remove_arc(0, 1)
	# assert g.num_arcs == 0
	# g.remove_arc(0, 1)
	# assert g.num_arcs == 0
	# ~~~
	fun remove_arc(u, v: V) is abstract

	## -------------------- ##
	## Non abstract methods ##
	## -------------------- ##

	# Adds all vertices of `vertices` to this digraph.
	#
	# If vertices appear more than once, they are only added once.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# g.add_vertices([0,1,2,3])
	# assert g.num_vertices == 4
	# g.add_vertices([2,3,4,5])
	# assert g.num_vertices == 6
	# ~~~
	fun add_vertices(vertices: Collection[V])
	do
		for u in vertices do add_vertex(u)
	end

	# Adds all arcs of `arcs` to this digraph.
	#
	# If arcs appear more than once, they are only added once.
	#
	# ~~~
	# import digraph
	# var g = new HashMapDigraph[Int]
	# var arcs = [[0,1], [1,2], [1,2]]
	# g.add_arcs(arcs)
	# assert g.num_arcs == 2
	# ~~~
	fun add_arcs(arcs: Collection[Array[V]])
	do
		for a in arcs do add_arc(a[0], a[1])
	end
end
