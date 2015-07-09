
import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestFailure
import random
import math

TICK = 1
INPUT_WIDTH = 28

# @cocotb.test()
# def sqrt_basic_test(dut):
#     """Test for sqrt(127)"""
#     i = 127

#     dut.integer_input = i
#     dut.reset = 0
#     dut.clk = 0
#     yield Timer(TICK)
#     dut.clk = 1
#     yield Timer(TICK)
#     dut.clk = 0
#     yield Timer(TICK)
#     dut.reset = 1
#     yield Timer(TICK)

#     for _ in range(INPUT_WIDTH):
#         dut.clk = 1
#         yield Timer(TICK)
#         dut.clk = 0
#         yield Timer(TICK)
#         dut.integer_input = 0

#     integer_sqrt = int(math.sqrt(i))
#     remainder = int(i - integer_sqrt**2)
#     if int(dut.result) != int(math.sqrt(i)) or int(dut.remainder) != remainder:
#         raise TestFailure(
#             "sqrt is incorrect for %i; r: %s, q: %s, expected r: %s, q: %s" % (i, int(dut.remainder), int(dut.result), integer_sqrt, remainder)) 

#     # check the zeros a few times as well 
#     for _ in range(5):
#         dut.clk = 1
#         yield Timer(TICK)
#         dut.clk = 0
#         yield Timer(TICK)

#         if int(dut.result) != 0 or int(dut.remainder) != 0:
#             raise TestFailure(
#                 "sqrt is incorrect for %i; r: %s, q: %s, expected r: %s, q: %s" % (i, int(dut.remainder), int(dut.result), integer_sqrt, remainder)) 


# @cocotb.test()
# def sqrt_7bit_test(dut):
#     """Test for sqrt up to 127 with resets"""

#     for i in range(127):
#         dut.integer_input = i
#         dut.reset = 0
#         dut.clk = 0
#         yield Timer(TICK)
#         dut.clk = 1
#         yield Timer(TICK)
#         dut.clk = 0
#         yield Timer(TICK)
#         dut.reset = 1
#         yield Timer(TICK)

#         for _ in range(int(INPUT_WIDTH)):
#             dut.clk = 1
#             yield Timer(TICK)
#             dut.clk = 0
#             yield Timer(TICK)

#         if int(dut.result) != int(math.sqrt(i)):
#             raise TestFailure(
#                 "sqrt is incorrect for %i; r: %s, q: %s" % (i, int(dut.remainder), int(dut.result))) 


@cocotb.test()
def sqrt_sequential_7bit_test(dut):
    """sequential sqrt test up to 127"""
    pipeline_delay = INPUT_WIDTH
    print("pipeline delay is: ", pipeline_delay)

    dut.reset = 0
    dut.clk = 0
    yield Timer(TICK)
    dut.clk = 1
    yield Timer(TICK)
    dut.clk = 0
    yield Timer(TICK)
    dut.reset = 1
    yield Timer(TICK)

    for i in range(128):
        #print(i)
        dut.integer_input = i

        if i >= pipeline_delay:
            actual_input = i - pipeline_delay
            
            if actual_input == 0:  # zero case
                integer_sqrt = 0
                remainder = 0
            else:
                integer_sqrt = int(math.sqrt(actual_input))
                remainder = int((i-pipeline_delay) - integer_sqrt**2)

            #print("actually: %i; got r: %s, q: %s, expected r: %s, q: %s" % (actual_input, hex(int(dut.remainder)), hex(int(dut.result)), hex(remainder), hex(integer_sqrt)))

            if int(dut.result) != integer_sqrt or int(dut.remainder) != remainder:
                raise TestFailure(
                    "sqrt is incorrect for %i; r: %s, q: %s, expected: r: %s, q: %s" % (i, int(dut.remainder), int(dut.result), remainder, integer_sqrt))

        dut.clk = 1
        yield Timer(TICK)
        dut.clk = 0
        yield Timer(TICK)

# @cocotb.test()
# def sqrt_randomised_test(dut):
#     """Checks the sqrt of 1000 random integers"""

#     max_number = 2**(INPUT_WIDTH-1) - 1

#     for _ in range(1000):
#         i = random.randint(0, max_number)

#         dut.integer_input = i
#         dut.reset = 0
#         dut.clk = 0
#         yield Timer(TICK)
#         dut.clk = 1
#         yield Timer(TICK)
#         dut.clk = 0
#         yield Timer(TICK)
#         dut.reset = 1
#         yield Timer(TICK)

#         for _ in range(int(INPUT_WIDTH/2)+1):
#             dut.clk = 1
#             yield Timer(TICK)
#             dut.clk = 0
#             yield Timer(TICK)

#         if int(dut.result) != int(math.sqrt(i)):
#             raise TestFailure(
#                 "sqrt is incorrect for %i; r: %s, q: %s" % (i, int(dut.remainder), int(dut.result))) 



