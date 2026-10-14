#!/usr/bin/env bash
# 使用 Icarus Verilog 对 Lab1 所有设计进行仿真验证
set -u
cd "$(dirname "$0")"
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT
failed=0

run() {
    local name=$1; shift
    if ! iverilog -g2005 -Wall -Wno-timescale -o "$build_dir/$name" "$@"; then
        echo "[$name] COMPILE ERROR"; failed=1; return
    fi
    local output
    output=$(vvp -n "$build_dir/$name")
    echo "$output" | sed "s/^/[$name] /"
    echo "$output" | grep -qx "PASS" || failed=1
}

run q1_reverse        required/q1_reverse.v        tb/tb_reverse.v
run q2_1_max2_assign  required/q2_1_max2_assign.v  tb/tb_max2.v
run q2_2_max3_always  required/q2_2_max3_always.v  tb/tb_max3.v
run q2_3_max3_inst    required/q2_3_max3_inst.v    tb/tb_max3.v
run q3_count_ones     required/q3_count_ones.v     tb/tb_count_ones.v
run s2_operators      selective/q2_operators.v     tb/tb_operators.v
run o1_regfile        optional/q1_regfile.v        tb/tb_regfile.v
run o2_mux2_param     optional/q2_mux2_param.v     tb/tb_mux2.v

if [ $failed -eq 0 ]; then echo "ALL PASS"; else echo "SOME TESTS FAILED"; exit 1; fi
