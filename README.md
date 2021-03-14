# FIR Filter implementation in FPGA
## Management and Analysis of Physics Dataset MOD A project
### [Saverio Monaco](https://github.com/SaverioMonaco/)
### [Javier Gerardo Carmona](https://github.com/eigen-carmona/)  

<img src="https://raw.githubusercontent.com/SaverioMonaco/4-Taps-FIR-Filter/track_saverio_10/tex/img/readme1.png" width=800>

## How to run the filter
1. Create the Xilinx environment
```console
source  /tools/Xilinx/Vivado/2018.3/settings64.sh
```

1.  build your bitstream 
```console
make clean; make
```

1. Program FPGA

```console
make program_fpga
```
1. In `script.py` change the USB port according to the correct one (use `ls -l /dev/ttyUSB*` to find it out)

1. Running the script `script.py`, the signal present in `signal.txt` will be sent to the FPGA and filtered

1. After compilation, the filtered signal will be in `fromfpga.txt`



A brief explanation of how the filter was made can be found in the [report](https://github.com/SaverioMonaco/4-Taps-FIR-Filter/blob/track_saverio_10/tex/report.pdf).

