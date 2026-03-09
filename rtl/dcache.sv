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
// Module       : dcache
// Description  : 4KB 2 Way Set-Associative Data Cache
//
// Author       : NGUYEN TO QUOC VIET
// Date         : 2026-03-08
// Version      : 1.0
// -----------------------------------------------------------------------------

module dcache
    import cache_pkg::*;
(
    //system 
    input logic clk, rst_n,
    
    //lsu - d-cache interface
    input logic [ADDR_WIDTH-1:0] addr,
    input logic mem_req,
    input logic mem_we,

    input logic [DATA_WIDTH-1:0] wdata,
    input logic [STRB_WIDTH-1:0] wstrb,

    output logic [DATA_WIDTH-1:0] rdata,
    output logic dcache_ready,
    output logic dcache_valid,

    //write buffer - d-cache interface
    output logic wb_push,
    output logic [ADDR_WIDTH-1:0] wb_addr,
    output logic [DATA_WIDTH-1:0] wb_data,
    output logic [STRB_WIDTH-1:0] wb_strb,

    input logic wb_full,
    
    //write buffer forwarding
    output logic [ADDR_WIDTH-1:0] fwd_addr,

    input logic fwd_hit,
    input logic [DATA_WIDTH-1:0] fwd_data,
    input logic [STRB_WIDTH-1:0] fwd_strb,

    //arbiter - d-cache interface
    input logic [DATA_WIDTH-1:0] arb_rdata,
    input logic arb_valid,
    input logic arb_last,
    input logic arb_grant,

    output logic dcache_req,
    output logic [ADDR_WIDTH-1:0] dcache_addr
);
    //address decode
    logic [WORD_SEL_BITS-1:0]   addr_word_sel;
    logic [DC_IDX_BITS-1:0]     addr_idx;
    logic [DC_TAG_BITS-1:0]     addr_tag;

    assign addr_word_sel = addr[WORD_OFF_BITS +: WORD_SEL_BITS];    //3:2
    assign addr_idx      = addr[LINE_OFF_BITS +: DC_IDX_BITS];      //10:4
    assign addr_tag      = addr[ADDR_WIDTH-1  -: DC_TAG_BITS];      //31:11

    //storage (2-way)
    logic [DC_TAG_BITS-1:0] cache_tag  [DC_SETS][DC_WAYS];
    logic [DATA_WIDTH-1:0] cache_data [DC_SETS][DC_WAYS][WORDS_PER_LINE];
    logic [DC_SETS-1:0][DC_WAYS-1:0] cache_valid;   //for simple reset
    logic [DC_SETS-1:0] lru;

    //tag check
    logic [DC_WAYS-1:0] way_hit;
    logic cache_hit;
    logic hit_way;  //which way hit
    logic [DATA_WIDTH-1:0] cache_rdata;

    always_comb begin
        for (int w = 0; w < DC_WAYS; w++) begin
            way_hit[w] = cache_valid[addr_idx][w] && (cache_tag[addr_idx][w] == addr_tag);
        end

        cache_hit   = |way_hit;
        hit_way     = way_hit[1];   //optimize
        cache_rdata = cache_data[addr_idx][hit_way][addr_word_sel];
    end

    //store-to-load forwarding merge
    assign fwd_addr = {addr[ADDR_WIDTH-1:WORD_OFF_BITS], {WORD_OFF_BITS{1'b0}}};
    logic [DATA_WIDTH-1:0] merged_rdata;

    always_comb begin
        for (int b = 0; b < STRB_WIDTH; b++) begin
            if (fwd_hit && fwd_strb[b])
                merged_rdata[b*8 +: 8] = fwd_data[b*8 +: 8];
            else
                merged_rdata[b*8 +: 8] = cache_rdata[b*8 +: 8];
        end
    end

    logic fwd_full_cover;
    assign fwd_full_cover = fwd_hit && (&fwd_strb);

    //refill buffer
    logic [DATA_WIDTH-1:0]      rf_buffer [WORDS_PER_LINE];
    logic [WORDS_PER_LINE-1:0]  rf_valid;
    logic [DC_TAG_BITS-1:0]     rf_tag;
    logic [DC_IDX_BITS-1:0]     rf_idx;
    logic [WORD_SEL_BITS-1:0]   rf_word_sel;

    logic rf_buffer_hit;
    assign rf_buffer_hit = rf_valid[addr_word_sel] && (rf_idx == addr_idx) && (rf_tag == addr_tag);

    //merge refill buffer with WB forwarding
    logic [DATA_WIDTH-1:0] rf_merged_rdata;

    always_comb begin
        for (int b = 0; b < STRB_WIDTH; b++) begin
            if (fwd_hit && fwd_strb[b])
                rf_merged_rdata[b*8 +: 8] = fwd_data[b*8 +: 8];
            else
                rf_merged_rdata[b*8 +: 8] = rf_buffer[addr_word_sel][b*8 +: 8];
        end
    end

    //eviction way selection
    logic evict_way;

    always_comb begin
        if (!cache_valid[rf_idx][0])
            evict_way = 1'b0;
        else if (!cache_valid[rf_idx][1])
            evict_way = 1'b1;
        else
            evict_way = lru[rf_idx];
    end
endmodule
