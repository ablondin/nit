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
print(g)

var path = g.a_shortest_path("a", "e")
if path != null then print(path)

for subset in g.strongly_connected_components.to_partitions do
	print subset
end
