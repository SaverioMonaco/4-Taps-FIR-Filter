set_param general.maxBackupLogs 0
open_hw
connect_hw_server
open_hw_target 
#open_hw_target {localhost:3121/xilinx_tcf/Digilent/210319A4332CA}
#open_hw_target 
current_hw_device [get_hw_devices xc7a100t_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7a100t_0] 0]
set_property PROBES.FILE {} [get_hw_devices xc7a100t_0]
set_property FULL_PROBES.FILE {} [get_hw_devices xc7a100t_0]
set_property PROGRAM.FILE {top.bit} [get_hw_devices xc7a100t_0]
program_hw_devices [get_hw_devices xc7a100t_0]
exit
