import digraph

var g = new ArrayDigraph[String]
g.add_vertex("a")
g.add_vertex("b")
g.add_arc("a", "c")
g.add_arc("b", "c")
g.add_arc("c", "a")
g.add_arc("d", "e")
print(g.vertices)
print(g.arcs)
print(g.to_graphviz)
print(g.incoming_arcs("b"))
print(g.outgoing_arcs("b"))
var cc = g.weak_connected_components
print(cc)
print(cc.all_subsets)
