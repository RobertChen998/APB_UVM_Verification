# ============================================
# APB UVM Multi-Seed Regression
# ============================================

set project_dir "your project directory"
set log_dir "$project_dir/your log directory"

file mkdir $log_dir

set seeds {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20}

foreach seed $seeds {

    puts ""
    puts "=========================================="
    puts " Running APB regression seed = $seed"
    puts "=========================================="

    set_property -name {xsim.simulate.xsim.more_options} \
    -value "-sv_seed $seed" \
    -objects [get_filesets sim_1]

    if {[current_sim -quiet] ne ""} {
        close_sim -force
    }

    launch_simulation -mode behavioral

    run all

    set src_log "$project_dir/APB_verification.sim/sim_1/behav/xsim/simulate.log"

    set dst_log "$log_dir/seed_${seed}.log"

    if {[file exists $src_log]} {
        file copy -force $src_log $dst_log
        puts "Saved log: $dst_log"
    } else {
        puts "WARNING: Cannot find simulation log:"
        puts "$src_log"
    }

    close_sim -force
}

puts ""
puts "=========================================="
puts " Regression completed"
puts " Logs: $log_dir"
puts "=========================================="