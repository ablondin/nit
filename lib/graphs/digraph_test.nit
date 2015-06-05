import digraph

#var g = new HashMapDigraph[String, nullable Int]
#g.add_vertex("a")
#g.add_vertex("b")
#g.add_vertex("c")
#g.add_vertex("d")
#g.add_vertex("e")
#g.add_arc("a", "b")
#g.add_arc("a", "c", 2)
#g.add_arc("a", "d", 3)
#g.add_arc("b", "d", 5)
#g.add_arc("c", "d", 1)
#g.add_arc("d", "a", 0)
#g.add_arc("d", "e", 2)
#print g.to_dot
#
#var path = g.a_shortest_path("a", "e")
#if path != null then print path else print "No path from a to e"
#
#for u in "abcde" do
#	for v in "abcde" do
#		var d = g.distance(u.to_s, v.to_s)
#		if d == null then
#			print "no path from {u} to {v}"
#		else
#			print "dist({u}, {v}) = {d}"
#		end
#	end
#end

var g = new HashMapDigraph[Int, nullable Int]
g.add_arc(1, 3)
g.add_arc(2, 3)
for arc in g.incoming_arcs(3) do
	assert g.is_predecessor(arc.source, arc.target)
end
