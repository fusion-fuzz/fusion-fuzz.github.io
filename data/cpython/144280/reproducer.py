import re
class Grammar:
    def __init__(self, rules: Dict[str, str]):
        self.rules = rules
def parse_string(grammar_source: str, _parser=None) -> Grammar:
    rules: Dict[str, str] = {}
    for line in grammar_source.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.+)$", line)
        if m:
            name = m.group(1)
            rhs = m.group(2).strip()
            rules[name] = rhs
    return Grammar(rules)
class FirstSetCalculator:
    TOKEN_RE = re.compile(r"'[^']*'|[A-Za-z_][A-Za-z0-9_]*|[^\s]")
    def __init__(self, rules: Dict[str, str]):
        self.rules = dict(rules)
        self.firsts: Dict[str, Set[str]] = {name: set() for name in self.rules}
    def tokenize(self, rhs: str):
        return [tok for tok in self.TOKEN_RE.findall(rhs)]
    def is_terminal(self, tok: str) -> bool:
        return re.fullmatch(r"[A-Z][A-Z0-9_]*", tok) is not None
    def is_nonterminal(self, tok: str) -> bool:
        return re.fullmatch(r"[a-zA-Z_][a-zA-Z0-9_]*", tok) is not None and not self.is_terminal(tok)
    def calculate(self) -> Dict[str, Set[str]]:
        changed = True
        while changed:
            for name, rhs in self.rules.items():
                tokens = self.tokenize(rhs)
                for tok in tokens:
                    if self.is_nonterminal(tok):
                        before = len(self.firsts[name])
def calculate_first_sets(grammar_source: str) -> Dict[str, Set[str]]:
    grammar: Grammar = parse_string(grammar_source, None)
    return FirstSetCalculator(grammar.rules).calculate()
grammar = "\n        start: ','.thing+ NEWLINE\n        thing: NUMBER\n        "
result = calculate_first_sets(grammar)
