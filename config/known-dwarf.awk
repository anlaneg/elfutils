#!/bin/awk -f

$1 ~ /DW_([A-Z]+)_([^ ]+)/ {
  match($1, /DW_([A-Z]+)_([^ ]+)/, fields);
  set = fields[1];
  elt = fields[2];
  if (set in DW)
    DW[set] = DW[set] "," elt;
  else
    DW[set] = elt;
  if ($NF == "*/" && $4 == "/*") {
    c = $5;
    for (i = 6; i < NF; ++i) c = c " " $i;
    comment[set, elt] = c;
  }
}
END {
  print "/* Generated by config/dwarf-known.awk from libdw.h contents.  */";
  n = asorti(DW, sets);
  for (i = 1; i <= n; ++i) {
    set = sets[i];
    if (what && what != set) continue;
    print "\n#define ALL_KNOWN_DW_" set " \\";
    split(DW[set], elts, ",");
    m = asort(elts);
    lo = hi = "";
    for (j = 1; j <= m; ++j) {
      elt = elts[j];
      if (elt ~ /(lo|low)_user$/) {
	lo = elt;
	continue;
      }
      if (elt ~ /(hi|high)_user$/) {
	hi = elt;
	continue;
      }
      if (comment[set, elt])
	print "  ONE_KNOWN_DW_" set "_DESC (" elt ", DW_" set "_" elt \
	  ", \"" comment[set, elt] "\") \\";
      else
	print "  ONE_KNOWN_DW_" set " (" elt ", DW_" set "_" elt ") \\";
    }
    print "  /* End of DW_" set "_*.  */";
  }
}