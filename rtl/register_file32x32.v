module register_file(
    input logic clk,
    input logic reset,

    /* 2 read ports and 2 write ports required */
      // read ports a and b
    input logic[4:0]    read_addr_a,
    output logic[31:0]  read_data_a,

    input logic[4:0]    read_addr_b,
    output logic[31:0]  read_data_b,

      // write ports c and d
    input logic[4:0]    write_addr_c,
    input logic         write_enable_c,
    input logic[31:0]   write_data_c,

    input logic[4:0]    write_addr_d,
    input logic         write_enable_d,
    input logic[31:0]   write_data_d
);

    logic[31:0] regs[31:0];
    integer i;

    assign read_data_a = reset ? 0 : regs[read_addr_a];
    assign read_data_b = reset ? 0 : regs[read_addr_b];

    always_ff @(posedge clk) begin
        if (reset) begin
            for (i=0; i<32; i=i+1) begin
                regs[i] <= 0;
            end
        end
        else if (write_enable_c || write_enable_d) begin
                if (write_enable_c && (write_addr_c != 0)) begin
                    regs[write_addr_c] <= write_data_c;
                end

                if (write_enable_d && (write_addr_c != 0)) begin
                    regs[write_addr_d] <= write_data_d;
                end
        end
    end
    
endmodule
