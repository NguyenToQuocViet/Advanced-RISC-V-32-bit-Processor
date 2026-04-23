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
// Module       : fwd_mux
// Description  : EX-stage operand forwarding. Selects between MEM-fwd, WB-fwd
//                and ID/EX register-read. WB_PC4 path replaces alu_result with
//                pc+4 (JAL/JALR rd write-back).
//
// Author       : NGUYEN TO QUOC VIET
// Date         : 2026-04-23
// Version      : 1.0
// -----------------------------------------------------------------------------

module fwd_mux
    import cpu_pkg::*;
(
    //forward select from FU
    input  logic [1:0]              forward_a,      //00=RF, 01=WB, 10=MEM
    input  logic [1:0]              forward_b,

    //ID/EX register read
    input  logic [DATA_WIDTH-1:0]   ex_rdata1,
    input  logic [DATA_WIDTH-1:0]   ex_rdata2,

    //MEM-stage source: alu_result OR pc+4 (JAL/JALR)
    input  logic [1:0]              mem_wb_sel,
    input  logic [DATA_WIDTH-1:0]   mem_alu_result,
    input  logic [ADDR_WIDTH-1:0]   mem_pc,

    //WB-stage source: already muxed by wb module
    input  logic [DATA_WIDTH-1:0]   wb_wdata,

    //forwarded operands
    output logic [DATA_WIDTH-1:0]   fw_src_a,
    output logic [DATA_WIDTH-1:0]   fw_src_b
);
    //MEM-fwd value: PC+4 for JAL/JALR (wb_sel==WB_PC4), else alu_result
    //load-use already stalled by HDU so mem_rdata never forwarded from MEM
    logic [DATA_WIDTH-1:0] mem_fwd_val;
    assign mem_fwd_val = (mem_wb_sel == WB_PC4) ? (mem_pc + 32'd4) : mem_alu_result;

    //3-to-1 mux, MEM > WB priority (FU enforces)
    assign fw_src_a = (forward_a == 2'b10) ? mem_fwd_val :
                      (forward_a == 2'b01) ? wb_wdata    : ex_rdata1;

    assign fw_src_b = (forward_b == 2'b10) ? mem_fwd_val :
                      (forward_b == 2'b01) ? wb_wdata    : ex_rdata2;
endmodule
