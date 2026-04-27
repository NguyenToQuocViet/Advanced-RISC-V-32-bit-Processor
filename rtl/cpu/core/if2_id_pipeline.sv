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
// Module       : IF2/ID Pipeline Register
// Description  : Renamed from if_id_pipeline (5-stage) for 7-stage pipeline.
//                Captures instruction + PC + branch prediction after I-Cache
//                tag compare completes in IF2.
//
// Author       : NGUYEN TO QUOC VIET
// Date         : 2026-04-27
// Version      : 2.0
// Changes      : Renamed from if_id_pipeline for 7-stage pipeline.
// -----------------------------------------------------------------------------

module if2_id_pipeline
    import cpu_pkg::*;
(
    input  logic                    clk,
    input  logic                    rst_n,

    input  logic                    stall,
    input  logic                    flush,

    //if2 interface
    input  logic [ADDR_WIDTH-1:0]   if_pc_i,
    input  logic [DATA_WIDTH-1:0]   if_instr_i,
    input  logic                    if_pred_taken_i,
    input  logic [ADDR_WIDTH-1:0]   if_pred_target_i,

    //id interface
    output logic [ADDR_WIDTH-1:0]   id_pc_o,
    output logic [DATA_WIDTH-1:0]   id_instr_o,
    output logic                    id_pred_taken_o,
    output logic [ADDR_WIDTH-1:0]   id_pred_target_o
);
    logic [ADDR_WIDTH-1:0]  pc;
    logic [DATA_WIDTH-1:0]  instr;
    logic                   pred_taken;
    logic [ADDR_WIDTH-1:0]  pred_target;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc          <= '0;
            instr       <= NOP_INSTR;
            pred_taken  <= 1'b0;
            pred_target <= '0;
        end else begin
            if (flush) begin
                pc          <= '0;
                instr       <= NOP_INSTR;
                pred_taken  <= 1'b0;
                pred_target <= '0;
            end else if (stall) begin
                pc          <= pc;
                instr       <= instr;
                pred_taken  <= pred_taken;
                pred_target <= pred_target;
            end else begin
                pc          <= if_pc_i;
                instr       <= if_instr_i;
                pred_taken  <= if_pred_taken_i;
                pred_target <= if_pred_target_i;
            end
        end
    end

    assign id_pc_o          = pc;
    assign id_instr_o       = instr;
    assign id_pred_taken_o  = pred_taken;
    assign id_pred_target_o = pred_target;
endmodule
