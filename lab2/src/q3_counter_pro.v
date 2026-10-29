module Counter #(
    parameter MIN_VALUE = 8'd10,
    parameter MAX_VALUE = 8'd13
)(
    input wire clk,
    input wire rst,
    input wire enable,
    output wire out
);
reg [7:0] counter;

always @(posedge clk) begin
    if(rst)
        counter <= 0;
    else if(enable == 0)
        counter <= 0;
    else if(counter < MIN_VALUE || counter >= MAX_VALUE)
        counter <= MIN_VALUE;
    else
        counter <= counter + 8'b1;
end

assign out = (counter == MAX_VALUE);

endmodule

module user_module(
    input wire clk,
    input wire rst,
    input wire enable,
    output wire out
);
Counter #(
    .MIN_VALUE(8'd10),
    .MAX_VALUE(8'd13)
) u_counter(
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .out(out)
);
endmodule
