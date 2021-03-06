# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in orjIIIr.v to working dir
# could also have multiple verilog files
vlog sequence_detector.v

#load simulation using HexDecoder as the top level simulation module
vsim sequence_detector

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# SW[1] should control LED[0]

force {SW[1]} 0
force {KEY[0]} 0

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 0
force {KEY[0]} 1

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 0
force {KEY[0]} 0

run 10ns

# SW[1] should control LED[0]
force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 0

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 1

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 0

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 1

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 0

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 1

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 0

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 1

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 0

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 1

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 0
force {KEY[0]} 0

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 0
force {KEY[0]} 1

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 0
force {KEY[0]} 0

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 0
force {KEY[0]} 1

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 0

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 1

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 0

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 1

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 0
force {KEY[0]} 0

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 0
force {KEY[0]} 1

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 0

run 10ns


# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 1

run 10ns

# SW[1] should control LED[0]

force {SW[1]} 1
force {KEY[0]} 0

run 10ns