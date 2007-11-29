### .perltidyrc as recommended by PBP.
### obtained from http://www.perlmonks.org/?node_id=485885
-l=78   # Max line width is 78 cols
-i=4    # Indent level is 4 cols
-ci=4   # Continuation indent is 4 cols
-se     # Errors to STDERR
-vt=2   # Maximal vertical tightness
-cti=0  # No extra indentation for closing brackets
-pt=1   # Medium parenthesis tightness
-bt=1   # Medium brace tightness
-sbt=1  # Medium square bracket tightness
-bbt=1  # Medium block brace tightness
-nsfs   # No space before semicolons
-nolq   # Don't outdent long quoted strings
-wbb="% + - * / x != == >= <= =~ !~ < > | & >= < = **= += *= &= <<= && += -= /= |= >>= ||= .= %= ^= x="
        # Break before all operators
