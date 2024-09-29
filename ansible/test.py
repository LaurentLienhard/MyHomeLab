import matplotlib.pyplot as plt
import networkx as nx

G = nx.DiGraph()

G.add_edges_from([("A", "B"), ("A", "C"), ("B", "D"), ("C", "D")])

pos = nx.spring_layout(G)
nx.draw(G, pos, with_labels=True)
plt.show()