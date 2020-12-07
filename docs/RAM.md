Assumptions made / questions about RAM - need to be verified by David Thomas
1. Asserting Read and Write illegal - what behaviour to do then? -Avalon says read and wrtie can't be done in the same cycle due to shared response signal, but we're not using one. (Not supported, fail test!)
2. Byte vs word addressing - for lb, output whole word (Avalon says ignore byteenable if you return readdata with no side effects)
	If asserted bits in byteenable are not adjacent - how to respond? Write the adjacent group starting from bit 15 or bit 1? Or just what is expected, or fail? Do whatever's convenient
	
	
	
	Test case: Testing with wait_request HIGH and LOW at different points. Control signals from master must stay constant.


If lw is used with a byte instead of x4 byte