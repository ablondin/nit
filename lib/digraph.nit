# Implementation of a directed graph
module digraph

# Arcs
class Arc[V: Object]
	# The source of the arc
	var source: V
	# The target of the arc
	var target: V
end

# Interface for digraphs
abstract class AbstractDigraph[V: Object]

	## Abstract methods ##

	# Adds the vertex ``u`` to this graph.
	#
	# If ``u`` already belongs to the graph, then
	# nothing happens.
	fun add_vertex(u: V) is abstract

	# Removes the vertex ``u`` from this graph and all
	# its incident arcs.
	#
	# If the vertex does not exist in the graph, then
	# nothing happens.
	fun remove_vertex(u: V) is abstract

	# Returns the number of vertices in this graph.
	var num_vertices = 0

	# Adds the arc ``(u,v)`` to this graph.
	#
	# If the arc already exists in the graph, then
	# nothing happens. If vertex ``u`` or vertex ``v``
	# do not exist in the graph, they are added.
	fun add_arc(u: V, v: V) is abstract

	# Removes the arc ``(u,v)`` from this graph.
	#
	# If the arc does not exist in the graph, then
	# nothing happens.
	fun remove_arc(u: V, v: V) is abstract

	# Returns the predecessors of ``u``, i.e. the
	# vertices ``v`` such that ``(u,v)`` is an arc
	fun predecessors(u: V): Collection[V] is abstract

	# Returns the successors of ``u``, i.e. the
	# vertices ``v`` such that ``(u,v)`` is an arc
	fun successors(u: V): Collection[V] is abstract

	## Non abstract methods ##

	redef fun to_s: String
	do
		if num_vertices >= 2 then
			return "Digraph of {num_vertices} vertices"
		else
			return "Digraph of {num_vertices} vertex"
		end
	end

	# Returns the indegree of ``u``, i.e. the number
	# of arcs whose target is ``u``.
	fun in_degree(u: V): Int
	do
		return predecessors(u).length
	end

	# Returns the outdegree of ``u``, i.e. the number
	# of arcs whose source is ``u``.
	fun out_degree(u: V): Int
	do
		return successors(u).length
	end
end

# A directed graph with low density.
class SparseDigraph[V: Object]
	super AbstractDigraph[V]

	# Attributes
	private var objects: Array[V] is noinit
	private var pred_map = new HashMap[V, Array[V]]
	private var succ_map = new HashMap[V, Array[V]]

	redef fun add_vertex(u: V)
	do
		if pred_map.keys.has(u) then
			return
		else
			pred_map[u] = new Array[V]
			succ_map[u] = new Array[V]
			num_vertices += 1
		end
	end

	redef fun remove_vertex(u: V)
	do
		if succ_map.keys.has(u) then
			for v in succ_map[u] do
				remove_arc(u, v)
			end
			succ_map.keys.remove(u)
			num_vertices -= 1
		end
	end

	redef fun add_arc(u: V, v: V)
	do
		if not succ_map.keys.has(u) then add_vertex(u)
		if not succ_map.keys.has(v) then add_vertex(v)
		succ_map[u].add(v)
		pred_map[v].add(u)
	end

	redef fun remove_arc(u: V, v: V)
	do
		if succ_map.keys.has(u) and succ_map[u].has(v) then
			succ_map[u].remove(v)
			pred_map[v].remove(u)
		end
	end

	redef fun predecessors(u: V): Collection[V]
	do
		return pred_map[u]
	end

	redef fun successors(u: V): Collection[V]
	do
		return succ_map[u]
	end
end
