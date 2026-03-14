# ==========================================
# elaborate.tcl
# ==========================================
create_project -in_memory -part xc7a35ticsg324-1L 

# Hàm đệ quy quét toàn bộ thư mục con để tìm file
proc get_files_recursive {dir pattern} {
    set files [glob -nocomplain -directory $dir $pattern]
    foreach sub_dir [glob -nocomplain -type d -directory $dir *] {
        set files [concat $files [get_files_recursive $sub_dir $pattern]]
    }
    return $files
}

# 1. BẮT BUỘC: Đọc tất cả các file Package trước
set pkg_files [get_files_recursive ../rtl "*_pkg.sv"]
if {[llength $pkg_files] > 0} { 
    read_verilog -sv $pkg_files 
    puts "Loaded Packages: $pkg_files"
}

# 2. Đọc toàn bộ các file Design còn lại (loại trừ các file pkg)
set design_files {}
foreach f [get_files_recursive ../rtl "*.sv"] {
    if {[string first "_pkg.sv" $f] == -1} { 
        lappend design_files $f 
    }
}
if {[llength $design_files] > 0} { 
    read_verilog -sv $design_files 
    puts "Loaded Design Files: [llength $design_files] files"
}

# Lưu ý: Top module đang set mặc định là cache_subsystem
synth_design -top cache_subsystem -rtl -name rtl_1
