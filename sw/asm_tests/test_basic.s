# Basic integration test program (RV32I)
# Expected: x1=5, x2=3, x3=8, mem[0]=8, x4=8, x5=0 (skipped by beq), x6=1
        addi x1, x0, 5        # 0x00500093
        addi x2, x0, 3        # 0x00300113
        add  x3, x1, x2       # 0x002081B3
        sw   x3, 0(x0)        # 0x00302023
        lw   x4, 0(x0)        # 0x00002203
        beq  x3, x4, skip     # 0x00418463 (taken, skips next instr)
        addi x5, x0, 99       # 0x06300293 (must NOT execute)
skip:   addi x6, x0, 1        # 0x00100313
end:    jal  x0, end          # 0x0000006F (infinite loop)