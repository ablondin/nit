import digraph

var g = new HashMapDigraph[String]
g.add_vertex("a")
g.add_vertex("b")
g.add_vertex("c")
g.add_vertex("d")
g.add_vertex("e")
g.add_arc("a", "b")
g.add_arc("a", "c")
g.add_arc("a", "d")
g.add_arc("b", "d")
g.add_arc("c", "d")
g.add_arc("d", "a")
g.add_arc("d", "e")

var path = g.a_shortest_path("a", "e")
if path != null then print(path) else print "null"

for u in "abcde" do
	for v in "abcde" do
		var d = g.distance(u.to_s, v.to_s)
		if d == null then
			print "no path from {u} to {v}"
		else
			print "dist({u}, {v}) = {d}"
		end
	end
end
