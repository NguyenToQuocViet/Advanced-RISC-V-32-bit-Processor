create_project -in_memory -part xc7a35ticsg324-1L 

read_verilog -sv ../rtl/axi_pkg.sv
read_verilog -sv ../rtl/cache_pkg.sv

read_verilog -sv [glob ../rtl/*.sv]

synth_design -top cache_subsystem -rtl -name rtl_1
