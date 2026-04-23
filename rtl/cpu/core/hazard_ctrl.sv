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
// Module       : hazard_ctrl
// Description  : Stall/flush distribution across pipeline registers.
//                Note: if_id_flush is owned by FCU (CWF + mispredict + ignore_valid).
//
// Author       : NGUYEN TO QUOC VIET
// Date         : 2026-04-23
// Version      : 1.0
// -----------------------------------------------------------------------------

module hazard_ctrl
    import cpu_pkg::*;
(
    //hazard sources
    input  logic    load_use_stall,
    input  logic    dcache_stall,
    input  logic    ex_flush,
    input  logic    mispredict_r,

    //per-stage stall (freeze pipeline reg)
    output logic    fcu_stall,
    output logic    if_id_stall,
    output logic    id_ex_stall,
    output logic    ex_mem_stall,
    output logic    mem_wb_stall,

    //per-stage flush (insert NOP into pipeline reg)
    output logic    id_ex_flush,
    output logic    ex_mem_flush,
    output logic    mem_wb_flush
);
    //dcache miss freeze all; load-use only freeze IF+ID
    assign fcu_stall    = dcache_stall | load_use_stall;
    assign if_id_stall  = dcache_stall | load_use_stall;
    assign id_ex_stall  = dcache_stall;
    assign ex_mem_stall = dcache_stall;
    assign mem_wb_stall = dcache_stall;

    //mispredict_r kills wrong-path in ID/EX + EX/MEM
    //ex_flush from load-use bubble: kill ID/EX only
    assign id_ex_flush  = mispredict_r | ex_flush;
    assign ex_mem_flush = mispredict_r;
    assign mem_wb_flush = 1'b0;
endmodule
