#!/usr/bin/env bash
set -uxo pipefail

#####################
# Sameple Functions #
#####################
verbose=""
kontrol_build() {
    kontrol build "$@"
}

kontrol_prove() {
    kontrol prove "$@"
}

kontrol_show() {
    kontrol show "${test}" "$@"
}

kontrol_to_dot() {
    kontrol to-dot "${test}" "$@"
}

kontrol_view() {
    kontrol view-kcfg "${test}" "$@"
}

kontrol_list() {
    kontrol list "$@"
}

kontrol_remove_node() {
    node_id="$1" ; shift
    kontrol remove-node "${test}" ${node_id} "$@"
}

kontrol_simplify_node() {
    node_id="$1" ; shift
    kontrol simplify-node "${test}" ${node_id} "${bug_report}" "$@"
}

kontrol_step_node() {
    node_id="$1" ; shift
    kontrol step-node "${test}" ${node_id} "${bug_report}" "$@"
}

kontrol_section_edge() {
    edge_id="$1" ; shift
    kontrol section-edge "${test}" ${edge_id} "${bug_report}" "$@"
}

#################################
# Kore RPC Server Stuck? Run .. #
#################################
# pkill kore-rpc || true

kontrol_build --require lemmas.k --module-import ERC20:DEMO-LEMMAS --verbose
kontrol_list
kontrol_prove -j$(getconf _NPROCESSORS_ONLN) \
            --bug-report=BUGREPORT.bug \
            --match-test Examples.test_assert_bool_failing \
            --match-test Examples.test_assert_bool_passing
            # --match-test Examples.test_wmul_increasing_overflow\
            # --match-test Examples.test_wmul_increasing\
            # --match-test Examples.test_wmul_increasing_positive\
            # --match-test Examples.test_wmul_increasing_gt_one\
            # --match-test Examples.test_wmul_weakly_increasing_positive\
            # --match-test Examples.test_wmul_wdiv_inverse_underflow\
            # --match-test Examples.test_wmul_wdiv_inverse
kontrol_list --verbose

###########################
# Additional Tests to Run #
###########################
#test=Examples.test_assert_bool_failing
#test=Examples.test_assert_bool_passing
#test=Examples.test_wmul_increasing_overflow
#test=Examples.test_wmul_increasing
#test=Examples.test_wmul_increasing_positive
#test=Examples.test_wmul_weakly_increasing_positive
#test=Examples.test_wmul_increasing_ge_one
#test=Examples.test_wmul_wdiv_inverse_underflow
#test=Examples.test_wmul_wdiv_inverse

###################################
# Review Assert bool Failing Test #
###################################
test=Examples.test_assert_bool_failing
kontrol_show --verbose

################
# Modify Nodes #
################
# kontrol_remove_node 4b6c47..d6d6d3
# kontrol_prove --reinit


##############################
# Additional Reinit Examples #
##############################
# test=AssertTest.test_sum_10
# date
# kontrol_prove --reinit
# date
# kontrol_prove --reinit
# date
# test=AssertTest.test_sum_100
# date
# kontrol_prove --reinit
# date
# kontrol_prove --reinit
# date
# test=AssertTest.test_sum_1000
# date
# kontrol_prove --reinit
# date
# kontrol_prove --reinit
# date

##########################
# Additional Run Example #
##########################
# kontrol_prove --reinit
# kontrol_section_edge --sections 4 d38e0e..ee4ec8,593be8..e93e52
# kontrol_show # --no-minimize --node 35880c..e4389e --node 17e757..6c2e55
# kontrol_view
# for test in ERC20Test.testAllowance ERC20Test.testApproveFailure_0 ERC20Test.testApproveFailure_1 ERC20Test.testApproveSuccess ERC20Test.testBalanceOf ERC20Test.testDecimals ERC20Test.testNameAndSymbol ERC20Test.testTotalSupply ERC20Test.testTransferFailure_0 ERC20Test.testTransferFailure_1 ERC20Test.testTransferFailure_2 ERC20Test.testTransferFromFailure ERC20Test.testTransferFromSuccess_0 ERC20Test.testTransferFromSuccess_1 ERC20Test.testTransferSuccess_0 ERC20Test.testTransferSuccess_1; do
#     kontrol_to_dot
# done
