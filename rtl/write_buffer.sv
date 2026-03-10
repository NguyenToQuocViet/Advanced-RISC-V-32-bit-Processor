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
// Module       : write_buffer
// Description  : 4-Entry FIFO Write Buffer with Store-to-Load Forwarding
//
// Author       : NGUYEN TO QUOC VIET
// Date         : 2026-03-10
// Version      : 1.0
// -----------------------------------------------------------------------------

module write_buffer
    import cache_pkg::*
(
    //system
    input logic clk, rst_n;

    //dcache - write buffer interface
    input logic                     push,
    input logic [ADDR_WIDTH-1:0]    push_addr,
    input logic [DATA_WIDTH-1:0]    push_data,
    input logic [STRB_WIDTH-1:0]    push_strb,

    output logic                    wb_full,

    //store-to-load forwarding
    input logic [ADDR_WIDTH-1:0]    fwd_addr,

    output logic                    fwd_hit,
    output logic [DATA_WIDTH-1:0]   fwd_data,
    output logic [STRB_WIDTH-1:0]   fwd_strb,

    //fence support
    input logic     fence,
    
    output logic    fence_done,

    //arbiter - write buffer interface
    output logic                    arb_wr_req,
    output logic [ADDR_WIDTH-1:0]   arb_wr_addr,
    output logic [DATA_WIDTH-1:0]   arb_wr_data,
    output logic [STRB_WIDTH-1:0]   arb_wr_strb,

    input logic                     arb_wr_done
);
    //FIFO storage
    logic [WB_DEPTH] entry_valid;   //4 entry, small -> use packed
    logic [ADDR_WIDTH-1:0] entry_addr [WB_DEPTH];
    logic [DATA_WIDTH-1:0] entry_data [WB_DEPTH];
    logic [STRB_WIDTH-1:0] entry_strb [WB_DEPTH];
    
    //pointer
    //NOTE: head and tail has 1 more bit, the MSB is for recognize overlap 
    logic [WB_PTR_BITS:0] head, tail; 
    logic [WB_PTR_BITS-1:0] head_idx, tail_idx;

    assign head_idx = head[WB_PTR_BITS-1:0];
    assign tail_idx = tail[WB_PTR_BITS-1:0];

    logic ptr_idx_eq;
    assign ptr_idx_eq = (head_idx == tail_idx);

    logic empty;
    assign empty = ptr_idx_eq && (head[WB_PTR_BITS] == tail[WB_OTR_BITS]);
    assign wb_full = ptr_idx_eq && (head[WB_PTR_BITS] != tail[WB_PTR_BITS]);

    //FIFO Push and Pop
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            head        <= '0;
            tail        <= '0;
            entry_valid <= '0;
        end else begin
            //push
            if (push && !wb_full) begin
                entry_valid[tail_idx] <= 1'b1;
                entry_addr [tail_idx] <= push_addr;
                entry_data [tail_idx] <= push_data;
                entry_strb [tail_idx] <= push_strb;

                tail <= tail + 1'b1;
            end

            //pop
            if (arb_wr_done && !empty) begin
                entry_valid[head_idx] <= 1'b0;

                head <= head + 1'b1;
            end
        end
    end
endmodule
