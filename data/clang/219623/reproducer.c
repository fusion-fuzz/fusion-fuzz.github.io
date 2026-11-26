void binding_to_label_loc() {
  char *b = &&MyLabel; // expected-note {{'b' initialized here}}
MyLabel:
  *b = 0;
}
