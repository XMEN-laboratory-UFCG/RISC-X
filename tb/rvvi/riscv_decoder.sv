
import core_pkg::*;

class riscv_decoder;

    // Constructor
    function new();
    endfunction

    // Function to decode an instruction and return the mnemonic
    function string decode_instruction (logic [31:0] instruction);
        logic [6:0] opcode;
        string mnemonic;
        
        // Extract the opcode
        opcode = instruction[6:0];
        
        // Decode based on the opcode
        case (opcode)
            OPCODE_LUI:       mnemonic = decode_lui(instruction);
            OPCODE_AUIPC:     mnemonic = decode_auipc(instruction);
            OPCODE_JAL:       mnemonic = decode_jal(instruction);
            OPCODE_JALR:      mnemonic = decode_jalr(instruction);
            OPCODE_BRANCH:    mnemonic = decode_branch(instruction);
            OPCODE_LOAD:      mnemonic = decode_load(instruction);
            OPCODE_STORE:     mnemonic = decode_store(instruction);
            OPCODE_OP_IMM:    mnemonic = decode_op_imm(instruction);
            OPCODE_OP:        mnemonic = decode_op(instruction);
            // OPCODE_MISC_MEM:  mnemonic = decode_misc_mem(instruction);
            OPCODE_SYSTEM:    mnemonic = decode_system(instruction);
            default:      mnemonic = "UNKNOWN";
        endcase
        
        return mnemonic;
    endfunction

    // Function to decode LUI instruction
    function string decode_lui(logic [31:0] instruction);
        string rd, imm;
        // logic [19:0] imm;
        rd = translate_register(instruction[11:7]);
        // if (instruction[31])
        //     imm = $sformatf("-0x%0h", -instruction[31:12]);
        // else
        //     imm = $sformatf("0x%0h", instruction[31:12]);
        // return $sformatf("lui %s, %s", rd, imm);
        return $sformatf("lui %s, 0x%0h", rd, instruction[31:12]);
        // return $sformatf("lui x%0d, 0x%0h", instruction[11:7], instruction[31:12]);
    endfunction

    // Function to decode AUIPC instruction
    function string decode_auipc(logic [31:0] instruction);
        string rd, imm;
        rd = translate_register(instruction[11:7]);
        return $sformatf("auipc %s, 0x%0h", rd, instruction[31:12]);
        // return $sformatf("auipc x%0d, 0x%0h", instruction[11:7], instruction[31:12]);
    endfunction

    // Function to decode JAL instruction
    function string decode_jal(logic [31:0] instruction);
        string rd, imm;
        rd = translate_register(instruction[11:7]);
        return $sformatf("jal %s, 0x%0h", rd, {instruction[31], instruction[19:12], instruction[20], instruction[30:21]});
        // return $sformatf("jal x%0d, 0x%0h", instruction[11:7], {instruction[31], instruction[19:12], instruction[20], instruction[30:21]});
    endfunction

    // Function to decode JALR instruction
    function string decode_jalr(logic [31:0] instruction);
        string rd, rs1, imm;
        rd  = translate_register(instruction[11:7]);
        rs1 = translate_register(instruction[19:15]);
        return $sformatf("jalr %s, %s, 0x%0h", rd, rs1, instruction[31:20]);
        // return $sformatf("jalr x%0d, x%0d, 0x%0h", instruction[11:7], instruction[19:15], instruction[31:20]);
    endfunction

    // Function to decode BRANCH instructions
    function string decode_branch(logic [31:0] instruction);
        string rs1, rs2, imm;
        string func;
        rs1 = translate_register(instruction[19:15]);
        rs2 = translate_register(instruction[24:20]);
        case (instruction[14:12])
            3'b000: func = "beq";
            3'b001: func = "bne";
            3'b100: func = "blt";
            3'b101: func = "bge";
            3'b110: func = "bltu";
            3'b111: func = "bgeu";
            default: func = "UNKNOWN";
        endcase
        return $sformatf("%s %s, %s, 0x%0h", func, rs1, rs2, {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0});
        // return $sformatf("%s x%0d, x%0d, pc + 0x%0h", func, instruction[19:15], instruction[24:20], {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0});
    endfunction

    // Function to decode LOAD instructions
    function string decode_load(logic [31:0] instruction);
        string rd, rs1, imm;
        string func;
        rd  = translate_register(instruction[11:7]);
        rs1 = translate_register(instruction[19:15]);
        case (instruction[14:12])
            3'b000: func = "lb";
            3'b001: func = "lh";
            3'b010: func = "lw";
            3'b100: func = "lbu";
            3'b101: func = "lhu";
            default: func = "UNKNOWN";
        endcase
        return $sformatf("%s %s, 0x%0h(%s)", func, rd, instruction[31:20], rs1);
        // return $sformatf("%s x%0d, 0x%0h(x%0d)", func, instruction[11:7], instruction[31:20], instruction[19:15]);
    endfunction

    // Function to decode STORE instructions
    function string decode_store(logic [31:0] instruction);
        string rs1, rs2, imm;
        string func;
        rs1 = translate_register(instruction[19:15]);
        rs2 = translate_register(instruction[24:20]);
        case (instruction[14:12])
            3'b000: func = "sb";
            3'b001: func = "sh";
            3'b010: func = "sw";
            default: func = "UNKNOWN";
        endcase
        return $sformatf("%s %s, 0x%0h(%s)", func, rs2, {instruction[31:25], instruction[11:7]}, rs1);
        // return $sformatf("%s x%0d, 0x%0h(x%0d)", func, instruction[24:20], {instruction[31:25], instruction[11:7]}, instruction[19:15]);
    endfunction

    // Function to decode OP-IMM instructions
    function string decode_op_imm(logic [31:0] instruction);
        string rd, rs1, imm;
        string func;
        logic [11:0] imm_bits;
        rd  = translate_register(instruction[11:7]);
        rs1 = translate_register(instruction[19:15]);
        imm_bits = instruction[31:20];
        if (instruction[31])
            // imm = $sformatf("-0x%0h", -imm_bits);
            imm = $sformatf("-%0d", -imm_bits);
        else
            // imm = $sformatf("0x%0h", imm_bits);
            imm = $sformatf("%0d", imm_bits);
        case (instruction[14:12])
            3'b000: func = "addi";
            3'b001: func = (instruction[31:25]==7'h0) ? ("slli") : ("UNKNOWN");
            3'b010: func = "slti";
            3'b011: func = "sltiu";
            3'b100: func = "xori";
            3'b101: func = (instruction[31:25]==7'h0) ? ("srli") : ((instruction[31:25]==7'h20) ? ("srai") : ("UNKNOWN"));
            3'b110: func = "ori";
            3'b111: func = "andi";
            default: func = "UNKNOWN";
        endcase
        return $sformatf("%s %s, %s, %s", func, rd, rs1, imm);
        // return $sformatf("%s %s, %s, 0x%0h", func, rd, rs1, instruction[31:20]);
        // return $sformatf("%s x%0d, x%0d, 0x%0h", func, instruction[11:7], instruction[19:15], instruction[31:20]);
    endfunction

    // Function to decode OP instructions
    function string decode_op(logic [31:0] instruction);
        string rd, rs1, rs2;
        string func;
        rd  = translate_register(instruction[11:7]);
        rs1 = translate_register(instruction[19:15]);
        rs2 = translate_register(instruction[24:20]);
        case (instruction[14:12])
            3'b000: func = (instruction[30] == 1'b0) ? "add" : "sub";
            3'b001: func = "sll";
            3'b010: func = "slt";
            3'b011: func = "sltu";
            3'b100: func = "xor";
            3'b101: func = (instruction[30] == 1'b0) ? "srl" : "sra";
            3'b110: func = "or";
            3'b111: func = "and";
            default: func = "UNKNOWN";
        endcase
        return $sformatf("%s %s, %s, %s", func, rd, rs1, rs2);
        // return $sformatf("%s x%0d, x%0d, x%0d", func, instruction[11:7], instruction[19:15], instruction[24:20]);
    endfunction

    // Function to decode MISC-MEM instructions
    function string decode_misc_mem(logic [31:0] instruction);
        return $sformatf("fence");
    endfunction

    // Function to decode SYSTEM instructions
    function string decode_system(logic [31:0] instruction);
        string rd, rs1;
        string csr_name;
        csr_addr_t csr_addr;
        rd  = translate_register(instruction[11:7]);
        rs1 = translate_register(instruction[19:15]);
        if (instruction[14:12] == '0) begin
            if ({instruction[19:15], instruction[11:7]} == '0) begin
                case (instruction[31:20])
                    12'h000: begin // ecall
                        return $sformatf("ecall");
                    end
                    12'h001: begin // ebreak
                        return $sformatf("ebreak");
                    end
                    12'h302: begin // mret
                        return $sformatf("mret");
                    end
                    12'h002: begin // uret
                        return $sformatf("uret");
                    end
                    12'h7b2: begin // dret
                        return $sformatf("dret");
                    end
                    12'h105: begin // wfi
                        return $sformatf("wfi");
                    end
                    default: begin
                        return $sformatf("UNKNOWN");
                    end
                endcase
            end
            else begin
                return $sformatf("UNKNOWN");
            end
        end
        else begin
            csr_addr = csr_addr_t'(instruction[31:20]);
            csr_name = translate_csr(csr_addr);
            
            case (instruction[14:12])
                3'b001: begin // csrrw
                    // return $sformatf("csrrw x%0d, %s, x%0d", instruction[11:7], csr_name, instruction[19:15]); 
                    return $sformatf("csrrw %s, %s, %s", rd, csr_name, rs1); 
                end
                3'b010: begin // csrrs
                    // return $sformatf("csrrs x%0d, %s, x%0d", instruction[11:7], csr_name, instruction[19:15]); 
                    return $sformatf("csrrs %s, %s, %s", rd, csr_name, rs1); 
                end
                3'b011: begin // csrrc
                    // return $sformatf("csrrc x%0d, %s, x%0d", instruction[11:7], csr_name, instruction[19:15]); 
                    return $sformatf("csrrc %s, %s, %s", rd, csr_name, rs1); 
                end
                3'b101: begin // csrrwi
                    // return $sformatf("csrrwi x%0d, %s, x%0d", instruction[11:7], csr_name, instruction[19:15]); 
                    // return $sformatf("csrrwi %s, %s, %s", rd, csr_name, rs1); 
                    return $sformatf("csrrwi %s, %s, 0x%0h", rd, csr_name, instruction[19:15]); 
                end
                3'b110: begin // csrrsi
                    // return $sformatf("csrrsi x%0d, %s, x%0d", instruction[11:7], csr_name, instruction[19:15]); 
                    // return $sformatf("csrrsi %s, %s, %s", rd, csr_name, rs1); 
                    return $sformatf("csrrsi %s, %s, 0x%0h", rd, csr_name, instruction[19:15]); 
                end
                3'b111: begin // csrrci
                    // return $sformatf("csrrci x%0d, %s, x%0d", instruction[11:7], csr_name, instruction[19:15]); 
                    // return $sformatf("csrrci %s, %s, %s", rd, csr_name, rs1); 
                    return $sformatf("csrrci %s, %s, 0x%0h", rd, csr_name, instruction[19:15]); 
                end
                default: begin
                    return $sformatf("UNKNOWN"); 
                end
            endcase
        end
    endfunction

    // Function to translate register number to mnemonic
    function string translate_register(logic [4:0] reg_num);
        case (reg_num)
            5'd0:  return "zero";
            5'd1:  return "ra";
            5'd2:  return "sp";
            5'd3:  return "gp";
            5'd4:  return "tp";
            5'd5:  return "t0";
            5'd6:  return "t1";
            5'd7:  return "t2";
            5'd8:  return "s0";
            5'd9:  return "s1";
            5'd10: return "a0";
            5'd11: return "a1";
            5'd12: return "a2";
            5'd13: return "a3";
            5'd14: return "a4";
            5'd15: return "a5";
            5'd16: return "a6";
            5'd17: return "a7";
            5'd18: return "s2";
            5'd19: return "s3";
            5'd20: return "s4";
            5'd21: return "s5";
            5'd22: return "s6";
            5'd23: return "s7";
            5'd24: return "s8";
            5'd25: return "s9";
            5'd26: return "s10";
            5'd27: return "s11";
            5'd28: return "t3";
            5'd29: return "t4";
            5'd30: return "t5";
            5'd31: return "t6";
            default: return "UNKNOWN_REG";
        endcase
    endfunction

    // Function to translate CSR address to mnemonic
    function string translate_csr(csr_addr_t csr_addr);
        string str;
        str = csr_addr.name(); // CSR name is defined in the typedef as CSR_NAME
        str = str.tolower();   // Make everything lowercase
        str = str.substr(4,str.len()-1); // Drop the "csr_" part
        return str;
    endfunction
    
endclass