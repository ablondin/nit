# Implementation of a directed graph
module digraph

# An arc
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
	#
	# If ``u`` does not exist, then an empty collection
	# is returned.
	fun predecessors(u: V): Collection[V] is abstract

	# Returns the successors of ``u``, i.e. the
	# vertices ``v`` such that ``(u,v)`` is an arc
	#
	# If ``u`` does not exist, then an empty collection
	# is returned.
	fun successors(u: V): Collection[V] is abstract

	# Returns the vertices of this graph.
	fun vertices: Collection[V] is abstract

	# Returns the arcs of this graph.
	fun arcs: Collection[Arc[V]] is abstract

	## -------------------- ##
	## Non abstract methods ##
	## -------------------- ##

	redef fun to_s: String
	do
		var s = "vertices"
		var t = "arcs"
		if num_vertices <= 1 then s = "vertex"
		if num_arcs <= 1 then t = "arc"
		return "Digraph of {num_vertices} {s} and {num_arcs} {t}"
	end

	# Returns the incoming arcs of vertex ``u``.
	#
	# If ``u`` is not in this graph, an empty
	# array is returned.
	fun incoming_arcs(u: V): Array[Arc[V]]
	do
		var arcs = new Array[Arc[V]]
		for v in successors(u) do
			arcs.add(new Arc[V](u, v))
		end
		return arcs
	end

	# Returns the outgoing arcs of vertex ``u``.
	#
	# If ``u`` is not in this graph, an empty
	# array is returned.
	fun outgoing_arcs(u: V): Array[Arc[V]]
	do
		var arcs = new Array[Arc[V]]
		for v in predecessors(u) do
			arcs.add(new Arc[V](v, u))
		end
		return arcs
	end

	# Returns a GraphViz string representing this
	# digraph.
	fun to_graphviz: String
	do
		var s = "digraph \{\n"
		var i = 0
		# Writing the vertices
		for u in vertices do
			s += "  {i} [label=\"{u}\"];\n"
			i += 1
		end
		# Writing the arcs
		for arc in arcs do
			s += "  {arc.source} -> {arc.target};\n"
		end
		s += "\}"
		return s
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

	# -------------------- #
	# Connected components #
	# -------------------- #
	fun weak_connected_components: DisjointSet[V]
	do
		var components = new DisjointSet[V]
		components.add_all(vertices)
		for arc in arcs do
			components.union(arc.source, arc.target)
		end
		return components
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
		if not succ_map[u].has(u) then
			succ_map[u].add(v)
			pred_map[v].add(u)
			num_arcs += 1
		end
	end

	redef fun remove_arc(u: V, v: V)
	do
		if succ_map.keys.has(u) and succ_map[u].has(v) then
			succ_map[u].remove(v)
			pred_map[v].remove(u)
			num_arcs -= 1
		end
	end

	redef fun predecessors(u: V): Collection[V]
	do
		if pred_map.keys.has(u) then
			return pred_map[u]
		else
			return new Array[V]
		end
	end

	redef fun successors(u: V): Collection[V]
	do
		if succ_map.keys.has(u) then
			return succ_map[u]
		else
			return new Array[V]
		end
	end

	redef fun vertices: RemovableCollection[V]
	do
		return pred_map.keys
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
