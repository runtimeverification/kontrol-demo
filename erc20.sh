#!/usr/bin/env bash
set -euxo pipefail


#### Get only the ERC20 tests in 'tests-to-run' using jq
jq '.ast.nodes[] | .name + "." + ( .nodes[].name | select(. |startswith("test")))' -r out/*.t.sol/*json | sort -u | grep -v -F -f exclude > tests-to-run

time kontrol build --require lemmas.k --module-import ERC20:DEMO-LEMMAS

for TEST in $(cat tests-to-run); do
  echo "++++++++++++++++++++++++ $TEST +++++++++++++++++++++++++"
  time kontrol prove --match-test $TEST --max-depth 10000 || true
  echo "-------------"
done < "tests-to-run" 2>&1 | tee tests-to-run.booster.timing-output


# printf "| Proof | Result | kore-rpc | sec | booster | sec |\n|-\n"
# grep -h -e PROOF -A2 tests-to-run.timing-output \
#     | sed \
#         -e "/--/d" \
#         -e "/^$/d" \
#     | sed \
#         -e "N;N;N;s/\(PROOF \([^:]*\): \([^\n]*\)\)\nreal\t*\([^\n]*\)\n\1\nreal\t\([^\n]*\)/| \3 | \2 | \4 | | \5 | |/g"
#         -e "s/ \([0-9]\)m/00:0\1:/g" \
#         -e "s/\([1-5][0-9]\)m/00:\1:/g" \
#         -e "s/:\([0-9]\.[0-9]*\)s/:0\1/g" \
#         -e "s/:\([1-5][0-9].[0-9]*\)s/:\1/g"
