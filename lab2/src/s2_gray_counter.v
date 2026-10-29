module user_module(
    input wire clk,
    input wire rst,
    output wire [3:0] gray,
    output wire out
);
reg [3:0] bin;
reg       out_r;

always @(posedge clk) begin
    if(rst) begin
        bin <= 0;
        out_r <= 0;
    end
    else begin
        bin <= bin + 4'b1;
        out_r <= (bin == 15);
    end
end

assign gray = bin ^ (bin >> 1);

assign out = out_r;

endmodule
