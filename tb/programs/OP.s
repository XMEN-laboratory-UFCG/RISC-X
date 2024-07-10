.globl main

.text
main:
	# Load initial values
    addi x1, x0, 3
    addi x2, x0, 9
    
    # Test the OP instructions
    add x2, x1, x2
    sub x3, x1, x2
    xor x4, x2, x3
    or x5, x3, x4
    and x6, x5, x4
    sll x7, x6, x1
    srl x8, x7, x1
    sra x9, x7, x1
    slt x10, x8, x7
    sltu x11, x7, x8

	# Store the regs to mem for dumping
    sw x0, 0(x0)
    sw x1, 4(x0)
    sw x2, 8(x0)
    sw x3, 12(x0)
    sw x4, 16(x0)
    sw x5, 20(x0)
    sw x6, 24(x0)
    sw x7, 28(x0)
    sw x8, 32(x0)
    sw x9, 36(x0)
    sw x10, 40(x0)
    sw x11, 44(x0)
    sw x12, 48(x0)
    sw x13, 52(x0)
    sw x14, 56(x0)
    sw x15, 60(x0)
    sw x16, 64(x0)
    sw x17, 68(x0)
    sw x18, 72(x0)
    sw x19, 76(x0)
    sw x20, 80(x0)
    sw x21, 84(x0)
    sw x22, 88(x0)
    sw x23, 92(x0)
    sw x24, 96(x0)
    sw x25, 100(x0)
    sw x26, 104(x0)
    sw x27, 108(x0)
    sw x28, 112(x0)
    sw x29, 116(x0)
    sw x30, 120(x0)
    sw x31, 124(x0)
