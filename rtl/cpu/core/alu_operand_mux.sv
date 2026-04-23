// -----------------------------------------------------------------------------
// Copyright (c) 2026 NGUYEN TO QUOC VIET
// Ho Chi Minh City University of Technology (HCMUT-VNU)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// -----------------------------------------------------------------------------
// Project      : Advanced RISC-V 32-bit Processor
// Module       : alu_operand_mux
// Description  : Final ALU operand selection. src_a chooses fwd_src_a vs PC
//                (AUIPC), src_b chooses fwd_src_b vs imm (I/S/U types).
//
// Author       : NGUYEN TO QUOC VIET
// Date         : 2026-04-23
// Version      : 1.0
// -----------------------------------------------------------------------------

module alu_operand_mux
    import cpu_pkg::*;
(
    //control
    input  logic                    alu_src,        //0=fw_src_b, 1=imm
    input  logic                    alu_src_a,      //0=fw_src_a, 1=pc

    //sources
    input  logic [DATA_WIDTH-1:0]   fw_src_a,
    input  logic [DATA_WIDTH-1:0]   fw_src_b,
    input  logic [ADDR_WIDTH-1:0]   ex_pc,
    input  logic [DATA_WIDTH-1:0]   ex_imm,

    //to ALU
    output logic [DATA_WIDTH-1:0]   alu_src_a_val,
    output logic [DATA_WIDTH-1:0]   alu_src_b_val
);
    //src_a=PC: AUIPC (pc + imm). src_b=imm: I/S/U + AUIPC
    assign alu_src_a_val = alu_src_a ? ex_pc  : fw_src_a;
    assign alu_src_b_val = alu_src   ? ex_imm : fw_src_b;
endmodule
