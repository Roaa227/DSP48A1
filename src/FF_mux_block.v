module FF_MUX_block(d, q, CE, clk, rst, Z_REG);
    parameter RSTTYPE = "SYNC";
    parameter size = 1 ;

    input [size-1 : 0] d;
    input clk, rst, CE, Z_REG;

    output [size-1 : 0] q;

    reg [size-1 : 0] q_seq;

    generate
        if(RSTTYPE == "ASYNC") begin
            always @(posedge clk or posedge rst) begin
                if(rst) begin
                    q_seq <= 0;
                end else begin
                        if(CE)
                            q_seq <= d;
                end
            end
        end
        else begin
            always @(posedge clk) begin
                if(rst) begin
                    q_seq <= 0;
                end else begin
                        if(CE)
                            q_seq <= d;
                end
            end
        end
    endgenerate

    assign q = (Z_REG)? q_seq : d;

endmodule