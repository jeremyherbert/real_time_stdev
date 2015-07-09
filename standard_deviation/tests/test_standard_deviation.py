import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestFailure
import numpy as np

from standard_deviation_filter import standard_deviation_filter

TICK = 1

@cocotb.test()
def standard_deviation_basic_test(dut):
    """windowed standard deviation test for a step transition"""

    window_size = 128
    max_value = 2**14-1

    ## model
    data = np.append(np.zeros(window_size*2), np.ones(window_size*10)*(2**14-1))
    result = standard_deviation_filter(data, window_size) 

    # non_zero = [hex(x) for x in result if x != 0]
    # print(non_zero)

    ## simulation
    # reset the dut
    dut.reset = 0
    dut.data_in = 0
    dut.clk = 0
    yield Timer(TICK)
    dut.clk = 1
    yield Timer(TICK)
    dut.reset = 1

    for i in range(window_size*2 + window_size*8): 
        dut.data_in = int(data[i])
        dut.clk = 0
        yield Timer(TICK)
        dut.clk = 1
        yield Timer(TICK)

        # clock in 'window_size' integers, plus the 28 cycle delay for variance and 14 cycle delay for sqrt
        if i >= (window_size + 28 + 6):
            desired_result = result[i-(window_size+28+6)]
            if int(dut.data_out) != desired_result:
                raise TestFailure("standard deviation output was wrong; got %i, expected %i" % (int(dut.data_out), desired_result))


    
