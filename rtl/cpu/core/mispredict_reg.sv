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
// Module       : mispredict_reg
// Description  : 1-cycle checkpoint FF on BRU->FCU feedback. Cuts 14-level
//                combinational path EX->IF. Not a pipeline stage.
//
// Author       : NGUYEN TO QUOC VIET
// Date         : 2026-04-23
// Version      : 1.0
// -----------------------------------------------------------------------------

module mispredict_reg
    import cpu_pkg::*;
(
    input  logic                    clk,
    input  logic                    rst_n,

    //from BRU (EX)
    input  logic                    bru_mispredict,
    input  logic [ADDR_WIDTH-1:0]   bru_correct_pc,

    //to FCU + icache flush
    output logic                    mispredict_r,
    output logic [ADDR_WIDTH-1:0]   correct_pc_r,
    output logic                    flush_refill_o
);
    //self-clearing: mispredict_r high for exactly 1 cycle
    //prevents re-trigger while correct_pc is in-flight to IF
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mispredict_r <= 1'b0;
            correct_pc_r <= '0;
        end else begin
            mispredict_r <= bru_mispredict && !mispredict_r;
            correct_pc_r <= bru_correct_pc;
        end
    end

    //icache refill abandon: registered mispredict sticky to cache_subsystem
    assign flush_refill_o = mispredict_r;
endmodule
