# ==========================================
# sim.tcl
# ==========================================
set project_name [file tail [file dirname [pwd]]]
open_project ${project_name}.xpr

# Yêu cầu Vivado tự động tìm và set Top Module cho file testbench
set_property top_auto_set 1 [get_filesets sim_1]
update_compile_order -fileset sim_1

# Cấu hình chạy mô phỏng đến khi kết thúc lệnh $finish
set_property -name {xsim.simulate.runtime} -value {-all} -objects [get_filesets sim_1]

puts "========== Launching Simulation =========="
launch_simulation

puts "SUCCESS: Simulation completed"

# Giữ GUI mở nếu chạy chế độ GUI (make sim)
if {[string match "*gui*" $rdi::mode]} {
    puts "Waveform window opened. Close manually when done."
} else {
    close_sim
    close_project
}
