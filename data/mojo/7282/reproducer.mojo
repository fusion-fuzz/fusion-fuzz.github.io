comptime D: Dict[Int, List[Int]] = {800: [1]}


def main():
    var result = List[Int]()
    var vals = materialize[D.values()]()
    for value in vals:
        result += value.copy()
    print(len(result))
