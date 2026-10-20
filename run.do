vlib work
vlog -f src_files.list +cover -covercells
vsim -voptargs=+acc work.top -classdebug -uvmcontrol=all -cover
add wave /top/alsuif/*
add wave /top/sr_if/*
coverage save alsu.ucdb -onexit 
run -all

# quit -sim
#vcover report alsu.ucdb -details -annotate -output alsu_coverage_report.txt