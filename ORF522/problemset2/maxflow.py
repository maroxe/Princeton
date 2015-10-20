#!/usr/bin/env python
#
# http://en.wikipedia.org/wiki/Ford-Fulkerson_algorithm
# Ford-Fulkerson algorithm computes max flow in a flow network.
#


class Edge(object):
  def __init__(self, u, v, w):
    self.source = u
    self.target = v
    self.capacity = w

  def __repr__(self):
    return "%s->%s:%s" % (self.source, self.target, self.capacity)


class FlowNetwork(object):
  def  __init__(self):
    self.adj = {}
    self.flow = {}

  def AddVertex(self, vertex):
      self.adj[vertex] = []

  def GetEdges(self, v):
    return self.adj[v]

  def AddEdge(self, u, v, w = 0):
    if u == v:
      raise ValueError("u == v")
    edge = Edge(u, v, w)
    redge = Edge(v, u, 0)
    edge.redge = redge
    redge.redge = edge
    self.adj[u].append(edge)
    self.adj[v].append(redge)
    # Intialize all flows to zero
    self.flow[edge] = 0
    self.flow[redge] = 0

  def FindPath(self, source, target, path):
    if source == target:
      return path
    for edge in self.GetEdges(source):
      residual = edge.capacity - self.flow[edge]
      if residual > 0 and not (edge, residual) in path:
        result = self.FindPath(edge.target, target, path + [(edge, residual)])
        if result != None:
          return result

  def MaxFlow(self, source, target):
    path = self.FindPath(source, target, [])
    print('path after enter MaxFlow: %s' % path)
    for key in self.flow:
      print('%s:%s' % (key,self.flow[key]))
    print('-' * 20)
    while path != None:
      flow = min(res for edge, res in path)
      for edge, res in path:
        self.flow[edge] += flow
        self.flow[edge.redge] -= flow
      for key in self.flow:
        print('%s:%s' % (key,self.flow[key]))
      path = self.FindPath(source, target, [])
      print('path inside of while loop: %s' % path)
    for key in self.flow:
      print('%s:%s' % (key,self.flow[key]))
    return sum(self.flow[edge] for edge in self.GetEdges(source))


if __name__ == "__main__":
  g = FlowNetwork()
  list(map(g.AddVertex, ['s', 'b', 'c', 'd', 'e', 'f', 't']))
  g.AddEdge('s', 'b', 5)
  g.AddEdge('s', 'c', 4)
  g.AddEdge('s', 'd', 8)

  g.AddEdge('b', 'd', 1)
  g.AddEdge('b', 'e', 3)

  g.AddEdge('c', 'f', 5)

  g.AddEdge('d', 'c', 3)
  g.AddEdge('d', 'e', 4)
  g.AddEdge('d', 'f', 6)

  g.AddEdge('e', 'f', 1)
  g.AddEdge('e', 't', 10)

  g.AddEdge('f', 'e', 1)
  g.AddEdge('f', 't', 6)

  g.AddEdge('t', 'f', 1)

  print(g.MaxFlow('s', 't'))
