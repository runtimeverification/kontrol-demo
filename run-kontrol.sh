set -euxo pipefail

kontrol_build() {
    kontrol build --require lemmas.k --module-import ERC20:DEMO-LEMMAS \
            ${verbose}
}

kontrol_prove() {
    kontrol prove ${verbose}     \ 
            ${break_on_calls}    \
            ${bug_report}        \
            ${fail_fast} "$@"
}

kontrol_show() {
    kontrol show ${verbose} ${test} "$@"
}

kontrol_to_dot() {
    kontrol to-dot ${verbose} ${test} "$@"
}

kontrol_view() {
    kontrol view-kcfg ${verbose} ${test} "$@"
}

kontrol_list() {
    kontrol list ${verbose} "$@"
}

kontrol_remove_node() {
    node_id="$1" ; shift
    kontrol remove-node ${verbose} ${test} ${node_id} "$@"
}

kontrol_simplify_node() {
    node_id="$1" ; shift
    kontrol simplify-node ${verbose} ${test} ${node_id} ${bug_report} "$@"
}

kontrol_step_node() {
    node_id="$1" ; shift
    kontrol step-node ${verbose} ${test} ${node_id} ${bug_report} "$@"
}

kontrol_section_edge() {
    edge_id="$1" ; shift
    kontrol section-edge ${verbose} ${test} ${edge_id} ${bug_report} "$@"
}

#test=Examples.test_assert_bool_failing
#test=Examples.test_assert_bool_passing
#test=Examples.test_wmul_increasing_overflow
#test=Examples.test_wmul_increasing
#test=Examples.test_wmul_increasing_positive
#test=Examples.test_wmul_weakly_increasing_positive
#test=Examples.test_wmul_increasing_ge_one
#test=Examples.test_wmul_wdiv_inverse_underflow
#test=Examples.test_wmul_wdiv_inverse

verbose=
verbose=--verbose

break_on_calls=--break-on-calls
# break_on_calls=

bug_report=--bug-report
# bug_report=

# Uncomment these lines as needed
# pkill kore-rpc || true
kontrol_build --rekompile --regen
# kontrol_list
# kontrol_remove_node 4b6c47..d6d6d3
kontrol_prove -j9                                              \
    --match-test Examples.test_assert_bool_failing             \
    --match-test Examples.test_assert_bool_passing             \
    --match-test Examples.test_wmul_increasing_overflow        \
    --match-test Examples.test_wmul_increasing                 \
    --match-test Examples.test_wmul_increasing_positive        \
    --match-test Examples.test_wmul_increasing_gt_one          \
    --match-test Examples.test_wmul_weakly_increasing_positive \
    --match-test Examples.test_wmul_wdiv_inverse_underflow     \
    --match-test Examples.test_wmul_wdiv_inverse
# kontrol_prove --reinit
# kontrol_section_edge --sections 4 d38e0e..ee4ec8,593be8..e93e52
# kontrol_show # --no-minimize --node 35880c..e4389e --node 17e757..6c2e55
# kontrol_view
# for test in ERC20Test.testAllowance ERC20Test.testApproveFailure_0 ERC20Test.testApproveFailure_1 ERC20Test.testApproveSuccess ERC20Test.testBalanceOf ERC20Test.testDecimals ERC20Test.testNameAndSymbol ERC20Test.testTotalSupply ERC20Test.testTransferFailure_0 ERC20Test.testTransferFailure_1 ERC20Test.testTransferFailure_2 ERC20Test.testTransferFromFailure ERC20Test.testTransferFromSuccess_0 ERC20Test.testTransferFromSuccess_1 ERC20Test.testTransferSuccess_0 ERC20Test.testTransferSuccess_1; do
#     kontrol_to_dot
# done

# test=AssertTest.test_sum_10
# date
# kontrol_prove --reinit
# date
# kontrol_prove --reinit
# date
# 
# test=AssertTest.test_sum_100
# date
# kontrol_prove --reinit
# date
# kontrol_prove --reinitf
# date
# 
# test=AssertTest.test_sum_1000
# date
# kontrol_prove --reinit
# date
# kontrol_prove --reinit
# date
