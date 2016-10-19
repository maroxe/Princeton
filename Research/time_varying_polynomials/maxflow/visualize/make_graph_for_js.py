from scipy.interpolate import lagrange
import numpy as np

# python make_graph_for_js.py > maxflow-data-py.js
flow = 'flow-graph3'
cap = 'cap-graph3'
points = 'time-points'

parse_file = lambda s: map(lambda r: map(float, r[:-1].split(',')), s)

regular_points = np.linspace(-1, 1, 100)


def parse_file_interpolate(lines, t):
    rows = map(lambda r: map(float, r[:-1].split(',')), lines)
    rows = map(lambda r: map(lagrange(t, r).__call__, regular_points), rows)
    return rows


template = 'var flow_data = %s;\nvar graph_data = %s;\nvar time_points=%s;'

with open(points) as f:
    t = parse_file(f.readlines())[0]

with open(flow) as f:
    s1 = parse_file_interpolate(f.readlines(), t)

with open(cap) as f:
    s2 = parse_file_interpolate(f.readlines(), t)

s3 = '[' + ','.join(map(str, regular_points)) + ']'

print(template % (str(s1), str(s2), str(s3)))
