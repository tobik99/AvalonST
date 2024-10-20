# run_tb.tcl - Script to compile and run OSVVM Testbench in QuestaSim

# Pfade anpassen, falls notwendig
set osvvm_path "D:\OsvvmLibraries\osvvm"
set design_path "D:\OsvvmLibraries\AvalonStreamingSlaveVC\src"
set testbench_path "D:\OsvvmLibraries\AvalonStreamingSlaveVC\testbench"

# Arbeitsverzeichnis anlegen
vlib work
vmap osvvm $osvvm_path

# OSVVM Bibliotheken kompilieren
vcom -work osvvm $osvvm_path/OSVVM/NamePkg.vhd
vcom -work osvvm $osvvm_path/OSVVM/AlertLogPkg.vhd
vcom -work osvvm $osvvm_path/OSVVM/OsvvmGlobalPkg.vhd
vcom -work osvvm $osvvm_path/OSVVM/ResolutionPkg.vhd
vcom -work osvvm $osvvm_path/OSVVM/TransactionPkg.vhd
vcom -work osvvm $osvvm_path/OSVVM/ScoreboardGenericPkg.vhd
vcom -work osvvm $osvvm_path/OSVVM/RandomBasePkg.vhd
vcom -work osvvm $osvvm_path/OSVVM/RandomPkg.vhd
vcom -work osvvm $osvvm_path/OSVVM/MemoryPkg.vhd

# Design-Dateien kompilieren
vcom -work work $design_path/my_design.vhd
vcom -work work $design_path/my_verification_component.vhd

# Testbench-Dateien kompilieren
vcom -work work $testbench_path/tb_AvalonStreamSlave.vhd

# Simulation ausführen
vsim -c work.tb_AvalonStreamSlave -do "run -all; quit"

# Optional: Transkript oder Logs öffnen, falls benötigt
# transcript ./sim_results/tb_AvalonStreamSlave_transcript.txt
