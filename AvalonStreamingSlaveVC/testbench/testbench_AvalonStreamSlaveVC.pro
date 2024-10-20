include ../../osvvm/osvvm.pro
include ../../Common/Common.pro

library osvvm_AvalonStreamingSlaveVC

analyze ../src/AvalonStreamSlaveVC.vhd
analyze ./tb_AvalonStreamSlaveVC.vhd
simulate StreamingTest