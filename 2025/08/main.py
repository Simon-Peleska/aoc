import math

file = open("input", "r")
# file = open("input2", "r")
level: int = 1
# y_len = len(lines)


def get_dist(point1: list[int], point2: list[int]):
    return (
        (point1[0] - point2[0]) ** 2
        + (point1[1] - point2[1]) ** 2
        + (point1[2] - point2[2]) ** 2
    ) ** 1 / 2


def get_graph(
    conns: dict[int, list[int]], point_idx: int, graph_parts: set[int]
) -> set[int]:
    if point_idx in graph_parts:
        return graph_parts

    graph_parts.add(point_idx)

    for point in conns[point_idx]:
        graph_parts = get_graph(conns, point, graph_parts)

    return graph_parts


def main():
    count = 0
    points: list[list[int]] = [
        [int(coord) for coord in line.split(",")] for line in file.readlines()
    ]

    dists: list[list[int]] = []
    for i in range(len(points)):
        for j in range(len(points)):
            if i >= j:
                continue
            dist = get_dist(points[i], points[j])
            count += dist
            dists.append([dist, i, j])

    dists = sorted(dists, key=lambda dist: dist[0])

    conns: dict[int, list[int]] = dict()

    if level == 1:
        dists = dists[:1000]

        for dist in dists:
            if dist[1] not in conns:
                conns[dist[1]] = []

            conns[dist[1]].append(dist[2])

            if dist[2] not in conns:
                conns[dist[2]] = []

            conns[dist[2]].append(dist[1])

        graph_lens: list[int] = []

        conns_keys_snap = conns.copy().keys()
        for conn in conns_keys_snap:
            if conn in conns:
                graph = get_graph(conns, conn, set())

                graph_lens.append(len(graph))

                for idx in graph:
                    conns.pop(idx)

        lens = sorted(graph_lens)[-3:]

        count = math.prod(lens)
    else:
        for dist in dists:
            if dist[1] not in conns:
                conns[dist[1]] = []

            conns[dist[1]].append(dist[2])

            if dist[2] not in conns:
                conns[dist[2]] = []

            conns[dist[2]].append(dist[1])

            if len(get_graph(conns, dist[1], set())) == len(points):
                count = points[dist[1]][0] * points[dist[2]][0]
                break

    print(count)


if __name__ == "__main__":
    main()
