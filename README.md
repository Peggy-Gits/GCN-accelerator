# GCN-accelerator
This project is a GCN accelerator. The strategy is to do combination of feature and weight matrices first and then aggregate. The matrix multiplication unit pipelined the accumulation of partial sum of the inner product produced by tree-structure CSAs. The design is synthesized, and the layout is shown in the figure below.\\
<img src = https://github.com/Peggy-Gits/GCN-accelerator/blob/main/images/Innovus_Layout.png style = " width :50% ; height : auto ">
